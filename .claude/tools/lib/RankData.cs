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

// bg-wiki's rank-by-rank augment tables for the rank-augmented items in the exports. rank-tables.cs writes them to
// .claude/cache/ranks/ranks.json and rank-doc.cs renders the rank documents from that file.
sealed class RankTables
{
	// The day the tables were read from bg-wiki, as yyyy-MM-dd.
	public string Fetched { get; }

	public IReadOnlyList<RankedItem> Items { get; }

	static string FilePath => Tool.InCache("ranks", "ranks.json");

	public RankTables(string fetched, IReadOnlyList<RankedItem> items)
	{
		Fetched = fetched;
		Items = items;
	}

	public static RankTables Load()
	{
		if (File.Exists(FilePath) is false)
			Tool.Fail("bg-wiki's rank tables aren't in .claude/cache. Run: dotnet run --no-cache .claude/tools/rank-tables.cs");
		var file = JsonSerializer.Deserialize<FileJson>(File.ReadAllText(FilePath))!;
		return new RankTables(file.Fetched, file.Items.Select(item => new RankedItem(item.Name, item.Title, item.RankMax,
			item.Paths.Select(path => new RankPath(path.Path, path.Ranks.Select(row => new RankRow(row.Rank, row.Augments)).ToList())).ToList())).ToList());
	}

	public void Save()
	{
		var file = new FileJson
		{
			Fetched = Fetched,
			Items = Items.Select(item => new ItemJson
			{
				Name = item.Name,
				Title = item.Title,
				RankMax = item.RankMax,
				Paths = item.Paths.Select(path => new PathJson
				{
					Path = path.Path,
					Ranks = path.Ranks.Select(row => new RowJson { Rank = row.Rank, Augments = row.Augments.ToList() }).ToList(),
				}).ToList(),
			}).ToList(),
		};
		Directory.CreateDirectory(Path.GetDirectoryName(FilePath)!);
		File.WriteAllText(FilePath, JsonSerializer.Serialize(file, new JsonSerializerOptions { WriteIndented = true, Encoder = JavaScriptEncoder.UnsafeRelaxedJsonEscaping }));
	}

	// The shape of ranks.json.
	sealed class FileJson
	{
		public string Fetched { get; set; }

		public List<ItemJson> Items { get; set; }

		public FileJson()
		{
			Fetched = "";
			Items = [];
		}
	}

	sealed class ItemJson
	{
		public string Name { get; set; }

		public string Title { get; set; }

		public int RankMax { get; set; }

		public List<PathJson> Paths { get; set; }

		public ItemJson()
		{
			Name = "";
			Title = "";
			Paths = [];
		}
	}

	sealed class PathJson
	{
		public string Path { get; set; }

		public List<RowJson> Ranks { get; set; }

		public PathJson()
		{
			Path = "";
			Ranks = [];
		}
	}

	sealed class RowJson
	{
		public int Rank { get; set; }

		public List<string> Augments { get; set; }

		public RowJson()
		{
			Augments = [];
		}
	}
}

// One item with a rank table.
sealed class RankedItem
{
	// The name as the export prints it.
	public string Name { get; }

	// The bg-wiki page the table came from.
	public string Title { get; }

	public int RankMax { get; }

	public IReadOnlyList<RankPath> Paths { get; }

	public RankedItem(string name, string title, int rankMax, IReadOnlyList<RankPath> paths)
	{
		Name = name;
		Title = title;
		RankMax = rankMax;
		Paths = paths;
	}
}

// One augment path of an item, with a row for every rank.
sealed class RankPath
{
	// A letter, or empty for an item with a single unnamed path.
	public string Path { get; }

	public IReadOnlyList<RankRow> Ranks { get; }

	public RankPath(string path, IReadOnlyList<RankRow> ranks)
	{
		Path = path;
		Ranks = ranks;
	}
}

// The whole augment at one rank: four lines, empty where a line hasn't unlocked yet.
sealed class RankRow
{
	public int Rank { get; }

	public IReadOnlyList<string> Augments { get; }

	public RankRow(int rank, IReadOnlyList<string> augments)
	{
		Rank = rank;
		Augments = augments;
	}
}

// Reads the {{Augment Rank Table}} template on an item's bg-wiki page.
static class RankTableParser
{
	// The item's rank table, or null when its page has none. A page whose table has no path, or a path with no
	// rows, isn't laid out the way this reads it, and throws InvalidOperationException rather than give an empty table.
	public static RankedItem? Parse(string name, WikiPage page)
	{
		if (page.Text.Contains("{{Augment Rank Table") is false)
			return null;
		var rankMax = Regex.Match(page.Text, @"\|RankMax=(\d+)");
		var paths = new List<RankPath>();
		List<RankRow>? rows = null;
		var rank = -1;
		string[] augments = ["", "", "", ""];
		foreach (var raw in page.Text.Split('\n'))
		{
			var line = raw.Trim();
			var path = Regex.Match(line, @"^\|Path=(.*)$");
			var rankStart = Regex.Match(line, @"^\|Rank=(\d+)$");
			var augment = Regex.Match(line, @"^\|Augment(\d)=(.*)$");
			if (path.Success)
			{
				rows = [];
				paths.Add(new RankPath(path.Groups[1].Value.Trim(), rows));
			}
			else if (rankStart.Success)
			{
				rank = int.Parse(rankStart.Groups[1].Value);
				augments = ["", "", "", ""];
			}
			else if (augment.Success && rank >= 0)
			{
				// The wiki writes "---" for a line that hasn't unlocked at this rank.
				var value = augment.Groups[2].Value.Trim();
				augments[int.Parse(augment.Groups[1].Value) - 1] = value.StartsWith("---") ? "" : value;
			}
			else if (line.StartsWith("}}") && rank >= 0 && rows is not null)
			{
				// A row carries three or four augment lines, so it ends at its closing braces, not at a line count.
				rows.Add(new RankRow(rank, augments));
				rank = -1;
			}
		}
		if (paths.Count == 0 || paths.Any(path => path.Ranks.Count == 0))
			throw new InvalidOperationException($"bg-wiki's {page.Title} page has an Augment Rank Table, but not every path's rows could be read from it. The page's layout may have changed.");
		return new RankedItem(name, page.Title, rankMax.Success ? int.Parse(rankMax.Groups[1].Value) : 0, paths);
	}
}
