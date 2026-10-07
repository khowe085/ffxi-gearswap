using System;
using System.Text;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Text.RegularExpressions;

namespace GearTools;

// Renders the two rank documents. docs/rank-augments.md holds bg-wiki's rank tables for every path item in the
// exports and names no character. data/<Character>/<Character>_rank_augments.md gives one character's path and
// rank for each of those items, with the augments that rank gives.
static class RankDoc
{
	static string[] slotOrder;
	static string[] families;
	static string[] familyHeadings;
	// From a character's folder to the tables.
	static string tablesLink;

	static RankDoc()
	{
		slotOrder = ["main", "sub", "range", "ammo", "head", "neck", "ear", "body", "hands", "ring", "back", "waist", "legs", "feet"];
		families = ["Nyame", "Bunzi", "Gleti"];
		familyHeadings = ["## Nyame", "## Bunzi's", "## Gleti's", "## Other path items"];
		tablesLink = "../../docs/rank-augments.md";
	}

	// docs/rank-augments.md, line by line: the tables, with no character in them.
	public static List<string> RenderTables(RankTables tables, Resources resources, OboroAugments oboro)
	{
		var items = Ordered(tables, resources);
		List<string> md =
		[
			"# Rank augments",
			"",
			$"Augment values at every rank for each rank-augmented item in the exports under `data/export/`. The Odyssey pieces (Nyame, Bunzi's, Gleti's and the other Sheol rewards) rank up to 30. Most other path items here rank up to 15 or 30. Every value comes from the item's own bg-wiki page, from the per-rank table under its augments (the `Augment Rank Table` template), read on {tables.Fetched} and copied by script, not by hand. Items Oboro ranks up (JSE necks, Ultimate Weapons, Unity weapons) come last, at maximum rank only, because bg-wiki has no per-rank table for them. A character's own path and rank for each item are in that character's folder, in `data/<Character>/<Character>_rank_augments.md`.",
			"",
			"- `//gs export` prints the path (`'Path: B'`) but never the rank. A copy that exports with no augments at all hasn't been ranked: it has only the base stats in its help text.",
			"- Ranks are cumulative: the row for a rank is the item's whole augment at that rank, not an increase over the rank before it. A blank cell means that augment line hasn't unlocked yet.",
			"- A path is fixed once chosen. Changing it means discarding the item and starting over (bg-wiki, Nyame Mail).",
			"",
			"## Items",
			"",
			"| Item | Slot | Paths | Max rank |",
			"|---|---|---|---|",
		];
		foreach (var item in items)
			md.Add($"| [{item.Name}](#{Anchor(item.Name)}) | {SlotOf(resources, item.Name)} | {string.Join(", ", item.Paths.Select(path => path.Path))} | {item.RankMax} |");
		md.Add("");

		foreach (var family in items.GroupBy(item => FamilyOf(item.Name)))
		{
			md.Add(familyHeadings[family.Key]);
			md.Add("");
			foreach (var item in family)
			{
				md.Add($"### {item.Name}");
				md.Add("");
				md.Add($"{FullName(resources, item.Name)}, {SlotOf(resources, item.Name)}. Ranks 1 to {item.RankMax}. Source: [bg-wiki](https://www.bg-wiki.com/ffxi/{Uri.EscapeDataString(item.Name.Replace(' ', '_'))}).");
				md.Add("");
				foreach (var path in item.Paths.OrderBy(path => path.Path, StringComparer.Ordinal))
				{
					var width = path.Ranks.Max(row => row.Augments.ToList().FindLastIndex(augment => augment.Length > 0) + 1);
					if (item.Paths.Count > 1)
					{
						md.Add($"Path {path.Path}:");
						md.Add("");
					}
					md.Add("| Rank | " + string.Join(" | ", Enumerable.Range(1, width).Select(number => $"Augment {number}")) + " |");
					md.Add("|---|" + string.Concat(Enumerable.Repeat("---|", width)));
					foreach (var row in path.Ranks)
						md.Add($"| {row.Rank} | " + string.Join(" | ", row.Augments.Take(width).Select(Cell)) + " |");
					md.Add("");
				}
			}
		}

		md.AddRange(oboro.Intro);
		md.Add("| Item | Slot | Max rank | Augments at max rank |");
		md.Add("|---|---|---|---|");
		foreach (var item in oboro.Items)
			md.Add($"| {item.Name} | {item.Slot} | {item.MaxRank} | {item.AtMaxRank} |");
		return md;
	}

