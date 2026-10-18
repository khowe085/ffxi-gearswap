// Runs the gear tools in .claude/tools, builds them, and runs the repo's tests.
//
//   dotnet run .claude/gear.cs -- <tool> [<option>...]
//   dotnet run .claude/gear.cs -- build
//   dotnet run .claude/gear.cs -- test [--all] [<category>...] [--filter <text>]
//
// <tool> is the tool's file name without .cs, as check-export, and the options after it are the tool's own. A tool runs
// from its build in this checkout's .claude/cache/builds, made again first whenever its source (its file, lib/ or
// Directory.Build.props) changed since. build brings every tool's build up to date at once.
//
// test runs each category of tests whose files changed since it last passed in this checkout: tools (every tool's
// build brought up to date, then tests/run-tests.cs on the made-up character there), data (the tools' checks of each
// character's gear files and docs), and gearswap. A pass vouches for the builds it ran on, so a build made again
// clears every pass. --all runs every category, and a category named runs whether or not it changed. --filter runs
// only the tools tests whose name holds the text, and counts for no pass.
using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Diagnostics;
using System.IO;
using System.Security.Cryptography;
using System.Text.RegularExpressions;

var repo = Path.GetFullPath(Path.Combine(Path.GetDirectoryName((string)AppContext.GetData("EntryPointFilePath")!)!, ".."));
var toolsDir = Path.Combine(repo, ".claude", "tools");
var builds = new Builds(repo);

if (args.Length == 0)
{
	return Stop("Usage: dotnet run .claude/gear.cs -- <tool> [<option>...]\n"
		+ "       dotnet run .claude/gear.cs -- build\n"
		+ "       dotnet run .claude/gear.cs -- test [--all] [<category>...] [--filter <text>]\n"
		+ $"Tools: {ToolNames()}");
}
if (args[0] == "build")
	return builds.BuildAll() ? 0 : 2;
if (args[0] == "test")
	return new TestCommand(repo, builds).Run(args[1..]);
var source = Path.Combine(toolsDir, args[0] + ".cs");
// A name with a folder in it would reach past the tools, as tests/run-tests or ../gear would.
if (args[0].IndexOfAny(['/', '\\']) >= 0 || File.Exists(source) is false)
	return Stop($"No tool named {args[0]} in .claude/tools. Tools: {ToolNames()}");
var assembly = builds.Get(source);
if (assembly is null)
	return 2;
return Apps.Run(assembly, args[1..]);

string ToolNames() => string.Join(" ", Directory.GetFiles(toolsDir, "*.cs").Select(Path.GetFileNameWithoutExtension).Order(StringComparer.Ordinal));

static int Stop(string message)
{
	Console.Error.WriteLine(message);
	return 2;
}

// The test command. Each category runs when the files its result rests on changed since it last passed: the hash of
// those files when it last passed is kept in the checkout's .claude/cache/passes.
sealed class TestCommand
{
	string repo;
	string toolsDir;
	string passes;
	Builds builds;
	string[] categories;

	public TestCommand(string repo, Builds builds)
	{
		this.repo = repo;
		this.builds = builds;
		toolsDir = Path.Combine(repo, ".claude", "tools");
		passes = Path.Combine(repo, ".claude", "cache", "passes");
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
		var outcome = 0;
		foreach (var category in categories.Where(category => named.Count == 0 || named.Contains(category)))
			outcome = Math.Max(outcome, Test(category, all || named.Count > 0, filter));
		return outcome;
	}

	// Runs a category, unless it passed with these files and isn't forced to run, and says how it went. The exit code:
	// 1 when it failed, and 2 when it couldn't run, as for a --filter no test's name holds.
	int Test(string category, bool forced, string? filter)
	{
		if (category == "gearswap")
		{
			Console.WriteLine("gearswap: no tests yet");
			return 0;
		}
		var pass = Path.Combine(passes, category);
		var before = Files.Hash(repo, Inputs(category));
		if (forced is false && File.Exists(pass) && File.ReadAllText(pass) == before)
		{
			Console.WriteLine($"{category}: no change since it last passed");
			return 0;
		}
		var watch = Stopwatch.StartNew();
		var outcome = category == "tools" ? RunToolsTests(filter) : RunDataChecks() ? 0 : 1;
		if (outcome == 1)
			Console.WriteLine($"{category}: FAILED");
		if (outcome != 0)
			return outcome;
		Console.WriteLine($"{category}: passed in {watch.Elapsed.TotalSeconds:0.0} s");
		// A filtered run tested only some of the files, and a run during which they changed tested what they were.
		if (filter is not null)
			return 0;
		if (Files.Hash(repo, Inputs(category)) != before)
		{
			Console.WriteLine($"{category}: no pass kept, since its files changed while it ran");
			return 0;
		}
		Directory.CreateDirectory(passes);
		File.WriteAllText(pass, before);
		return 0;
	}

