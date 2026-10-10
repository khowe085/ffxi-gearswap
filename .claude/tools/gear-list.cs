// Checks data/<Character>/<Character>_gear_list.md against the character's sets files (lib/Dto.cs), one for each job:
// every job has a column, every piece a set names has a row, each job column names exactly the sets that name it, in
// the sets file's order, and the counts, sections, sort order and copies agree with the sets and the export. A set's
// own slots count, not what it takes from its base. It reads the tables under the list's "## <Slot> (<count>)"
// headings; a table anywhere else in the file isn't part of the list.
//
//   dotnet run --no-cache .claude/tools/gear-list.cs -- --in <sets.json> [--in <sets.json> ...] [--print | --json]
//                                                     [--export <path>]
//
// --print writes the table the sets call for, to paste over the list's sections, or to start the list from when the
// character has none yet. --json writes the problems as findings (lib/Dto.cs) and nothing else. Without --export it
// reads the newest export of the sets files' character. Exit code 1 on a mismatch.
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
var cli = new Arguments(args, ["--in", "--export"], ["--print", "--json"]);
if (cli.Flag("--print") && cli.Flag("--json"))
	Tool.Fail("--print writes a table and --json writes findings; give one of them.");
if (cli.Options("--in").Count == 0)
	Tool.Fail("Name a sets file for each job: --in <sets.json>");
// By job, in the order given.
var byJob = new Dictionary<string, SetsDto>();
var inputs = new Dictionary<string, string>();
foreach (var input in cli.Options("--in"))
{
	var read = Dto.LoadSets(input);
	if (byJob.ContainsKey(read.Job))
		Tool.Fail($"{inputs[read.Job]} and {input} are both for {read.Job}. Give one sets file for each job.");
	byJob[read.Job] = read;
	inputs[read.Job] = input;
}
var characters = byJob.Values.Select(read => read.Character).Distinct(StringComparer.OrdinalIgnoreCase).ToList();
if (characters.Count > 1)
	Tool.Fail($"The sets files are for {string.Join(" and ", characters)}. One gear list covers one character.");
var character = Characters.Named(characters[0]);
var exportPath = Export.ForSets(cli, character);
var owned = Export.Read(exportPath);
var resources = Resources.Load();
var listPath = Characters.GearList(character);
var hasList = File.Exists(listPath);
if (hasList is false && cli.Flag("--print") is false)
	Tool.Fail($"No gear list at {Tool.RepoRelative(listPath)}. --print gives the table to start one from.");
var lines = hasList ? File.ReadAllLines(listPath) : [];

string[] sectionOrder = ["Weapons", "Ammo", "Head", "Neck", "Earrings", "Body", "Hands", "Rings", "Back", "Waist", "Legs", "Feet"];
// The slots a set can fill with two copies of one piece, each with the other side.
var pairedSlots = new Dictionary<string, string> { ["main"] = "sub", ["left_ear"] = "right_ear", ["left_ring"] = "right_ring" };

var problems = 0;
var findings = new List<Finding>();

// The list as written. Its rows are in the gear sections only: a "## <Slot> (<count>)" heading opens one and the
// next "## " heading ends it, so a table under Reference, or under any other heading, is left alone.
var rows = new List<ListRow>();
var sectionCounts = new Dictionary<string, int>();
// The job columns of the list's first table, which every other table has to repeat.
string[]? listed = null;
// The job columns of the table being read, and null between tables.
string[]? header = null;
var unreadTable = false;
var section = "";
for (var i = 0; i < lines.Length; i++)
{
	if (lines[i].StartsWith("## "))
	{
		var heading = Regex.Match(lines[i], @"^## (.+) \((\d+)\)\s*$");
		section = heading.Success ? heading.Groups[1].Value : "";
		if (heading.Success)
			sectionCounts[section] = int.Parse(heading.Groups[2].Value);
	}
	if (section.Length == 0 || lines[i].StartsWith('|') is false)
	{
		// A table ends at the first line that isn't one of its rows.
		header = null;
		unreadTable = false;
		continue;
	}
	if (unreadTable || Markdown.IsDelimiterRow(lines[i]))
		continue;
	var cells = lines[i].Trim().Trim('|').Split('|').Select(cell => cell.Trim()).ToArray();
	if (cells[0] == "Item")
	{
		header = cells.Skip(2).Select(cell => cell.Replace(" sets", "")).ToArray();
		var named = header.Distinct().ToArray();
		if (named.Length < header.Length)
			Problem($"line {i + 1}: the header names a job more than once: {string.Join(", ", header)}");
		listed ??= named;
		if (named.SequenceEqual(listed) is false)
			Problem($"## {section} has the job columns {string.Join(", ", named)}, but the list's first table has {string.Join(", ", listed)}");
		continue;
	}
	if (header is null)
	{
		Problem($"line {i + 1}: this table's first row isn't an `| Item | Copy | ... |` header, so its rows aren't read");
		unreadTable = true;
		continue;
	}
	if (cells.Length != header.Length + 2)
	{
		Problem($"line {i + 1}: {cells.Length} cells, but the header has {header.Length + 2}");
		continue;
	}
	// A row keeps the columns of its own header, so under a header that leaves a job out it names no sets for it.
	var sets = header.Distinct().ToDictionary(job => job, job => new List<string>());
	for (var column = 0; column < header.Length; column++)
		sets[header[column]].AddRange(Regex.Matches(cells[column + 2], "`([^`]+)`").Select(match => match.Groups[1].Value));
	rows.Add(new ListRow(i + 1, section, cells[0], cells[1], sets));
}
var jobs = listed ?? [];
foreach (var job in jobs.Where(job => byJob.ContainsKey(job) is false))
	Problem($"The list has a {job} column, but no --in sets file is for {job}");
