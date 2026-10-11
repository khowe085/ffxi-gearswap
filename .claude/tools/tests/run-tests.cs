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

// The sets files Testy_gear_list.md is written from.
string[] testySets = ["--in", "sets/Testy_BLU.json", "--in", "sets/Testy_RDM.json"];

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

Test("SelReader.StripComments drops comments and keeps strings and line numbers", () =>
{
	var source = "a = 'x--y' -- gone\n--[[ block\nsets.X = {} ]] b = \"--\"\nc = 1 -- 'quoted'\n";
	var stripped = SelReader.StripComments(source);
	Equal("a = 'x--y' \n\n b = \"--\"\nc = 1 \n", stripped);
	Equal(source.Count(c => c == '\n'), stripped.Count(c => c == '\n'));
});

Test("SelReader.StripComments reads a block comment with = signs to the bracket that closes it", () =>
{
	// The library writes its long notes this way. "]]" inside one doesn't end it.
	var source = "x = 1 --[==[ note ]] still a comment\ngear.ghost = hp_gear(\"Eschan Stone\", 20)\n]==] y = 2\n--[=[ one ]=] z = 3\na = 1 --[= only a line\nb = 2\n";
	Equal("x = 1 \n\n y = 2\n z = 3\na = 1 \nb = 2\n", SelReader.StripComments(source));
});

Test("SelReader.StripComments leaves a Lua long string whole, -- and all", () =>
{
	Equal("a = [[ -- kept ]] b = 1 \n", SelReader.StripComments("a = [[ -- kept ]] b = 1 -- gone\n"));
	Equal("a = [==[ x ]] -- kept ]==] c = 2 \nd = 3\n", SelReader.StripComments("a = [==[ x ]] -- kept ]==] c = 2 --[[ gone ]]\nd = 3\n"));
	Equal("t[1] = 2 \n", SelReader.StripComments("t[1] = 2 -- gone\n"));
});

Test("PieceDto.Matches takes any copy when it names no augments, and only its own when it does", () =>
{
	var sets = Dto.ReadSets(Path.Combine(pristine.Repo, "sets", "Testy_RDM.json"));
	var copies = Export.Read(Export.Latest(null)).Where(item => item.Name == "Colada").ToList();
	var refresh = sets.Sets.Single(set => set.Name == "Weapons.Idle").Slots["main"];
	True(refresh.Matches(copies[0]) && refresh.Matches(copies[1]) is false, "the Refresh piece is the wardrobe copy only");
	var sash = Export.Read(Export.Latest(null)).Single(item => item.Name == "Obstin. Sash");
	True(sets.Sets.Single(set => set.Name == "Midcast.Enfeebling").Slots["waist"].Matches(sash), "a piece without augments takes the augmented copy");
	True(new PieceDto { Item = "Obstin. Sash", Augments = [] }.Matches(sash), "an empty list of augments names none");
});

Test("Dto.ReadSets reads a sets file, and Dto.Resolve lays each set over its base", () =>
{
	var sets = Dto.ReadSets(Path.Combine(pristine.Repo, "sets", "Testy_RDM.json"));
	Equal("1 Testy RDM 11", $"{sets.SchemaVersion} {sets.Character} {sets.Job} {sets.Sets.Count}");
	Equal(null, sets.SpellLists);
	var enfeebling = Dto.Resolve(sets, "Midcast.Enfeebling");
	Equal("back body head left_ear left_ring right_ring waist", string.Join(" ", enfeebling.Keys.Order(StringComparer.Ordinal)));
	Equal("Atrophy Chapeau +4", enfeebling["head"].Item);
	Equal("MND+20", enfeebling["back"].Augments![0]);
	Equal(null, enfeebling["body"].Bag);
	var accuracy = Dto.Resolve(sets, "WS[each magical WS].ACC");
	Equal("Coiste Bodhar Eschan Stone", $"{accuracy["ammo"].Item} {accuracy["waist"].Item}");
	Equal(0, Dto.Resolve(sets, "Weapons").Count);
	Contains(Throws<InvalidOperationException>(() => Dto.Resolve(sets, "Nowhere")).Message, "No set named Nowhere");
	var blu = Dto.ReadSets(Path.Combine(pristine.Repo, "sets", "Testy_BLU.json"));
	Equal("Foot Kick, Power Attack", string.Join(", ", blu.SpellLists!["Physical"]));
	Equal(0, blu.SpellLists["Stun"].Count);
});

Test("Dto.ReadSets refuses a sets file it can't use, and says why", () =>
{
	string Refusal(string json)
	{
		var path = Path.Combine(workDir, "sets-" + Guid.NewGuid().ToString("N")[..8] + ".json");
		File.WriteAllText(path, json);
		return Throws<InvalidOperationException>(() => Dto.ReadSets(path)).Message;
	}
	string Sets(string sets, string job = "RDM", int version = 1) => $$"""{ "schemaVersion": {{version}}, "character": "Testy", "job": "{{job}}", "sets": [ {{sets}} ] }""";
	Contains(Throws<InvalidOperationException>(() => Dto.ReadSets(Path.Combine(workDir, "no-such-sets.json"))).Message, "No sets file at ");
	Contains(Refusal("{ not json"), ".json can't be read as a sets file: ");
	Contains(Refusal("null"), ".json can't be read as a sets file");
	Contains(Refusal(Sets("", version: 2)), ".json has schemaVersion 2; the tools read 1");
	Contains(Refusal(Sets("", job: "XYZ")), ".json: XYZ isn't a job");
	Contains(Refusal("""{ "schemaVersion": 1, "job": "RDM", "sets": [] }"""), ".json names no character");
	Contains(Refusal(Sets("""{ "slots": {} }""")), ".json: set 1 has no name");
	Contains(Refusal(Sets("""{ "name": "Idle", "slots": {} }, { "name": "Idle", "slots": {} }""")), ".json: two sets named Idle");
	Contains(Refusal(Sets("""{ "name": "Midcast", "base": "Idle", "slots": {} }""")), ".json: Midcast is built on Idle, and no set has that name");
	Contains(Refusal(Sets("""{ "name": "A", "base": "B", "slots": {} }, { "name": "B", "base": "A", "slots": {} }""")), ".json: A is built on itself: A, B, A");
	Contains(Refusal(Sets("""{ "name": "Idle", "slots": { "nose": { "item": "Nyame Helm" } } }""")), ".json: Idle: nose isn't a slot");
	Contains(Refusal(Sets("""{ "name": "Idle", "slots": { "ear1": { "item": "Loquac. Earring" } } }""")), ".json: Idle: ear1 isn't a slot");
	Contains(Refusal(Sets("""{ "name": "Idle", "slots": { "head": { "augments": [] } } }""")), ".json: Idle: head names no item");
});

Test("Dto.ReadSets refuses a spell list that is null or holds a null", () =>
{
	string Refusal(string lists)
	{
		var path = Path.Combine(workDir, "lists-" + Guid.NewGuid().ToString("N")[..8] + ".json");
		File.WriteAllText(path, $$"""{ "schemaVersion": 1, "character": "Testy", "job": "BLU", "sets": [], "spellLists": { {{lists}} } }""");
		return Throws<InvalidOperationException>(() => Dto.ReadSets(path)).Message;
	}
	Contains(Refusal("\"Physical\": null"), ".json: spellLists: Physical is null");
	Contains(Refusal("\"Physical\": [\"Foot Kick\", null]"), ".json: spellLists: Physical holds a null");
});

Test("Dto.ReadSets refuses a spell set that names no set", () =>
{
	var path = Path.Combine(workDir, "spell-sets.json");
	File.WriteAllText(path, """{ "schemaVersion": 1, "character": "Testy", "job": "BLU", "sets": [ { "name": "Cocoon set", "slots": {} } ], "spellSets": { "Cocoon": "Cocoon set", "Occultation": "Nowhere" } }""");
	Contains(Throws<InvalidOperationException>(() => Dto.ReadSets(path)).Message, ".json: spellSets: Occultation names the set Nowhere, and no set has that name");
});

Test("Dto.ReadRequest refuses bags GearSwap can't equip from", () =>
{
	var path = Path.Combine(workDir, "request-with-a-locker.json");
	File.WriteAllText(path, File.ReadAllText(Path.Combine(pristine.Repo, "sets", "Testy_request.json")).Replace("\"bags\": [\"wardrobe\", \"wardrobe2\"]", "\"bags\": [\"wardrobe\", \"locker\"]"));
	Contains(Throws<InvalidOperationException>(() => Dto.ReadRequest(path)).Message, "request-with-a-locker.json: bags names locker, which GearSwap can't equip from. Bags: inventory wardrobe");
});

Test("OptimizeResult carries the spell lists it changed, and leaves them out when it changed none", () =>
{
	var changed = Dto.ToJson(new OptimizeResult { SpellLists = new Dictionary<string, List<string>> { ["Buff"] = ["Cocoon"] } });
	Contains(changed, "\"spellLists\": {\n    \"Buff\": [\n      \"Cocoon\"\n    ]\n  }");
	True(Dto.ToJson(new OptimizeResult()).Contains("spellLists") is false, "a result that changed no list names none");
});

Test("Dto.ReadRequest reads an optimize request with the sets inside it", () =>
{
	var request = Dto.ReadRequest(Path.Combine(pristine.Repo, "sets", "Testy_request.json"));
	Equal("Testy BLU data/export/Testy 2026-01-02 08-00-00.lua", $"{request.Character} {request.Job} {request.Export}");
	Equal("wardrobe wardrobe2", string.Join(" ", request.Bags!));
	Equal("Damage taken as low as it goes", request.Targets!["Midcast"]);
	Equal("Nyame Helm", Dto.Resolve(request.Sets, "Midcast")["head"].Item);
	var path = Path.Combine(workDir, "request-for-another-job.json");
	File.WriteAllText(path, File.ReadAllText(Path.Combine(pristine.Repo, "sets", "Testy_request.json")).Replace("\"job\": \"BLU\",\n  \"export\"", "\"job\": \"RDM\",\n  \"export\""));
	Contains(Throws<InvalidOperationException>(() => Dto.ReadRequest(path)).Message, "is for Testy RDM, but its sets are for Testy BLU");
	var setless = Path.Combine(workDir, "request-without-sets.json");
	File.WriteAllText(setless, """{ "schemaVersion": 1, "character": "Testy", "job": "BLU", "export": "x.lua", "sets": null }""");
	Contains(Throws<InvalidOperationException>(() => Dto.ReadRequest(setless)).Message, "request-without-sets.json has no sets");
});

Test("Dto.ToJson writes the names in camel case and leaves out what isn't set", () =>
{
	var sets = new SetsDto { Character = "Testy", Job = "RDM", Sets = [new SetDto { Name = "Idle", Slots = { ["head"] = new PieceDto { Item = "Nyame Helm" } } }] };
	var json = Dto.ToJson(sets);
	Contains(json, "\"schemaVersion\": 1");
	Contains(json, "\"item\": \"Nyame Helm\"");
	True(json.Contains("base") is false && json.Contains("augments") is false && json.Contains("spellLists") is false, json);
	var finding = Dto.ToJson(new List<Finding> { new Finding("check-export", "error", "Idle", "head", "Nyame Helm", "not in the export") });
	Contains(finding, "\"tool\": \"check-export\",\n    \"severity\": \"error\",\n    \"set\": \"Idle\",\n    \"slot\": \"head\",\n    \"item\": \"Nyame Helm\",\n    \"message\": \"not in the export\"");
	var result = Dto.ToJson(new OptimizeResult { Sets = sets.Sets, Changes = [new SetChange { Set = "Idle", Slot = "head", From = "", To = "Nyame Helm", Reason = "DT" }] });
	Contains(result, "\"changes\": [");
	Contains(result, "\"shortfalls\": []");
	Contains(result, "\"docsEdited\": []");
});

Test("Arguments takes an option given more than once, and gives the last when one value is asked for", () =>
{
	var cli = new Arguments(["--in", "a.json", "--json", "--in", "b.json"], ["--in", "--export"], ["--json"]);
	Equal("a.json b.json", string.Join(" ", cli.Options("--in")));
	Equal("b.json", cli.Option("--in"));
	Equal(0, cli.Options("--export").Count);
	Equal(null, cli.Option("--export"));
});

Test("SelReader reads a Sel gear file's sets: tables, gear entries, set_combine and aliases", () =>
{
	var read = SelReader.Read(Path.Combine(pristine.Repo, "data", "Testy", "Testy_Blu_Gear.lua"), "Testy", "BLU", []);
	var sets = read.Sets;
	Equal("Testy BLU", $"{sets.Character} {sets.Job}");
	Equal("idle | idle.DT | precast.FC | midcast['Blue Magic'] | midcast['Blue Magic'].Buff | midcast[\"Testy's Own\"] | engaged | buff.Doom | Kiting",
		string.Join(" | ", sets.Sets.Select(set => set.Name)));
	string Slots(string name) => string.Join(", ", sets.Sets.Single(set => set.Name == name).Slots.OrderBy(slot => slot.Key, StringComparer.Ordinal)
		.Select(slot => $"{slot.Key}={slot.Value.Item}{(slot.Value.Augments is null ? "" : $" [{string.Join(", ", slot.Value.Augments)}]")}{(slot.Value.Bag is null ? "" : $" ({slot.Value.Bag})")}"));
	string? Base(string name) => sets.Sets.Single(set => set.Name == name).Base;
	Equal("hands=Hashishin Bazubands +3, head=Nyame Helm [Path: B], waist=Rumination Sash", Slots("idle"));
	Equal("idle ammo=empty", $"{Base("idle.DT")} {Slots("idle.DT")}");
	Equal("left_ear=Loquac. Earring, left_ring=Stikini Ring (wardrobe8), right_ring=Prolix Ring", Slots("precast.FC"));
	Equal("idle", Base("midcast['Blue Magic']"));
	Equal("midcast['Blue Magic']", sets.Sets.Single(set => set.Name == "midcast['Blue Magic'].Buff").AliasOf);
	Equal("back=Sucellos's Cape [MND+20, Mag. Acc+20 /Mag. Dmg.+20, Haste+10]", Slots("midcast[\"Testy's Own\"]"));
	// Each set after the first that set_combine names is laid into the set's own slots.
	Equal("idle body=Ayanmo Corazza +2, left_ear=Loquac. Earring, left_ring=Stikini Ring (wardrobe8), right_ring=Prolix Ring", $"{Base("engaged")} {Slots("engaged")}");
	Equal("Cocoon", string.Join(", ", sets.SpellLists!["Buff"]));
	Equal(1, sets.SpellLists.Count);
	Equal("Ayanmo Corazza +2", Dto.Resolve(sets, "engaged")["body"].Item);
});

