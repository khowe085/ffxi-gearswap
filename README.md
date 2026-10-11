## This repository

* `data/Vanar/` holds Vanar's notes: `Vanar_gear_list.md`, the gear Vanar's job files use, and the files it links: `Vanar_notes.md` (the player's rules for the sets, the ranks the player has given, merits, job points, Master Levels and nation), `Vanar_gear_notes.md` (notes on Vanar's copies) and `Vanar_rank_augments.md` (Vanar's path and rank for each path-augmented item). The job files themselves and the RahvinGS engine they include are on the `rahvin` branch.
* `docs/ffxi-mechanics.md` explains the game mechanics the gear sets rely on: casting time, recast, haste, accuracy and attack, magic accuracy, enhancing and enfeebling magic, magic damage, Cure, blue magic and weapon skills.
* `docs/gear-notes.md` records what an item's text and the export don't show, for any copy of the item: hidden values, set bonuses, conditions and slot or hand restrictions.
* `docs/rank-augments.md` gives the augment values at every rank for the exports' path-augmented gear (Nyame, Bunzi's, Gleti's and the other "Path:" items), taken from bg-wiki's rank tables.
* The three files under `docs/` hold for any character and name none. What holds for one character is in that character's folder under `data/`.
* `.claude/agents/gear-optimizer.md` is a Claude Code agent that builds and reviews gear sets from the export, the docs above and the character's own notes. `.claude/tools/` holds the .NET file-based apps it checks its work with (`.claude/tools/README.md`): they list what the character owns, check a job file against the export, and keep the gear list and the docs in step. They need the .NET 10 SDK, and keep what they download in `.claude/cache/`, which git ignores. The tools that read job files or the gear library need the RahvinGS engine at `data/common/RahvinGS/`, which this branch doesn't include.

---

Author: Byrth

Version: 0.930

Date: 06/13/2017

GearSwap

Abbreviation: gs

Commands (<> indicates a field. You do not actually have to use <>s):
* gs c <string> : Passes the <string> to the self_command() user function.
* gs equip <string> : Attempts to interpret the <string> as an index of the sets table and equip that set. Will ignore "sets" if the string starts with it.
** gs equip naked : This equips the default set "naked," which is just a bunch of empty slots. If you remake sets (sets={}) in your get_sets(), this will not work.
* gs naked : (or n) Equips the naked set as gs equip naked does, then disables the user file so nothing re-equips gear until the next gs naked. A bare gs enable or gs disable also ends it.
* gs debugmode : Activates GearSwap's Debug Mode, which prints out why specific gear equipping attempts failed, shows you when you're entering events, and enables the eval command.
** gs eval <string> : This command evaluates the <string> as Lua code in the global gearswap environment (not the user environment, which is in the user_env table). It is only available when debugmode is on.
* gs showswaps : Shows when your gear successfully changes and what it changes to.
* gs load <string> : (or l <string>) Attempts to load the first version of <string> found, assuming it is a file path relative to 9 potential base directories, in this order:
  
  * ..GearSwap/libs-dev/<string>
  * ..GearSwap/libs/<string>
  * GearSwap/data/<character_name>/<string>
  * GearSwap/data/common/<string>
  * GearSwap/data/<string>
  * APPDATA/Windower/GearSwap/<character_name>/<string>
  * APPDATA/Windower/GearSwap/common/<string>
  * APPDATA/Windower/GearSwap/<string>
  * ..Windower/addons/libs/<string>

* gs reload : Reloads the current user file.
* gs export <options> : Exports your currently equipped gear, inventory, or all the items in your current Lua files' sets into GearSwap .lua or spellcast .xml format. Takes options "inventory", "all", "wearable", "sets", and "xml." Defaults to currently equipped gear and lua otherwise. Also exports appropriate advanced set tables with augments for currently equipped gear and inventory. "all", unless with "compact" or "bgwiki", writes one table per bag (inventory, safe2, wardrobe3...), then one per storage slip (slip1 to slip33) for the items stored with a porter moogle; slip items carry no augments, and an empty bag or slip is left out.
* gs enable <slot> : Enables equip commands targeting a specified slot. "All" will allow all equip commands. Providing no slot argument will enable user GearSwap file execution, if it was disabled.
* gs disable <slot> : Disables equip commands targeting a given slot. "All" will prevent all equip commands. Providing no second argument will disable user GearSwap file execution, although registered events will still run.
* gs validate <sets|inv> <filter> : This command checks to see whether the equipment in the sets table also exists in your inventory (default), or (by passing "inv") whether the equipment in your inventory exists in your sets table. <filter> is an optional list of words that restricts the output to only those items that contain text from one of the filter's words.
* gs test set <set> : Equips the set over a naked character, reading it as gs equip does, then disables the user file for 30 seconds so the gear stays on.
* gs test [precast|midcast] <action> : Strips every slot but main, sub and range, then calls the user file's precast and then midcast for the named spell, ability or weapon skill, without using it, and disables the user file for 30 seconds. "precast" stops before midcast. The spell table is aimed at your target, or at you with none, and carries spell.test = true so the user file can tell a test from a real use. When the 30 seconds end, the file is enabled and gets a status_change with your current status. Another gs test during the 30 seconds starts over, and a bare gs enable or gs disable takes over from the timer.
* gs audit <gs test's arguments> : Runs gs test with those arguments, waits for the server's stats update, sends /checkparam <me>, and appends one JSON object a line to data/audit/<character>.jsonl: the arguments, the date, job and levels, STR to CHR (totals, and what gear and buffs add), attack, defense, elemental resistances, max HP and MP, /checkparam's accuracy and attack for each hand and ranged and its evasion and defense, the gear in each slot, and the active buffs. Haste, fast cast, magic accuracy and damage taken aren't in it, because the game doesn't send them to the client. A gs test, another gs audit, a bare gs enable or gs disable, a user file load, or the end of the 30 seconds before the record is written drops it. If no stats update arrives after the gear goes on, the record says so with char_stats_fresh = false.
* gs stash <jobs> [unused] : Reads the file GearSwap would load for each job listed, such as `gs stash BLU RDM`, and moves the gear their sets use out of wardrobe and wardrobe2, into the first of case, sack, safe, safe2, storage and locker with room. With "unused", it moves everything else out of the two wardrobes instead. Equipped pieces stay. It stops with a message when every stash bag in reach is full.
* gs pull <jobs> : Reads the same files and moves the gear their sets use into wardrobe, then wardrobe2, from every other bag in reach, taking only the copies the wardrobes lack. The inventory, satchel, sack, case and wardrobes 3 to 8 are in reach anywhere; safe, safe2, storage and locker are in reach in the Mog House, and all but storage at a Nomad or Pilgrim Moogle. It stops with a message when both wardrobes are full.
* gs e, gs x and gs t are short for gs equip, gs export and gs test.

Purpose: To assist in the micromanaging of equipment!

Settings Files:  
There is no settings file for GearSwap.

Additional Assistance:
The Windower/addons/GearSwap/beta_examples_and_information folder has a file in it named Variables.xlsx that gives more specific information. If that is insufficient, you can go to BlueGartr's FFXI section or FFXIAH and ask for more assistance.
