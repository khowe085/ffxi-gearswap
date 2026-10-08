// A worked example of choosing a set by search instead of by eye: the fastest recast BLU can reach from owned gear.
// It was used to build sets.Midcast.FastRecast in data/Vanar/BLU.lua. Copy it for a new question: change what is
// read from each piece and the formula in Score, and keep the shape (prune each slot, then try every combination).
// It shares nothing with the other tools, so a copy runs from any folder.
//
//   dotnet run --no-cache .claude/tools/owned-gear.cs -- --job BLU --json > pieces.json
//   dotnet run --no-cache .claude/tools/search-fast-recast.cs -- pieces.json [--table]
//
// --table prints what was read from each piece, in place of searching.
// recast = base x (1 - gear haste) x (1 - floor(min(trait + gear Fast Cast, 80) / 2) / 100) x (1 - Blue magic recast)
// Gear haste caps at 26% as listed, which is 25% (256/1024). Every slot but main, sub and range is searched; the
// two ears and the two rings take two different copies. It prints the best set for each Fast Cast trait level and
// for three pools: pieces BLU's sets already wear, pieces any job file wears, and everything owned.
using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.IO;
using System.Text.Json;
using System.Text.RegularExpressions;

if (args.Length is < 1 or > 2 || File.Exists(args[0]) is false || (args.Length == 2 && args[1] != "--table"))
{
	Console.Error.WriteLine("Give the file owned-gear.cs --job BLU --json wrote, and --table to see what was read from each piece.");
	return 2;
}

// "Enhances "Fast Cast" effect" hides its number in the help text; these are the values (docs/gear-notes.md).
// Fi Follet Cape +1's is its Path A augment at Vanar's rank 11, which the export doesn't print.
var hiddenFastCast = new Dictionary<string, int>
{
	["Loquac. Earring"] = 2, ["Prolix Ring"] = 2, ["Swith Cape"] = 3, ["Witful Belt"] = 3,
	["Enif Cosciales"] = 8, ["Chelona Boots"] = 4, ["Orvail Pants +1"] = 5, ["Fi Follet Cape +1"] = 8,
};
// The Jhakri set bonus is Fast Cast by pieces worn, so each piece counts toward it and the bonus is added at the end.
HashSet<string> jhakri = ["Jhakri Coronal +2", "Jhakri Robe +2", "Jhakri Cuffs +2", "Jhakri Slops +2", "Jhakri Pigaches +2", "Jhakri Ring"];
int[] jhakriFastCast = [0, 0, 3, 6, 9, 12, 12];
// Player rule: no Quick Magic gear but Witful Belt.
HashSet<string> quickMagic = ["Impatiens", "Perimede Cape", "Ogapepo Cape"];
// Lines of help text from here on describe a set bonus, a pet or a condition, not what the wearer always gets.
var conditional = new Regex(@"^\s*(Set:|Pet:|Avatar:|Wyvern:|Automaton:|Unity Ranking|Latent effect|Citizen of|Summoned Pet)", RegexOptions.IgnoreCase);

