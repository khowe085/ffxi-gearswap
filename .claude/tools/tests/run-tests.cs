// Tests for the tools in the folder above. They run against the small made-up character under fixture/ (Testy),
// never against the real data: the shared code is called directly, and each tool is run as it is from the command
// line, pointed at a copy of the fixture, once as it stands and once with mistakes put in that the tool has to
// report.
//
//   dotnet run --no-cache .claude/tools/tests/run-tests.cs [-- <text>]
//
// With <text>, only the tests whose name contains it run. Exit code 1 when a test fails. Nothing here uses the
// network: wiki.cs, rank-tables.cs and fetch-sources.cs are covered through the shared code they call.
using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Diagnostics;
using System.IO;
using System.Text.Json;
using GearTools;

var testsDir = AppContext.GetData("EntryPointFileDirectoryPath") as string ?? Path.Combine(Environment.CurrentDirectory, ".claude", "tools", "tests");
var toolsDir = Path.GetFullPath(Path.Combine(testsDir, ".."));
var fixtureDir = Path.Combine(testsDir, "fixture");
var workDir = Path.Combine(Path.GetTempPath(), "gear-tools-tests-" + Environment.ProcessId);

// The shared code reads the repo and the cache named here, so set them before anything touches it.
var pristine = NewSandbox();
Environment.SetEnvironmentVariable("GEAR_TOOLS_ROOT", pristine.Repo);
Environment.SetEnvironmentVariable("GEAR_TOOLS_CACHE", pristine.Cache);

var tests = new List<KeyValuePair<string, Action>>();
void Test(string name, Action body) => tests.Add(KeyValuePair.Create(name, body));

// ---------------------------------------------------------------- the shared code

Test("Export.Latest takes the newest export by the date in its name, under either spelling", () =>
{
	Equal("Testy 2026-01-02 08-00-00.lua", Path.GetFileName(Export.Latest(null)));
	Equal("Testy", Export.CharacterOf(Export.Latest(null)));
	Equal("2026-01-02", Export.DateOf(Export.Latest(null)));
});

Test("Export.Owners names each character that has an export, once", () =>
{
	Equal("Testy", string.Join(" ", Export.Owners()));
});

Test("Export.Read gives each item its bag, slot key and augments as printed", () =>
{
	var items = Export.Read(Export.Latest(null));
	Equal(22, items.Count);
	var colada = items.Where(item => item.Name == "Colada").ToList();
	Equal(2, colada.Count);
	Equal("\"Refresh\"+2, Mag. Acc.+11, DMG:+1", colada[0].AugmentText);
	Equal("wardrobe", colada[0].Bag);
	Equal("locker", colada[1].Bag);
	True(colada[0].CanBeEquippedFromBag && colada[1].CanBeEquippedFromBag is false, "the wardrobe can be equipped from, the locker can't");
	Equal("item", items.Single(item => item.Name == "Echo Drops").SlotKey);
	Equal(0, items.Single(item => item.Name == "Naegling").Augments.Count);
});

Test("Export.Read puts an item on a storage slip in the bag slip<N>", () =>
{
	var stored = Export.Read(Export.Latest(null)).Single(item => item.Name == "Ayanmo Corazza +2");
	Equal("slip23", stored.Bag);
	Equal(23, stored.Slip);
	True(stored.CanBeEquippedFromBag is false, "a slip can't be equipped from");
	Equal(0, Export.Read(Export.Latest(null)).Single(item => item.Name == "Naegling").Slip);
});

Test("Export.Read reads an export from before bags were listed", () =>
{
	var items = Export.Read(Path.Combine(pristine.Repo, "data", "export", "Testy_2025-12-31_08-00-00.lua"));
	Equal(3, items.Count);
	True(items.All(item => item.Bag.Length == 0 && item.CanBeEquippedFromBag), "no bag is known, so none is ruled out");
	Equal(3, items.Single(item => item.Name == "Sucellos's Cape").Augments.Count);
});

Test("Resources finds an item by its short name or its log name, as GearSwap does", () =>
{
	var resources = Resources.Load();
	Equal("Loquac. Earring", resources.Pick("Loquacious Earring")!.Name);
	Equal("Loquac. Earring", resources.Pick("loquac. earring")!.Name);
	Equal(0, resources.Named("Nyame Helmm").Count);
	Equal(99, resources.Pick("Nyame Helm")!.Level);
	Equal(119, resources.Pick("Nyame Helm")!.ItemLevel);
	True(resources.Pick("Nyame Helm")!.Description.Contains("Accuracy+40"), "the help text comes along");
});

Test("Resources shows the highest stage of a weapon whose name several ids share", () =>
{
	var resources = Resources.Load();
	Equal(9, resources.Named("Almace").Count);
	Equal(20689, resources.Pick("Almace", "main")!.Id);
	Equal(119, resources.Pick("Almace")!.ItemLevel);
});

Test("ItemInfo knows the jobs and slots a piece fits", () =>
{
	var resources = Resources.Load();
	var sash = resources.Pick("Obstin. Sash")!;
	True(sash.WornBy("RDM") && sash.WornBy("rdm") && sash.WornBy("BLU") is false, "RDM wears Obstin. Sash, BLU doesn't");
	Equal("WHM RDM BRD SCH", string.Join(" ", sash.Jobs));
	Equal(22, resources.Pick("Nyame Helm")!.Jobs.Count);
	var ring = resources.Pick("Stikini Ring")!;
	True(ring.FitsSlot("left_ring") && ring.FitsSlot("ring2") && ring.FitsSlot("rring") && ring.FitsSlot("left_ear") is false, "a ring fits either ring slot under any of its names, and no ear");
	Equal("ring", ring.Group);
	Equal("sub", resources.Pick("Ammurapi Shield")!.Group);
	True(resources.Pick("Ammurapi Shield")!.FitsSlot("main") is false, "a shield doesn't go in main");
	True(resources.Pick("Naegling")!.FitsSlot("sub") && resources.Pick("Naegling")!.Group == "main", "a one-handed sword fits both hands and is listed under main");
});

Test("LuaGearFile reads the entries a job file defines, and not ones in comments", () =>
{
	var file = LuaGearFile.Read(Path.Combine(pristine.Repo, "data", "Testy", "RDM.lua"));
	Equal("coladaRefresh stikini1 stikini2 sucellosINT sucellosMND", string.Join(" ", file.Defs.Select(def => def.Key).Order(StringComparer.Ordinal)));
	var cape = file.Defs.Single(def => def.Key == "sucellosINT");
	Equal("Sucellos's Cape", cape.Name);
	Equal("INT+20, Mag. Acc+20 /Mag. Dmg.+20, \"Mag.Atk.Bns.\"+10", cape.AugmentText);
	Equal(9, cape.Line);
	var library = LuaGearFile.Read(Path.Combine(pristine.Repo, "data", "common", "RahvinGS", "GearSets-Include.lua"));
	True(library.Defs.Any(def => def.Key == "notAnEntry") is false, "an entry inside a comment isn't one");
	Equal("wardrobe8", library.Defs.Single(def => def.Key == "stikiniWardrobe8").Bag);
	Equal(null, library.Defs.Single(def => def.Key == "naegling").Bag);
});

Test("LuaGearFile lists each slot a set fills, by set name and line", () =>
{
	var file = LuaGearFile.Read(Path.Combine(pristine.Repo, "data", "Testy", "RDM.lua"));
	string Sets(string key) => string.Join(" | ", file.Uses.Where(use => use.Key == key).Select(use => $"{use.SetName}:{use.Slot}"));
	Equal("Weapons['Savage Blade']:main", Sets("naegling"));
	Equal("Idle:head", Sets("nyameHead"));
	Equal("Midcast.Enfeebling:head", Sets("atrophyHeadPlusFour"));
	Equal("Midcast['Stoneskin']:left_ring", Sets("prolix"));
	Equal("WS:ammo", Sets("coiste"));
	Equal("WS[ws].ACC:waist", Sets("eschan"));
	Equal(27, file.Uses.Single(use => use.Key == "nyameHead").Line);
	True(file.Uses.Any(use => use.SetName.StartsWith("Old")) is false, "a set inside a block comment isn't read");
	True(file.ReferencedKeys.Contains("regalGem") is false, "nor are the keys it names");
});

