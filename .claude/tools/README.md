# Gear tools

.NET file-based apps for building and checking the gear sets in `data/<Character>/`. They read the repo's own files (the latest `//gs export`, the job files, the RahvinGS gear library, the docs) and a few outside sources kept in `.claude/cache/`. The `gear-optimizer` agent (`.claude/agents/gear-optimizer.md`) runs them; they also run by hand.

## Running one

From the repo root, with the .NET 10 SDK:

```bash
dotnet run --no-cache .claude/tools/check-export.cs -- --job BLU
```

- Options go after `--`. Each tool's opening comment lists its own.
- Always pass `--no-cache`. Every tool also compiles the shared code in `lib/` (through `Directory.Build.props`), and `dotnet run` only rebuilds when the tool's own file changes. Without `--no-cache`, a tool built before an edit under `lib/` stops and says so, rather than run the old code.
- Most tools take `--char <name>` and `--export <path>`. Without them they use the newest export in `data/export/`, by the date in its file name, and the character that export is named for.
- Exit code 0 means nothing wrong was found, 1 means the tool found a problem, 2 means it couldn't run (a bad option, a missing file, an empty cache).
- Nothing is built into the repo: `dotnet run` keeps its output under the user's temp folder.

## The cache

`.claude/cache/` is git-ignored. `fetch-sources.cs` fills it, and the tools that need it say so when it is empty.

| Folder | What | From |
|---|---|---|
| `res/` | Windower's `items.lua`, `item_descriptions.lua` and `spells.lua`: every item's id, jobs, slots and help text | Windower/Resources, branch head |
| `wsdist_beta/` | Kastra's damage simulator, read as source | IzaKastra/wsdist_beta at `d12ac59` |
| `bg_job_guides/` | The wikitext of bg-wiki's simulated gear sets, one file a job | IzaKastra/bg_job_guides at `f264ae4` |
| `ranks/ranks.json` | bg-wiki's rank-by-rank augment tables for the export's items | `rank-tables.cs` |
| `wiki/` | bg-wiki pages saved as wikitext | `wiki.cs` |

The two repos are pinned to the commits `docs/ffxi-mechanics.md` cites file and line numbers from. Move a pin only together with those references.

## The tools