var pieces = new List<Piece>();
using (var json = JsonDocument.Parse(File.ReadAllText(args[0])))
{
	foreach (var entry in json.RootElement.EnumerateArray())
	{
		var slots = entry.GetProperty("Slots").EnumerateArray().Select(slot => slot.GetString()!).ToList();
		if (slots.All(slot => slot is "main" or "sub" or "range"))
			continue;
		var name = entry.GetProperty("Name").GetString()!;
		var augments = entry.GetProperty("Augments").EnumerateArray().Select(augment => augment.GetString()!).Where(augment => augment.StartsWith("Pet:") is false).ToList();
		var always = string.Join("\n", entry.GetProperty("Description").GetString()!.Split('\n').TakeWhile(line => conditional.IsMatch(line) is false));
		var augmentText = string.Join("\n", augments);
		int Sum(string text, string pattern) => Regex.Matches(text, pattern, RegexOptions.Multiline).Sum(match => int.Parse(match.Groups[1].Value));
		var haste = Sum(always, @"(?<![A-Za-z:] )(?<![A-Za-z])Haste\+(\d+)%") + Sum(augmentText, @"^Haste\+(\d+)");
		var fastCast = hiddenFastCast.TryGetValue(name, out var hidden) ? hidden : Sum(always, @"""Fast Cast""\+(\d+)%") + Sum(augmentText, @"""Fast Cast""\+(\d+)");
		var blueRecast = Sum(always, @"Blue magic recast delay -(\d+)%");
		var damageTaken = Sum(always, @"(?<!Physical |Magic |Phys\. )Damage taken-(\d+)%") + Sum(augmentText, @"^Damage taken-(\d+)%");
		var wornBy = entry.GetProperty("WornBy").EnumerateObject().Select(job => job.Name).ToList();
		var who = wornBy.Contains("BLU") ? "BLU" : wornBy.FirstOrDefault() ?? "-";
		// One candidate for each copy held, so two copies of a ring can fill both ring slots.
		foreach (var bag in entry.GetProperty("Bags").EnumerateArray())
			pieces.Add(new Piece(name, bag.GetString()!, slots, haste, fastCast, blueRecast, jhakri.Contains(name) ? 1 : 0, damageTaken, who, quickMagic.Contains(name)));
	}
}

// The numbers read from each piece that has any. Check these against the help text before trusting a result: a
// pattern that misses a stat, or counts a pet's, makes every answer below wrong.
if (args.Length == 2)
{
	foreach (var piece in pieces.Where(piece => piece.Haste + piece.FastCast + piece.BlueRecast + piece.Jhakri > 0).OrderBy(piece => piece.Slots[0], StringComparer.Ordinal).ThenByDescending(piece => piece.Haste + piece.FastCast))
		Console.WriteLine($"{piece.Slots[0],-10} H{piece.Haste,2} FC{piece.FastCast,2} B{piece.BlueRecast,2} J{piece.Jhakri} DT{piece.DamageTaken,2} {piece.Bag,-10} {piece.Who,-4} {piece.Name}");
	return 0;
}

int[] traits = [5, 15, 20, 25];
string[] singleSlots = ["ammo", "head", "body", "hands", "legs", "feet", "neck", "waist", "back"];
string[] pairedSlots = ["left_ear", "left_ring"];
string[] pools = ["BLU", "carried", "owned"];
// Blue magic takes Blue magic recast gear; Utsusemi and other spells don't.
bool[] spellKinds = [true, false];
foreach (var pool in pools)
{
	foreach (var blue in spellKinds)
	{
		bool Eligible(Piece piece) => piece.QuickMagic is false && (pool == "owned" || (pool == "carried" ? piece.Who != "-" : piece.Who == "BLU"));
		// Each slot's choices: one piece, or none, which leaves the idle set's piece in place.
		var groups = new List<List<Piece[]>>();
		foreach (var slot in singleSlots)
		{
			List<Piece[]> choices = [[]];
			choices.AddRange(pieces.Where(piece => piece.Slots.Contains(slot) && Eligible(piece)).Select<Piece, Piece[]>(piece => [piece]));
			groups.Add(Prune(choices, blue));
		}
		foreach (var slot in pairedSlots)
		{
			var candidates = pieces.Where(piece => piece.Slots.Contains(slot) && Eligible(piece)).ToList();
			List<Piece[]> choices = [[]];
			for (var first = 0; first < candidates.Count; first++)
			{
				choices.Add([candidates[first]]);
				for (var second = first + 1; second < candidates.Count; second++)
					choices.Add([candidates[first], candidates[second]]);
			}
			groups.Add(Prune(choices, blue));
		}

		var best = traits.ToDictionary(trait => trait, trait => new Best());
		var picked = new Piece[groups.Count][];
		void Try(int group, int haste, int fastCast, int blueRecast, int jhakriCount, int damageTaken)
		{
			if (group < groups.Count)
			{
				foreach (var choice in groups[group])
				{
					picked[group] = choice;
					Try(group + 1, haste + choice.Sum(piece => piece.Haste), fastCast + choice.Sum(piece => piece.FastCast), blueRecast + choice.Sum(piece => piece.BlueRecast),
						jhakriCount + choice.Sum(piece => piece.Jhakri), damageTaken + choice.Sum(piece => piece.DamageTaken));
				}
				return;
			}
			foreach (var trait in traits)
			{
				var gearFastCast = fastCast + jhakriFastCast[Math.Min(jhakriCount, 6)];
				var score = Math.Round(Score(haste, trait + gearFastCast, blue ? blueRecast : 0), 9);
				var current = best[trait];
				// Lower is better. Among equal recasts, the set with more damage taken reduction wins.
				if (score < current.Score || (score == current.Score && damageTaken > current.DamageTaken))
				{
					best[trait] = new Best(score, damageTaken, picked.ToArray(), haste, gearFastCast, blue ? blueRecast : 0, score < current.Score ? 1 : current.Ties + 1);
				}
				else if (score == current.Score)
				{
					current.Ties++;
				}
			}
		}
		Try(0, 0, 0, 0, 0, 0);

		Console.WriteLine($"===== pool={pool} {(blue ? "blue" : "non-blue (Utsusemi)")}  combos={groups.Aggregate(1L, (total, group) => total * group.Count):N0}");
		foreach (var trait in traits)
		{
			var found = best[trait];
			Console.WriteLine($"  trait {trait}: H{found.Haste} gearFC{found.FastCast} B{found.BlueRecast} DT{found.DamageTaken} x{found.Score:F4} cut {100 * (1 - found.Score):F2}%  ties={found.Ties}");
			Console.WriteLine("     " + string.Join(" | ", found.Set.SelectMany(choice => choice).Select(piece =>
				$"{piece.Name}({piece.Haste}/{piece.FastCast}{(piece.BlueRecast > 0 ? "/B" + piece.BlueRecast : "")}{(piece.DamageTaken > 0 ? " DT" + piece.DamageTaken : "")} {piece.Bag} {piece.Who})")));
		}
	}
}
return 0;

// The share of the base recast left.
static double Score(int haste, int fastCastTotal, int blueRecast) => (1 - Math.Min(haste, 26) / 26.0 * 0.25) * (1 - Math.Min(fastCastTotal, 80) / 2 / 100.0) * (1 - blueRecast / 100.0);

// Cuts a slot's choices down before they are multiplied together: of the choices equal in every stat the formula
// reads, keep the one with most damage taken reduction, then drop any choice another one beats or ties everywhere.
static List<Piece[]> Prune(IEnumerable<Piece[]> choices, bool blue)
{
	var keyed = choices
		.GroupBy(choice => (Haste: Math.Min(choice.Sum(piece => piece.Haste), 26), FastCast: choice.Sum(piece => piece.FastCast), BlueRecast: blue ? choice.Sum(piece => piece.BlueRecast) : 0, Jhakri: choice.Sum(piece => piece.Jhakri)))
		.Select(group => (Stats: group.Key, Choice: group.OrderByDescending(choice => choice.Sum(piece => piece.DamageTaken)).ThenBy(choice => choice.Length).First()))
		.ToList();
	var kept = new List<Piece[]>();
	foreach (var one in keyed)
	{
		var damageTaken = one.Choice.Sum(piece => piece.DamageTaken);
		var beaten = keyed.Any(other => ReferenceEquals(one.Choice, other.Choice) is false
			&& other.Stats.Haste >= one.Stats.Haste && other.Stats.FastCast >= one.Stats.FastCast && other.Stats.BlueRecast >= one.Stats.BlueRecast && other.Stats.Jhakri >= one.Stats.Jhakri
			&& other.Choice.Sum(piece => piece.DamageTaken) >= damageTaken
			&& (other.Stats != one.Stats || other.Choice.Sum(piece => piece.DamageTaken) > damageTaken));
		if (beaten is false)
			kept.Add(one.Choice);
	}
	return kept;
}

// One copy of a piece, with the numbers the recast formula reads from it.
sealed class Piece
{
	public string Name { get; }

	public string Bag { get; }

	public IReadOnlyList<string> Slots { get; }

	public int Haste { get; }

	public int FastCast { get; }

	public int BlueRecast { get; }

	// 1 for a piece of the Jhakri set.
	public int Jhakri { get; }

	public int DamageTaken { get; }

	// "BLU" when a BLU set wears it, another job's name when only that job's sets do, "-" when no set does.
	public string Who { get; }

	public bool QuickMagic { get; }

	public Piece(string name, string bag, IReadOnlyList<string> slots, int haste, int fastCast, int blueRecast, int jhakri, int damageTaken, string who, bool quickMagic)
	{
		Name = name;
		Bag = bag;
		Slots = slots;
		Haste = haste;
		FastCast = fastCast;
		BlueRecast = blueRecast;
		Jhakri = jhakri;
		DamageTaken = damageTaken;
		Who = who;
		QuickMagic = quickMagic;
	}
}

// The best set found so far for one trait level.
sealed class Best
{
	public double Score { get; }

	public int DamageTaken { get; }

	public Piece[][] Set { get; }

	public int Haste { get; }

	public int FastCast { get; }

	public int BlueRecast { get; }

	// How many combinations reach this score.
	public int Ties { get; set; }

	public Best()
	{
		Score = 9;
		DamageTaken = -1;
		Set = [];
	}

	public Best(double score, int damageTaken, Piece[][] set, int haste, int fastCast, int blueRecast, int ties)
	{
		Score = score;
		DamageTaken = damageTaken;
		Set = set;
		Haste = haste;
		FastCast = fastCast;
		BlueRecast = blueRecast;
		Ties = ties;
	}
}