jobs = jobs.Where(byJob.ContainsKey).ToArray();
// A sets file for a job the list has no column for still counts: its pieces are worked out with the rest, and
// --print gives it a column.
var unlisted = byJob.Keys.Where(job => jobs.Contains(job) is false).ToList();
string[] columns = [.. jobs, .. unlisted];

// The list the sets call for. A set that wears one item with the same augments on both sides of a pair, as two rings
// worn together, wears two copies of it, and each copy gets its own row: the first side's sets and the second's.
var twins = new HashSet<string>();
foreach (var job in columns)
{
	foreach (var set in byJob[job].Sets)
	{
		var resolved = Dto.Resolve(byJob[job], set.Name);
		foreach (var pair in pairedSlots.Where(pair => resolved.ContainsKey(pair.Key) && resolved.ContainsKey(pair.Value)))
		{
			if (Identity(resolved[pair.Key]) == Identity(resolved[pair.Value]) && resolved[pair.Key].Item != Dto.Empty)
				twins.Add(Identity(resolved[pair.Key]));
		}
	}
}
var pieces = new Dictionary<string, Piece>();
// With no list yet there is no column to miss. The missing list is the one thing to report, below.
foreach (var job in hasList ? unlisted : [])
	Problem($"{inputs[job]} is for {job}, and the list has no {job} column. --print gives the table with a {job} column");