Test("SelReader notes what it can't read, and leaves it out", () =>
{
	var read = SelReader.Read(Path.Combine(pristine.Repo, "data", "Testy", "Testy_Blu_Gear.lua"), "Testy", "BLU", []);
	Equal(2, read.Notes.Count);
	Contains(read.Notes[0], "Testy_Blu_Gear.lua:30: sets.buff.Doom is built on sets.buff.Doom, which no file read defines, so the base is left out");
	Contains(read.Notes[1], "Testy_Blu_Gear.lua:31: sets.Kiting: feet is gear.no_such_piece, which no file read defines, so the slot is left out");
	Equal(null, read.Sets.Sets.Single(set => set.Name == "buff.Doom").Base);
	Equal(0, read.Sets.Sets.Single(set => set.Name == "Kiting").Slots.Count);
	var odd = Path.Combine(workDir, "Odd_Blu_Gear.lua");
	File.WriteAllText(odd, "sets.a = {head=\"Nyame Helm\", \"Loose\", nose=\"Nyame Helm\", body=some_variable}\nsets.b = sets.nowhere\nsets.c = make_set()\nsets.a = {head=\"Nyame Helm\"}\n"
		+ "for _,ws in ipairs({'A'}) do sets.WS[ws].Acc = {head=\"Bogus Hat\"} end\nblue_magic_maps.Buff:remove('Cocoon')\nlocal held = sets.weapons[state.Weapons.value]\n");
	var notes = SelReader.Read(odd, "Odd", "BLU", []).Notes;
	Contains(string.Join("\n", notes), "Odd_Blu_Gear.lua:1: sets.a: an entry with no slot, \"Loose\", is left out");
	Contains(string.Join("\n", notes), "Odd_Blu_Gear.lua:1: sets.a: nose isn't a slot, so it is left out");
	Contains(string.Join("\n", notes), "Odd_Blu_Gear.lua:1: sets.a: body is some_variable, which this reader can't follow, so the slot is left out");
	Contains(string.Join("\n", notes), "Odd_Blu_Gear.lua:2: sets.b is sets.nowhere, which no file read defines, so the base is left out");
	Contains(string.Join("\n", notes), "Odd_Blu_Gear.lua:3: sets.c = make_set(...) isn't a table or set_combine, so the set is left out");
	Contains(string.Join("\n", notes), "Odd_Blu_Gear.lua:4: sets.a is defined a second time; the last definition is the one read");
	Contains(string.Join("\n", notes), "Odd_Blu_Gear.lua:5: sets.WS[...].Acc is named at run time, so this reader can't read it and the set is left out");
	Contains(string.Join("\n", notes), "Odd_Blu_Gear.lua:6: blue_magic_maps.Buff:remove(...) changes the list in a way this reader can't follow, so the list read may not be the one the game uses");
	Equal(8, notes.Count);
});

Test("SelReader keeps what a set was built on when that set is defined again, as Lua copies it", () =>
{
	var file = Path.Combine(workDir, "Again_Rdm_Gear.lua");
	File.WriteAllText(file, "sets.engaged = {body=\"Ayanmo Corazza +2\"}\nsets.engaged = set_combine(sets.engaged, {hands=\"Hashi. Bazu. +3\"})\n"
		+ "sets.A = {head=\"Nyame Helm\"}\nsets.B = set_combine(sets.A, {waist=\"Eschan Stone\"})\nsets.C = sets.B\nsets.A = {head=\"Atro. Chapeau +4\"}\n");
	var sets = SelReader.Read(file, "Again", "RDM", []).Sets;
	var engaged = sets.Sets.Single(set => set.Name == "engaged");
	Equal(null, engaged.Base);
	Equal("body hands", string.Join(" ", engaged.Slots.Keys.Order(StringComparer.Ordinal)));
	Equal("Nyame Helm Eschan Stone", $"{Dto.Resolve(sets, "B")["head"].Item} {Dto.Resolve(sets, "B")["waist"].Item}");
	Equal("Nyame Helm", Dto.Resolve(sets, "C")["head"].Item);
	Equal("Atro. Chapeau +4", Dto.Resolve(sets, "A")["head"].Item);
	// What the reader writes, the checkers can read.
	var path = Path.Combine(workDir, "again.json");
	File.WriteAllText(path, Dto.ToJson(sets));
	Equal(4, Dto.ReadSets(path).Sets.Count);
});

Test("SelReader drops the sets inside a set that is defined again, as Lua replaces the table that held them", () =>
{
	var file = Path.Combine(workDir, "Children_Rdm_Gear.lua");
	File.WriteAllText(file, "sets.idle = {head=\"Nyame Helm\"}\nsets.idle.DT = set_combine(sets.idle, {body=\"Ayanmo Corazza +2\"})\nsets.kite = set_combine(sets.idle.DT, {feet=\"Atro. Boots\"})\n"
		+ "sets.idle = {head=\"Atro. Chapeau +4\"}\nsets.engaged = {body=\"Lethargy Sayon +3\"}\nsets.engaged.Acc = {body=\"Ayanmo Corazza +2\"}\nsets.engaged = set_combine(sets.engaged, {hands=\"Hashi. Bazu. +3\"})\n");
	var read = SelReader.Read(file, "Children", "RDM", []);
	Equal("idle kite engaged", string.Join(" ", read.Sets.Sets.Select(set => set.Name)));
	// A set built on a dropped set keeps what it copied.
	var kite = Dto.Resolve(read.Sets, "kite");
	Equal("Nyame Helm Ayanmo Corazza +2 Atro. Boots", $"{kite["head"].Item} {kite["body"].Item} {kite["feet"].Item}");
	Equal("body hands", string.Join(" ", Dto.Resolve(read.Sets, "engaged").Keys.Order(StringComparer.Ordinal)));
	var notes = string.Join("\n", read.Notes);
	Contains(notes, "Children_Rdm_Gear.lua:4: sets.idle is defined a second time; the last definition is the one read");
	Contains(notes, "Children_Rdm_Gear.lua:4: sets.idle.DT is dropped: defining sets.idle again replaces the table that held it");
	Contains(notes, "Children_Rdm_Gear.lua:7: sets.engaged.Acc is dropped: defining sets.engaged again replaces the table that held it");
	var path = Path.Combine(workDir, "children.json");
	File.WriteAllText(path, Dto.ToJson(read.Sets));
	Equal(3, Dto.ReadSets(path).Sets.Count);
});

Test("SelReader reads a set_combine inside a set_combine as the one call it amounts to", () =>
{
	var file = Path.Combine(workDir, "Nested_Rdm_Gear.lua");
	File.WriteAllText(file, "sets.a = {head=\"Nyame Helm\"}\nsets.b = set_combine(set_combine(sets.a, {body=\"Ayanmo Corazza +2\"}), {hands=\"Hashi. Bazu. +3\"})\n"
		+ "sets.c = set_combine({waist=\"Eschan Stone\"}, set_combine(sets.a, {feet=\"Atro. Boots\"}))\n");
	var read = SelReader.Read(file, "Nested", "RDM", []);
	Equal(0, read.Notes.Count);
	var b = read.Sets.Sets.Single(set => set.Name == "b");
	Equal("a body hands", $"{b.Base} {string.Join(" ", b.Slots.Keys.Order(StringComparer.Ordinal))}");
	var c = read.Sets.Sets.Single(set => set.Name == "c");
	Equal(" feet head waist", $"{c.Base} {string.Join(" ", c.Slots.Keys.Order(StringComparer.Ordinal))}");
});

Test("SelReader notes a table that fills one slot under two of its names, and reads the last", () =>
{
	var file = Path.Combine(workDir, "Twice_Rdm_Gear.lua");
	File.WriteAllText(file, "sets.x = {ear1=\"Loquac. Earring\", left_ear=\"Hashi. Earring +1\"}\n");
	var read = SelReader.Read(file, "Twice", "RDM", []);
	Equal("Hashi. Earring +1", read.Sets.Sets[0].Slots["left_ear"].Item);
	Contains(string.Join("\n", read.Notes), "Twice_Rdm_Gear.lua:1: sets.x: ear1 and left_ear both fill left_ear; the last one, left_ear, is read");
});

Test("SelReader records the blue spells that have a set of their own, where Sel looks for one", () =>
{
	var file = Path.Combine(workDir, "Own_Blu_Gear.lua");
	File.WriteAllText(file, "sets.midcast['Blue Magic'] = {}\nsets.midcast['Blue Magic'].Cocoon = {head=\"Nyame Helm\"}\nsets.midcast['Occultation'] = {}\n"
		+ "sets.midcast.FastRecast = {}\nsets.midcast['Blue Magic'].Physical = {}\nsets.precast.FC['Foot Kick'] = {}\n");
	var sets = SelReader.Read(file, "Own", "BLU", []).Sets;
	Equal("Cocoon=midcast['Blue Magic'].Cocoon Occultation=midcast.Occultation", string.Join(" ", sets.SpellSets!.Select(spell => $"{spell.Key}={spell.Value}")));
	var rdm = Path.Combine(workDir, "Own_Rdm_Gear.lua");
	File.WriteAllText(rdm, "sets.midcast['Blue Magic'].Cocoon = {}\n");
	Equal(null, SelReader.Read(rdm, "Own", "RDM", []).Sets.SpellSets);
});

Test("SelReader starts from the sets Sel's own files define, so building on them is no mistake and a set inside one is dropped when the file defines it", () =>
{
	var file = Path.Combine(workDir, "Seeded_Blu_Gear.lua");
	File.WriteAllText(file, "sets.idle.DT = {head=\"Nyame Helm\"}\nsets.idle = {body=\"Ayanmo Corazza +2\"}\nsets.TreasureHunter = set_combine(sets.TreasureHunter, {waist=\"Eschan Stone\"})\n"
		+ "sets.precast.FC = {ear1=\"Loquac. Earring\"}\nsets.kite = set_combine(sets.engaged, {feet=\"Atro. Boots\"})\n");
	var read = SelReader.Read(file, "Seeded", "BLU", []);
	Equal("idle TreasureHunter precast.FC kite", string.Join(" ", read.Sets.Sets.Select(set => set.Name)));
	Equal(null, read.Sets.Sets.Single(set => set.Name == "TreasureHunter").Base);
	Equal(null, read.Sets.Sets.Single(set => set.Name == "kite").Base);
	Equal(1, read.Notes.Count);
	Contains(read.Notes[0], "Seeded_Blu_Gear.lua:2: sets.idle.DT is dropped: defining sets.idle again replaces the table that held it");
});

Test("SelReader records no spell set Sel would never reach, as when a top-level set for the spell's list comes first", () =>
{
	var file = Path.Combine(workDir, "Reach_Blu_Gear.lua");
	File.WriteAllText(file, "blue_magic_maps.Buff = S{'Cocoon'}\nblue_magic_maps.Physical = S{'Foot Kick'}\nsets.midcast.Buff = {}\n"
		+ "sets.midcast['Blue Magic'].Cocoon = {}\nsets.midcast['Blue Magic']['Foot Kick'] = {}\n");
	var sets = SelReader.Read(file, "Reach", "BLU", []).Sets;
	Equal("Foot Kick=midcast['Blue Magic']['Foot Kick']", string.Join(" ", sets.SpellSets!.Select(spell => $"{spell.Key}={spell.Value}")));
});

Test("SelReader takes gear entries, blue magic lists and top-level sets from the files Sel loads before the gear file", () =>
{
	var earlier = Path.Combine(workDir, "Earlier-Items.lua");
	File.WriteAllText(earlier, "gear.loquac = {name=\"Loquac. Earring\"}\nblue_magic_maps.Buff = S{'Not Read'}\nblue_magic_maps.Healing = S{'Magic Fruit'}\nsets.not_read = {head=\"Nyame Helm\"}\n");
	var gearFile = Path.Combine(workDir, "Earlier_Blu_Gear.lua");
	File.WriteAllText(gearFile, "blue_magic_maps.Buff = S{'Cocoon'}\nsets.idle = {ear1=gear.loquac}\n");
	var read = SelReader.Read(gearFile, "Earlier", "BLU", [earlier]);
	Equal("not_read idle", string.Join(" ", read.Sets.Sets.Select(set => set.Name)));
	Equal("Loquac. Earring", read.Sets.Sets[1].Slots["left_ear"].Item);
	Equal("Buff Cocoon | Healing Magic Fruit", string.Join(" | ", read.Sets.SpellLists!.Select(list => $"{list.Key} {string.Join(", ", list.Value)}")));
	Equal(0, read.Notes.Count);
});

