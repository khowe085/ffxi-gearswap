// Looks items up in wsdist's gear data, gear.py in .claude/cache/wsdist_beta (IzaKastra's damage simulator, which
// produced bg-wiki's simulated sets). Use it as a second opinion on an item's stats, and to see which rank and path
// entries the simulator has. docs/ffxi-mechanics.md lists where wsdist's formulas and item data are wrong.
//
//   dotnet run --no-cache .claude/tools/wsdist-gear.cs -- "<regex>"       entries whose Name or Name2 matches
//   dotnet run --no-cache .claude/tools/wsdist-gear.cs -- --check-nyame   Nyame's entries against docs/rank-augments.md
//
// It reads the one-line item dicts. Ambuscade capes and Linos are built by loops in gear.py (lines 440-447 and
// 1159-1225) and aren't found here. Exit code 1 when --check-nyame finds a difference. At the pinned commit it
// finds one: "Nyame Flanchard R15B" (gear.py line 1581), which docs/ffxi-mechanics.md lists among wsdist's errors.
using System;
using System.Text;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.IO;
using System.Text.RegularExpressions;
using GearTools;

Tool.Init();
var cli = new Arguments(args, [], ["--check-nyame"], takesWords: true);
var gearPath = Tool.InCache("wsdist_beta", "gear.py");
if (File.Exists(gearPath) is false)
	Tool.Fail("wsdist isn't in .claude/cache. Run: dotnet run --no-cache .claude/tools/fetch-sources.cs");

var entries = new List<GearEntry>();
var lines = File.ReadAllLines(gearPath);
for (var i = 0; i < lines.Length; i++)
{
	var entry = Regex.Match(lines[i], @"^(\w+)\s*=\s*\{(.*)\}\s*(#.*)?$");
	if (entry.Success)
		entries.Add(new GearEntry(i + 1, entry.Groups[1].Value, Fields(entry.Groups[2].Value)));
}
if (entries.Count == 0)
	Tool.Fail("gear.py in .claude/cache/wsdist_beta holds no item entry this tool can read. Delete that folder and run fetch-sources.cs again.");

if (cli.Flag("--check-nyame"))
	return CheckNyame();
if (cli.Words.Count != 1)
	Tool.Fail("Give one regex to match item names against, or --check-nyame.");
var wanted = Tool.Pattern("The item pattern", cli.Words[0]);
var found = entries.Where(entry => wanted.IsMatch(entry.Text("Name")) || wanted.IsMatch(entry.Text("Name2"))).ToList();
foreach (var entry in found)
{
	Console.WriteLine($"gear.py:{entry.Line}  {(entry.Text("Name2").Length > 0 ? entry.Text("Name2") : entry.Text("Name"))}  ({entry.Variable})");
	Console.WriteLine("    " + string.Join(", ", entry.Fields.Where(field => field.Key is not ("Name" or "Name2")).Select(field => $"{field.Key} {Shown(field.Value)}")));
}
Console.WriteLine($"{found.Count} of {entries.Count} entries");
return 0;

// A value as written, with its total when it is a sum such as 30+35.
string Shown(string value)
{
	var number = Number(value);
	var text = value.Replace("\"", "").Trim('[', ']').Replace(",", "").Trim();
	return number is null || value.Trim().All(c => char.IsDigit(c) || c is '.' or '-') ? text : $"{number.Value.ToString(CultureInfo.InvariantCulture)} ({value.Trim()})";
}

// The total of a value written as numbers joined by + and -, or null when it is anything else.
double? Number(string value)
{
	var text = value.Replace(" ", "");
	if (Regex.IsMatch(text, @"^[+-]?\d+(\.\d+)?([+-]\d+(\.\d+)?)*$") is false)
		return null;
	return Regex.Matches(text, @"[+-]?\d+(\.\d+)?").Sum(term => double.Parse(term.Value, CultureInfo.InvariantCulture));
}