Test("LuaGearFile lists what a hook wears under the hook's name, and only real slots", () =>
{
	var file = LuaGearFile.Read(Path.Combine(pristine.Repo, "data", "Testy", "RDM.lua"));
	var uses = file.Uses.Where(use => use.Key == "sucellosINT").ToList();
	Equal(1, uses.Count);
	Equal("midcast_custom()", uses[0].SetName);
	Equal("back", uses[0].Slot);
	True(file.LooseReferences.Any(line => line.Contains("local cape = gear.sucellosINT")), "a variable that holds a piece is reported, not taken for a slot");
	Equal(0, file.DirectSlotValues.Count);
});

Test("LuaGearFile.StripComments drops comments and keeps strings and line numbers", () =>
{
	var source = "a = 'x--y' -- gone\n--[[ block\nsets.X = {} ]] b = \"--\"\nc = 1 -- 'quoted'\n";
	var stripped = LuaGearFile.StripComments(source);
	Equal("a = 'x--y' \n\n b = \"--\"\nc = 1 \n", stripped);
	Equal(source.Count(c => c == '\n'), stripped.Count(c => c == '\n'));
});

Test("LuaGearFile.StripComments reads a block comment with = signs to the bracket that closes it", () =>
{
	// The library writes its long notes this way. "]]" inside one doesn't end it.
	var source = "x = 1 --[==[ note ]] still a comment\ngear.ghost = hp_gear(\"Eschan Stone\", 20)\n]==] y = 2\n--[=[ one ]=] z = 3\na = 1 --[= only a line\nb = 2\n";
	Equal("x = 1 \n\n y = 2\n z = 3\na = 1 \nb = 2\n", LuaGearFile.StripComments(source));
});

Test("GearFiles finds the job files and lets a job file's entry replace the library's", () =>
{
	var files = GearFiles.Load("Testy");
	Equal("BLU RDM", string.Join(" ", files.Jobs.Keys));
	True(files.Globals is not null, "Testy-Globals.lua is found");
	var defs = files.DefsFor("RDM");
	Equal("Atrophy Chapeau +4", defs["atrophyHeadPlusFour"].Name);
	Equal("RDM.lua", defs["stikini1"].FileName);
	True(files.DefsFor("BLU").ContainsKey("stikini1") is false, "another job file's entries aren't shared");
	Equal("RDM", string.Join(" ", files.Select("rdm")));
});

Test("GearDef.Matches takes any copy when it names no augments, and only its own when it does", () =>
{
	var files = GearFiles.Load("Testy");
	var copies = Export.Read(Export.Latest(null)).Where(item => item.Name == "Colada").ToList();
	var refresh = files.DefsFor("RDM")["coladaRefresh"];
	True(refresh.Matches(copies[0]) && refresh.Matches(copies[1]) is false, "the Refresh entry is the wardrobe copy only");
	var sash = Export.Read(Export.Latest(null)).Single(item => item.Name == "Obstin. Sash");
	True(files.DefsFor("RDM")["obstinateSash"].Matches(sash), "an entry without augments takes the augmented copy");
});

Test("Characters finds each folder that holds job files, and names its documents", () =>
{
	Equal("Testy", string.Join(" ", Characters.All()));
	True(Characters.IsJobFile(Path.Combine("data", "Testy", "RDM.lua")), "RDM.lua is a job file");
	True(Characters.IsJobFile(Path.Combine("data", "Testy", "Testy-Globals.lua")) is false, "Testy-Globals.lua isn't a job file");
	Equal("data/Testy/Testy_gear_list.md", Tool.RepoRelative(Characters.GearList("Testy")));
	Equal("data/Testy/Testy_notes.md", Tool.RepoRelative(Characters.Notes("Testy")));
	Equal("data/Testy/Testy_gear_notes.md", Tool.RepoRelative(Characters.GearNotes("Testy")));
	Equal("data/Testy/Testy_rank_augments.md", Tool.RepoRelative(Characters.RankAugments("Testy")));
});

Test("PlayerRanks reads the Ranks table in a character's notes, with the day each rank was given", () =>
{
	var ranks = PlayerRanks.Read(Characters.Notes("Testy"));
	Equal("Nyame Helm, Obstin. Sash", string.Join(", ", ranks.Keys));
	Equal("B 2 2026-01-03", $"{ranks["Nyame Helm"].Path} {ranks["Nyame Helm"].Rank} {ranks["Nyame Helm"].Given}");
	Equal("A 20 2026-01-02", $"{ranks["Obstin. Sash"].Path} {ranks["Obstin. Sash"].Rank} {ranks["Obstin. Sash"].Given}");
	Equal(0, PlayerRanks.Read(Path.Combine(workDir, "no-such-notes.md")).Count);
	var bare = Path.Combine(workDir, "notes-without-ranks.md");
	File.WriteAllText(bare, "# Notes\n\n## Rules\n\n| Item | Path | Rank | Given |\n|---|---|---|---|\n| Nyame Helm | B | 2 | 2026-01-03 |\n");
	Equal(0, PlayerRanks.Read(bare).Count);
});

Test("PlayerRanks refuses a Ranks row it can't read, and gives its line", () =>
{
	string Refusal(string row)
	{
		var notes = Path.Combine(workDir, "notes-" + Guid.NewGuid().ToString("N")[..8] + ".md");
		File.WriteAllText(notes, "# Notes\n\n## Ranks\n\n| Item | Path | Rank | Given |\n|---|---|---|---|\n| Nyame Helm | B | 2 | 2026-01-03 |\n" + row + "\n\n## After\n\n| Not | A | Rank | Row |\n");
		return Throws<InvalidOperationException>(() => PlayerRanks.Read(notes)).Message;
	}
	Contains(Refusal("| Nyame Mail | B | two | 2026-01-03 |"), ".md:8: \"two\" isn't a rank");
	Contains(Refusal("| Nyame Mail | B | 20 | last week |"), ".md:8: \"last week\" isn't a day, written as in 2026-10-04");
	Contains(Refusal("| Nyame Mail | B | 20 |"), ".md:8: a Ranks row has four cells: Item, Path, Rank, Given");
	Contains(Refusal("| Nyame Helm | B | 3 | 2026-01-04 |"), ".md:8: a second row for Nyame Helm");
});

Test("Sims.Load reads each simulated set with its buff level, items and augment notes", () =>
{
	var sets = Sims.Load("rdm");
	Equal(2, sets.Count);
	Equal("Savage Blade", sets[0].Name);
	Equal("Red Mage* Sets", sets[0].Section);
	Equal("Mid buff", sets[0].CaptionTop);
	Equal("54330 damage", sets[0].CaptionBottom);
	Equal("Nyame Helm", sets[0].Items["Head"]);
	True(sets[0].Items.ContainsKey("Sub") is false, "an empty slot is left out");
	Equal("STR, Weapon Skill Damage", sets[0].Augments["Back"]);
	Equal("Almace", Sims.ItemName(Sims.Load("blu")[0].Items["Main"]));
});

