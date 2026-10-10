using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.IO;
using System.Text.Encodings.Web;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace GearTools;

// The JSON the tools and the gear-optimizer agent read and write, whatever GearSwap framework the sets come from. A
// reader for one framework (sel-sets.cs) writes a SetsDto; the checkers read it; the agent takes an OptimizeRequest
// and answers with an OptimizeResult. Every file carries schemaVersion 1.
static class Dto
{
	public const int SchemaVersion = 1;

	// The item name a piece gives to clear a slot, as GearSwap's own "empty" does.
	public const string Empty = "empty";

	static JsonSerializerOptions options;

	static Dto()
	{
		options = new JsonSerializerOptions
		{
			PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
			PropertyNameCaseInsensitive = true,
			DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull,
			WriteIndented = true,
			Encoder = JavaScriptEncoder.UnsafeRelaxedJsonEscaping,
		};
	}

	// A sets file, checked: it throws an InvalidOperationException that says what is wrong with one it can't use.
	public static SetsDto ReadSets(string path)
	{
		var sets = Read<SetsDto>(path, "a sets file");
		Validate(sets, path);
		return sets;
	}

	public static OptimizeRequest ReadRequest(string path)
	{
		var request = Read<OptimizeRequest>(path, "an optimize request");
		if (request.Sets is null)
			throw new InvalidOperationException($"{path} has no sets.");
		foreach (var bag in request.Bags?.Where(bag => Export.EquippableBags.Contains(bag) is false) ?? [])
			throw new InvalidOperationException($"{path}: bags names {bag}, which GearSwap can't equip from. Bags: {string.Join(" ", Export.EquippableBags)}");
		if (request.SchemaVersion != SchemaVersion)
			throw new InvalidOperationException($"{path} has schemaVersion {request.SchemaVersion}; the tools read {SchemaVersion}.");
		Validate(request.Sets, path);
		if (request.Character != request.Sets.Character || request.Job != request.Sets.Job)
			throw new InvalidOperationException($"{path} is for {request.Character} {request.Job}, but its sets are for {request.Sets.Character} {request.Sets.Job}.");
		return request;
	}

	// ReadSets for a tool: a file it can't use stops the tool.
	public static SetsDto LoadSets(string path)
	{
		try
		{
			return ReadSets(path);
		}
		catch (InvalidOperationException problem)
		{
			Tool.Fail(problem.Message);
			throw;
		}
	}

	// What a set wears: its base's pieces, each base resolved the same way, with the set's own slots over them.
	// A name inside an alias, as B.X for B = A, is the set A.X.
	public static Dictionary<string, PieceDto> Resolve(SetsDto sets, string name)
	{
		var byName = sets.Sets.ToDictionary(set => set.Name);
		var asked = name;
		for (var hops = 0; byName.ContainsKey(name) is false && hops <= sets.Sets.Count; hops++)
		{
			var alias = sets.Sets.Where(set => set.AliasOf is not null && Inside(name, set.Name)).MaxBy(set => set.Name.Length);
			if (alias is null)
				break;
			name = alias.AliasOf + name[alias.Name.Length..];
		}
		if (byName.ContainsKey(name) is false)
			throw new InvalidOperationException($"No set named {asked}.");
		var chain = new List<string>();
		for (var current = name; current is not null; current = byName[current].AliasOf ?? byName[current].Base)
		{
			if (chain.Contains(current))
				throw new InvalidOperationException($"{name} is built on itself: {string.Join(", ", chain.SkipWhile(link => link != current))}, {current}.");
			if (byName.ContainsKey(current) is false)
				throw new InvalidOperationException($"{chain[^1]} is built on {current}, and no set has that name.");
			chain.Add(current);
		}
		var slots = new Dictionary<string, PieceDto>();
		foreach (var link in Enumerable.Reverse(chain))
		{
			foreach (var slot in byName[link].Slots)
				slots[slot.Key] = slot.Value;
		}
		return slots;
	}

	// Whether name is a set inside the set parent, as idle.DT and midcast['Blue Magic'] are.
	public static bool Inside(string name, string parent) => name.Length > parent.Length && name.StartsWith(parent, StringComparison.Ordinal)
		&& (name[parent.Length] == '.' || name[parent.Length] == '[');

	public static string ToJson(object value) => JsonSerializer.Serialize(value, options);

