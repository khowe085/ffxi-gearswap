using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.ComponentModel;
using System.IO;
using System.Net.Http;

namespace GearTools;

// The outside sources the tools read from the cache: Windower's resource files, and two IzaKastra repos at the commits
// docs/ffxi-mechanics.md cites file and line numbers from. A tool fetches what it reads when the cache lacks it, and
// says so on standard error, where it can't mix with what the tool writes for another to read. fetch-sources.cs
// fetches them all, and the resources again with --refresh.
static class Sources
{
	public static IReadOnlyList<string> ResourceFiles { get; }

	public static IReadOnlyList<string> RepoNames { get; }

	// Windower's resources follow the live game, so they are taken from the branch head, not pinned. The tests point
	// GEAR_TOOLS_RESOURCES at a stand-in on their own machine.
	static string ResourcesUrl => Environment.GetEnvironmentVariable("GEAR_TOOLS_RESOURCES") ?? "https://raw.githubusercontent.com/Windower/Resources/master/resources_data/";

	static Dictionary<string, (string Url, string Commit)> repos;
	static string handPlaced;

	static Sources()
	{
		ResourceFiles = ["items.lua", "item_descriptions.lua", "spells.lua"];
		// docs/ffxi-mechanics.md quotes these two by file and line, so a different commit would make its references wrong.
		repos = new()
		{
			["wsdist_beta"] = ("https://github.com/IzaKastra/wsdist_beta", "d12ac5923ccace977ad55d172c8698b5886b9e4f"),
			["bg_job_guides"] = ("https://github.com/IzaKastra/bg_job_guides", "f264ae4f3bceb4d6e98bb7df5c4c22b21315c407"),
		};
		RepoNames = [.. repos.Keys];
		handPlaced = "put there by hand";
	}

	public static void FillResources()
	{
		foreach (var file in ResourceFiles.Where(file => File.Exists(Tool.InCache("res", file)) is false))
			Console.Error.WriteLine(Download(file));
	}

	// Downloads a resource file into the cache, over any copy there, and says how big it is. A download that fails
	// stops the tool.
	public static string Download(string file)
	{
		var path = Tool.InCache("res", file);
		byte[] bytes;
		try
		{
			using var http = new HttpClient();
			bytes = http.GetByteArrayAsync(ResourcesUrl + file).GetAwaiter().GetResult();
		}
		catch (Exception problem) when (problem is HttpRequestException or TaskCanceledException)
		{
			Tool.Fail($"res/{file}: couldn't download it. {problem.Message}");
			throw;
		}
		Directory.CreateDirectory(Path.GetDirectoryName(path)!);
		// The download takes the file's place whole, so no tool reads half of one. Windows won't replace a file another
		// tool has open, and says so.
		var partial = $"{path}.{Environment.ProcessId}.partial";
		File.WriteAllBytes(partial, bytes);
		try
		{
			File.Move(partial, path, true);
		}
		catch (IOException problem)
		{
			File.Delete(partial);
			Tool.Fail($"res/{file}: couldn't put the download in place. {problem.Message}");
		}
		return $"res/{file}: downloaded ({bytes.Length / 1024} KB)";
	}

	public static string Describe(string file)
	{
		var path = Tool.InCache("res", file);
		return $"res/{file}: present ({new FileInfo(path).Length / 1024} KB, from {File.GetLastWriteTime(path):yyyy-MM-dd})";
	}

	public static void FillRepo(string name)
	{
		var outcome = FetchRepo(name);
		if (outcome.StartsWith("present") is false && outcome != handPlaced)
			Console.Error.WriteLine($"{name}: {outcome}");
	}

	// Brings a pinned repo's folder in the cache to its commit, and says what that took. A git failure stops the tool.
	public static string FetchRepo(string name)
	{
		var (url, commit) = repos[name];
		// The tests point a repo at one they make on their own machine: GEAR_TOOLS_REPO_<NAME> is "<url> <commit>".
		var standIn = Environment.GetEnvironmentVariable("GEAR_TOOLS_REPO_" + name.ToUpperInvariant())?.Split(' ', 2);
		if (standIn is { Length: 2 })
			(url, commit) = (standIn[0], standIn[1]);
		try
		{
			return FillRepoFolder(Tool.InCache(name), url, commit);
		}
		catch (InvalidOperationException problem)
		{
			Tool.Fail($"{name}: {problem.Message}");
			throw;
		}
		catch (Win32Exception problem)
		{
			Tool.Fail($"{name}: couldn't run git, which fetching it takes. {problem.Message}");
			throw;
		}
	}

	// GitSource.Fetch, with two ways round it. A folder that holds files and no .git was put there by hand, as the
	// tests' fixture is, and is read as it is. A fetch that finishes leaves the commit it fetched in a file beside the
	// folder, so a tool that finds the folder at the pinned commit needs no git.
	public static string FillRepoFolder(string folder, string url, string commit)
	{
		if (Directory.Exists(folder) && Directory.Exists(Path.Combine(folder, ".git")) is false && Directory.EnumerateFileSystemEntries(folder).Any())
			return handPlaced;
		var fetched = folder + ".commit";
		if (Directory.Exists(folder) && File.Exists(fetched) && File.ReadAllText(fetched).Trim() == commit)
			return $"present at {commit[..7]}";
		var outcome = GitSource.Fetch(folder, url, commit);
		File.WriteAllText(fetched, commit + "\n");
		return outcome;
	}
}
