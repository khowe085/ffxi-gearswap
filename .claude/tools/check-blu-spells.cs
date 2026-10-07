// Checks a BLU job file's blue magic lists against Windower's spell list. The engine gives a blue spell the midcast
// set of the first list that names it, so a spell in two lists only ever gets the first one's set, and a spell in
// none gets no blue magic set at all: it casts in the idle set with only sets.Midcast over it. It also catches a
// misspelled spell name.
//
//   dotnet run --no-cache .claude/tools/check-blu-spells.cs [-- --char <name>]
//
// A list is read from the job file when the file assigns it whole, as Name = S { ... } at the start of a line, and
// from the engine otherwise. The output says which lists came from where. The job file is read as text, so any other
// assignment to a list, and an add or remove call on one, is reported as a change this check can't read.
//
// A spell with a set of its own, sets.Midcast['<spell>'], needs no list: the engine wears that set in place of any
// list's.
//
// Exit code 1 when a spell is in no list or in two, a list names something that isn't a blue spell, or the job file
// changes a list in a way this check can't read.
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
var character = Characters.Named(cli.Option("--char") ?? Export.CharacterOf(Export.Latest(null)));
var jobPath = Tool.InRepo("data", character, "BLU.lua");
if (File.Exists(jobPath) is false)
	Tool.Fail($"No data/{character}/BLU.lua.");
var enginePath = Tool.InRepo("data", "common", "RahvinGS", "interface.lua");
if (File.Exists(enginePath) is false)
	Tool.Fail("data/common/RahvinGS/interface.lua is missing. Run: git submodule update --init");
var jobFile = LuaGearFile.StripComments(File.ReadAllText(jobPath));
var engine = LuaGearFile.StripComments(File.ReadAllText(enginePath));

// In the order the engine tests them (builders.lua).
string[] order = ["BluePhysical", "BlueBreath", "BlueNuke", "BlueSkill", "BlueBuff", "BlueTank", "BlueHealing", "BlueACC"];
var problems = 0;
var lists = new Dictionary<string, HashSet<string>>();
var fromJobFile = new List<string>();
foreach (var name in order)
{
	// The one form this check reads: the list assigned whole, at the start of a line. A list the job file doesn't
	// assign that way keeps the engine's own.
	var whole = new Regex(@"^[ \t]*(" + name + @")\s*=\s*S\s*\{(.*?)\}", RegexOptions.Singleline | RegexOptions.Multiline);
	var declared = whole.Match(jobFile);
	if (declared.Success)
		fromJobFile.Add(name);
	// Any other assignment, and a call that adds to the list or removes from it, changes what the game ends up
	// with in a way the text alone doesn't show: a second assignment may run before the first or after it.
	var changes = Regex.Matches(jobFile, @"(?<![.\w])" + name + @"\s*(?:=(?!=)|:\s*(?:add|remove)\s*\()")
		.Where(change => declared.Success is false || change.Index != declared.Groups[1].Index)
		.Select(change => jobFile.AsSpan(0, change.Index).Count('\n') + 1).ToList();
	if (changes.Count > 0)
		Problem($"BLU.lua changes {name} at line{(changes.Count > 1 ? "s" : "")} {string.Join(", ", changes)} in a way this check can't read, so the list it checked may not be the one the game uses");
	var source = declared.Success ? declared : whole.Match(engine);
	lists[name] = Regex.Matches(source.Groups[2].Value, @"'((?:[^'\\]|\\.)*)'|""((?:[^""\\]|\\.)*)""")
		.Select(match => (match.Groups[1].Success ? match.Groups[1].Value : match.Groups[2].Value).Replace("\\'", "'"))
		.ToHashSet();
}

// The sets the job file gives a spell by name, written out as sets.Midcast['Name'], sets.Midcast["Name"] or
// sets.Midcast.Name. A name a loop fills in isn't seen.
var ownSets = Regex.Matches(jobFile, @"\bsets\.Midcast(?:\.(\w+)|\[\s*(?:'((?:[^'\\]|\\.)*)'|""((?:[^""\\]|\\.)*)"")\s*\])\s*=(?!=)")
	.Select(match => match.Groups.Values.Skip(1).First(group => group.Success).Value.Replace("\\'", "'"))
	.ToHashSet();

var spells = Resources.BlueSpells().Distinct().ToList();
var placedBySet = new List<string>();
foreach (var spell in spells)
{
	var named = order.Where(name => lists[name].Contains(spell)).ToList();
	if (named.Count == 0 && ownSets.Contains(spell))
	{
		placedBySet.Add(spell);
	}
	else if (named.Count == 0)
	{
		Problem($"{spell}: in no list, so it casts in the idle set with only sets.Midcast over it, and no blue magic set");
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
Console.WriteLine($"lists from BLU.lua: {Named(fromJobFile)}; from the engine: {Named(order.Except(fromJobFile))}");
if (placedBySet.Count > 0)
	Console.WriteLine($"in no list, wearing a set of their own: {string.Join(", ", placedBySet)}");
Console.WriteLine($"problems: {problems}");
return problems > 0 ? 1 : 0;

void Problem(string message)
{
	problems++;
	Console.WriteLine("  " + message);
}

string Named(IEnumerable<string> names) => names.Any() ? string.Join(", ", names) : "none";
