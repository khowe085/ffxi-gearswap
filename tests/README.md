# GearSwap's tests

Lua tests of GearSwap itself and of Selindrile's framework on top of it, run by [busted](https://lunarmodules.github.io/busted/) on a plain Lua 5.1, the language Windower's LuaJIT speaks. They play a made-up character, Testy, on a stand-in for the game, and look at what a player would: what is worn, what GearSwap sends, and what the user file's hooks are handed.

```bash
dotnet run .claude/gear.cs -- test gearswap
```

runs every spec file, each in a busted process of its own, side by side (`.claude/tools/tests/run-gearswap-tests.cs`). `--filter <text>` runs only the tests whose name holds the text. One file can also be run by hand from the repo root, where `.busted` sets busted up:

```bash
busted tests/sel/idle_spec.lua
```

They run on Linux or WSL, not on Windows, and need Lua 5.1, LuaRocks and busted: `luarocks --lua-version 5.1 install busted`. Nothing else: no game, no Windower, no network.

## What is where

| Path | What |
|---|---|
| `gearswap/` | GearSwap with no framework: the order of an action's precast, midcast and aftercast, what the hooks are handed, commands, status and buff events, and how a set becomes equip requests (names, augments, bags, `empty`, slot names, `set_combine`). |
| `sel/` | How Sel picks and lays sets, as `docs/frameworks/sel.md` describes: idle, engaged, precast, midcast, weapon skills, abilities, the weapon lock, defense and kiting, and the hooks a gear file may define. Then the rest of Sel: its `gs c` commands, its mode class, the status box, Treasure Hunter, spell maps, and what it does on buffs, zoning, the time of day, a sub job change and a monster's actions. |
| `jobs/` | What each job file in `data/` does on top of Sel, one spec per job: the set a spell, ability or weapon skill takes, what a job's hook changes or sends, its commands, the states it keeps and what its tick does on its own (Auto Buff Mode, Hasso, Majesty and the rest). They play Jobby, a made-up character with a small gear file for each job. |
| `data/` | Every character's real gear file loads under GearSwap and Sel, builds its sets and gets through a status change and an action without an error. It finds the gear files itself, so a new one is tested without an edit here. |
| `harness/` | Tests of the stand-ins below. |
| `support/` | The harness. |
| `fixture/data/Testy/` | Testy's user files: `Testy_WHM.lua`, a plain GearSwap file whose hooks note what they were handed; `Testy_Rdm_Gear.lua`, a small Sel gear file the real `data/RDM.lua` loads; and the other files the tests load by name. |
| `fixture/data/Autoy/` | Autoy's Sel gear files (RDM, WAR, DRK), for the tests of Sel's automatic actions (`sel/auto_*_spec.lua`): its tick, the Auto modes and the lists they work from. `support/autoy.lua` boots Autoy. |
| `fixture/data/Commy/` | Commy's Sel gear files, for the real `data/RDM.lua`, `WAR.lua` and `THF.lua`: the character the tests of Sel's commands, modes, status box, Treasure Hunter, spell maps and event handling play. `support/commy.lua` holds Commy's gear and boot options. |
| `fixture/data/Jobby/` | Jobby's gear files, one per job (`Jobby_Blu_Gear.lua` and so on), which the real job files load. Each defines the sets its job file looks for with pieces that tell them apart, so a test knows from what is worn which set was chosen. `support/jobby.lua` holds Jobby's boot options, the idle sets as the game shows them worn, and a look at the actions, chat lines and commands a job file sent. |
| `fixture/res/` | Small cuts of Windower's resource files: only the entries the tests use, each line as Windower/Resources has it. Add an entry by copying its line from there. |

## The harness

`support/harness.lua` boots GearSwap for a test as Windower loads an addon: `harness.boot(options)` returns a session whose `type`, `console`, `finish_action`, `interrupt_action`, `engage`, `gain_buff` and `advance` play the game, and whose `worn`, `traffic` and `log` say what happened. The session runs most of the game's own functions too (`set_day`, `change_zone`, `give_pet`, `send` and the rest) and lets the game settle after each. `support/testy.lua` holds Testy's gear and boot options.

