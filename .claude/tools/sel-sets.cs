// Reads a Selindrile gear file, data/<Character>/<Character>_<Job>_Gear.lua, into a sets file: the JSON (lib/Dto.cs)
// that check-export, check-blu-spells, gear-list, owned-gear, set-stats and the gear-optimizer agent read. It is the
// one tool here that knows the Sel framework. It reads the files Sel loads first, in Sel's order (the job file,
// data/User/User-Globals.lua, <Character>-Globals.lua, <Character>-Items.lua, <Character>_Crafting.lua and
// data/User/User-<JOB>.lua), for gear entries, blue magic lists and the sets assigned outside any function, then every
// set in the gear file. A set_combine becomes a set with a base and the slots it puts over it.
//
//   dotnet run --no-cache .claude/tools/sel-sets.cs -- <gear file> <JOB> [--out <sets.json>]
//
// Without --out the sets file goes to standard output. What the reader couldn't follow (a gear entry no file read
// defines, a base no file read defines, a value it can't read), a set dropped by its parent's redefinition, and a set
// defined twice in one file are noted on standard error ("note"), with exit code 1. A set defined again on itself in
// one file, sets.x = set_combine(sets.x, {...}), is a usual Sel pattern: it is printed as "info" and leaves the exit
// code 0.
using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.IO;
using GearTools;

Tool.Init();
var cli = new Arguments(args, ["--out"], [], takesWords: true);
if (cli.Words.Count != 2)
	Tool.Fail("Give the gear file and the job: sel-sets.cs -- <gear file> <JOB> [--out <sets.json>]");
var gearFile = cli.Words[0];
var job = cli.Words[1].ToUpperInvariant();
if (File.Exists(gearFile) is false)
	Tool.Fail($"No gear file at {gearFile}.");
var named = SelReader.NameOf(gearFile);
if (named.Success is false)
	Tool.Fail($"{Path.GetFileName(gearFile)} isn't named like a Sel gear file (<Character>_<Job>_Gear.lua).");
if (Resources.JobNames.Skip(1).Contains(job) is false)
	Tool.Fail($"{job} isn't a job. Jobs: {string.Join(" ", Resources.JobNames.Skip(1))}");
if (named.Groups["job"].Value.ToUpperInvariant() != job)
	Tool.Fail($"{Path.GetFileName(gearFile)} is a {named.Groups["job"].Value.ToUpperInvariant()} gear file, not {job}.");

var character = named.Groups["who"].Value;
var before = SelReader.LoadedBefore(gearFile, character, job);
var read = SelReader.Read(gearFile, character, job, before);
Console.Error.WriteLine($"read {string.Join(", ", before.Append(gearFile).Select(path => Tool.RepoRelative(Path.GetFullPath(path))))}");
foreach (var note in read.Notes)
	Console.Error.WriteLine("  note  " + note);
foreach (var line in read.Info)
	Console.Error.WriteLine("  info  " + line);
var json = Dto.ToJson(read.Sets);
var output = cli.Option("--out");
if (output is null)
{
	Console.WriteLine(json);
}
else
{
	File.WriteAllText(output, json + Environment.NewLine);
}
Console.Error.WriteLine($"{read.Sets.Sets.Count} sets, {read.Sets.SpellLists?.Count ?? 0} spell lists -> {output ?? "standard output"}; notes: {read.Notes.Count}, information: {read.Info.Count}");
return read.Notes.Count > 0 ? 1 : 0;
