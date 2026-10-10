using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.IO;
using System.Text.RegularExpressions;

namespace GearTools;

// A character's rank file, data/<Character>/<Character>_rank_augments.md, as rank-doc.cs writes it: for each path item,
// the path and rank of the copy the export prints and the augments that rank gives.
static class RankAugments
{
	// The rows of the table under "| Item | Slot | Path | Rank | Given | Augments at that rank |", by the item name the
	// export prints, and the rows of the table of the items Oboro ranks up. bg-wiki gives an Oboro item's augments at
	// its maximum rank only; they are read from tablesPath, docs/rank-augments.md, when it is given.
	public static Dictionary<string, RankedCopy> Read(string path, string? tablesPath = null)
	{
		var atMaxRank = tablesPath is null ? [] : Table(tablesPath, "| Item | Slot | Max rank | Augments at max rank |")
			.ToDictionary(cells => cells[0], cells => Regex.Replace(cells[3], @"\s*\(\[bg-wiki\]\(.*$", ""), StringComparer.OrdinalIgnoreCase);
		var rows = new Dictionary<string, RankedCopy>(StringComparer.OrdinalIgnoreCase);
		foreach (var cells in Table(path, "| Item | Slot | Path | Rank | Given | Augments at that rank |"))
			rows[Regex.Match(cells[0], @"^\[(.+?)\]").Groups[1].Value] = new RankedCopy(cells[2], cells[3], cells[5], null);
		foreach (var cells in Table(path, "| Item | Slot | Max rank |"))
		{
			// rank-doc.cs writes the copy as "`'Path: A'`, rank 20 (2026-10-05)", "no augments: rank 0, ..." and the like.
			var rank = Regex.Match(cells[3], @"rank (\d+|unknown)") is { Success: true } found ? found.Groups[1].Value : "unknown";
			rows[cells[0]] = new RankedCopy("", rank, atMaxRank.GetValueOrDefault(cells[0]) ?? "", cells[2]);
		}
		return rows;
	}

	// The rows of the table whose header line starts with header, split into cells.
	static IEnumerable<List<string>> Table(string path, string header)
	{
		var inTable = false;
		foreach (var line in File.ReadLines(path))
		{
			if (line.StartsWith(header))
			{
				inTable = true;
				continue;
			}
			if (inTable is false || line.StartsWith("|---"))
				continue;
			if (line.StartsWith('|') is false)
				yield break;
			// rank-doc.cs writes a "|" inside a cell as "\|".
			yield return Regex.Split(line.Trim().Trim('|'), @"(?<!\\)\|").Select(cell => cell.Trim().Replace("\\|", "|")).ToList();
		}
	}
}

// One row of the rank file.
sealed class RankedCopy
{
	public string Path { get; }

	// A number, or "unknown" when the player hasn't given it.
	public string Rank { get; }

	// The augments at that rank, as the rank file writes them, comma separated. For an item Oboro ranks up, the ones at
	// its maximum rank.
	public string Augments { get; }

	// The maximum rank of an item Oboro ranks up; null for any other.
	public string? MaxRank { get; }

	public RankedCopy(string path, string rank, string augments, string? maxRank)
	{
		Path = path;
		Rank = rank;
		Augments = augments;
		MaxRank = maxRank;
	}
}
