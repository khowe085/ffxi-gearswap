// Reads bg-wiki's rank-by-rank augment tables ({{Augment Rank Table}}) for every item in the newest export of each
// character, and saves them to .claude/cache/ranks/ranks.json for rank-doc.cs.
//
//   dotnet run --no-cache .claude/tools/rank-tables.cs
//
// Run it after an export that adds a rank-augmented item, or to pick up a change on bg-wiki. It replaces the saved
// tables and stamps them with today's date, which rank-doc.cs then prints as the day they were read.
using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using GearTools;

Tool.Init();
new Arguments(args, [], []);
var exports = Export.Owners().Select(Export.Latest).ToList();
var names = exports.SelectMany(Export.Read).Where(line => line.SlotKey != "item").Select(line => line.Name).Distinct().ToList();
var pages = await Wiki.Fetch(names);

var items = new List<RankedItem>();
foreach (var name in names.Where(pages.ContainsKey))
{
	RankedItem? item = null;
	try
	{
		item = RankTableParser.Parse(name, pages[name]);
	}
	catch (InvalidOperationException problem)
	{
		// The saved tables stay as they were.
		Tool.Fail(problem.Message);
	}
	if (item is not null)
		items.Add(item);
}

new RankTables(DateTime.Today.ToString("yyyy-MM-dd"), items).Save();
Console.WriteLine($"{items.Count} items with rank tables, from {string.Join(", ", exports.Select(Tool.RepoRelative))}: {string.Join(", ", items.Select(item => item.Name))}");
var unread = names.Where(name => pages.ContainsKey(name) is false).ToList();
if (unread.Count > 0)
	Console.WriteLine($"No bg-wiki page under the export's name for: {string.Join(", ", unread)}");