foreach (var job in columns)
{
	foreach (var set in byJob[job].Sets)
	{
		foreach (var slot in set.Slots.Where(slot => slot.Value.Item != Dto.Empty))
		{
			var identity = Identity(slot.Value);
			string? side = null;
			if (twins.Contains(identity))
			{
				side = pairedSlots.ContainsValue(slot.Key) ? "second" : "first";
				identity += "|" + side;
			}
			var useSection = SectionOf(slot.Key);
			if (pieces.TryGetValue(identity, out var piece) is false)
			{
				pieces[identity] = piece = new Piece(ItemName(slot.Value), AugmentText(slot.Value), side, useSection, columns);
			}
			else if (piece.Section != useSection)
			{
				Problem($"{job}: {piece.Item} is worn in {slot.Key} ({useSection}) by {set.Name}, but elsewhere under {piece.Section}");
			}
			if (piece.Sets[job].Contains(set.Name) is false)
				piece.Sets[job].Add(set.Name);
		}
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

if (hasList is false)
{
	Problem($"No gear list at {Tool.RepoRelative(listPath)} yet. The table above is the one to start it from");
	return Finish();
}

// Each piece finds its row, and no row serves two pieces. An item with several rows is told apart by the Copy
// column.
var taken = new HashSet<ListRow>();
foreach (var piece in pieces.Values)
{
	var candidates = rows.Where(row => row.Item == piece.Item).ToList();
	var free = candidates.Where(candidate => taken.Contains(candidate) is false).ToList();
	ListRow? row;
	if (candidates.Count <= 1)
	{
		row = free.FirstOrDefault();
	}
	else if (piece.TwinKey is not null)
	{
		row = free.FirstOrDefault(candidate => jobs.All(job => candidate.SetsFor(job).SequenceEqual(piece.Sets[job])));
	}
	else
	{
		row = free.FirstOrDefault(candidate => candidate.Copy == piece.AugmentText);
	}
	if (row is null)
	{
		string why;
		if (candidates.Count == 0)
		{
			why = "no row";
		}
		else if (free.Count == 0)
		{
			why = $"no row left, since another copy took {(candidates.Count == 1 ? "its one row" : $"each of its {candidates.Count} rows")}";
		}
		else
		{
			why = $"none of its {candidates.Count} rows matches";
		}
		Problem($"{piece.Item}{(piece.AugmentText.Length > 0 ? $" [{piece.AugmentText}]" : "")}: {why}. Expected: {string.Join(" | ", columns.Select(job => $"{job}: {Cell(piece.Sets[job])}"))}");
		continue;
	}
	taken.Add(row);
	foreach (var job in jobs.Where(job => row.SetsFor(job).SequenceEqual(piece.Sets[job]) is false))
		Problem($"line {row.Line}: {piece.Item}, {job} column\n    list:  {Cell(row.SetsFor(job))}\n    sets:  {Cell(piece.Sets[job])}");
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
		var why = owned.Count(copy => copy.Name == piece.Item) > 1 ? "the piece the sets wear names no augments" : "the export has one copy";
		Problem($"line {row.Line}: {piece.Item}: the Copy column says [{row.Copy}], but {why}, so the column stays empty");
	}
}
foreach (var row in rows.Where(row => taken.Contains(row) is false))
	Problem($"line {row.Line}: {row.Item}{(row.Copy.Length > 0 ? $" [{row.Copy}]" : "")} has a row, but no set wears it");

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

// The opening sentence names the export's date and repeats the totals. It ends where the first section starts.
var intro = string.Join(" ", lines.TakeWhile(line => line.StartsWith("## ") is false));
var exportDate = Regex.Match(intro, @"`//gs export` of (\d{4}-\d{2}-\d{2})");
if (exportDate.Success && exportDate.Groups[1].Value != Export.DateOf(exportPath))
	Problem($"The list says it was taken from the export of {exportDate.Groups[1].Value}, and this check read the one of {Export.DateOf(exportPath)}. Update the date once the list passes");
var total = Regex.Match(intro, @"\*\*(\d+) pieces\*\*");
if (total.Success && int.Parse(total.Groups[1].Value) != rows.Count)
	Problem($"The list says {total.Groups[1].Value} pieces and has {rows.Count} rows");
int Wearing(params string[] together) => rows.Count(row => together.All(job => row.SetsFor(job).Count > 0));
int Alone(string job) => rows.Count(row => jobs.All(other => (row.SetsFor(other).Count > 0) == (other == job)));
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
if (cli.Flag("--json") is false)
	Console.WriteLine($"rows {rows.Count}; {string.Join("; ", jobs.Select(job => $"{job} {Wearing(job)} ({Alone(job)} {job} only)").Concat(pairs))}");
return Finish();

void Problem(string message)
{
	problems++;
	if (cli.Flag("--json"))
	{
		findings.Add(new Finding("gear-list", "error", "", "", "", message));
	}
	else
	{
		Console.WriteLine("  " + message);
	}
}

int Finish()
{
	if (cli.Flag("--json"))
	{
		Console.WriteLine(Dto.ToJson(findings));
	}
	else
	{
		Console.WriteLine($"problems: {problems}");
	}
	return problems > 0 ? 1 : 0;
}

// The name //gs export prints, which is the one the list uses, whichever name the piece gives.
string ItemName(PieceDto piece) => resources.ExportName(piece.Item);

string AugmentText(PieceDto piece) => string.Join(", ", piece.Augments ?? []);

string Identity(PieceDto piece) => ItemName(piece) + "|" + AugmentText(piece);

string SectionOf(string slot) => ItemInfo.CanonicalSlot(slot) switch
{
	"main" or "sub" or "range" => "Weapons",
	"left_ear" or "right_ear" => "Earrings",
	"left_ring" or "right_ring" => "Rings",
	var other => char.ToUpperInvariant(other[0]) + other[1..],
};

string Cell(IEnumerable<string> sets) => string.Join(", ", sets.Select(set => $"`{set}`"));

string CopyColumn(Piece piece)
{
	var copies = owned.Count(copy => copy.Name == piece.Item);
	// The sets wear at least two of them, whatever the export holds. An export with fewer is reported against the row.
	if (piece.TwinKey is not null)
		return $"one of {(copies <= 2 ? "two" : copies.ToString())} identical copies";
	return copies > 1 ? piece.AugmentText : "";
}

// A row of the list as written.
sealed class ListRow
{
	public int Line { get; }

	public string Section { get; }

	public string Item { get; }

	public string Copy { get; }

	Dictionary<string, List<string>> sets;

	public ListRow(int line, string section, string item, string copy, Dictionary<string, List<string>> sets)
	{
		Line = line;
		Section = section;
		Item = item;
		Copy = copy;
		this.sets = sets;
	}

	// The sets the row names for a job: none when its table has no column for the job.
	public IReadOnlyList<string> SetsFor(string job) => sets.GetValueOrDefault(job) ?? [];
}

// A piece the sets wear, and the sets that wear it, job by job.
sealed class Piece
{
	public string Item { get; }

	public string AugmentText { get; }

	// "first" or "second", when the piece is one of two identical copies a set wears on both sides of a pair.
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