	// The files of the checkout a category's result rests on. The tools tests run on a fixture of their own, so they
	// rest on the tools' source and tests/ alone. The data checks rest on the data and the docs they check; the builds
	// they run are rested on through the build that clears their pass.
	IEnumerable<string> Inputs(string category)
	{
		if (category == "tools")
			return ToolSources().Concat(Files.Under(Path.Combine(toolsDir, "tests")));
		return Files.Under(Path.Combine(repo, "data")).Concat(Files.Under(Path.Combine(repo, "docs")));
	}

	// Each tool's file, the shared code they compile, and this launcher, which builds and runs them.
	IEnumerable<string> ToolSources() => Directory.GetFiles(toolsDir, "*.cs")
		.Concat(Files.Under(Path.Combine(toolsDir, "lib")))
		.Concat(Files.IfThere(Path.Combine(toolsDir, "Directory.Build.props")))
		.Append(Path.Combine(repo, ".claude", "gear.cs"));

	// Every build is brought up to date first. A tool that doesn't build fails the category, and so does a run that
	// crashed, whatever code it exited with.
	int RunToolsTests(string? filter)
	{
		if (builds.BuildAll() is false)
			return 1;
		string[] arguments = filter is null ? [] : [filter];
		var exit = Apps.Run(builds.AssemblyOf(Path.Combine(toolsDir, "tests", "run-tests.cs")), arguments);
		return exit is 0 or 2 ? exit : 1;
	}