Test("RankTableParser reads every path and rank of a wiki page's rank table", () =>
{
	var page = new WikiPage("Nyame Helm", string.Join("\n",
		"|RankMax=30", "{{Augment Rank Table", "|Path=A", "{{Augment Rank Row", "|Rank=1", "|Augment1=Accuracy+1", "|Augment2=---", "}}",
		"|Path=B", "{{Augment Rank Row", "|Rank=1", "|Augment1=Attack+3 Rng. Atk.+3", "|Augment2=---", "|Augment3=---", "}}",
		"{{Augment Rank Row", "|Rank=2", "|Augment1=Attack+4 Rng. Atk.+4", "|Augment2=Weapon skill damage +1%", "}}", "}}"));
	var item = RankTableParser.Parse("Nyame Helm", page)!;
	Equal(30, item.RankMax);
	Equal("A B", string.Join(" ", item.Paths.Select(path => path.Path)));
	Equal(2, item.Paths[1].Ranks.Count);
	Equal("Attack+4 Rng. Atk.+4|Weapon skill damage +1%||", string.Join("|", item.Paths[1].Ranks[1].Augments));
	Equal("Accuracy+1|||", string.Join("|", item.Paths[0].Ranks[0].Augments));
	Equal(null, RankTableParser.Parse("Naegling", new WikiPage("Naegling", "no table here")));
});

Test("RankTableParser refuses a rank table with no path or no rows, instead of saving an empty one", () =>
{
	var noPath = new WikiPage("Odd Helm", string.Join("\n", "{{Augment Rank Table", "{{Augment Rank Row", "|Rank=1", "|Augment1=Accuracy+1", "}}", "}}"));
	Contains(Throws<InvalidOperationException>(() => RankTableParser.Parse("Odd Helm", noPath)).Message, "Odd Helm");
	var noRows = new WikiPage("Odd Mail", string.Join("\n", "{{Augment Rank Table", "|Path=A", "}}"));
	Contains(Throws<InvalidOperationException>(() => RankTableParser.Parse("Odd Mail", noRows)).Message, "Odd Mail");
});

Test("RankDoc.RenderTables gives bg-wiki's tables for every path item, and names no character", () =>
{
	var text = string.Join("\n", RankDoc.RenderTables(RankTables.Load(), Resources.Load(), TestOboro()));
	Contains(text, "read on 2026-01-03");
	Contains(text, "| [Nyame Helm](#nyame-helm) | head | A, B, C | 30 |");
	Contains(text, "## Nyame\n\n### Nyame Helm\n\nNyame Helm, head. Ranks 1 to 30. Source: [bg-wiki](https://www.bg-wiki.com/ffxi/Nyame_Helm).");
	Contains(text, "Path A:\n\n| Rank | Augment 1 |\n|---|---|\n| 1 | Accuracy+1 |");
	Contains(text, "Path B:\n\n| Rank | Augment 1 | Augment 2 |\n|---|---|---|\n| 1 | Attack+3 Rng. Atk.+3 |  |\n| 2 | Attack+4 Rng. Atk.+4 | Weapon skill damage +1% |");
	Contains(text, "## Other path items\n\n### Coiste Bodhar");
	Contains(text, "Obstinate Sash, waist. Ranks 1 to 30. Source:");
	Contains(text, "## Oboro rank augments (maximum only)\n\nOboro ranks these up.\n\n| Item | Slot | Max rank | Augments at max rank |\n|---|---|---|---|\n| Almace | main | 15 | DMG +5 |\n| Dls. Torque +1 | neck | 20 | INT and MND +12 |");
	True(text.Contains("Testy") is false, "the tables name no character");
	True(text.Contains("**") is false, "the tables mark no rank as anyone's");
});

Test("RankDoc.RenderCharacter gives the character's path and rank for each item, from the Ranks table or the export", () =>
{
	var text = string.Join("\n", RankDoc.RenderCharacter(RankTables.Load(), Resources.Load(), TestOboro(), TestCharacterRanks(copy => copy)));
	Contains(text, "# Testy: rank augments");
	Contains(text, "in the export `data/export/Testy 2026-01-02 08-00-00.lua`");
	Contains(text, "[Testy_notes.md](Testy_notes.md#ranks)");
	Contains(text, "| Item | Slot | Path | Rank | Given | Augments at that rank |");
	Contains(text, "| [Nyame Helm](../../docs/rank-augments.md#nyame-helm) | head | B | 2 | 2026-01-03 | Attack+4 Rng. Atk.+4, Weapon skill damage +1% |");
	Contains(text, "| [Coiste Bodhar](../../docs/rank-augments.md#coiste-bodhar) | ammo | A | unknown |  |  |");
	Contains(text, "| [Eschan Stone](../../docs/rank-augments.md#eschan-stone) | waist | none | 0 |  | none (base stats only) |");
	Contains(text, "| [Obstin. Sash](../../docs/rank-augments.md#obstin-sash) | waist | A | 20 | 2026-01-02 | Mag. Acc.+15, Enfb. mag. skill +5 |");
	Contains(text, "## Items Oboro ranks up");
	Contains(text, "| Item | Slot | Max rank | Testy's copy |\n|---|---|---|---|\n| Almace | main | 15 | no augments: rank 0, stage unknown |");
	True(text.Contains("Dls. Torque +1") is false, "an Oboro item the character doesn't hold is left out");
	True(text.Contains("The export prints") is false, "nothing is ranked ahead of this export");
});

Test("RankDoc.RenderCharacter says so when the player gave a rank the export doesn't show yet", () =>
{
	var data = TestCharacterRanks(copy => copy.Name == "Obstin. Sash" ? new ExportItem(copy.Bag, copy.SlotKey, copy.Name, []) : copy);
	var text = string.Join("\n", RankDoc.RenderCharacter(RankTables.Load(), Resources.Load(), TestOboro(), data));
	Contains(text, "- The export prints Obstinate Sash with no augments, as it would an unranked piece. The player has since given its rank, and the table uses it.");
	Contains(text, "| [Obstin. Sash](../../docs/rank-augments.md#obstin-sash) | waist | A | 20 | 2026-01-02 | Mag. Acc.+15, Enfb. mag. skill +5 |");
});

Test("RankDoc.RenderCharacter reads an Oboro item's path from the export and its rank from the Ranks table", () =>
{
	var data = TestCharacterRanks(copy => copy.Name == "Almace" ? new ExportItem(copy.Bag, copy.SlotKey, copy.Name, ["Path: A"]) : copy);
	Contains(string.Join("\n", RankDoc.RenderCharacter(RankTables.Load(), Resources.Load(), TestOboro(), data)), "| Almace | main | 15 | `'Path: A'` (so Level 119 III), rank unknown |");
	data.Ranks["Almace"] = new PlayerRank("A", 7, "2026-01-03");
	Contains(string.Join("\n", RankDoc.RenderCharacter(RankTables.Load(), Resources.Load(), TestOboro(), data)), "| Almace | main | 15 | `'Path: A'` (so Level 119 III), rank 7 (2026-01-03) |");
});

Test("RankDoc.RenderCharacter leaves path and rank open for a piece held only on a storage slip", () =>
{
	// A slip records no augments, so the copy says nothing of its path.
	var data = TestCharacterRanks(copy => copy.Name == "Coiste Bodhar" ? new ExportItem("slip5", copy.SlotKey, copy.Name, []) : copy);
	Contains(string.Join("\n", RankDoc.RenderCharacter(RankTables.Load(), Resources.Load(), TestOboro(), data)), "| [Coiste Bodhar](../../docs/rank-augments.md#coiste-bodhar) | ammo | ? | unknown |  |  |");
});

Test("RankDoc.RenderCharacter refuses a rank for an item that has no rank table", () =>
{
	var data = TestCharacterRanks(copy => copy);
	data.Ranks["Obstinate Sash"] = new PlayerRank("A", 20, "2026-01-03");
	var failure = Throws<InvalidOperationException>(() => RankDoc.RenderCharacter(RankTables.Load(), Resources.Load(), TestOboro(), data));
	Contains(failure.Message, "\"Obstinate Sash\"");
	Contains(failure.Message, "Obstin. Sash");
});

Test("GitSource.Fetch checks out the pinned commit, and leaves a folder already at it alone", () =>
{
	var source = NewGitRepo("source-one");
	var target = Path.Combine(workDir, "fetch-one");
	Contains(GitSource.Fetch(target, source.Path, source.Commit), "fetched");
	Equal("hello", File.ReadAllText(Path.Combine(target, "file.txt")).Trim());
	Contains(GitSource.Fetch(target, source.Path, source.Commit), "present");
});

