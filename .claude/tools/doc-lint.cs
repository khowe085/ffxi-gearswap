// Checks the docs after an edit: the ones under docs/, which hold for any character, and a character's own beside
// the job files in data/<Character>/.
//
//   dotnet run --no-cache .claude/tools/doc-lint.cs [-- --char <name>] [--export <path>]
//
// Every doc: links and anchors resolve, tables keep one column count and have a delimiter row and a blank line
// above, no raw HTML-like tag or pair of tildes sits outside code (both change how the page renders).
// docs/: no doc names a character, since what holds for one character goes in that character's folder.
// docs/gear-notes.md: no item has two entries, no item is both in a "No notes" list and given an entry, and every
// "Simulated sets" bullet agrees with the sets in bg_job_guides.
// <Character>_gear_notes.md: every entry is for a piece in the export or for an entry of docs/gear-notes.md, once,
// and the table of pieces the simulated sets wear that the character lacks agrees with the sets.
// Exit code 1 when it finds a problem.
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
var cli = new Arguments(args, ["--char", "--export"], []);
var exportPath = Export.Resolve(cli);
var character = cli.Option("--char") ?? Export.CharacterOf(exportPath);
var export = Export.Read(exportPath);
var ownDir = Tool.InRepo("data", character);
// Each doc by its path from the repo root.
var docs = Directory.GetFiles(Tool.InRepo("docs"), "*.md")
	.Concat(Directory.Exists(ownDir) ? Directory.GetFiles(ownDir, "*.md") : [])
	.Select(Tool.RepoRelative)
	.Order(StringComparer.Ordinal)
	.ToDictionary(path => path, path => File.ReadAllLines(Tool.InRepo(path)));
var notesPath = "docs/gear-notes.md";
var ownNotesPath = Tool.RepoRelative(Characters.GearNotes(character));
var problems = 0;

// The anchors each doc's headings make, as GitHub builds them: lower case, punctuation dropped, spaces to hyphens,
// and -1, -2 on a repeated heading.
var anchors = new Dictionary<string, HashSet<string>>();
foreach (var doc in docs)
{
	var made = new HashSet<string>();
	var seen = new Dictionary<string, int>();
	foreach (var line in OutsideFences(doc.Value))
	{
		var heading = Regex.Match(line.Text, @"^(#{1,6})\s+(.*?)\s*#*\s*$");
		if (heading.Success is false)
			continue;
		var text = Regex.Replace(heading.Groups[2].Value, @"\[([^\]]*)\]\([^)]*\)", "$1").Replace("`", "").Replace("*", "");
		var slug = new string(text.Trim().ToLowerInvariant().Where(c => char.IsLetterOrDigit(c) || c is '-' or '_' or ' ').Select(c => c == ' ' ? '-' : c).ToArray());
		if (seen.TryGetValue(slug, out var count))
		{
			seen[slug] = count + 1;
			slug = $"{slug}-{count + 1}";
		}
		else
		{
			seen[slug] = 0;
		}
		made.Add(slug);
	}
	anchors[doc.Key] = made;
}

foreach (var doc in docs)
{
	int? columns = null;
	var tableStart = 0;
	var lines = doc.Value;
	var folder = Path.GetDirectoryName(Tool.InRepo(doc.Key))!;
	var inFence = false;
	for (var i = 0; i < lines.Length; i++)
	{
		var line = lines[i];
		if (line.TrimStart().StartsWith("```"))
		{
			inFence = inFence is false;
			columns = null;
			continue;
		}
		if (inFence)
			continue;
		var prose = Regex.Replace(line, "`[^`]*`", "``");
		foreach (Match link in Regex.Matches(prose, @"\]\(([^)\s]*(?:\([^)\s]*\)[^)\s]*)*)\)"))
		{
			var target = link.Groups[1].Value;
			if (target.StartsWith("http"))
				continue;
			var hash = target.IndexOf('#');
			// A link is read from the folder of the doc it is in.
			var file = hash == 0 ? doc.Key : Tool.RepoRelative(Path.GetFullPath(Path.Combine(folder, Uri.UnescapeDataString(hash > 0 ? target[..hash] : target))));
			var anchor = hash >= 0 ? target[(hash + 1)..] : null;
			if (File.Exists(Tool.InRepo(file)) is false && Directory.Exists(Tool.InRepo(file)) is false)
			{
				Problem($"{doc.Key}:{i + 1}: link to a missing file, {target}");
			}
			else if (anchor is not null && anchors.ContainsKey(file) is false)
			{
				Problem($"{doc.Key}:{i + 1}: anchor into a file this tool doesn't read, {target}");
			}
			else if (anchor is not null && anchors[file].Contains(anchor) is false)
			{
				Problem($"{doc.Key}:{i + 1}: broken anchor, {target}");
			}
		}
		foreach (Match tag in Regex.Matches(prose, @"<[A-Za-z][A-Za-z0-9-]*(\s[^<>]*)?>"))
			Problem($"{doc.Key}:{i + 1}: raw tag {tag.Value}; put it in backticks");
		var withoutLinks = Regex.Replace(prose.Replace("\\~", ""), @"\]\([^)]*\)", "]()");
		if (withoutLinks.Count(c => c == '~') >= 2)
			Problem($"{doc.Key}:{i + 1}: two tildes on one line strike the text between them out; escape them");

		if (line.StartsWith('|') is false)
		{
			columns = null;
			continue;
		}
		var cells = prose.Replace("\\|", "").Trim().Trim('|').Split('|').Length;
		if (columns is null)
		{
			columns = cells;
			tableStart = i;
			if (i + 1 >= lines.Length || Regex.IsMatch(lines[i + 1], @"^\|[\s:|-]+\|?\s*$") is false)
				Problem($"{doc.Key}:{i + 1}: table without a delimiter row");
			if (i > 0 && lines[i - 1].Trim().Length > 0)
				Problem($"{doc.Key}:{i + 1}: table with no blank line above it");
		}
		else if (cells != columns)
		{
			Problem($"{doc.Key}:{i + 1}: {cells} cells, but the table that starts at line {tableStart + 1} has {columns}");
		}
	}
}

