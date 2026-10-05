// Checks every gear.<key> a job file wears against the character's //gs export and Windower's resources: that the
// key is defined, the item exists and is owned with those augments, the job can wear it, it fits the slot the set
// puts it in, and a copy sits in a bag GearSwap can equip from. Gear on a storage slip counts as owned,
// but has to come back from a porter moogle before a set can wear it.
//
//   dotnet run --no-cache .claude/tools/check-export.cs [-- --job BLU,RDM] [--char <name>] [--export <path>]
//
// Exit code 1 when it finds an error. Warnings (a piece that has to be moved to a wardrobe, an entry no set wears)
// don't change the exit code.
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
var cli = new Arguments(args, ["--job", "--char", "--export"], []);
var exportPath = Export.Resolve(cli);
var character = Characters.Named(cli.Option("--char") ?? Export.CharacterOf(exportPath));
var owned = Export.Read(exportPath);
var resources = Resources.Load();
var files = GearFiles.Load(character);
if (files.Jobs.Count == 0)
	Tool.Fail($"data/{character} holds no job file to check. A job file is named for its job, as RDM.lua is.");

Console.WriteLine($"Export: {Tool.RepoRelative(exportPath)}");
var errors = 0;
var warnings = 0;
foreach (var job in files.Select(cli.Option("--job")))
{
	var file = files.Jobs[job];
	var defs = files.DefsFor(job);
	Console.WriteLine($"{file.FileName}: {file.ReferencedKeys.Count} keys");
	// A job file's opening comment names the export its pieces were taken from.
	var named = Regex.Match(string.Join("\n", File.ReadLines(file.Path).Take(20)), @"data/export/(.+?\.lua)");
	if (named.Success && named.Groups[1].Value != Path.GetFileName(exportPath))
		Warn($"{file.FileName}'s header names the export {named.Groups[1].Value}, and this check read {Path.GetFileName(exportPath)}. Update the header once the file passes");
	foreach (var key in file.ReferencedKeys.Order(StringComparer.Ordinal))
	{
		var uses = file.Uses.Where(use => use.Key == key).ToList();
		var where = uses.Count == 0 ? "" : $" (line {uses[0].Line}, {uses[0].SetName})";
		if (defs.TryGetValue(key, out var def) is false)
		{
			Error($"gear.{key}{where}: not defined in {file.FileName}, the globals or the library, so the slot gets nothing");
			continue;
		}
		var items = resources.Named(def.Name);
		if (items.Count == 0)
		{
			Error($"gear.{key} -> \"{def.Name}\": no weapon or armor has that name or log name, so GearSwap equips nothing and says nothing");
			continue;
		}
		// The export prints the short name, whichever name the entry uses.
		var copies = owned.Where(copy => items.Any(item => item.Name.Equals(copy.Name, StringComparison.OrdinalIgnoreCase))).ToList();
		if (copies.Count == 0)
		{
			Error($"gear.{key} -> \"{def.Name}\": not in the export");
			continue;
		}
		var matching = copies.Where(def.Matches).ToList();
		if (matching.Count == 0)
		{
			Error($"gear.{key} -> \"{def.Name}\": augments [{def.AugmentText}] match no copy. The export has: {string.Join(" | ", copies.Select(copy => $"[{copy.AugmentText}]"))}");
			continue;
		}
		if (items.Any(item => item.WornBy(job)) is false)
			Error($"gear.{key} -> \"{def.Name}\": {job} can't wear it (jobs: {string.Join(" ", items[0].Jobs)})");
		foreach (var use in uses.Where(use => items.Any(item => item.FitsSlot(use.Slot)) is false))
			Error($"gear.{key} -> \"{def.Name}\": {use.SetName} puts it in {use.Slot}, but it goes in {string.Join(" or ", items[0].Slots)} (line {use.Line})");
		if (def.Bag is not null && matching.Any(copy => copy.Bag == def.Bag) is false)
		{
			Error($"gear.{key} -> \"{def.Name}\": pinned to {def.Bag}, but the matching copies are in {Bags(matching)}");
		}
		else if (matching.All(copy => copy.Slip > 0))
		{
			Warn($"gear.{key} -> \"{def.Name}\": only on storage slip {matching[0].Slip}. Get it back from a porter moogle and put it in a wardrobe before a set can wear it");
		}
		else if (matching.Any(copy => copy.CanBeEquippedFromBag) is false)
		{
			Warn($"gear.{key} -> \"{def.Name}\": only in {Bags(matching)}. GearSwap equips from the inventory and the wardrobes, so move it");
		}
	}
	foreach (var def in file.Defs.Where(def => file.ReferencedKeys.Contains(def.Key) is false))
		Warn($"gear.{def.Key} -> \"{def.Name}\": defined at {file.FileName}:{def.Line} but nothing in the file wears it");
	foreach (var line in file.DirectSlotValues)
		Warn($"{line}: a slot filled without a gear.<key> entry, so it carries no swap priority");
	foreach (var line in file.LooseReferences)
		Console.WriteLine($"  note  {line}: gear.<key> outside a \"slot = gear.<key>\" pair; not checked for slot");
}
Console.WriteLine($"problems: {errors} errors, {warnings} warnings");
return errors > 0 ? 1 : 0;

void Error(string message)
{
	errors++;
	Console.WriteLine("  ERROR " + message);
}

void Warn(string message)
{
	warnings++;
	Console.WriteLine("  warn  " + message);
}

string Bags(List<ExportItem> copies) => string.Join(", ", copies.Select(copy => copy.Bag.Length == 0 ? "an unnamed bag" : copy.Bag).Distinct());
