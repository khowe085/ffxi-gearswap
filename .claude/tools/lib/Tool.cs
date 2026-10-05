using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Diagnostics.CodeAnalysis;
using System.IO;

namespace GearTools;

// What every tool in this folder shares: where the repo and the cache are, and how a tool stops.
static class Tool
{
	public static string RepoRoot { get; }

	public static string ToolsDir { get; }

	public static string CacheDir { get; }

	static Tool()
	{
		// dotnet run builds a file-based app into a temp folder, so the assembly's own path says nothing about the
		// repo. It passes the app's source folder here instead: this folder, or tests/ under it.
		var entryDir = AppContext.GetData("EntryPointFileDirectoryPath") as string;
		var tools = ToolsFolderFrom(entryDir, "") ?? ToolsFolderFrom(Environment.CurrentDirectory, Path.Combine(".claude", "tools"));
		if (tools is null)
			Fail("Can't find .claude/tools: run the tool from inside the repo.");
		ToolsDir = tools;
		// The tests (tests/run-tests.cs) point the tools at a made-up repo and cache with these two variables.
		RepoRoot = Environment.GetEnvironmentVariable("GEAR_TOOLS_ROOT") ?? Path.GetFullPath(Path.Combine(tools, "..", ".."));
		CacheDir = Environment.GetEnvironmentVariable("GEAR_TOOLS_CACHE") ?? Path.Combine(RepoRoot, ".claude", "cache");
	}

	// Call first in every tool. dotnet run rebuilds a file-based app only when the app's own file changes, so after
	// an edit under lib/ a plain run would go on using the old build. This stops it and says how to rebuild.
	public static void Init()
	{
		var built = File.GetLastWriteTimeUtc(Path.Combine(AppContext.BaseDirectory, typeof(Tool).Assembly.GetName().Name + ".dll"));
		var sources = Directory.GetFiles(Path.Combine(ToolsDir, "lib"), "*.cs").Append(Path.Combine(ToolsDir, "Directory.Build.props"));
		if (sources.Max(File.GetLastWriteTimeUtc) > built)
			Fail("This build is older than .claude/tools/lib. Run the tool again with: dotnet run --no-cache <tool>.cs");
	}

	public static string InRepo(params string[] parts) => Path.Combine([RepoRoot, .. parts]);

	public static string InCache(params string[] parts) => Path.Combine([CacheDir, .. parts]);

	// A path as the docs and the job files write it: relative to the repo, with forward slashes.
	public static string RepoRelative(string path) => Path.GetRelativePath(RepoRoot, path).Replace('\\', '/');

	[DoesNotReturn]
	public static void Fail(string message)
	{
		Console.Error.WriteLine(message);
		Environment.Exit(2);
	}

	// The tools folder, found by walking up from a folder: the first one that has lib/Tool.cs under the given path.
	static string? ToolsFolderFrom(string? start, string below)
	{
		for (var dir = start is null ? null : new DirectoryInfo(start); dir is not null; dir = dir.Parent)
		{
			var candidate = Path.Combine(dir.FullName, below);
			if (File.Exists(Path.Combine(candidate, "lib", "Tool.cs")))
				return Path.GetFullPath(candidate);
		}
		return null;
	}
}

// The arguments a tool was run with: "--name value" options, "--name" flags, and the words left over.
sealed class Arguments
{
	public IReadOnlyList<string> Words { get; }

	Dictionary<string, string> values;
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
				values[arg] = args[++i];
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

	public string? Option(string name) => values.GetValueOrDefault(name);

	public bool Flag(string name) => flags.Contains(name);
}