Test("SelReader builds the gear file's sets on the sets an earlier file defines, as Vanar-Items.lua's TreasureHunter and buff.Doom", () =>
{
	var items = Path.Combine(workDir, "Built-Items.lua");
	File.WriteAllText(items, "sets.buff.Doom = {waist=\"Gishdubar Sash\"}\nsets.TreasureHunter = {head=\"Volte Cap\",hands=\"Volte Bracers\"}\n"
		+ "function swap()\n\tif x then\n\t\tsets.inside_if = {}\n\tend\n\tsets.inside_function = {}\nend\nfor i = 1, 2 do sets.inside_for = {} end\n"
		+ "do sets.inside_do = {} end\nsets.Capacity = {back=\"Mecisto. Mantle\"}\n");
	var gearFile = Path.Combine(workDir, "Built_Rdm_Gear.lua");
	File.WriteAllText(gearFile, "sets.TreasureHunter = set_combine(sets.TreasureHunter, {waist=\"Chaac Belt\"})\n"
		+ "sets.midcast.Dia = set_combine(sets.midcast.FastRecast, sets.TreasureHunter)\nsets.buff.Doom = set_combine(sets.buff.Doom, {ring1=\"Eshmun's Ring\"})\n"
		+ "function job_setup()\n\tsets.gear_function = {}\nend\n");
	var read = SelReader.Read(gearFile, "Built", "RDM", [items]);
	Equal("buff.Doom TreasureHunter Capacity midcast.Dia gear_function", string.Join(" ", read.Sets.Sets.Select(set => set.Name)));
	string Slots(string name) => string.Join(", ", Dto.Resolve(read.Sets, name).OrderBy(slot => slot.Key).Select(slot => $"{slot.Key}={slot.Value.Item}"));
	Equal("hands=Volte Bracers, head=Volte Cap, waist=Chaac Belt", Slots("TreasureHunter"));
	Equal("hands=Volte Bracers, head=Volte Cap, waist=Chaac Belt", Slots("midcast.Dia"));
	Equal("left_ring=Eshmun's Ring, waist=Gishdubar Sash", Slots("buff.Doom"));
	Equal(null, read.Sets.Sets.Single(set => set.Name == "TreasureHunter").Base);
	Contains(string.Join("\n", read.Notes), "Built_Rdm_Gear.lua:2: sets.midcast.Dia is built on sets.midcast.FastRecast");
	Equal(1, read.Notes.Count);
});

Test("SelReader keeps count of blocks through a function written as a value, so what is nested stays nested", () =>
{
	var items = Path.Combine(workDir, "Depth-Items.lua");
	File.WriteAllText(items, "gear.picker = {pick = function(x) if x then return 1 end end, name=\"Eschan Stone\"}\n"
		+ "function swap()\n\tsets.handler = function() return sets.idle end\n\tsets.inside_one = {}\nend\n"
		+ "function swap_again()\n\tgear.table = {f = function() if x then return 1 end end}\n\tsets.inside_two = {}\nend\n"
		+ "sets.later = {head=\"Nyame Helm\"}\n");
	var gearFile = Path.Combine(workDir, "Depth_Rdm_Gear.lua");
	File.WriteAllText(gearFile, "sets.idle = {head=\"Nyame Helm\"}\n");
	var read = SelReader.Read(gearFile, "Depth", "RDM", [items]);
	Equal("later idle", string.Join(" ", read.Sets.Sets.Select(set => set.Name)));
	Equal(0, read.Notes.Count);
});

Test("SelReader reports a set built on itself again as information, not a mistake, and sel-sets' exit code counts only mistakes", () =>
{
	var file = Path.Combine(workDir, "Self_Rdm_Gear.lua");
	File.WriteAllText(file, "sets.engaged = {body=\"Ayanmo Corazza +2\"}\nsets.engaged = set_combine(sets.engaged, {hands=\"Hashi. Bazu. +3\"})\n"
		+ "sets.idle = {head=\"Nyame Helm\"}\nsets.idle.DT = {}\nsets.idle = set_combine(sets.idle, {feet=\"Atro. Boots\"})\nsets.kite = {}\nsets.kite = {feet=\"Atro. Boots\"}\n");
	var read = SelReader.Read(file, "Self", "RDM", []);
	Equal("Self_Rdm_Gear.lua:2: sets.engaged is defined a second time, built on itself; the last definition is the one read\n"
		+ "Self_Rdm_Gear.lua:5: sets.idle is defined a second time, built on itself; the last definition is the one read", string.Join("\n", read.Info));
	Equal("Self_Rdm_Gear.lua:5: sets.idle.DT is dropped: defining sets.idle again replaces the table that held it\n"
		+ "Self_Rdm_Gear.lua:7: sets.kite is defined a second time; the last definition is the one read", string.Join("\n", read.Notes));
	var sandbox = NewSandbox();
	File.WriteAllText(Path.Combine(sandbox.Repo, "data", "Testy", "Testy_Rdm_Gear.lua"), "sets.engaged = {body=\"Ayanmo Corazza +2\"}\nsets.engaged = set_combine(sets.engaged, {hands=\"Hashi. Bazu. +3\"})\n");
	var run = sandbox.Run("sel-sets", "data/Testy/Testy_Rdm_Gear.lua", "RDM", "--out", "rdm.json");
	Equal(0, run.ExitCode);
	Contains(run.Output, "  info  Testy_Rdm_Gear.lua:2: sets.engaged is defined a second time, built on itself; the last definition is the one read");
	Contains(run.Output, "notes: 0, information: 1");
});

Test("SelReader leaves out a slot given as an empty string, which GearSwap equips nothing for, and notes it", () =>
{
	var file = Path.Combine(workDir, "Blank_Whm_Gear.lua");
	File.WriteAllText(file, "sets.HPDown = {head=\"Nyame Helm\",legs=\"\",feet={name=\"\"}}\n");
	var read = SelReader.Read(file, "Blank", "WHM", []);
	Equal("head", string.Join(" ", read.Sets.Sets.Single().Slots.Keys));
	Equal("Blank_Whm_Gear.lua:1: sets.HPDown: legs is \"\", which GearSwap equips nothing for and takes nothing off for, so the slot is left out\n"
		+ "Blank_Whm_Gear.lua:1: sets.HPDown: feet is {name=\"\"}, which GearSwap equips nothing for and takes nothing off for, so the slot is left out", string.Join("\n", read.Notes));
	var path = Path.Combine(workDir, "blank.json");
	File.WriteAllText(path, Dto.ToJson(read.Sets));
	Equal(1, Dto.ReadSets(path).Sets.Count);
});

Test("SelReader keeps a set made the same table as another as an alias, whose children are the other's, before and after", () =>
{
	var file = Path.Combine(workDir, "Alias_Rdm_Gear.lua");
	File.WriteAllText(file, "sets.midcast.Sleep = {head=\"Nyame Helm\"}\nsets.midcast.Sleep.Resistant = {body=\"Atro. Tabard +3\"}\n"
		+ "sets.midcast['Dia III'] = sets.midcast.Sleep\nsets.midcast.Sleep.DW = {sub=\"Ammurapi Shield\"}\n"
		+ "sets.midcast['Dia III'].Saboteur = {hands=\"Leth. Ganth. +3\"}\nsets.kite = set_combine(sets.midcast['Dia III'].Resistant, {feet=\"Atro. Boots\"})\n"
		+ "sets.Bind = sets.midcast['Dia III']\n");
	var read = SelReader.Read(file, "Alias", "RDM", []);
	Equal(0, read.Notes.Count);
	Equal("midcast.Sleep midcast.Sleep.Resistant midcast['Dia III'] midcast.Sleep.DW midcast.Sleep.Saboteur kite Bind", string.Join(" ", read.Sets.Sets.Select(set => set.Name)));
	var dia = read.Sets.Sets.Single(set => set.Name == "midcast['Dia III']");
	Equal("midcast.Sleep", dia.AliasOf);
	Equal(0, dia.Slots.Count);
	Equal(null, dia.Base);
	Equal("midcast.Sleep", read.Sets.Sets.Single(set => set.Name == "Bind").AliasOf);
	Equal("midcast.Sleep.Resistant", read.Sets.Sets.Single(set => set.Name == "kite").Base);
	// The tools reach the alias's children by its own name, through a sets file read back.
	var path = Path.Combine(workDir, "alias.json");
	File.WriteAllText(path, Dto.ToJson(read.Sets));
	var sets = Dto.ReadSets(path);
	Contains(File.ReadAllText(path), "\"aliasOf\": \"midcast.Sleep\"");
	string Slots(string name) => string.Join(", ", Dto.Resolve(sets, name).OrderBy(slot => slot.Key).Select(slot => $"{slot.Key}={slot.Value.Item}"));
	Equal("head=Nyame Helm", Slots("midcast['Dia III']"));
	Equal("body=Atro. Tabard +3", Slots("midcast['Dia III'].Resistant"));
	Equal("sub=Ammurapi Shield", Slots("midcast['Dia III'].DW"));
	Equal("hands=Leth. Ganth. +3", Slots("midcast.Sleep.Saboteur"));
	Equal("hands=Leth. Ganth. +3", Slots("Bind.Saboteur"));
});

Test("SelReader turns an alias into the old table's holder when the set it names is defined again", () =>
{
	var file = Path.Combine(workDir, "Rebound_Rdm_Gear.lua");
	File.WriteAllText(file, "sets.A = {head=\"Nyame Helm\"}\nsets.A.X = {body=\"Atro. Tabard +3\"}\nsets.B = sets.A\nsets.C = sets.A\nsets.A = {head=\"Atro. Chapeau +4\"}\n");
	var read = SelReader.Read(file, "Rebound", "RDM", []);
	Equal("A B B.X C", string.Join(" ", read.Sets.Sets.Select(set => set.Name).Order(StringComparer.Ordinal)));
	string Slots(string name) => string.Join(", ", Dto.Resolve(read.Sets, name).OrderBy(slot => slot.Key).Select(slot => $"{slot.Key}={slot.Value.Item}"));
	Equal("head=Atro. Chapeau +4", Slots("A"));
	Equal("head=Nyame Helm", Slots("B"));
	Equal(null, read.Sets.Sets.Single(set => set.Name == "B").AliasOf);
	Equal("B", read.Sets.Sets.Single(set => set.Name == "C").AliasOf);
	Equal("body=Atro. Tabard +3", Slots("C.X"));
	Equal("Rebound_Rdm_Gear.lua:5: sets.A is defined a second time; the last definition is the one read", string.Join("\n", read.Notes));
});

Test("SelReader builds a set defined again on itself, through its own name or its alias, on the alias that keeps the old table", () =>
{
	foreach (var through in new[] { "A", "B" })
	{
		var file = Path.Combine(workDir, $"Through{through}_Rdm_Gear.lua");
		File.WriteAllText(file, $"sets.A = {{head=\"Nyame Helm\"}}\nsets.B = sets.A\nsets.A = set_combine(sets.{through}, {{body=\"Atro. Tabard +3\"}})\n");
		var read = SelReader.Read(file, $"Through{through}", "RDM", []);
		var path = Path.Combine(workDir, $"through-{through}.json");
		File.WriteAllText(path, Dto.ToJson(read.Sets));
		var sets = Dto.ReadSets(path);
		string Slots(string name) => string.Join(", ", Dto.Resolve(sets, name).OrderBy(slot => slot.Key).Select(slot => $"{slot.Key}={slot.Value.Item}"));
		Equal("B", sets.Sets.Single(set => set.Name == "A").Base);
		Equal(null, sets.Sets.Single(set => set.Name == "B").AliasOf);
		Equal("head=Nyame Helm", Slots("B"));
		Equal("body=Atro. Tabard +3, head=Nyame Helm", Slots("A"));
		Equal(0, read.Notes.Count);
	}
});

Test("Dto.ReadSets refuses an alias with pieces of its own or one that names no set", () =>
{
	string Refusal(string sets)
	{
		var path = Path.Combine(workDir, "alias-" + Guid.NewGuid().ToString("N")[..8] + ".json");
		File.WriteAllText(path, $$"""{ "schemaVersion": 1, "character": "Testy", "job": "RDM", "sets": [ {{sets}} ] }""");
		return Throws<InvalidOperationException>(() => Dto.ReadSets(path)).Message;
	}
	Contains(Refusal("""{ "name": "B", "aliasOf": "A", "slots": {} }"""), ".json: B is an alias of A, and no set has that name");
	Contains(Refusal("""{ "name": "A", "slots": {} }, { "name": "B", "aliasOf": "A", "slots": { "head": { "item": "Nyame Helm" } } }"""), ".json: B is an alias of A, so it can't have a base or slots of its own");
	Contains(Refusal("""{ "name": "A", "slots": {} }, { "name": "B", "aliasOf": "A", "base": "A", "slots": {} }"""), ".json: B is an alias of A, so it can't have a base or slots of its own");
	Contains(Refusal("""{ "name": "A", "slots": {} }, { "name": "B", "aliasOf": "A", "slots": {} }, { "name": "C", "aliasOf": "B", "slots": {} }"""), ".json: C is an alias of B, which is an alias itself; name A");
});

Test("SelReader counts lines after a string left open at the end of its line", () =>
{
	var file = Path.Combine(workDir, "Open_Rdm_Gear.lua");
	File.WriteAllText(file, "local x = 'oops\nsets.a = {nose=\"Nyame Helm\"}\n");
	Equal("Open_Rdm_Gear.lua:2: sets.a: nose isn't a slot, so it is left out", string.Join("\n", SelReader.Read(file, "Open", "RDM", []).Notes));
});

Test("SelReader reports a set defined in two branches of one if as information", () =>
{
	var file = Path.Combine(workDir, "Branch_Rdm_Gear.lua");
	File.WriteAllText(file, "if a then\n\tsets.x = {head=\"Nyame Helm\"}\nelseif b then\n\tsets.x = {head=\"Atro. Chapeau +4\"}\nelse\n\tif c then sets.x = {} end\nend\n"
		+ "if a then sets.y = {} end\nif b then sets.y = {} end\n");
	var read = SelReader.Read(file, "Branch", "RDM", []);
	Equal("Branch_Rdm_Gear.lua:4: sets.x is defined in another branch of one if; the last definition is the one read\n"
		+ "Branch_Rdm_Gear.lua:6: sets.x is defined in another branch of one if; the last definition is the one read", string.Join("\n", read.Info));
	Equal("Branch_Rdm_Gear.lua:9: sets.y is defined a second time; the last definition is the one read", string.Join("\n", read.Notes));
});

