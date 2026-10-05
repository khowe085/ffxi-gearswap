// Checks data/<Character>/<Character>_gear_list.md against the character's job files: every job file has a column,
// every piece a set or hook wears has a row, each job column names exactly the sets that wear it, in file order,
// and the counts, sections, sort order and copies agree with the files and the export.
//
//   dotnet run --no-cache .claude/tools/gear-list.cs [-- --print] [--char <name>] [--export <path>]
//
// --print writes the table the job files call for, to paste over the list's sections. Exit code 1 on a mismatch.
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
var cli = new Arguments(args, ["--char", "--export"], ["--print"]);
var exportPath = Export.Resolve(cli);
var character = cli.Option("--char") ?? Export.CharacterOf(exportPath);
var owned = Export.Read(exportPath);
var resources = Resources.Load();
var files = GearFiles.Load(character);
var listPath = Characters.GearList(character);
if (File.Exists(listPath) is false)
	Tool.Fail($"No gear list at {Tool.RepoRelative(listPath)}.");
var lines = File.ReadAllLines(listPath);

string[] sectionOrder = ["Weapons", "Ammo", "Head", "Neck", "Earrings", "Body", "Hands", "Rings", "Back", "Waist", "Legs", "Feet"];
// The list names a set built in a loop once, by what the loop covers. ws is the loop over the magical weapon skills.
var loopSetWording = new Dictionary<string, string> { ["[ws]"] = "[each magical WS]" };

// The list as written.
var rows = new List<ListRow>();
var sectionCounts = new Dictionary<string, int>();
string[] jobs = [];
var section = "";
for (var i = 0; i < lines.Length; i++)
{
	var heading = Regex.Match(lines[i], @"^## (.+) \((\d+)\)\s*$");
	if (heading.Success)
	{
		section = heading.Groups[1].Value;
		sectionCounts[section] = int.Parse(heading.Groups[2].Value);
		continue;
	}
	if (lines[i].StartsWith("| ") is false || lines[i].StartsWith("|---"))
		continue;
	var cells = lines[i].Trim().Trim('|').Split('|').Select(cell => cell.Trim()).ToArray();
	if (cells[0] == "Item")
	{
		jobs = cells.Skip(2).Select(cell => cell.Replace(" sets", "")).ToArray();
		continue;
	}
	if (cells.Length != jobs.Length + 2)
		Tool.Fail($"{Tool.RepoRelative(listPath)}:{i + 1}: {cells.Length} cells, but the header has {jobs.Length + 2}.");
	var sets = jobs.Select((job, column) => KeyValuePair.Create(job, Regex.Matches(cells[column + 2], "`([^`]+)`").Select(match => match.Groups[1].Value).ToList()))
		.ToDictionary(pair => pair.Key, pair => pair.Value);
	rows.Add(new ListRow(i + 1, section, cells[0], cells[1], sets));
}
foreach (var job in jobs.Where(job => files.Jobs.ContainsKey(job) is false))
	Tool.Fail($"The list has a {job} column, but there is no data/{character}/{job}.lua.");
// A job file the list has no column for still counts: its pieces are worked out with the rest, and --print gives
// it a column.
var unlisted = files.Jobs.Keys.Where(job => jobs.Contains(job) is false).ToList();
string[] columns = [.. jobs, .. unlisted];

// The list the job files call for. Two keys for one item with the same augments, in one file, are two copies of
// it, such as two rings worn together, and each gets its own row.
var twins = new HashSet<string>();
foreach (var job in columns)
{
	var defs = files.DefsFor(job);
	var perItem = files.Jobs[job].Uses.Where(use => defs.ContainsKey(use.Key))
		.GroupBy(use => ItemName(defs[use.Key]) + "|" + defs[use.Key].AugmentText)
		.Where(group => group.Select(use => use.Key).Distinct().Count() > 1);
	foreach (var group in perItem)
		twins.Add(group.Key);
}
var pieces = new Dictionary<string, Piece>();
var problems = 0;
foreach (var job in unlisted)
	Problem($"data/{character}/{job}.lua has no column in the list. --print gives the table with a {job} column");
foreach (var job in columns)
{
	var defs = files.DefsFor(job);
	foreach (var use in files.Jobs[job].Uses)
	{
		if (defs.TryGetValue(use.Key, out var def) is false)
		{
			Problem($"{job}: gear.{use.Key} (line {use.Line}) has no definition; check-export.cs reports these");
			continue;
		}
		var item = ItemName(def);
		var identity = item + "|" + def.AugmentText;
		var twin = twins.Contains(identity);
		if (twin)
			identity += "|" + use.Key;
		var useSection = SectionOf(use.Slot);
		if (pieces.TryGetValue(identity, out var piece) is false)
		{
			pieces[identity] = piece = new Piece(item, def.AugmentText, twin ? use.Key : null, useSection, columns);
		}
		else if (piece.Section != useSection)
		{
			Problem($"{job}: gear.{use.Key} is worn in {use.Slot} ({useSection}) at line {use.Line}, but elsewhere under {piece.Section}");
		}
		var label = use.SetName;
		foreach (var wording in loopSetWording)
			label = label.Replace(wording.Key, wording.Value);
		if (piece.Sets[job].Contains(label) is false)
			piece.Sets[job].Add(label);
	}
}

