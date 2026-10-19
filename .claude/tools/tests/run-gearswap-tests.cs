// Runs GearSwap's Lua tests, the spec files under tests/, each in a busted process of its own, side by side, and
// reports each test.
//
//   dotnet run .claude/gear.cs -- test gearswap [--filter <text>]
//
// With a filter, only the tests whose name holds the text run. busted reads .busted at the repo root; to run one spec
// file by hand: busted tests/sel/idle_spec.lua. The tests copy a Windower install into the temp folder; each run
// gives its busted processes a temp folder of their own and removes it after. They run on Linux or WSL. Exit code 1
// when a test fails or a spec file doesn't run, 2 when busted can't be run or nothing runs.
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

var filter = args.Length > 0 ? args[0] : null;
// LuaRocks installs busted on Windows as a batch file, which can't be started as a program, and the tests' Windower
// install is laid out with Linux paths.
if (OperatingSystem.IsWindows())
{
	Console.Error.WriteLine("GearSwap's tests run on Linux or WSL, not on Windows.");
	return 2;
}
var specs = LuaSpecs.Find(Tool.RepoRoot);
var temp = Path.Combine(Path.GetTempPath(), "gearswap-tests-" + Guid.NewGuid().ToString("N")[..8]);
Directory.CreateDirectory(temp);
var runs = new SpecRun[specs.Count];
var missing = false;
try
{
	Parallel.For(0, specs.Count, new ParallelOptions { MaxDegreeOfParallelism = Environment.ProcessorCount }, i =>
	{
		var start = new ProcessStartInfo("busted") { WorkingDirectory = Tool.RepoRoot, RedirectStandardOutput = true, RedirectStandardError = true };
		foreach (var argument in LuaSpecs.BustedArguments(specs[i], filter))
			start.ArgumentList.Add(argument);
		string[] temps = ["TMPDIR", "TEMP", "TMP"];
		foreach (var name in temps)
			start.Environment[name] = temp;
		try
		{
			using var process = Process.Start(start)!;
			// Read both streams at once, so a full error pipe can't stall busted while this waits on its output.
			var error = process.StandardError.ReadToEndAsync();
			var output = process.StandardOutput.ReadToEnd();
			process.WaitForExit();
			runs[i] = LuaSpecs.Read(specs[i], output, error.Result);
		}
		catch (Win32Exception)
		{
			missing = true;
		}
	});
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
	return 2;
}
return LuaSpecs.Report(runs, filter, Console.Out);