Test("StatBook takes the copy in the bag a piece names", () =>
{
	ExportItem[] owned = [new("wardrobe", "head", "Nyame Helm", ["Accuracy+10"]), new("wardrobe2", "head", "Nyame Helm", ["Accuracy+20"])];
	var book = new StatBook(Resources.Load(), owned, new Dictionary<string, Dictionary<string, int>>());
	Equal(60, book.Totals(new Dictionary<string, PieceDto> { ["head"] = new PieceDto { Item = "Nyame Helm", Bag = "wardrobe2" } })["Acc"]);
	Equal(50, book.Totals(new Dictionary<string, PieceDto> { ["head"] = new PieceDto { Item = "Nyame Helm" } })["Acc"]);
});

Test("SelReader.LoadedBefore takes the files Sel loads before the gear file, in Sel's order", () =>
{
	var sandbox = NewSandbox();
	File.WriteAllText(Path.Combine(sandbox.Repo, "data", "Testy", "Testy-Items.lua"), "\n");
	File.WriteAllText(Path.Combine(sandbox.Repo, "data", "Testy", "Testy_Crafting.lua"), "\n");
	Directory.CreateDirectory(Path.Combine(sandbox.Repo, "data", "User"));
	File.WriteAllText(Path.Combine(sandbox.Repo, "data", "User", "User-Globals.lua"), "\n");
	File.WriteAllText(Path.Combine(sandbox.Repo, "data", "User", "User-BLU.lua"), "\n");
	File.WriteAllText(Path.Combine(sandbox.Repo, "data", "User", "User-RDM.lua"), "\n");
	var run = sandbox.Run("sel-sets", "data/Testy/Testy_Blu_Gear.lua", "blu", "--out", "blu.json");
	Contains(run.Output, "read data/User/User-Globals.lua, data/Testy/Testy-Globals.lua, data/Testy/Testy-Items.lua, data/Testy/Testy_Crafting.lua, data/User/User-BLU.lua, data/Testy/Testy_Blu_Gear.lua");
});

Test("SelReader.SetName quotes any string key so it reads back as the same key, and keeps a number key a number", () =>
{
	Equal("a['it\\'s \"x\"']", SelReader.SetName(["a", "it's \"x\""]));
	Equal("a[\"it's\"]", SelReader.SetName(["a", "it's"]));
	Equal("a['back\\\\slash']", SelReader.SetName(["a", "back\\slash"]));
	var file = Path.Combine(workDir, "Keys_Rdm_Gear.lua");
	File.WriteAllText(file, "sets.weapons[1] = {main=\"Naegling\"}\nsets.weapons['1'] = {main=\"Crocea Mors\"}\nsets.other = set_combine(sets.weapons[1], {sub=\"Ammurapi Shield\"})\n");
	var read = SelReader.Read(file, "Keys", "RDM", []);
	Equal("weapons[1] weapons['1'] other", string.Join(" ", read.Sets.Sets.Select(set => set.Name)));
	Equal("weapons[1]", read.Sets.Sets.Single(set => set.Name == "other").Base);
	Equal(0, read.Notes.Count);
});

Test("owned-gear refuses a sets file for a character other than the export's", () =>
{
	var two = NewSandbox();
	File.Copy(Path.Combine(two.Repo, "data", "export", "Testy 2026-01-02 08-00-00.lua"), Path.Combine(two.Repo, "data", "export", "Ghost 2026-02-01 08-00-00.lua"));
	Equal(0, two.Run("owned-gear", "--char", "Testy", "--sets", "sets/Testy_RDM.json").ExitCode);
	Stops(two.Run("owned-gear", "--export", "data/export/Ghost 2026-02-01 08-00-00.lua", "--sets", "sets/Testy_RDM.json"), "Ghost 2026-02-01 08-00-00.lua is Ghost's export, and the sets are Testy's.");
});

Test("sel-sets writes the sets file for a Sel gear file, from the files Sel loads with it", () =>
{
	var sandbox = NewSandbox();
	File.WriteAllText(Path.Combine(sandbox.Repo, "data", "BLU.lua"), "blue_magic_maps = {}\nblue_magic_maps.Physical = S{'Foot Kick'}\nblue_magic_maps.Buff = S{'Not Read'}\n");
	File.WriteAllText(Path.Combine(sandbox.Repo, "data", "Testy", "Testy-Items.lua"), "gear.no_such_piece = {name=\"Eschan Stone\"}\n");
	var run = sandbox.Run("sel-sets", "data/Testy/Testy_Blu_Gear.lua", "blu", "--out", "blu.json");
	Equal(1, run.ExitCode);
	Contains(run.Output, "read data/BLU.lua, data/Testy/Testy-Globals.lua, data/Testy/Testy-Items.lua, data/Testy/Testy_Blu_Gear.lua");
	Contains(run.Output, "Testy_Blu_Gear.lua:30: sets.buff.Doom is built on sets.buff.Doom");
	Contains(run.Output, "9 sets, 2 spell lists -> blu.json; notes: 1");
	var sets = Dto.ReadSets(Path.Combine(sandbox.Repo, "blu.json"));
	Equal("Testy BLU", $"{sets.Character} {sets.Job}");
	Equal("Eschan Stone", sets.Sets.Single(set => set.Name == "Kiting").Slots["feet"].Item);
	Equal("Physical Foot Kick | Buff Cocoon", string.Join(" | ", sets.SpellLists!.Select(list => $"{list.Key} {string.Join(", ", list.Value)}")));
	// Without --out the sets file goes to standard output, and the notes to standard error.
	var printed = sandbox.Run("sel-sets", "data/Testy/Testy_Blu_Gear.lua", "BLU");
	using var parsed = JsonDocument.Parse(printed.StandardOutput);
	Equal(9, parsed.RootElement.GetProperty("sets").GetArrayLength());
});

Test("sel-sets stops on a gear file it can't find or doesn't know the character of, and on a job that isn't one", () =>
{
	Stops(pristine.Run("sel-sets", "data/Testy/Nowhere_Blu_Gear.lua", "BLU"), "No gear file at data/Testy/Nowhere_Blu_Gear.lua.");
	Stops(pristine.Run("sel-sets", "data/Testy/Testy-Globals.lua", "BLU"), "Testy-Globals.lua isn't named like a Sel gear file (<Character>_<Job>_Gear.lua).");
	Stops(pristine.Run("sel-sets", "data/Testy/Testy_Blu_Gear.lua", "XYZ"), "XYZ isn't a job.");
	Stops(pristine.Run("sel-sets", "data/Testy/Testy_Blu_Gear.lua", "RDM"), "Testy_Blu_Gear.lua is a BLU gear file, not RDM.");
	Stops(pristine.Run("sel-sets", "data/Testy/Testy_Blu_Gear.lua"), "Give the gear file and the job: sel-sets.cs -- <gear file> <JOB> [--out <sets.json>]");
});

Test("StatBook totals a set's stats from the help text, the copy's augments and the values it is given", () =>
{
	var sets = Dto.ReadSets(Path.Combine(pristine.Repo, "sets", "Testy_RDM.json"));
	var owned = Export.Read(Export.Latest(null));
	var enfeebling = Dto.Resolve(sets, "Midcast.Enfeebling");
	var bare = new StatBook(Resources.Load(), owned, new Dictionary<string, Dictionary<string, int>>()).Totals(enfeebling);
	Equal(164, bare["Macc"]);
	Equal(16, bare["FC"]);
	Equal(19, bare["Haste"]);
	Equal(14, bare["DT"]);
	Equal(122, bare["MND"]);
	Equal(28, bare["EnfEffect"]);
	Equal(4, bare["Refresh"]);
	True(bare.ContainsKey("Att") && bare["Att"] == 64, "Lethargy Sayon +3's Attack+64, and no pet's");
	// A value the help text hides, such as Loquac. Earring's Fast Cast, comes from what the caller gives.
	var extra = new Dictionary<string, Dictionary<string, int>> { ["Loquac. Earring"] = new() { ["FC"] = 2 } };
	var book = new StatBook(Resources.Load(), owned, extra);
	Equal(18, book.Totals(enfeebling)["FC"]);
	// A piece that names no augments takes the first copy the export holds.
	Equal(2, book.Totals(Dto.Resolve(sets, "Weapons.Idle"))["Refresh"]);
	Equal(2, book.Totals(new Dictionary<string, PieceDto> { ["main"] = new PieceDto { Item = "Colada" } })["Refresh"]);
	Contains(StatBook.Describe(book.Totals(enfeebling)), "Macc 164, ");
	Equal("", StatBook.Describe(book.Totals(new Dictionary<string, PieceDto> { ["head"] = new PieceDto { Item = Dto.Empty } })));
});

Test("StatBook adds a path item's augments at the character's rank, from the rank file, to the copy on that path", () =>
{
	var ranks = RankAugments.Read(Characters.RankAugments("Testy"));
	var helm = new Dictionary<string, PieceDto> { ["head"] = new PieceDto { Item = "Nyame Helm" } };
	ExportItem[] onPath = [new("wardrobe", "head", "Nyame Helm", ["Path: B"])];
	var unranked = new StatBook(Resources.Load(), onPath, new Dictionary<string, Dictionary<string, int>>()).Totals(helm);
	// Testy's Nyame Helm is path B, rank 2: Attack+4 Rng. Atk.+4, Weapon skill damage +1%.
	var ranked = new StatBook(Resources.Load(), onPath, new Dictionary<string, Dictionary<string, int>>(), ranks).Totals(helm);
	Equal(unranked["Att"] + 4, ranked["Att"]);
	Equal(unranked.GetValueOrDefault("WSD") + 1, ranked["WSD"]);
	// The export can print a copy with no augments after the player has given its rank; rank-doc.cs writes that row
	// with the given path and rank, so the row is the copy's.
	ExportItem[] bare = [new("wardrobe", "head", "Nyame Helm", [])];
	Equal(StatBook.Describe(ranked), StatBook.Describe(new StatBook(Resources.Load(), bare, new Dictionary<string, Dictionary<string, int>>(), ranks).Totals(helm)));
	// A copy printed on another path isn't the row's.
	ExportItem[] otherPath = [new("wardrobe", "head", "Nyame Helm", ["Path: A"])];
	Equal(StatBook.Describe(unranked), StatBook.Describe(new StatBook(Resources.Load(), otherPath, new Dictionary<string, Dictionary<string, int>>(), ranks).Totals(helm)));
});

Test("StatBook warns of a path copy whose rank the player hasn't given, and not of an unranked piece", () =>
{
	var ranks = RankAugments.Read(Characters.RankAugments("Testy"));
	ExportItem[] owned = [new("wardrobe", "ammo", "Coiste Bodhar", ["Path: A"]), new("wardrobe", "waist", "Eschan Stone", [])];
	var warnings = new List<string>();
	new StatBook(Resources.Load(), owned, new Dictionary<string, Dictionary<string, int>>(), ranks).Totals(new Dictionary<string, PieceDto>
	{
		["ammo"] = new PieceDto { Item = "Coiste Bodhar" },
		["waist"] = new PieceDto { Item = "Eschan Stone" },
	}, warnings);
	Equal("ammo: \"Coiste Bodhar\" is path A at a rank the player hasn't given, so its rank augments are missing", string.Join("\n", warnings));
});

Test("StatBook warns of a path copy the rank file has no row for, when it is given a rank file", () =>
{
	ExportItem[] owned = [new("wardrobe", "ammo", "Coiste Bodhar", ["Path: A"])];
	var ammo = new Dictionary<string, PieceDto> { ["ammo"] = new PieceDto { Item = "Coiste Bodhar" } };
	var warnings = new List<string>();
	new StatBook(Resources.Load(), owned, new Dictionary<string, Dictionary<string, int>>(), new Dictionary<string, RankedCopy>()).Totals(ammo, warnings);
	Equal("ammo: \"Coiste Bodhar\" prints path A, and the rank file has no row for it, so its rank augments are missing", string.Join("\n", warnings));
	// A caller that gives no rank file counts no rank augments, and isn't told so piece by piece.
	var none = new List<string>();
	new StatBook(Resources.Load(), owned, new Dictionary<string, Dictionary<string, int>>()).Totals(ammo, none);
	Equal(0, none.Count);
});

Test("StatBook warns when the copy prints another path than the rank file's row, so rank-doc.cs is out of date", () =>
{
	var ranks = RankAugments.Read(Characters.RankAugments("Testy"));
	// Testy's rank file has Eschan Stone as path none, rank 0.
	ExportItem[] owned = [new("wardrobe", "waist", "Eschan Stone", ["Path: A"])];
	var warnings = new List<string>();
	new StatBook(Resources.Load(), owned, new Dictionary<string, Dictionary<string, int>>(), ranks)
		.Totals(new Dictionary<string, PieceDto> { ["waist"] = new PieceDto { Item = "Eschan Stone" } }, warnings);
	Equal("waist: \"Eschan Stone\" prints path A, but the rank file gives path none; run rank-doc.cs, since its rank augments are missing", string.Join("\n", warnings));
});

