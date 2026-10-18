using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Diagnostics.CodeAnalysis;
using System.IO;
using System.Reflection;
using System.Text.RegularExpressions;

namespace GearTools;

// What every tool in this folder shares: where the repo and the cache are, and how a tool stops.
static class Tool
{
	public static string RepoRoot { get; }

	public static string CacheDir { get; }

	static Tool()
	{
		// The launcher (.claude/gear.cs) names the checkout to work on, since one build of a tool serves every checkout
		// with the same source. A tool started any other way may be a build older than its source.
		var root = Environment.GetEnvironmentVariable("GEAR_TOOLS_ROOT");
		if (root is null)
			Fail($"Run the tool with the launcher: dotnet run .claude/gear.cs -- {Assembly.GetEntryAssembly()?.GetName().Name}");
		RepoRoot = root;
		// The tests (tests/run-tests.cs) point the tools at a cache of their own.
		CacheDir = Environment.GetEnvironmentVariable("GEAR_TOOLS_CACHE") ?? Path.Combine(RepoRoot, ".claude", "cache");
	}

	public static string InRepo(params string[] parts) => Path.Combine([RepoRoot, .. parts]);

	public static string InCache(params string[] parts) => Path.Combine([CacheDir, .. parts]);

	// A path as the docs write it: relative to the repo, with forward slashes.
	public static string RepoRelative(string path) => Path.GetRelativePath(RepoRoot, path).Replace('\\', '/');

	// A regular expression given on the command line, matched without regard to case. One that can't be read stops
	// the tool.
	public static Regex Pattern(string what, string pattern)
	{
		try
		{
			return new Regex(pattern, RegexOptions.IgnoreCase);
		}
		catch (ArgumentException problem)
		{
			Fail($"{what} isn't a regular expression: {problem.Message}");
			throw;
		}
	}

	[DoesNotReturn]
	public static void Fail(string message)
	{
		Console.Error.WriteLine(message);
		Environment.Exit(2);
	}
}

// The arguments a tool was run with: "--name value" options, "--name" flags, and the words left over.
sealed class Arguments
{
	public IReadOnlyList<string> Words { get; }

	// Every value an option was given, in order.
	Dictionary<string, List<string>> values;
	HashSet<string> flags;

	// A name outside both lists stops the tool, and so does a word when the tool takes none, so a mistyped option
	// or a value given without its option can't pass unnoticed.
	public Arguments(string[] args, string[] valueOptions, string[] flagOptions, bool takesWords = false)
	{
		values = [];
		flags = [];
		var words = new List<string>();
		var options = string.Join(" ", valueOptions.Select(option => option + " <value>").Concat(flagOptions));
		for (var i = 0; i < args.Length; i++)
		{
			var arg = args[i];
			if (flagOptions.Contains(arg))
			{
				flags.Add(arg);
			}
			else if (valueOptions.Contains(arg))
			{
				if (i + 1 >= args.Length)
					Tool.Fail($"{arg} needs a value.");
				if (values.TryGetValue(arg, out var given) is false)
					values[arg] = given = [];
				given.Add(args[++i]);
			}
			else if (arg.StartsWith("--"))
			{
				Tool.Fail($"Unknown option {arg}. Options: {options}");
			}
			else if (takesWords)
			{
				words.Add(arg);
			}
			else
			{
				Tool.Fail($"Unexpected argument {arg}. Options: {options}");
			}
		}
		Words = words;
	}

	// An option given more than once keeps its last value here. Options gives them all.
	public string? Option(string name) => values.GetValueOrDefault(name)?[^1];

	public IReadOnlyList<string> Options(string name) => values.GetValueOrDefault(name) ?? [];

	public bool Flag(string name) => flags.Contains(name);
}
