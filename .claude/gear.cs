// Runs the gear tools in .claude/tools, and the repo's tests, from builds kept for the content of their source: an
// app's own file, lib/ and Directory.Build.props. An app is built only when no build of that source is kept, so an
// edit to any of them brings a new build, and every checkout with the same source shares one.
//
//   dotnet run .claude/gear.cs -- <tool> [<option>...]
//   dotnet run .claude/gear.cs -- test [--all] [<category>...] [--filter <text>]
//
// <tool> is the tool's file name without .cs, as check-export, and the options after it are the tool's own. The tool
// works on this checkout.
//
// test runs each category of tests whose files changed since it last passed, in this checkout or any other: tools
// (tests/run-tests.cs, on the made-up character there), data (the tools' checks of each character's gear files and
// docs), and gearswap. --all runs every category, and a category named runs whether or not it changed. --filter runs
// only the tools tests whose name holds the text, and counts for no pass.
//
// Builds and passes are kept in ~/.cache/ffxi-gearswap (%LOCALAPPDATA%\ffxi-gearswap on Windows), and a tool's builds
// unused for 30 days are removed when it is built again. GEAR_TOOLS_BUILDS and GEAR_TOOLS_PASSES keep them elsewhere,
// for the tests.
using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Diagnostics;
using System.IO;
using System.Security.Cryptography;
using System.Text.Json;
using System.Text.RegularExpressions;

var launcher = (string)AppContext.GetData("EntryPointFilePath")!;
// The tests run the launcher on checkouts of their own, which GEAR_TOOLS_ROOT names.
var repo = Environment.GetEnvironmentVariable("GEAR_TOOLS_ROOT") ?? Path.GetFullPath(Path.Combine(Path.GetDirectoryName(launcher)!, ".."));
var toolsDir = Path.Combine(repo, ".claude", "tools");
var builds = new Builds(Environment.GetEnvironmentVariable("GEAR_TOOLS_BUILDS") ?? Path.Combine(SharedFolder(), "builds"), toolsDir, launcher);

if (args.Length == 0)
	return Stop("Usage: dotnet run .claude/gear.cs -- <tool> [<option>...]\n"
		+ "       dotnet run .claude/gear.cs -- test [--all] [<category>...] [--filter <text>]\n"
		+ $"Tools: {ToolNames()}");
if (args[0] == "test")
	return new TestCommand(repo, builds, Environment.GetEnvironmentVariable("GEAR_TOOLS_PASSES") ?? Path.Combine(SharedFolder(), "passes"), launcher).Run(args[1..]);
var source = Path.Combine(toolsDir, args[0] + ".cs");
if (File.Exists(source) is false)
	return Stop($"No tool named {args[0]} in .claude/tools. Tools: {ToolNames()}");
var assembly = builds.Get(source);
if (assembly is null)
	return 2;
return Apps.Run(assembly, args[1..], repo);

string ToolNames() => string.Join(" ", Directory.GetFiles(toolsDir, "*.cs").Select(Path.GetFileNameWithoutExtension).Order(StringComparer.Ordinal));

static int Stop(string message)
{
	Console.Error.WriteLine(message);
	return 2;
}

// Kept for every checkout: ~/.cache/ffxi-gearswap, or %LOCALAPPDATA%\ffxi-gearswap on Windows.
static string SharedFolder() => OperatingSystem.IsWindows()
	? Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "ffxi-gearswap")
	: Path.Combine(Environment.GetEnvironmentVariable("XDG_CACHE_HOME") ?? Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), ".cache"), "ffxi-gearswap");

// The test command. Each category runs when the files its result rests on changed since it last passed: a pass is
// kept under the hash of those files, so a checkout with the same files doesn't run it again either.
sealed class TestCommand
{
	string repo;
	string toolsDir;
	string cache;
	Builds builds;
	string passes;
	string launcher;
	string[] categories;

	public TestCommand(string repo, Builds builds, string passes, string launcher)
	{
		this.repo = repo;
		this.builds = builds;
		this.passes = passes;
		this.launcher = launcher;
		toolsDir = Path.Combine(repo, ".claude", "tools");
		// The tools find the cache the same way (lib/Tool.cs).
		cache = Environment.GetEnvironmentVariable("GEAR_TOOLS_CACHE") ?? Path.Combine(repo, ".claude", "cache");
		categories = ["tools", "data", "gearswap"];
	}

