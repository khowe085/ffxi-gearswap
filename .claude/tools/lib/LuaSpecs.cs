using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.IO;

namespace GearTools;

// GearSwap's Lua tests, which busted runs: the spec files under tests/, what busted's JSON output says of the tests
// in one, and the report of a run. tests/run-gearswap-tests.cs runs each spec file in a busted process of its own.
static class LuaSpecs
{
	public static IReadOnlyList<string> Find(string repo) => throw new NotImplementedException();

	public static SpecRun Read(string spec, string output) => throw new NotImplementedException();

	public static int Report(IReadOnlyList<SpecRun> runs, string? filter, TextWriter output) => throw new NotImplementedException();
}

// What busted's run of one spec file came to: its tests, or, when it didn't run, what it wrote instead.
sealed class SpecRun
{
	public string Spec { get; }

	public bool Ran { get; }

	public IReadOnlyList<SpecTest> Tests { get; }

	public string Output { get; }

	public SpecRun(string spec, bool ran, IReadOnlyList<SpecTest> tests, string output)
	{
		Spec = spec;
		Ran = ran;
		Tests = tests;
		Output = output;
	}
}

sealed class SpecTest
{
	public string Name { get; }

	public SpecResult Result { get; }

	public string Message { get; }

	public double Seconds { get; }

	public SpecTest(string name, SpecResult result, string message, double seconds)
	{
		Name = name;
		Result = result;
		Message = message;
		Seconds = seconds;
	}
}

enum SpecResult
{
	Passed,
	Failed,
	Pending,
}
