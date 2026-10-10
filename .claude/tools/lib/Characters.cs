using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.IO;
using System.Text.RegularExpressions;

namespace GearTools;

// The characters here, and where each one's own documents are. What holds for any character is under docs/. What
// holds for one is in that character's folder under data/, linked from the gear list.
static class Characters
{
	// A character is a folder under data/ that holds its notes or its gear list. Folders of framework files alone, as
	// data/User is, aren't characters.
	public static IReadOnlyList<string> All()
	{
		var data = Tool.InRepo("data");
		if (Directory.Exists(data) is false)
			return [];
		return Directory.GetDirectories(data)
			.Where(folder => File.Exists(Notes(Path.GetFileName(folder))) || File.Exists(GearList(Path.GetFileName(folder))))
			.Select(folder => Path.GetFileName(folder))
			.Order(StringComparer.Ordinal)
			.ToList();
	}

	// A character's name as its folder under data/ spells it, whatever case it was given in. A name with no folder
	// stays as it was given.
	public static string Named(string name)
	{
		var data = Tool.InRepo("data");
		if (Directory.Exists(data) is false)
			return name;
		return Directory.GetDirectories(data)
			.Select(folder => Path.GetFileName(folder))
			.FirstOrDefault(folder => folder.Equals(name, StringComparison.OrdinalIgnoreCase)) ?? name;
	}

	// Every piece the sets wear and the sets that wear it. gear-list.cs checks it.
	public static string GearList(string character) => InFolder(character, "_gear_list.md");

	// The player's rules, merits and the like, and the Ranks table rank-doc.cs reads.
	public static string Notes(string character) => InFolder(character, "_notes.md");

	// Notes on the character's own copies, and the pieces bg-wiki's simulated sets wear that the character lacks.
	public static string GearNotes(string character) => InFolder(character, "_gear_notes.md");

	// The character's path and rank for each path item. rank-doc.cs writes it.
	public static string RankAugments(string character) => InFolder(character, "_rank_augments.md");

	static string InFolder(string character, string suffix) => Tool.InRepo("data", character, character + suffix);
}