	public int Run(string[] arguments)
	{
		var all = false;
		string? filter = null;
		var named = new List<string>();
		for (var i = 0; i < arguments.Length; i++)
		{
			if (arguments[i] == "--all")
			{
				all = true;
			}
			else if (arguments[i] == "--filter")
			{
				if (i + 1 >= arguments.Length)
					return Stop("--filter needs the text to look for");
				filter = arguments[++i];
			}
			else if (categories.Contains(arguments[i]))
			{
				named.Add(arguments[i]);
			}
			else
			{
				return Stop($"No test category named {arguments[i]}. Categories: {string.Join(" ", categories)}");
			}
		}
		if (filter is not null && named.SequenceEqual(["tools"]) is false)
			return Stop("--filter is for the tools tests alone: test tools --filter <text>");
		var failed = false;
		foreach (var category in categories.Where(category => named.Count == 0 || named.Contains(category)))
		{
			if (Test(category, all || named.Count > 0, filter) is false)
				failed = true;
		}
		return failed ? 1 : 0;
	}

	// Runs a category, unless it passed with these files and isn't forced to run, and says how it went. False when it
	// failed.
	bool Test(string category, bool forced, string? filter)
	{
		if (category == "gearswap")
		{
			Console.WriteLine("gearswap: no tests yet");
			return true;
		}
		var pass = Path.Combine(passes, category + "-" + Fingerprint.Of(Inputs(category).Select(file => (Path.GetRelativePath(repo, file).Replace('\\', '/'), file))));
		if (forced is false && File.Exists(pass))
		{
			Console.WriteLine($"{category}: no change since it last passed");
			return true;
		}
		var watch = Stopwatch.StartNew();
		if ((category == "tools" ? RunToolsTests(filter) : RunDataChecks()) is false)
		{
			Console.WriteLine($"{category}: FAILED");
			return false;
		}
		Console.WriteLine($"{category}: passed in {watch.Elapsed.TotalSeconds:0.0} s");
		// A filtered run tested only some of the files.
		if (filter is null)
		{
			Directory.CreateDirectory(passes);
			File.WriteAllText(pass, "");
		}
		return true;
	}

	// The files a category's result rests on. The tools tests run on a fixture of their own, so only the tools'
	// folder counts for them. The data checks rest on the data and the docs they check, the tools' source, and what of
	// the cache can differ between checkouts: Windower's resources and bg-wiki's rank tables.
	IEnumerable<string> Inputs(string category)
	{
		if (category == "tools")
			return FilesUnder(toolsDir).Append(launcher);
		return FilesUnder(Path.Combine(repo, "data"))
			.Concat(FilesUnder(Path.Combine(repo, "docs")))
			.Concat(Directory.GetFiles(toolsDir, "*.cs"))
			.Concat(FilesUnder(Path.Combine(toolsDir, "lib")))
			.Concat(IfThere(Path.Combine(toolsDir, "Directory.Build.props")))
			.Append(launcher)
			.Concat(FilesUnder(Path.Combine(cache, "res")))
			.Concat(IfThere(Path.Combine(cache, "ranks", "ranks.json")));
	}

	// Builds every tool and the tests, and runs the tests with a file that says where each tool's build is, so they
	// run the tools without building them.
	bool RunToolsTests(string? filter)
	{
		var tools = Directory.GetFiles(toolsDir, "*.cs").Order(StringComparer.Ordinal).ToList();
		var apps = tools.Append(Path.Combine(toolsDir, "tests", "run-tests.cs")).ToList();
		var assemblies = new string?[apps.Count];
		Parallel.For(0, apps.Count, i => assemblies[i] = builds.Get(apps[i]));
		if (assemblies.Contains(null))
			return false;
		var manifest = Path.Combine(Path.GetTempPath(), "gear-test-builds-" + Guid.NewGuid().ToString("N")[..8] + ".json");
		using (var file = File.Create(manifest))
		using (var json = new Utf8JsonWriter(file, new JsonWriterOptions { Indented = true }))
		{
			json.WriteStartObject();
			for (var i = 0; i < tools.Count; i++)
				json.WriteString(Path.GetFileNameWithoutExtension(tools[i]), assemblies[i]);
			json.WriteEndObject();
		}
		try
		{
			string[] arguments = filter is null ? [] : [filter];
			return Apps.Run(assemblies[^1]!, arguments, repo, new Dictionary<string, string> { ["GEAR_TOOLS_TEST_BUILDS"] = manifest }) == 0;
		}
		finally
		{
			File.Delete(manifest);
		}
	}

