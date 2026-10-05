using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.IO;
using System.Text.RegularExpressions;

namespace GearTools;

// Reads the files //gs export writes into data/export: every item a character holds, bag by bag.
static class Export
{
	// The bags GearSwap can equip from. A piece anywhere else has to be moved before a set can wear it.
	public static IReadOnlyList<string> EquippableBags { get; }

	static Regex fileName;
	static Regex bagLine;
	static Regex itemLine;
	static Regex augmentList;
	static Regex quoted;

	static Export()
	{
		EquippableBags = ["inventory", "wardrobe", "wardrobe2", "wardrobe3", "wardrobe4", "wardrobe5", "wardrobe6", "wardrobe7", "wardrobe8"];
		fileName = new Regex(@"^(?<who>.+?)[ _](?<stamp>\d{4}-\d{2}-\d{2}[ _]\d{2}-\d{2}-\d{2})\.lua$");
		bagLine = new Regex(@"^    (\w+) = \{\s*$");
		itemLine = new Regex(@"^\s+(\w+)=(?:""((?:[^""\\]|\\.)*)""|\{ name=""((?:[^""\\]|\\.)*)""(.*)\}),?\s*$");
		augmentList = new Regex(@"augments=\{(.*?)\}");
		quoted = new Regex(@"'((?:[^'\\]|\\.)*)'");
	}

	// The export a tool should read: the one named with --export, or the newest one for the character.
	public static string Resolve(Arguments cli)
	{
		var given = cli.Option("--export");
		if (given is null)
			return Latest(cli.Option("--char"));
		if (File.Exists(given) is false)
			Tool.Fail($"No export at {given}.");
		return Path.GetFullPath(given);
	}

	// The newest export, by the time in its file name. //gs export has written both "Vanar 2026-10-01 20-15-33.lua"
	// and "Vanar_2026-09-27_18-24-29.lua", so the names themselves don't sort by date.
	public static string Latest(string? character)
	{
		var dir = Tool.InRepo("data", "export");
		var dated = Directory.GetFiles(dir, "*.lua")
			.Select(path => new DatedExport(path, fileName.Match(Path.GetFileName(path))))
			.Where(export => export.Name.Success)
			.ToList();
		var characters = dated.Select(export => export.Character).Distinct(StringComparer.OrdinalIgnoreCase).ToList();
		if (character is null && characters.Count != 1)
			Tool.Fail($"data/export holds exports for {characters.Count} characters ({string.Join(", ", characters)}). Pass --char <name>.");
		character ??= characters[0];
		var newest = dated.Where(export => export.Character.Equals(character, StringComparison.OrdinalIgnoreCase))
			.OrderBy(export => export.Stamp, StringComparer.Ordinal)
			.LastOrDefault();
		if (newest is null)
			Tool.Fail($"No export for {character} in data/export.");
		return newest.Path;
	}

	// The characters data/export holds an export for.
	public static IReadOnlyList<string> Owners() => Directory.GetFiles(Tool.InRepo("data", "export"), "*.lua")
		.Select(path => fileName.Match(Path.GetFileName(path)))
		.Where(name => name.Success)
		.Select(name => name.Groups["who"].Value)
		.Distinct(StringComparer.OrdinalIgnoreCase)
		.Order(StringComparer.Ordinal)
		.ToList();

	// The character an export belongs to, from its file name.
	public static string CharacterOf(string exportPath) => NameOf(exportPath).Groups["who"].Value;

	// The date in an export's file name, as yyyy-MM-dd.
	public static string DateOf(string exportPath) => NameOf(exportPath).Groups["stamp"].Value[..10];

	// Every line of an export, bag by bag. With the Rahvin engine loaded, //gs export all writes one table for each
	// bag and then one for each storage slip (slip1 to slip33), holding the items a porter moogle keeps on it.
	public static List<ExportItem> Read(string path)
	{
		var items = new List<ExportItem>();
		var bag = "";
		foreach (var line in File.ReadLines(path))
		{
			var header = bagLine.Match(line);
			if (header.Success)
			{
				bag = header.Groups[1].Value;
				continue;
			}
			var entry = itemLine.Match(line);
			if (entry.Success is false)
				continue;
			var name = entry.Groups[2].Success ? entry.Groups[2].Value : entry.Groups[3].Value;
			var augments = augmentList.Match(entry.Groups[4].Value);
			var list = augments.Success
				? quoted.Matches(augments.Groups[1].Value).Select(match => Unescape(match.Groups[1].Value)).ToList()
				: [];
			items.Add(new ExportItem(bag, entry.Groups[1].Value, Unescape(name), list));
		}
		return items;
	}

	static Match NameOf(string exportPath)
	{
		var name = fileName.Match(Path.GetFileName(exportPath));
		if (name.Success is false)
			Tool.Fail($"{Path.GetFileName(exportPath)} isn't named like a //gs export (<character> <date> <time>.lua).");
		return name;
	}

	static string Unescape(string text) => text.Replace("\\\"", "\"").Replace("\\'", "'").Replace("\\\\", "\\");

	sealed class DatedExport
	{
		public string Path { get; }

		public Match Name { get; }

		public string Character => Name.Groups["who"].Value;

		// The two spellings of the stamp differ only in their separators.
		public string Stamp => Name.Groups["stamp"].Value.Replace('_', ' ');

		public DatedExport(string path, Match name)
		{
			Path = path;
			Name = name;
		}
	}
}

// One line of an export: an item, the bag it is in, and the key GearSwap printed it under.
sealed class ExportItem
{
	// The bag as Windower names it, or slip<N> for an item stored on storage slip N. Empty for the exports written
	// before bags were listed.
	public string Bag { get; }

	// "item" for anything that can't be worn; otherwise a slot, though not always the only one the piece fits.
	public string SlotKey { get; }

	public string Name { get; }

	// As printed, in order. A job file names one copy of several by repeating this list exactly.
	public IReadOnlyList<string> Augments { get; }

	public string AugmentText => string.Join(", ", Augments);

	public bool CanBeEquippedFromBag => Bag.Length == 0 || Export.EquippableBags.Contains(Bag);

	// The number of the storage slip the item is stored on, or 0 when it is in a bag. A slip holds no augments, so
	// an item on one never carries any.
	public int Slip => Bag.StartsWith("slip") && int.TryParse(Bag[4..], out var number) ? number : 0;

	public ExportItem(string bag, string slotKey, string name, IReadOnlyList<string> augments)
	{
		Bag = bag;
		SlotKey = slotKey;
		Name = name;
		Augments = augments;
	}
}
