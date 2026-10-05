using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.IO;
using System.Text.RegularExpressions;

namespace GearTools;

// Windower's resource files, which fetch-sources.cs puts in the cache. They hold what //gs export leaves out:
// each item's id, jobs, slots, level and help text.
sealed class Resources
{
	// Indexed by the bit each job has in an item's jobs number. Bit 0 is unused.
	public static IReadOnlyList<string> JobNames { get; }

	// Indexed by the bit each slot has in an item's slots number, spelled as GearSwap sets spell them.
	public static IReadOnlyList<string> SlotNames { get; }

	Dictionary<string, List<ItemInfo>> byName;

	static Resources()
	{
		JobNames = ["", "WAR", "MNK", "WHM", "BLM", "RDM", "THF", "PLD", "DRK", "BST", "BRD", "RNG", "SAM", "NIN", "DRG", "SMN", "BLU", "COR", "PUP", "DNC", "SCH", "GEO", "RUN"];
		SlotNames = ["main", "sub", "range", "ammo", "head", "body", "hands", "legs", "feet", "neck", "waist", "left_ear", "right_ear", "left_ring", "right_ring", "back"];
	}

	Resources(Dictionary<string, List<ItemInfo>> byName)
	{
		this.byName = byName;
	}

	public static Resources Load()
	{
		var itemsPath = Tool.InCache("res", "items.lua");
		var descriptionsPath = Tool.InCache("res", "item_descriptions.lua");
		if (File.Exists(itemsPath) is false || File.Exists(descriptionsPath) is false)
			Tool.Fail("Windower's resources aren't in .claude/cache. Run: dotnet run --no-cache .claude/tools/fetch-sources.cs");

		var text = "(?:[^\"\\\\]|\\\\.)*";
		var descriptionLine = new Regex("^\\s*\\[(\\d+)\\] = \\{id=\\d+,en=\"(" + text + ")\"");
		var descriptions = new Dictionary<int, string>();
		foreach (var line in File.ReadLines(descriptionsPath))
		{
			var match = descriptionLine.Match(line);
			if (match.Success)
				descriptions[int.Parse(match.Groups[1].Value)] = Unescape(match.Groups[2].Value);
		}

		var itemLine = new Regex("^\\s*\\[(\\d+)\\] = \\{id=\\d+,en=\"(" + text + ")\",ja=\"" + text + "\",enl=\"(" + text + ")\"(.*)\\},?\\s*$");
		var byName = new Dictionary<string, List<ItemInfo>>(StringComparer.OrdinalIgnoreCase);
		foreach (var line in File.ReadLines(itemsPath))
		{
			var match = itemLine.Match(line);
			if (match.Success is false)
				continue;
			var rest = match.Groups[4].Value;
			var category = Regex.Match(rest, "category=\"(\\w+)\"").Groups[1].Value;
			if (category != "Weapon" && category != "Armor")
				continue;
			var id = int.Parse(match.Groups[1].Value);
			var item = new ItemInfo(id, Unescape(match.Groups[2].Value), Unescape(match.Groups[3].Value), category,
				Number(rest, "jobs"), Number(rest, "slots"), Number(rest, "level"), Number(rest, "item_level"),
				descriptions.GetValueOrDefault(id, ""));
			string[] names = [item.Name, item.LogName];
			foreach (var name in names.Distinct(StringComparer.OrdinalIgnoreCase))
			{
				if (byName.TryGetValue(name, out var list) is false)
					byName[name] = list = [];
				list.Add(item);
			}
		}
		return new Resources(byName);
	}

	// The names of every blue magic spell, for checking a BLU file's spell lists.
	public static List<string> BlueSpells()
	{
		var path = Tool.InCache("res", "spells.lua");
		if (File.Exists(path) is false)
			Tool.Fail("Windower's resources aren't in .claude/cache. Run: dotnet run --no-cache .claude/tools/fetch-sources.cs");
		return File.ReadLines(path)
			.Where(line => line.Contains("type=\"BlueMagic\""))
			.Select(line => Unescape(Regex.Match(line, "\\ben=\"((?:[^\"\\\\]|\\\\.)*)\"").Groups[1].Value))
			.ToList();
	}

