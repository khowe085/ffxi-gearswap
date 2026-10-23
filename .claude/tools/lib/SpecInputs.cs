using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.IO;
using System.Security.Cryptography;

namespace GearTools;

// The repo files GearSwap's tests can rest on: their hashes before a run, which of them every spec file rests on, and
// what the record of a spec file that passed holds of those it loaded.
static class SpecInputs
{
	// Every file the tests can rest on, by its path in the repo with forward slashes, with its hash, 32 hex digits: the
	// tests (the spec files, the harness and the fixtures), GearSwap's Lua at the repo's root, libs/ and data/, Windower's
	// libraries under docs/windower/libs, and .busted. The hashes are those a run is taken to have rested on, so they are
	// read before it starts.
	public static IReadOnlyDictionary<string, string> Read(string repo)
	{
		var files = new Dictionary<string, string>();
		if (Directory.Exists(repo) is false)
			return files;
		var candidates = Directory.GetFiles(repo, "*.lua")
			.Concat(FilesUnder(Path.Combine(repo, "tests")))
			.Concat(FilesUnder(Path.Combine(repo, "libs")))
			.Concat(FilesUnder(Path.Combine(repo, "data")))
			.Concat(FilesUnder(Path.Combine(repo, "docs", "windower", "libs")))
			.Append(Path.Combine(repo, ".busted"));
		foreach (var file in candidates)
		{
			try
			{
				files[Path.GetRelativePath(repo, file).Replace('\\', '/')] = HashOf(file);
			}
			catch (Exception problem) when (problem is IOException or UnauthorizedAccessException)
			{
				// A file that is gone or can't be read has no hash, which a record that holds it finds a change.
			}
		}
		return files;
	}

	// The hash of what the runner is built from: its own file, the shared code in lib/ and the build settings.
	public static string HashOfRunner(string entry)
	{
		var tools = Path.GetFullPath(Path.Combine(Path.GetDirectoryName(entry)!, ".."));
		var props = Path.Combine(tools, "Directory.Build.props");
		var sources = FilesUnder(Path.Combine(tools, "lib")).Append(entry);
		if (File.Exists(props))
			sources = sources.Append(props);
		using var hash = IncrementalHash.CreateHash(HashAlgorithmName.SHA256);
		foreach (var source in sources.Select(source => (Name: Path.GetRelativePath(tools, source).Replace('\\', '/'), Path: source)).OrderBy(source => source.Name, StringComparer.Ordinal))
			Append(hash, source.Name + " " + HashOf(source.Path));
		return Finish(hash);
	}

	// The hash of what every spec file rests on, loaded or not: the files RestedOnByAll names, by content, the names of the
	// files in the places the tests' Windower install is copied from, since a spec file may look there for a file that
	// is not there, and runner, the hash of what the runner is built from.
	public static string HashOfGlobals(IReadOnlyDictionary<string, string> files, string runner)
	{
		using var hash = IncrementalHash.CreateHash(HashAlgorithmName.SHA256);
		Append(hash, "runner " + runner);
		foreach (var file in files.OrderBy(file => file.Key, StringComparer.Ordinal))
		{
			if (RestedOnByAll(file.Key))
				Append(hash, "content " + file.Key + " " + file.Value);
			else if (CopiedFrom(file.Key))
				Append(hash, "name " + file.Key);
		}
		return Finish(hash);
	}

	// The record of a spec file that passed, from the paths of the files it loaded as the harness wrote them, with the
	// hashes the files had in files. Left out are the files every spec file rests on, which the globals cover, and the
	// paths that are no file of the repo, as a file the addon wrote into the tests' Windower install. Null when the spec
	// file itself is not among files.
	public static SpecRecord? Record(string spec, IReadOnlyDictionary<string, string> files, IEnumerable<string> loaded)
	{
		if (files.TryGetValue(spec, out var hash) is false)
			return null;
		var rested = loaded.Select(Normalize).OfType<string>()
			.Where(path => files.ContainsKey(path) && RestedOnByAll(path) is false)
			.Distinct()
			.ToDictionary(path => path, path => files[path]);
		return new SpecRecord(spec, hash, rested);
	}

	// The harness the tests run on, the resources and the Windower libraries it stands in for, and busted's settings: a
	// change to any of them can change what any spec file does, whether it loads the file or not.
	static bool RestedOnByAll(string path) =>
		path == ".busted" || In(path, "tests/support/") || In(path, "tests/fixture/res/") || In(path, "docs/windower/libs/");

	// GearSwap's Lua at the repo's root, libs/, data/ and the fixture characters' files: the places the tests' Windower
	// install is copied from.
	static bool CopiedFrom(string path) =>
		(path.EndsWith(".lua", StringComparison.Ordinal) && path.Contains('/') is false) || In(path, "libs/") || In(path, "data/") || In(path, "tests/fixture/data/");

	static bool In(string path, string folder) => path.StartsWith(folder, StringComparison.Ordinal);

	// A path in the repo as its folders and file name alone, with forward slashes, or null when it names nothing in the repo.
	static string? Normalize(string path)
	{
		var parts = new List<string>();
		foreach (var part in path.Trim().Replace('\\', '/').Split('/'))
		{
			if (part is "" or ".")
				continue;
			if (part == "..")
			{
				if (parts.Count == 0)
					return null;
				parts.RemoveAt(parts.Count - 1);
			}
			else
			{
				parts.Add(part);
			}
		}
		return parts.Count == 0 ? null : string.Join("/", parts);
	}

	static IEnumerable<string> FilesUnder(string folder) => Directory.Exists(folder) ? Directory.GetFiles(folder, "*", SearchOption.AllDirectories) : [];

	static string HashOf(string file) => Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(file)))[..32].ToLowerInvariant();

	static void Append(IncrementalHash hash, string line) => hash.AppendData(Encoding.UTF8.GetBytes(line + "\n"));

	static string Finish(IncrementalHash hash) => Convert.ToHexString(hash.GetHashAndReset())[..32].ToLowerInvariant();
}
