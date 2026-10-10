// Prints each set's stat totals (lib/SetStats.cs) from a sets file (lib/Dto.cs): each set laid over its base, every
// piece's help text, its copy's augments from the export, a path piece's augments at the character's rank from
// data/<Character>/<Character>_rank_augments.md, and the extra stats a file gives for what none of those show (hidden
// values from docs/gear-notes.md).
// The gear-optimizer agent reports its shortfalls from these numbers.
//
//   dotnet run --no-cache .claude/tools/set-stats.cs -- --in <sets.json> [--set <regex>] [--extra <stats.json>]
//                                                     [--json] [--export <path>]
//
// --set keeps the sets whose name matches. --extra is { "<item>": { "<stat>": <value>, ... } }, by the name the export
// prints, with the stat names the output uses (FC, DT, Macc and so on). --json writes [ { "set", "stats", "warnings" } ].
// A piece the resources don't know, whose augments no exported copy has, or whose path's rank the player hasn't given,
// is warned of on standard error (in "warnings" with --json), since its stats are missing from the totals.
// The rank file follows the newest export, as rank-doc.cs writes it, whatever --export names. An item Oboro ranks up
// counts at its maximum rank, from docs/rank-augments.md, which gives no other; below it, it is warned of.
using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.IO;
using System.Text.Json;
using GearTools;

Tool.Init();
var cli = new Arguments(args, ["--in", "--set", "--extra", "--export"], ["--json"]);
var input = cli.Option("--in");
if (input is null)
	Tool.Fail("Name the sets file: --in <sets.json>");
var sets = Dto.LoadSets(input);
var only = cli.Option("--set") is { } pattern ? Tool.Pattern("--set", pattern) : null;
var extra = new Dictionary<string, Dictionary<string, int>>();
if (cli.Option("--extra") is { } extraPath)
{
	if (File.Exists(extraPath) is false)
		Tool.Fail($"No stats file at {extraPath}.");
	try
	{
		extra = JsonSerializer.Deserialize<Dictionary<string, Dictionary<string, int>>>(File.ReadAllText(extraPath)) ?? [];
	}
	catch (JsonException problem)
	{
		Tool.Fail($"{extraPath} can't be read as {{ \"<item>\": {{ \"<stat>\": <value> }} }}: {problem.Message}");
	}
}
// A path piece's augments at the character's rank come from the character's rank file, when there is one.
var rankFile = Characters.RankAugments(sets.Character);
var ranks = File.Exists(rankFile) ? RankAugments.Read(rankFile, Tool.InRepo("docs", "rank-augments.md")) : [];
var book = new StatBook(Resources.Load(), Export.Read(Export.ForSets(cli, sets.Character)), extra, ranks);

var totals = new List<SetTotals>();
foreach (var set in sets.Sets.Where(set => only?.IsMatch(set.Name) ?? true))
{
	var warnings = new List<string>();
	totals.Add(new SetTotals(set.Name, book.Totals(Dto.Resolve(sets, set.Name), warnings), warnings));
}
if (cli.Flag("--json"))
{
	Console.WriteLine(Dto.ToJson(totals));
	return 0;
}
foreach (var set in totals)
{
	Console.WriteLine(set.Set);
	Console.WriteLine("    = " + StatBook.Describe(set.Stats));
	foreach (var warning in set.Warnings)
		Console.Error.WriteLine($"  warn  {set.Set} {warning}");
}
return 0;

// One set's totals, as --json writes them.
sealed class SetTotals
{
	public string Set { get; }

	public Dictionary<string, int> Stats { get; }

	// What couldn't be counted: a piece the resources don't know, or augments no exported copy has.
	public IReadOnlyList<string> Warnings { get; }

	public SetTotals(string set, Dictionary<string, int> stats, IReadOnlyList<string> warnings)
	{
		Set = set;
		Stats = stats;
		Warnings = warnings;
	}
}
