using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.IO;
using System.Text.Encodings.Web;
using System.Text.Json;

namespace GearTools;

// What GearSwap's spec files rested on when they last passed, kept between runs so that a later run reruns only the spec
// files a change could have affected. For each spec file that passed: its hash and that of each repo file it loaded. For
// all of them: the hash of the files every spec file rests on, under which the records were made.
sealed class SpecStore
{
	public string Globals { get; }

	public IReadOnlyDictionary<string, SpecRecord> Records { get; }

	const int Version = 1;

	static JsonSerializerOptions options;

	public SpecStore(string globals, IReadOnlyDictionary<string, SpecRecord> records)
	{
		Globals = globals;
		Records = records;
	}

	static SpecStore()
	{
		options = new JsonSerializerOptions
		{
			PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
			PropertyNameCaseInsensitive = true,
			WriteIndented = true,
			Encoder = JavaScriptEncoder.UnsafeRelaxedJsonEscaping,
		};
	}

	// The spec files a change could have affected. Every one when there is no store or the files they all rest on changed
	// since it was made; otherwise each with no record, and each whose own file, or a file it loaded, changed or is gone.
	// files holds the hash of each file now, by its path in the repo.
	public static IReadOnlyList<string> Select(SpecStore? store, string globals, IReadOnlyList<string> specs, IReadOnlyDictionary<string, string> files)
	{
		if (store is null || store.Globals != globals)
			return specs;
		return specs.Where(spec => store.Records.TryGetValue(spec, out var record) is false || record.Holds(files) is false).ToList();
	}

	// The store after a run of the spec files in ran: the records of those that passed replace the old ones, and a spec
	// file that ran and failed keeps none, so it runs again. The records of the others stay, unless they were made under
	// other globals, which vouch for nothing now, and so do those of spec files that are gone.
	public static SpecStore Update(SpecStore? store, string globals, IReadOnlyList<string> specs, IReadOnlyList<string> ran, IReadOnlyList<SpecRecord> passed)
	{
		var existing = specs.ToHashSet();
		var rerun = ran.ToHashSet();
		var records = new Dictionary<string, SpecRecord>();
		if (store is not null && store.Globals == globals)
		{
			foreach (var record in store.Records.Values.Where(record => existing.Contains(record.Spec) && rerun.Contains(record.Spec) is false))
				records[record.Spec] = record;
		}
		foreach (var record in passed.Where(record => existing.Contains(record.Spec)))
			records[record.Spec] = record;
		return new SpecStore(globals, records);
	}

	// The store a file holds, or null when there is no such file or it holds no store this code can use: it is not JSON,
	// not a store, or made by another version.
	public static SpecStore? Read(string path)
	{
		try
		{
			var json = JsonSerializer.Deserialize<StoreJson>(File.ReadAllText(path), options);
			if (json is null || json.Version != Version || json.Globals is null || json.Specs is null)
				return null;
			var records = new Dictionary<string, SpecRecord>();
			foreach (var (spec, record) in json.Specs)
			{
				if (record?.Hash is null || record.Files is null || record.Files.Values.Any(hash => hash is null))
					return null;
				records[spec] = new SpecRecord(spec, record.Hash, record.Files.ToDictionary(file => file.Key, file => file.Value!));
			}
			return new SpecStore(json.Globals, records);
		}
		catch (Exception problem) when (problem is IOException or UnauthorizedAccessException or JsonException)
		{
			return null;
		}
	}

	// Writes the store to the file, in a folder made if there is none, and replaces what the file held whole: a run that
	// reads it while this writes finds the old store or the new, never half of one.
	public void Write(string path)
	{
		Directory.CreateDirectory(Path.GetDirectoryName(path)!);
		var json = new StoreJson
		{
			Version = Version,
			Globals = Globals,
			Specs = Records.OrderBy(record => record.Key, StringComparer.Ordinal).ToDictionary(record => record.Key, record => (RecordJson?)new RecordJson
			{
				Hash = record.Value.Hash,
				Files = record.Value.Files.OrderBy(file => file.Key, StringComparer.Ordinal).ToDictionary(file => file.Key, file => (string?)file.Value),
			}),
		};
		var written = path + "." + Guid.NewGuid().ToString("N")[..8] + ".tmp";
		try
		{
			File.WriteAllText(written, JsonSerializer.Serialize(json, options));
			File.Move(written, path, overwrite: true);
		}
		finally
		{
			File.Delete(written);
		}
	}

	sealed class StoreJson
	{
		public int Version { get; set; }

		public string? Globals { get; set; }

		public Dictionary<string, RecordJson?>? Specs { get; set; }
	}

	sealed class RecordJson
	{
		public string? Hash { get; set; }

		public Dictionary<string, string?>? Files { get; set; }
	}
}

// What one spec file rested on when it passed: its own hash and that of each repo file it loaded, by the file's path in
// the repo.
sealed class SpecRecord
{
	public string Spec { get; }

	public string Hash { get; }

	public IReadOnlyDictionary<string, string> Files { get; }

	public SpecRecord(string spec, string hash, IReadOnlyDictionary<string, string> files)
	{
		Spec = spec;
		Hash = hash;
		Files = files;
	}

	// Whether the spec file and each file it loaded have the hashes it passed with. files holds the hash of each file now.
	public bool Holds(IReadOnlyDictionary<string, string> files) =>
		files.GetValueOrDefault(Spec) == Hash && Files.All(file => files.GetValueOrDefault(file.Key) == file.Value);
}