Test("StatBook counts an item Oboro ranks up at its maximum rank, from docs/rank-augments.md, and warns below it", () =>
{
	var file = Path.Combine(workDir, "Oboro_rank_augments.md");
	File.WriteAllText(file, string.Join("\n",
		"| Item | Slot | Path | Rank | Given | Augments at that rank |",
		"|---|---|---|---|---|---|",
		"",
		"## Items Oboro ranks up",
		"",
		"| Item | Slot | Max rank | Oboro's copy |",
		"|---|---|---|---|",
		"| Dls. Torque +1 | neck | 20 | `'Path: A'`, rank 20 (2026-01-02) |",
		"| Mirage Stole +2 | neck | 25 | `'Path: A'`, rank 20 (2026-01-02) |",
		"| Tizona | main | 15 | `'Path: A'` (so Level 119 III), rank 15 (2026-01-02) |",
		"| Almace | main | 15 | no augments: rank 0, stage unknown |",
		""));
	var ranks = RankAugments.Read(file, Path.Combine(pristine.Repo, "docs", "rank-augments.md"));
	ExportItem[] owned =
	[
		new("wardrobe", "neck", "Dls. Torque +1", ["Path: A"]), new("wardrobe", "neck", "Mirage Stole +2", ["Path: A"]),
		new("wardrobe", "main", "Tizona", ["Path: A"]), new("wardrobe", "main", "Almace", []),
	];
	var none = new Dictionary<string, Dictionary<string, int>>();
	(Dictionary<string, int> Totals, string Warnings) Wear(string slot, string item)
	{
		var piece = new Dictionary<string, PieceDto> { [slot] = new PieceDto { Item = item } };
		var bare = new StatBook(Resources.Load(), owned, none).Totals(piece);
		var warnings = new List<string>();
		var ranked = new StatBook(Resources.Load(), owned, none, ranks).Totals(piece, warnings);
		var added = ranked.Keys.Union(bare.Keys).Where(stat => ranked.GetValueOrDefault(stat) != bare.GetValueOrDefault(stat))
			.ToDictionary(stat => stat, stat => ranked.GetValueOrDefault(stat) - bare.GetValueOrDefault(stat));
		return (added, string.Join("\n", warnings));
	}
	// At its maximum rank, bg-wiki's augments are the copy's.
	Equal("EnhDur 20, EnfDur 20, INT 12, MND 12 | ", $"{StatBook.Describe(Wear("neck", "Dls. Torque +1").Totals)} | {Wear("neck", "Dls. Torque +1").Warnings}");
	// Below it, they aren't known.
	Equal(" | neck: \"Mirage Stole +2\" is rank 20 of 25, and its augments are known at rank 25 only, so they're missing",
		$"{StatBook.Describe(Wear("neck", "Mirage Stole +2").Totals)} | {Wear("neck", "Mirage Stole +2").Warnings}");
	// An Ultimate Weapon's augments work in the main hand only.
	Equal("Acc 30, Macc 30 | ", $"{StatBook.Describe(Wear("main", "Tizona").Totals)} | {Wear("main", "Tizona").Warnings}");
	Equal(" | ", $"{StatBook.Describe(Wear("sub", "Tizona").Totals)} | {Wear("sub", "Tizona").Warnings}");
	// A copy that exports with no augments is rank 0.
	Equal(" | ", $"{StatBook.Describe(Wear("main", "Almace").Totals)} | {Wear("main", "Almace").Warnings}");
});

Test("StatBook reads \"X and Y +N\" as two stats only in docs/rank-augments.md's text, not in help text", () =>
{
	// Seven items' help text says "HP and MP recovered while healing +2", which gives no HP.
	Equal("", StatBook.Describe(StatBook.Read("HP and MP recovered while healing +2")));
});

Test("StatBook reads the augments as docs/rank-augments.md writes them at an Oboro item's maximum rank", () =>
{
	string Read(string text) => StatBook.Describe(StatBook.Read(text, sharedValues: true));
	Equal("EnhDur 20, EnfDur 20, INT 12, MND 12", Read("INT and MND +12, Enhancing magic effect duration +20%, Enfeebling magic effect duration +20%"));
	Equal("STP 7, Crit 5, STR 25, DEX 25", Read("STR and DEX +25, Store TP +7, Critical hit rate +5%"));
	Equal("Acc 30, Macc 30", Read("DMG +38, Accuracy and Magic Accuracy +30, Sword enhancement spell damage +150% (its own enspell damage only)"));
});
Test("StatBook reads the augments as the rank file writes them", () =>
{
	string Read(string text) => StatBook.Describe(StatBook.Read(text));
	Equal("Acc 15, Macc 15, EnhSkill 10", Read("Accuracy+15, Mag. Acc.+15, Enha. mag. skill +10"));
	Equal("Macc 15, EnfSkill 2", Read("Mag. Acc.+15, Enfb. mag. skill +2"));
	Equal("DA 5, STR 14", Read("STR+14, Double Attack +5%"));
	Equal("FC 8, SIRD 3", Read("\"Fast Cast\" +8%, Spell Interruption Rate -3%"));
	Equal("Att 25, WSD 10, DA 3", Read("Attack+25 Rng. Atk.+25, Weapon skill damage +10%, \"Double Attack\"+3%"));
});

Test("StatBook reads the export's abbreviated Triple Attack augment", () =>
{
	string Read(string text) => StatBook.Describe(StatBook.Read(text));
	Equal("Acc 21, Att 31, TA 2", Read("Accuracy+21 Attack+21, \"Triple Atk.\"+2, Attack+10"));
	Equal("DA 2, TA 2, STR 9, DEX 8", Read("STR+9, DEX+8, \"Dbl.Atk.\"+2, \"Triple Atk.\"+2"));
});

Test("StatBook counts the set bonuses docs/gear-notes.md gives, by the pieces worn", () =>
{
	string Bonus(params string[] pieces) => StatBook.Describe(StatBook.SetBonuses(pieces));
	Equal("", Bonus("Atro. Chapeau +4"));
	Equal("Acc 15, Macc 15", Bonus("Atro. Chapeau +4", "Atrophy Tabard +2"));
	// NQ and +1 Artifact armor has no set bonus; a Regal Earring counts as one more piece.
	Equal("", Bonus("Atro. Chapeau +4", "Atro. Gloves +1", "Atro. Boots"));
	Equal("Acc 30, Macc 30", Bonus("Atro. Chapeau +3", "Atro. Tights +2", "Regal Earring"));
	Equal("Acc 60, Macc 60", Bonus("Atro. Chapeau +4", "Atrophy Tabard +4", "Atro. Gloves +4", "Atro. Tights +4", "Atro. Boots +4", "Regal Earring"));
	Equal("Acc 15, Macc 15", Bonus("Assim. Keffiyeh +3", "Assim. Jubbah +2"));
	Equal("", Bonus("Regal Earring"));
	// Jhakri: every +2 piece and the ring; the first adds nothing, each after it 3%, up to 12%.
	Equal("FC 3", Bonus("Jhakri Coronal +2", "Jhakri Slops +2"));
	Equal("FC 6", Bonus("Jhakri Coronal +2", "Jhakri Slops +2", "Jhakri Ring"));
	Equal("", Bonus("Jhakri Coronal +2", "Jhakri Slops +1"));
	Equal("FC 12", Bonus("Jhakri Coronal +2", "Jhakri Robe +2", "Jhakri Cuffs +2", "Jhakri Slops +2", "Jhakri Pigaches +2", "Jhakri Ring"));
});

Test("StatBook counts a right-ear-only earring's right-ear lines in the right ear only, and the rest in either ear", () =>
{
	var extra = new Dictionary<string, Dictionary<string, int>>
	{
		["Balder Earring +1"] = new() { ["DT"] = -1 },
		["Lethargy Earring"] = new() { ["Macc"] = 5 },
	};
	string Wear(string slot, string item) =>
		StatBook.Describe(new StatBook(Resources.Load(), [], extra).Totals(new Dictionary<string, PieceDto> { [slot] = new PieceDto { Item = item } }));
	// Balder Earring +1: "Attack+10 Evasion+10\n"Store TP"+3\nRight ear: "Quadruple Attack"+1%". The lines before
	// "Right ear:" and its extra values count in either ear.
	// "Quadruple Attack" isn't a stat StatBook counts, so the right ear adds nothing here.
	Equal("Att 10, DT -1, STP 3, Eva 10", Wear("left_ear", "Balder Earring +1"));
	Equal("Att 10, DT -1, STP 3, Eva 10", Wear("right_ear", "Balder Earring +1"));
	// Lethargy Earring's help text opens with "Right ear:", so in the left ear it gives nothing, its extra values
	// included.
	Equal("Macc 5, FC 7, EnhDur 7", Wear("right_ear", "Lethargy Earring"));
	Equal("", Wear("left_ear", "Lethargy Earring"));
});

Test("StatBook counts a weapon's magic accuracy skill from the main hand only", () =>
{
	string Wear(string slot) =>
		StatBook.Describe(new StatBook(Resources.Load(), [], new Dictionary<string, Dictionary<string, int>>())
			.Totals(new Dictionary<string, PieceDto> { [slot] = new PieceDto { Item = "Almace" } }));
	Equal("MaccSkill 255, MDmg 186, DEX 50, SwordSkill 269", Wear("main"));
	Equal("MDmg 186, DEX 50, SwordSkill 269", Wear("sub"));
});

Test("StatBook counts ranged accuracy and attack as neither Accuracy nor Attack, in help text or augments", () =>
{
	string Read(string text) => StatBook.Describe(StatBook.Read(text));
	Equal("", Read("Rng.Atk.+3"));
	Equal("", Read("Rng.Acc.+20"));
	Equal("", Read("Rng. Acc.+15 Rng. Atk.+15"));
	Equal("Acc 10", Read("Ranged Accuracy+40 Ranged Attack+30 Accuracy+10"));
	Equal("Acc 20, Att 20", Read("Accuracy+20 Attack+20"));
	Equal("Acc 20, Att 20", Read("Accuracy+20 Attack+20 Rng.Acc.+20 Rng.Atk.+20"));
	Equal("Macc 25, MAB 25", Read("Mag. Acc.+25 \"Mag.Atk.Bns.\"+25"));
	Equal("MAB 12", Read("\"Mag. Atk. Bns.\"+12"));
	// Through a piece: Nyame Helm's help text gives Accuracy+40 Attack+30, and the copy's ranged augment adds neither.
	var copy = new ExportItem("wardrobe", "head", "Nyame Helm", ["Rng.Atk.+3", "Rng.Acc.+5"]);
	var totals = new StatBook(Resources.Load(), [copy], new Dictionary<string, Dictionary<string, int>>())
		.Totals(new Dictionary<string, PieceDto> { ["head"] = new PieceDto { Item = "Nyame Helm", Augments = ["Rng.Atk.+3", "Rng.Acc.+5"] } });
	Equal("40 30", $"{totals["Acc"]} {totals["Att"]}");
});

Test("StatBook warns of a piece the resources don't know and of augments no exported copy has", () =>
{
	var sets = Dto.ReadSets(Path.Combine(pristine.Repo, "sets", "Testy_RDM_mistakes.json"));
	var book = new StatBook(Resources.Load(), Export.Read(Export.Latest(null)), new Dictionary<string, Dictionary<string, int>>());
	var warnings = new List<string>();
	book.Totals(Dto.Resolve(sets, "Broken"), warnings);
	var text = string.Join("\n", warnings);
	Contains(text, "legs: \"Nyame Helmm\" isn't a weapon or armor in Windower's resources, so it adds nothing");
	Contains(text, "back: \"Sucellos's Cape\" [MND+20, Nope] matches no copy in the export, so only its help text counts");
	Contains(text, "neck: \"Regal Gem\" matches no copy in the export, so only its help text counts");
	Contains(text, "right_ring: \"Stikini Ring\" matches no copy in the export");
	Equal(4, warnings.Count);
});

Test("set-stats warns of what it couldn't count, on standard error and in its JSON", () =>
{
	var run = pristine.Run("set-stats", "--in", "sets/Testy_RDM_mistakes.json", "--set", "^Broken$");
	Equal(0, run.ExitCode);
	Contains(run.Output, "  warn  Broken legs: \"Nyame Helmm\" isn't a weapon or armor in Windower's resources, so it adds nothing");
	True(run.StandardOutput.Contains("warn") is false, "the warnings go to standard error");
	var json = pristine.Run("set-stats", "--in", "sets/Testy_RDM_mistakes.json", "--set", "^Broken$", "--json");
	using var parsed = JsonDocument.Parse(json.StandardOutput);
	Equal(4, parsed.RootElement[0].GetProperty("warnings").GetArrayLength());
	using var clean = JsonDocument.Parse(pristine.Run("set-stats", "--in", "sets/Testy_RDM.json", "--set", "^Idle$", "--json").StandardOutput);
	Equal(0, clean.RootElement[0].GetProperty("warnings").GetArrayLength());
});

Test("set-stats prints each set's totals, laid over its base, with the values a file gives", () =>
{
	var extra = Path.Combine(workDir, "extra-stats.json");
	File.WriteAllText(extra, """{ "Loquac. Earring": { "FC": 2 } }""");
	var run = pristine.Run("set-stats", "--in", "sets/Testy_RDM.json", "--set", "^Midcast", "--extra", extra);
	Equal(0, run.ExitCode);
	Contains(run.Output, "Midcast.Enfeebling\n    = Acc 128, ");
	Contains(run.Output, "FC 18");
	Contains(run.Output, "Midcast['Stoneskin']\n    = ");
	True(run.Output.Contains("Weapons") is false, "--set keeps the sets whose name matches");
	var json = pristine.Run("set-stats", "--in", "sets/Testy_RDM.json", "--set", "^Midcast.Enfeebling$", "--json");
	using var parsed = JsonDocument.Parse(json.StandardOutput);
	Equal("Midcast.Enfeebling", parsed.RootElement[0].GetProperty("set").GetString());
	Equal(16, parsed.RootElement[0].GetProperty("stats").GetProperty("FC").GetInt32());
	Stops(pristine.Run("set-stats"), "Name the sets file: --in <sets.json>");
	Stops(pristine.Run("set-stats", "--in", "sets/Testy_RDM.json", "--extra", Path.Combine(workDir, "no-such-extra.json")), "No stats file at ");
});

