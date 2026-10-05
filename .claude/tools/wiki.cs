// Saves bg-wiki pages as wikitext under .claude/cache/wiki, one file a page, to read or grep afterwards.
//
//   dotnet run --no-cache .claude/tools/wiki.cs -- [--refresh] "<Title>" ["<Title>" ...]
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

Tool.Init();
var cli = new Arguments(args, [], ["--refresh"], takesWords: true);
if (cli.Words.Count == 0)
	Tool.Fail("Name at least one page: dotnet run --no-cache .claude/tools/wiki.cs -- \"Nyame Helm\"");
var dir = Tool.InCache("wiki");
Directory.CreateDirectory(dir);

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
return missing > 0 ? 1 : 0;
