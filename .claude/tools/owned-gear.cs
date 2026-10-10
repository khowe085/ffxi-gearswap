// Lists the weapons and armor in a character's //gs export with what the export leaves out: each piece's slot,
// jobs and in-game help text from Windower's resources, and the sets that already wear it, from the sets files
// (lib/Dto.cs) given with --sets. This is the pool a set is chosen from. Gear stored on a storage slip is listed
// too, under the bag name slip<N>.
//
//   dotnet run --no-cache .claude/tools/owned-gear.cs [-- --job RDM,BLU] [--slot legs] [--grep <regex>]
//                                                       [--json | --findings] [--sets <sets.json> ...]
//                                                       [--char <name>] [--export <path>]
//
// --json writes the pieces, in the shape search-fast-recast.cs reads. --findings writes what the other checkers'
// --json writes (lib/Dto.cs): here, each piece in the export that Windower's resources don't know as gear. The two
// names differ because --json was already taken by the list of pieces.
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
var cli = new Arguments(args, ["--job", "--slot", "--grep", "--sets", "--char", "--export"], ["--json", "--findings"]);
if (cli.Flag("--json") && cli.Flag("--findings"))
	Tool.Fail("--json writes the pieces and --findings writes findings; give one of them.");
var exportPath = Export.Resolve(cli);
var character = Characters.Named(cli.Option("--char") ?? Export.CharacterOf(exportPath));
var resources = Resources.Load();
var wearers = cli.Options("--sets").Select(Dto.LoadSets).ToList();
foreach (var sets in wearers)
	Export.RequireOwner(exportPath, sets.Character);
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

var pieces = new List<OwnedPiece>();
var unknown = new List<ExportItem>();
foreach (var copies in Export.Read(exportPath).Where(line => line.SlotKey != "item").GroupBy(line => line.Name + "|" + line.AugmentText))
{
	var copy = copies.First();
	var candidates = resources.Named(copy.Name);
	var item = resources.Pick(copy.Name, copy.SlotKey);
	if (item is null)
	{
		unknown.Add(copy);
		continue;
	}
	if (wantedJobs.Count > 0 && wantedJobs.Any(item.WornBy) is false)
		continue;
	if (slot is not null && item.FitsSlot(slot) is false)
		continue;
	if (grep is not null && grep.IsMatch(copy.Name + "\n" + item.Description + "\n" + copy.AugmentText) is false)
		continue;
	bool Names(PieceDto piece) => candidates.Any(candidate => candidate.Name.Equals(piece.Item, StringComparison.OrdinalIgnoreCase) || candidate.LogName.Equals(piece.Item, StringComparison.OrdinalIgnoreCase)) && piece.Matches(copy);
	var wornBy = new Dictionary<string, List<string>>();
	foreach (var sets in wearers)
	{
		var wearing = sets.Sets.Where(set => set.Slots.Values.Any(Names)).Select(set => set.Name).ToList();
		if (wearing.Count > 0)
			wornBy[sets.Job] = (wornBy.GetValueOrDefault(sets.Job) ?? []).Union(wearing).ToList();
	}
	pieces.Add(new OwnedPiece(copy, copies.Select(line => line.Bag).ToList(), item, candidates.Count, wornBy));
}

string[] groupOrder = ["main", "sub", "range", "ammo", "head", "neck", "ear", "body", "hands", "ring", "back", "waist", "legs", "feet"];
pieces = pieces.OrderBy(piece => Array.IndexOf(groupOrder, piece.Group)).ThenBy(piece => piece.Name, StringComparer.Ordinal).ThenBy(piece => string.Join(", ", piece.Augments), StringComparer.Ordinal).ToList();

if (cli.Flag("--findings"))
{
	var findings = unknown.DistinctBy(copy => copy.Name).Select(copy => new Finding("owned-gear", "warn", "", copy.SlotKey, copy.Name, "not a weapon or armor in Windower's resources")).ToList();
	Console.WriteLine(Dto.ToJson(findings));
}
else if (cli.Flag("--json"))
{
	Console.WriteLine(OwnedPiece.ToJson(pieces));
}
else
{
	Console.WriteLine($"# {Tool.RepoRelative(exportPath)}");
	Console.WriteLine("# slot | name | augments | bags (! = GearSwap can't equip from it) | jobs | worn by | help text");
	foreach (var piece in pieces)
	{
		var bags = string.Join(", ", piece.Bags.Select(bag => Export.EquippableBags.Contains(bag) || bag.Length == 0 ? bag : "!" + bag));
		// The piece's own jobs, whatever --job asked for, so a job that can't wear it is seen to be missing.
		var jobs = piece.Jobs.Count == 22 ? "All jobs" : string.Join(" ", piece.Jobs);
		var helpText = string.Join(" / ", piece.Description.Split('\n', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries));
		var stages = piece.SharedIds > 1 ? $" [{piece.SharedIds} items share this name; this is the highest stage]" : "";
		Console.WriteLine($"{piece.Group,-5} | {piece.Name} | {string.Join(", ", piece.Augments)} | {bags} | {jobs} | {string.Join(" ", piece.WornBy.Keys.Order(StringComparer.Ordinal))} | {helpText}{stages}");
	}
}
Console.Error.WriteLine($"{pieces.Count} pieces{(unknown.Count > 0 ? $"; not weapons or armor in the resources: {string.Join(", ", unknown.Select(copy => copy.Name).Distinct())}" : "")}");

// One piece the character holds: a copy from the export with what the resources and the sets files say of it.
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

	// The sets that wear it, by job.
	public IReadOnlyDictionary<string, List<string>> WornBy { get; }

	public OwnedPiece(ExportItem copy, IReadOnlyList<string> bags, ItemInfo item, int sharedIds, IReadOnlyDictionary<string, List<string>> wornBy)
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
			WornBy = piece.WornBy;
		}
	}
}
