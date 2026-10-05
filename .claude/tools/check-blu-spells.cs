// Checks a BLU job file's blue magic lists against Windower's spell list. The engine gives a blue spell the midcast
// set of the first list that names it, so a spell in two lists only ever gets the first one's set, and a spell in
// none gets no blue magic set at all, only the idle set under every cast. It also catches a misspelled spell name.
//
//   dotnet run --no-cache .claude/tools/check-blu-spells.cs [-- --char <name>]
//
// Exit code 1 when a spell is in no list or in two, or a list names something that isn't a blue spell.
using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.IO;
using System.Text.RegularExpressions;
using GearTools;

Tool.Init();
var cli = new Arguments(args, ["--char"], []);
var character = cli.Option("--char") ?? Export.CharacterOf(Export.Latest(null));
var jobPath = Tool.InRepo("data", character, "BLU.lua");
if (File.Exists(jobPath) is false)
	Tool.Fail($"No data/{character}/BLU.lua.");
var jobFile = LuaGearFile.StripComments(File.ReadAllText(jobPath));
var engine = LuaGearFile.StripComments(File.ReadAllText(Tool.InRepo("data", "common", "RahvinGS", "interface.lua")));

// In the order the engine tests them (builders.lua). A list the job file doesn't declare keeps the engine's own.
string[] order = ["BluePhysical", "BlueBreath", "BlueNuke", "BlueSkill", "BlueBuff", "BlueTank", "BlueHealing", "BlueACC"];
var lists = new Dictionary<string, HashSet<string>>();
foreach (var name in order)
{
	var declared = Regex.Match(jobFile, @"^" + name + @"\s*=\s*S\s*\{(.*?)\}", RegexOptions.Singleline | RegexOptions.Multiline);
	if (declared.Success is false)
		declared = Regex.Match(engine, @"^" + name + @"\s*=\s*S\s*\{(.*?)\}", RegexOptions.Singleline | RegexOptions.Multiline);
	lists[name] = Regex.Matches(declared.Groups[1].Value, @"'((?:[^'\\]|\\.)*)'|""((?:[^""\\]|\\.)*)""")
		.Select(match => (match.Groups[1].Success ? match.Groups[1].Value : match.Groups[2].Value).Replace("\\'", "'"))
		.ToHashSet();
}

var spells = Resources.BlueSpells().Distinct().ToList();
var problems = 0;
foreach (var spell in spells)
{
	var named = order.Where(name => lists[name].Contains(spell)).ToList();
	if (named.Count == 0)
	{
		Problem($"{spell}: in no list, so it casts in the idle set");
	}
	else if (named.Count > 1)
	{
		Problem($"{spell}: in {string.Join(" and ", named)}; only {named[0]} takes effect");
	}
}
foreach (var name in order)
{
	foreach (var unknown in lists[name].Where(spell => spells.Contains(spell) is false))
		Problem($"{name} names '{unknown}', which isn't a blue spell in Windower's resources");
}
Console.WriteLine($"{spells.Count} blue spells; {string.Join(", ", order.Select(name => $"{name} {lists[name].Count}"))}");
Console.WriteLine($"problems: {problems}");
return problems > 0 ? 1 : 0;

void Problem(string message)
{
	problems++;
	Console.WriteLine("  " + message);
}