Test("GitSource.Fetch recovers a folder left half made by a fetch that failed", () =>
{
	var source = NewGitRepo("source-two");
	var target = Path.Combine(workDir, "fetch-two");
	Throws<InvalidOperationException>(() => GitSource.Fetch(target, Path.Combine(workDir, "no-such-repo"), source.Commit));
	True(Directory.Exists(Path.Combine(target, ".git")), "the failed fetch left its folder behind");
	Contains(GitSource.Fetch(target, source.Path, source.Commit), "fetched");
	Equal("hello", File.ReadAllText(Path.Combine(target, "file.txt")).Trim());
});

// ---------------------------------------------------------------- check-export.cs

Test("check-export passes a job file whose gear is owned, wearable and in reach", () =>
{
	var run = pristine.Run("check-export");
	Equal(0, run.ExitCode);
	Contains(run.Output, "Export: data/export/Testy 2026-01-02 08-00-00.lua");
	Contains(run.Output, "BLU.lua: 3 keys");
	Contains(run.Output, "RDM.lua: 15 keys");
	Contains(run.Output, "problems: 0 errors, 0 warnings");
});

Test("check-export reports each kind of mistake in a job file", () =>
{
	var sandbox = NewSandbox();
	sandbox.Edit("data/Testy/RDM.lua", "data/export/Testy 2026-01-02 08-00-00.lua.", "data/export/Testy 2026-01-01 08-00-00.lua.");
	sandbox.Edit("data/Testy/RDM.lua", "gear.stikini2 = hp_gear(\"Stikini Ring\", 0)\n",
		"gear.stikini2 = hp_gear(\"Stikini Ring\", 0)\n"
		+ "gear.badAugments = hp_gear(\"Sucellos's Cape\", 0, { augments = { 'MND+20', 'Nope', } })\n"
		+ "gear.misspelt = hp_gear(\"Nyame Helmm\", 0)\n"
		+ "gear.neverWorn = hp_gear(\"Eschan Stone\", 20)\n");
	sandbox.Edit("data/Testy/RDM.lua", "\tsets.Midcast = set_combine(sets.Idle, {})\n",
		"\tsets.Midcast = set_combine(sets.Idle, {})\n"
		+ "\tsets.Broken = {\n\t\thead = gear.noSuchKey,\n\t\tneck = gear.regalGem,\n\t\tback = gear.badAugments,\n\t\tlegs = gear.misspelt,\n"
		+ "\t\thands = gear.hashishinHandsPlusThree,\n\t\tleft_ear = gear.stikini1,\n\t\tright_ring = gear.stikiniWardrobe8,\n"
		+ "\t\tbody = gear.ayanmoBodyPlusTwo,\n\t\twaist = \"Eschan Stone\",\n\t}\n"
		+ "\tsets.Burst = { body = gear.eaBody }\n");
	var run = sandbox.Run("check-export", "--job", "RDM");
	Equal(1, run.ExitCode);
	Contains(run.Output, "warn  RDM.lua's header names the export Testy 2026-01-01 08-00-00.lua, and this check read Testy 2026-01-02 08-00-00.lua");
	Contains(run.Output, "ERROR gear.noSuchKey (line 42, Broken): not defined");
	Contains(run.Output, "ERROR gear.regalGem -> \"Regal Gem\": not in the export");
	Contains(run.Output, "ERROR gear.badAugments -> \"Sucellos's Cape\": augments [MND+20, Nope] match no copy. The export has: [MND+20, Mag. Acc+20 /Mag. Dmg.+20, Haste+10] | [INT+20");
	Contains(run.Output, "ERROR gear.misspelt -> \"Nyame Helmm\": no weapon or armor has that name or log name");
	Contains(run.Output, "ERROR gear.hashishinHandsPlusThree -> \"Hashishin Bazubands +3\": RDM can't wear it (jobs: BLU)");
	Contains(run.Output, "ERROR gear.stikini1 -> \"Stikini Ring\": Broken puts it in left_ear, but it goes in left_ring or right_ring (line 47)");
	Contains(run.Output, "ERROR gear.stikiniWardrobe8 -> \"Stikini Ring\": pinned to wardrobe8, but the matching copies are in wardrobe");
	Contains(run.Output, "warn  gear.ayanmoBodyPlusTwo -> \"Ayanmo Corazza +2\": only on storage slip 23. Get it back from a porter moogle");
	Contains(run.Output, "warn  gear.eaBody -> \"Ea Houppelande\": only in safe2. GearSwap equips from the inventory and the wardrobes");
	Contains(run.Output, "warn  gear.neverWorn -> \"Eschan Stone\": defined at RDM.lua:17 but nothing in the file wears it");
	Contains(run.Output, "warn  RDM.lua:50: sets.Broken: waist = \"Eschan Stone\": a slot filled without a gear.<key> entry");
	Contains(run.Output, "note  RDM.lua:69: local cape = gear.sucellosINT");
	Contains(run.Output, "problems: 7 errors, 5 warnings");
	True(run.Output.Contains("BLU.lua") is false, "--job RDM leaves the other job files alone");
});

Test("check-export can read an older export, where newer pieces are missing", () =>
{
	var run = pristine.Run("check-export", "--job", "BLU", "--export", Path.Combine(pristine.Repo, "data", "export", "Testy 2026-01-01 08-00-00.lua"));
	Equal(1, run.ExitCode);
	Contains(run.Output, "ERROR gear.ruminationSash -> \"Rumination Sash\": not in the export");
	Contains(run.Output, "warn  BLU.lua's header names the export Testy 2026-01-02 08-00-00.lua, and this check read Testy 2026-01-01 08-00-00.lua");
});

Test("a tool stops on an option it doesn't know, a job that has no file, or a stray word", () =>
{
	var unknown = pristine.Run("check-export", "--jobs", "RDM");
	Equal(2, unknown.ExitCode);
	Contains(unknown.Output, "Unknown option --jobs. Options: --job <value> --char <value> --export <value>");
	var noFile = pristine.Run("check-export", "--job", "THF");
	Equal(2, noFile.ExitCode);
	Contains(noFile.Output, "No data/Testy/THF.lua. Job files: BLU, RDM");
	var stray = pristine.Run("check-export", "RDM");
	Equal(2, stray.ExitCode);
	Contains(stray.Output, "Unexpected argument RDM");
});

// ---------------------------------------------------------------- gear-list.cs

Test("gear-list passes a list that matches the job files, and --print reproduces it", () =>
{
	var run = pristine.Run("gear-list");
	Equal(0, run.ExitCode);
	Contains(run.Output, "rows 17; BLU 3 (2 BLU only); RDM 15 (14 RDM only); BLU and RDM 1");
	Contains(run.Output, "problems: 0");
	var printed = pristine.Run("gear-list", "--print").Output.Replace("\r", "").Split('\n').Where(line => line.StartsWith('|') || line.StartsWith("## ")).ToList();
	// The Reference section at the top links the character's other files, and isn't part of the table.
	var written = File.ReadAllLines(Path.Combine(pristine.Repo, "data", "Testy", "Testy_gear_list.md")).Where(line => line.StartsWith('|') || (line.StartsWith("## ") && line != "## Reference")).ToList();
	Equal(string.Join("\n", written), string.Join("\n", printed));
});

