// Saves bg-wiki pages as wikitext under docs/wiki/pages, one file a page, to read or grep afterwards, and keeps the
// title each was saved under in titles.txt there, since a file's name can't always be read back as its title.
//
//   dotnet run .claude/gear.cs -- wiki [--refresh] "<Title>" ["<Title>" ...]
//
// A title is the page name as in its URL or with spaces: "Nyame_Helm" or "Nyame Helm", "Category:Enspell".
// A page already saved is left alone unless --refresh is given. Exit code 1 when a page doesn't exist.
using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.IO;
using System.Text.RegularExpressions;
using GearTools;

var cli = new Arguments(args, [], ["--refresh"], takesWords: true);
if (cli.Words.Count == 0)
	Tool.Fail("Name at least one page: dotnet run .claude/gear.cs -- wiki \"Nyame Helm\"");
var dir = Tool.InRepo("docs", "wiki", "pages");
Directory.CreateDirectory(dir);
var titlesFile = Path.Combine(dir, "titles.txt");
var titles = new SortedSet<string>(File.Exists(titlesFile) ? File.ReadAllLines(titlesFile).Where(line => line.Length > 0) : [], StringComparer.Ordinal);

// Characters Windows won't take in a file name, and the space, become underscores.
string FileFor(string title) => Path.Combine(dir, Regex.Replace(title, "[ :/\\\\?*\"<>|]", "_") + ".txt");

var wanted = cli.Words.Where(title => cli.Flag("--refresh") || File.Exists(FileFor(title)) is false).ToList();
var pages = wanted.Count > 0 ? await Wiki.Fetch(wanted) : [];
var missing = 0;
foreach (var title in cli.Words)
{
	var file = FileFor(title);
	if (pages.TryGetValue(title, out var page))
	{
		File.WriteAllText(file, page.Text);
		titles.Add(title);
		var redirect = page.Title.Replace('_', ' ') == title.Replace('_', ' ') ? "" : $" (the page is \"{page.Title}\")";
		Console.WriteLine($"saved   {Tool.RepoRelative(file)} ({page.Text.Length} chars){redirect}");
	}
	else if (wanted.Contains(title))
	{
		missing++;
		Console.WriteLine($"MISSING {title}: bg-wiki has no page by that name");
	}
	else
	{
		Console.WriteLine($"cached  {Tool.RepoRelative(file)} ({new FileInfo(file).Length} bytes, from {File.GetLastWriteTime(file):yyyy-MM-dd})");
	}
}
if (titles.Count > 0)
	File.WriteAllText(titlesFile, string.Join("", titles.Select(title => title + "\n")));
return missing > 0 ? 1 : 0;
