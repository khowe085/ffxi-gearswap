# Gear tools

.NET file-based apps for building and checking gear sets. They don't read a GearSwap framework's Lua: they read **sets files**, JSON that any framework's sets can be written as (`lib/Dto.cs`), and check them against the repo's own files (the latest `//gs export`, the docs under `docs/`, the character's own notes in `data/<Character>/`) and the outside data checked in under `docs/`: bg-wiki's, Windower's and wsdist's. One tool, `sel-sets.cs`, reads Selindrile's gear files into a sets file; it is the only one that knows a framework. The `gear-optimizer` agent (`.claude/agents/gear-optimizer.md`) runs the tools; they also run by hand.

## Running one

From the repo root, with the .NET 10 SDK, through the launcher, `.claude/gear.cs`:

```bash
dotnet run .claude/gear.cs -- check-export --in blu.json
```

- After `--` comes the tool's name, without `.cs`, then its own options. Each tool's opening comment lists them.
- A tool runs from its build in the checkout's `.claude/cache/builds`, which git ignores. A run makes the build again first when the tool's source changed since: its file, `lib/` (the shared code every tool compiles, through `Directory.Build.props`) or `Directory.Build.props`, whether by an edit, a pull or a branch switch. `build` brings every tool's build up to date at once:

  ```bash
  dotnet run .claude/gear.cs -- build
  ```

- A tool that takes a sets file reads the newest export of that file's character, by the date in the export's file name, unless `--export <path>` names another. The tools that take no sets file take `--char <name>` and `--export <path>`, and without them use the newest export and the character it is named for.
- Exit code 0 means nothing wrong was found, 1 means the tool found a problem, 2 means it couldn't run (a bad option, a missing or unreadable file, a site it cannot reach, or a tool the launcher doesn't know or can't build).
- Write sets files to a scratch folder, not into the repo.

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

## Outside data

What the tools take from outside the repo seldom changes, so it is checked in under `docs/`, and the tools read it from there. Only the tools that write it fetch anything. The `update-ext-data` skill (`.claude/skills/update-ext-data/SKILL.md`) runs them all, then `rank-doc.cs` and the data checks, and reports what changed. It commits nothing.

| Path under `docs/` | What | Written by |
|---|---|---|
| `windower/` | Windower's `items.lua`, `item_descriptions.lua` and `spells.lua`: every item's id, jobs, slots and help text | `fetch-sources.cs`, from Windower/Resources at its branch head |
| `wsdist/gear.py` | The item data of Kastra's damage simulator | `fetch-sources.cs`, from IzaKastra/wsdist_beta at `d12ac59` |
| `wiki/rank-tables.json` | bg-wiki's rank-by-rank augment tables for the items in every character's newest export, with the day they were read, which `docs/rank-augments.md` prints | `rank-tables.cs` |
| `wiki/simulated-sets/` | The wikitext of bg-wiki's simulated gear sets, one file a job | `simulated-sets.cs`, from IzaKastra/bg_job_guides at `f264ae4` |
| `wiki/pages/`, `wiki/page-titles.txt` | bg-wiki pages saved as wikitext, and the title each was saved under | `wiki.cs` |

wsdist_beta and bg_job_guides are pinned to the commits `docs/ffxi-mechanics.md` cites file and line numbers from. Move a pin only together with those references.

`.claude/cache/`, which git ignores, holds what the launcher makes for each checkout: the tools' builds and the tests' passes.

## The tools

| Tool | What it does | Run it |
|---|---|---|
| `fetch-sources.cs` | Writes Windower's resources into `docs/windower/` and wsdist's `gear.py` into `docs/wsdist/`. It writes nothing unless it got every file. | After a game update. |
| `sel-sets.cs` | Reads a Selindrile gear file, `data/<Character>/<Character>_<Job>_Gear.lua`, into a sets file (`--out`, or standard output). Gear entries, blue magic lists and top-level sets also come from the files Sel loads first. What it can't follow it leaves out and notes, with exit code 1; so it does for a dropped set and a set defined twice in one file. A set defined again on itself (`sets.x = set_combine(sets.x, {...})`) is printed as information and leaves the exit code 0. `docs/frameworks/sel.md` says how it reads the file. | Before any check of a Sel character's sets, and again after the gear file changes. |
| `owned-gear.cs` | Lists the weapons and armor in the export with slot, jobs, bag and help text, and with `--sets <sets.json>` (repeatable) the sets that already wear each piece. Filters: `--job`, `--slot`, `--grep`; `--json` for another tool; `--findings` for the export's pieces the resources don't know as gear. | To see what a slot can choose from, before picking a piece. |
| `check-export.cs` | Checks every piece a sets file names: a real item, owned with those augments, wearable by the job, right for the slot, and in a bag GearSwap can equip from. `--bags wardrobe,wardrobe2` holds every piece to those bags. `--json` writes findings. | After every change to a set, and when a new export arrives. |
| `check-blu-spells.cs` | Checks that each blue spell is in exactly one of a BLU sets file's spell lists, and that every name in them is a real spell. A spell `spellSets` gives a set of its own needs no list. `--json` writes findings. | After moving a spell between lists. |
| `gear-list.cs` | Checks `<Character>_gear_list.md` against the character's sets files, one `--in` for each job, and reports a job the list has no column for. It reads only the tables under the `## <Slot> (<count>)` headings of the list. `--print` writes the table the sets call for, with a column for every job; `--json` writes findings. | After every change to a set. |
| `set-stats.cs` | Totals each set's stats, laid over its base: help text, the copy's augments, a path piece's augments at the character's rank from `<Character>_rank_augments.md` (an item Oboro ranks up at its maximum rank only, from `docs/rank-augments.md`), and the extra values `--extra <stats.json>` gives for what none of those show. It warns of a piece the resources don't know, whose augments no exported copy has, or whose path's rank the player hasn't given, since those stats are missing. `--set` picks sets by regex; `--json` for another tool. | To compare two versions of a set, and to report how far a set is from a target. |
| `simulated-sets.cs` | Writes bg-wiki's simulated sets into `docs/wiki/simulated-sets/`, one file a job, from IzaKastra/bg_job_guides at its pinned commit, over what is there. | When the bg_job_guides pin moves. |
| `sims.cs` | Shows bg-wiki's simulated sets for a job, from `docs/wiki/simulated-sets/`, marks what the character owns, and counts how often each piece fills a slot. | For a reference set to start from. |
| `wsdist-gear.cs` | Looks an item up in wsdist's gear data, `docs/wsdist/gear.py`. `--check-nyame` compares its Nyame entries with `docs/rank-augments.md`; at the pinned commit it finds one difference, the Nyame Flanchard error `docs/ffxi-mechanics.md` lists, and so exits with 1. | For a second opinion on an item's stats, and to see which rank entries the simulator has. |
| `wiki.cs` | Saves bg-wiki pages as wikitext into `docs/wiki/pages/`, many to a request, and adds their titles to `docs/wiki/page-titles.txt`. A page already saved is left alone unless `--refresh` is given. | Before relying on a mechanic or an item detail the docs don't cover. |
| `rank-tables.cs` | Reads bg-wiki's rank tables into `docs/wiki/rank-tables.json`, for the items in every character's newest export. | After an export that adds a rank-augmented item. |
| `rank-doc.cs` | Writes the two rank documents from those tables: `docs/rank-augments.md`, the tables themselves, and each character's `<Character>_rank_augments.md`, that character's path and rank for each item, from the newest export and the Ranks table in `<Character>_notes.md`. It stops, writing nothing, on a Ranks row it can't hold to the tables and the export: an unknown item, a path the item lacks, a rank its table lacks, or a path other than the one the export prints. It stops the same way on an exported item that prints a path and has neither a rank table nor a row among the items Oboro ranks up. `--check` writes nothing and exits with 1 when a document isn't what it would write. | After the player reports a new rank (change its row in the Ranks table first), and after a new export. |
| `doc-lint.cs` | Checks the docs under `docs/` (its folders too) and the character's own files: links, anchors, tables and code fences; that no doc under `docs/` names a character; `docs/gear-notes.md` against the simulated sets; and the character's gear notes against the export and the sets. Also lists owned pieces the notes don't cover. | After any edit under `docs/` or to a character's notes. |
| `search-fast-recast.cs` | A worked example of choosing a set by exhaustive search: the fastest recast a job reaches from owned gear, read from `owned-gear.cs --json`. The hidden Fast Cast values, the trait levels and any pieces to leave out are arguments. It uses nothing from `lib/`, so a copy runs from any folder. | Copy it when a set's worth is a formula over a few stats. |

## Typical runs

A Sel character's BLU sets changed:

```bash
dotnet run .claude/gear.cs -- sel-sets data/Vanar/Vanar_Blu_Gear.lua BLU --out <scratch>/blu.json
```

```bash
dotnet run .claude/gear.cs -- check-export --in <scratch>/blu.json
```

```bash
dotnet run .claude/gear.cs -- check-blu-spells --in <scratch>/blu.json
```

```bash
dotnet run .claude/gear.cs -- gear-list --in <scratch>/blu.json --in <scratch>/rdm.json
```

What can RDM wear on its legs, and which pieces have Fast Cast:

```bash
dotnet run .claude/gear.cs -- owned-gear --job RDM --slot legs --sets <scratch>/rdm.json
```

```bash
dotnet run .claude/gear.cs -- owned-gear --job RDM --grep "fast cast"
```

How a set's totals stand:

```bash
dotnet run .claude/gear.cs -- set-stats --in <scratch>/blu.json --set "^precast\.FC" --extra <scratch>/extra.json
```

A new export arrived: read each job's sets file again, run `check-export.cs` and `gear-list.cs`, fix what they report, then update the export named in the gear list's first sentence and in the root `README.md`. `gear-list.cs` says when the list's sentence still names an older export; nothing checks the root `README.md`. Then run the `update-ext-data` skill, or `rank-tables.cs` and `rank-doc.cs`, so the two rank documents follow the new export.

The player reported a rank: change its row in the Ranks table of `data/<Character>/<Character>_notes.md`, then

```bash
dotnet run .claude/gear.cs -- rank-doc
```

## What the checks rest on

- **The export** is the only record of what the character owns. `//gs export all` writes one table for each bag and one for each storage slip (`slip1` to `slip33`). GearSwap equips from the inventory and the wardrobes only, so `check-export.cs` warns about a piece that is only in another bag or on a slip. The export never shows a path item's rank; those come from the player and live in the Ranks table of the character's notes, `data/<Character>/<Character>_notes.md`.
- **What holds for any character is under `docs/`, and what holds for one is in its folder under `data/`**: `<Character>_notes.md` (the player's rules, ranks, merits and the like), `<Character>_gear_notes.md` (notes on the character's own copies) and `<Character>_rank_augments.md` (generated), all linked from `<Character>_gear_list.md`. A character is a folder under `data/` that holds its notes or its gear list. `doc-lint.cs` reports a doc under `docs/` that names one. How a framework picks its sets is under `docs/frameworks/`.
- **Windower's resources** (`docs/windower/`) give each item's jobs and slots, and both of its names. A piece may use the short name the export prints or the long log name; the tools accept either, as GearSwap does.
- **A sets file is only as good as its reader.** `sel-sets.cs` reads the gear file's text, not a running GearSwap: what a hook equips, a set named at run time, and a gear entry the framework fills at run time aren't in the sets file. It notes what it left out. Gear a set inherits from its base is checked once, in the set that names it.
- **None of this runs GearSwap or the game.** A clean run means the sets name real, owned, wearable gear in the right slots. It doesn't mean the sets behave in game.

## Tests

The repo's tests fall in three categories, and the launcher's `test` runs each one whose files changed since it last passed:

```bash
dotnet run .claude/gear.cs -- test
```

| Category | What runs | The files it rests on |
|---|---|---|
| `tools` | Every tool's build brought up to date, then `tests/run-tests.cs`: the shared code and each tool, on a small made-up character | The tools' source (each tool's file, `lib/` and `Directory.Build.props`), `tests/` and the launcher |
| `data` | The tools' checks of each character, a folder under `data/` with its notes or gear list: `sel-sets.cs` on each of its gear files, then `check-export.cs` on each sets file, `check-blu-spells.cs` on the BLU one, `gear-list.cs` on them all, and `doc-lint.cs`. Then `rank-doc --check` | `data/` and `docs/`, the outside data in it too, the launcher, which says what the checks are, and the builds it runs (see below) |
| `gearswap` | No tests yet | |

- The hash of a category's files when it last passed is kept in the checkout's `.claude/cache/passes`. A run that fails, one with `--filter`, or one during which the files changed keeps no pass.
- A pass vouches for the builds it ran on, so a build made again clears every pass.
- `--all` runs every category, and `test tools` (or `data`) runs that one whether or not it changed.
- `test tools --filter gear-list` runs only the tools tests whose name holds the text.
- Exit code 0 when every category that ran passed, 1 when one failed, 2 for an option or a category it doesn't know, or a `--filter` no test's name holds.

`tests/run-tests.cs` runs against Testy, whose repository is `tests/fixture/repo/`: its export, notes and gear list, a small Sel gear file (`data/Testy/Testy_Blu_Gear.lua`), sets files under `sets/`, clean and with mistakes put in, and small copies of the outside data under `docs/`. The tests never read the real data and never use the network.

- The tests run the tools' builds the launcher just made, side by side, each on what it makes for itself, and each prints how long it took. A run takes a few seconds, after building the tools.
- A test that needs a mistake copies the fixture to the temp folder, breaks the copy and runs the tool on it. Environment variables point the tools at what a test made: `GEAR_TOOLS_ROOT` at its repository, `GEAR_TOOLS_WIKI` and `GEAR_TOOLS_RESOURCES` at stand-ins for bg-wiki's API and Windower's resource files that the test runs on its own machine, and `GEAR_TOOLS_REPO_<NAME>` (`GEAR_TOOLS_REPO_WSDIST_BETA`, `GEAR_TOOLS_REPO_BG_JOB_GUIDES`) at a repository the test made, as `<url> <commit>`. Nothing else should set them. The tools a test runs also share a temp folder of the test's own, so the test can see what they left behind.

## Adding or changing a tool

- Start with a test in `tests/run-tests.cs` that fails for the reason the change is needed, with the fixture extended to show it.
- A tool is one `.cs` file here, with top-level statements. Code two tools need goes in `lib/`.
- A checker takes sets files, not a framework's Lua. Support for another framework is a reader like `sel-sets.cs` that writes a SetsDto, and a page under `docs/frameworks/`.
- Keep a tool's usage in its opening comment and its row in the table above.
- `search-fast-recast.cs` must keep running as a lone copy, so it uses nothing from `lib/`.