// docs/ holds what is true for any character, so a character's name there marks something misplaced: a rank, a
// rule, a note on one copy.
var names = Characters.All();
foreach (var doc in docs.Where(doc => doc.Key.StartsWith("docs/")))
{
	for (var i = 0; i < doc.Value.Length; i++)
	{
		foreach (var name in names.Where(name => Regex.IsMatch(doc.Value[i], $@"\b{Regex.Escape(name)}\b")))
			Problem($"{doc.Key}:{i + 1}: names {name}. What holds for one character goes in data/{name}/");
	}
}

var wearable = export.Where(line => line.SlotKey != "item").ToList();
var haveSets = Directory.Exists(Tool.InCache("bg_job_guides"));
if (haveSets is false)
	Console.WriteLine("Simulated sets not checked: .claude/cache/bg_job_guides is missing. Run fetch-sources.cs.");

// The generic notes' entries: items, and a few headings that aren't items, such as the armor sets.
var noted = new HashSet<string>();
if (docs.TryGetValue(notesPath, out var notes))
{
	var entries = Entries(notesPath, notes);
	noted.UnionWith(entries.Keys);
	const string noNotes = "No notes beyond the help text: ";
	var covered = entries.Keys.ToHashSet();
	for (var i = 0; i < notes.Length; i++)
	{
		if (notes[i].StartsWith(noNotes) is false)
			continue;
		var listed = notes[i][noNotes.Length..].TrimEnd('.').Split(", ");
		foreach (var item in listed.Where(entries.ContainsKey))
			Problem($"{notesPath}:{i + 1}: {item} is in a \"No notes\" list and has an entry");
		covered.UnionWith(listed);
	}

	// Not a mistake in the doc, but worth knowing before a set takes one: the owned pieces the notes don't cover.
	var bare = wearable.Where(line => line.Slip == 0 && covered.Contains(line.Name) is false).Select(line => line.Name).Distinct().Order(StringComparer.Ordinal).ToList();
	if (bare.Count > 0)
		Console.WriteLine($"No notes yet for {bare.Count} pieces in the bags: {string.Join(", ", bare)}");
	var onSlips = wearable.Where(line => line.Slip > 0 && covered.Contains(line.Name) is false).Select(line => line.Name).Distinct().Count();
	if (onSlips > 0)
		Console.WriteLine($"No notes for {onSlips} pieces on storage slips. Read a piece's bg-wiki page before a set takes one.");

	if (haveSets)
		CheckSimulatedSetBullets(entries);
}

if (docs.TryGetValue(ownNotesPath, out var ownNotes))
{
	var owned = export.Select(line => line.Name).ToHashSet();
	var headings = ownNotes.Select((text, index) => new NumberedLine(index + 1, text)).Where(line => line.Text.StartsWith("### ")).ToList();
	foreach (var heading in headings.Where(heading => owned.Contains(heading.Text[4..].Trim()) is false && noted.Contains(heading.Text[4..].Trim()) is false))
		Problem($"{ownNotesPath}:{heading.Number}: {heading.Text[4..].Trim()} has an entry, but it is neither in the export nor an entry of {notesPath}");
	// Reading the entries reports an item that has two.
	Entries(ownNotesPath, ownNotes);
	if (haveSets)
		CheckPiecesLacking(ownNotes);
}