Test("set-stats adds what the character's rank file gives, and warns of a rank the player hasn't given", () =>
{
	var sets = Dto.ReadSets(Path.Combine(pristine.Repo, "sets", "Testy_RDM.json"));
	var unranked = new StatBook(Resources.Load(), Export.Read(Export.Latest(null)), new Dictionary<string, Dictionary<string, int>>())
		.Totals(Dto.Resolve(sets, "Midcast.Enfeebling"));
	EnfSkill(pristine, unranked.GetValueOrDefault("EnfSkill") + 5);
	var ws = pristine.Run("set-stats", "--in", "sets/Testy_RDM.json", "--set", "^WS$");
	Contains(ws.Output, "  warn  WS ammo: \"Coiste Bodhar\" is path A at a rank the player hasn't given, so its rank augments are missing");
	// A character with no rank file gets the totals without it.
	var sandbox = NewSandbox();
	File.Delete(Path.Combine(sandbox.Repo, "data", "Testy", "Testy_rank_augments.md"));
	EnfSkill(sandbox, unranked.GetValueOrDefault("EnfSkill"));

	void EnfSkill(Sandbox where, int expected)
	{
		var run = where.Run("set-stats", "--in", "sets/Testy_RDM.json", "--set", "^Midcast.Enfeebling$", "--json");
		Equal(0, run.ExitCode);
		using var parsed = JsonDocument.Parse(run.StandardOutput);
		// A stat that totals 0 is left out.
		var stats = parsed.RootElement[0].GetProperty("stats");
		Equal(expected, stats.TryGetProperty("EnfSkill", out var skill) ? skill.GetInt32() : 0);
	}
});