| Tool | What it does | Run it |
|---|---|---|
| `fetch-sources.cs` | Fills the cache: resources and the two pinned repos. `--refresh` fetches again. | Once on a new checkout, and after a game update for fresh resources. |
| `owned-gear.cs` | Lists the weapons and armor in the export with slot, jobs, bag, help text, the `gear.<key>` entries that name each piece, and the job files that already wear it. Filters: `--job`, `--slot`, `--grep`; `--json` for another tool. | To see what a slot can choose from, before picking a piece. |
| `check-export.cs` | Checks every `gear.<key>` a job file wears: defined, a real item, owned with those augments, wearable by the job, right for the slot, and in a bag GearSwap can equip from. | After every change to a job file, and when a new export arrives. |
| `gear-list.cs` | Checks `<Character>_gear_list.md` against the job files, set by set, and reports a job file the list has no column for. `--print` writes the table the files call for, with a column for every job file. | After every change to a job file. |
| `check-blu-spells.cs` | Checks that each blue spell is in exactly one of BLU.lua's spell lists, and that every name in them is a real spell. | After moving a spell between lists. |
| `sims.cs` | Shows bg-wiki's simulated sets for a job, marks what the character owns, and counts how often each piece fills a slot. | For a reference set to start from. |
| `wsdist-gear.cs` | Looks an item up in wsdist's gear data. `--check-nyame` compares its Nyame entries with `docs/rank-augments.md`; at the pinned commit it finds one difference, the Nyame Flanchard error `docs/ffxi-mechanics.md` lists, and so exits with 1. | For a second opinion on an item's stats, and to see which rank entries the simulator has. |
| `wiki.cs` | Saves bg-wiki pages as wikitext, many to a request. | Before relying on a mechanic or an item detail the docs don't cover. |
| `rank-tables.cs` | Reads bg-wiki's rank tables for the export's items into the cache. | After an export that adds a rank-augmented item. |
| `rank-doc.cs` | Renders `docs/rank-augments.md` from those tables and the player's ranks, which are kept in the tool. | After the player reports a new rank (edit the ranks in the tool first). |
| `doc-lint.cs` | Checks the docs: links, anchors, tables, and `gear-notes.md` against the simulated sets. Also lists owned pieces the notes don't cover. | After any edit under `docs/`. |
| `search-fast-recast.cs` | A worked example of choosing a set by exhaustive search (BLU's Fast Recast set). It uses nothing from `lib/`, so a copy runs from any folder. | Copy it when a set's worth is a formula over a few stats. |

## Typical runs

A set changed:

```bash
dotnet run --no-cache .claude/tools/check-export.cs
```

```bash
dotnet run --no-cache .claude/tools/gear-list.cs
```

What can RDM wear on its legs, and which pieces have Fast Cast:

```bash
dotnet run --no-cache .claude/tools/owned-gear.cs -- --job RDM --slot legs
```

```bash
dotnet run --no-cache .claude/tools/owned-gear.cs -- --job RDM --grep "fast cast"
```

A new export arrived: run `check-export.cs` and `gear-list.cs`, fix what they report, then update the export named in each job file's opening comment, in the gear list's first sentence and in the root `README.md`. The two tools say when a job file's comment or the list's sentence still names an older export; nothing checks the root `README.md`. Then run `rank-tables.cs` and `rank-doc.cs` so `docs/rank-augments.md` follows the new export.

## What the checks rest on

- **The export** is the only record of what the character owns. `//gs export all`, with the Rahvin engine loaded, writes one table for each bag and one for each storage slip (`slip1` to `slip33`). GearSwap equips from the inventory and the wardrobes only, so `check-export.cs` warns about a piece that is only in another bag or on a slip. The export never shows a path item's rank; those come from the player and live in `rank-doc.cs`.
- **Windower's resources** give each item's jobs and slots, and both of its names. A `gear.<key>` entry may use the short name the export prints or the long log name; the tools accept either, as GearSwap does.
- **The job files are read as text**, not run. A set is found by its `sets.<name> = { ... }` or `sets.<name> = set_combine(..., { ... })` assignment, and a piece by a `slot = gear.<key>` pair inside it. Gear a hook puts on with a `slot = gear.<key>` pair is listed under the hook's name, as in `midcast_custom()`. Inside a set's table, a slot given anything else, such as an item's name in quotes, gets a warning and isn't checked. A hook that fills a slot any other way isn't seen.
- **None of this runs GearSwap or the game.** A clean run means the file names real, owned, wearable gear in the right slots. It doesn't mean the sets behave in game.

## Tests

`tests/run-tests.cs` checks the shared code and runs each tool against a small made-up character, Testy, whose repository and cache are under `tests/fixture/`. It never reads the real data and never uses the network.

```bash
dotnet run --no-cache .claude/tools/tests/run-tests.cs
```

```bash
dotnet run --no-cache .claude/tools/tests/run-tests.cs -- gear-list
```

- A word after `--` runs only the tests whose name contains it.
- A test that needs a mistake copies the fixture to the temp folder, breaks the copy and runs the tool on it. Two environment variables point the tools at a copy: `GEAR_TOOLS_ROOT` for the repository and `GEAR_TOOLS_CACHE` for the cache. Nothing else should set them.
- The whole run takes about a minute, because each tool run is a build.

## Adding or changing a tool

- Start with a test in `tests/run-tests.cs` that fails for the reason the change is needed, with the fixture extended to show it.
- A tool is one `.cs` file here, with top-level statements, starting with `Tool.Init()`. Code two tools need goes in `lib/`.
- Keep a tool's usage in its opening comment and its row in the table above.
- `search-fast-recast.cs` is the exception to both: it must keep running as a lone copy, so it uses nothing from `lib/`.