Console.WriteLine($"{docs.Count} docs, {docs.Values.Sum(lines => lines.Length)} lines; problems: {problems}");
return problems > 0 ? 1 : 0;

void Problem(string message)
{
	problems++;
	Console.WriteLine("  " + message);
}

IEnumerable<NumberedLine> OutsideFences(string[] lines)
{
	var inFence = false;
	for (var i = 0; i < lines.Length; i++)
	{
		if (lines[i].TrimStart().StartsWith("```"))
		{
			inFence = inFence is false;
		}
		else if (inFence is false)
		{
			yield return new NumberedLine(i + 1, lines[i]);
		}
	}
}

// The entries of a gear notes doc. An entry is a "### <item>" heading and the lines under it, up to the next
// heading. A second entry for an item is a problem.
Dictionary<string, List<NumberedLine>> Entries(string path, string[] lines)
{
	var entries = new Dictionary<string, List<NumberedLine>>();
	List<NumberedLine>? current = null;
	for (var i = 0; i < lines.Length; i++)
	{
		if (lines[i].StartsWith("### "))
		{
			var item = lines[i][4..].Trim();
			if (entries.ContainsKey(item))
				Problem($"{path}:{i + 1}: a second entry for {item}");
			entries[item] = current = [];
		}
		else if (lines[i].StartsWith("## "))
		{
			current = null;
		}
		else
		{
			current?.Add(new NumberedLine(i + 1, lines[i]));
		}
	}
	return entries;
}

// docs/gear-notes.md says, in a piece's entry, which of bg-wiki's simulated RDM and BLU sets wear it. Each such
// bullet is checked against the sets, and a piece in the character's bags that the sets wear has to have one.
void CheckSimulatedSetBullets(Dictionary<string, List<NumberedLine>> entries)
{
	var resources = Resources.Load();
	// The entries cover the gear in the bags. Gear on a storage slip is owned too, but has no entries yet.
	var inBags = export.Where(line => line.Slip == 0).Select(line => line.Name).ToHashSet();
	var owned = export.Select(line => line.Name).ToHashSet();
	var usage = SimulatedSets.Usage();
	bool IsCape(string piece) => resources.Pick(piece)?.Group == "back";

	var withBullet = new HashSet<string>();
	foreach (var entry in entries)
	{
		foreach (var bullet in entry.Value.Where(line => line.Text.StartsWith("- Simulated sets")))
		{
			withBullet.Add(entry.Key);
			var parts = Regex.Match(bullet.Text, @"^- Simulated sets \(\[bg-wiki All Jobs Gear Sets\]\([^)]*\), Odyssey at rank 30, Nyame Path B rank 25\): (.*)$");
			if (parts.Success is false)
			{
				Problem($"{notesPath}:{bullet.Number}: {entry.Key}: the Simulated sets bullet doesn't open the way the others do");
				continue;
			}
			// The pages name a cape by its stat and main augment, not by the item, so a cape's bullet says so
			// in place of a list of sets.
			if (IsCape(entry.Key))
				continue;
			var said = Regex.Match(parts.Groups[1].Value, @"^((?:RDM|BLU): .*?)\.(?: |$)");
			if (usage.TryGetValue(entry.Key, out var byJob) is false)
			{
				Problem($"{notesPath}:{bullet.Number}: {entry.Key} has a Simulated sets bullet, but no RDM or BLU set wears it");
			}
			else if (said.Success is false || said.Groups[1].Value != SimulatedSets.Describe(byJob))
			{
				Problem($"{notesPath}:{bullet.Number}: {entry.Key}: the bullet's sets differ from the pages\n    pages: {SimulatedSets.Describe(byJob)}");
			}
		}
	}
	foreach (var piece in usage.Keys.Where(piece => inBags.Contains(piece) && withBullet.Contains(piece) is false))
		Problem($"{notesPath}: {piece} is in a bag and in the simulated sets, but its entry has no Simulated sets bullet. Sets: {SimulatedSets.Describe(usage[piece])}");
	foreach (var piece in withBullet.Where(piece => owned.Contains(piece) is false))
		Problem($"{notesPath}: {piece} has a Simulated sets bullet but isn't in the export");
}