	// Reads each character's gear files into sets files, checks those against the export, the blue magic lists and
	// the gear list, and lints the docs with the character's own. Then checks the rank documents, when this checkout's
	// cache has bg-wiki's rank tables to check them against: those carry the day they were read, so they aren't
	// fetched for the check.
	bool RunDataChecks()
	{
		var sets = Path.Combine(Path.GetTempPath(), "gear-data-" + Guid.NewGuid().ToString("N")[..8]);
		Directory.CreateDirectory(sets);
		var passed = true;
		try
		{
			foreach (var character in Characters())
			{
				var lists = new List<string>();
				foreach (var gear in GearFiles(character))
				{
					var json = Path.Combine(sets, $"{character}_{gear.Job}.json");
					passed &= Check("sel-sets", Path.GetRelativePath(repo, gear.File).Replace('\\', '/'), gear.Job, "--out", json);
					// What sel-sets couldn't follow it notes and leaves out, so the rest is still worth checking.
					if (File.Exists(json) is false)
						continue;
					lists.AddRange(["--in", json]);
					passed &= Check("check-export", "--in", json);
					if (gear.Job == "BLU")
						passed &= Check("check-blu-spells", "--in", json);
				}
				if (lists.Count > 0)
					passed &= Check("gear-list", [.. lists]);
				passed &= Check("doc-lint", "--char", character);
			}
			if (File.Exists(Path.Combine(cache, "ranks", "ranks.json")))
				passed &= Check("rank-doc", "--check");
			else
				Console.WriteLine("data: rank-doc --check skipped: this checkout's cache has no bg-wiki rank tables (rank-tables reads them)");
		}
		finally
		{
			Directory.Delete(sets, true);
		}
		return passed;
	}

	// Runs a tool for the data checks, and says whether it found nothing wrong.
	bool Check(string tool, params string[] arguments)
	{
		Console.WriteLine($"data: {tool} {string.Join(" ", arguments.Select(argument => Path.IsPathRooted(argument) ? Path.GetFileName(argument) : argument))}");
		var assembly = builds.Get(Path.Combine(toolsDir, tool + ".cs"));
		return assembly is not null && Apps.Run(assembly, arguments, repo) == 0;
	}

	// The characters as lib/Characters.cs finds them: each folder under data/ that holds its notes or its gear list.
	IEnumerable<string> Characters()
	{
		var data = Path.Combine(repo, "data");
		if (Directory.Exists(data) is false)
			return [];
		return Directory.GetDirectories(data)
			.Select(folder => Path.GetFileName(folder))
			.Where(name => File.Exists(Path.Combine(data, name, name + "_notes.md")) || File.Exists(Path.Combine(data, name, name + "_gear_list.md")))
			.Order(StringComparer.Ordinal)
			.ToList();
	}

	// A character's Sel gear files, <Character>_<Job>_Gear.lua, as sel-sets.cs reads their names.
	IEnumerable<GearFile> GearFiles(string character)
	{
		var name = new Regex("^" + Regex.Escape(character) + @"_(?<job>[A-Za-z]{3})_gear\.lua$", RegexOptions.IgnoreCase);
		return Directory.GetFiles(Path.Combine(repo, "data", character), "*.lua")
			.Order(StringComparer.Ordinal)
			.Select(file => (Path: file, Found: name.Match(Path.GetFileName(file))))
			.Where(file => file.Found.Success)
			.Select(file => new GearFile(file.Path, file.Found.Groups["job"].Value.ToUpperInvariant()))
			.ToList();
	}

	static IEnumerable<string> FilesUnder(string folder) => Directory.Exists(folder) ? Directory.GetFiles(folder, "*", SearchOption.AllDirectories) : [];

	static IEnumerable<string> IfThere(string file) => File.Exists(file) ? [file] : [];

	static int Stop(string message)
	{
		Console.Error.WriteLine(message);
		return 2;
	}
}

sealed class GearFile
{
	public string File { get; }

	public string Job { get; }

	public GearFile(string file, string job)
	{
		File = file;
		Job = job;
	}
}

// The kept builds of the apps in .claude/tools, each in a folder named for the app and the hash of its source.
sealed class Builds
{
	string folder;
	string toolsDir;
	string launcher;

	public Builds(string folder, string toolsDir, string launcher)
	{
		this.folder = folder;
		this.toolsDir = toolsDir;
		this.launcher = launcher;
	}

	// The app's assembly, built first when no build of its source is kept. Null when it doesn't build, after writing
	// the compiler's errors.
	public string? Get(string source)
	{
		var name = Path.GetFileNameWithoutExtension(source);
		var kept = Path.Combine(folder, name + "-" + Hash(source));
		var assembly = Path.Combine(kept, name + ".dll");
		if (File.Exists(assembly) is false && Build(source, name, kept) is false)
			return null;
		// The folder's time is when the build was last used, which decides when it is removed.
		Directory.SetLastWriteTimeUtc(kept, DateTime.UtcNow);
		return assembly;
	}

