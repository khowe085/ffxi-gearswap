# Selindrile's GearSwap framework

How Selindrile's framework (Sel) picks and lays the gear sets a character's gear file defines, and how its files map to the sets files the tools in `.claude/tools` read. What a stat does in the game is in [ffxi-mechanics.md](../ffxi-mechanics.md); this page is only about which set is on when. It was read from `libs/Sel-Include.lua` and `libs/Sel-SelfCommands.lua` in this repository, and the function names below are the ones there.

## The files

Sel loads a job's files in this order. Each one can redefine what an earlier one set.

| File | What it holds | Edit it? |
|---|---|---|
| `data/<JOB>.lua` | The job file: states, the job's own logic and, for BLU, the blue magic lists (`blue_magic_maps`). | No. Redefine what needs changing in a later file. |
| `libs/Sel-*.lua` | The framework: set selection, modes, commands. It also gives placeholder entries such as `gear.ElementalObi`, which it fills at run time. | No. |
| `data/User/User-Globals.lua` | Settings for every character and job. | Rarely. |
| `data/<Character>/<Character>-Globals.lua`, `<Character>-Items.lua`, `<Character>_Crafting.lua` | The character's settings, gear entries and sets for every job (Items holds sets such as `sets.TreasureHunter` and `sets.buff.Doom`). | For gear entries and sets shared by jobs. |
| `data/User/User-<JOB>.lua` | Settings for one job, every character. | Rarely. |
| `data/<Character>/<Character>_<Job>_Gear.lua` | The gear file: `user_job_setup()` (modes, binds, gear entries) and `init_gear_sets()`, where the sets are built. | Yes. This is where sets change. |

## How a set is written

- A set is a table of slots: `sets.precast.FC = {head="Carmine Mask +1", ear1="Loquac. Earring", ...}`. A slot holds an item name as a string, a `{name="...", augments={...}}` table that picks one copy, or a `gear.x` entry that holds such a table. `bag="wardrobe2"` in the table pins the copy to a bag.
- The slot names `ear1`, `ear2`, `ring1`, `ring2` and `range` are the same slots as `left_ear`, `right_ear`, `left_ring`, `right_ring` and `ranged`.
- `empty` clears a slot.
- `set_combine(sets.A, {...})` makes a new set: a copy of A with the table's slots over it. With more arguments, each one goes over the ones before it.
- `sets.B = sets.A` makes B the same table as A, not a copy: a later change to one is a change to both.
- A slot a set leaves out keeps whatever was on before. Precast and midcast sets go on over the idle or engaged set, so a slot left out of them keeps the idle or engaged piece.

## How Sel picks a set

For each action Sel starts at a table and walks down its keys, taking each key the table has and skipping each one it lacks. The deepest table it reaches is the set it equips. A key that names no set is not an error: Sel stops at the table above it and says nothing.

| Action | Starts at | Then, in order |
|---|---|---|
| Idle | `sets.idle` | `Weak` under weakness; the idle mode (`state.IdleMode`, or `state.NonCombatIdleMode` for a DT, Tank or EVA mode out of combat); `Pet`, then `Engaged` with a pet; the job's custom idle groups. |
| Engaged | `sets.engaged` | `state.CombatForm` (such as `DW`); `state.CombatWeapon`; the offense mode (`state.OffenseMode`); the hybrid mode (`state.HybridMode`); the custom melee groups. Out of melee range Sel equips the idle set instead. |
| Resting | `sets.resting` | |
| Precast of a spell | `sets.precast.FC` | the spell's custom class, then its name (`sets.precast.FC.Utsusemi`), then its spell map, then a `Cure` set for any Cure or Curaga map. Failing all three, its skill (`sets.precast.FC['Blue Magic']`) or its type, and the three again under that. Then the casting mode (`state.CastingMode`), and `DW` when the character can dual wield. |
| Midcast of a spell | `sets.midcast` | The same as precast: class, name, map, skill or type, casting mode, `DW`. A spell that matches nothing gets `sets.midcast` itself. |
| Weapon skill | `sets.precast.WS` | the weapon skill's name (or map, class, type), then the weapon skill mode (`state.WeaponskillMode`; `Match` takes the offense mode's name when there is such a mode), then the weapon set's name (`state.Weapons`). |
| Job ability | `sets.precast.JA` | the ability's name. Other ability types start at `sets.precast.<type>`, such as `sets.precast.Waltz` or `sets.precast.Step`, and fall back to `sets.precast.JA`. |

