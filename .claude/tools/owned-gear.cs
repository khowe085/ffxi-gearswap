// Lists the weapons and armor in a character's //gs export with what the export leaves out: each piece's slot,
// jobs and in-game help text from Windower's resources, the gear.<key> entries that name it, and the job files
// whose sets already wear it. This is the pool a set is chosen from. Gear stored on a storage slip is listed
// too, under the bag name slip<N>.
//
//   dotnet run --no-cache .claude/tools/owned-gear.cs [-- --job RDM,BLU] [--slot legs] [--grep <regex>] [--json]
//                                                       [--char <name>] [--export <path>]
//
// --job keeps the pieces at least one of those jobs can wear. --slot takes main, sub, range, ammo, head, neck, ear,
// body, hands, ring, back, waist, legs or feet. --grep is a case-insensitive regex over the name, the help text and
// the augments. A copy held more than once is one line, with every bag it is in.
using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Text.Encodings.Web;
using System.Text.Json;
using System.Text.RegularExpressions;
using GearTools;

Tool.Init();
var cli = new Arguments(args, ["--job", "--slot", "--grep", "--char", "--export"], ["--json"]);
var exportPath = Export.Resolve(cli);
var character = Characters.Named(cli.Option("--char") ?? Export.CharacterOf(exportPath));
var resources = Resources.Load();
var files = GearFiles.Load(character);
var wantedJobs = (cli.Option("--job") ?? "").Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries).Select(job => job.ToUpperInvariant()).ToList();
foreach (var job in wantedJobs.Where(job => Resources.JobNames.Contains(job) is false))
	Tool.Fail($"{job} isn't a job. Jobs: {string.Join(" ", Resources.JobNames.Skip(1))}");
var slot = cli.Option("--slot") switch
{
	null => null,
	"ear" => "left_ear",
	"ring" => "left_ring",
	var other => ItemInfo.CanonicalSlot(other),
};
if (slot is not null && Resources.SlotNames.Contains(slot) is false)
	Tool.Fail($"{cli.Option("--slot")} isn't a slot. Slots: main sub range ammo head neck ear body hands ring back waist legs feet");
var grep = cli.Option("--grep") is { } pattern ? Tool.Pattern("--grep", pattern) : null;

// Every definition that could name a piece, with the file it is in when that isn't the library.
var definitions = files.Library.Defs.Select(def => new NamedDef(def, null)).ToList();
if (files.Globals is not null)
	definitions.AddRange(files.Globals.Defs.Select(def => new NamedDef(def, files.Globals.FileName)));
foreach (var file in files.Jobs.Values)
	definitions.AddRange(file.Defs.Select(def => new NamedDef(def, file.FileName)));
var defsByJob = files.Jobs.Keys.ToDictionary(job => job, files.DefsFor);

var pieces = new List<OwnedPiece>();
var unknown = new List<string>();
foreach (var copies in Export.Read(exportPath).Where(line => line.SlotKey != "item").GroupBy(line => line.Name + "|" + line.AugmentText))
{
	var copy = copies.First();
	var candidates = resources.Named(copy.Name);
	var item = resources.Pick(copy.Name, copy.SlotKey);
	if (item is null)
	{
		unknown.Add(copy.Name);
		continue;
	}
	if (wantedJobs.Count > 0 && wantedJobs.Any(item.WornBy) is false)
		continue;
	if (slot is not null && item.FitsSlot(slot) is false)
		continue;
	if (grep is not null && grep.IsMatch(copy.Name + "\n" + item.Description + "\n" + copy.AugmentText) is false)
		continue;
	bool Names(GearDef def) => candidates.Any(candidate => candidate.Name.Equals(def.Name, StringComparison.OrdinalIgnoreCase) || candidate.LogName.Equals(def.Name, StringComparison.OrdinalIgnoreCase)) && def.Matches(copy);
	var keys = definitions.Where(named => Names(named.Def))
		.GroupBy(named => named.Def.Key)
		.Select(group => "gear." + group.Key + (group.All(named => named.FileName is null) ? "" : $" ({string.Join(", ", group.Where(named => named.FileName is not null).Select(named => named.FileName))})"))
		.ToList();
	var wornBy = new Dictionary<string, List<string>>();
	foreach (var job in files.Jobs.Keys)
	{
		var sets = files.Jobs[job].Uses.Where(use => defsByJob[job].TryGetValue(use.Key, out var def) && Names(def)).Select(use => use.SetName).Distinct().ToList();
		if (sets.Count > 0)
			wornBy[job] = sets;
	}
	pieces.Add(new OwnedPiece(copy, copies.Select(line => line.Bag).ToList(), item, candidates.Count, keys, wornBy));
}

string[] groupOrder = ["main", "sub", "range", "ammo", "head", "neck", "ear", "body", "hands", "ring", "back", "waist", "legs", "feet"];
pieces = pieces.OrderBy(piece => Array.IndexOf(groupOrder, piece.Group)).ThenBy(piece => piece.Name, StringComparer.Ordinal).ThenBy(piece => string.Join(", ", piece.Augments), StringComparer.Ordinal).ToList();