Test("gear-list reports each kind of mismatch between the list and the job files", () =>
{
	var sandbox = NewSandbox();
	var list = "data/Testy/Testy_gear_list.md";
	sandbox.Edit(list, "of 2026-01-02: **17 pieces** (3 for BLU, 15 for RDM, 1 worn by both)", "of 2026-01-01: **18 pieces** (4 for BLU, 15 for RDM, 2 worn by both)");
	sandbox.Edit(list, "## Ammo (1)", "## Ammo (2)");
	sandbox.Edit(list, "| Nyame Helm |  | `Idle` | `Idle` |", "| Nyame Helm |  | `Idle` |  |");
	sandbox.Edit(list, "| Naegling |  |  | `Weapons['Savage Blade']` |\n", "| Naegling |  |  | `Weapons['Savage Blade']` |\n| Almace |  |  | `Idle` |\n");
	sandbox.Edit(list, "| Colada | \"Refresh\"+2, Mag. Acc.+11, DMG:+1 |", "| Colada | Weapon skill damage +2%, DMG:+14 |");
	sandbox.Edit(list, "| Prolix Ring |  |  | `Midcast['Stoneskin']` |\n", "");
	sandbox.Edit(list, "| Lethargy Sayon +3 |  |  | `Idle` |\n", "");
	sandbox.Edit(list, "| Hashi. Bazu. +3 |  | `Idle` |  |\n", "| Hashi. Bazu. +3 |  | `Idle` |  |\n| Lethargy Sayon +3 |  |  | `Idle` |\n");
	sandbox.Edit(list, "| Sucellos's Cape | INT+20, Mag. Acc+20 /Mag. Dmg.+20, \"Mag.Atk.Bns.\"+10 |", "| Sucellos's Cape | INT+20, Nope |");
	var run = sandbox.Run("gear-list");
	Equal(1, run.ExitCode);
	Contains(run.Output, "Nyame Helm, RDM column\n    list:  \n    files: `Idle`");
	Contains(run.Output, "Almace has a row, but no set or hook wears it");
	Contains(run.Output, "## Weapons isn't sorted by item name");
	Contains(run.Output, "## Ammo (2) has 1 rows");
	Contains(run.Output, "Colada: the Copy column says [Weapon skill damage +2%, DMG:+14], but the sets wear [\"Refresh\"+2, Mag. Acc.+11, DMG:+1]");
	Contains(run.Output, "Prolix Ring: no row. Expected: BLU:  | RDM: `Midcast['Stoneskin']`");
	Contains(run.Output, "Lethargy Sayon +3 is under Hands, but the sets wear it under Body");
	Contains(run.Output, "Sucellos's Cape [INT+20, Mag. Acc+20 /Mag. Dmg.+20, \"Mag.Atk.Bns.\"+10]: none of its 2 rows matches");
	Contains(run.Output, "Sucellos's Cape [INT+20, Nope] matches no copy");
	Contains(run.Output, "The list says it was taken from the export of 2026-01-01, and this check read the one of 2026-01-02");
	Contains(run.Output, "The list says 18 pieces and has 17 rows");
	Contains(run.Output, "The list says 4 for BLU and has 3 rows with BLU sets");
	Contains(run.Output, "The list says 2 worn by both, and 0 rows have both BLU and RDM sets");
});

Test("gear-list checks a claim that some of a job's pieces are worn by that job alone", () =>
{
	var sandbox = NewSandbox();
	sandbox.Edit("data/Testy/Testy_gear_list.md", "1 worn by both)", "1 worn by both; 9 of them RDM only)");
	var run = sandbox.Run("gear-list");
	Equal(1, run.ExitCode);
	Contains(run.Output, "The list says 9 of them RDM only, and 14 rows have RDM sets alone");
});

Test("gear-list reports a job file the list has no column for, and --print gives the table with it", () =>
{
	var sandbox = NewSandbox();
	File.WriteAllText(Path.Combine(sandbox.Repo, "data", "Testy", "WAR.lua"),
		"include('RahvinGS/GearSets-Include')\nfunction get_sets()\n\tsets.Idle = {\n\t\tmain = gear.naegling,\n\t\thead = gear.nyameHead,\n\t\twaist = gear.eschan,\n\t}\nend\n");
	var run = sandbox.Run("gear-list");
	Equal(1, run.ExitCode);
	Contains(run.Output, "data/Testy/WAR.lua has no column in the list. --print gives the table with a WAR column");
	Contains(run.Output, "problems: 1");
	var printed = sandbox.Run("gear-list", "--print").Output.Replace("\r", "");
	Contains(printed, "| Item | Copy | BLU sets | RDM sets | WAR sets |");
	Contains(printed, "| Naegling |  |  | `Weapons['Savage Blade']` | `Idle` |");
	Contains(printed, "| Nyame Helm |  | `Idle` | `Idle` | `Idle` |");
	Contains(printed, "| Eschan Stone |  |  | `WS[each magical WS].ACC` | `Idle` |");
});

// ---------------------------------------------------------------- rank-doc.cs

Test("rank-doc finds both rank documents to be what it would write", () =>
{
	var run = pristine.Run("rank-doc", "--check");
	Equal(0, run.ExitCode);
	Contains(run.Output, "docs/rank-augments.md");
	Contains(run.Output, "data/Testy/Testy_rank_augments.md");
});

Test("rank-doc rewrites a character's document from the Ranks table, and leaves the tables alone", () =>
{
	var sandbox = NewSandbox();
	sandbox.Edit("data/Testy/Testy_notes.md", "| Nyame Helm | B | 2 | 2026-01-03 |", "| Nyame Helm | B | 15 | 2026-01-05 |");
	var stale = sandbox.Run("rank-doc", "--check");
	Equal(1, stale.ExitCode);
	Contains(stale.Output, "data/Testy/Testy_rank_augments.md isn't what this would write");
	var tables = Path.Combine(sandbox.Repo, "docs", "rank-augments.md");
	var before = File.ReadAllText(tables);
	Equal(before, File.ReadAllText(Path.Combine(pristine.Repo, "docs", "rank-augments.md")));
	var run = sandbox.Run("rank-doc");
	Equal(0, run.ExitCode);
	Contains(File.ReadAllText(Path.Combine(sandbox.Repo, "data", "Testy", "Testy_rank_augments.md")),
		"| [Nyame Helm](../../docs/rank-augments.md#nyame-helm) | head | B | 15 | 2026-01-05 | Attack+20 Rng. Atk.+20, Weapon skill damage +7% |");
	Equal(before, File.ReadAllText(tables));
	Equal(0, sandbox.Run("rank-doc", "--check").ExitCode);
});

Test("rank-doc stops on a Ranks row it can't use, and writes nothing", () =>
{
	var sandbox = NewSandbox();
	var document = Path.Combine(sandbox.Repo, "data", "Testy", "Testy_rank_augments.md");
	var before = File.ReadAllText(document);
	sandbox.Edit("data/Testy/Testy_notes.md", "| Nyame Helm | B | 2 | 2026-01-03 |", "| Nyame Hat | B | 2 | 2026-01-03 |");
	var unknown = sandbox.Run("rank-doc");
	Equal(2, unknown.ExitCode);
	Contains(unknown.Output, "\"Nyame Hat\"");
	sandbox.Edit("data/Testy/Testy_notes.md", "| Nyame Hat | B | 2 | 2026-01-03 |", "| Nyame Helm | B | two | 2026-01-03 |");
	var unreadable = sandbox.Run("rank-doc");
	Equal(2, unreadable.ExitCode);
	Contains(unreadable.Output, "data/Testy/Testy_notes.md:15: \"two\" isn't a rank");
	Equal(before, File.ReadAllText(document));
});

// ---------------------------------------------------------------- owned-gear.cs

Test("owned-gear lists what a job can wear in a slot, with bag, jobs, keys and who wears it", () =>
{
	var run = pristine.Run("owned-gear", "--job", "RDM", "--slot", "waist");
	Equal(0, run.ExitCode);
	Contains(run.Output, "waist | Eschan Stone |  | wardrobe | All jobs | gear.eschan | RDM | DEF:9 HP+20 MP+20");
	Contains(run.Output, "waist | Obstin. Sash | Path: A | wardrobe | WHM RDM BRD SCH | gear.obstinateSash | RDM | MND+5 / Enfeebling magic duration +5%");
	Contains(run.Output, "waist | Rumination Sash |  | inventory | ");
	Contains(run.Output, "| gear.ruminationSash | BLU | MND+4 Magic Accuracy+3");
	Contains(run.Output, "3 pieces");
	var blu = pristine.Run("owned-gear", "--job", "blu", "--slot", "waist");
	True(blu.Output.Contains("Obstin. Sash") is false, "BLU can't wear Obstin. Sash, so it isn't offered");
	Contains(blu.Output, "2 pieces");
});