if (cli.Flag("--print"))
{
	foreach (var name in sectionOrder)
	{
		// Copies of one item come in the order the export lists them, as the list has them.
		var inSection = pieces.Values.Where(piece => piece.Section == name)
			.OrderBy(piece => piece.Item, StringComparer.Ordinal)
			.ThenBy(piece => owned.FindIndex(copy => copy.Name == piece.Item && copy.AugmentText == piece.AugmentText))
			.ThenBy(piece => piece.TwinKey, StringComparer.Ordinal).ToList();
		// A slot no set fills has no section.
		if (inSection.Count == 0)
			continue;
		Console.WriteLine($"## {name} ({inSection.Count})");
		Console.WriteLine();
		Console.WriteLine($"| Item | Copy | {string.Join(" | ", columns.Select(job => job + " sets"))} |");
		Console.WriteLine($"|---|---|{string.Concat(columns.Select(job => "---|"))}");
		foreach (var piece in inSection)
			Console.WriteLine($"| {piece.Item} | {CopyColumn(piece)} | {string.Join(" | ", columns.Select(job => Cell(piece.Sets[job])))} |");
		Console.WriteLine();
	}
}

// Each piece finds its row. An item with several rows is told apart by the Copy column.
var taken = new HashSet<ListRow>();
foreach (var piece in pieces.Values)
{
	var candidates = rows.Where(row => row.Item == piece.Item).ToList();
	ListRow? row;
	if (candidates.Count <= 1)
	{
		row = candidates.FirstOrDefault();
	}
	else if (piece.TwinKey is not null)
	{
		row = candidates.FirstOrDefault(candidate => taken.Contains(candidate) is false && jobs.All(job => candidate.Sets[job].SequenceEqual(piece.Sets[job])));
	}
	else
	{
		row = candidates.FirstOrDefault(candidate => candidate.Copy == piece.AugmentText);
	}
	if (row is null)
	{
		var why = candidates.Count == 0 ? "no row" : $"none of its {candidates.Count} rows matches";
		Problem($"{piece.Item}{(piece.AugmentText.Length > 0 ? $" [{piece.AugmentText}]" : "")}: {why}. Expected: {string.Join(" | ", columns.Select(job => $"{job}: {Cell(piece.Sets[job])}"))}");
		continue;
	}
	taken.Add(row);
	foreach (var job in jobs.Where(job => row.Sets[job].SequenceEqual(piece.Sets[job]) is false))
		Problem($"line {row.Line}: {piece.Item}, {job} column\n    list:  {Cell(row.Sets[job])}\n    files: {Cell(piece.Sets[job])}");
	if (row.Section != piece.Section)
		Problem($"line {row.Line}: {piece.Item} is under {row.Section}, but the sets wear it under {piece.Section}");
	// An item with one row still has to name the copy the sets wear, or the list sends the player to the wrong one.
	var expectedCopy = CopyColumn(piece);
	if (row.Copy != expectedCopy && expectedCopy.Length > 0)
	{
		Problem($"line {row.Line}: {piece.Item}: the Copy column says [{row.Copy}], but the sets wear [{expectedCopy}]");
	}
	else if (row.Copy != expectedCopy)
	{
		Problem($"line {row.Line}: {piece.Item}: the Copy column says [{row.Copy}], but the export has one copy, so the column stays empty");
	}
}
foreach (var row in rows.Where(row => taken.Contains(row) is false))
	Problem($"line {row.Line}: {row.Item}{(row.Copy.Length > 0 ? $" [{row.Copy}]" : "")} has a row, but no set or hook wears it");

foreach (var name in sectionCounts.Keys)
{
	var inSection = rows.Where(row => row.Section == name).ToList();
	if (inSection.Count != sectionCounts[name])
		Problem($"## {name} ({sectionCounts[name]}) has {inSection.Count} rows");
	if (inSection.Select(row => row.Item).SequenceEqual(inSection.Select(row => row.Item).Order(StringComparer.Ordinal)) is false)
		Problem($"## {name} isn't sorted by item name");
}

// The Copy column has to name a copy the export really holds.
foreach (var row in rows)
{
	var copies = owned.Where(copy => copy.Name == row.Item).ToList();
	if (copies.Count == 0)
	{
		Problem($"line {row.Line}: {row.Item} isn't in the export");
	}
	else if (row.Copy.Length > 0 && row.Copy.StartsWith("one of") is false && copies.Any(copy => copy.AugmentText == row.Copy) is false)
	{
		Problem($"line {row.Line}: {row.Item} [{row.Copy}] matches no copy. The export has: {string.Join(" | ", copies.Select(copy => $"[{copy.AugmentText}]"))}");
	}
	else if (row.Copy.StartsWith("one of") && copies.Count < 2)
	{
		Problem($"line {row.Line}: {row.Item} is listed as one of several copies, but the export has {copies.Count}");
	}
}

