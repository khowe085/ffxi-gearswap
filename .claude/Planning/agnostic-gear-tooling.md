# agnostic-gear-tooling

Make the gear-optimizer agent and `.claude/tools` independent of the GearSwap framework. The tools and the agent take a gear-sets DTO (JSON) and return one. The caller (the main session) reads the framework's files into the DTO and writes the result back into them.

## Decisions (from the user, 2026-10-08)

| Question | Decision |
|---|---|
| Who applies changes to the framework | The main session or agent that calls the tools. The one exception is a checked-in Sel reader that writes a SetsDto (user, 2026-10-08). Writing the result back into the Sel files stays manual. |
| Agent role | Returns a DTO and never edits Lua. Framework-neutral docs (gear notes, rank docs, notes, gear list) stay with the agent. |
| Format | JSON files: `--in <file.json>`, and `--out <file.json>` or stdout. |
| Frameworks | Sel only. The Rahvin parsing is removed. The DTO leaves room to add Rahvin back later. |

## Why

The tools only parse RahvinGS: `gear.<key> = hp_gear|mp_gear|rank_gear(` in `lib/GearDefs.cs:43`, the library path `data/common/RahvinGS/...` hardcoded at `:335`, and `IsJobFile` at `lib/Characters.cs:40` requiring `^[A-Z]{3}\.lua$`. This branch is Sel (`data/<JOB>.lua` plus `data/<Char>/<Char>_<Job>_Gear.lua`, with `{name=...,augments=...}` tables and plain string slot values), so `check-export`, `gear-list` and `check-blu-spells` see nothing or fail here.

## DTO contract

All DTOs are C# records serialized with System.Text.Json. They go in a new `lib/Dto.cs` and carry `schemaVersion: 1`.

**Piece**: `{ item, augments?: string[], bag?: string }`. `item` is the export name. `augments` must match the export when present.

**SetsDto** (the input to the checkers and the agent):
```json
{ "schemaVersion": 1, "character": "Vanar", "job": "BLU",
  "sets": [ { "name": "precast.FC", "slots": { "head": { "item": "Carmine Mask +1", "augments": ["..."] } } } ],
  "spellLists": { "Physical": ["Savage Blade"] } }
```
- `name` is the caller's own set path, an opaque string to the tools. Sel `sets.precast.FC` becomes `precast.FC`.
- A set has an optional `base: "<other set name>"` and lists only the slots it overrides, matching `set_combine(base, {...})`. Tools resolve the base chain themselves (`Dto.Resolve`) before checking or totting up stats; a missing base or a cycle is an error. Decided 2026-10-09.
- `spellLists` is optional and only for BLU.
- `spellSets` is optional and only for BLU: `{ "<spell>": "<set name>" }` for each blue spell that has a set of its own, where the framework looks for one. The reader fills it (for Sel, a set named for the spell under `sets.midcast`, or under `sets.midcast['Blue Magic']`; see `docs/frameworks/sel.md`). `check-blu-spells` counts such a spell as placed, in no list or in two. Each value must name a set in the file. Added 2026-10-10.

**OptimizeRequest** (the input to the agent): `{ schemaVersion, character, job, export: "<path>", sets: SetsDto, bags?: ["wardrobe","wardrobe2"], targets?: { "<set>": "<free text or stat goal>" } }`