Test("owned-gear marks bags GearSwap can't reach, counts copies and names the entry for each copy", () =>
{
	var run = pristine.Run("owned-gear");
	Equal(0, run.ExitCode);
	Contains(run.Output, "body  | Ayanmo Corazza +2 |  | !slip23 | WHM RDM BRD BLU RUN | gear.ayanmoBodyPlusTwo |  | ");
	Contains(run.Output, "body  | Ea Houppelande |  | !safe2 | ");
	Contains(run.Output, "ring  | Stikini Ring |  | wardrobe, wardrobe | ");
	Contains(run.Output, "gear.stikiniWardrobe8, gear.stikini1 (RDM.lua), gear.stikini2 (RDM.lua) | RDM | ");
	Contains(run.Output, "main  | Colada | \"Refresh\"+2, Mag. Acc.+11, DMG:+1 | wardrobe | ");
	Contains(run.Output, "| gear.coladaRefresh (RDM.lua) | RDM | ");
	Contains(run.Output, "main  | Colada | Weapon skill damage +2%, DMG:+14 | !locker | ");
	Contains(run.Output, "back  | Sucellos's Cape | INT+20, Mag. Acc+20 /Mag. Dmg.+20, \"Mag.Atk.Bns.\"+10 | wardrobe | RDM | gear.sucellosINT (RDM.lua) | RDM | ");
	Contains(run.Output, "[9 items share this name; this is the highest stage]");
	Contains(run.Output, "20 pieces");
	True(run.Output.Contains("Echo Drops") is false, "an item that can't be worn isn't gear");
});

Test("owned-gear filters by slot under either hand and by text, and writes JSON for another tool", () =>
{
	Contains(pristine.Run("owned-gear", "--slot", "sub").Output, "5 pieces");
	Contains(pristine.Run("owned-gear", "--slot", "ring").Output, "2 pieces");
	var grep = pristine.Run("owned-gear", "--grep", "fast cast");
	Contains(grep.Output, "Loquac. Earring");
	Contains(grep.Output, "Prolix Ring");
	Contains(grep.Output, "Atro. Chapeau +4");
	Contains(grep.Output, "5 pieces");
	var json = pristine.Run("owned-gear", "--job", "RDM", "--slot", "back", "--json");
	using var parsed = JsonDocument.Parse(json.StandardOutput);
	Equal(2, parsed.RootElement.GetArrayLength());
	Equal("INT+20", parsed.RootElement[0].GetProperty("Augments")[0].GetString());
	var cape = parsed.RootElement[1];
	Equal("Sucellos's Cape", cape.GetProperty("Name").GetString());
	Equal("MND+20", cape.GetProperty("Augments")[0].GetString());
	Equal("wardrobe", cape.GetProperty("Bags")[0].GetString());
	Equal("back", cape.GetProperty("Slots")[0].GetString());
	Equal("Idle", cape.GetProperty("WornBy").GetProperty("RDM")[0].GetString());
	True(cape.GetProperty("Description").GetString()!.Length > 0, "the help text is in the JSON");
	Equal(2, pristine.Run("owned-gear", "--slot", "nose").ExitCode);
	Equal(2, pristine.Run("owned-gear", "--job", "XYZ").ExitCode);
});

// ---------------------------------------------------------------- the other checkers

Test("check-blu-spells passes lists that hold every blue spell once", () =>
{
	var run = pristine.Run("check-blu-spells");
	Equal(0, run.ExitCode);
	Contains(run.Output, "9 blue spells; BluePhysical 2, BlueBreath 1, BlueNuke 1, BlueSkill 1, BlueBuff 1, BlueTank 2, BlueHealing 1, BlueACC 0");
	Contains(run.Output, "problems: 0");
});

Test("check-blu-spells reports a spell in no list, in two lists, and a name that isn't a spell", () =>
{
	var sandbox = NewSandbox();
	sandbox.Edit("data/Testy/BLU.lua", "BlueBuff = S { 'Cocoon' }", "BlueBuff = S { 'Foot Kick', 'Cocon' }");
	var run = sandbox.Run("check-blu-spells");
	Equal(1, run.ExitCode);
	Contains(run.Output, "Cocoon: in no list, so it casts in the idle set");
	Contains(run.Output, "Foot Kick: in BluePhysical and BlueBuff; only BluePhysical takes effect");
	Contains(run.Output, "BlueBuff names 'Cocon', which isn't a blue spell");
	Contains(run.Output, "problems: 3");
});

Test("sims shows a job's simulated sets and marks what the character lacks", () =>
{
	var list = pristine.Run("sims", "--job", "rdm");
	Contains(list.Output, "Savage Blade: Mid buff (54330 damage); High buff (56183 damage)");
	var set = pristine.Run("sims", "--job", "rdm", "--set", "savage");
	Contains(set.Output, "== Savage Blade, Mid buff: 54330 damage");
	Contains(set.Output, "  Head   Nyame Helm\n");
	Contains(set.Output, "  Ear2   Hoxne Earring  MISSING");
	Contains(set.Output, "  Body   Ayanmo Corazza +2  (on slip 23)\n");
	Contains(set.Output, "  Back   Sucellos's Cape [STR, Weapon Skill Damage]\n");
	Contains(pristine.Run("sims", "--job", "blu", "--set", "expiacion").Output, "  Main   Almace (Level 119 III)\n");
	var counts = pristine.Run("sims", "--job", "rdm", "--counts").Output;
	Contains(counts, "  Ear2   Hoxne Earring 1  MISSING");
	Contains(counts, "  Body   Ayanmo Corazza +2 1  (on slip 23)");
	Equal(2, pristine.Run("sims", "--job", "rdm", "--set", "no such set").ExitCode);
	Equal(2, pristine.Run("sims").ExitCode);
});

Test("doc-lint passes docs that are in order, and says which owned pieces have no notes", () =>
{
	var run = pristine.Run("doc-lint");
	Equal(0, run.ExitCode);
	Contains(run.Output, "No notes yet for 1 pieces in the bags: Ea Houppelande");
	Contains(run.Output, "No notes for 1 pieces on storage slips.");
	Contains(run.Output, "7 docs, ");
	Contains(run.Output, "problems: 0");
});

Test("doc-lint reports each kind of mistake in the docs", () =>
{
	var sandbox = NewSandbox();
	var notes = "docs/gear-notes.md";
	var own = "data/Testy/Testy_gear_notes.md";
	sandbox.Edit(notes, "(rank-augments.md#nyame-helm).", "(rank-augments.md#nyame-helmet).");
	sandbox.Edit(notes, "### Almace\n", "### Naegling\n");
	sandbox.Edit(notes, "RDM: Savage Blade (Mid buff, High buff); BLU: Expiacion (Mid buff).", "RDM: Savage Blade (Mid buff); BLU: Expiacion (Mid buff).");
	sandbox.Edit(notes, "No notes beyond the help text: Atro. Chapeau +4.", "No notes beyond the help text: Atro. Chapeau +4, Nyame Helm.");
	sandbox.Edit(own, "| Hoxne Earring | Savage Blade |", "| Hoxne Earring | Savage Blade | extra |");
	sandbox.Edit(own, "| Hoxne Earring | Expiacion |\n", "| Nyame Helm | Expiacion |\n");
	sandbox.Edit("docs/ffxi-mechanics.md", "A tilde inside code is fine", "See [nothing](nowhere.md), <b>bold</b> and ~a~ b. A tilde inside code is fine");
	var run = sandbox.Run("doc-lint");
	Equal(1, run.ExitCode);
	Contains(run.Output, "docs/gear-notes.md:27: broken anchor, rank-augments.md#nyame-helmet");
	Contains(run.Output, "docs/gear-notes.md:13: a second entry for Naegling");
	Contains(run.Output, "Nyame Helm: the bullet's sets differ from the pages\n    pages: RDM: Savage Blade (Mid buff, High buff); BLU: Expiacion (Mid buff)");
	Contains(run.Output, "Almace is in a bag and in the simulated sets, but its entry has no Simulated sets bullet");
	Contains(run.Output, "Nyame Helm is in a \"No notes\" list and has an entry");
	Contains(run.Output, "3 cells, but the table that starts at line ");
	Contains(run.Output, "data/Testy/Testy_gear_notes.md: the BLU table of pieces the sets use lacks Hoxne Earring (Expiacion)");
	Contains(run.Output, "Nyame Helm is in the BLU table of pieces the character lacks, but it is owned or no BLU set wears it");
	Contains(run.Output, "docs/ffxi-mechanics.md:13: link to a missing file, nowhere.md");
	Contains(run.Output, "docs/ffxi-mechanics.md:13: raw tag <b>");
	Contains(run.Output, "docs/ffxi-mechanics.md:13: two tildes on one line");
});