- **A Lua state of its own.** Each boot gets its own environment, with its own `require`, so GearSwap's globals, the libraries it loads and the user file's globals don't carry from one test to the next. What Lua keeps for the whole state is shared: the `string` table, since Windower's string functions have to be where strings' methods come from, and the metatables of strings, numbers, booleans and functions. Each boot puts these back as Lua had them before the first, so one boot's libraries don't wrap another's.
- **A Windower install of its own.** GearSwap runs from a copy, made in the temp folder once per spec file: the repo's GearSwap (its Lua, `libs/`, and the Lua under `data/` with `fixture/data` added), Windower's libraries from `docs/windower/libs` and the resources from `fixture/res`. What GearSwap or Sel write lands in the copy, never in the repo, and the copy is removed when busted exits. Paths in an error are given back as the repo's. File names match in any case, as on Windows.
- **Windower's own libraries**, unchanged, from `docs/windower/libs`. `dotnet run .claude/gear.cs -- windower-libs` writes them from Windower/Lua at the commit `.claude/tools/lib/Sources.cs` pins; move the pin there, run it, and run the tests. Windower's C modules are stood in for: `support/pack.lua` (string.pack and string.unpack in Windower's formats), `support/bit.lua` (LuaJIT's bit), a socket with only gettime and sleep, and an empty mime.
- **Windower's Lua dialect.** Windower's Lua takes a method called on a literal (`'%d':format(n)`, `0:char()`, `true:fn()`) or on a table constructor, and a function expression called where it stands. `support/dialect.lua` puts each in parentheses before a file is compiled; nothing else changes, line numbers included.
- **The game** (`support/game.lua`): the character, a monster to target, the other mobs a test adds, a pet, bags and gear, and the Windower API over them. Nothing happens on its own. What GearSwap sends waits for the game to settle, as it would for the next frame: an equip request is carried out and confirmed with the packets the server answers with, and so is a move of an item between bags (the server's side of `gs stash` and `gs pull`, which takes nothing from or into a closed bag, a Mog House bag away from the Mog House and a moogle, or a full one); a command runs (a `wait` puts the rest off); chat input goes through the outgoing text event. The clock moves only when a test advances it, and the timers due then run. A test says when the server answers an action, when a buff comes or goes, when a recast starts, when Vana'diel's time, day or weather, the zone or a job changes, and when a pet (a puppetmaster's automaton, a geomancer's luopan) arrives, changes status or gains TP, or an indicolure comes or goes: `give_pet`, `take_pet`, `set_pet_status`, `set_pet_tp` and `set_indi` send the packets the server does, and `place_pet` puts out a pet with none, as one out when GearSwap loads.
  - **Other mobs**: `add_party_member` adds another player, in the party (`<p1>` on), in another party of the alliance (`slot = 'a10'`) or, with `in_party = false`, in none; `add_mob` an NPC; `target` and `subtarget` aim at one. A mob's `distance` is squared, as Windower gives it.
  - **What the game reports of itself**: `set_info` changes what `get_info` says (the Mog House, the target arrow); `set_automaton` and `set_species` what `get_mjob_data` says for a puppetmaster and a Monipulator; `set_job_traits` the traits `get_abilities` lists; `start_ability_recast` and `start_spell_recast` the recasts. A bag with `disabled` set is closed; a game with `refuse_moves` or `refuse_equips` set refuses every move or equip request; `loading` set to `'player'` or `'job'` has `get_player` report a character the game is still loading. `turns` lists the angles the character was turned to.
  - **Packets**: the game writes most of the packets the server sends byte by byte. `send` builds one from Windower's own field definitions, by label, so each lands where the real game puts it: `gs:send(0x00A, {['Zone'] = 230})`; `send_zone_in` lays labels over the zone-in packet for the game as it stands, and `receive` sends a packet's bytes as they are.
- **A plain user file** (`support/plain.lua`): Testy as a white mage on one of the plain GearSwap files in `fixture/data/Testy/`, and a look at the chat, the prints and the events such a file notes.

## Adding a test

- Start with a test that fails for the reason the change is needed. A test that needs the game to do something it doesn't yet fails for want of it; add that to `support/game.lua` or `support/harness.lua`.
- Boot in the test or a `before_each`, so each test starts from the same place. Give the boot only the items the test needs.
- Pin what GearSwap and Sel really do. When they do something else than `docs/frameworks/sel.md` says, settle which is right before writing the test.
- A file runs in a process of its own, so several smaller spec files finish sooner than one big one.