	bool Build(string source, string name, string kept)
	{
		var locks = Path.Combine(folder, "locks");
		Directory.CreateDirectory(locks);
		// Another run may be building the same source: one builds it, and the others wait for it and take its build.
		using var held = Lock(Path.Combine(locks, Path.GetFileName(kept)));
		if (Directory.Exists(kept))
			return true;
		Console.Error.WriteLine($"Building {name}");
		// The build's own files go to the temp folder, not to the dotnet folder that keeps a build of each app by path.
		var work = Path.Combine(Path.GetTempPath(), "gear-build-" + Guid.NewGuid().ToString("N")[..8]);
		var output = kept + ".partial";
		try
		{
			Delete(output);
			var build = Finished.Run("dotnet", "build", source, "--artifacts-path", work, "-o", output, "--nologo", "-v", "q");
			if (build.ExitCode != 0)
			{
				Console.Error.WriteLine($"{name}.cs doesn't build:\n{build.Output.Trim()}");
				return false;
			}
			Directory.Move(output, kept);
		}
		finally
		{
			Delete(work);
			Delete(output);
		}
		RemoveUnused(name, kept);
		return true;
	}

	void RemoveUnused(string name, string kept)
	{
		var unused = DateTime.UtcNow.AddDays(-30);
		foreach (var old in Directory.GetDirectories(folder, name + "-*").Where(dir => dir != kept && Directory.GetLastWriteTimeUtc(dir) < unused))
		{
			try
			{
				Delete(old);
				File.Delete(Path.Combine(folder, "locks", Path.GetFileName(old)));
			}
			catch (Exception problem) when (problem is IOException or UnauthorizedAccessException)
			{
				// Windows keeps a running build's files open; it goes when the tool is next built.
			}
		}
	}

	// The app's file, lib/ and Directory.Build.props, which every app here compiles with it, and this launcher, which
	// says how they are built.
	string Hash(string source)
	{
		var lib = Path.Combine(toolsDir, "lib");
		var shared = Directory.Exists(lib) ? Directory.GetFiles(lib, "*.cs") : [];
		return Fingerprint.Of(shared.Prepend(source).Append(Path.Combine(toolsDir, "Directory.Build.props"))
			.Select(file => (Path.GetRelativePath(toolsDir, file).Replace('\\', '/'), file))
			.Append(("launcher", launcher)));
	}

	static FileStream Lock(string path)
	{
		while (true)
		{
			try
			{
				return new FileStream(path, FileMode.OpenOrCreate, FileAccess.ReadWrite, FileShare.None);
			}
			catch (IOException)
			{
				Thread.Sleep(100);
			}
		}
	}

	static void Delete(string folder)
	{
		if (Directory.Exists(folder))
			Directory.Delete(folder, true);
	}
}

// What a set of files holds, as 32 hex digits: each file's name and content, and the runtime, since what is built for
// one runtime may not run on the next.
static class Fingerprint
{
	public static string Of(IEnumerable<(string Name, string Path)> files)
	{
		using var hash = IncrementalHash.CreateHash(HashAlgorithmName.SHA256);
		foreach (var file in files.OrderBy(file => file.Name, StringComparer.Ordinal))
		{
			hash.AppendData(Encoding.UTF8.GetBytes(file.Name + "\n"));
			hash.AppendData(SHA256.HashData(File.Exists(file.Path) ? File.ReadAllBytes(file.Path) : []));
		}
		hash.AppendData(Encoding.UTF8.GetBytes(Environment.Version.ToString()));
		return Convert.ToHexString(hash.GetHashAndReset())[..32].ToLowerInvariant();
	}
}

// Runs a built app with this launcher's input and output, on the checkout given.
static class Apps
{
	public static int Run(string assembly, IEnumerable<string> arguments, string repo, IReadOnlyDictionary<string, string>? environment = null)
	{
		var start = new ProcessStartInfo("dotnet");
		start.ArgumentList.Add(assembly);
		foreach (var argument in arguments)
			start.ArgumentList.Add(argument);
		// The build may have been made in another checkout, and knows only that one's path.
		start.Environment["GEAR_TOOLS_ROOT"] = repo;
		foreach (var variable in environment ?? new Dictionary<string, string>())
			start.Environment[variable.Key] = variable.Value;
		using var process = Process.Start(start)!;
		process.WaitForExit();
		return process.ExitCode;
	}
}

// A process run to its end, with what it wrote to either stream.
sealed class Finished
{
	public int ExitCode { get; }

	public string Output { get; }

	public Finished(int exitCode, string output)
	{
		ExitCode = exitCode;
		Output = output;
	}

	public static Finished Run(string program, params string[] arguments)
	{
		var start = new ProcessStartInfo(program) { RedirectStandardOutput = true, RedirectStandardError = true };
		foreach (var argument in arguments)
			start.ArgumentList.Add(argument);
		using var process = Process.Start(start)!;
		// Read both streams at once, so a full error pipe can't stall the process while this waits on its output.
		var error = process.StandardError.ReadToEndAsync();
		var output = process.StandardOutput.ReadToEnd();
		process.WaitForExit();
		return new Finished(process.ExitCode, output + error.Result);
	}
}
