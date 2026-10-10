// Checks every piece a sets file (lib/Dto.cs) puts in a slot against the character's //gs export and Windower's
// resources: the item exists and is owned with those augments, the job can wear it, it fits the slot, and a copy sits
// in a bag GearSwap can equip from (or in one of the bags --bags names). Gear on a storage slip counts as owned, but
// has to come back from a porter moogle before a set can wear it. Each set's own slots are checked, so a piece a base
// set wears is checked once, where that set names it.
//
//   dotnet run --no-cache .claude/tools/check-export.cs -- --in <sets.json> [--bags wardrobe,wardrobe2] [--json]
//                                                         [--export <path>]
//
// Without --export it reads the newest export of the sets file's character. The text output gives each problem once,
// with every set and slot it is in; --json writes one finding for each set and slot instead.
// Exit code 1 when it finds an error. Warnings (a piece that has to be moved to a wardrobe) don't change it.
using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.IO;
using GearTools;

Tool.Init();
var cli = new Arguments(args, ["--in", "--bags", "--export"], ["--json"]);
var input = cli.Option("--in");
if (input is null)
	Tool.Fail("Name the sets file to check: --in <sets.json>");
var sets = Dto.LoadSets(input);
var allowed = cli.Option("--bags")?.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries).ToList();
foreach (var bag in allowed?.Where(bag => Export.EquippableBags.Contains(bag) is false) ?? [])
	Tool.Fail($"--bags names {bag}, which GearSwap can't equip from. Bags: {string.Join(" ", Export.EquippableBags)}");
var exportPath = Export.ForSets(cli, sets.Character);
var owned = Export.Read(exportPath);
var resources = Resources.Load();

// Each finding with the slot it was found in.
var findings = new List<KeyValuePair<Finding, Worn>>();
var job = sets.Job;
var worn = sets.Sets.SelectMany(set => set.Slots.Where(slot => slot.Value.Item != Dto.Empty).Select(slot => new Worn(set.Name, slot.Key, slot.Value))).ToList();
foreach (var piece in worn.GroupBy(use => Identity(use.Piece)))
{
	var first = piece.First().Piece;
	var items = resources.Named(first.Item);
	if (items.Count == 0)
	{
		Add(piece, "error", "no weapon or armor has that name or log name, so GearSwap equips nothing and says nothing");
		continue;
	}
	// The export prints the short name, whichever name the piece gives.
	var copies = owned.Where(copy => items.Any(item => item.Name.Equals(copy.Name, StringComparison.OrdinalIgnoreCase))).ToList();
	if (copies.Count == 0)
	{
		Add(piece, "error", "not in the export");
		continue;
	}
	var matching = copies.Where(first.Matches).ToList();
	if (matching.Count == 0)
	{
		Add(piece, "error", $"augments match no copy. The export has: {string.Join(" | ", copies.Select(copy => $"[{copy.AugmentText}]"))}");
		continue;
	}
	if (items.Any(item => item.WornBy(job)) is false)
		Add(piece, "error", $"{job} can't wear it (jobs: {string.Join(" ", items[0].Jobs)})");
	foreach (var use in piece.Where(use => items.Any(item => item.FitsSlot(use.Slot)) is false))
		Add([use], "error", $"goes in {string.Join(" or ", items[0].Slots)}, not {use.Slot}");
	if (first.Bag is not null && matching.Any(copy => copy.Bag == first.Bag) is false)
	{
		Add(piece, "error", $"pinned to {first.Bag}, but the matching copies are in {Bags(matching)}");
		continue;
	}
	// GearSwap takes a pinned piece from its bag only, so the other copies don't count.
	if (first.Bag is not null)
		matching = matching.Where(copy => copy.Bag == first.Bag).ToList();
	if (allowed is not null && matching.Any(copy => allowed.Contains(copy.Bag)) is false)
	{
		Add(piece, "error", $"only in {Bags(matching)}, and --bags allows {string.Join(", ", allowed)}");
	}
	else if (matching.All(copy => copy.Slip > 0))
	{
		Add(piece, "warn", $"only on storage slip {matching[0].Slip}. Get it back from a porter moogle and put it in a wardrobe before a set can wear it");
	}
	else if (matching.Any(copy => copy.CanBeEquippedFromBag) is false)
	{
		Add(piece, "warn", $"only in {Bags(matching)}. GearSwap equips from the inventory and the wardrobes, so move it");
	}
}

var errors = findings.Count(finding => finding.Key.Severity == "error");
if (cli.Flag("--json"))
{
	Console.WriteLine(Dto.ToJson(findings.Select(finding => finding.Key).ToList()));
	return errors > 0 ? 1 : 0;
}
Console.WriteLine($"Export: {Tool.RepoRelative(exportPath)}");
Console.WriteLine($"{input}: {job}, {sets.Sets.Count} sets, {worn.Select(use => Identity(use.Piece)).Distinct().Count()} pieces");
// One line for each problem, with every set and slot it is found in.
var lines = findings.GroupBy(finding => (finding.Key.Severity, Label: Label(finding.Value.Piece), finding.Key.Message)).ToList();
foreach (var line in lines)
	Console.WriteLine($"  {(line.Key.Severity == "error" ? "ERROR" : "warn ")} {line.Key.Label}: {line.Key.Message} ({string.Join(", ", line.Select(finding => $"{finding.Key.Set} {finding.Key.Slot}"))})");
Console.WriteLine($"problems: {lines.Count(line => line.Key.Severity == "error")} errors, {lines.Count(line => line.Key.Severity == "warn")} warnings");
return errors > 0 ? 1 : 0;

void Add(IEnumerable<Worn> uses, string severity, string message)
{
	foreach (var use in uses)
		findings.Add(KeyValuePair.Create(new Finding("check-export", severity, use.Set, use.Slot, use.Piece.Item, message), use));
}

// The piece as the text output names it: the item, then its augments and its bag when it gives them.
string Label(PieceDto piece) => $"\"{piece.Item}\""
	+ (piece.Augments is { Count: > 0 } ? $" [{string.Join(", ", piece.Augments)}]" : "")
	+ (piece.Bag is null ? "" : $" ({piece.Bag})");

// GearSwap matches an item's name without regard to case.
string Identity(PieceDto piece) => Label(piece).ToLowerInvariant();

string Bags(List<ExportItem> copies) => string.Join(", ", copies.Select(copy => copy.Bag.Length == 0 ? "an unnamed bag" : copy.Bag).Distinct());

// One slot of one set and the piece in it.
sealed class Worn
{
	public string Set { get; }

	public string Slot { get; }

	public PieceDto Piece { get; }

	public Worn(string set, string slot, PieceDto piece)
	{
		Set = set;
		Slot = slot;
		Piece = piece;
	}
}
