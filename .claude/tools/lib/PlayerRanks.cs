using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.IO;
using System.Text.RegularExpressions;

namespace GearTools;

// The ranks the player has given for a character's path items. //gs export never prints a rank, so they are kept
// in a table under "## Ranks" in the character's notes file, one row an item:
//
//   | Item | Path | Rank | Given |
//   |---|---|---|---|
//   | Nyame Helm | B | 11 | 2026-10-04 |
static class PlayerRanks
{
	// By the name the export prints. Empty when there is no notes file, or it has no Ranks section. A row that
	// can't be read throws InvalidOperationException with its file and line.
	public static Dictionary<string, PlayerRank> Read(string notesPath)
	{
		var ranks = new Dictionary<string, PlayerRank>();
		if (File.Exists(notesPath) is false)
			return ranks;
		var lines = File.ReadAllLines(notesPath);
		var start = Array.FindIndex(lines, line => line.Trim() == "## Ranks");
		if (start < 0)
			return ranks;
		for (var i = start + 1; i < lines.Length && lines[i].StartsWith("## ") is false; i++)
		{
			if (lines[i].StartsWith('|') is false)
				continue;
			var cells = lines[i].Trim().Trim('|').Split('|').Select(cell => cell.Trim()).ToArray();
			if (cells[0] == "Item" || Markdown.IsDelimiterRow(lines[i]))
				continue;
			var where = $"{Tool.RepoRelative(notesPath)}:{i + 1}";
			if (cells.Length != 4)
				throw new InvalidOperationException($"{where}: a Ranks row has four cells: Item, Path, Rank, Given.");
			if (int.TryParse(cells[2], out var rank) is false || rank < 0)
				throw new InvalidOperationException($"{where}: \"{cells[2]}\" isn't a rank.");
			if (Regex.IsMatch(cells[3], @"^\d{4}-\d{2}-\d{2}$") is false)
				throw new InvalidOperationException($"{where}: \"{cells[3]}\" isn't a day, written as in 2026-10-04.");
			if (ranks.ContainsKey(cells[0]))
				throw new InvalidOperationException($"{where}: a second row for {cells[0]}.");
			ranks[cells[0]] = new PlayerRank(cells[1], rank, cells[3]);
		}
		return ranks;
	}
}

sealed class PlayerRank
{
	public string Path { get; }

	public int Rank { get; }

	// yyyy-MM-dd.
	public string Given { get; }

	public PlayerRank(string path, int rank, string given)
	{
		Path = path;
		Rank = rank;
		Given = given;
	}
}
