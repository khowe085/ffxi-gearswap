using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Globalization;
using System.IO;
using System.Text.Json;

namespace GearTools;

// GearSwap's Lua tests, which busted runs: the spec files under tests/, what busted's JSON output says of the tests
// in one, and the report of a run. tests/run-gearswap-tests.cs runs each spec file in a busted process of its own.
static class LuaSpecs
{
	// Every *_spec.lua under the repo's tests/, by its path in the repo with forward slashes, in order.
	public static IReadOnlyList<string> Find(string repo)
	{
		var tests = Path.Combine(repo, "tests");
		if (Directory.Exists(tests) is false)
			return [];
		return Directory.GetFiles(tests, "*_spec.lua", SearchOption.AllDirectories)
			.Select(file => Path.GetRelativePath(repo, file).Replace('\\', '/'))
			.Order(StringComparer.Ordinal)
			.ToList();
	}

	// busted's arguments for a spec file: the repo's output handler, and the filter, which busted reads as a Lua
	// pattern: each character a pattern gives a meaning to is escaped, so it finds the text as it is, and each letter
	// matches in either case, as the tools tests' filter does.
	public static IReadOnlyList<string> BustedArguments(string spec, string? filter)
	{
		List<string> arguments = ["--output=tests/support/report.lua"];
		if (filter is not null)
			arguments.Add("--filter=" + string.Concat(filter.Select(Literal)));
		arguments.Add(spec);
		return arguments;
	}

	// Reads what busted wrote for a spec file with the repo's output handler, tests/support/report.lua: busted's
	// JSON, as the last line on standard output, after anything the tests printed. Output without it is a spec file
	// that didn't run, as one busted couldn't load, and its run keeps what was written on both streams.
	public static SpecRun Read(string spec, string standardOutput, string standardError, int exitCode)
	{
		var output = standardOutput + standardError;
		var lines = standardOutput.ReplaceLineEndings("\n").TrimEnd('\n').Split('\n');
		var last = lines[^1];
		if (last.StartsWith('{'))
		{
			try
			{
				using var json = JsonDocument.Parse(last);
				var tests = new List<(int Line, SpecTest Test)>();
				void Take(string list, SpecResult result)
				{
					if (json.RootElement.TryGetProperty(list, out var entries) is false)
						return;
					foreach (var entry in entries.EnumerateArray())
					{
						var message = Text(entry, "message");
						var traceback = entry.TryGetProperty("trace", out var trace) ? Text(trace, "traceback") : "";
						if (entry.TryGetProperty("isError", out var isError) && isError.ValueKind == JsonValueKind.True && traceback.Length > 0)
							message += "\n" + traceback.TrimStart('\n');
						var element = entry.TryGetProperty("element", out var found) ? found : default;
						var seconds = element.ValueKind == JsonValueKind.Object && element.TryGetProperty("duration", out var duration) && duration.ValueKind == JsonValueKind.Number ? duration.GetDouble() : 0;
						// The test's own line, where it is declared; a failure's trace says where its assertion was.
						var declared = element.ValueKind == JsonValueKind.Object && element.TryGetProperty("trace", out var elementTrace) ? elementTrace : default;
						var line = declared.ValueKind == JsonValueKind.Object && declared.TryGetProperty("currentline", out var current) && current.ValueKind == JsonValueKind.Number ? current.GetInt32() : 0;
						tests.Add((line, new SpecTest(Text(entry, "name"), result, message, seconds)));
					}
				}
				Take("successes", SpecResult.Passed);
				Take("failures", SpecResult.Failed);
				Take("errors", SpecResult.Failed);
				Take("pendings", SpecResult.Pending);
				// busted's exit code counts the tests that failed, so any other means it broke off after its results.
				if (exitCode != 0 && tests.All(test => test.Test.Result != SpecResult.Failed))
					return new SpecRun(spec, false, [], $"busted exited with code {exitCode}, though no test failed\n{output.Trim()}");
				return new SpecRun(spec, true, tests.OrderBy(test => test.Line).Select(test => test.Test).ToList(), output);
			}
			catch (JsonException)
			{
			}
		}
		return new SpecRun(spec, false, [], output.Trim());
	}

	// Writes a line for each test and then the count, and returns the exit code: 0 when every test passed, 1 when
	// one failed or a spec file didn't run, and 2 when there was nothing to run, as for a filter no test's name holds.
	public static int Report(IReadOnlyList<SpecRun> runs, string? filter, TextWriter output)
	{
		if (runs.Count == 0)
		{
			output.WriteLine("No spec files under tests/.");
			return 2;
		}
		var tests = runs.SelectMany(run => run.Tests.Select(test => (run.Spec, Test: test))).ToList();
		var unrun = runs.Where(run => run.Ran is false).ToList();
		if (tests.Count == 0 && unrun.Count == 0)
		{
			output.WriteLine(filter is null ? "No tests in the spec files under tests/." : $"No gearswap test's name holds \"{filter}\".");
			return 2;
		}
		foreach (var (spec, test) in tests)
		{
			if (test.Result == SpecResult.Pending)
			{
				output.WriteLine($"SKIP {test.Name} ({spec})" + (test.Message.Length > 0 ? ": " + test.Message : ""));
				continue;
			}
			var seconds = test.Seconds.ToString("0.00", CultureInfo.InvariantCulture);
			output.WriteLine($"{(test.Result == SpecResult.Passed ? "PASS" : "FAIL")} {test.Name} ({spec}, {seconds} s)");
			if (test.Result == SpecResult.Failed)
				output.WriteLine("     " + test.Message.Replace("\n", "\n     "));
		}
		foreach (var run in unrun)
		{
			output.WriteLine($"FAIL {run.Spec} didn't run");
			output.WriteLine("     " + run.Output.Replace("\n", "\n     "));
		}
		var ran = tests.Count(test => test.Test.Result != SpecResult.Pending);
		var passed = tests.Count(test => test.Test.Result == SpecResult.Passed);
		var pending = tests.Count - ran;
		var count = $"{passed} of {ran} tests passed";
		if (pending > 0)
			count += $", {pending} pending";
		if (unrun.Count > 0)
			count += $"; {unrun.Count} spec file{(unrun.Count == 1 ? "" : "s")} didn't run";
		output.WriteLine(count);
		return passed == ran && unrun.Count == 0 ? 0 : 1;
	}

	static string Literal(char c)
	{
		if ("^$()%.[]*+-?".Contains(c))
			return "%" + c;
		if (char.IsAsciiLetter(c))
			return $"[{char.ToLowerInvariant(c)}{char.ToUpperInvariant(c)}]";
		return c.ToString();
	}

	static string Text(JsonElement entry, string name) =>
		entry.ValueKind == JsonValueKind.Object && entry.TryGetProperty(name, out var value) && value.ValueKind == JsonValueKind.String ? value.GetString()! : "";
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
