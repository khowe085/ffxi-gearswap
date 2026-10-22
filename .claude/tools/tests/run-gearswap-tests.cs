// Runs GearSwap's Lua tests, the spec files under tests/, each in a busted process of its own, side by side, and
// reports each test.
//
//   dotnet run .claude/gear.cs -- test gearswap [--filter <text>]
//
// With a filter, only the tests whose name holds the text run. With --affected, only the spec files a change could have
// affected since they last passed run: those with no record, and those whose own file, or a repo file they loaded, has
// changed. Without a filter, a run keeps a record of each spec file that passed in .claude/cache/gearswap-specs.json,
// from what its busted process says it loaded (tests/support/harness.lua writes that to the file GEARSWAP_TEST_DEPS
// names), unless a file it rests on changed during the run. A change to a file every spec file rests on, or no usable
// record, has every spec file run. busted reads .busted at the repo root; to run one spec file by hand: busted
// tests/sel/idle_spec.lua. The tests copy a Windower install into the temp folder; each run gives its busted processes
// a temp folder of their own and removes it after. They run on Linux or WSL. Exit code 1 when a test fails or a spec
// file doesn't run, 2 when nothing runs (0 under --affected when no spec file is affected), 3 when busted can't run
// here.
using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using GearTools;

var affected = args.Contains("--affected");
var filter = args.FirstOrDefault(argument => argument != "--affected");
// LuaRocks installs busted on Windows as a batch file, which can't be started as a program, and the tests' Windower
// install is laid out with Linux paths.
if (OperatingSystem.IsWindows())
{
	Console.Error.WriteLine("GearSwap's tests run on Linux or WSL, not on Windows.");
	return 3;
}
var specs = LuaSpecs.Find(Tool.RepoRoot);
// A run with a filter tests only some of what the spec files hold, so it says nothing of what they rest on.
var recording = filter is null;
var storeFile = Tool.InRepo(".claude", "cache", "gearswap-specs.json");
// A run rests on the files as they are before it starts, so that one changed while it runs is found changed after.
var files = SpecInputs.Read(Tool.RepoRoot);
var runner = SpecInputs.HashOfRunner((string)AppContext.GetData("EntryPointFilePath")!);
var globals = SpecInputs.HashOfGlobals(files, runner);
var store = SpecStore.Read(storeFile);
var chosen = affected ? SpecStore.Select(store, globals, specs, files) : specs;
if (affected && specs.Count > 0)
{
	if (chosen.Count == 0)
	{
		Console.WriteLine("No spec file is affected by the changes since they last passed.");
	}
	else if (chosen.Count < specs.Count)
	{
		var unaffected = specs.Count - chosen.Count;
		Console.WriteLine($"Running {chosen.Count} of {specs.Count} spec files; the other {unaffected} {(unaffected == 1 ? "is" : "are")} unaffected by the changes since they last passed.");
	}
	else
	{
		var reason = store is null ? ": there is no record of an earlier run" : store.Globals != globals ? ": a file every spec rests on changed" : "";
		Console.WriteLine($"Running all {specs.Count} spec file{(specs.Count == 1 ? "" : "s")}{reason}.");
	}
}
var temp = Path.Combine(Path.GetTempPath(), "gearswap-tests-" + Guid.NewGuid().ToString("N")[..8]);
Directory.CreateDirectory(temp);
var runs = new SpecRun[chosen.Count];
var passed = new List<SpecRecord>();
var missing = false;
// The error a program that isn't there gives: ENOENT.
const int FileNotFound = 2;
// Where the i-th chosen spec file's busted writes the repo files it loaded.
string DependencyFile(int i) => Path.Combine(temp, $"dependencies-{i}.txt");
try
{
	Parallel.For(0, chosen.Count, new ParallelOptions { MaxDegreeOfParallelism = Environment.ProcessorCount }, i =>
	{
		var start = new ProcessStartInfo("busted") { WorkingDirectory = Tool.RepoRoot, RedirectStandardOutput = true, RedirectStandardError = true };
		foreach (var argument in LuaSpecs.BustedArguments(chosen[i], filter))
			start.ArgumentList.Add(argument);
		string[] temps = ["TMPDIR", "TEMP", "TMP"];
		foreach (var name in temps)
			start.Environment[name] = temp;
		if (recording)
			start.Environment["GEARSWAP_TEST_DEPS"] = DependencyFile(i);
		Process process;
		try
		{
			process = Process.Start(start)!;
		}
		catch (Win32Exception problem)
		{
			// Not found is busted not installed; anything else is a busted that is there but wouldn't start.
			if (problem.NativeErrorCode == FileNotFound)
			{
				missing = true;
			}
			else
			{
				runs[i] = new SpecRun(chosen[i], false, [], "busted couldn't be started: " + problem.Message);
			}
			return;
		}
		using (process)
		{
			// Read both streams at once, so a full pipe can't stall busted while this waits on the other.
			var error = process.StandardError.ReadToEndAsync();
			var output = process.StandardOutput.ReadToEndAsync();
			// A spec file takes seconds; one still running after this is stuck in a loop, and what it wrote says where.
			if (process.WaitForExit(TimeSpan.FromMinutes(10)) is false)
			{
				process.Kill(entireProcessTree: true);
				process.WaitForExit();
				runs[i] = new SpecRun(chosen[i], false, [], $"busted was stopped after 10 minutes\n{output.Result}{error.Result}".Trim());
				return;
			}
			runs[i] = LuaSpecs.Read(chosen[i], output.Result, error.Result, process.ExitCode);
		}
	});
	// A spec file busted wrote no list of loaded files for never got to exit, and a record of it would vouch for nothing.
	// Nor would one made after a file changed while the run went on: a busted process copies the install when it first
	// boots, which can be well into the run, so it may have read the file after the change, and a record that holds the
	// hash from before would hold again once the change is undone. So a record is kept only when the files it holds, and
	// those every spec file rests on, have the hashes they had before the run.
	if (missing is false && recording)
	{
		var after = SpecInputs.Read(Tool.RepoRoot);
		if (SpecInputs.HashOfGlobals(after, runner) == globals)
		{
			for (var i = 0; i < chosen.Count; i++)
			{
				if (runs[i].Passed && File.Exists(DependencyFile(i)) && SpecInputs.Record(chosen[i], files, File.ReadLines(DependencyFile(i))) is { } record && record.Holds(after))
					passed.Add(record);
			}
		}
	}
}
finally
{
	try
	{
		Directory.Delete(temp, true);
	}
	catch (Exception problem) when (problem is IOException or UnauthorizedAccessException)
	{
		// A file a busted process still held is left for the system to clear with the rest of the temp folder.
	}
}
if (missing)
{
	Console.Error.WriteLine("Couldn't run busted, which GearSwap's tests run on. Install Lua 5.1, LuaRocks and busted: luarocks --lua-version 5.1 install busted");
	return 3;
}
var exit = chosen.Count == 0 && specs.Count > 0 ? 0 : LuaSpecs.Report(runs, filter, Console.Out);
if (recording && exit is 0 or 1)
{
	try
	{
		SpecStore.Update(store, globals, specs, chosen, passed).Write(storeFile);
	}
	catch (Exception problem) when (problem is IOException or UnauthorizedAccessException)
	{
		Console.Error.WriteLine($"Couldn't keep what the spec files rest on in {storeFile}: {problem.Message}");
	}
}
return exit;