The spell map comes from Sel's own mappings and from the job file's `job_get_spell_map`. A mode's sub-table that the gear file doesn't define leaves the set above it in place, so `sets.midcast['Blue Magic'].Magical.Resistant` is worn only in the Resistant casting mode, and otherwise `sets.midcast['Blue Magic'].Magical` is.

### Sets laid over the chosen set

After the chosen set Sel equips more sets over it, each only when the gear file defines it:

- Idle: `sets.ExtraRegen` under 80% HP, `sets.DuskIdle`, `sets.DayIdle` or `sets.NightIdle`, and buff sets such as `sets.buff.Elvorseal`.
- Idle and engaged: the defense set while a defense mode is on (`sets.defense.<mode>`), and `sets.Kiting` while kiting is on.
- Precast, midcast and weapon skills, in combat with a defense mode on: the chosen set's `.DT` variant (`sets.precast.FC.DT`, `sets.precast.WS.DT`, `sets.midcast.FastRecast.DT` and so on), or the idle or engaged set when there is none.
- Weapon skills: `sets.Skillchain`, `sets.TreasureHunter` on an untagged target, and the elemental obi, cape and ring for an elemental weapon skill.
- Magic bursts: `sets.MagicBurst` (or `sets.ResistantMagicBurst`, `sets.HelixBurst`) over a nuke's midcast set when the magic burst mode is on.
- Buff sets under `sets.buff`, such as `sets.buff['Burst Affinity']`, which the job file equips while the buff is up.

### The weapon lock

`state.Weapons` names a weapon set under `sets.weapons`, such as `sets.weapons.Tizona`. Unless `state.UnlockWeapons` is on, Sel locks the slots that set fills (`main` and `sub`, and `range` or `ammo` when it names them): no other set's piece goes in a locked slot, whatever the set says. With the weapons state at `None` nothing is locked and each set's weapons go on, which resets TP when they change. With the lock off, Sel lays the weapon set over the idle and engaged sets.

## Hooks a gear file may define

Sel calls these when the gear file defines them. Each one can equip more gear after the chosen set, so a slot can end up with a piece no set table shows. Read every one the gear file has before judging what a set ends up wearing.

| Hook | When it runs |
|---|---|
| `user_job_setup()`, `character_user_job_setup()` | At load, before the sets. Modes, binds and gear entries. |
| `init_gear_sets()` | At load. Builds the sets. |
| `user_job_precast`, `user_job_midcast`, `user_job_aftercast` | Before Sel's own handling of that phase. |
| `user_job_post_precast`, `user_job_post_midcast`, `user_job_post_aftercast` | After the phase's set is equipped. A swap here goes over the set. |
| `user_job_filter_precast` and the other `filter` hooks | Before anything; they can cancel the action. |
| `user_job_customize_idle_set`, `user_job_customize_melee_set`, `user_job_customize_defense_set`, `user_job_customize_kiting_set`, `user_job_customize_passive_set` | When Sel builds that set; they return the set to wear. |
| `user_job_buff_change`, `user_job_state_change`, `user_job_self_command`, `user_job_tick` | On a buff, a mode change, a command, or every tick. |

The same hooks without `user_` (`job_post_midcast` and so on) belong to the job file, and run before the `user_job_` ones.

## Blue magic

A blue spell's spell map is the name of the first list in `blue_magic_maps` that holds it, such as `Magical` or `PhysicalStr`, so its midcast set is `sets.midcast['Blue Magic'].<list>` under the walk above. Sel tries the lists in no fixed order (Lua's `pairs`), so a spell in two lists can take either list's set from one load to the next. A spell in no list falls back to `sets.midcast['Blue Magic']`. `check-blu-spells.cs` reports both.

## Reading a gear file into a sets file

`sel-sets.cs` writes the sets file the tools and the `gear-optimizer` agent read. It reads the text; it doesn't run Lua.