	static T Read<T>(string path, string what)
		where T : class
	{
		if (File.Exists(path) is false)
			throw new InvalidOperationException($"No {(what == "a sets file" ? "sets file" : "request")} at {path}.");
		T? read;
		try
		{
			read = JsonSerializer.Deserialize<T>(File.ReadAllText(path), options);
		}
		catch (JsonException problem)
		{
			throw new InvalidOperationException($"{path} can't be read as {what}: {problem.Message}");
		}
		return read ?? throw new InvalidOperationException($"{path} can't be read as {what}: it holds null.");
	}

	static void Validate(SetsDto sets, string path)
	{
		if (sets.SchemaVersion != SchemaVersion)
			throw new InvalidOperationException($"{path} has schemaVersion {sets.SchemaVersion}; the tools read {SchemaVersion}.");
		if (string.IsNullOrWhiteSpace(sets.Character))
			throw new InvalidOperationException($"{path} names no character.");
		if (Resources.JobNames.Skip(1).Contains(sets.Job) is false)
			throw new InvalidOperationException($"{path}: {sets.Job} isn't a job. Jobs: {string.Join(" ", Resources.JobNames.Skip(1))}");
		// JSON can say null where the classes say empty.
		sets.Sets ??= [];
		foreach (var set in sets.Sets)
			set.Slots ??= [];
		var problems = new List<string>();
		var seen = new HashSet<string>();
		for (var i = 0; i < sets.Sets.Count; i++)
		{
			var set = sets.Sets[i];
			if (string.IsNullOrWhiteSpace(set.Name))
			{
				problems.Add($"set {i + 1} has no name");
				continue;
			}
			if (seen.Add(set.Name) is false)
				problems.Add($"two sets named {set.Name}");
			if (set.AliasOf is not null && (set.Base is not null || set.Slots.Count > 0))
				problems.Add($"{set.Name} is an alias of {set.AliasOf}, so it can't have a base or slots of its own");
			foreach (var slot in set.Slots)
			{
				// Only the canonical names, so two spellings of one slot can't both sit in a set.
				if (Resources.SlotNames.Contains(slot.Key) is false)
					problems.Add($"{set.Name}: {slot.Key} isn't a slot. Slots: {string.Join(" ", Resources.SlotNames)}");
				else if (string.IsNullOrWhiteSpace(slot.Value?.Item))
					problems.Add($"{set.Name}: {slot.Key} names no item");
			}
		}
		var named = sets.Sets.Where(set => string.IsNullOrWhiteSpace(set.Name) is false).GroupBy(set => set.Name).ToDictionary(group => group.Key, group => group.First());
		foreach (var set in sets.Sets.Where(set => set.AliasOf is not null))
		{
			if (named.TryGetValue(set.AliasOf!, out var target) is false)
			{
				problems.Add($"{set.Name} is an alias of {set.AliasOf}, and no set has that name");
			}
			else if (target.AliasOf is not null)
			{
				problems.Add($"{set.Name} is an alias of {set.AliasOf}, which is an alias itself; name {target.AliasOf}");
			}
		}
		foreach (var spell in sets.SpellSets ?? [])
		{
			if (seen.Contains(spell.Value) is false)
				problems.Add($"spellSets: {spell.Key} names the set {spell.Value}, and no set has that name");
		}
		foreach (var list in sets.SpellLists ?? [])
		{
			if (list.Value is null)
			{
				problems.Add($"spellLists: {list.Key} is null");
			}
			else if (list.Value.Any(spell => spell is null))
			{
				problems.Add($"spellLists: {list.Key} holds a null");
			}
		}
		if (problems.Count == 0)
		{
			foreach (var set in sets.Sets)
			{
				try
				{
					Resolve(sets, set.Name);
				}
				catch (InvalidOperationException problem)
				{
					var message = problem.Message.TrimEnd('.');
					if (problems.Contains(message) is false)
						problems.Add(message);
				}
			}
		}
		if (problems.Count > 0)
			throw new InvalidOperationException($"{path}: {string.Join($"\n{path}: ", problems)}");
	}
}

// One piece in one slot: the item by the name the export prints or its log name, and the copy it means.
sealed class PieceDto
{
	public string Item { get; set; }