	// <Character>_rank_augments.md, line by line. It throws when the Ranks table names an item, or the export prints
	// a path for one, that has no rank table and isn't one Oboro ranks up: either would be left out without a word.
	public static List<string> RenderCharacter(RankTables tables, Resources resources, OboroAugments oboro, CharacterRanks character)
	{
		var named = tables.Items.Select(item => item.Name).Concat(oboro.Items.Select(item => item.Name)).ToList();
		var unknown = character.Ranks.Keys.Where(name => named.Contains(name) is false).ToList();
		if (unknown.Count > 0)
			throw new InvalidOperationException($"{character.Character}'s Ranks table names {string.Join(", ", unknown.Select(name => $"\"{name}\""))}, and no rank table goes by that name. A rank is recorded under the name the export prints: {string.Join(", ", named)}.");

		var untabled = character.Owned.Where(copy => copy.Augments.Any(augment => augment.StartsWith("Path: ")) && named.Contains(copy.Name) is false)
			.Select(copy => copy.Name).Distinct().ToList();
		if (untabled.Count > 0)
			throw new InvalidOperationException($"{character.Export} prints a path for {Listed(untabled)}, and no rank table goes by that name. Run rank-tables.cs to read bg-wiki's table. An item bg-wiki has no table for needs a row among the items Oboro ranks up, in rank-doc.cs.");

		var who = character.Character;
		List<ExportItem> CopiesOf(string name) => character.Owned.Where(copy => copy.Name == name).ToList();
		// A slip records no augments, so only a copy in a bag shows its path.
		IReadOnlyList<string> PrintedOf(string name) => CopiesOf(name).Where(copy => copy.Slip == 0).Select(copy => copy.Augments).FirstOrDefault() ?? [];

		// A Ranks row is held to what can be checked: the path the export prints, the item's paths and the ranks
		// its table has. A mistyped row would otherwise put another path's augments, or none, in the document.
		foreach (var given in character.Ranks)
		{
			// bg-wiki has no rank table for an item Oboro ranks up, so its row can only be held to the export.
			var item = tables.Items.FirstOrDefault(candidate => candidate.Name == given.Key);
			var path = item?.Paths.FirstOrDefault(candidate => candidate.Path == given.Value.Path);
			if (item is not null && path is null)
				throw new InvalidOperationException($"{who}'s Ranks table: {given.Key} has no path \"{given.Value.Path}\". Its paths: {string.Join(", ", item.Paths.Select(candidate => candidate.Path))}.");
			var printed = Regex.Match(AsExported(PrintedOf(given.Key)), @"Path: (\w)");
			if (printed.Success && printed.Groups[1].Value != given.Value.Path)
				throw new InvalidOperationException($"{who}'s Ranks table gives {given.Key} path {given.Value.Path}, but the export prints 'Path: {printed.Groups[1].Value}'.");
			if (path is not null && given.Value.Rank > 0 && path.Ranks.Any(row => row.Rank == given.Value.Rank) is false)
				throw new InvalidOperationException($"{who}'s Ranks table: {given.Key} has no rank {given.Value.Rank} on path {path.Path}. Its ranks there: {Spans(path.Ranks.Select(row => row.Rank).ToList())}.");
		}
		bool Held(string name) => CopiesOf(name).Count > 0 || character.Ranks.ContainsKey(name);
		// What is known of a copy: the player's word, or else what the export alone can tell.
		CopyRank RankOf(string name)
		{
			var augments = PrintedOf(name);
			if (character.Ranks.TryGetValue(name, out var given))
				return new CopyRank(given.Path, given.Rank.ToString(), given.Given, augments);
			if (CopiesOf(name).All(copy => copy.Slip > 0))
				return new CopyRank("?", "unknown", "", augments);
			if (augments.Count == 0)
				return new CopyRank("none", "0", "", augments);
			var path = Regex.Match(AsExported(augments), @"Path: (\w)");
			return new CopyRank(path.Success ? path.Groups[1].Value : "?", "unknown", "", augments);
		}

		var held = Ordered(tables, resources).Where(item => Held(item.Name)).ToList();
		// Only a copy in a bag is printed with its augments, so only one of those can be printed bare.
		var ahead = held.Where(item => character.Ranks.ContainsKey(item.Name) && CopiesOf(item.Name).Any(copy => copy.Slip == 0) && RankOf(item.Name).Augments.Count == 0)
			.Select(item => FullName(resources, item.Name)).ToList();

		List<string> md =
		[
			$"# {who}: rank augments",
			"",
			$"{who}'s path and rank for each rank-augmented item in the export `{character.Export}`, with the augments that rank gives. `.claude/tools/rank-doc.cs` writes this file from the Ranks table in [{who}_notes.md]({who}_notes.md#ranks) and from bg-wiki's rank tables in [rank-augments.md]({tablesLink}), which has every other rank. Don't edit it by hand: change the Ranks table and run the tool.",
			"",
			"- `//gs export` prints the path (`'Path: B'`) but never the rank, so a rank is the player's word, with the day it was given.",
			"- A copy that exports with no augments at all hasn't been ranked: it is rank 0, with only the base stats in its help text.",
			"- A path item with no row in the Ranks table shows as unknown: the player hasn't given its rank. Ask before a set decision turns on it.",
		];
		if (ahead.Count > 0)
			md.Add($"- The export prints {Listed(ahead)} with no augments, as it would an unranked piece. The player has since given {(ahead.Count == 1 ? "its rank" : "their ranks")}, and the table uses {(ahead.Count == 1 ? "it" : "them")}.");
		md.Add("");
		md.Add("| Item | Slot | Path | Rank | Given | Augments at that rank |");
		md.Add("|---|---|---|---|---|---|");
		foreach (var item in held)
		{
			var copy = RankOf(item.Name);
			var rows = (item.Paths.FirstOrDefault(path => path.Path == copy.Path) ?? item.Paths[0]).Ranks;
			md.Add($"| [{item.Name}]({tablesLink}#{Anchor(item.Name)}) | {SlotOf(resources, item.Name)} | {copy.Path} | {copy.Rank} | {copy.Given} | {Cell(AugmentsAt(rows, copy.Rank))} |");
		}

		var oboroHeld = oboro.Items.Where(item => Held(item.Name)).ToList();
		if (oboroHeld.Count == 0)
			return md;
		md.Add("");
		md.Add("## Items Oboro ranks up");
		md.Add("");
		md.Add($"bg-wiki gives these items' augments at maximum rank only: [rank-augments.md]({tablesLink}#oboro-rank-augments-maximum-only). A copy that exports with no augments is rank 0. One that exports with a path has a rank the export doesn't show.");
		md.Add("");
		md.Add($"| Item | Slot | Max rank | {who}'s copy |");
		md.Add("|---|---|---|---|");
		foreach (var item in oboroHeld)
		{
			var copy = RankOf(item.Name);
			var rank = character.Ranks.TryGetValue(item.Name, out var given) ? $"rank {given.Rank} ({given.Given})" : "rank unknown";
			string shown;
			if (copy.Augments.Count > 0)
			{
				// Only the Level 119 III stage of an Ultimate Weapon takes the augment, so a path gives the stage away.
				shown = $"`{AsExported(copy.Augments)}`{(item.UltimateWeapon ? " (so Level 119 III)" : "")}, {rank}";
			}
			else if (given is null && copy.Path == "none")
			{
				shown = "no augments: rank 0" + (item.UltimateWeapon ? ", stage unknown" : "");
			}
			else
			{
				shown = "no augments in the export, " + rank;
			}
			md.Add($"| {item.Name} | {item.Slot} | {item.MaxRank} | {shown} |");
		}
		return md;
	}

	// The items in the order both documents list them: by family, then slot, then name.
	static List<RankedItem> Ordered(RankTables tables, Resources resources) => tables.Items
		.OrderBy(item => FamilyOf(item.Name))
		.ThenBy(item => Array.IndexOf(slotOrder, SlotOf(resources, item.Name)))
		.ThenBy(item => item.Name, StringComparer.Ordinal)
		.ToList();

	static string SlotOf(Resources resources, string name) => resources.Pick(name)?.Group ?? "";

	// The log name in title case, as the item's page heads it: "Bunzi's Rod", not "bunzi's rod".
	static string FullName(Resources resources, string name) => CultureInfo.InvariantCulture.TextInfo.ToTitleCase(resources.Pick(name)?.LogName ?? name).Replace("'S ", "'s ").Replace(" Of ", " of ");

	static int FamilyOf(string name)
	{
		var family = Array.FindIndex(families, name.StartsWith);
		return family < 0 ? families.Length : family;
	}

	// A copy's augments as the export prints them between the braces.
	static string AsExported(IReadOnlyList<string> augments) => string.Join(",", augments.Select(augment => $"'{augment}'"));

	static string Cell(string text) => text.Replace("|", "\\|");

	static string AugmentsAt(IReadOnlyList<RankRow> rows, string rank)
	{
		if (int.TryParse(rank, out var number) is false)
			return "";
		if (number == 0)
			return "none (base stats only)";
		var row = rows.FirstOrDefault(candidate => candidate.Rank == number);
		return row is null ? "" : string.Join(", ", row.Augments.Where(augment => augment.Length > 0));
	}

	static string Anchor(string name) => new string(name.ToLowerInvariant().Replace(' ', '-').Where(c => char.IsLetterOrDigit(c) || c == '-').ToArray());

	// Numbers as a reader lists them: "1 to 30" for an unbroken run, "1, 2, 15, 20" otherwise.
	static string Spans(IReadOnlyList<int> numbers) =>
		numbers.Count > 2 && numbers[^1] - numbers[0] == numbers.Count - 1 ? $"{numbers[0]} to {numbers[^1]}" : string.Join(", ", numbers);

	// "a", "a and b", "a, b and c".
	static string Listed(IReadOnlyList<string> parts) => parts.Count <= 1 ? string.Concat(parts) : string.Join(", ", parts.Take(parts.Count - 1)) + " and " + parts[^1];

	// What is known of a character's copy: its path ("none" when unranked, "?" when nothing shows it), its rank as
	// a number or "unknown", the day the player gave the rank, and the augments the export printed.
	sealed class CopyRank
	{
		public string Path { get; }

		public string Rank { get; }

		public string Given { get; }

		public IReadOnlyList<string> Augments { get; }

		public CopyRank(string path, string rank, string given, IReadOnlyList<string> augments)
		{
			Path = path;
			Rank = rank;
			Given = given;
			Augments = augments;
		}
	}
}