// The "key": value pairs of a one-line Python dict, in order. A value runs to the next comma outside quotes and
// brackets.
List<KeyValuePair<string, string>> Fields(string body)
{
	var fields = new List<KeyValuePair<string, string>>();
	var i = 0;
	while (i < body.Length)
	{
		var key = Regex.Match(body[i..], @"^\s*f?""([^""]*)""\s*:\s*");
		if (key.Success is false)
			break;
		i += key.Length;
		var start = i;
		var depth = 0;
		char? quote = null;
		for (; i < body.Length; i++)
		{
			var c = body[i];
			if (quote is not null)
			{
				quote = c == quote ? null : quote;
			}
			else if (c is '"' or '\'')
			{
				quote = c;
			}
			else if (c is '[' or '(' or '{')
			{
				depth++;
			}
			else if (c is ']' or ')' or '}')
			{
				depth--;
			}
			else if (c == ',' && depth == 0)
			{
				break;
			}
		}
		fields.Add(KeyValuePair.Create(key.Groups[1].Value, body[start..i].Trim()));
		i++;
	}
	return fields;
}

// wsdist has an entry for each Nyame piece at rank 0 and, for paths A to C, at ranks 15, 20, 25 and 30. What each
// adds over the rank 0 entry should be the augment bg-wiki's rank table gives for that path and rank.
int CheckNyame()
{
	// bg-wiki's augment wording -> the stat keys wsdist uses.
	var statNames = new Dictionary<string, string>
	{
		["Attack"] = "Attack", ["Rng. Atk."] = "Ranged Attack", ["Accuracy"] = "Accuracy", ["Rng. Acc."] = "Ranged Accuracy",
		["Mag. Acc."] = "Magic Accuracy", ["Magic Accuracy"] = "Magic Accuracy", ["Weapon skill damage"] = "Weapon Skill Damage",
		["\"Double Attack\""] = "DA", ["\"Store TP\""] = "Store TP", ["Physical damage limit"] = "PDL", ["Critical hit rate"] = "Crit Rate",
		["\"Mag. Atk. Bns.\""] = "Magic Attack", ["Magic Damage"] = "Magic Damage", ["Magic burst damage II"] = "Magic Burst Damage II",
	};
	string[] attributes = ["STR", "DEX", "VIT", "AGI", "INT", "MND", "CHR"];

	// Item -> path -> rank -> the augment cells of that row of docs/rank-augments.md.
	var tables = new Dictionary<string, Dictionary<string, Dictionary<int, List<string>>>>();
	string? item = null;
	string? path = null;
	var docPath = Tool.InRepo("docs", "rank-augments.md");
	if (File.Exists(docPath) is false)
		Tool.Fail("docs/rank-augments.md is missing. Write it with: dotnet run --no-cache .claude/tools/rank-doc.cs");
	foreach (var line in File.ReadLines(docPath))
	{
		var heading = Regex.Match(line, @"^### (.+)$");
		var pathLine = Regex.Match(line, @"^Path ([A-D])");
		var row = Regex.Match(line, @"^\| (\d+) \|(.*)\|\s*$");
		if (heading.Success)
		{
			item = heading.Groups[1].Value.Trim();
			path = null;
		}
		else if (pathLine.Success)
		{
			path = pathLine.Groups[1].Value;
		}
		else if (row.Success && item is not null && path is not null && item.StartsWith("Nyame"))
		{
			if (tables.TryGetValue(item, out var byPath) is false)
				tables[item] = byPath = [];
			if (byPath.TryGetValue(path, out var byRank) is false)
				byPath[path] = byRank = [];
			byRank[int.Parse(row.Groups[1].Value)] = row.Groups[2].Value.Split('|').Select(cell => cell.Trim()).Where(cell => cell.Length > 0).ToList();
		}
	}

	var differences = 0;
	var nyame = entries.Select(entry => new { Entry = entry, Id = Regex.Match(entry.Variable, @"^Nyame_\w+?(\d+)([A-D]?)$") }).Where(pair => pair.Id.Success).ToList();
	var ranked = nyame.Where(pair => pair.Id.Groups[1].Value != "0").ToList();
	// Nothing to compare isn't a pass. It means wsdist no longer names these entries the way this reads them.
	if (ranked.Count == 0)
		Tool.Fail("gear.py has no ranked Nyame entry, such as Nyame_Helm15B, so there is nothing to check.");
	foreach (var pair in ranked)
	{
		var name = pair.Entry.Text("Name");
		var rank = int.Parse(pair.Id.Groups[1].Value);
		var letter = pair.Id.Groups[2].Value;
		var unranked = nyame.FirstOrDefault(other => other.Entry.Text("Name") == name && other.Id.Groups[1].Value == "0")?.Entry;
		if (unranked is null || tables.TryGetValue(name, out var byPath) is false || byPath.TryGetValue(letter, out var byRank) is false || byRank.TryGetValue(rank, out var cells) is false)
		{
			Console.WriteLine($"gear.py:{pair.Entry.Line} {name} R{rank}{letter}: no rank 0 entry or no row in docs/rank-augments.md to compare with");
			differences++;
			continue;
		}
		var added = new SortedDictionary<string, double>(StringComparer.Ordinal);
		foreach (var field in pair.Entry.Fields.Where(field => field.Key != "Rank"))
		{
			var value = Number(field.Value);
			var before = Number(unranked.Text(field.Key)) ?? 0;
			if (value is not null && value.Value != before)
				added[field.Key] = value.Value - before;
		}
		var expected = new SortedDictionary<string, double>(StringComparer.Ordinal);
		foreach (var cell in cells)
		{
			// One cell can hold two augments: "Attack+25 Rng. Atk.+25".
			foreach (var part in Regex.Split(cell, @"(?<=\d)%?\s+(?=[A-Z""])"))
			{
				var augment = Regex.Match(part.Trim(), @"^(.*?)\s*([+-])\s*(\d+)%?$");
				if (augment.Success is false)
				{
					Console.WriteLine($"docs/rank-augments.md, {name} R{rank}{letter}: can't read \"{part}\"");
					differences++;
					continue;
				}
				var amount = int.Parse(augment.Groups[3].Value) * (augment.Groups[2].Value == "-" ? -1 : 1);
				var wording = augment.Groups[1].Value.Trim();
				// "STR/VIT" and the like raise each attribute named.
				string[] stats = [];
				if (wording.Split('/').All(attributes.Contains))
				{
					stats = wording.Split('/');
				}
				else if (statNames.TryGetValue(wording, out var known))
				{
					stats = [known];
				}
				else
				{
					Console.WriteLine($"docs/rank-augments.md, {name} R{rank}{letter}: no wsdist stat known for \"{wording}\"");
					differences++;
				}
				foreach (var stat in stats)
					expected[stat] = expected.GetValueOrDefault(stat) + amount;
			}
		}
		if (added.SequenceEqual(expected) is false)
		{
			Console.WriteLine($"gear.py:{pair.Entry.Line} {name} R{rank}{letter}: wsdist adds {Listed(added)} | bg-wiki {Listed(expected)}");
			differences++;
		}
	}
	Console.WriteLine($"{ranked.Count} ranked Nyame entries checked; differences: {differences}");
	return differences > 0 ? 1 : 0;
}

string Listed(SortedDictionary<string, double> stats) => string.Join(", ", stats.Select(stat => $"{stat.Key} {stat.Value.ToString(CultureInfo.InvariantCulture)}"));

// One item dict of gear.py: the line it is on, the Python variable it is assigned to, and its fields in order.
sealed class GearEntry
{
	public int Line { get; }

	public string Variable { get; }

	public IReadOnlyList<KeyValuePair<string, string>> Fields { get; }

	public GearEntry(int line, string variable, IReadOnlyList<KeyValuePair<string, string>> fields)
	{
		Line = line;
		Variable = variable;
		Fields = fields;
	}

	// A field's value without its quotes, or empty when the entry doesn't have the field.
	public string Text(string key) => Fields.FirstOrDefault(field => field.Key == key).Value?.Trim('"') ?? "";
}