	// The copy's augments exactly as the export prints them. Null or empty names no copy, and any will do.
	public List<string>? Augments { get; set; }

	// The bag the piece has to come from, when it names one.
	public string? Bag { get; set; }

	public PieceDto()
	{
		Item = "";
	}

	public bool Matches(ExportItem copy) => Augments is null || Augments.Count == 0 || Augments.SequenceEqual(copy.Augments);
}

// A set: a base, when it has one, and the slots it puts over it.
sealed class SetDto
{
	// The caller's own name for the set. The tools only compare it.
	public string Name { get; set; }

	public string? Base { get; set; }

	// The set this one is the same table as, as sets.B = sets.A makes it: B has no base or slots of its own, and the
	// sets inside A are inside B too, so B.X is A.X. Written back as sets.B = sets.A, never as a copy.
	public string? AliasOf { get; set; }

	// By canonical slot name, as Resources.SlotNames spells them.
	public Dictionary<string, PieceDto> Slots { get; set; }

	public SetDto()
	{
		Name = "";
		Slots = [];
	}
}

sealed class SetsDto
{
	public int SchemaVersion { get; set; }

	public string Character { get; set; }

	public string Job { get; set; }

	public List<SetDto> Sets { get; set; }

	// BLU only: each blue magic list by name, with its spells.
	public Dictionary<string, List<string>>? SpellLists { get; set; }

	// BLU only: the blue spells that have a set of their own, where the framework looks for one, each with the name of
	// that set. Such a spell wears its own set whatever list it is in, or none.
	public Dictionary<string, string>? SpellSets { get; set; }

	public SetsDto()
	{
		SchemaVersion = Dto.SchemaVersion;
		Character = "";
		Job = "";
		Sets = [];
	}
}

// What the caller asks of the gear-optimizer agent.
sealed class OptimizeRequest
{
	public int SchemaVersion { get; set; }

	public string Character { get; set; }

	public string Job { get; set; }

	// The //gs export to choose from, relative to the repo.
	public string Export { get; set; }

	public SetsDto Sets { get; set; }

	// The bags the sets may take pieces from. Null allows every bag GearSwap equips from.
	public List<string>? Bags { get; set; }

	// By set name: what the caller wants of that set, in words or as a stat goal.
	public Dictionary<string, string>? Targets { get; set; }

	public OptimizeRequest()
	{
		SchemaVersion = Dto.SchemaVersion;
		Character = "";
		Job = "";
		Export = "";
		Sets = new SetsDto();
	}
}

// The agent's answer. Sets holds a full replacement for each set it touched.
sealed class OptimizeResult
{
	public int SchemaVersion { get; set; }

	public List<SetDto> Sets { get; set; }

	// BLU only: a full replacement for each blue magic list the agent changed. Null when it changed none.
	public Dictionary<string, List<string>>? SpellLists { get; set; }

	public List<SetChange> Changes { get; set; }

	public List<Shortfall> Shortfalls { get; set; }

	public List<string> Questions { get; set; }

	public List<string> DocsEdited { get; set; }

	public OptimizeResult()
	{
		SchemaVersion = Dto.SchemaVersion;
		Sets = [];
		Changes = [];
		Shortfalls = [];
		Questions = [];
		DocsEdited = [];
	}
}

sealed class SetChange
{
	public string Set { get; set; }

	public string Slot { get; set; }

	public string From { get; set; }

	public string To { get; set; }

	public string Reason { get; set; }

	public SetChange()
	{
		Set = "";
		Slot = "";
		From = "";
		To = "";
		Reason = "";
	}
}

sealed class Shortfall
{
	public string Set { get; set; }

	public string Stat { get; set; }

	public double Target { get; set; }

	public double Achieved { get; set; }

	public string Note { get; set; }

	public Shortfall()
	{
		Set = "";
		Stat = "";
		Note = "";
	}
}

// One problem a checker found, as its --json writes it. Severity is "error" or "warn".
sealed class Finding
{
	public string Tool { get; }

	public string Severity { get; }

	public string Set { get; }

	public string Slot { get; }

	public string Item { get; }

	public string Message { get; }

	public Finding(string tool, string severity, string set, string slot, string item, string message)
	{
		Tool = tool;
		Severity = severity;
		Set = set;
		Slot = slot;
		Item = item;
		Message = message;
	}
}