Test("doc-lint keeps what holds for one character out of docs/", () =>
{
	var sandbox = NewSandbox();
	sandbox.Edit("docs/gear-notes.md", "- Its Path B augments are in", "- Testy's copy is rank 2. Its Path B augments are in");
	sandbox.Edit("docs/ffxi-mechanics.md", "A small doc for the tools' tests.", "A small doc for the tools' tests. See `data/Testy/RDM.lua`.");
	var run = sandbox.Run("doc-lint");
	Equal(1, run.ExitCode);
	Contains(run.Output, "docs/gear-notes.md:27: names Testy. What holds for one character goes in data/Testy/");
	Contains(run.Output, "docs/ffxi-mechanics.md:3: names Testy.");
	Contains(run.Output, "problems: 2");
});

Test("doc-lint follows links between a character's own files and the docs", () =>
{
	var sandbox = NewSandbox();
	sandbox.Edit("data/Testy/Testy_notes.md", "(../../docs/ffxi-mechanics.md)", "(../../docs/no-such-doc.md)");
	sandbox.Edit("data/Testy/Testy_gear_notes.md", "(../../docs/gear-notes.md#nyame-helm)", "(../../docs/gear-notes.md#nyame-helmet)");
	sandbox.Edit("data/Testy/Testy_gear_list.md", "(Testy_notes.md)", "(Testy_notes.md#no-such-heading)");
	var run = sandbox.Run("doc-lint");
	Equal(1, run.ExitCode);
	Contains(run.Output, "data/Testy/Testy_notes.md:3: link to a missing file, ../../docs/no-such-doc.md");
	Contains(run.Output, "data/Testy/Testy_gear_notes.md:9: broken anchor, ../../docs/gear-notes.md#nyame-helmet");
	Contains(run.Output, "data/Testy/Testy_gear_list.md:7: broken anchor, Testy_notes.md#no-such-heading");
	Contains(run.Output, "problems: 3");
});

Test("doc-lint holds a character's gear notes to pieces the character has, one entry each", () =>
{
	var sandbox = NewSandbox();
	sandbox.Edit("data/Testy/Testy_gear_notes.md", "## Pieces the simulated sets use", "### Hoxne Earring\n\n- Testy wants one.\n\n### Nyame Helm\n\n- Again.\n\n## Pieces the simulated sets use");
	var run = sandbox.Run("doc-lint");
	Equal(1, run.ExitCode);
	Contains(run.Output, "data/Testy/Testy_gear_notes.md:11: Hoxne Earring has an entry, but it is neither in the export nor an entry of docs/gear-notes.md");
	Contains(run.Output, "data/Testy/Testy_gear_notes.md:15: a second entry for Nyame Helm");
	Contains(run.Output, "problems: 2");
});

Test("wsdist-gear finds an item's entries, and checks Nyame's against the rank doc", () =>
{
	var found = pristine.Run("wsdist-gear", "nyame helm r15");
	Contains(found.Output, "gear.py:8  Nyame Helm R15B  (Nyame_Helm15B)");
	Contains(found.Output, "Attack 50 (30+20)");
	Contains(found.Output, "2 of 4 entries");
	var clean = pristine.Run("wsdist-gear", "--check-nyame");
	Equal(0, clean.ExitCode);
	Contains(clean.Output, "2 ranked Nyame entries checked; differences: 0");
	var sandbox = NewSandbox();
	File.WriteAllText(Path.Combine(sandbox.Cache, "wsdist_beta", "gear.py"), File.ReadAllText(Path.Combine(sandbox.Cache, "wsdist_beta", "gear.py")).Replace("\"Attack\":30+20", "\"Attack\":30+19"));
	var wrong = sandbox.Run("wsdist-gear", "--check-nyame");
	Equal(1, wrong.ExitCode);
	Contains(wrong.Output, "gear.py:8 Nyame Helm R15B: wsdist adds Attack 19, Ranged Attack 20, Weapon Skill Damage 7 | bg-wiki Attack 20, Ranged Attack 20, Weapon Skill Damage 7");
	Equal(2, pristine.Run("wsdist-gear").ExitCode);
});

Test("search-fast-recast reads owned-gear's JSON, with the hidden Fast Cast values", () =>
{
	var pieces = Path.Combine(workDir, "pieces.json");
	File.WriteAllText(pieces, pristine.Run("owned-gear", "--job", "BLU", "--json").StandardOutput);
	var table = pristine.Run("search-fast-recast", pieces, "--table");
	Equal(0, table.ExitCode);
	Contains(table.Output, "left_ear   H 0 FC 2 B 0 J0 DT 0 wardrobe   RDM  Loquac. Earring");
	Contains(table.Output, "hands      H 3 FC 0 B16 J0 DT10 wardrobe   BLU  Hashi. Bazu. +3");
	var search = pristine.Run("search-fast-recast", pieces);
	Equal(0, search.ExitCode);
	Contains(search.Output, "===== pool=owned blue");
	Contains(search.Output, "Hashi. Bazu. +3(3/0/B16 DT10 wardrobe BLU)");
	Equal(2, pristine.Run("search-fast-recast").ExitCode);
});

Test("a tool built before an edit to the shared code stops until it is rebuilt", () =>
{
	var sandbox = NewSandbox();
	var copy = Path.Combine(sandbox.Repo, ".claude", "tools");
	Directory.CreateDirectory(Path.Combine(copy, "lib"));
	foreach (var file in Directory.GetFiles(Path.Combine(toolsDir, "lib"), "*.cs"))
		File.Copy(file, Path.Combine(copy, "lib", Path.GetFileName(file)));
	File.Copy(Path.Combine(toolsDir, "Directory.Build.props"), Path.Combine(copy, "Directory.Build.props"));
	File.Copy(Path.Combine(toolsDir, "check-blu-spells.cs"), Path.Combine(copy, "check-blu-spells.cs"));
	var tool = Path.Combine(copy, "check-blu-spells.cs");
	Equal(0, sandbox.RunFile(tool, true).ExitCode);
	Equal(0, sandbox.RunFile(tool, false).ExitCode);
	File.SetLastWriteTimeUtc(Path.Combine(copy, "lib", "Wiki.cs"), DateTime.UtcNow.AddSeconds(5));
	var stale = sandbox.RunFile(tool, false);
	Equal(2, stale.ExitCode);
	Contains(stale.Output, "This build is older than .claude/tools/lib. Run the tool again with: dotnet run --no-cache");
	File.SetLastWriteTimeUtc(Path.Combine(copy, "lib", "Wiki.cs"), DateTime.UtcNow.AddSeconds(-1));
	Equal(0, sandbox.RunFile(tool, true).ExitCode);
});

// ---------------------------------------------------------------- running them

