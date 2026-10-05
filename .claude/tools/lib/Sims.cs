using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.IO;
using System.Text.Encodings.Web;
using System.Text.Json;
using System.Text.RegularExpressions;

namespace GearTools;

// bg-wiki's simulated gear sets (All Jobs Gear Sets), read from the wikitext IzaKastra/bg_job_guides keeps for
// each job. fetch-sources.cs puts that repo in the cache.
static class Sims
{
	// The slots of an Equipment Set template, in the order the wiki draws them.
	public static IReadOnlyList<string> Slots { get; }

	static Sims()
	{
		Slots = ["Main", "Sub", "Range", "Ammo", "Head", "Neck", "Ear1", "Ear2", "Body", "Hands", "Ring1", "Ring2", "Back", "Waist", "Legs", "Feet"];
	}

	// Every simulated set on a job's page. One set name usually has several, one for each buff level.
	public static List<SimSet> Load(string job)
	{
		var path = Tool.InCache("bg_job_guides", job.ToLowerInvariant() + ".md");
		if (File.Exists(path) is false)
			Tool.Fail($"No simulated sets for {job} in .claude/cache/bg_job_guides. Run: dotnet run --no-cache .claude/tools/fetch-sources.cs");
		var sets = new List<SimSet>();
		var section = "";
		var setName = "";
		Dictionary<string, string>? fields = null;
		foreach (var raw in File.ReadLines(path))
		{
			var line = raw.Trim();
			var heading = Regex.Match(line, @"^(=+)\s*(.*?)\s*=+$");
			var name = Regex.Match(line, @"^\|Set Name\s*=(.*)$");
			var field = Regex.Match(line, @"^\|\s*(\w+)\s*=(.*)$");
			if (heading.Success)
			{
				section = Clean(heading.Groups[2].Value);
			}
			else if (name.Success)
			{
				setName = Clean(name.Groups[1].Value);
			}
			else if (line.StartsWith("Equipment Set"))
			{
				fields = [];
			}
			else if (fields is not null && field.Success)
			{
				fields[field.Groups[1].Value] = Clean(field.Groups[2].Value);
			}
			else if (fields is not null && line.StartsWith("}}"))
			{
				// A template with no slot filled is a layout shell, not a set.
				if (Slots.Any(slot => fields.GetValueOrDefault(slot, "").Length > 0))
					sets.Add(new SimSet(section, setName, fields));
				fields = null;
			}
		}
		return sets;
	}

	// The item a slot names, without the stage the page adds to an upgraded weapon: "Tizona (Level 119 III)".
	public static string ItemName(string slotValue) => Regex.Replace(slotValue, @"\s*\(Level [^)]*\)", "").Trim();

	public static string ToJson(IEnumerable<SimSet> sets) =>
		JsonSerializer.Serialize(sets.Select(set => new SetJson(set)), new JsonSerializerOptions { WriteIndented = true, Encoder = JavaScriptEncoder.UnsafeRelaxedJsonEscaping });

	// Wiki links become their label, and the footnote star after a name goes.
	static string Clean(string text) => Regex.Replace(Regex.Replace(text, @"\[\[(?:[^\]|]*\|)?([^\]]*)\]\]", "$1"), @"\s+", " ").Trim().TrimEnd('*').Trim();

	sealed class SetJson
	{
		public string Section { get; }

		public string Name { get; }

		public string CaptionTop { get; }

		public string CaptionBottom { get; }

		public IReadOnlyDictionary<string, string> Items { get; }

		public IReadOnlyDictionary<string, string> Augments { get; }

		public SetJson(SimSet set)
		{
			Section = set.Section;
			Name = set.Name;
			CaptionTop = set.CaptionTop;
			CaptionBottom = set.CaptionBottom;
			Items = set.Items;
			Augments = set.Augments;
		}
	}
}

// One simulated set: a weapon skill, spell or TP set at one buff level.
sealed class SimSet
{
	// The page section the set is under.
	public string Section { get; }

	// The set's name, such as "Savage Blade". Sets for several buff levels share it.
	public string Name { get; }

	// The buff level or condition, such as "Mid buff".
	public string CaptionTop { get; }

	// The result the page quotes, such as "54330 damage".
	public string CaptionBottom { get; }

	// Slot to item, for the slots the set fills. Keys are the names in Sims.Slots.
	public IReadOnlyDictionary<string, string> Items { get; }

	// Slot to the augment note the page gives for that slot's piece, where it gives one.
	public IReadOnlyDictionary<string, string> Augments { get; }

	public SimSet(string section, string name, Dictionary<string, string> fields)
	{
		Section = section;
		Name = name;
		CaptionTop = fields.GetValueOrDefault("CaptionTop", "");
		CaptionBottom = fields.GetValueOrDefault("CaptionBottom", "");
		Items = Sims.Slots.Where(slot => fields.GetValueOrDefault(slot, "").Length > 0).ToDictionary(slot => slot, slot => fields[slot]);
		Augments = fields.Where(pair => pair.Key.EndsWith("Aug") && pair.Value.Length > 0).ToDictionary(pair => pair.Key[..^3], pair => pair.Value);
	}
}
