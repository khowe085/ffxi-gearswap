// Shows bg-wiki's simulated gear sets for a job (All Jobs Gear Sets, from IzaKastra/bg_job_guides) and marks which
// pieces the character owns. The sets assume Odyssey gear at rank 30 and Nyame Path B at rank 25, so a piece owned
// at a lower rank is worth less than its place in a set suggests (docs/ffxi-mechanics.md, Simulated sets).
//
//   dotnet run --no-cache .claude/tools/sims.cs -- --job rdm                        the sets on the page
//   dotnet run --no-cache .claude/tools/sims.cs -- --job rdm --set "savage blade"   those sets, slot by slot
//   dotnet run --no-cache .claude/tools/sims.cs -- --job rdm --counts [--set ...]   how often each piece fills a slot
//   dotnet run --no-cache .claude/tools/sims.cs -- --job rdm --json                 everything, for another tool
//
// --set matches any set whose name contains the text, ignoring case. Also takes --char <name> and --export <path>.
using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using GearTools;

Tool.Init();
var cli = new Arguments(args, ["--job", "--set", "--char", "--export"], ["--counts", "--json"]);
var job = cli.Option("--job");
if (job is null)
	Tool.Fail("Name the job: --job rdm");
var sets = Sims.Load(job);
if (sets.Count == 0)
	Tool.Fail($"The {job} page in .claude/cache/bg_job_guides holds no simulated set.");
var filter = cli.Option("--set");
if (filter is not null)
	sets = sets.Where(set => set.Name.Contains(filter, StringComparison.OrdinalIgnoreCase)).ToList();
if (sets.Count == 0)
	Tool.Fail($"No set on the {job} page has \"{filter}\" in its name.");

var exportPath = Export.Resolve(cli);
var owned = Export.Read(exportPath).Where(line => line.SlotKey != "item").ToList();
var resources = Resources.Load();

// The page names a piece by its short name or its long one; the export only prints the short one.
string? OwnedAs(string slotValue)
{
	var name = Sims.ItemName(slotValue);
	var names = resources.Named(name).Select(item => item.Name).Append(name).ToHashSet(StringComparer.OrdinalIgnoreCase);
	return owned.FirstOrDefault(line => names.Contains(line.Name))?.Name;
}

string Mark(string slotValue)
{
	var name = OwnedAs(slotValue);
	if (name is null)
		return "  MISSING";
	var copies = owned.Where(line => line.Name == name).ToList();
	return copies.All(line => line.Slip > 0) ? $"  (on slip {copies[0].Slip})" : "";
}

if (cli.Flag("--json"))
{
	Console.WriteLine(Sims.ToJson(sets));
}
else if (cli.Flag("--counts"))
{
	foreach (var level in sets.GroupBy(set => set.CaptionTop))
	{
		Console.WriteLine($"== {level.Key}: {level.Count()} sets ({string.Join(", ", level.Select(set => set.Name).Distinct())})");
		foreach (var slot in Sims.Slots)
		{
			var pieces = level.Where(set => set.Items.ContainsKey(slot))
				.GroupBy(set => set.Items[slot] + (set.Augments.TryGetValue(slot, out var augment) ? $" [{augment}]" : ""))
				.OrderByDescending(group => group.Count())
				.Select(group => $"{group.Key} {group.Count()}{Mark(group.First().Items[slot]).TrimEnd()}");
			Console.WriteLine($"  {slot,-6} {string.Join("; ", pieces)}");
		}
	}
}
else if (filter is null)
{
	foreach (var section in sets.GroupBy(set => set.Section))
	{
		Console.WriteLine($"== {section.Key}");
		foreach (var name in section.GroupBy(set => set.Name))
			Console.WriteLine($"  {name.Key}: {string.Join("; ", name.Select(set => $"{set.CaptionTop} ({set.CaptionBottom})"))}");
	}
}
else
{
	foreach (var set in sets)
	{
		Console.WriteLine($"== {set.Name}, {set.CaptionTop}: {set.CaptionBottom}");
		foreach (var slot in Sims.Slots.Where(set.Items.ContainsKey))
			Console.WriteLine($"  {slot,-6} {set.Items[slot]}{(set.Augments.TryGetValue(slot, out var augment) ? $" [{augment}]" : "")}{Mark(set.Items[slot])}");
	}
}