// What a character's document is made from, besides the tables: the export's copies and the player's ranks.
sealed class CharacterRanks
{
	public string Character { get; }

	// The export the copies came from, as a path from the repo root.
	public string Export { get; }

	public IReadOnlyList<ExportItem> Owned { get; }

	// By the name the export prints, such as "Obstin. Sash".
	public Dictionary<string, PlayerRank> Ranks { get; }

	public CharacterRanks(string character, string export, IReadOnlyList<ExportItem> owned, Dictionary<string, PlayerRank> ranks)
	{
		Character = character;
		Export = export;
		Owned = owned;
		Ranks = ranks;
	}
}

// The items Oboro ranks up. bg-wiki gives their augments at maximum rank only, so they are typed in, not read.
sealed class OboroAugments
{
	// The section's heading and what it says before its table.
	public IReadOnlyList<string> Intro { get; }

	public IReadOnlyList<OboroItem> Items { get; }

	public OboroAugments(IReadOnlyList<string> intro, IReadOnlyList<OboroItem> items)
	{
		Intro = intro;
		Items = items;
	}
}

sealed class OboroItem
{
	// The name as the export prints it.
	public string Name { get; }

	public string Slot { get; }

	public int MaxRank { get; }

	// A Relic, Mythic, Empyrean or Aeonic weapon. Only its Level 119 III stage takes the augment, and the export
	// prints every stage under one name.
	public bool UltimateWeapon { get; }

	// The augments at maximum rank, with their source, as the table cell reads.
	public string AtMaxRank { get; }

	public OboroItem(string name, string slot, int maxRank, bool ultimateWeapon, string atMaxRank)
	{
		Name = name;
		Slot = slot;
		MaxRank = maxRank;
		UltimateWeapon = ultimateWeapon;
		AtMaxRank = atMaxRank;
	}
}