	// Reads each character's gear files into sets files, checks those against the export, the blue magic lists and
	// the gear list, and lints the docs with the character's own. Then checks the rank documents against bg-wiki's rank
	// tables in docs/wiki.
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
			passed &= Check("rank-doc", "--check");
		}
		finally
		{
			Files.TryDeleteFolder(sets);
		}
		return passed;
	}

	// Runs a tool for the data checks, and says whether it found nothing wrong.
	bool Check(string tool, params string[] arguments)
	{
		Console.WriteLine($"data: {tool} {string.Join(" ", arguments.Select(argument => Path.IsPathRooted(argument) ? Path.GetFileName(argument) : argument))}");
		var assembly = builds.Get(Path.Combine(toolsDir, tool + ".cs"));
		// The paths given are the repo's, wherever the launcher was run from.
		return assembly is not null && Apps.Run(assembly, arguments, workingDirectory: repo) == 0;
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

	// A character's Sel gear files, <Character>_<Job>_Gear.lua, named as SelReader.NameOf reads them.
	IEnumerable<GearFile> GearFiles(string character)
	{
		var name = new Regex(@"^(?<who>[^_]+)_(?<job>[A-Za-z]{3})_[Gg]ear\.lua$");
		return Directory.GetFiles(Path.Combine(repo, "data", character), "*.lua")
			.Order(StringComparer.Ordinal)
			.Select(file => (Path: file, Found: name.Match(Path.GetFileName(file))))
			.Where(file => file.Found.Success && file.Found.Groups["who"].Value.Equals(character, StringComparison.OrdinalIgnoreCase))
			.Select(file => new GearFile(file.Path, file.Found.Groups["job"].Value.ToUpperInvariant()))
			.ToList();
	}

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

// The tools' builds in the checkout's .claude/cache/builds, a folder each, and the tools tests' beside them. A build
// notes the hash of the source it was made from, so one whose source changed since, by an edit, a pull or a branch
// switch, is made again before it runs.
sealed class Builds
{
	string repo;
	string folder;
	string toolsDir;
	string passes;

	public Builds(string repo)
	{
		this.repo = repo;
		folder = Path.Combine(repo, ".claude", "cache", "builds");
		toolsDir = Path.Combine(repo, ".claude", "tools");
		passes = Path.Combine(repo, ".claude", "cache", "passes");
	}

	public string AssemblyOf(string source)
	{
		var name = Path.GetFileNameWithoutExtension(source);
		return Path.Combine(folder, name, name + ".dll");
	}

	// The app's build, made again first when it is missing or its source changed. Null when it doesn't build, after
	// writing the compiler's errors.
	public string? Get(string source) => Current(source) ? AssemblyOf(source) : null;

	// Brings the builds of every tool and of the tools tests up to date, side by side. False when one doesn't build.
	public bool BuildAll()
	{
		var apps = Directory.GetFiles(toolsDir, "*.cs").Append(Path.Combine(toolsDir, "tests", "run-tests.cs")).ToList();
		var current = new bool[apps.Count];
		Parallel.For(0, apps.Count, i => current[i] = Current(apps[i]));
		return current.All(done => done);
	}

	// Runs started at once take turns at a build, and one whose turn comes after another made it finds it current.
	bool Current(string source)
	{
		var made = SourceHash(source);
		if (MadeFrom(source) == made)
			return true;
		using var turn = Turn(Path.Combine(folder, Path.GetFileNameWithoutExtension(source) + ".lock"));
		return MadeFrom(source) == made || Build(source, made);
	}

	// What an app's build is made from: its own file, the shared code and the build settings.
	string SourceHash(string source) => Files.Hash(repo, Files.Under(Path.Combine(toolsDir, "lib"))
		.Concat(Files.IfThere(Path.Combine(toolsDir, "Directory.Build.props")))
		.Append(source));

	// The hash the app's build notes, or null when it has no build or no note.
	string? MadeFrom(string source)
	{
		try
		{
			return File.Exists(AssemblyOf(source)) ? File.ReadAllText(Path.Combine(Path.GetDirectoryName(AssemblyOf(source))!, "source.hash")) : null;
		}
		catch (Exception problem) when (problem is FileNotFoundException or DirectoryNotFoundException)
		{
			// Another run may be replacing the build.
			return null;
		}
	}

	// Builds the app over the build it has, and notes in it the hash of the source it was made from.
	bool Build(string source, string made)
	{
		var name = Path.GetFileNameWithoutExtension(source);
		Console.Error.WriteLine($"Building {name}");
		// The build's own files go to the temp folder, not to the dotnet folder that keeps a build of each app by path,
		// and its output beside the build it replaces, so the one can be moved over the other.
		var suffix = Guid.NewGuid().ToString("N")[..8];
		var work = Path.Combine(Path.GetTempPath(), "gear-build-" + suffix);
		var output = Path.Combine(folder, $"{name}.new-{suffix}");
		var replaced = Path.Combine(folder, $"{name}.old-{suffix}");
		try
		{
			var build = Finished.Run("dotnet", "build", source, "--artifacts-path", work, "-o", output, "--nologo", "-v", "q");
			if (build.ExitCode != 0)
			{
				Console.Error.WriteLine($"{name}.cs doesn't build:\n{build.Output.Trim()}");
				return false;
			}
			File.WriteAllText(Path.Combine(output, "source.hash"), made);
			// A test's pass vouches for the builds it ran on.
			foreach (var pass in Directory.Exists(passes) ? Directory.GetFiles(passes) : [])
				File.Delete(pass);
			var kept = Path.Combine(folder, name);
			// Moved aside rather than deleted where it is, since a tool may be running from it: a move takes the whole
			// build or none of it, where a delete on Windows can leave part of it behind.
			if (Directory.Exists(kept))
				Directory.Move(kept, replaced);
			Directory.Move(output, kept);
			return true;
		}
		catch (Exception problem) when (problem is IOException or UnauthorizedAccessException)
		{
			Console.Error.WriteLine($"{name}'s build couldn't be replaced: {problem.Message} Build again once nothing runs it.");
			return false;
		}
		finally
		{
			Files.TryDeleteFolder(work);
			Files.TryDeleteFolder(output);
			Files.TryDeleteFolder(replaced);
		}
	}

	// Waits while another run holds the lock, but not past what a build can take.
	static FileStream Turn(string path)
	{
		var waited = Stopwatch.StartNew();
		while (true)
		{
			Directory.CreateDirectory(Path.GetDirectoryName(path)!);
			try
			{
				return new FileStream(path, FileMode.OpenOrCreate, FileAccess.ReadWrite, FileShare.None);
			}
			catch (IOException) when (waited.Elapsed < TimeSpan.FromMinutes(5))
			{
				Thread.Sleep(100);
			}
		}
	}
}

static class Files
{
	public static IEnumerable<string> Under(string folder) => Directory.Exists(folder) ? Directory.GetFiles(folder, "*", SearchOption.AllDirectories) : [];

	public static IEnumerable<string> IfThere(string file) => File.Exists(file) ? [file] : [];

	// The hash of files by their path in the repo and their content, as 32 hex digits.
	public static string Hash(string repo, IEnumerable<string> files)
	{
		using var hash = IncrementalHash.CreateHash(HashAlgorithmName.SHA256);
		foreach (var file in files.Select(file => (Name: Path.GetRelativePath(repo, file).Replace('\\', '/'), Path: file)).OrderBy(file => file.Name, StringComparer.Ordinal))
		{
			hash.AppendData(Encoding.UTF8.GetBytes(file.Name + "\n"));
			hash.AppendData(SHA256.HashData(File.ReadAllBytes(file.Path)));
		}
		return Convert.ToHexString(hash.GetHashAndReset())[..32].ToLowerInvariant();
	}

	// For a folder nothing reads again, which a virus scanner or a tool still running may hold for a while.
	public static void TryDeleteFolder(string folder)
	{
		try
		{
			if (Directory.Exists(folder))
				Directory.Delete(folder, true);
		}
		catch (Exception problem) when (problem is IOException or UnauthorizedAccessException)
		{
		}
	}
}

// Runs a built app with this launcher's input and output.
static class Apps
{
	public static int Run(string assembly, IEnumerable<string> arguments, string? workingDirectory = null)
	{
		var start = new ProcessStartInfo("dotnet") { WorkingDirectory = workingDirectory ?? "" };
		start.ArgumentList.Add(assembly);
		foreach (var argument in arguments)
			start.ArgumentList.Add(argument);
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