	// Every weapon or armor piece with this name or log name, ignoring case, which is how GearSwap matches the
	// name a set gives. Several ids can share one name: every stage of a Relic, Mythic or Empyrean weapon does.
	public IReadOnlyList<ItemInfo> Named(string name) => byName.TryGetValue(name, out var list) ? list : [];

	// The item to describe for a name. Of several, it prefers the ones that fit the slot the export printed, then
	// the highest item level, so an upgraded weapon shows its last stage, not its level 75 one.
	public ItemInfo? Pick(string name, string? slotKey = null)
	{
		var candidates = Named(name);
		var fitting = slotKey is null ? [] : candidates.Where(item => item.FitsSlot(slotKey)).ToList();
		return (fitting.Count > 0 ? fitting : candidates)
			.OrderByDescending(item => item.ItemLevel)
			.ThenByDescending(item => item.Level)
			.ThenByDescending(item => item.Id)
			.FirstOrDefault();
	}

	// \b keeps "level" from matching inside "item_level".
	static int Number(string fields, string key)
	{
		var match = Regex.Match(fields, "\\b" + key + "=(\\d+)");
		return match.Success ? int.Parse(match.Groups[1].Value) : 0;
	}

	static string Unescape(string text) => text.Replace("\\n", "\n").Replace("\\\"", "\"").Replace("\\'", "'").Replace("\\\\", "\\");
}

// One weapon or armor piece from Windower's resources.
sealed class ItemInfo
{
	public int Id { get; }

	// The short name, which is what //gs export prints.
	public string Name { get; }

	// The long name from the chat log. A set may give either one.
	public string LogName { get; }

	public string Category { get; }

	public int JobMask { get; }

	public int SlotMask { get; }

	public int Level { get; }

	// 0 below item level 119 gear.
	public int ItemLevel { get; }

	// The in-game help text, with its line breaks.
	public string Description { get; }

	public IReadOnlyList<string> Jobs => Enumerable.Range(1, 22).Where(bit => (JobMask & (1 << bit)) != 0).Select(bit => Resources.JobNames[bit]).ToList();

	public IReadOnlyList<string> Slots => Enumerable.Range(0, 16).Where(bit => (SlotMask & (1 << bit)) != 0).Select(bit => Resources.SlotNames[bit]).ToList();

	// One word for where the piece goes: both ears are "ear", both rings "ring", and a one-handed weapon "main".
	public string Group
	{
		get
		{
			if ((SlotMask & 3) != 0)
				return (SlotMask & 1) != 0 ? "main" : "sub";
			var first = Slots.FirstOrDefault() ?? "";
			return first.Replace("left_", "").Replace("right_", "");
		}
	}

	public ItemInfo(int id, string name, string logName, string category, int jobMask, int slotMask, int level, int itemLevel, string description)
	{
		Id = id;
		Name = name;
		LogName = logName;
		Category = category;
		JobMask = jobMask;
		SlotMask = slotMask;
		Level = level;
		ItemLevel = itemLevel;
		Description = description;
	}

	public bool WornBy(string job)
	{
		var bit = Resources.JobNames.ToList().IndexOf(job.ToUpperInvariant());
		return bit > 0 && (JobMask & (1 << bit)) != 0;
	}

	// Takes a slot under any of the names GearSwap accepts in a set: left_ear, ear1 and lear are one slot.
	public bool FitsSlot(string slot)
	{
		var bit = Resources.SlotNames.ToList().IndexOf(CanonicalSlot(slot));
		return bit >= 0 && (SlotMask & (1 << bit)) != 0;
	}

	public static string CanonicalSlot(string slot) => slot.ToLowerInvariant() switch
	{
		"ranged" => "range",
		"ear1" or "lear" or "learring" or "left_ear" => "left_ear",
		"ear2" or "rear" or "rearring" or "right_ear" => "right_ear",
		"ring1" or "lring" or "left_ring" => "left_ring",
		"ring2" or "rring" or "right_ring" => "right_ring",
		var other => other,
	};
}