Test("Characters finds each folder that holds a character's notes or gear list, and names its documents", () =>
{
	Equal("Testy", string.Join(" ", Characters.All()));
	// A folder of Lua files alone, as data/User is, holds no character's documents.
	var user = Path.Combine(pristine.Repo, "data", "User");
	var listy = Path.Combine(pristine.Repo, "data", "Listy");
	Directory.CreateDirectory(user);
	Directory.CreateDirectory(listy);
	File.WriteAllText(Path.Combine(user, "User-Globals.lua"), "-- settings\n");
	File.WriteAllText(Path.Combine(listy, "Listy_gear_list.md"), "# Listy\n");
	try
	{
		Equal("Listy Testy", string.Join(" ", Characters.All()));
	}
	finally
	{
		Directory.Delete(user, true);
		Directory.Delete(listy, true);
	}
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

Test("check-export passes a sets file whose gear is owned, wearable and in reach", () =>
{
	var run = pristine.Run("check-export", "--in", "sets/Testy_RDM.json");
	Equal(0, run.ExitCode);
	Contains(run.Output, "Export: data/export/Testy 2026-01-02 08-00-00.lua");
	Contains(run.Output, "sets/Testy_RDM.json: RDM, 11 sets, 14 pieces");
	Contains(run.Output, "problems: 0 errors, 0 warnings");
	var blu = pristine.Run("check-export", "--in", "sets/Testy_BLU.json");
	Equal(0, blu.ExitCode);
	Contains(blu.Output, "sets/Testy_BLU.json: BLU, 2 sets, 3 pieces");
});

Test("check-export reports each kind of mistake in a sets file", () =>
{
	var run = pristine.Run("check-export", "--in", "sets/Testy_RDM_mistakes.json");
	Equal(1, run.ExitCode);
	Contains(run.Output, "ERROR \"Regal Gem\": not in the export (Broken neck, Burst neck)");
	Contains(run.Output, "ERROR \"Sucellos's Cape\" [MND+20, Nope]: augments match no copy. The export has: [MND+20, Mag. Acc+20 /Mag. Dmg.+20, Haste+10] | [INT+20");
	Contains(run.Output, "ERROR \"Nyame Helmm\": no weapon or armor has that name or log name, so GearSwap equips nothing and says nothing (Broken legs)");
	Contains(run.Output, "ERROR \"Hashishin Bazubands +3\": RDM can't wear it (jobs: BLU) (Broken hands)");
	Contains(run.Output, "ERROR \"Stikini Ring\": goes in left_ring or right_ring, not left_ear (Broken left_ear)");
	Contains(run.Output, "ERROR \"Stikini Ring\" (wardrobe8): pinned to wardrobe8, but the matching copies are in wardrobe (Broken right_ring)");
	Contains(run.Output, "warn  \"Ayanmo Corazza +2\": only on storage slip 23. Get it back from a porter moogle and put it in a wardrobe before a set can wear it (Broken body)");
	Contains(run.Output, "warn  \"Ea Houppelande\": only in safe2. GearSwap equips from the inventory and the wardrobes, so move it (Burst body)");
	Contains(run.Output, "problems: 6 errors, 2 warnings");
	True(run.Output.Contains("Nyame Helm\"") is false, "the base's own piece is fine, and isn't reported for each set built on it");
	// --json gives one finding for each set and slot.
	var json = pristine.Run("check-export", "--in", "sets/Testy_RDM_mistakes.json", "--json");
	Equal(1, json.ExitCode);
	using var parsed = JsonDocument.Parse(json.StandardOutput);
	Equal(9, parsed.RootElement.GetArrayLength());
	var burst = parsed.RootElement.EnumerateArray().Single(finding => finding.GetProperty("set").GetString() == "Burst" && finding.GetProperty("slot").GetString() == "neck");
	Equal("check-export error Regal Gem not in the export", $"{burst.GetProperty("tool").GetString()} {burst.GetProperty("severity").GetString()} {burst.GetProperty("item").GetString()} {burst.GetProperty("message").GetString()}");
});

Test("check-export can read an older export, where newer pieces are missing", () =>
{
	var run = pristine.Run("check-export", "--in", "sets/Testy_BLU.json", "--export", Path.Combine(pristine.Repo, "data", "export", "Testy 2026-01-01 08-00-00.lua"));
	Equal(1, run.ExitCode);
	Contains(run.Output, "ERROR \"Rumination Sash\": not in the export (Idle waist)");
});

Test("check-export --bags holds every piece to the bags named", () =>
{
	var run = pristine.Run("check-export", "--in", "sets/Testy_BLU.json", "--bags", "wardrobe,wardrobe2");
	Equal(1, run.ExitCode);
	Contains(run.Output, "ERROR \"Rumination Sash\": only in inventory, and --bags allows wardrobe, wardrobe2 (Idle waist)");
	Contains(run.Output, "problems: 1 errors, 0 warnings");
	Equal(0, pristine.Run("check-export", "--in", "sets/Testy_RDM.json", "--bags", "wardrobe").ExitCode);
	Stops(pristine.Run("check-export", "--in", "sets/Testy_RDM.json", "--bags", "wardrobe,locker"), "--bags names locker, which GearSwap can't equip from. Bags: inventory wardrobe");
});

Test("check-export holds a piece pinned to a bag to the copies in that bag", () =>
{
	var sandbox = NewSandbox();
	File.WriteAllText(Path.Combine(sandbox.Repo, "sets", "pinned.json"),
		"""{ "schemaVersion": 1, "character": "Testy", "job": "RDM", "sets": [ { "name": "Idle", "slots": { "main": { "item": "Colada", "bag": "locker" } } } ] }""");
	var run = sandbox.Run("check-export", "--in", "sets/pinned.json");
	Equal(0, run.ExitCode);
	Contains(run.Output, "warn  \"Colada\" (locker): only in locker. GearSwap equips from the inventory and the wardrobes, so move it (Idle main)");
	var bags = sandbox.Run("check-export", "--in", "sets/pinned.json", "--bags", "wardrobe");
	Equal(1, bags.ExitCode);
	Contains(bags.Output, "ERROR \"Colada\" (locker): only in locker, and --bags allows wardrobe (Idle main)");
});

Test("sel-sets and check-export: what Testy's Sel gear file wears is checked, and an empty slot is no piece", () =>
{
	var sandbox = NewSandbox();
	Equal(1, sandbox.Run("sel-sets", "data/Testy/Testy_Blu_Gear.lua", "BLU", "--out", "blu.json").ExitCode);
	var run = sandbox.Run("check-export", "--in", "blu.json");
	Equal(1, run.ExitCode);
	Contains(run.Output, "ERROR \"Stikini Ring\" (wardrobe8): pinned to wardrobe8, but the matching copies are in wardrobe (precast.FC left_ring, engaged left_ring)");
	Contains(run.Output, "ERROR \"Sucellos's Cape\" [MND+20, Mag. Acc+20 /Mag. Dmg.+20, Haste+10]: BLU can't wear it (jobs: RDM) (midcast[\"Testy's Own\"] back)");
	Contains(run.Output, "warn  \"Ayanmo Corazza +2\": only on storage slip 23.");
	Contains(run.Output, "problems: 2 errors, 1 warnings");
	True(run.Output.Contains("empty") is false, run.Output);
});

Test("a tool stops on an option it doesn't know, a sets file that isn't there, or a stray word", () =>
{
	var unknown = pristine.Run("check-export", "--jobs", "RDM");
	Equal(2, unknown.ExitCode);
	Contains(unknown.Output, "Unknown option --jobs. Options: --in <value> --bags <value> --export <value> --json");
	var noFile = pristine.Run("check-export", "--in", "sets/Testy_THF.json");
	Equal(2, noFile.ExitCode);
	Contains(noFile.Output, "No sets file at sets/Testy_THF.json.");
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
	Stops(pristine.Run("check-export", "--in"), "--in needs a value.");
	var nobody = Path.Combine(workDir, "nobody.json");
	File.WriteAllText(nobody, """{ "schemaVersion": 1, "character": "Nobody", "job": "RDM", "sets": [] }""");
	Stops(pristine.Run("check-export", "--in", nobody), "No export for Nobody in data/export.");
	Stops(pristine.Run("check-export", "--in", "sets/Testy_RDM.json", "--export", "nowhere.lua"), "No export at nowhere.lua.");
	Stops(pristine.Run("check-export", "--in", "sets/Testy_RDM.json", "--export", Path.Combine("data", "Testy", "Testy_Blu_Gear.lua")), "Testy_Blu_Gear.lua isn't named like a //gs export (<character> <date> <time>.lua).");
	Stops(pristine.Run("owned-gear", "--slot", "bogus"), "bogus isn't a slot. Slots: main sub range ammo head neck ear body hands ring back waist legs feet");
	Stops(pristine.Run("owned-gear", "--job", "XYZ"), "XYZ isn't a job. Jobs: WAR MNK");
	Stops(pristine.Run("sims"), "Name the job: --job rdm");
	Stops(pristine.Run("sims", "--job", "nope"), "No simulated sets for nope in .claude/cache/bg_job_guides. Run: dotnet run --no-cache .claude/tools/fetch-sources.cs");
	Stops(pristine.Run("sims", "--job", "rdm", "--set", "zzzz"), "No set on the rdm page has \"zzzz\" in its name.");
	Stops(pristine.Run("wsdist-gear"), "Give one regex to match item names against, or --check-nyame.");
	Stops(pristine.Run("wsdist-gear", "nyame", "helm"), "Give one regex to match item names against, or --check-nyame.");
	Stops(pristine.Run("wiki"), "Name at least one page: dotnet run --no-cache .claude/tools/wiki.cs -- \"Nyame Helm\"");
	// With exports for two characters, a tool has to be told whose to read. A sets file says whose it is.
	var two = NewSandbox();
	File.Copy(Path.Combine(two.Repo, "data", "export", "Testy 2026-01-02 08-00-00.lua"), Path.Combine(two.Repo, "data", "export", "Ghost 2026-02-01 08-00-00.lua"));
	Stops(two.Run("owned-gear"), "data/export holds exports for 2 characters (Ghost, Testy). Pass --char <name>.");
	Equal(0, two.Run("owned-gear", "--char", "Testy").ExitCode);
	Equal(0, two.Run("check-export", "--in", "sets/Testy_RDM.json").ExitCode);
	Stops(two.Run("check-export", "--in", "sets/Testy_RDM.json", "--export", "data/export/Ghost 2026-02-01 08-00-00.lua"), "Ghost 2026-02-01 08-00-00.lua is Ghost's export, and the sets are Testy's.");
});

Test("a tool stops when the file it checks isn't there or isn't named, or holds nothing for it to check", () =>
{
	var sandbox = NewSandbox();
	File.Delete(Path.Combine(sandbox.Repo, "data", "Testy", "Testy_gear_list.md"));
	Stops(sandbox.Run("check-blu-spells"), "Name the sets file to check: --in <sets.json>");
	Stops(sandbox.Run("check-blu-spells", "--in", "sets/Testy_RDM.json"), "sets/Testy_RDM.json has no spellLists to check.");
	Stops(sandbox.Run("gear-list", testySets), "No gear list at data/Testy/Testy_gear_list.md.");
	Stops(sandbox.Run("gear-list"), "Name a sets file for each job: --in <sets.json>");
	Stops(sandbox.Run("check-export"), "Name the sets file to check: --in <sets.json>");
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
	var export = noExports.Run("check-export", "--in", "sets/Testy_RDM.json");
	Equal(2, export.ExitCode);
	Contains(export.Output, "data/export holds no //gs export");
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
	var setless = NewSandbox();
	File.WriteAllText(Path.Combine(setless.Repo, "sets", "Testy_RDM.json"), "null");
	Stops(setless.Run("check-export", "--in", "sets/Testy_RDM.json"), "sets/Testy_RDM.json can't be read as a sets file");
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

Test("gear-list passes a list that matches the sets files, and --print reproduces it", () =>
{
	var run = pristine.Run("gear-list", testySets);
	Equal(0, run.ExitCode);
	Contains(run.Output, "rows 17; BLU 3 (2 BLU only); RDM 15 (14 RDM only); BLU and RDM 1");
	Contains(run.Output, "problems: 0");
	var printed = pristine.Run("gear-list", [.. testySets, "--print"]).Output.Replace("\r", "").Split('\n').Where(line => line.StartsWith('|') || line.StartsWith("## ")).ToList();
	// The Reference section at the top links the character's other files, and isn't part of the table.
	var written = File.ReadAllLines(Path.Combine(pristine.Repo, "data", "Testy", "Testy_gear_list.md")).Where(line => line.StartsWith('|') || (line.StartsWith("## ") && line != "## Reference")).ToList();
	Equal(string.Join("\n", written), string.Join("\n", printed));
});

Test("gear-list reports rows, counts, copies and totals that differ from the sets files", () =>
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
	var run = sandbox.Run("gear-list", testySets);
	Equal(1, run.ExitCode);
	Contains(run.Output, "Nyame Helm, RDM column\n    list:  \n    sets:  `Idle`");
	Contains(run.Output, "Almace has a row, but no set wears it");
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

Test("gear-list --json writes a finding for each problem in the list", () =>
{
	var sandbox = NewSandbox();
	sandbox.Edit("data/Testy/Testy_gear_list.md", "## Ammo (1)", "## Ammo (2)");
	var run = sandbox.Run("gear-list", [.. testySets, "--json"]);
	Equal(1, run.ExitCode);
	using var parsed = JsonDocument.Parse(run.StandardOutput);
	Equal(1, parsed.RootElement.GetArrayLength());
	var finding = parsed.RootElement[0];
	Equal("gear-list error ## Ammo (2) has 1 rows", $"{finding.GetProperty("tool").GetString()} {finding.GetProperty("severity").GetString()} {finding.GetProperty("message").GetString()}");
	Equal(0, JsonDocument.Parse(pristine.Run("gear-list", [.. testySets, "--json"]).StandardOutput).RootElement.GetArrayLength());
	Stops(pristine.Run("gear-list", [.. testySets, "--json", "--print"]), "--print writes a table and --json writes findings; give one of them.");
});

Test("gear-list checks a claim that some of a job's pieces are worn by that job alone", () =>
{
	var sandbox = NewSandbox();
	sandbox.Edit("data/Testy/Testy_gear_list.md", "1 worn by both)", "1 worn by both; 9 of them RDM only)");
	var run = sandbox.Run("gear-list", testySets);
	Equal(1, run.ExitCode);
	Contains(run.Output, "The list says 9 of them RDM only, and 14 rows have RDM sets alone");
});

Test("gear-list reports a sets file for a job the list has no column for, and --print gives the table with it", () =>
{
	var sandbox = NewSandbox();
	File.WriteAllText(Path.Combine(sandbox.Repo, "sets", "Testy_WAR.json"),
		"""{ "schemaVersion": 1, "character": "Testy", "job": "WAR", "sets": [ { "name": "Idle", "slots": { "main": { "item": "Naegling" }, "head": { "item": "Nyame Helm" }, "waist": { "item": "Eschan Stone" } } } ] }""");
	string[] three = [.. testySets, "--in", "sets/Testy_WAR.json"];
	var run = sandbox.Run("gear-list", three);
	Equal(1, run.ExitCode);
	Contains(run.Output, "sets/Testy_WAR.json is for WAR, and the list has no WAR column. --print gives the table with a WAR column");
	Contains(run.Output, "problems: 1");
	var printed = sandbox.Run("gear-list", [.. three, "--print"]).Output.Replace("\r", "");
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
	var run = sandbox.Run("gear-list", testySets);
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
	var run = sandbox.Run("gear-list", testySets);
	Equal(0, run.ExitCode);
	Contains(run.Output, "problems: 0");
});

Test("gear-list counts a malformed row or a column with no sets file as a problem in the list", () =>
{
	var sandbox = NewSandbox();
	sandbox.Edit("data/Testy/Testy_gear_list.md", "| Naegling |  |  | `Weapons['Savage Blade']` |", "| Naegling |  |  | `Weapons['Savage Blade']` | extra |");
	var malformed = sandbox.Run("gear-list", testySets);
	Equal(1, malformed.ExitCode);
	Contains(malformed.Output, "line 17: 5 cells, but the header has 4");
	var column = pristine.Run("gear-list", "--in", "sets/Testy_RDM.json");
	Equal(1, column.ExitCode);
	Contains(column.Output, "The list has a BLU column, but no --in sets file is for BLU");
});

Test("gear-list leaves tables outside the gear sections alone, and reports a section whose columns differ", () =>
{
	var sandbox = NewSandbox();
	var list = "data/Testy/Testy_gear_list.md";
	sandbox.Edit(list, "## Reference\n", "## Reference\n\n| File | What it holds |\n|---|---|\n| Testy_notes.md | The player's rules |\n");
	var reference = sandbox.Run("gear-list", testySets);
	Equal(0, reference.ExitCode);
	Contains(reference.Output, "problems: 0");
	sandbox.Edit(list, "## Ammo (1)\n\n| Item | Copy | BLU sets | RDM sets |\n|---|---|---|---|\n| Coiste Bodhar |  |  | `WS` |", "## Ammo (1)\n\n| Item | Copy | RDM sets |\n|---|---|---|\n| Coiste Bodhar |  | `WS` |");
	var columns = sandbox.Run("gear-list", testySets);
	Equal(1, columns.ExitCode);
	Contains(columns.Output, "## Ammo has the job columns RDM, but the list's first table has BLU, RDM");
	Contains(columns.Output, "problems: 1");
});

Test("gear-list reports a piece worn under two sections, and a row the export doesn't back", () =>
{
	var sets = NewSandbox();
	sets.Edit("sets/Testy_RDM.json", "{ \"name\": \"WS\", \"slots\": { \"ammo\": { \"item\": \"Coiste Bodhar\" } } }", "{ \"name\": \"WS\", \"slots\": { \"ammo\": { \"item\": \"Coiste Bodhar\" }, \"waist\": { \"item\": \"Nyame Helm\" } } }");
	var worn = sets.Run("gear-list", testySets);
	Equal(1, worn.ExitCode);
	Contains(worn.Output, "RDM: Nyame Helm is worn in waist (Waist) by WS, but elsewhere under Head");
	var rows = NewSandbox();
	var list = "data/Testy/Testy_gear_list.md";
	rows.Edit(list, "| Eschan Stone |  |", "| Eschan Stonee |  |");
	rows.Edit(list, "| Prolix Ring |  |", "| Prolix Ring | one of two identical copies |");
	var unbacked = rows.Run("gear-list", testySets);
	Equal(1, unbacked.ExitCode);
	Contains(unbacked.Output, "Eschan Stonee isn't in the export");
	Contains(unbacked.Output, "Prolix Ring is listed as one of several copies, but the export has 1");
	Contains(unbacked.Output, "Prolix Ring: the Copy column says [one of two identical copies], but the export has one copy, so the column stays empty");
});

Test("gear-list says it once when the files wear two copies of a piece and the export holds one", () =>
{
	var sandbox = NewSandbox();
	var export = Path.Combine(sandbox.Repo, "data", "export", "Testy 2026-01-02 08-00-00.lua");
	File.WriteAllText(export, File.ReadAllText(export).Replace("        left_ring=\"Stikini Ring\",\n        left_ring=\"Stikini Ring\",\n", "        left_ring=\"Stikini Ring\",\n"));
	var run = sandbox.Run("gear-list", testySets);
	Equal(1, run.ExitCode);
	Contains(run.Output, "Stikini Ring is listed as one of several copies, but the export has 1");
	True(run.Output.Contains("one of 1 identical") is false, run.Output);
	Contains(run.Output, "problems: 2");
});

Test("gear-list --print gives the table to start a list from when the character has none", () =>
{
	var sandbox = NewSandbox();
	File.Delete(Path.Combine(sandbox.Repo, "data", "Testy", "Testy_gear_list.md"));
	var run = sandbox.Run("gear-list", [.. testySets, "--print"]);
	Equal(1, run.ExitCode);
	Contains(run.Output, "## Weapons (3)\n\n| Item | Copy | BLU sets | RDM sets |\n|---|---|---|---|\n| Ammurapi Shield |  |  | `Weapons['Savage Blade']` |");
	Contains(run.Output, "No gear list at data/Testy/Testy_gear_list.md yet. The table above is the one to start it from");
	Contains(run.Output, "problems: 1");
});

Test("gear-list stops on a sets file that gives two sets one name, since it can't tell their sets apart", () =>
{
	var sandbox = NewSandbox();
	sandbox.Edit("sets/Testy_RDM.json", "{ \"name\": \"WS[each magical WS]\", \"base\": \"WS\", \"slots\": {} },", "{ \"name\": \"WS[each magical WS]\", \"base\": \"WS\", \"slots\": {} },\n    { \"name\": \"WS\", \"slots\": { \"ammo\": { \"item\": \"Coiste Bodhar\" } } },");
	Stops(sandbox.Run("gear-list", testySets), "sets/Testy_RDM.json: two sets named WS");
});

Test("gear-list reads each table by its own header, and says so when it can't", () =>
{
	var list = "data/Testy/Testy_gear_list.md";
	var ammo = "## Ammo (1)\n\n| Item | Copy | BLU sets | RDM sets |\n|---|---|---|---|\n";
	var spaced = NewSandbox();
	spaced.Edit(list, ammo, "## Ammo (1)\n\n| Item | Copy | BLU sets | RDM sets |\n| --- | :-- | --- | --- |\n");
	Equal(0, spaced.Run("gear-list", testySets).ExitCode);
	var twice = NewSandbox();
	twice.Edit(list, ammo + "| Coiste Bodhar |  |  | `WS` |", "## Ammo (1)\n\n| Item | Copy | RDM sets | RDM sets |\n|---|---|---|---|\n| Coiste Bodhar |  |  | `WS` |");
	var repeated = twice.Run("gear-list", testySets);
	Equal(1, repeated.ExitCode);
	Contains(repeated.Output, "line 21: the header names a job more than once: RDM, RDM");
	Contains(repeated.Output, "problems: 2");
	var headless = NewSandbox();
	headless.Edit(list, ammo, "## Ammo (1)\n\n| Piece | Copy | BLU sets | RDM sets |\n|---|---|---|---|\n");
	var unread = headless.Run("gear-list", testySets);
	Equal(1, unread.ExitCode);
	Contains(unread.Output, "line 21: this table's first row isn't an `| Item | Copy | ... |` header, so its rows aren't read");
	Contains(unread.Output, "Coiste Bodhar: no row.");
	Contains(unread.Output, "## Ammo (1) has 0 rows");
});

Test("gear-list says why the Copy column stays empty for a piece that names no augments", () =>
{
	var sandbox = NewSandbox();
	var list = "data/Testy/Testy_gear_list.md";
	sandbox.Edit("sets/Testy_RDM.json", "\"right_ring\": { \"item\": \"Stikini Ring\" },\n", "");
	sandbox.Edit(list, "| Stikini Ring | one of two identical copies |  | `Idle` |\n| Stikini Ring | one of two identical copies |  | `Idle` |\n", "| Stikini Ring | one of two identical copies |  | `Idle` |\n");
	sandbox.Edit(list, "## Rings (3)", "## Rings (2)");
	sandbox.Edit(list, "**17 pieces** (3 for BLU, 15 for RDM, 1 worn by both)", "**16 pieces** (3 for BLU, 14 for RDM, 1 worn by both)");
	var run = sandbox.Run("gear-list", testySets);
	Equal(1, run.ExitCode);
	Contains(run.Output, "Stikini Ring: the Copy column says [one of two identical copies], but the piece the sets wear names no augments, so the column stays empty");
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

// The sets that wear Testy's pieces, as owned-gear takes them.
string[] testyWearers = ["--sets", "sets/Testy_BLU.json", "--sets", "sets/Testy_RDM.json"];

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

Test("owned-gear lists what a job can wear in a slot, with bag, jobs and the sets that wear it", () =>
{
	var run = pristine.Run("owned-gear", ["--job", "RDM", "--slot", "waist", .. testyWearers]);
	Equal(0, run.ExitCode);
	Contains(run.Output, "waist | Eschan Stone |  | wardrobe | All jobs | RDM | DEF:9 HP+20 MP+20");
	Contains(run.Output, "waist | Obstin. Sash | Path: A | wardrobe | WHM RDM BRD SCH | RDM | MND+5 / Enfeebling magic duration +5%");
	Contains(run.Output, "waist | Rumination Sash |  | inventory | ");
	Contains(run.Output, "| BLU | MND+4 Magic Accuracy+3");
	Contains(run.Output, "3 pieces");
	var blu = pristine.Run("owned-gear", "--job", "blu", "--slot", "waist");
	True(blu.Output.Contains("Obstin. Sash") is false, "BLU can't wear Obstin. Sash, so it isn't offered");
	Contains(blu.Output, "2 pieces");
	// Without --sets no set is known to wear anything.
	Contains(blu.Output, "waist | Eschan Stone |  | wardrobe | All jobs |  | DEF:9 HP+20 MP+20");
});

Test("owned-gear marks bags GearSwap can't reach, counts copies and names the sets that wear each copy", () =>
{
	var run = pristine.Run("owned-gear", testyWearers);
	Equal(0, run.ExitCode);
	Contains(run.Output, "# slot | name | augments | bags (! = GearSwap can't equip from it) | jobs | worn by | help text");
	Contains(run.Output, "body  | Ayanmo Corazza +2 |  | !slip23 | WHM RDM BRD BLU RUN |  | ");
	Contains(run.Output, "body  | Ea Houppelande |  | !safe2 | ");
	Contains(run.Output, "ring  | Stikini Ring |  | wardrobe, wardrobe | All jobs | RDM | ");
	Contains(run.Output, "main  | Colada | \"Refresh\"+2, Mag. Acc.+11, DMG:+1 | wardrobe | RDM PLD BLU | RDM | ");
	Contains(run.Output, "main  | Colada | Weapon skill damage +2%, DMG:+14 | !locker | RDM PLD BLU |  | ");
	Contains(run.Output, "back  | Sucellos's Cape | INT+20, Mag. Acc+20 /Mag. Dmg.+20, \"Mag.Atk.Bns.\"+10 | wardrobe | RDM | RDM | ");
	Contains(run.Output, "head  | Nyame Helm | Path: B | wardrobe | All jobs | BLU RDM | ");
	Contains(run.Output, "[9 items share this name; this is the highest stage]");
	Contains(run.Output, "20 pieces");
	True(run.Output.Contains("Echo Drops") is false, "an item that can't be worn isn't gear");
	True(run.Output.Contains("gear.") is false, "no gear entries are listed");
});

Test("owned-gear names what the export holds that the resources don't know as gear", () =>
{
	var sandbox = NewSandbox();
	sandbox.Edit("data/export/Testy 2026-01-02 08-00-00.lua", "        sub=\"Ammurapi Shield\",\n", "        sub=\"Ammurapi Shield\",\n        sub=\"No Such Shield\",\n");
	var run = sandbox.Run("owned-gear");
	Equal(0, run.ExitCode);
	Contains(run.Output, "20 pieces; not weapons or armor in the resources: No Such Shield");
});

Test("owned-gear --findings writes what the resources don't know as gear as findings, and --json keeps its list of pieces", () =>
{
	var sandbox = NewSandbox();
	sandbox.Edit("data/export/Testy 2026-01-02 08-00-00.lua", "        sub=\"Ammurapi Shield\",\n", "        sub=\"Ammurapi Shield\",\n        sub=\"No Such Shield\",\n");
	var run = sandbox.Run("owned-gear", "--findings");
	Equal(0, run.ExitCode);
	using var parsed = JsonDocument.Parse(run.StandardOutput);
	Equal(1, parsed.RootElement.GetArrayLength());
	var finding = parsed.RootElement[0];
	Equal("owned-gear|warn||sub|No Such Shield|not a weapon or armor in Windower's resources",
		$"{finding.GetProperty("tool").GetString()}|{finding.GetProperty("severity").GetString()}|{finding.GetProperty("set").GetString()}|{finding.GetProperty("slot").GetString()}|{finding.GetProperty("item").GetString()}|{finding.GetProperty("message").GetString()}");
	Stops(sandbox.Run("owned-gear", "--json", "--findings"), "--json writes the pieces and --findings writes findings; give one of them.");
});

Test("owned-gear names a set once when two sets files for one job both wear the piece", () =>
{
	var json = pristine.Run("owned-gear", "--job", "RDM", "--slot", "back", "--json", "--sets", "sets/Testy_RDM.json", "--sets", "sets/Testy_RDM.json");
	using var parsed = JsonDocument.Parse(json.StandardOutput);
	Equal("Idle", string.Join(" ", parsed.RootElement[1].GetProperty("WornBy").GetProperty("RDM").EnumerateArray().Select(set => set.GetString())));
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
	var json = pristine.Run("owned-gear", ["--job", "RDM", "--slot", "back", "--json", .. testyWearers]);
	using var parsed = JsonDocument.Parse(json.StandardOutput);
	Equal(2, parsed.RootElement.GetArrayLength());
	Equal("INT+20", parsed.RootElement[0].GetProperty("Augments")[0].GetString());
	Equal("midcast_custom()", parsed.RootElement[0].GetProperty("WornBy").GetProperty("RDM")[0].GetString());
	var cape = parsed.RootElement[1];
	Equal("Sucellos's Cape", cape.GetProperty("Name").GetString());
	Equal("MND+20", cape.GetProperty("Augments")[0].GetString());
	Equal("wardrobe", cape.GetProperty("Bags")[0].GetString());
	Equal("back", cape.GetProperty("Slots")[0].GetString());
	Equal("Idle", cape.GetProperty("WornBy").GetProperty("RDM")[0].GetString());
	True(cape.TryGetProperty("Keys", out _) is false, "the JSON names no gear entries");
	True(cape.GetProperty("Description").GetString()!.Length > 0, "the help text is in the JSON");
	Equal(2, pristine.Run("owned-gear", "--slot", "nose").ExitCode);
	Equal(2, pristine.Run("owned-gear", "--job", "XYZ").ExitCode);
});

// ---------------------------------------------------------------- the other checkers

Test("check-blu-spells passes lists that hold every blue spell once", () =>
{
	var run = pristine.Run("check-blu-spells", "--in", "sets/Testy_BLU.json");
	Equal(0, run.ExitCode);
	Contains(run.Output, "9 blue spells; Physical 2, Breath 1, Magical 1, SkillBasedBuff 1, Buff 1, Healing 1, MagicAccuracy 2, Stun 0");
	Contains(run.Output, "problems: 0");
});

Test("check-blu-spells reports a spell in no list, in two lists, and a name that isn't a spell", () =>
{
	var run = pristine.Run("check-blu-spells", "--in", "sets/Testy_BLU_mistakes.json");
	Equal(1, run.ExitCode);
	Contains(run.Output, "Cocoon: in no list");
	Contains(run.Output, "Foot Kick: in Physical and Buff; keep it in one, since which list's set it wears is up to the framework");
	Contains(run.Output, "Buff names 'Cocon', which isn't a blue spell in Windower's resources");
	Contains(run.Output, "problems: 3");
});

Test("check-blu-spells takes a spell with a set of its own as placed, in no list or in one", () =>
{
	var sandbox = NewSandbox();
	sandbox.Edit("sets/Testy_BLU.json", "\"Buff\": [\"Cocoon\"],", "\"Buff\": [],");
	sandbox.Edit("sets/Testy_BLU.json", "  \"spellLists\": {", "  \"spellSets\": { \"Cocoon\": \"Midcast\", \"Occultation\": \"Midcast\" },\n  \"spellLists\": {");
	var run = sandbox.Run("check-blu-spells", "--in", "sets/Testy_BLU.json");
	Equal(0, run.ExitCode);
	Contains(run.Output, "in no list, wearing a set of its own: Cocoon (Midcast)");
	Contains(run.Output, "problems: 0");
	sandbox.Edit("sets/Testy_BLU.json", "\"Cocoon\": \"Midcast\", ", "");
	Contains(sandbox.Run("check-blu-spells", "--in", "sets/Testy_BLU.json").Output, "Cocoon: in no list");
});

Test("check-blu-spells --json writes a finding for each problem", () =>
{
	var run = pristine.Run("check-blu-spells", "--in", "sets/Testy_BLU_mistakes.json", "--json");
	Equal(1, run.ExitCode);
	using var parsed = JsonDocument.Parse(run.StandardOutput);
	var findings = parsed.RootElement.EnumerateArray()
		.Select(finding => $"{finding.GetProperty("tool").GetString()}|{finding.GetProperty("severity").GetString()}|{finding.GetProperty("set").GetString()}|{finding.GetProperty("slot").GetString()}|{finding.GetProperty("item").GetString()}|{finding.GetProperty("message").GetString()}")
		.ToList();
	Equal(3, findings.Count);
	Contains(string.Join("\n", findings), "check-blu-spells|error|||Cocoon|in no list");
	Contains(string.Join("\n", findings), "check-blu-spells|error|Physical, Buff||Foot Kick|in Physical and Buff; keep it in one, since which list's set it wears is up to the framework");
	Contains(string.Join("\n", findings), "check-blu-spells|error|Buff||Cocon|isn't a blue spell in Windower's resources");
	var clean = pristine.Run("check-blu-spells", "--in", "sets/Testy_BLU.json", "--json");
	Equal(0, clean.ExitCode);
	Equal(0, JsonDocument.Parse(clean.StandardOutput).RootElement.GetArrayLength());
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
	File.AppendAllText(Path.Combine(sandbox.Repo, "data", "Testy", "Testy_notes.md"), "\nThe sets are in [the gear file](Testy_Blu_Gear.lua#idle).\n");
	File.AppendAllText(Path.Combine(sandbox.Repo, "docs", "ffxi-mechanics.md"), "\n| a | b |\n| 1 | 2 |\n\nText right above.\n| c | d |\n|---|---|\n| 1 | 2 |\n");
	sandbox.Edit(notes, "*Naegling.*\n\n" + bullet, "*Naegling.*\n\n- Simulated sets (bg-wiki): ");
	sandbox.Edit(notes, "No notes beyond the help text: Colada.", "### Colada\n\n" + bullet + "RDM: Savage Blade (Mid buff).");
	sandbox.Edit(notes, "## Other slots\n", "## Ears\n\n### Hoxne Earring\n\n" + bullet + "RDM: Savage Blade (Mid buff, High buff); BLU: Expiacion (Mid buff).\n\n## Other slots\n");
	sandbox.Edit("data/Testy/Testy_gear_notes.md", "| Hoxne Earring | Savage Blade |", "| Hoxne Earring | Chant du Cygne |");
	var run = sandbox.Run("doc-lint");
	Equal(1, run.ExitCode);
	Contains(run.Output, "data/Testy/Testy_notes.md:22: anchor into a file this tool doesn't read, Testy_Blu_Gear.lua#idle");
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

Test("doc-lint checks the docs in folders under docs/ too", () =>
{
	var sandbox = NewSandbox();
	Directory.CreateDirectory(Path.Combine(sandbox.Repo, "docs", "frameworks"));
	File.WriteAllText(Path.Combine(sandbox.Repo, "docs", "frameworks", "sel.md"), "# Sel\n\nTesty's sets. See [the mechanics](../ffxi-mechanics.md) and [nothing](nowhere.md).\n");
	var run = sandbox.Run("doc-lint");
	Equal(1, run.ExitCode);
	Contains(run.Output, "docs/frameworks/sel.md:3: names Testy.");
	Contains(run.Output, "docs/frameworks/sel.md:3: link to a missing file, nowhere.md");
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

Test("search-fast-recast reads owned-gear's JSON, with the hidden Fast Cast values it is given", () =>
{
	var pieces = Path.Combine(workDir, "pieces.json");
	File.WriteAllText(pieces, pristine.Run("owned-gear", ["--job", "BLU", "--json", .. testyWearers]).StandardOutput);
	var hidden = Path.Combine(workDir, "hidden-fast-cast.json");
	File.WriteAllText(hidden, """{ "Loquac. Earring": 2, "Prolix Ring": 2 }""");
	var table = pristine.Run("search-fast-recast", pieces, "--job", "BLU", "--hidden", hidden, "--table");
	Equal(0, table.ExitCode);
	Contains(table.Output, "left_ear   H 0 FC 2 B 0 J0 DT 0 wardrobe   RDM  Loquac. Earring");
	Contains(table.Output, "hands      H 3 FC 0 B16 J0 DT10 wardrobe   BLU  Hashi. Bazu. +3");
	var search = pristine.Run("search-fast-recast", pieces, "--job", "BLU", "--hidden", hidden, "--traits", "5,15");
	Equal(0, search.ExitCode);
	Contains(search.Output, "===== pool=owned blue");
	Contains(search.Output, "  trait 15: ");
	Contains(search.Output, "Hashi. Bazu. +3(3/0/B16 DT10 wardrobe BLU)");
	// The help text doesn't give Loquac. Earring's number, so without the hidden values it counts for nothing.
	True(pristine.Run("search-fast-recast", pieces, "--job", "BLU", "--table").Output.Contains("Loquac. Earring") is false, "a hidden value came from nowhere");
	var excluded = pristine.Run("search-fast-recast", pieces, "--job", "BLU", "--hidden", hidden, "--exclude", "^Hashi");
	True(excluded.Output.Contains("Hashi. Bazu. +3(") is false, "--exclude keeps a piece out of the search");
	Equal(2, pristine.Run("search-fast-recast").ExitCode);
	Equal(2, pristine.Run("search-fast-recast", pieces).ExitCode);
	Stops(pristine.Run("search-fast-recast", pieces, "--job", "BLU", "--traits", "5,x"), "Give the file owned-gear.cs --json wrote");
	Stops(pristine.Run("search-fast-recast", pieces, "--job", "BLU", "--exclude", "("), "Give the file owned-gear.cs --json wrote");
});

Test("search-fast-recast searches blue magic only for BLU", () =>
{
	var pieces = Path.Combine(workDir, "pieces-rdm.json");
	File.WriteAllText(pieces, pristine.Run("owned-gear", ["--job", "RDM", "--json", .. testyWearers]).StandardOutput);
	var search = pristine.Run("search-fast-recast", pieces, "--job", "RDM");
	Equal(0, search.ExitCode);
	Contains(search.Output, "===== pool=RDM non-blue (Utsusemi)");
	Contains(search.Output, "  trait 0: ");
	True(search.Output.Contains(" blue  combos") is false, "a job other than BLU has no blue magic to search");
});

Test("search-fast-recast stops with its usage line on a --hidden file that isn't JSON", () =>
{
	var pieces = Path.Combine(workDir, "pieces-for-hidden.json");
	File.WriteAllText(pieces, pristine.Run("owned-gear", ["--job", "BLU", "--json", .. testyWearers]).StandardOutput);
	var broken = Path.Combine(workDir, "hidden-broken.json");
	File.WriteAllText(broken, "{ not json");
	Stops(pristine.Run("search-fast-recast", pieces, "--job", "BLU", "--hidden", broken), "Give the file owned-gear.cs --json wrote");
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
	Equal(0, sandbox.RunFile(tool, true, "--in", "sets/Testy_BLU.json").ExitCode);
	Equal(0, sandbox.RunFile(tool, false, "--in", "sets/Testy_BLU.json").ExitCode);
	File.SetLastWriteTimeUtc(Path.Combine(copy, "lib", "Wiki.cs"), DateTime.UtcNow.AddSeconds(5));
	var stale = sandbox.RunFile(tool, false, "--in", "sets/Testy_BLU.json");
	Equal(2, stale.ExitCode);
	Contains(stale.Output, "This build is older than .claude/tools/lib. Run the tool again with: dotnet run --no-cache");
	File.SetLastWriteTimeUtc(Path.Combine(copy, "lib", "Wiki.cs"), DateTime.UtcNow.AddSeconds(-1));
	Equal(0, sandbox.RunFile(tool, true, "--in", "sets/Testy_BLU.json").ExitCode);
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
		if (Path.GetExtension(file) is ".lua" or ".md" or ".py" or ".json")
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

	public ToolRun RunFile(string toolFile, bool rebuild, params string[] arguments) => Start(toolFile, rebuild, arguments);

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