- Each `sets.X = ...` in the gear file becomes a set named for its path under `sets`, written as Lua writes it: `sets.midcast['Blue Magic'].Physical` becomes `midcast['Blue Magic'].Physical`, and `sets.precast.WS['Savage Blade']` becomes `precast.WS['Savage Blade']`. A key that is a plain name takes the dot form whichever form the file used.
- `set_combine(sets.A, {...})` becomes a set with base `A` and the table's slots. A later set argument has its pieces copied into the set's own slots, since a sets file gives a set one base. A `set_combine` inside another is read as its arguments in its place, since `set_combine(set_combine(sets.A, t1), t2)` gives what `set_combine(sets.A, t1, t2)` does: the set keeps base `A`, with `t1` and then `t2` over it. `sets.B = sets.A` becomes an alias: a set `B` with `aliasOf` `A` and no base or slots, because in Lua B is the same table as A. A set inside either is inside both, whether written before or after the alias: `sets.B.X = ...` is read as `A.X`, and the tools resolve `B.X` to `A.X`. When `A` is later given a new table, the alias keeps the old one: `B` takes the old set's base and slots and the sets inside it, and other aliases of it name `B`. Assigning to `B` itself gives it a table of its own.
- A slot given as `""`, or `{name=""}`, is left out and noted. GearSwap's `expand_entry` (`equip_processing.lua`) reads `""` as no item, so the slot is neither equipped nor taken off; a sets file can't say that, and `empty` would take the piece off.
- Slots take their canonical names: `ear1` becomes `left_ear`, `ring2` becomes `right_ring`, `ranged` becomes `range`. `empty` becomes the item `empty`. A table that fills one slot under two names, as `ear1=` and `left_ear=`, keeps the last and is noted.
- For BLU, `spellSets` names each blue spell that has a set of its own where the midcast walk above reaches one: `sets.midcast['<spell>']`; or, when no `sets.midcast` set is named for one of the spell's lists (its spell map, which Sel tries next), `sets.midcast['Blue Magic']['<spell>']`.
- The reader starts from the empty sets Sel's own files make before the gear file runs: `precast` with `FC`, `JA`, `WS`, `RA` and `Item` under it, `midcast` with `Item`, `RA` and `Pet`, `idle`, `resting`, `engaged`, `defense`, `buff`, `element`, `passive`, `weapons`, `DuskIdle`, `DayIdle`, `NightIdle` (`Sel-Include.lua`) and `TreasureHunter` (`Sel-TreasureHunter.lua`). Building on one of them takes nothing from it, so `set_combine(sets.TreasureHunter, {...})` is read as the table alone, with no note. One a file read defines becomes a set like any other, and the sets inside it that were written before that are dropped, as above. They aren't written to the sets file unless a file read defines them.
- The files Sel loads before the gear file are read in Sel's order: the job file, `User-Globals.lua`, `<Character>-Globals.lua`, `<Character>-Items.lua`, `<Character>_Crafting.lua`, `User-<JOB>.lua`. Gear entries (`gear.x`) and blue magic lists come from anywhere in them; sets only from assignments outside any function or block, which run as the file loads (the others are made at run time). Those sets are written to the sets file, before the gear file's, since the game wears them. A gear-file set built on one takes its pieces: `sets.TreasureHunter = set_combine(sets.TreasureHunter, {...})` after Items' `sets.TreasureHunter = {head=...,hands=...}` keeps the head and hands. Redefining another file's set is no mistake and isn't noted; a set defined twice in one file is, except one defined again on itself (`sets.x = set_combine(sets.x, {...})`) or in another branch of the same `if`, which is printed as information and doesn't count toward the exit code.
- Left out, and noted on standard error: a gear entry no file read defines (such as `gear.ElementalObi`, which Sel fills at run time), a base no file read defines, a set named at run time (`sets.WS[ws]`), a value it can't follow, and a call that changes a blue magic list (`blue_magic_maps.Buff:remove(...)`), whose list is then read as assigned. An assignment counts wherever it is, inside an `if` or a function too, in the order the file has it, so a gear entry has to come before the sets that name it in the file, whatever order Sel calls the functions in. A set defined twice keeps its last definition, and a set built on the earlier one keeps the earlier one's pieces, as Lua copies them. The sets inside the earlier one, such as `sets.idle.DT` under `sets.idle`, are dropped and noted, because the new table doesn't hold them: that is so for a `set_combine` too, which copies slots only.
- What a hook equips isn't in the sets file. Read the hooks.

## Writing a result back

The `gear-optimizer` agent returns sets in the same shape and never edits Lua; the caller writes them into the gear file.

- Keep the set's form: a set with a base is `set_combine(sets.<base>, {...})` with only its own slots; one without is a plain table.
- An alias (`aliasOf`) is written `sets.<alias> = sets.<target>`, never as a copy or a `set_combine`, so a later change to the target still reaches it. A change to a set inside an alias, `B.X`, is a change to `A.X`: write it there. If a result needs the alias to wear something its target doesn't, that ends the alias; say so to the caller rather than write it silently.
- Reuse a `gear.x` entry the file already has when its item and augments match the piece. Otherwise write the item name as a string, or `{name="...", augments={...}}` for a piece that names augments, with the augments exactly as the export prints them, and `bag="..."` when the piece names a bag.
- Then read the edited file again with `sel-sets.cs` and run `check-export.cs` on the result. The same reader on both sides is the check that the write-back says what the result said.
