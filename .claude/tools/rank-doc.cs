// Writes the two rank documents from the bg-wiki rank tables rank-tables.cs saved. docs/rank-augments.md holds the
// tables and names no character. data/<Character>/<Character>_rank_augments.md gives one character's path and rank
// for each item, from that character's newest export and from the Ranks table in <Character>_notes.md, since
// //gs export never shows a rank.
//
//   dotnet run --no-cache .claude/tools/rank-doc.cs [-- --check]
//
// When the player reports a new rank: change its row in the Ranks table, run this, then correct what the character's
// notes and gear notes say about that piece, and look again at the sets that wear it. Both documents are generated; don't edit them. A Ranks
// row that names an unknown item, a path the item lacks, a rank its table lacks or a path other than the one the
// export prints stops the run with nothing written. So does an exported item that prints a path and has neither a
// rank table nor a row among the items Oboro ranks up. --check writes nothing, and exits with 1 when a document
// isn't what this would write.
using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.IO;
using GearTools;

Tool.Init();
var cli = new Arguments(args, [], ["--check"]);

// Oboro's augments (JSE necks, Ultimate Weapons, Unity weapons) rank up too, but bg-wiki gives only the maximum, not
// a table for each rank, so this section is typed in from the pages read on 2026-10-02. An item of this kind that
// turns up in an export needs a row here, and the run stops until it has one.
var oboro = new OboroAugments(
[
	"## Oboro rank augments (maximum only)",
	"",
	"Oboro in Port Jeuno ranks up JSE necks, Ultimate Weapons (Relic, Mythic, Empyrean and Aeonic at Level 119 III) and Unity weapons. bg-wiki lists only each item's augments at its maximum rank, not rank by rank, so an item below its cap has less than these values by an amount the wiki doesn't give. A copy that exports with no augments is rank 0. A copy that exports with `'Path: A'` has been ranked, and its rank has to come from the player.",
	"",
	"- JSE necks: NQ necks cap at rank 15, +1 necks at rank 20 and +2 necks at rank 25 ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:JSE_Necks)).",
	"- Ultimate Weapons cap at rank 15, and only a Level 119 III weapon can start. The export prints `'Path: A'` on them, but Path A is the only path. The augments work in the main hand only. The weapon skill damage augment applies to every hit of that weapon skill, and it multiplies with the weapon's hidden weapon skill bonus ([bg-wiki](https://www.bg-wiki.com/ffxi/BGWiki:Ultimate_Weapon_Augments)).",
	"- `//gs export` prints the same name for every stage of a Relic, Mythic, Empyrean or Ergon weapon. Almace, Tizona and Mpu Gandring each share their export name with 4 to 11 item IDs, so the export doesn't show the stage. An Ultimate Weapon with `'Path: A'` must be Level 119 III, because only that stage takes the augment.",
	"",
],
[
	new OboroItem("Dls. Torque +1", "neck", 20, false, "INT and MND +12, Enhancing magic effect duration +20%, Enfeebling magic effect duration +20% ([bg-wiki](https://www.bg-wiki.com/ffxi/Dls._Torque_%2B1))"),
	new OboroItem("Mirage Stole +2", "neck", 25, false, "STR and DEX +25, Store TP +7, Critical hit rate +5% ([bg-wiki](https://www.bg-wiki.com/ffxi/Mirage_Stole_%2B2))"),
	new OboroItem("Tizona", "main", 15, true, "Main hand: DMG +18, Expiacion damage +15%, Accuracy +30, Magic Accuracy +30. With the weapon's hidden Expiacion +30%, the total at rank 15 is +49.5%, because the two multiply ([bg-wiki](https://www.bg-wiki.com/ffxi/Tizona_(Level_119_III)))"),
	new OboroItem("Almace", "main", 15, true, "Main hand: DMG +5, Chant du Cygne damage +10%, DEX and MND +20 ([bg-wiki](https://www.bg-wiki.com/ffxi/BGWiki:Ultimate_Weapon_Augments))"),
	new OboroItem("Pukulatmuj +1", "main", 15, false, "DMG +38, Accuracy and Magic Accuracy +30, Sword enhancement spell damage +150% (its own enspell damage only) ([bg-wiki](https://www.bg-wiki.com/ffxi/Pukulatmuj_%2B1))"),
]);

var tables = RankTables.Load();
var resources = Resources.Load();
// Every document is rendered before any is written, so a Ranks row that can't be used leaves the files alone.
var documents = new List<KeyValuePair<string, List<string>>>();
try
{
	documents.Add(KeyValuePair.Create(Tool.InRepo("docs", "rank-augments.md"), RankDoc.RenderTables(tables, resources, oboro)));
	var owners = Export.Owners();
	foreach (var character in Characters.All().Where(name => owners.Contains(name, StringComparer.OrdinalIgnoreCase)))
	{
		var export = Export.Latest(character);
		var owned = Export.Read(export).Where(line => line.SlotKey != "item").ToList();
		var ranks = new CharacterRanks(character, Tool.RepoRelative(export), owned, PlayerRanks.Read(Characters.Notes(character)));
		documents.Add(KeyValuePair.Create(Characters.RankAugments(character), RankDoc.RenderCharacter(tables, resources, oboro, ranks)));
	}
}
catch (InvalidOperationException problem)
{
	Tool.Fail(problem.Message);
}

var stale = 0;
foreach (var document in documents)
{
	var path = document.Key;
	var written = File.Exists(path) ? File.ReadAllText(path) : null;
	// Keep the line endings the file already has, so a regenerated document differs only where its content does.
	var newline = written is not null && written.Contains("\r\n") ? "\r\n" : "\n";
	var text = string.Join(newline, document.Value) + newline;
	if (cli.Flag("--check") is false)
	{
		Directory.CreateDirectory(Path.GetDirectoryName(path)!);
		File.WriteAllText(path, text);
		Console.WriteLine($"{document.Value.Count} lines -> {Tool.RepoRelative(path)}");
	}
	else if (written == text)
	{
		Console.WriteLine($"{Tool.RepoRelative(path)} is what this would write");
	}
	else
	{
		stale++;
		Console.WriteLine($"{Tool.RepoRelative(path)} isn't what this would write. Run rank-doc.cs to bring it up to date.");
	}
}
return stale > 0 ? 1 : 0;
