// Checks the blue magic lists of a BLU sets file (its spellLists, lib/Dto.cs) against Windower's spell list: every
// blue spell is in exactly one list, and every name in a list is a blue spell. A spell the sets file's spellSets gives
// a set of its own wears that set whatever the lists say, so it needs no list, and two lists don't matter for it. A spell in two lists wears whichever
// list's set the framework happens to try first; a spell in none wears no list's set; a misspelled name places
// nothing.
//
//   dotnet run --no-cache .claude/tools/check-blu-spells.cs -- --in <sets.json> [--json]
//
// --json writes the problems as findings (lib/Dto.cs): the spell as the item, and the lists that name it as the set.
// Exit code 1 when a spell is in no list or in two, or a list names something that isn't a blue spell.
using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.IO;
using GearTools;

Tool.Init();
var cli = new Arguments(args, ["--in"], ["--json"]);
var spells = Resources.BlueSpells().Distinct().ToList();
var input = cli.Option("--in");
if (input is null)
	Tool.Fail("Name the sets file to check: --in <sets.json>");
var sets = Dto.LoadSets(input);
var lists = sets.SpellLists;
var ownSets = sets.SpellSets ?? [];
if (lists is null || lists.Count == 0)
	Tool.Fail($"{input} has no spellLists to check.");

// Each finding with its line in the text output.
var findings = new List<KeyValuePair<Finding, string>>();
var placedBySet = new List<string>();
foreach (var spell in spells)
{
	var named = lists.Where(list => list.Value.Contains(spell)).Select(list => list.Key).ToList();
	if (named.Count == 0 && ownSets.TryGetValue(spell, out var own))
	{
		placedBySet.Add($"{spell} ({own})");
	}
	else if (ownSets.ContainsKey(spell))
	{
		// A set of its own wins over any list's, so two lists choose nothing.
	}
	else if (named.Count == 0)
	{
		Problem("", spell, "in no list", $"{spell}: in no list");
	}
	else if (named.Count > 1)
	{
		var message = $"in {string.Join(" and ", named)}; keep it in one, since which list's set it wears is up to the framework";
		Problem(string.Join(", ", named), spell, message, $"{spell}: {message}");
	}
}
foreach (var list in lists)
{
	foreach (var unknown in list.Value.Distinct().Where(spell => spells.Contains(spell) is false))
		Problem(list.Key, unknown, "isn't a blue spell in Windower's resources", $"{list.Key} names '{unknown}', which isn't a blue spell in Windower's resources");
}
if (cli.Flag("--json"))
{
	Console.WriteLine(Dto.ToJson(findings.Select(finding => finding.Key).ToList()));
	return findings.Count > 0 ? 1 : 0;
}
foreach (var finding in findings)
	Console.WriteLine("  " + finding.Value);
Console.WriteLine($"{spells.Count} blue spells; {string.Join(", ", lists.Select(list => $"{list.Key} {list.Value.Count}"))}");
if (placedBySet.Count > 0)
	Console.WriteLine($"in no list, wearing a set of its own: {string.Join(", ", placedBySet)}");
Console.WriteLine($"problems: {findings.Count}");
return findings.Count > 0 ? 1 : 0;

void Problem(string set, string spell, string message, string text) => findings.Add(KeyValuePair.Create(new Finding("check-blu-spells", "error", set, "", spell, message), text));