if (cli.Flag("--json"))
{
	Console.WriteLine(OwnedPiece.ToJson(pieces));
}
else
{
	Console.WriteLine($"# {Tool.RepoRelative(exportPath)}");
	Console.WriteLine("# slot | name | augments | bags (! = GearSwap can't equip from it) | jobs | keys | worn by | help text");
	foreach (var piece in pieces)
	{
		var bags = string.Join(", ", piece.Bags.Select(bag => Export.EquippableBags.Contains(bag) || bag.Length == 0 ? bag : "!" + bag));
		// The piece's own jobs, whatever --job asked for, so a job that can't wear it is seen to be missing.
		var jobs = piece.Jobs.Count == 22 ? "All jobs" : string.Join(" ", piece.Jobs);
		var helpText = string.Join(" / ", piece.Description.Split('\n', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries));
		var stages = piece.SharedIds > 1 ? $" [{piece.SharedIds} items share this name; this is the highest stage]" : "";
		Console.WriteLine($"{piece.Group,-5} | {piece.Name} | {string.Join(", ", piece.Augments)} | {bags} | {jobs} | {string.Join(", ", piece.Keys)} | {string.Join(" ", piece.WornBy.Keys)} | {helpText}{stages}");
	}
}
Console.Error.WriteLine($"{pieces.Count} pieces{(unknown.Count > 0 ? $"; not weapons or armor in the resources: {string.Join(", ", unknown.Distinct())}" : "")}");

// A definition and the file that holds it. The file is null for the library.
sealed class NamedDef
{
	public GearDef Def { get; }

	public string? FileName { get; }

	public NamedDef(GearDef def, string? fileName)
	{
		Def = def;
		FileName = fileName;
	}
}

// One piece the character holds: a copy from the export with what the resources and the gear files say of it.
sealed class OwnedPiece
{
	// The short name, as the export prints it.
	public string Name { get; }

	public string LogName { get; }

	public int Id { get; }

	// How many item ids share the name. Above 1, the export can't say which stage this copy is.
	public int SharedIds { get; }

	public IReadOnlyList<string> Augments { get; }

	// One entry per copy held.
	public IReadOnlyList<string> Bags { get; }

	public string Group { get; }

	public IReadOnlyList<string> Slots { get; }

	public IReadOnlyList<string> Jobs { get; }

	public int Level { get; }

	public int ItemLevel { get; }

	public string Description { get; }

	// The gear.<key> entries that name this copy, with the job file for the ones defined outside the library.
	public IReadOnlyList<string> Keys { get; }

	// The sets that wear it, by job file.
	public IReadOnlyDictionary<string, List<string>> WornBy { get; }

	public OwnedPiece(ExportItem copy, IReadOnlyList<string> bags, ItemInfo item, int sharedIds, IReadOnlyList<string> keys, IReadOnlyDictionary<string, List<string>> wornBy)
	{
		Name = copy.Name;
		LogName = item.LogName;
		Id = item.Id;
		SharedIds = sharedIds;
		Augments = copy.Augments;
		Bags = bags;
		Group = item.Group.Length > 0 ? item.Group : copy.SlotKey;
		Slots = item.Slots;
		Jobs = item.Jobs;
		Level = item.Level;
		ItemLevel = item.ItemLevel;
		Description = item.Description;
		Keys = keys;
		WornBy = wornBy;
	}

	public static string ToJson(IEnumerable<OwnedPiece> pieces) =>
		JsonSerializer.Serialize(pieces.Select(piece => new Json(piece)), new JsonSerializerOptions { WriteIndented = true, Encoder = JavaScriptEncoder.UnsafeRelaxedJsonEscaping });

	// A piece as --json writes it. search-fast-recast.cs and any script made from it read these names.
	sealed class Json
	{
		public string Name { get; }

		public string LogName { get; }

		public int Id { get; }

		public int SharedIds { get; }

		public IReadOnlyList<string> Augments { get; }

		public IReadOnlyList<string> Bags { get; }

		public string Group { get; }

		public IReadOnlyList<string> Slots { get; }

		public IReadOnlyList<string> Jobs { get; }

		public int Level { get; }

		public int ItemLevel { get; }

		public string Description { get; }

		public IReadOnlyList<string> Keys { get; }

		public IReadOnlyDictionary<string, List<string>> WornBy { get; }

		public Json(OwnedPiece piece)
		{
			Name = piece.Name;
			LogName = piece.LogName;
			Id = piece.Id;
			SharedIds = piece.SharedIds;
			Augments = piece.Augments;
			Bags = piece.Bags;
			Group = piece.Group;
			Slots = piece.Slots;
			Jobs = piece.Jobs;
			Level = piece.Level;
			ItemLevel = piece.ItemLevel;
			Description = piece.Description;
			Keys = piece.Keys;
			WornBy = piece.WornBy;
		}
	}
}
