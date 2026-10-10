# Gear tools

.NET file-based apps for building and checking gear sets. They don't read a GearSwap framework's Lua: they read **sets files**, JSON that any framework's sets can be written as (`lib/Dto.cs`), and check them against the repo's own files (the latest `//gs export`, the docs under `docs/`, the character's own notes in `data/<Character>/`) and a few outside sources kept in `.claude/cache/`. One tool, `sel-sets.cs`, reads Selindrile's gear files into a sets file; it is the only one that knows a framework. The `gear-optimizer` agent (`.claude/agents/gear-optimizer.md`) runs the tools; they also run by hand.

## Running one

From the repo root, with the .NET 10 SDK:

```bash
dotnet run --no-cache .claude/tools/check-export.cs -- --in blu.json
```

- Options go after `--`. Each tool's opening comment lists its own.
- Always pass `--no-cache`. Every tool also compiles the shared code in `lib/` (through `Directory.Build.props`), and `dotnet run` only rebuilds when the tool's own file changes. Without `--no-cache`, a tool built before an edit under `lib/` stops and says so, rather than run the old code.
- A tool that takes a sets file reads the newest export of that file's character, by the date in the export's file name, unless `--export <path>` names another. The tools that take no sets file take `--char <name>` and `--export <path>`, and without them use the newest export and the character it is named for.
- Exit code 0 means nothing wrong was found, 1 means the tool found a problem, 2 means it couldn't run (a bad option, a missing or unreadable file, an empty cache, a site it cannot reach).
- Nothing is built into the repo: `dotnet run` keeps its output under the user's temp folder. Write sets files to a scratch folder, not into the repo.

## Sets files

All carry `"schemaVersion": 1`. The classes are in `lib/Dto.cs`; property names are camel case.

**SetsDto**, what the checkers read:

```json
{ "schemaVersion": 1, "character": "Vanar", "job": "BLU",
  "sets": [
    { "name": "precast.FC", "slots": { "head": { "item": "Carmine Mask +1" } } },
    { "name": "precast.FC['Blue Magic']", "base": "precast.FC",
      "slots": { "body": { "item": "Hashishin Mintan +1" } } },
    { "name": "idle", "slots": { "back": { "item": "Rosmerta's Cape", "augments": ["DEX+20", "..."], "bag": "wardrobe2" } } }
  ],
  "spellLists": { "Physical": ["Bilgestorm"] } }
```

- A set's `name` is the caller's own; the tools only compare names, and two sets can't share one.
- `base` names the set it is built on, and `slots` holds only the slots it puts over it. The tools resolve the chain themselves; a base no set has, or a chain that comes back to itself, stops the tool.
- `aliasOf` names the set this one is the same table as (Lua's `sets.B = sets.A`). An alias has no base or slots of its own, and its target can't be an alias. A name inside an alias, `B.X`, resolves to `A.X`. Write one back as `sets.B = sets.A`, never as a copy.
- Slots go by their canonical names: `main sub range ammo head neck left_ear right_ear body hands left_ring right_ring back waist legs feet`.
- A piece's `item` is the name the export prints or the item's log name. `augments`, when given, must be the copy's exactly as the export prints them; without them any copy will do. `bag` pins the piece to one bag. The item `empty` clears the slot.
- `spellLists` is for BLU: each blue magic list by name, with its spells.
- `spellSets` is for BLU: `{ "<spell>": "<set name>" }` for each blue spell that has a set of its own, which it wears whatever list it is in. The reader fills it from where the framework looks for such a set. Each value must name a set in the file. `check-blu-spells` counts these spells as placed.

**OptimizeRequest**, what the caller gives the agent: `character`, `job`, `export` (the export's path), `sets` (a SetsDto), and optionally `bags` (the only bags the sets may take pieces from) and `targets` (by set name, what the caller wants of that set).

**OptimizeResult**, what the agent answers with: `sets` (a full replacement for each set it touched, in the SetsDto shape), `spellLists` (BLU only: a full replacement for each blue magic list it changed, left out when it changed none), `changes` (`set`, `slot`, `from`, `to`, `reason`), `shortfalls` (`set`, `stat`, `target`, `achieved`, `note`), `questions` and `docsEdited`.

**Findings**, what `check-export`, `check-blu-spells` and `gear-list` write with `--json`, and `owned-gear` with `--findings` (its `--json` is the list of pieces another tool reads): `[ { "tool", "severity": "error" or "warn", "set", "slot", "item", "message" } ]`. A field a tool has nothing for is empty: `gear-list`'s findings give only the message, and `check-blu-spells` gives the spell as the item and the lists that name it as the set. Exit codes are the same as without the flag.

## The cache

`.claude/cache/` is git-ignored. `fetch-sources.cs` fills it, and the tools that need it say so when it is empty.

| Folder | What | From |
|---|---|---|
| `res/` | Windower's `items.lua`, `item_descriptions.lua` and `spells.lua`: every item's id, jobs, slots and help text | Windower/Resources, branch head |
| `wsdist_beta/` | Kastra's damage simulator, read as source | IzaKastra/wsdist_beta at `d12ac59` |
| `bg_job_guides/` | The wikitext of bg-wiki's simulated gear sets, one file a job | IzaKastra/bg_job_guides at `f264ae4` |
| `ranks/ranks.json` | bg-wiki's rank-by-rank augment tables for the items in every character's newest export | `rank-tables.cs` |
| `wiki/` | bg-wiki pages saved as wikitext | `wiki.cs` |

The two repos are pinned to the commits `docs/ffxi-mechanics.md` cites file and line numbers from. Move a pin only together with those references.

## The tools

| Tool | What it does | Run it |
|---|---|---|
| `fetch-sources.cs` | Fills the cache: resources and the two pinned repos. `--refresh` fetches again. | Once on a new checkout, and after a game update for fresh resources. |
| `sel-sets.cs` | Reads a Selindrile gear file, `data/<Character>/<Character>_<Job>_Gear.lua`, into a sets file (`--out`, or standard output). Gear entries, blue magic lists and top-level sets also come from the files Sel loads first. What it can't follow it leaves out and notes, with exit code 1; so it does for a dropped set and a set defined twice in one file. A set defined again on itself (`sets.x = set_combine(sets.x, {...})`) is printed as information and leaves the exit code 0. `docs/frameworks/sel.md` says how it reads the file. | Before any check of a Sel character's sets, and again after the gear file changes. |
| `owned-gear.cs` | Lists the weapons and armor in the export with slot, jobs, bag and help text, and with `--sets <sets.json>` (repeatable) the sets that already wear each piece. Filters: `--job`, `--slot`, `--grep`; `--json` for another tool; `--findings` for the export's pieces the resources don't know as gear. | To see what a slot can choose from, before picking a piece. |
| `check-export.cs` | Checks every piece a sets file names: a real item, owned with those augments, wearable by the job, right for the slot, and in a bag GearSwap can equip from. `--bags wardrobe,wardrobe2` holds every piece to those bags. `--json` writes findings. | After every change to a set, and when a new export arrives. |
| `check-blu-spells.cs` | Checks that each blue spell is in exactly one of a BLU sets file's spell lists, and that every name in them is a real spell. A spell `spellSets` gives a set of its own needs no list. `--json` writes findings. | After moving a spell between lists. |
| `gear-list.cs` | Checks `<Character>_gear_list.md` against the character's sets files, one `--in` for each job, and reports a job the list has no column for. It reads only the tables under the `## <Slot> (<count>)` headings of the list. `--print` writes the table the sets call for, with a column for every job; `--json` writes findings. | After every change to a set. |
| `set-stats.cs` | Totals each set's stats, laid over its base: help text, the copy's augments, a path piece's augments at the character's rank from `<Character>_rank_augments.md` (an item Oboro ranks up at its maximum rank only, from `docs/rank-augments.md`), and the extra values `--extra <stats.json>` gives for what none of those show. It warns of a piece the resources don't know, whose augments no exported copy has, or whose path's rank the player hasn't given, since those stats are missing. `--set` picks sets by regex; `--json` for another tool. | To compare two versions of a set, and to report how far a set is from a target. |
| `sims.cs` | Shows bg-wiki's simulated sets for a job, marks what the character owns, and counts how often each piece fills a slot. | For a reference set to start from. |
| `wsdist-gear.cs` | Looks an item up in wsdist's gear data. `--check-nyame` compares its Nyame entries with `docs/rank-augments.md`; at the pinned commit it finds one difference, the Nyame Flanchard error `docs/ffxi-mechanics.md` lists, and so exits with 1. | For a second opinion on an item's stats, and to see which rank entries the simulator has. |
| `wiki.cs` | Saves bg-wiki pages as wikitext, many to a request. | Before relying on a mechanic or an item detail the docs don't cover. |
| `rank-tables.cs` | Reads bg-wiki's rank tables into the cache, for the items in every character's newest export. | After an export that adds a rank-augmented item. |
| `rank-doc.cs` | Writes the two rank documents from those tables: `docs/rank-augments.md`, the tables themselves, and each character's `<Character>_rank_augments.md`, that character's path and rank for each item, from the newest export and the Ranks table in `<Character>_notes.md`. It stops, writing nothing, on a Ranks row it can't hold to the tables and the export: an unknown item, a path the item lacks, a rank its table lacks, or a path other than the one the export prints. It stops the same way on an exported item that prints a path and has neither a rank table nor a row among the items Oboro ranks up. `--check` writes nothing and exits with 1 when a document isn't what it would write. | After the player reports a new rank (change its row in the Ranks table first), and after a new export. |
| `doc-lint.cs` | Checks the docs under `docs/` (its folders too) and the character's own files: links, anchors, tables and code fences; that no doc under `docs/` names a character; `docs/gear-notes.md` against the simulated sets; and the character's gear notes against the export and the sets. Also lists owned pieces the notes don't cover. | After any edit under `docs/` or to a character's notes. |
| `search-fast-recast.cs` | A worked example of choosing a set by exhaustive search: the fastest recast a job reaches from owned gear, read from `owned-gear.cs --json`. The hidden Fast Cast values, the trait levels and any pieces to leave out are arguments. It uses nothing from `lib/`, so a copy runs from any folder. | Copy it when a set's worth is a formula over a few stats. |

## Typical runs

A Sel character's BLU sets changed:

```bash
dotnet run --no-cache .claude/tools/sel-sets.cs -- data/Vanar/Vanar_Blu_Gear.lua BLU --out <scratch>/blu.json
```

```bash
dotnet run --no-cache .claude/tools/check-export.cs -- --in <scratch>/blu.json
```

```bash
dotnet run --no-cache .claude/tools/check-blu-spells.cs -- --in <scratch>/blu.json
```

```bash
dotnet run --no-cache .claude/tools/gear-list.cs -- --in <scratch>/blu.json --in <scratch>/rdm.json
```

What can RDM wear on its legs, and which pieces have Fast Cast:

```bash
dotnet run --no-cache .claude/tools/owned-gear.cs -- --job RDM --slot legs --sets <scratch>/rdm.json
```

```bash
dotnet run --no-cache .claude/tools/owned-gear.cs -- --job RDM --grep "fast cast"
```

How a set's totals stand:

```bash
dotnet run --no-cache .claude/tools/set-stats.cs -- --in <scratch>/blu.json --set "^precast\.FC" --extra <scratch>/extra.json
```

A new export arrived: read each job's sets file again, run `check-export.cs` and `gear-list.cs`, fix what they report, then update the export named in the gear list's first sentence and in the root `README.md`. `gear-list.cs` says when the list's sentence still names an older export; nothing checks the root `README.md`. Then run `rank-tables.cs` and `rank-doc.cs` so the two rank documents follow the new export.

The player reported a rank: change its row in the Ranks table of `data/<Character>/<Character>_notes.md`, then

```bash
dotnet run --no-cache .claude/tools/rank-doc.cs
```

## What the checks rest on

- **The export** is the only record of what the character owns. `//gs export all` writes one table for each bag and one for each storage slip (`slip1` to `slip33`). GearSwap equips from the inventory and the wardrobes only, so `check-export.cs` warns about a piece that is only in another bag or on a slip. The export never shows a path item's rank; those come from the player and live in the Ranks table of the character's notes, `data/<Character>/<Character>_notes.md`.
- **What holds for any character is under `docs/`, and what holds for one is in its folder under `data/`**: `<Character>_notes.md` (the player's rules, ranks, merits and the like), `<Character>_gear_notes.md` (notes on the character's own copies) and `<Character>_rank_augments.md` (generated), all linked from `<Character>_gear_list.md`. A character is a folder under `data/` that holds its notes or its gear list. `doc-lint.cs` reports a doc under `docs/` that names one. How a framework picks its sets is under `docs/frameworks/`.
- **Windower's resources** give each item's jobs and slots, and both of its names. A piece may use the short name the export prints or the long log name; the tools accept either, as GearSwap does.
- **A sets file is only as good as its reader.** `sel-sets.cs` reads the gear file's text, not a running GearSwap: what a hook equips, a set named at run time, and a gear entry the framework fills at run time aren't in the sets file. It notes what it left out. Gear a set inherits from its base is checked once, in the set that names it.
- **None of this runs GearSwap or the game.** A clean run means the sets name real, owned, wearable gear in the right slots. It doesn't mean the sets behave in game.

## Tests

`tests/run-tests.cs` checks the shared code and runs each tool against a small made-up character, Testy, whose repository and cache are under `tests/fixture/`: its export, notes and gear list, a small Sel gear file (`data/Testy/Testy_Blu_Gear.lua`), and sets files under `sets/`, clean and with mistakes put in. It never reads the real data and never uses the network.

```bash
dotnet run --no-cache .claude/tools/tests/run-tests.cs
```

```bash
dotnet run --no-cache .claude/tools/tests/run-tests.cs -- gear-list
```

- A word after `--` runs only the tests whose name contains it.
- A test that needs a mistake copies the fixture to the temp folder, breaks the copy and runs the tool on it. Three environment variables point the tools at what a test made: `GEAR_TOOLS_ROOT` at its repository, `GEAR_TOOLS_CACHE` at its cache, and `GEAR_TOOLS_WIKI` at a stand-in for bg-wiki's API that the test runs on its own machine. Nothing else should set them.
- The whole run takes about three minutes, because each tool run is a build.

## Adding or changing a tool

- Start with a test in `tests/run-tests.cs` that fails for the reason the change is needed, with the fixture extended to show it.
- A tool is one `.cs` file here, with top-level statements, starting with `Tool.Init()`. Code two tools need goes in `lib/`.
- A checker takes sets files, not a framework's Lua. Support for another framework is a reader like `sel-sets.cs` that writes a SetsDto, and a page under `docs/frameworks/`.
- Keep a tool's usage in its opening comment and its row in the table above.
- `search-fast-recast.cs` is the exception to both: it must keep running as a lone copy, so it uses nothing from `lib/`.