// <Character>_gear_notes.md lists the pieces the simulated sets wear that the character lacks, in one table for
// each job. The tables are checked against the sets and the export.
void CheckPiecesLacking(string[] ownNotes)
{
	var start = Array.FindIndex(ownNotes, line => line.StartsWith("## Pieces the simulated sets use"));
	if (start < 0)
		return;
	var owned = export.Select(line => line.Name).ToHashSet();
	var listed = SimulatedSets.Jobs.ToDictionary(job => job, job => new Dictionary<string, NumberedLine>());
	string? tableJob = null;
	for (var i = start + 1; i < ownNotes.Length && ownNotes[i].StartsWith("## ") is false; i++)
	{
		var marker = ownNotes[i].Trim().Trim('*');
		var row = Regex.Match(ownNotes[i], @"^\| (.+?) \| (.+?) \|$");
		if (SimulatedSets.Jobs.Contains(marker) && ownNotes[i].Trim().StartsWith("**"))
		{
			tableJob = marker;
		}
		else if (row.Success && tableJob is not null && row.Groups[1].Value is not ("Piece" or "---"))
		{
			listed[tableJob][row.Groups[1].Value] = new NumberedLine(i + 1, row.Groups[2].Value);
		}
	}
	foreach (var job in SimulatedSets.Jobs)
	{
		// A piece is lacking when it isn't owned, or when the page asks for a path or augment, which the export's
		// name alone can't confirm. An owned cape is left to the reader: its copies are told apart by augments.
		var lacking = new Dictionary<string, SortedSet<string>>();
		var ownedCapes = new HashSet<string>();
		foreach (var set in Sims.Load(job))
		{
			foreach (var slot in set.Items.Keys)
			{
				var piece = Sims.ItemName(set.Items[slot]);
				var hasAugment = set.Augments.TryGetValue(slot, out var augment);
				if (owned.Contains(piece) && slot != "Back" && hasAugment is false)
					continue;
				var name = set.Items[slot] + (hasAugment ? $" [{augment}]" : "");
				if (owned.Contains(piece) && slot == "Back")
					ownedCapes.Add(name);
				if (lacking.TryGetValue(name, out var sets) is false)
					lacking[name] = sets = new SortedSet<string>(StringComparer.Ordinal);
				sets.Add(set.Name);
			}
		}
		foreach (var piece in lacking)
		{
			var expected = string.Join(", ", piece.Value);
			if (listed[job].TryGetValue(piece.Key, out var row) is false)
			{
				if (ownedCapes.Contains(piece.Key) is false)
					Problem($"{ownNotesPath}: the {job} table of pieces the sets use lacks {piece.Key} ({expected})");
			}
			else if (row.Text != expected)
			{
				Problem($"{ownNotesPath}:{row.Number}: {piece.Key}, {job} sets\n    doc:   {row.Text}\n    pages: {expected}");
			}
		}
		foreach (var row in listed[job].Where(row => lacking.ContainsKey(row.Key) is false))
			Problem($"{ownNotesPath}:{row.Value.Number}: {row.Key} is in the {job} table of pieces the character lacks, but it is owned or no {job} set wears it");
	}
}

// bg-wiki's simulated sets for the two jobs the notes follow.
static class SimulatedSets
{
	public static IReadOnlyList<string> Jobs { get; }

	static SimulatedSets()
	{
		Jobs = ["RDM", "BLU"];
	}

	// Piece -> job -> set name -> buff levels, each in page order.
	public static Dictionary<string, Dictionary<string, Dictionary<string, List<string>>>> Usage()
	{
		var usage = new Dictionary<string, Dictionary<string, Dictionary<string, List<string>>>>();
		foreach (var job in Jobs)
		{
			foreach (var set in Sims.Load(job))
			{
				foreach (var slot in set.Items.Keys)
				{
					var piece = Sims.ItemName(set.Items[slot]);
					if (usage.TryGetValue(piece, out var byJob) is false)
						usage[piece] = byJob = [];
					if (byJob.TryGetValue(job, out var bySet) is false)
						byJob[job] = bySet = [];
					if (bySet.TryGetValue(set.Name, out var levels) is false)
						bySet[set.Name] = levels = [];
					if (levels.Contains(set.CaptionTop) is false)
						levels.Add(set.CaptionTop);
				}
			}
		}
		return usage;
	}

	// A piece's sets as its bullet writes them: "RDM: Savage Blade (Mid buff, High buff); BLU: Expiacion (Mid buff)".
	public static string Describe(Dictionary<string, Dictionary<string, List<string>>> byJob) =>
		string.Join("; ", byJob.Select(job => job.Key + ": " + string.Join("; ", job.Value.Select(set => $"{set.Key} ({string.Join(", ", set.Value)})"))));
}

// A line of a doc with its 1-based number.
sealed class NumberedLine
{
	public int Number { get; }

	public string Text { get; }

	public NumberedLine(int number, string text)
	{
		Number = number;
		Text = text;
	}
}
