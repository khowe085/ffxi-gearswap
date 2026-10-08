// Tests for the tools in the folder above. They run against the small made-up character under fixture/ (Testy),
// never against the real data: the shared code is called directly, and each tool is run as it is from the command
// line, pointed at a copy of the fixture, once as it stands and once with mistakes put in that the tool has to
// report.
//
//   dotnet run --no-cache .claude/tools/tests/run-tests.cs [-- <text>]
//
// With <text>, only the tests whose name contains it run. Exit code 1 when a test fails. Nothing here uses the
// network: wiki.cs and rank-tables.cs ask a stand-in for bg-wiki on this machine, and they and fetch-sources.cs
// are also run with the network cut off, to see them stop. The git sources are fetched from repositories made here.
// That leaves two things no test runs: a download of Windower's resources that works, and the wait after bg-wiki
// answers 429.
using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Diagnostics;
using System.IO;
using System.Net;
using System.Net.Sockets;
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
// The tests call the shared code in this process, so a build older than lib/ would test the old code.
Tool.Init();

var tests = new List<KeyValuePair<string, Action>>();
void Test(string name, Action body) => tests.Add(KeyValuePair.Create(name, body));

// ---------------------------------------------------------------- the shared code

Test("Export.Latest takes the newest export by the date in its name, under either spelling", () =>
{
	// The fixture has an export of the same day, an hour earlier, under the underscore spelling.
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

Test("Resources gives the name the export prints, whichever of an item's two names it is asked by", () =>
{
	var resources = Resources.Load();
	Equal("Hashi. Bazu. +3", resources.ExportName("Hashishin Bazubands +3"));
	Equal("Hashi. Bazu. +3", resources.ExportName("Hashi. Bazu. +3"));
	Equal("No Such Item", resources.ExportName("No Such Item"));
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

Test("a character named in another case is still the one whose folder it is", () =>
{
	var sandbox = NewSandbox();
	sandbox.Edit("data/Testy/Testy_gear_notes.md", "| Hoxne Earring | Savage Blade |", "| Hoxne Earring | Chant du Cygne |");
	var run = sandbox.Run("doc-lint", "--char", "testy");
	Equal(1, run.ExitCode);
	Contains(run.Output, "data/Testy/Testy_gear_notes.md:");
	Contains(run.Output, "Hoxne Earring, RDM sets");
	Equal("Testy", Characters.Named("testy"));
	Equal("Nobody", Characters.Named("Nobody"));
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

Test("Markdown.IsDelimiterRow knows the row under a table's header, however it is spaced or aligned", () =>
{
	string[] rows = ["|---|---|", "| --- | :--- | ---: | :-: |", "|---|---", "| - |"];
	foreach (var row in rows)
		True(Markdown.IsDelimiterRow(row), row + " is a delimiter row");
	string[] others = ["| a | b |", "||", "| |", "---", "| Nyame Helm | - |"];
	foreach (var other in others)
		True(Markdown.IsDelimiterRow(other) is false, other + " isn't a delimiter row");
});

Test("PlayerRanks reads a Ranks table whose delimiter row sets the alignment", () =>
{
	var notes = Path.Combine(workDir, "notes-with-aligned-ranks.md");
	File.WriteAllText(notes, "## Ranks\n\n| Item | Path | Rank | Given |\n|:---|:---:|---:| --- |\n| Nyame Helm | B | 2 | 2026-01-03 |\n");
	var ranks = PlayerRanks.Read(notes);
	Equal("Nyame Helm", string.Join(", ", ranks.Keys));
	Equal(2, ranks["Nyame Helm"].Rank);
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

Test("Wiki.Read takes the pages, the renamed titles and the continuation out of a reply", () =>
{
	var reply = Wiki.Read("""
		{"continue":{"rvcontinue":"12|34","continue":"||"},"query":{
		"normalized":[{"from":"Nyame_Helm","to":"Nyame Helm"},{"from":"Obstinate_Sash","to":"Obstinate Sash"}],
		"redirects":[{"from":"Obstinate Sash","to":"Obstin. Sash"}],
		"pages":[{"title":"Nyame Helm","revisions":[{"slots":{"main":{"content":"helm text"}}}]},{"title":"Obstin. Sash"},{"title":"No Such Page","missing":true}]}}
		""");
	Equal("helm text", reply.Texts["Nyame Helm"]);
	Equal(1, reply.Texts.Count);
	Equal("12|34", reply.Continue["rvcontinue"]);
	Equal("||", reply.Continue["continue"]);
	Equal("Nyame Helm", Wiki.Settled("Nyame_Helm", reply.Renamed));
	Equal("Obstin. Sash", Wiki.Settled("Obstinate_Sash", reply.Renamed));
	Equal("Naegling", Wiki.Settled("Naegling", reply.Renamed));
	Equal(0, Wiki.Read("""{"batchcomplete":true,"query":{"pages":[]}}""").Continue.Count);
});

Test("Wiki.Read refuses an error from the API, and a reply that isn't JSON", () =>
{
	Contains(Throws<InvalidOperationException>(() => Wiki.Read("""{"error":{"code":"toomanyvalues","info":"Too many values supplied for parameter \"titles\"."}}""")).Message, "toomanyvalues: Too many values supplied");
	Contains(Throws<InvalidOperationException>(() => Wiki.Read("""{"batchcomplete":true}""")).Message, "without a query");
	Contains(Throws<InvalidOperationException>(() => Wiki.Read("<html>Just a moment...</html>")).Message, "isn't JSON");
});

Test("Wiki.Fetch asks again for the rest of a reply the wiki cut short, and keys each page as it was asked for", () =>
{
	var asked = new List<string>();
	var replies = new Queue<string>([
		"""{"continue":{"rvcontinue":"12|34","continue":"||"},"query":{"normalized":[{"from":"Nyame_Helm","to":"Nyame Helm"}],"redirects":[{"from":"Obstinate Sash","to":"Obstin. Sash"}],"pages":[{"title":"Nyame Helm","revisions":[{"slots":{"main":{"content":"helm text"}}}]},{"title":"Obstin. Sash"},{"title":"No Such Page","missing":true}]}}""",
		"""{"batchcomplete":true,"query":{"normalized":[{"from":"Nyame_Helm","to":"Nyame Helm"}],"redirects":[{"from":"Obstinate Sash","to":"Obstin. Sash"}],"pages":[{"title":"Nyame Helm"},{"title":"Obstin. Sash","revisions":[{"slots":{"main":{"content":"sash text"}}}]},{"title":"No Such Page","missing":true}]}}""",
	]);
	var pages = Wiki.Fetch(["Nyame_Helm", "Obstinate Sash", "No Such Page"], url =>
	{
		asked.Add(url);
		return Task.FromResult(replies.Dequeue());
	}).GetAwaiter().GetResult();
	Equal(2, asked.Count);
	True(asked[0].EndsWith("&titles=Nyame_Helm%7CObstinate%20Sash%7CNo%20Such%20Page"), asked[0]);
	Equal(asked[0] + "&continue=%7C%7C&rvcontinue=12%7C34", asked[1]);
	Equal("Nyame Helm", pages["Nyame_Helm"].Title);
	Equal("helm text", pages["Nyame_Helm"].Text);
	Equal("Obstin. Sash", pages["Obstinate Sash"].Title);
	Equal("sash text", pages["Obstinate Sash"].Text);
	Equal(2, pages.Count);
});

Test("Wiki.Fetch gives up on a wiki that never finishes a reply", () =>
{
	var requests = 0;
	var endless = """{"continue":{"rvcontinue":"1|2","continue":"||"},"query":{"pages":[{"title":"Naegling"}]}}""";
	var problem = Throws<InvalidOperationException>(() => Wiki.Fetch(["Naegling"], url =>
	{
		requests++;
		return Task.FromResult(endless);
	}).GetAwaiter().GetResult());
	Contains(problem.Message, "kept answering in parts");
	Equal(2, requests);
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

Test("RankDoc.RenderCharacter says the export prints a piece bare only when it prints the piece", () =>
{
	// A slip records nothing of the augments, and a piece in no bag isn't printed at all.
	var onSlip = TestCharacterRanks(copy => copy.Name == "Obstin. Sash" ? new ExportItem("slip5", copy.SlotKey, copy.Name, []) : copy);
	var text = string.Join("\n", RankDoc.RenderCharacter(RankTables.Load(), Resources.Load(), TestOboro(), onSlip));
	True(text.Contains("The export prints") is false, text);
	Contains(text, "| [Obstin. Sash](../../docs/rank-augments.md#obstin-sash) | waist | A | 20 | 2026-01-02 | Mag. Acc.+15, Enfb. mag. skill +5 |");
	var absent = TestCharacterRanks(copy => copy.Name == "Obstin. Sash" ? new ExportItem(copy.Bag, copy.SlotKey, "Rumination Sash", []) : copy);
	text = string.Join("\n", RankDoc.RenderCharacter(RankTables.Load(), Resources.Load(), TestOboro(), absent));
	True(text.Contains("The export prints") is false, text);
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

Test("RankDoc.RenderCharacter refuses a path the item lacks, a rank its table lacks, and a path the export contradicts", () =>
{
	string Refusal(string item, PlayerRank rank)
	{
		var data = TestCharacterRanks(copy => copy);
		data.Ranks[item] = rank;
		return Throws<InvalidOperationException>(() => RankDoc.RenderCharacter(RankTables.Load(), Resources.Load(), TestOboro(), data)).Message;
	}
	Contains(Refusal("Nyame Helm", new PlayerRank("b", 1, "2026-01-03")), "Nyame Helm has no path \"b\". Its paths: A, B, C.");
	Contains(Refusal("Obstin. Sash", new PlayerRank("A", 31, "2026-01-03")), "Obstin. Sash has no rank 31 on path A. Its ranks there: 1, 20.");
	Contains(Refusal("Nyame Helm", new PlayerRank("A", 1, "2026-01-03")), "gives Nyame Helm path A, but the export prints 'Path: B'.");
	// Rank 0 needs no row: it is the unranked piece.
	var unranked = TestCharacterRanks(copy => copy);
	unranked.Ranks["Coiste Bodhar"] = new PlayerRank("A", 0, "2026-01-03");
	Contains(string.Join("\n", RankDoc.RenderCharacter(RankTables.Load(), Resources.Load(), TestOboro(), unranked)), "| ammo | A | 0 | 2026-01-03 | none (base stats only) |");
});

Test("RankDoc.RenderCharacter refuses an export that prints a path for an item no rank table covers", () =>
{
	var data = TestCharacterRanks(copy => copy.Name == "Prolix Ring" ? new ExportItem(copy.Bag, copy.SlotKey, copy.Name, ["Path: A"]) : copy);
	var failure = Throws<InvalidOperationException>(() => RankDoc.RenderCharacter(RankTables.Load(), Resources.Load(), TestOboro(), data));
	Contains(failure.Message, "data/export/Testy 2026-01-02 08-00-00.lua prints a path for Prolix Ring, and no rank table goes by that name.");
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
	var failure = Throws<InvalidOperationException>(() => GitSource.Fetch(target, Path.Combine(workDir, "no-such-repo"), source.Commit));
	Contains(failure.Message, $"git fetch --quiet --depth 1 --filter=blob:none origin {source.Commit} failed in {target}: ");
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
	var grep = pristine.Run("owned-gear", "--grep", "(");
	Equal(2, grep.ExitCode);
	Contains(grep.Output, "--grep isn't a regular expression");
	var pattern = pristine.Run("wsdist-gear", "nyame (");
	Equal(2, pattern.ExitCode);
	Contains(pattern.Output, "The item pattern isn't a regular expression");
});

// ---------------------------------------------------------------- gear-list.cs

Test("a tool stops on a value it can't use: a character, an export, a slot, a job or a set", () =>
{
	Stops(pristine.Run("check-export", "--job"), "--job needs a value.");
	Stops(pristine.Run("check-export", "--char", "Nobody"), "No export for Nobody in data/export.");
	Stops(pristine.Run("check-export", "--export", "nowhere.lua"), "No export at nowhere.lua.");
	Stops(pristine.Run("check-export", "--export", Path.Combine("data", "Testy", "RDM.lua")), "RDM.lua isn't named like a //gs export (<character> <date> <time>.lua).");
	Stops(pristine.Run("owned-gear", "--slot", "bogus"), "bogus isn't a slot. Slots: main sub range ammo head neck ear body hands ring back waist legs feet");
	Stops(pristine.Run("owned-gear", "--job", "XYZ"), "XYZ isn't a job. Jobs: WAR MNK");
	Stops(pristine.Run("sims"), "Name the job: --job rdm");
	Stops(pristine.Run("sims", "--job", "nope"), "No simulated sets for nope in .claude/cache/bg_job_guides. Run: dotnet run --no-cache .claude/tools/fetch-sources.cs");
	Stops(pristine.Run("sims", "--job", "rdm", "--set", "zzzz"), "No set on the rdm page has \"zzzz\" in its name.");
	Stops(pristine.Run("wsdist-gear"), "Give one regex to match item names against, or --check-nyame.");
	Stops(pristine.Run("wsdist-gear", "nyame", "helm"), "Give one regex to match item names against, or --check-nyame.");
	Stops(pristine.Run("wiki"), "Name at least one page: dotnet run --no-cache .claude/tools/wiki.cs -- \"Nyame Helm\"");
	// With exports for two characters, a tool has to be told whose to read.
	var two = NewSandbox();
	File.Copy(Path.Combine(two.Repo, "data", "export", "Testy 2026-01-02 08-00-00.lua"), Path.Combine(two.Repo, "data", "export", "Ghost 2026-02-01 08-00-00.lua"));
	Stops(two.Run("check-export"), "data/export holds exports for 2 characters (Ghost, Testy). Pass --char <name>.");
	Stops(two.Run("check-export", "--char", "Ghost"), "No folder data/Ghost.");
	Equal(0, two.Run("check-export", "--char", "Testy").ExitCode);
});

Test("a tool stops when the file it checks, or the engine it checks against, isn't there", () =>
{
	var sandbox = NewSandbox();
	File.Delete(Path.Combine(sandbox.Repo, "data", "Testy", "BLU.lua"));
	File.Delete(Path.Combine(sandbox.Repo, "data", "Testy", "Testy_gear_list.md"));
	Stops(sandbox.Run("check-blu-spells"), "No data/Testy/BLU.lua.");
	Stops(sandbox.Run("gear-list"), "No gear list at data/Testy/Testy_gear_list.md.");
	Directory.Delete(Path.Combine(sandbox.Repo, "data", "common"), true);
	Stops(sandbox.Run("check-export"), "data/common/RahvinGS/GearSets-Include.lua is missing. Run: git submodule update --init");
});

Test("a tool that finds part of the cache missing names the command that fills it", () =>
{
	var sandbox = NewSandbox();
	File.Delete(Path.Combine(sandbox.Cache, "res", "spells.lua"));
	Stops(sandbox.Run("check-blu-spells"), "Windower's resources aren't in .claude/cache. Run: dotnet run --no-cache .claude/tools/fetch-sources.cs");
	File.Delete(Path.Combine(sandbox.Cache, "res", "items.lua"));
	Stops(sandbox.Run("owned-gear"), "Windower's resources aren't in .claude/cache. Run: dotnet run --no-cache .claude/tools/fetch-sources.cs");
	Directory.Delete(Path.Combine(sandbox.Cache, "ranks"), true);
	Stops(sandbox.Run("rank-doc", "--check"), "bg-wiki's rank tables aren't in .claude/cache. Run: dotnet run --no-cache .claude/tools/rank-tables.cs");
	Directory.Delete(Path.Combine(sandbox.Cache, "wsdist_beta"), true);
	Stops(sandbox.Run("wsdist-gear", "nyame"), "wsdist isn't in .claude/cache. Run: dotnet run --no-cache .claude/tools/fetch-sources.cs");
	// doc-lint goes on without the simulated sets, and says so.
	Directory.Delete(Path.Combine(sandbox.Cache, "bg_job_guides"), true);
	var lint = sandbox.Run("doc-lint");
	Equal(0, lint.ExitCode);
	Contains(lint.Output, "Simulated sets not checked: .claude/cache/bg_job_guides is missing. Run fetch-sources.cs.");
});

Test("a tool stops, and says what is missing, when the repository lacks a folder or a file it reads", () =>
{
	var noExports = NewSandbox();
	Directory.Delete(Path.Combine(noExports.Repo, "data", "export"), true);
	var export = noExports.Run("check-export");
	Equal(2, export.ExitCode);
	Contains(export.Output, "data/export holds no //gs export");
	var noEngine = NewSandbox();
	Directory.Delete(Path.Combine(noEngine.Repo, "data", "common"), true);
	var spells = noEngine.Run("check-blu-spells");
	Equal(2, spells.ExitCode);
	Contains(spells.Output, "data/common/RahvinGS/interface.lua is missing");
	var noDocs = NewSandbox();
	Directory.Delete(Path.Combine(noDocs.Repo, "docs"), true);
	var lint = noDocs.Run("doc-lint");
	Equal(1, lint.ExitCode);
	Contains(lint.Output, "link to a missing file, ../../docs/rank-augments.md");
	var nyame = noDocs.Run("wsdist-gear", "--check-nyame");
	Equal(2, nyame.ExitCode);
	Contains(nyame.Output, "docs/rank-augments.md is missing");
	// rank-doc makes the folder its document goes in.
	Equal(0, noDocs.Run("rank-doc").ExitCode);
	True(File.Exists(Path.Combine(noDocs.Repo, "docs", "rank-augments.md")), "rank-doc didn't write docs/rank-augments.md");
});

Test("a tool stops when a file it reads holds nothing it can use", () =>
{
	var ranks = NewSandbox();
	File.WriteAllText(Path.Combine(ranks.Cache, "ranks", "ranks.json"), "{ not json");
	Stops(ranks.Run("rank-doc", "--check"), "ranks.json can't be read");
	File.WriteAllText(Path.Combine(ranks.Cache, "ranks", "ranks.json"), "null");
	Stops(ranks.Run("rank-doc", "--check"), "ranks.json can't be read");
	var items = NewSandbox();
	File.WriteAllText(Path.Combine(items.Cache, "res", "items.lua"), "");
	Stops(items.Run("owned-gear"), "res/items.lua holds no weapon or armor");
	var spells = NewSandbox();
	File.WriteAllText(Path.Combine(spells.Cache, "res", "spells.lua"), "");
	Stops(spells.Run("check-blu-spells"), "res/spells.lua holds no blue spell");
	var wsdist = NewSandbox();
	File.WriteAllText(Path.Combine(wsdist.Cache, "wsdist_beta", "gear.py"), "Naegling = {\"Name\":\"Naegling\", \"DMG\":166}\n");
	Stops(wsdist.Run("wsdist-gear", "--check-nyame"), "gear.py has no ranked Nyame entry");
	File.WriteAllText(Path.Combine(wsdist.Cache, "wsdist_beta", "gear.py"), "");
	Stops(wsdist.Run("wsdist-gear", "nyame"), "wsdist_beta holds no item entry");
	var page = NewSandbox();
	File.WriteAllText(Path.Combine(page.Cache, "bg_job_guides", "rdm.md"), "");
	Stops(page.Run("sims", "--job", "rdm"), "holds no simulated set");
	var export = NewSandbox();
	File.WriteAllText(Path.Combine(export.Repo, "data", "export", "Testy 2026-01-02 08-00-00.lua"), "garbage");
	Stops(export.Run("owned-gear"), "holds no items");
	var jobless = NewSandbox();
	File.Delete(Path.Combine(jobless.Repo, "data", "Testy", "BLU.lua"));
	File.Delete(Path.Combine(jobless.Repo, "data", "Testy", "RDM.lua"));
	Stops(jobless.Run("check-export"), "holds no job file");
});

Test("a tool that needs the network stops with exit code 2 when it can't be reached", () =>
{
	var sandbox = NewSandbox();
	var tables = Path.Combine(sandbox.Cache, "ranks", "ranks.json");
	var saved = File.ReadAllText(tables);
	var wiki = sandbox.RunOffline("wiki", "Nyame Helm");
	Equal(2, wiki.ExitCode);
	Contains(wiki.Output, "Couldn't reach bg-wiki");
	var ranks = sandbox.RunOffline("rank-tables");
	Equal(2, ranks.ExitCode);
	Contains(ranks.Output, "Couldn't reach bg-wiki");
	Equal(saved, File.ReadAllText(tables));
	var sources = sandbox.RunOffline("fetch-sources", "--refresh");
	Equal(2, sources.ExitCode);
	Contains(sources.Output, "res/items.lua: couldn't download it");
	// Without --refresh the resources in the cache stay as they are, and the first repository git can't fetch stops it.
	var repositories = sandbox.RunOffline("fetch-sources");
	Equal(2, repositories.ExitCode);
	Contains(repositories.Output, "res/items.lua: present (");
	Contains(repositories.Output, "wsdist_beta: git fetch --quiet --depth 1 --filter=blob:none origin d12ac5923ccace977ad55d172c8698b5886b9e4f failed in ");
});

Test("wiki saves each page under the name it was asked by, says which it couldn't find, and asks once", () =>
{
	var reply = """
		{"batchcomplete":true,"query":{
		"redirects":[{"from":"Obstinate Sash","to":"Obstin. Sash"}],
		"pages":[{"title":"Nyame Helm","revisions":[{"slots":{"main":{"content":"helm text"}}}]},
		{"title":"Obstin. Sash","revisions":[{"slots":{"main":{"content":"sash text"}}}]},
		{"title":"Category:Enspell","revisions":[{"slots":{"main":{"content":"enspell text"}}}]},
		{"title":"No Such Page","missing":true}]}}
		""";
	using var site = new StandInSite(request => new StandInReply(200, reply));
	var sandbox = NewSandbox();
	var run = sandbox.RunAgainst(site, "wiki", "Nyame Helm", "Obstinate Sash", "Category:Enspell", "No Such Page");
	Equal(1, run.ExitCode);
	Contains(run.Output, "saved   ../cache/wiki/Nyame_Helm.txt (9 chars)\n");
	Contains(run.Output, "saved   ../cache/wiki/Obstinate_Sash.txt (9 chars) (the page is \"Obstin. Sash\")");
	Contains(run.Output, "saved   ../cache/wiki/Category_Enspell.txt (12 chars)");
	Contains(run.Output, "MISSING No Such Page: bg-wiki has no page by that name");
	Equal("sash text", File.ReadAllText(Path.Combine(sandbox.Cache, "wiki", "Obstinate_Sash.txt")));
	Equal(1, site.Requests.Count);
	Contains(site.Requests[0], "titles=Nyame Helm|Obstinate Sash|Category:Enspell|No Such Page");
	// A page already saved is asked for again only with --refresh.
	var again = sandbox.RunAgainst(site, "wiki", "Category:Enspell");
	Equal(0, again.ExitCode);
	Contains(again.Output, "cached  ../cache/wiki/Category_Enspell.txt (12 bytes, from ");
	Equal(1, site.Requests.Count);
	Equal(0, sandbox.RunAgainst(site, "wiki", "--refresh", "Category:Enspell").ExitCode);
	Equal(2, site.Requests.Count);
});

Test("wiki stops when bg-wiki answers with an error, in HTTP or in its reply", () =>
{
	var sandbox = NewSandbox();
	using var busy = new StandInSite(request => new StandInReply(503, "busy"));
	Stops(sandbox.RunAgainst(busy, "wiki", "Nyame Helm"), "bg-wiki answered 503 for http://127.0.0.1:");
	using var refusing = new StandInSite(request => new StandInReply(200, """{"error":{"code":"maxlag","info":"Waiting for a database server"}}"""));
	Stops(sandbox.RunAgainst(refusing, "wiki", "Nyame Helm"), "bg-wiki's API answered with an error, maxlag: Waiting for a database server");
	Equal(0, Directory.GetFiles(Path.Combine(sandbox.Cache, "wiki")).Length);
});

Test("rank-tables saves the rank table of every exported item whose page has one", () =>
{
	var helm = string.Join("\n", "|RankMax=30", "{{Augment Rank Table", "|Path=A", "{{Augment Rank Row", "|Rank=1", "|Augment1=Accuracy+1", "|Augment2=---", "}}",
		"|Path=B", "{{Augment Rank Row", "|Rank=1", "|Augment1=Attack+3 Rng. Atk.+3", "|Augment2=---", "|Augment3=---", "}}", "}}");
	string Reply(string helmText) => "{\"query\":{\"pages\":[{\"title\":\"Naegling\",\"revisions\":[{\"slots\":{\"main\":{\"content\":\"no table here\"}}}]},"
		+ "{\"title\":\"Nyame Helm\",\"revisions\":[{\"slots\":{\"main\":{\"content\":" + JsonSerializer.Serialize(helmText) + "}}}]}]}}";
	using var site = new StandInSite(request => new StandInReply(200, Reply(helm)));
	var sandbox = NewSandbox();
	var run = sandbox.RunAgainst(site, "rank-tables");
	Equal(0, run.ExitCode);
	Contains(run.Output, "1 items with rank tables, from data/export/Testy 2026-01-02 08-00-00.lua: Nyame Helm");
	Contains(run.Output, "No bg-wiki page under the export's name for: Rumination Sash, Almace, Ammurapi Shield, ");
	Equal(1, site.Requests.Count);
	Contains(site.Requests[0], "titles=Rumination Sash|Naegling|Almace|");
	var path = Path.Combine(sandbox.Cache, "ranks", "ranks.json");
	using var saved = JsonDocument.Parse(File.ReadAllText(path));
	Equal(DateTime.Today.ToString("yyyy-MM-dd"), saved.RootElement.GetProperty("Fetched").GetString());
	var items = saved.RootElement.GetProperty("Items");
	Equal(1, items.GetArrayLength());
	Equal("Nyame Helm", items[0].GetProperty("Name").GetString());
	Equal(30, items[0].GetProperty("RankMax").GetInt32());
	Equal("A B", string.Join(" ", items[0].GetProperty("Paths").EnumerateArray().Select(entry => entry.GetProperty("Path").GetString())));
	Equal("Attack+3 Rng. Atk.+3", items[0].GetProperty("Paths")[1].GetProperty("Ranks")[0].GetProperty("Augments")[0].GetString());
	// A page whose table can't be read stops the run, and the tables saved before stay.
	var before = File.ReadAllText(path);
	using var odd = new StandInSite(request => new StandInReply(200, Reply("{{Augment Rank Table\n|Path=A\n}}")));
	Stops(sandbox.RunAgainst(odd, "rank-tables"), "bg-wiki's Nyame Helm page has an Augment Rank Table, but not every path's rows could be read from it.");
	Equal(before, File.ReadAllText(path));
});

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

Test("gear-list reports rows, counts, copies and totals that differ from the job files", () =>
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

Test("gear-list wants a row for each of two identical copies", () =>
{
	var sandbox = NewSandbox();
	var list = "data/Testy/Testy_gear_list.md";
	sandbox.Edit(list, "| Stikini Ring | one of two identical copies |  | `Idle` |\n| Stikini Ring | one of two identical copies |  | `Idle` |\n", "| Stikini Ring | one of two identical copies |  | `Idle` |\n");
	sandbox.Edit(list, "## Rings (3)", "## Rings (2)");
	sandbox.Edit(list, "**17 pieces** (3 for BLU, 15 for RDM, 1 worn by both)", "**16 pieces** (3 for BLU, 14 for RDM, 1 worn by both)");
	var run = sandbox.Run("gear-list");
	Equal(1, run.ExitCode);
	Contains(run.Output, "Stikini Ring: no row left, since another copy took its one row. Expected: BLU:  | RDM: `Idle`");
	Contains(run.Output, "problems: 1");
});

Test("gear-list reads the totals from the list's opening sentence only", () =>
{
	var sandbox = NewSandbox();
	var list = "data/Testy/Testy_gear_list.md";
	sandbox.Edit(list, "(3 for BLU, 15 for RDM, 1 worn by both)", "(3 for BLU)");
	sandbox.Edit(list, "## Reference\n", "## Reference\n\nThe notes say 99 for RDM, which isn't a count of this list.\n");
	var run = sandbox.Run("gear-list");
	Equal(0, run.ExitCode);
	Contains(run.Output, "problems: 0");
});

Test("gear-list counts a malformed row or a column with no job file as a problem in the list", () =>
{
	var sandbox = NewSandbox();
	sandbox.Edit("data/Testy/Testy_gear_list.md", "| Naegling |  |  | `Weapons['Savage Blade']` |", "| Naegling |  |  | `Weapons['Savage Blade']` | extra |");
	var malformed = sandbox.Run("gear-list");
	Equal(1, malformed.ExitCode);
	Contains(malformed.Output, "line 17: 5 cells, but the header has 4");
	var orphaned = NewSandbox();
	File.Delete(Path.Combine(orphaned.Repo, "data", "Testy", "BLU.lua"));
	var column = orphaned.Run("gear-list");
	Equal(1, column.ExitCode);
	Contains(column.Output, "The list has a BLU column, but there is no data/Testy/BLU.lua");
});

Test("gear-list leaves tables outside the gear sections alone, and reports a section whose columns differ", () =>
{
	var sandbox = NewSandbox();
	var list = "data/Testy/Testy_gear_list.md";
	sandbox.Edit(list, "## Reference\n", "## Reference\n\n| File | What it holds |\n|---|---|\n| Testy_notes.md | The player's rules |\n");
	var reference = sandbox.Run("gear-list");
	Equal(0, reference.ExitCode);
	Contains(reference.Output, "problems: 0");
	sandbox.Edit(list, "## Ammo (1)\n\n| Item | Copy | BLU sets | RDM sets |\n|---|---|---|---|\n| Coiste Bodhar |  |  | `WS` |", "## Ammo (1)\n\n| Item | Copy | RDM sets |\n|---|---|---|\n| Coiste Bodhar |  | `WS` |");
	var columns = sandbox.Run("gear-list");
	Equal(1, columns.ExitCode);
	Contains(columns.Output, "## Ammo has the job columns RDM, but the list's first table has BLU, RDM");
	Contains(columns.Output, "problems: 1");
});

Test("gear-list reports a key with no entry, a piece worn under two sections, and a row the export doesn't back", () =>
{
	var sets = NewSandbox();
	sets.Edit("data/Testy/RDM.lua", "\tsets.WS = { ammo = gear.coiste }\n", "\tsets.WS = { ammo = gear.coiste, neck = gear.noSuchKey, waist = gear.nyameHead }\n");
	var worn = sets.Run("gear-list");
	Equal(1, worn.ExitCode);
	Contains(worn.Output, "RDM: gear.noSuchKey (line 45) has no definition; check-export.cs reports these");
	Contains(worn.Output, "RDM: gear.nyameHead is worn in waist (Waist) at line 45, but elsewhere under Head");
	var rows = NewSandbox();
	var list = "data/Testy/Testy_gear_list.md";
	rows.Edit(list, "| Eschan Stone |  |", "| Eschan Stonee |  |");
	rows.Edit(list, "| Prolix Ring |  |", "| Prolix Ring | one of two identical copies |");
	var unbacked = rows.Run("gear-list");
	Equal(1, unbacked.ExitCode);
	Contains(unbacked.Output, "Eschan Stonee isn't in the export");
	Contains(unbacked.Output, "Prolix Ring is listed as one of several copies, but the export has 1");
	Contains(unbacked.Output, "Prolix Ring: the Copy column says [one of two identical copies], but the export has one copy, so the column stays empty");
	// Three identical copies need three rows.
	var third = NewSandbox();
	third.Edit("data/Testy/RDM.lua", "gear.stikini2 = hp_gear(\"Stikini Ring\", 0)\n", "gear.stikini2 = hp_gear(\"Stikini Ring\", 0)\ngear.stikini3 = hp_gear(\"Stikini Ring\", 0)\n");
	third.Edit("data/Testy/RDM.lua", "\tsets.WS = { ammo = gear.coiste }\n", "\tsets.WS = { ammo = gear.coiste, left_ring = gear.stikini3 }\n");
	Contains(third.Run("gear-list").Output, "Stikini Ring: no row left, since another copy took each of its 2 rows. Expected: BLU:  | RDM: `WS`");
});

Test("gear-list says it once when the files wear two copies of a piece and the export holds one", () =>
{
	var sandbox = NewSandbox();
	var export = Path.Combine(sandbox.Repo, "data", "export", "Testy 2026-01-02 08-00-00.lua");
	File.WriteAllText(export, File.ReadAllText(export).Replace("        left_ring=\"Stikini Ring\",\n        left_ring=\"Stikini Ring\",\n", "        left_ring=\"Stikini Ring\",\n"));
	var run = sandbox.Run("gear-list");
	Equal(1, run.ExitCode);
	Contains(run.Output, "Stikini Ring is listed as one of several copies, but the export has 1");
	True(run.Output.Contains("one of 1 identical") is false, run.Output);
	Contains(run.Output, "problems: 2");
});

Test("gear-list --print gives the table to start a list from when the character has none", () =>
{
	var sandbox = NewSandbox();
	File.Delete(Path.Combine(sandbox.Repo, "data", "Testy", "Testy_gear_list.md"));
	var run = sandbox.Run("gear-list", "--print");
	Equal(1, run.ExitCode);
	Contains(run.Output, "## Weapons (3)\n\n| Item | Copy | BLU sets | RDM sets |\n|---|---|---|---|\n| Ammurapi Shield |  |  | `Weapons['Savage Blade']` |");
	Contains(run.Output, "No gear list at data/Testy/Testy_gear_list.md yet. The table above is the one to start it from");
	Contains(run.Output, "problems: 1");
});

Test("gear-list reports two loops over one variable that both wear gear, since it can't tell their sets apart", () =>
{
	var loop = "\t\tsets.WS[ws].ACC = set_combine(sets.WS[ws], { waist = gear.eschan })\n\tend\n";
	var sandbox = NewSandbox();
	sandbox.Edit("data/Testy/RDM.lua", loop, loop + "\tfor _, ws in ipairs({ 'Chant du Cygne' }) do\n\t\tsets.WS[ws].ACC = set_combine(sets.WS[ws], { ammo = gear.coiste })\n\tend\n");
	var run = sandbox.Run("gear-list");
	Equal(1, run.ExitCode);
	Contains(run.Output, "RDM: sets named by the loop variable ws wear gear in the loops at lines 46, 50. The list words such a set by its variable alone, so give each loop a variable of its own");
	// A second loop that wears nothing takes no wording, so it is no trouble.
	var bare = NewSandbox();
	bare.Edit("data/Testy/RDM.lua", loop, loop + "\tfor _, ws in ipairs({ 'Chant du Cygne' }) do\n\t\tsets.WS[ws].ACC = set_combine(sets.WS[ws], {})\n\tend\n");
	Equal(0, bare.Run("gear-list").ExitCode);
});

Test("gear-list reads each table by its own header, and says so when it can't", () =>
{
	var list = "data/Testy/Testy_gear_list.md";
	var ammo = "## Ammo (1)\n\n| Item | Copy | BLU sets | RDM sets |\n|---|---|---|---|\n";
	var spaced = NewSandbox();
	spaced.Edit(list, ammo, "## Ammo (1)\n\n| Item | Copy | BLU sets | RDM sets |\n| --- | :-- | --- | --- |\n");
	Equal(0, spaced.Run("gear-list").ExitCode);
	var twice = NewSandbox();
	twice.Edit(list, ammo + "| Coiste Bodhar |  |  | `WS` |", "## Ammo (1)\n\n| Item | Copy | RDM sets | RDM sets |\n|---|---|---|---|\n| Coiste Bodhar |  |  | `WS` |");
	var repeated = twice.Run("gear-list");
	Equal(1, repeated.ExitCode);
	Contains(repeated.Output, "line 21: the header names a job more than once: RDM, RDM");
	Contains(repeated.Output, "problems: 2");
	var headless = NewSandbox();
	headless.Edit(list, ammo, "## Ammo (1)\n\n| Piece | Copy | BLU sets | RDM sets |\n|---|---|---|---|\n");
	var unread = headless.Run("gear-list");
	Equal(1, unread.ExitCode);
	Contains(unread.Output, "line 21: this table's first row isn't an `| Item | Copy | ... |` header, so its rows aren't read");
	Contains(unread.Output, "Coiste Bodhar: no row.");
	Contains(unread.Output, "## Ammo (1) has 0 rows");
});

Test("gear-list says why the Copy column stays empty for an entry that names no augments", () =>
{
	var sandbox = NewSandbox();
	var list = "data/Testy/Testy_gear_list.md";
	sandbox.Edit("data/Testy/RDM.lua", "\t\tright_ring = gear.stikini2,\n", "");
	sandbox.Edit(list, "| Stikini Ring | one of two identical copies |  | `Idle` |\n| Stikini Ring | one of two identical copies |  | `Idle` |\n", "| Stikini Ring | one of two identical copies |  | `Idle` |\n");
	sandbox.Edit(list, "## Rings (3)", "## Rings (2)");
	sandbox.Edit(list, "**17 pieces** (3 for BLU, 15 for RDM, 1 worn by both)", "**16 pieces** (3 for BLU, 14 for RDM, 1 worn by both)");
	var run = sandbox.Run("gear-list");
	Equal(1, run.ExitCode);
	Contains(run.Output, "Stikini Ring: the Copy column says [one of two identical copies], but the entry that wears it names no augments, so the column stays empty");
	Contains(run.Output, "problems: 1");
});

// ---------------------------------------------------------------- rank-doc.cs

Test("rank-doc finds both rank documents to be what it would write", () =>
{
	var run = pristine.Run("rank-doc", "--check");
	Equal(0, run.ExitCode);
	Contains(run.Output, "docs/rank-augments.md is what this would write");
	Contains(run.Output, "data/Testy/Testy_rank_augments.md is what this would write");
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
	Contains(run.Output, "86 lines -> docs/rank-augments.md");
	Contains(run.Output, "22 lines -> data/Testy/Testy_rank_augments.md");
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

Test("rank-doc stops on an exported path item that no rank table covers, and writes nothing", () =>
{
	var sandbox = NewSandbox();
	sandbox.Edit("data/export/Testy 2026-01-02 08-00-00.lua", "left_ring=\"Prolix Ring\",", "left_ring={ name=\"Prolix Ring\", augments={'Path: A',}},");
	var document = Path.Combine(sandbox.Repo, "data", "Testy", "Testy_rank_augments.md");
	var before = File.ReadAllText(document);
	var run = sandbox.Run("rank-doc");
	Equal(2, run.ExitCode);
	Contains(run.Output, "prints a path for Prolix Ring, and no rank table goes by that name.");
	Equal(before, File.ReadAllText(document));
});

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

Test("owned-gear names what the export holds that the resources don't know as gear", () =>
{
	var sandbox = NewSandbox();
	sandbox.Edit("data/export/Testy 2026-01-02 08-00-00.lua", "        sub=\"Ammurapi Shield\",\n", "        sub=\"Ammurapi Shield\",\n        sub=\"No Such Shield\",\n");
	var run = sandbox.Run("owned-gear");
	Equal(0, run.ExitCode);
	Contains(run.Output, "20 pieces; not weapons or armor in the resources: No Such Shield");
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
	Contains(run.Output, "lists from BLU.lua: BlueBuff; from the engine: BluePhysical, BlueBreath, BlueNuke, BlueSkill, BlueTank, BlueHealing, BlueACC");
	Contains(run.Output, "problems: 0");
	// A list declared inside a function is the same global.
	var indented = NewSandbox();
	indented.Edit("data/Testy/BLU.lua", "BlueBuff = S { 'Cocoon' }", "\tBlueBuff = S { 'Cocoon', 'Foot Kick' }");
	Contains(indented.Run("check-blu-spells").Output, "Foot Kick: in BluePhysical and BlueBuff");
});

Test("check-blu-spells takes a spell with a set of its own as placed, since the engine wears that set", () =>
{
	var sandbox = NewSandbox();
	sandbox.Edit("data/Testy/BLU.lua", "BlueBuff = S { 'Cocoon' }", "BlueBuff = S { }");
	sandbox.Edit("data/Testy/BLU.lua", "\tsets.Midcast = set_combine(sets.Idle, {})\n", "\tsets.Midcast = set_combine(sets.Idle, {})\n\tsets.Midcast['Cocoon'] = set_combine(sets.Midcast, {})\n");
	var run = sandbox.Run("check-blu-spells");
	Equal(0, run.ExitCode);
	Contains(run.Output, "in no list, wearing a set of their own: Cocoon");
	Contains(run.Output, "problems: 0");
	sandbox.Edit("data/Testy/BLU.lua", "sets.Midcast['Cocoon'] =", "sets.Midcast.Cocoon =");
	Equal(0, sandbox.Run("check-blu-spells").ExitCode);
	// A set under another name leaves the spell where it was.
	sandbox.Edit("data/Testy/BLU.lua", "sets.Midcast.Cocoon =", "sets.Midcast.Cocoons =");
	Contains(sandbox.Run("check-blu-spells").Output, "Cocoon: in no list, so it casts in the idle set");
});

Test("check-blu-spells says what a spell in no list ends up wearing", () =>
{
	var sandbox = NewSandbox();
	sandbox.Edit("data/Testy/BLU.lua", "BlueBuff = S { 'Cocoon' }", "BlueBuff = S { }");
	Contains(sandbox.Run("check-blu-spells").Output, "Cocoon: in no list, so it casts in the idle set with only sets.Midcast over it, and no blue magic set");
});

Test("check-blu-spells says so when the job file changes a list in a way it can't read", () =>
{
	var sandbox = NewSandbox();
	sandbox.Edit("data/Testy/BLU.lua", "BlueBuff = S { 'Cocoon' }", "BlueBuff = BlueBuff + S { 'Foot Kick' }\nBlueTank:remove('Blank Gaze')");
	var run = sandbox.Run("check-blu-spells");
	Equal(1, run.ExitCode);
	Contains(run.Output, "BLU.lua changes BlueBuff at line 7 in a way this check can't read, so the list it checked may not be the one the game uses");
	Contains(run.Output, "BLU.lua changes BlueTank at line 8 in a way this check can't read");
	Contains(run.Output, "lists from BLU.lua: none; from the engine: BluePhysical, BlueBreath, BlueNuke, BlueSkill, BlueBuff, BlueTank, BlueHealing, BlueACC");
	Contains(run.Output, "problems: 2");
	// Which of two assignments the game ends up with depends on when each runs, and the text doesn't say.
	var twice = NewSandbox();
	twice.Edit("data/Testy/BLU.lua", "function get_sets()\n", "function get_sets()\n\tBlueBuff = S { 'Cocoon', 'Foot Kick' }\n");
	var second = twice.Run("check-blu-spells");
	Equal(1, second.ExitCode);
	Contains(second.Output, "BLU.lua changes BlueBuff at line 10 in a way this check can't read");
	Contains(second.Output, "problems: 1");
	// Reading a list changes nothing.
	var reading = NewSandbox();
	reading.Edit("data/Testy/BLU.lua", "function get_sets()\n", "function get_sets()\n\tif BlueBuff:contains('Cocoon') and BlueBuff ~= nil and BlueBuff == BlueBuff then end\n");
	Equal(0, reading.Run("check-blu-spells").ExitCode);
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

Test("doc-lint reports mistakes in links, entries, Simulated sets bullets, table rows and raw markup", () =>
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

Test("doc-lint reports what else can be wrong with a link, a table, a Simulated sets bullet or a row of pieces lacking", () =>
{
	var sandbox = NewSandbox();
	var notes = "docs/gear-notes.md";
	var bullet = "- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): ";
	File.AppendAllText(Path.Combine(sandbox.Repo, "data", "Testy", "Testy_notes.md"), "\nThe sets are in [the job file](RDM.lua#idle).\n");
	File.AppendAllText(Path.Combine(sandbox.Repo, "docs", "ffxi-mechanics.md"), "\n| a | b |\n| 1 | 2 |\n\nText right above.\n| c | d |\n|---|---|\n| 1 | 2 |\n");
	sandbox.Edit(notes, "*Naegling.*\n\n" + bullet, "*Naegling.*\n\n- Simulated sets (bg-wiki): ");
	sandbox.Edit(notes, "No notes beyond the help text: Colada.", "### Colada\n\n" + bullet + "RDM: Savage Blade (Mid buff).");
	sandbox.Edit(notes, "## Other slots\n", "## Ears\n\n### Hoxne Earring\n\n" + bullet + "RDM: Savage Blade (Mid buff, High buff); BLU: Expiacion (Mid buff).\n\n## Other slots\n");
	sandbox.Edit("data/Testy/Testy_gear_notes.md", "| Hoxne Earring | Savage Blade |", "| Hoxne Earring | Chant du Cygne |");
	var run = sandbox.Run("doc-lint");
	Equal(1, run.ExitCode);
	Contains(run.Output, "data/Testy/Testy_notes.md:22: anchor into a file this tool doesn't read, RDM.lua#idle");
	Contains(run.Output, "docs/ffxi-mechanics.md:15: table without a delimiter row");
	Contains(run.Output, "docs/ffxi-mechanics.md:19: table with no blank line above it");
	Contains(run.Output, "Naegling: the Simulated sets bullet doesn't open the way the others do");
	Contains(run.Output, "Colada has a Simulated sets bullet, but no RDM or BLU set wears it");
	Contains(run.Output, "docs/gear-notes.md: Hoxne Earring has a Simulated sets bullet but isn't in the export");
	Contains(run.Output, "Hoxne Earring, RDM sets\n    doc:   Chant du Cygne\n    pages: Savage Blade");
});

Test("doc-lint reads a table of pieces lacking whose delimiter row is spaced out and sets the alignment", () =>
{
	var sandbox = NewSandbox();
	var own = Path.Combine(sandbox.Repo, "data", "Testy", "Testy_gear_notes.md");
	File.WriteAllText(own, File.ReadAllText(own).Replace("|---|---|", "| :--- | :--- |"));
	var run = sandbox.Run("doc-lint");
	Equal(0, run.ExitCode);
	Contains(run.Output, "problems: 0");
});

Test("doc-lint reads a \"No notes\" list whose last name ends in a full stop of its own", () =>
{
	var sandbox = NewSandbox();
	sandbox.Edit("data/export/Testy 2026-01-02 08-00-00.lua", "        waist=\"Eschan Stone\",\n", "        waist=\"Eschan Stone\",\n        legs=\"Tatena. Sune.\",\n");
	Contains(sandbox.Run("doc-lint").Output, "No notes yet for 2 pieces in the bags: Ea Houppelande, Tatena. Sune.");
	sandbox.Edit("docs/gear-notes.md", "No notes beyond the help text: Colada.", "No notes beyond the help text: Colada, Tatena. Sune.");
	var run = sandbox.Run("doc-lint");
	Equal(0, run.ExitCode);
	Contains(run.Output, "No notes yet for 1 pieces in the bags: Ea Houppelande\n");
	// The list and an entry for the same piece are still told apart.
	sandbox.Edit("docs/gear-notes.md", "## Other slots\n", "## Legs\n\n### Tatena. Sune.\n\n*Legs.*\n\n## Other slots\n");
	var twice = sandbox.Run("doc-lint");
	Equal(1, twice.ExitCode);
	Contains(twice.Output, "Tatena. Sune. is in a \"No notes\" list and has an entry");
});

Test("doc-lint counts a pipe inside a code span as a cell, as the page does", () =>
{
	var sandbox = NewSandbox();
	sandbox.Edit("docs/ffxi-mechanics.md", "| Fast Cast | 80% |", "| Fast Cast | `80|90`% |");
	var run = sandbox.Run("doc-lint");
	Equal(1, run.ExitCode);
	Contains(run.Output, "docs/ffxi-mechanics.md:11: 3 cells, but the table that starts at line 9 has 2");
});

Test("doc-lint knows an owned piece that a simulated set names by its long name", () =>
{
	var sandbox = NewSandbox();
	var page = Path.Combine(sandbox.Cache, "bg_job_guides", "blu.md");
	File.WriteAllText(page, File.ReadAllText(page).Replace("|Head = Nyame Helm", "|Head = Nyame Helm\n            |Hands = Hashishin Bazubands +3"));
	var run = sandbox.Run("doc-lint");
	Equal(1, run.ExitCode);
	Contains(run.Output, "docs/gear-notes.md: Hashi. Bazu. +3 is in a bag and in the simulated sets, but its entry has no Simulated sets bullet. Sets: BLU: Expiacion (Mid buff)");
	True(run.Output.Contains("lacks Hashishin Bazubands +3") is false, "an owned piece was taken for one the character lacks:\n" + run.Output);
	Contains(run.Output, "problems: 1");
});

Test("doc-lint reports a code fence that is never closed", () =>
{
	var sandbox = NewSandbox();
	File.AppendAllText(Path.Combine(sandbox.Repo, "docs", "ffxi-mechanics.md"), "\n```\n| a | b |\n");
	var run = sandbox.Run("doc-lint");
	Equal(1, run.ExitCode);
	Contains(run.Output, "docs/ffxi-mechanics.md:15: a code fence that is never closed, so nothing after it is checked");
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

Test("wsdist-gear --check-nyame says what it can't compare and what it can't read", () =>
{
	var sandbox = NewSandbox();
	File.AppendAllText(Path.Combine(sandbox.Cache, "wsdist_beta", "gear.py"), "Nyame_Mail15B = {\"Name\":\"Nyame Mail\", \"Name2\":\"Nyame Mail R15B\", \"Rank\":15, \"Accuracy\":40}\n");
	sandbox.Edit("docs/rank-augments.md", "| 15 | Attack+20 Rng. Atk.+20 | Weapon skill damage +7% |", "| 15 | Attack+20 Rng. Atk.+20 | Weapon skill damage up 7% |");
	sandbox.Edit("docs/rank-augments.md", "| 15 | \"Mag. Atk. Bns.\"+20 | INT/MND/CHR+5 |", "| 15 | \"Mag. Atk. Bns.\"+20 | Enmity+5 |");
	var run = sandbox.Run("wsdist-gear", "--check-nyame");
	Equal(1, run.ExitCode);
	Contains(run.Output, "gear.py:11 Nyame Mail R15B: no rank 0 entry or no row in docs/rank-augments.md to compare with");
	Contains(run.Output, "docs/rank-augments.md, Nyame Helm R15B: can't read \"Weapon skill damage up 7%\"");
	Contains(run.Output, "docs/rank-augments.md, Nyame Helm R15C: no wsdist stat known for \"Enmity\"");
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

// A tool that couldn't run: exit code 2, and a line that says why.
void Stops(ToolRun run, string message)
{
	Equal(2, run.ExitCode);
	Contains(run.Output, message);
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

// Stands in for bg-wiki's API on this machine: it answers each request with what a test hands it.
sealed class StandInSite : IDisposable
{
	public string Url { get; }

	// The path and query of each request, unescaped, in the order they came.
	public List<string> Requests { get; }

	TcpListener listener;
	Func<string, StandInReply> answer;

	public StandInSite(Func<string, StandInReply> answer)
	{
		this.answer = answer;
		Requests = [];
		// Port 0 leaves the choice of a free port to the system.
		listener = new TcpListener(IPAddress.Loopback, 0);
		listener.Start();
		Url = $"http://127.0.0.1:{((IPEndPoint)listener.LocalEndpoint).Port}/api.php";
		Task.Run(Serve);
	}

	public void Dispose() => listener.Stop();

	async Task Serve()
	{
		while (true)
		{
			TcpClient client;
			try
			{
				client = await listener.AcceptTcpClientAsync();
			}
			catch (Exception stopped) when (stopped is SocketException or ObjectDisposedException)
			{
				return;
			}
			using (client)
			{
				var stream = client.GetStream();
				var reader = new StreamReader(stream, Encoding.ASCII);
				var requestLine = await reader.ReadLineAsync() ?? "";
				// The headers end at the first empty line, and a GET sends nothing after them.
				while ((await reader.ReadLineAsync())?.Length > 0)
				{
				}
				var target = Uri.UnescapeDataString(requestLine.Split(' ').ElementAtOrDefault(1) ?? "");
				Requests.Add(target);
				var reply = answer(target);
				var body = Encoding.UTF8.GetBytes(reply.Body);
				var head = $"HTTP/1.1 {reply.Status} Stand-in\r\nContent-Type: application/json; charset=utf-8\r\nContent-Length: {body.Length}\r\nConnection: close\r\n\r\n";
				await stream.WriteAsync(Encoding.ASCII.GetBytes(head));
				await stream.WriteAsync(body);
			}
		}
	}
}

sealed class StandInReply
{
	public int Status { get; }

	public string Body { get; }

	public StandInReply(int status, string body)
	{
		Status = status;
		Body = body;
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

	public ToolRun Run(string tool, params string[] arguments) => Start(Path.Combine(toolsDir, tool + ".cs"), true, arguments);

	// Runs a tool with its web requests sent to a closed port of this machine, so each fails at once, as it does
	// with no network.
	public ToolRun RunOffline(string tool, params string[] arguments) => Start(Path.Combine(toolsDir, tool + ".cs"), true, arguments, offline: true);

	// Runs a tool with bg-wiki's API answered by a stand-in on this machine. Every other web request goes to the
	// closed port, so a tool that asked the real site would fail, not reach it.
	public ToolRun RunAgainst(StandInSite wiki, string tool, params string[] arguments) => Start(Path.Combine(toolsDir, tool + ".cs"), true, arguments, offline: true, wiki: wiki.Url);

	public ToolRun RunFile(string toolFile, bool rebuild) => Start(toolFile, rebuild, []);

	ToolRun Start(string toolFile, bool rebuild, string[] arguments, bool offline = false, string? wiki = null)
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
		if (offline)
		{
			// .NET reads these in either case, and takes the lower-case name first where case matters.
			string[] proxies = ["http_proxy", "https_proxy", "all_proxy", "HTTP_PROXY", "HTTPS_PROXY", "ALL_PROXY"];
			foreach (var proxy in proxies)
				start.Environment[proxy] = "http://127.0.0.1:1";
			// The same for git, over any proxy its own configuration names.
			start.Environment["GIT_CONFIG_COUNT"] = "1";
			start.Environment["GIT_CONFIG_KEY_0"] = "http.proxy";
			start.Environment["GIT_CONFIG_VALUE_0"] = "http://127.0.0.1:1";
			start.Environment.Remove("no_proxy");
			start.Environment.Remove("NO_PROXY");
		}
		if (wiki is not null)
		{
			start.Environment["GEAR_TOOLS_WIKI"] = wiki;
			start.Environment["no_proxy"] = "127.0.0.1";
			start.Environment["NO_PROXY"] = "127.0.0.1";
		}
		using var process = Process.Start(start)!;
		var error = process.StandardError.ReadToEndAsync();
		var output = process.StandardOutput.ReadToEnd();
		process.WaitForExit();
		return new ToolRun(process.ExitCode, output, error.Result);
	}
}