var filter = args.Length > 0 ? args[0] : "";
var failed = 0;
var ran = 0;
foreach (var test in tests.Where(test => test.Key.Contains(filter, StringComparison.OrdinalIgnoreCase)))
{
	ran++;
	try
	{
		test.Value();
		Console.WriteLine("PASS " + test.Key);
	}
	catch (Exception problem)
	{
		failed++;
		Console.WriteLine("FAIL " + test.Key);
		Console.WriteLine("     " + problem.Message.Replace("\n", "\n     "));
	}
}
try
{
	ForceDelete(workDir);
}
catch (IOException)
{
	// A folder git or dotnet still holds open is left for the system to clear with the rest of the temp folder.
}
Console.WriteLine($"{ran - failed} of {ran} tests passed");
return failed > 0 ? 1 : 0;

// ---------------------------------------------------------------- helpers

Sandbox NewSandbox()
{
	var sandbox = new Sandbox(Path.Combine(workDir, "sandbox-" + Guid.NewGuid().ToString("N")[..8]), toolsDir);
	CopyFolder(Path.Combine(fixtureDir, "repo"), sandbox.Repo);
	CopyFolder(Path.Combine(fixtureDir, "cache"), sandbox.Cache);
	return sandbox;
}

void CopyFolder(string from, string to)
{
	foreach (var file in Directory.GetFiles(from, "*", SearchOption.AllDirectories))
	{
		var target = Path.Combine(to, Path.GetRelativePath(from, file));
		Directory.CreateDirectory(Path.GetDirectoryName(target)!);
		// Git may check the fixture out with either line ending; the tests are written against "\n".
		if (Path.GetExtension(file) is ".lua" or ".md" or ".py")
		{
			File.WriteAllText(target, File.ReadAllText(file).Replace("\r\n", "\n"));
		}
		else
		{
			File.Copy(file, target);
		}
	}
}

// Git marks its object files read-only, which stops a plain delete on Windows.
void ForceDelete(string folder)
{
	if (Directory.Exists(folder) is false)
		return;
	foreach (var file in Directory.GetFiles(folder, "*", SearchOption.AllDirectories))
		File.SetAttributes(file, FileAttributes.Normal);
	Directory.Delete(folder, true);
}

// A small repository with one commit, to fetch from without the network.
GitRepo NewGitRepo(string name)
{
	var path = Path.Combine(workDir, name);
	Directory.CreateDirectory(path);
	File.WriteAllText(Path.Combine(path, "file.txt"), "hello\n");
	string Git(params string[] arguments)
	{
		var start = new ProcessStartInfo("git") { WorkingDirectory = path, RedirectStandardOutput = true, RedirectStandardError = true };
		foreach (var argument in arguments)
			start.ArgumentList.Add(argument);
		using var process = Process.Start(start)!;
		var error = process.StandardError.ReadToEndAsync();
		var output = process.StandardOutput.ReadToEnd();
		process.WaitForExit();
		if (process.ExitCode != 0)
			throw new TestFailure($"git {string.Join(" ", arguments)} failed: {error.Result}");
		return output.Trim();
	}
	Git("init", "--quiet");
	// A fetch that asks for one commit with a blob filter, as GitSource does, needs the source to allow both.
	Git("config", "uploadpack.allowFilter", "true");
	Git("config", "uploadpack.allowAnySHA1InWant", "true");
	Git("add", "file.txt");
	Git("-c", "user.name=Tests", "-c", "user.email=tests@example.invalid", "-c", "commit.gpgsign=false", "commit", "--quiet", "-m", "One file");
	return new GitRepo(path, Git("rev-parse", "HEAD"));
}

OboroAugments TestOboro() => new OboroAugments(["## Oboro rank augments (maximum only)", "", "Oboro ranks these up.", ""],
	[new OboroItem("Almace", "main", 15, true, "DMG +5"), new OboroItem("Dls. Torque +1", "neck", 20, false, "INT and MND +12")]);

// Testy's newest export and Ranks table, with each copy passed through a change first.
CharacterRanks TestCharacterRanks(Func<ExportItem, ExportItem> change)
{
	var export = Export.Latest(null);
	return new CharacterRanks("Testy", Tool.RepoRelative(export), Export.Read(export).Select(change).ToList(), PlayerRanks.Read(Characters.Notes("Testy")));
}

void True(bool condition, string what)
{
	if (condition is false)
		throw new TestFailure("Not true: " + what);
}

void Equal<T>(T expected, T actual)
{
	if (EqualityComparer<T>.Default.Equals(expected, actual) is false)
		throw new TestFailure($"Expected: {expected}\nActual:   {actual}");
}

void Contains(string text, string part)
{
	if (text.Replace("\r", "").Contains(part) is false)
		throw new TestFailure($"Missing: {part}\nIn:\n{text.TrimEnd()}");
}

TException Throws<TException>(Action body)
	where TException : Exception
{
	try
	{
		body();
	}
	catch (TException expected)
	{
		return expected;
	}
	throw new TestFailure($"Expected a {typeof(TException).Name}, and nothing was thrown");
}

sealed class TestFailure : Exception
{
	public TestFailure(string message)
		: base(message)
	{
	}
}

// A repository made for one test, and its only commit.
sealed class GitRepo
{
	public string Path { get; }

	public string Commit { get; }

	public GitRepo(string path, string commit)
	{
		Path = path;
		Commit = commit;
	}
}

// What a tool printed and how it ended.
sealed class ToolRun
{
	public int ExitCode { get; }

	public string StandardOutput { get; }

	// Standard output and standard error together, as a terminal shows them.
	public string Output { get; }

	public ToolRun(int exitCode, string standardOutput, string standardError)
	{
		ExitCode = exitCode;
		StandardOutput = standardOutput;
		Output = standardOutput + standardError;
	}
}

// A copy of the fixture for one test to read or to break: a small repository and the cache beside it.
sealed class Sandbox
{
	public string Repo { get; }

	public string Cache { get; }

	string toolsDir;

	public Sandbox(string folder, string toolsDir)
	{
		Repo = Path.Combine(folder, "repo");
		Cache = Path.Combine(folder, "cache");
		this.toolsDir = toolsDir;
	}

	// Replaces one piece of text in a file of the sandbox's repository. The text has to be there exactly once.
	public void Edit(string relativePath, string oldText, string newText)
	{
		var path = Path.Combine(Repo, relativePath);
		var text = File.ReadAllText(path);
		var first = text.IndexOf(oldText, StringComparison.Ordinal);
		if (first < 0 || text.IndexOf(oldText, first + 1, StringComparison.Ordinal) >= 0)
			throw new TestFailure($"The fixture's {relativePath} doesn't hold this text exactly once: {oldText}");
		File.WriteAllText(path, text.Replace(oldText, newText));
	}

	// Runs one of the tools against this sandbox, as the command line does.
	public ToolRun Run(string tool, params string[] arguments) => Start(Path.Combine(toolsDir, tool + ".cs"), true, arguments);

	// Runs a tool file from anywhere, with or without --no-cache.
	public ToolRun RunFile(string toolFile, bool rebuild) => Start(toolFile, rebuild, []);

	ToolRun Start(string toolFile, bool rebuild, string[] arguments)
	{
		var start = new ProcessStartInfo("dotnet") { WorkingDirectory = Repo, RedirectStandardOutput = true, RedirectStandardError = true };
		start.ArgumentList.Add("run");
		if (rebuild)
			start.ArgumentList.Add("--no-cache");
		start.ArgumentList.Add(toolFile);
		start.ArgumentList.Add("--");
		foreach (var argument in arguments)
			start.ArgumentList.Add(argument);
		start.Environment["GEAR_TOOLS_ROOT"] = Repo;
		start.Environment["GEAR_TOOLS_CACHE"] = Cache;
		using var process = Process.Start(start)!;
		var error = process.StandardError.ReadToEndAsync();
		var output = process.StandardOutput.ReadToEnd();
		process.WaitForExit();
		return new ToolRun(process.ExitCode, output, error.Result);
	}
}