**OptimizeResult** (the agent's output):
```json
{ "schemaVersion": 1, "sets": [ /* same shape as SetsDto.sets, full replacement for each set touched */ ],
  "changes": [ { "set": "...", "slot": "...", "from": "...", "to": "...", "reason": "..." } ],
  "shortfalls": [ { "set": "...", "stat": "Fast Cast", "target": 80, "achieved": 74, "note": "..." } ],
  "questions": [ "..." ], "docsEdited": [ "data/Vanar/Vanar_gear_list.md" ] }
```

**Findings** (the checkers' output): `[ { "tool", "severity": "error|warn", "set", "slot", "item", "message" } ]`. Text output stays the default and `--json` writes findings. Exit codes stay 0/1/2.

## Tool changes

| Tool | Change |
|---|---|
| `lib/GearDefs.cs` | Delete the Lua/Rahvin parsing (`GearFiles`, `LuaGearFile` except `StripComments`, which may still be useful, and the library path). Replace it with `Dto.Load(path)` and validation. |
| `lib/Characters.cs` | Find a character by its `<Char>_notes.md` or `_gear_list.md` instead of `IsJobFile`. Keep the doc-path helpers. |
| `check-export.cs` | `--in sets.json`. Same checks per piece: a real item, owned with those augments, wearable by the job, right slot, equippable bag. New `--bags` restriction, so "only wardrobe/wardrobe2" can be checked. |
| `gear-list.cs` | Compare `<Char>_gear_list.md` against one or more SetsDto files (`--in` repeatable, one per job). `--print` builds the table from the DTOs. The `## <Slot> (<count>)` format is unchanged. |
| `<Char>_gear_list.md` | Rewrite it to be framework-agnostic (user, 2026-10-08). Key columns by job, not by job file name (`BLU.lua`). Rows list owned pieces, with the DTO set names that wear them. Regenerate the whole doc from the latest export plus the SetsDto files with `gear-list --print`. Vanar's current list is out of date (rahvin files, 2026-10-05 export), so it gets replaced, not migrated. |
| `check-blu-spells.cs` | Reads `spellLists` from the DTO. Each spell is in exactly one list and every name is a real spell. Remove the `interface.lua`/`builders.lua` list order and the hardcoded Rahvin list names. |
| `owned-gear.cs` | Remove `Keys`. `WornBy` comes from optional `--sets` DTOs. The rest of the `--json` shape is unchanged (`search-fast-recast` uses it). |
| `doc-lint.cs`, `rank-doc.cs`, `rank-tables.cs` | Only the `Characters.All()` discovery change. |
| `search-fast-recast.cs` | Remove the Vanar/BLU hardcodes and the `data/Vanar/BLU.lua` reference. Read the caps and inputs from args or a DTO. Low priority. |
| `sims`, `wsdist-gear`, `wiki`, `fetch-sources`, `Export`, `Resources`, rank libs | No change. Fix the Rahvin comment at `Export.cs:73`. |
| `sel-sets.cs` (new) | The Sel reader, from the gear-optimizer's scratch `selcheck.cs`. A reference copy is in `.claude/Planning/agnostic-gear-tooling/selcheck.cs`. Move its lexer and parser into `lib/SelReader.cs`. Output a SetsDto with `--out`. Its bag and ownership checks are dropped because `check-export` already does them. It is the only Sel-specific code. |
| `set-stats.cs` (new) | `selcheck`'s `StatBook` stat totals, run over a SetsDto (FC, DT, WSD, MAB, accuracy and so on per set). Framework-neutral. The optimizer uses it to report shortfalls. |
| `README.md` | Rewrite the tool table and "Typical runs" around DTO files. |

## Agent definition (`.claude/agents/gear-optimizer.md`)

- Input: the path to an OptimizeRequest JSON. Output: the path to an OptimizeResult JSON in the scratchpad, plus a short text summary.
- Remove every Rahvin reference: line 8 (the engine submodule), line 21 (`get_sets` hooks), line 26 (README §8, `GearSets-Include`, `interface.lua`, `builders.lua`), line 37 (engine layering and weapon lock), lines 99–112 (`gear.<key>` builders and the comment template), line 137 (`data/common`), and line 149 (`//gs c checksets`).
- Framework knowledge the optimizer needs goes in a separate doc, not in request fields (decided 2026-10-09). Proposed: `docs/frameworks/sel.md`, covering how Sel picks a set for each action, the set-name meanings, the layering (idle under everything, `set_combine`), the weapon lock, and the hooks a gear file may define (e.g. `user_job_post_midcast`). The agent reads it the way it reads `docs/ffxi-mechanics.md`. `docs/` names no character, so this fits.
- Checks the agent runs: `check-export --in <its own result>` and `check-blu-spells`. `gear-list` and `doc-lint` run after the caller has applied the result, or the agent runs them against the result DTO.

## Caller workflow (main session, Sel)

1. Run `sel-sets.cs -- <gear file> <JOB> --out <sets.json>`. It resolves `gear.x` tables and `set_combine`.
2. Write the OptimizeRequest and invoke the agent.
3. Apply `OptimizeResult.sets` to the Sel gear file. Reuse existing `gear.x` names where an item and augments match. Otherwise write the item string, or `{name=,augments=}` for augmented pieces.
4. Re-extract a SetsDto from the edited file and run `check-export --in`. This is the round-trip check that the translation was correct.

Risk: step 3, the write-back, is still done by hand. Step 4 catches mistakes in it, because the edited file is re-extracted with the same reader.

## Tests (TDD per `tdd-workflow`)

- `.claude/tools/tests/run-tests.cs` uses a Rahvin-style fixture (`fixture/repo`, character Testy). Moving to DTO input **will break existing tests**. Per the ground rule, list the affected tests and confirm with the user before changing or removing any.
- New fixture: Testy SetsDto/OptimizeRequest JSON files, valid and with injected mistakes (a non-owned piece, wrong augments, wrong slot, a job that can't wear it, the wrong bag, a duplicated BLU spell, an unknown spell).
- Write the new tests first, red, then implement.

## Order

1. `lib/Dto.cs` and its tests, then `lib/SelReader.cs` and `sel-sets.cs`. Write the tests first, against a small Sel fixture for Testy.
2. `check-export`, then `check-blu-spells`, then `gear-list`, then `owned-gear`.
3. The `Characters` discovery change and its tools.
4. Rewrite the agent definition and README.
5. One full run on Vanar BLU through the caller workflow. Verification: all checker output shown.
6. Blind review gate (up to 3 rounds), then a PR on request.

## Open questions

1. ~~Flat or base plus overrides~~: base plus overrides (2026-10-09).
2. ~~Framework facts: request fields or doc~~: a separate doc (2026-10-09).
3. ~~Where does this work land?~~ Decided 2026-10-09: worktree `quizzical-bell-295858`, branch `work/claude/agnostic-gear-tooling`, from selindrile `7800acf`. The gear-set changes stay on `claude/nyame-gear-gearset-analysis-cb192d`.
4. ~~search-fast-recast.cs~~: keep it as a worked example (2026-10-09). Only its Vanar/BLU hardcodes go.