// The opening sentence names the export's date and repeats the totals.
var intro = string.Join(" ", lines);
var exportDate = Regex.Match(intro, @"`//gs export` of (\d{4}-\d{2}-\d{2})");
if (exportDate.Success && exportDate.Groups[1].Value != Export.DateOf(exportPath))
	Problem($"The list says it was taken from the export of {exportDate.Groups[1].Value}, and this check read the one of {Export.DateOf(exportPath)}. Update the date once the list passes");
var total = Regex.Match(intro, @"\*\*(\d+) pieces\*\*");
if (total.Success && int.Parse(total.Groups[1].Value) != rows.Count)
	Problem($"The list says {total.Groups[1].Value} pieces and has {rows.Count} rows");
int Wearing(params string[] together) => rows.Count(row => together.All(job => row.Sets[job].Count > 0));
int Alone(string job) => rows.Count(row => jobs.All(other => (row.Sets[other].Count > 0) == (other == job)));
foreach (var job in jobs)
{
	var claimed = Regex.Match(intro, $@"(\d+) for {job}\b");
	if (claimed.Success && int.Parse(claimed.Groups[1].Value) != Wearing(job))
		Problem($"The list says {claimed.Groups[1].Value} for {job} and has {Wearing(job)} rows with {job} sets");
	var alone = Regex.Match(intro, $@"(\d+) of them {job} only");
	if (alone.Success && int.Parse(alone.Groups[1].Value) != Alone(job))
		Problem($"The list says {alone.Groups[1].Value} of them {job} only, and {Alone(job)} rows have {job} sets alone");
}
// "N for A, N for B, N worn by both" counts the rows the two jobs just named share.
var shared = Regex.Match(intro, @"\d+ for (\w{3}), \d+ for (\w{3}), (\d+) worn by both");
if (shared.Success && jobs.Contains(shared.Groups[1].Value) && jobs.Contains(shared.Groups[2].Value) && int.Parse(shared.Groups[3].Value) != Wearing(shared.Groups[1].Value, shared.Groups[2].Value))
	Problem($"The list says {shared.Groups[3].Value} worn by both, and {Wearing(shared.Groups[1].Value, shared.Groups[2].Value)} rows have both {shared.Groups[1].Value} and {shared.Groups[2].Value} sets");

// Every number the opening sentence could quote.
var pairs = jobs.SelectMany((first, index) => jobs.Skip(index + 1).Select(second => $"{first} and {second} {Wearing(first, second)}"));
Console.WriteLine($"rows {rows.Count}; {string.Join("; ", jobs.Select(job => $"{job} {Wearing(job)} ({Alone(job)} {job} only)").Concat(pairs))}");
Console.WriteLine($"problems: {problems}");
return problems > 0 ? 1 : 0;

void Problem(string message)
{
	problems++;
	Console.WriteLine("  " + message);
}

// The name //gs export prints, which is the one the list uses, whichever name the entry gives.
string ItemName(GearDef def) => resources.Pick(def.Name)?.Name ?? def.Name;

string SectionOf(string slot) => ItemInfo.CanonicalSlot(slot) switch
{
	"main" or "sub" or "range" => "Weapons",
	"left_ear" or "right_ear" => "Earrings",
	"left_ring" or "right_ring" => "Rings",
	var other => char.ToUpperInvariant(other[0]) + other[1..],
};

string Cell(List<string> sets) => string.Join(", ", sets.Select(set => $"`{set}`"));

string CopyColumn(Piece piece)
{
	var copies = owned.Count(copy => copy.Name == piece.Item);
	if (piece.TwinKey is not null)
		return $"one of {(copies == 2 ? "two" : copies.ToString())} identical copies";
	return copies > 1 ? piece.AugmentText : "";
}

// A row of the list as written.
sealed class ListRow
{
	public int Line { get; }

	public string Section { get; }

	public string Item { get; }

	public string Copy { get; }

	public Dictionary<string, List<string>> Sets { get; }

	public ListRow(int line, string section, string item, string copy, Dictionary<string, List<string>> sets)
	{
		Line = line;
		Section = section;
		Item = item;
		Copy = copy;
		Sets = sets;
	}
}

// A piece the job files wear, and the sets that wear it, job by job.
sealed class Piece
{
	public string Item { get; }

	public string AugmentText { get; }

	// The key, when the piece is one of several identical copies that the files tell apart by key alone.
	public string? TwinKey { get; }

	public string Section { get; }

	public Dictionary<string, List<string>> Sets { get; }

	public Piece(string item, string augmentText, string? twinKey, string section, string[] columns)
	{
		Item = item;
		AugmentText = augmentText;
		TwinKey = twinKey;
		Section = section;
		Sets = columns.ToDictionary(job => job, job => new List<string>());
	}
}
