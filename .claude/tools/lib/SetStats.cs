using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.IO;
using System.Text.RegularExpressions;

namespace GearTools;

// A set's stat totals, read from each piece's help text and its copy's augments, as set-stats.cs prints them. It
// reads what the text says the wearer always has: a pet's, a set bonus's, a latent effect's and the like are dropped.
// A path piece's augments at the character's rank come from the character's rank file, and what the text hides
// (docs/gear-notes.md) from the caller, as extra stats by item. The numbers are a sum, not the game's caps or formulas;
// docs/ffxi-mechanics.md has those.
sealed class StatBook
{
	// The order Describe lists the stats in. A stat outside it comes after, by name.
	public static IReadOnlyList<string> Order { get; }

	static (Regex Pattern, string Stat)[] rules;
	static (string From, string To)[] abbreviations;
	static Regex conditional;

	Resources resources;
	IReadOnlyList<ExportItem> owned;
	Dictionary<string, Dictionary<string, int>> extra;
	// Null when the caller gives no rank file.
	IReadOnlyDictionary<string, RankedCopy>? ranks;

	static StatBook()
	{
		Order = ["Acc", "Att", "Macc", "MaccSkill", "MAB", "MDmg", "DT", "PDT", "MDT", "FC", "Haste", "Cure", "CureII",
			"EnhSkill", "EnfSkill", "ElemSkill", "DarkSkill", "HealSkill", "BlueSkill", "AllSkill", "EnhDur", "AugEnhDur", "EnfDur", "AugEnfDur",
			"EnfEffect", "WSD", "DA", "TA", "STP", "Crit", "PDL", "Refresh", "RefreshPot", "RegenPot", "MBD", "MBD2", "SIRD", "Aquaveil", "Stoneskin",
			"TH", "DW", "HP", "MP", "STR", "DEX", "VIT", "AGI", "INT", "MND", "CHR", "MEva", "MDB", "Eva", "SwordSkill", "BMCast", "BMRecast",
			"CureCast", "BreathDmg", "TPBonus", "WSAcc", "SB", "Gain", "BA", "CA", "Efflux", "EnfCast", "Regain"];
		// From here to the end of the text, or of the line, nothing is a stat the wearer always has.
		conditional = new Regex(@"(?:(?:Pet:|Avatar:|Summoned Pet:|Automaton:|Set:|Latent effect:)[\s\S]*$)|(?:(?:Unity Ranking:|Citizen of |Reives:|Main hand:)[^\n]*)");
		// In this order: a longer form goes before any shorter one inside it, so "Rng.Acc.+" becomes "Ranged Accuracy+"
		// before "Acc.+" could make it "Rng.Accuracy+", which the Accuracy rule would then count.
		abbreviations = [
			("Rng.Acc.", "Ranged Accuracy"), ("Rng. Acc.", "Ranged Accuracy"), ("Rng.Atk.", "Ranged Attack"), ("Rng. Atk.", "Ranged Attack"),
			("\"Mag.Atk.Bns.\"", "MAB"), ("\"Mag. Atk. Bns.\"", "MAB"), ("\"Magic Atk. Bonus\"", "MAB"), ("\"M. Atk. B.\"", "MAB"),
			("\"Magic Def. Bonus\"", "MDB"), ("\"M. Def. B.\"", "MDB"),
			("Mag. Acc+", "Magic Accuracy+"), ("Mag. Acc.+", "Magic Accuracy+"), ("Mag. Acc.", "Magic Accuracy"),
			("Mag. Dmg.+", "Magic Damage+"), ("Mag. Dmg.", "Magic Damage"),
			("Mag. Eva.", "Magic Evasion"), ("Magic Eva.", "Magic Evasion"), ("Eva.", "Evasion"),
			("Acc.+", "Accuracy+"), ("Atk.+", "Attack+"),
			("\"Dbl.Atk.\"", "\"Double Attack\""), ("\"Triple Atk.\"", "\"Triple Attack\""), ("Crit.hit rate", "Critical hit rate"),
			("Enfb.mag. skill", "Enfeebling magic skill"), ("Enha.mag. skill", "Enhancing magic skill"),
			("Enfb. mag. skill", "Enfeebling magic skill"), ("Enha. mag. skill", "Enhancing magic skill"),
			("Elem. magic skill", "Elemental magic skill"), ("Enh. Mag. eff. dur.", "AUGENHDUR"),
		];
		// In this order: each match is blanked out before the next rule runs, so "Magic Accuracy+" is never counted
		// again as "Accuracy+". A rule with no stat only blanks out what it matches.
		(string, string)[] written = [
			(@"Ranged Accuracy\s*\+(\d+)", ""), (@"Ranged Attack\s*\+(\d+)", ""), (@"Rng\.\s*Acc\.\s*\+(\d+)", ""), (@"Rng\.\s*Atk\.\s*\+(\d+)", ""),
			(@"Magic Accuracy skill \+(\d+)", ""), (@"Parrying skill \+(\d+)", ""), (@"Archery skill \+(\d+)", ""),
			(@"Weapon Skill Accuracy\s*\+(\d+)", "WSAcc"),
			(@"Magic Accuracy\s*\+(\d+)", "Macc"), (@"Magic Damage taken\s*-(\d+)%", "MDT"), (@"Physical [Dd]amage taken\s*-(\d+)%", "PDT"),
			(@"Phys\. dmg\. taken -(\d+)%", "PDT"), (@"Damage taken\s*-(\d+)%", "DT"), (@"Magic Damage\s*\+(\d+)", "MDmg"),
			(@"Magic Evasion\s*\+(\d+)", "MEva"), (@"Evasion\s*\+(\d+)", "Eva"), (@"MDB\s*\+(\d+)", "MDB"), (@"MAB\s*\+(\d+)", "MAB"),
			(@"Accuracy\s*\+(\d+)", "Acc"),
			// The rank file writes it unquoted, which the Attack rule after it would read as Attack.
			(@"\bDouble Attack\s*\+(\d+)%?", "DA"), (@"Attack\s*\+(\d+)", "Att"), (@"""Fast Cast""\s*\+(\d+)%?", "FC"), (@"Haste\s*\+(\d+)%?", "Haste"),
			(@"""Cure"" potency II \+(\d+)%", "CureII"), (@"""Cure"" potency \+(\d+)%", "Cure"), (@"""Cure"" spellcasting time -(\d+)%", "CureCast"),
			(@"Enhancing magic skill \+(\d+)", "EnhSkill"), (@"Enfeebling magic skill \+(\d+)", "EnfSkill"), (@"Elemental magic skill \+(\d+)", "ElemSkill"),
			(@"Dark magic skill \+(\d+)", "DarkSkill"), (@"Healing magic skill \+(\d+)", "HealSkill"), (@"Blue [Mm]agic skill \+(\d+)", "BlueSkill"),
			(@"All magic skills \+(\d+)", "AllSkill"), (@"Sword skill \+(\d+)", "SwordSkill"), (@"Club skill \+(\d+)", ""), (@"Dagger skill \+(\d+)", ""),
			(@"Enhancing magic effect duration \+(\d+)%", "EnhDur"), (@"Enfeebling magic effect duration \+(\d+)%", "EnfDur"), (@"Enhancing magic duration \+(\d+)%", "EnhDur"), (@"AUGENHDUR \+(\d+)", "AugEnhDur"), (@"Enfeebling magic duration \+(\d+)%", "EnfDur"),
			(@"Enfeebling [Mm]agic effect \+(\d+)", "EnfEffect"), (@"Enfeebling magic casting time -(\d+)%", "EnfCast"), (@"Weapon [Ss]kill [Dd]amage\s*\+(\d+)%", "WSD"),
			(@"""Double Attack""\s*\+(\d+)%?", "DA"), (@"""Triple Attack""\s*\+(\d+)%?", "TA"), (@"""Store TP""\s*-(\d+)", "-STP"), (@"""Store TP""\s*\+(\d+)", "STP"), (@"\bStore TP \+(\d+)", "STP"),
			(@"Critical hit rate\s*\+(\d+)%?", "Crit"), (@"Physical damage limit\s*\+(\d+)%", "PDL"), (@"""Refresh"" potency \+(\d+)", "RefreshPot"),
			// "Refesh" is how one item's help text spells it.
			(@"""Refresh""\s*\+(\d+)", "Refresh"), (@"""Refesh""\s*\+(\d+)", "Refresh"), (@"""Regen"" potency\s*\+(\d+)", "RegenPot"), (@"Magic burst damage II \+(\d+)", "MBD2"),
			(@"Magic burst damage\s*\+(\d+)", "MBD"), (@"Spell interruption rate down (\d+)%", "SIRD"), (@"Spell [Ii]nterruption [Rr]ate -(\d+)%", "SIRD"), (@"""Aquaveil""\s*\+(\d+)", "Aquaveil"),
			(@"""Stoneskin""\s*\+(\d+)", "Stoneskin"), (@"""Treasure Hunter""\s*\+(\d+)", "TH"), (@"""Dual Wield""\s*\+(\d+)", "DW"),
			(@"Blue magic spellcasting time -(\d+)%", "BMCast"), (@"Blue magic recast delay -(\d+)%", "BMRecast"), (@"Breath Damage dealt\s*\+(\d+)%", "BreathDmg"),
			(@"TP Bonus \+(\d+)", "TPBonus"), (@"""Subtle Blow""\s*\+(\d+)", "SB"), (@"""Gain"" magic effects \+(\d+)", "Gain"),
			(@"""Burst Affinity""\s*\+(\d+)", "BA"), (@"""Chain Affinity""\s*\+(\d+)", "CA"), (@"""Efflux"" TP [Bb]onus \+(\d+)", "Efflux"),
			(@"Regain\s*\+(\d+)", "Regain"), (@"""Regain""\s*\+(\d+)", "Regain"),
			(@"\bHP\s*\+(\d+)", "HP"), (@"\bMP\s*\+(\d+)", "MP"), (@"\bSTR\s*\+(\d+)", "STR"), (@"\bDEX\s*\+(\d+)", "DEX"), (@"\bVIT\s*\+(\d+)", "VIT"),
			(@"\bAGI\s*\+(\d+)", "AGI"), (@"\bINT\s*\+(\d+)", "INT"), (@"\bMND\s*\+(\d+)", "MND"), (@"\bCHR\s*\+(\d+)", "CHR"),
			(@"\bSTR\s*-(\d+)", "-STR"), (@"\bDEX\s*-(\d+)", "-DEX"), (@"\bVIT\s*-(\d+)", "-VIT"), (@"\bAGI\s*-(\d+)", "-AGI"),
		];
		rules = written.Select(rule => (new Regex(rule.Item1), rule.Item2)).ToArray();
	}

	// owned: the export, for the augments of the copy each piece means. extra: stats to add for an item, by the name
	// the export prints. ranks: the character's rank file (RankAugments.Read).
	public StatBook(Resources resources, IReadOnlyList<ExportItem> owned, IReadOnlyDictionary<string, Dictionary<string, int>> extra,
		IReadOnlyDictionary<string, RankedCopy>? ranks = null)
	{
		this.resources = resources;
		this.owned = owned;
		this.extra = new Dictionary<string, Dictionary<string, int>>(extra, StringComparer.OrdinalIgnoreCase);
		this.ranks = ranks;
	}

	// A set's slots, resolved over their bases (Dto.Resolve). An empty slot, or an item the resources don't know,
	// adds nothing.
	public Dictionary<string, int> Totals(IReadOnlyDictionary<string, PieceDto> slots, List<string>? warnings = null)
	{
		var total = new Dictionary<string, int>();
		void Add(string stat, int value) => total[stat] = total.GetValueOrDefault(stat) + value;
		var worn = new List<string>();
		foreach (var (slot, piece) in slots)
		{
			if (piece.Item == Dto.Empty)
				continue;
			var info = resources.Pick(piece.Item);
			if (info is null)
			{
				warnings?.Add($"{slot}: \"{piece.Item}\" isn't a weapon or armor in Windower's resources, so it adds nothing");
				continue;
			}
			// A piece that names no augments takes the first copy held.
			var copy = owned.FirstOrDefault(line => info.Name.Equals(line.Name, StringComparison.OrdinalIgnoreCase) && piece.Matches(line)
				&& (piece.Bag is null || piece.Bag == line.Bag));
			if (copy is null)
			{
				var augments = piece.Augments is { Count: > 0 } ? $" [{string.Join(", ", piece.Augments)}]" : "";
				warnings?.Add($"{slot}: \"{piece.Item}\"{augments} matches no copy in the export, so only its help text counts");
			}
			// An earring's help text gives the lines from "Right ear:" on in the right ear only. Sortie earrings open
			// with it, so in the left ear they give nothing at all; Balder Earring's stats before it count in either ear.
			var text = info.Description;
			var rightEar = Regex.Match(text, @"^Right ear:", RegexOptions.Multiline);
			if (rightEar.Success && slot != "right_ear")
			{
				if (rightEar.Index == 0)
					continue;
				text = text[..rightEar.Index];
			}
			foreach (var (stat, value) in Parse(text))
				Add(stat, value);
			foreach (var augment in copy?.Augments ?? [])
			{
				foreach (var (stat, value) in Parse(augment))
					Add(stat, value);
			}
			// The export prints a ranked copy's path but never its rank, so what the rank adds comes from the rank file.
			// A copy printed with no path can still be the row's: rank-doc.cs writes a rank the player has given since.
			var printedPath = copy?.Augments.FirstOrDefault(augment => augment.StartsWith("Path: "));
			RankedCopy? ranked = null;
			if (copy is not null && ranks is not null && ranks.TryGetValue(info.Name, out var row))
				ranked = row;
			else if (copy is not null && ranks is not null && printedPath is not null)
				warnings?.Add($"{slot}: \"{piece.Item}\" prints path {printedPath["Path: ".Length..]}, and the rank file has no row for it, so its rank augments are missing");
			if (ranked is { MaxRank: not null })
			{
				foreach (var (stat, value) in OboroAugments(slot, piece.Item, ranked, warnings))
					Add(stat, value);
			}
			else if (ranked is not null && printedPath is not null && printedPath != $"Path: {ranked.Path}")
			{
				warnings?.Add($"{slot}: \"{piece.Item}\" prints path {printedPath["Path: ".Length..]}, but the rank file gives path {ranked.Path}; run rank-doc.cs, since its rank augments are missing");
			}
			else if (ranked is not null)
			{
				if (ranked.Rank == "unknown")
					warnings?.Add($"{slot}: \"{piece.Item}\" is path {ranked.Path} at a rank the player hasn't given, so its rank augments are missing");
				foreach (var (stat, value) in Parse(ranked.Augments))
					Add(stat, value);
			}
			foreach (var (stat, value) in extra.GetValueOrDefault(info.Name) ?? [])
				Add(stat, value);
			// A weapon's magic accuracy skill counts from the main hand only.
			var skill = Regex.Match(info.Description, @"Magic Accuracy skill \+(\d+)");
			if (slot == "main" && skill.Success)
				Add("MaccSkill", int.Parse(skill.Groups[1].Value));
			worn.Add(info.Name);
		}
		foreach (var (stat, value) in SetBonuses(worn))
			Add(stat, value);
		return total.Where(stat => stat.Value != 0).ToDictionary();
	}

	// An item Oboro ranks up: bg-wiki gives its augments at maximum rank only, so they count at that rank and are
	// missing below it. An Ultimate Weapon's, written after "Main hand:", work in the main hand only.
	static IEnumerable<(string Stat, int Value)> OboroAugments(string slot, string item, RankedCopy ranked, List<string>? warnings)
	{
		if (ranked.Rank == "0")
			return [];
		if (ranked.Rank == "unknown")
		{
			warnings?.Add($"{slot}: \"{item}\" is ranked by Oboro at a rank the player hasn't given, so its augments are missing");
			return [];
		}
		if (ranked.Rank != ranked.MaxRank)
		{
			warnings?.Add($"{slot}: \"{item}\" is rank {ranked.Rank} of {ranked.MaxRank}, and its augments are known at rank {ranked.MaxRank} only, so they're missing");
			return [];
		}
		if (ranked.Augments.StartsWith("Main hand:"))
			return slot == "main" ? Parse(ranked.Augments["Main hand:".Length..], sharedValues: true) : [];
		return Parse(ranked.Augments, sharedValues: true);
	}

	// The set bonuses counted, by the names the export prints. The help text names a set bonus only as "Set:", so the
	// numbers are docs/gear-notes.md's, written here: the Atrophy and Assimilator's sets (+2, +3 and +4 pieces, with a
	// Regal Earring as one more piece) and the Jhakri set (+2 pieces and the ring). Other sets aren't counted.
	public static Dictionary<string, int> SetBonuses(IEnumerable<string> pieces)
	{
		var names = pieces.ToList();
		bool Upgraded(string name) => name.EndsWith(" +2") || name.EndsWith(" +3") || name.EndsWith(" +4");
		var regal = names.Contains("Regal Earring") ? 1 : 0;
		var bonuses = new Dictionary<string, int>();
		void Add(string stat, int value) => bonuses[stat] = bonuses.GetValueOrDefault(stat) + value;
		string[][] artifact = [["Atro. ", "Atrophy "], ["Assim. ", "Assimilator's "]];
		foreach (var prefixes in artifact)
		{
			var count = names.Count(name => prefixes.Any(name.StartsWith) && Upgraded(name));
			if (count == 0)
				continue;
			// 15 for each piece after the first, up to five pieces.
			var accuracy = 15 * (Math.Min(count + regal, 5) - 1);
			if (accuracy > 0)
			{
				Add("Acc", accuracy);
				Add("Macc", accuracy);
			}
		}
		var jhakri = names.Count(name => name == "Jhakri Ring" || (name.StartsWith("Jhakri ") && name.EndsWith(" +2")));
		if (jhakri >= 2)
			Add("FC", 3 * (Math.Min(jhakri, 5) - 1));
		return bonuses;
	}

	public static string Describe(Dictionary<string, int> totals) => string.Join(", ", totals.Keys
		.OrderBy(stat => Order.Contains(stat) ? Order.ToList().IndexOf(stat) : Order.Count)
		.ThenBy(stat => stat, StringComparer.Ordinal)
		.Select(stat => $"{stat} {totals[stat]}"));

	public static Dictionary<string, int> Read(string text, bool sharedValues = false) => Parse(text, sharedValues).GroupBy(stat => stat.Stat).ToDictionary(group => group.Key, group => group.Sum(stat => stat.Value));

	// sharedValues: the text is docs/rank-augments.md's, which writes two stats that share a value as "INT and MND +12".
	static IEnumerable<(string Stat, int Value)> Parse(string text, bool sharedValues = false)
	{
		var work = conditional.Replace(text, "").Replace("Right ear:", "");
		// Help text says "HP and MP recovered while healing +2" of one stat, so only that text is read this way.
		if (sharedValues)
			work = Regex.Replace(work, @"\b(\w[\w. ]*?) and (\w[\w. ]*?) \+(\d+)", "$1 +$3 $2 +$3");
		foreach (var (from, to) in abbreviations)
			work = work.Replace(from, to);
		foreach (var (pattern, stat) in rules)
		{
			foreach (Match match in pattern.Matches(work))
			{
				if (stat.Length == 0)
					continue;
				var value = int.Parse(match.Groups[1].Value);
				yield return stat.StartsWith('-') ? (stat[1..], -value) : (stat, value);
			}
			work = pattern.Replace(work, " ");
		}
	}
}
