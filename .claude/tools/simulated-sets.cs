// Writes bg-wiki's simulated gear sets (All Jobs Gear Sets) into docs/wiki/simulated-sets, one file a job, from
// IzaKastra/bg_job_guides, which keeps the wiki markup of each job's page as a backup, at the commit
// docs/ffxi-mechanics.md cites. A job the repository no longer has a page for is dropped.
//
//   dotnet run .claude/gear.cs -- simulated-sets
//
// The files keep the page's wikitext as it is, under .txt, so doc-lint doesn't read them as docs.
using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.IO;
using System.Text.RegularExpressions;
using GearTools;

new Arguments(args, [], []);
var commit = Sources.Pin("bg_job_guides").Commit[..7];
var checkout = Sources.Checkout("bg_job_guides");
List<(string Job, byte[] Text)> pages;
try
{
	// A job's page is named for the job; the README and the main page beside them aren't a job's.
	var jobPage = new Regex(@"^[a-z]{3}\.md$");
	pages = Directory.GetFiles(checkout, "*.md")
		.Where(file => jobPage.IsMatch(Path.GetFileName(file)))
		.Order(StringComparer.Ordinal)
		.Select(file => (Path.GetFileNameWithoutExtension(file), File.ReadAllBytes(file)))
		.ToList();
}
finally
{
	Sources.RemoveCheckout(checkout);
}
if (pages.Count == 0)
	Tool.Fail($"bg_job_guides has no job's page at {commit}.");
var target = Tool.InRepo("docs", "wiki", "simulated-sets");
var written = pages.Select(page => Path.Combine(target, page.Job + ".txt")).ToHashSet(StringComparer.Ordinal);
try
{
	Directory.CreateDirectory(target);
	foreach (var page in pages)
		File.WriteAllBytes(Path.Combine(target, page.Job + ".txt"), page.Text);
	// Only once every page is written, so a write that fails leaves no job without one.
	foreach (var gone in Directory.GetFiles(target, "*.txt").Where(file => written.Contains(file) is false))
		File.Delete(gone);
}
catch (Exception problem) when (problem is IOException or UnauthorizedAccessException)
{
	Tool.Fail($"{Tool.RepoRelative(target)}: couldn't write it. {problem.Message}");
}
Console.WriteLine($"{pages.Count} jobs' simulated sets from bg_job_guides at {commit} in {Tool.RepoRelative(target)}");
