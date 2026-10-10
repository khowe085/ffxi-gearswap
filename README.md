## Modes and keys

Every mode below can be changed in game with `//gs c toggle <Mode>` (on/off modes), `//gs c cycle <Mode>` (modes with a list of values; add `reverse` to go backwards) or `//gs c set <Mode> <value>`. Key notation: `^` Ctrl, `!` Alt, `@` Windows key, `~` Shift.

### Keys for every job (`data/User/User-Globals.lua`)

| Key | Command | Mode | Values (default first) |
|---|---|---|---|
| `F7` | cycle | Weapons | The job file's weapon sets |
| `!^F7` | toggle | AutoFoodMode | off, on |
| `!@^F7` | cycle | AutoWS | OFF, then the current weapon set's `AutoWS_List` choices; back to OFF on a weapon change |
| `@F8` | toggle | AutoNukeMode | off, on |
| `^F8` | toggle | AutoStunMode | off, on |
| `!F8` | toggle | AutoDefenseMode | off, on |
| `!@^F8` | toggle | AutoTrustMode | off, on |
| `F9` | cycle | OffenseMode | Set per job |
| `^F9` | cycle | HybridMode | Set per job |
| `@F9` | cycle | RangedMode | Set per job |
| `!F9` | cycle | WeaponskillMode | Match, then per job |
| `F10` | set | DefenseMode Physical | Turns on the physical defense set |
| `^F10` | cycle | PhysicalDefenseMode | PDT, then per job |
| `!F10` | toggle | Kiting | off, on |
| `F11` | set | DefenseMode Magical | Turns on the magical defense set |
| `^F11` | cycle | MagicalDefenseMode | MDT, then per job |
| `@F11` | cycle | CastingMode | Set per job |
| `!F11` | cycle | ExtraMeleeMode | Set per job |
| `F12` | set | DefenseMode Resist | Turns on the resist defense set |
| `^F12` | cycle | ResistDefenseMode | MEVA, then per job |
| `@F12` | cycle | IdleMode | Set per job |
| `!F12` | reset | DefenseMode | Back to None |
| `@Pause` | cycle | AutoBuffMode | Off, Auto, then the job's other buff lists |
| `@ScrollLock` | cycle | Passive | None, then per job |

Other keys for every job: `Pause` runs `gs c update user`, `!@^F12` reloads GearSwap, `!@^Pause` runs `gs org`, `!@^Backspace` runs `gs c buffup`.

### Vanar's job keys (`data/Vanar/Vanar_<Job>_Gear.lua`)

| Job | Key | Command | Mode |
|---|---|---|---|
| BLU | `@F10` | toggle | LearningMode |
| BLU | `` !@^` `` | cycle | MagicBurstMode (the file binds SkillchainMode to this key first, and the second bind wins) |
| BLU | — | cycle | JobMode: AoE, Melee (default Melee); loads the AzureSets spell set |
| RDM | `@F10` | cycle | RecoverMode: 35%, 60%, Always, Never |
| RDM | `` @` `` | cycle | ElementalMode: Fire, Ice, Wind, Earth, Lightning, Water, Light, Dark |
| THF | `@F10` | toggle | AmbushMode |
| THF | `` @` `` | cycle | SkillchainMode: Off, Single, Lock |

The three files also bind `@F8` to AutoNukeMode, which is the same as the global key. Their other keys use job abilities or spells directly and change no mode.

### Modes with no key, for every job

| Mode | Values (default first) | What it does |
|---|---|---|
| TreasureMode | None, Tag (THF also SATA, Fulltime); every job starts in Tag | Treasure Hunter gear; Tag wears it until a monster is tagged. A job file with a `TH_Whitelist` (RDM, BLU) limits it to those spells, abilities and weaponskills plus ranged attacks, and engaging alone wears none |
| AutoWSBuff | on, off | Uses Last Resort, Berserk, Warcry or Aggressor before a weaponskill in the job file's `ws_buff_list` |
| AutoWSRestore | on, off | Lets AutoWS use Sanguine Blade, Catastrophe, Entropy or Mystic Boon at low HP or MP |
| UnlockWeapons | off, on | Lets sets change main and sub; while engaged they stay put |
| AutoWSMode | off, on | Only drives RngHelper's ranged auto-ws, and stays off without RngHelper |
| RngHelper, RngHelperQuickDraw | off, on | Ranged attack helper |
| AutoArts, AutoLockstyle, ReEquip, SkipProcWeapons | on, off | Arts upkeep, lockstyle on load and weapon change, re-equip weapons when bare, hide Proc weapon sets |
| AutoShadowMode, AutoSubMode, AutoJumpMode, AutoSuperJumpMode, AutoTankMode, AutoCleanupMode, AutoAcceptRaiseMode | off, on | Job automation |
| AutoRemoveDoomMode, AutoHolyWaterMode, AutoContradanceMode, CancelStoneskin, AdjustTargets, MiniQueue, RefineWaltz, IdleStep, HoverShot, UseCustomTimers, SelfWarp2Block, DisplayMode | on, off | Upkeep and convenience |
| Capacity, NotifyBuffs, SelectNPCTargets, WakeUpWeapons, ElementalWheel | off, on | Capacity cape on; tell the party about buffs in `NotifyBuffs`; let `<st>` targeting pick NPCs; hold `sets.WakeUpWeapons` while asleep; move ElementalMode on after each nuke |
| AutoRuneMode | Off, Runes, Full | RUN or /RUN: keeps runes up |
| AutoSambaMode | Off, Haste Samba, Aspir Samba, Drain Samba II | DNC or /DNC: keeps the chosen samba up |
| MagicBurstMode, SkillchainMode | Off, Single, Lock | Wears the magic burst or skillchain set for the next action (Single) or until turned off (Lock) |
| RecoverMode | 35%, 60%, Always, Never | Nukes wear the MP-recovery set below that MP |
| ElementalMode | Fire, Ice, Wind, Earth, Lightning, Water, Light, Dark | Element used by the element-picking nuke and ninjutsu commands |
| RuneElement | Ignis, Gelus, Flabra, Tellus, Sulpor, Unda, Lux, Tenebrae | Rune AutoRuneMode keeps up |
| RegenMode | None, Duration, Potency | Which Regen midcast set to wear |
| AspisMode | 250, 500, 1000, Always, Never | When Diamond Aspis swaps in for a job ability: below that TP, always, or never |
| Uninterruptible | Delay, Off, Full | Delay holds a cast pressed while moving until you stop; Full keeps queued actions through an interruption |
| PCTargetMode | default, stpt, stal, stpc | Subtarget used for spells aimed at players |
| WeaponSets | Set per job | Picks which group of weapon sets `Weapons` cycles through |
| CraftingMode, CraftQuality, EquipStop, RestingMode | | Crafting and debugging |

### Modes each job file adds (`data/<JOB>.lua`), none bound to a key

| Job | Modes |
|---|---|
| BLM | DeathMode, AutoManawell |
| BLU | LearningMode, AutoUnbridled |
| BRD | ExtraSongsMode, AutoDummyMode, CarnMode, Pianissimode, AutoSongMode |
| BST | AutoFightMode, AutoReadyMode, AutoRewardMode, AutoCallPet, PetMode, RewardMode, JugMode |
| COR | CompensatorMode, RollMode, AutoAmmoMode, UseDefaultAmmo, TrueShotMode, LuzafRing |
| DNC | MainStep, CycleStep, AutoPrestoMode, AutoStepMode, DanceStance |
| DRG | Stance, AutoBondMode |
| DRK | Stance, DrainSwapWeaponMode |
| GEO | ShowDistance, AutoEntrust, UnlockGeomancy, CombatEntrustOnly, AutoGeoAbilities |
| MNK | AutoBoost |
| NIN | Stance, ElementalMode |
| PLD | Stance, CurrentStep, AutoEmblem, AutoCover, AutoMajesty |
| PUP | PartyChatWS, PetMode, AutoManeuvers, AutoPuppetMode, AutoRepairMode, AutoDeployMode, AutoPetMode, PetWSGear, PetEnmityGear |
| RDM | BuffWeaponsMode, MurgleisMode |
| RNG | AutoAmmoMode, UseDefaultAmmo, TrueShotMode |
| RUN | Stance, Steps |
| SAM | Stance |
| SMN | PactSpamMode, AutoFavor, AutoConvert |
| WAR | Stance, ConquerorMode |
| WHM | AutoCaress, AutoCelerity, Gambanteinn, BlockLowDevotion, ElementalMode |

Vanar's gear files add ExtraMeleeMode (BLU, THF), JobMode (BLU), AmbushMode (THF) and BuffWeaponsMode (RDM).

---

## This repository

* `data/Vanar/` holds Vanar's notes: `Vanar_gear_list.md`, the gear Vanar's job files use, and the files it links: `Vanar_notes.md` (the player's rules for the sets, the ranks the player has given, merits, job points, Master Levels and nation), `Vanar_gear_notes.md` (notes on Vanar's copies) and `Vanar_rank_augments.md` (Vanar's path and rank for each path-augmented item). The job files themselves and the RahvinGS engine they include are on the `rahvin` branch.
* `docs/ffxi-mechanics.md` explains the game mechanics the gear sets rely on: casting time, recast, haste, accuracy and attack, magic accuracy, enhancing and enfeebling magic, magic damage, Cure, blue magic and weapon skills.
* `docs/gear-notes.md` records what an item's text and the export don't show, for any copy of the item: hidden values, set bonuses, conditions and slot or hand restrictions.
* `docs/rank-augments.md` gives the augment values at every rank for the exports' path-augmented gear (Nyame, Bunzi's, Gleti's and the other "Path:" items), taken from bg-wiki's rank tables.
* The three files under `docs/` hold for any character and name none. What holds for one character is in that character's folder under `data/`.
* `.claude/agents/gear-optimizer.md` is a Claude Code agent that builds and reviews gear sets from the export, the docs above and the character's own notes. `.claude/tools/` holds the .NET file-based apps it checks its work with (`.claude/tools/README.md`): they list what the character owns, check a job file against the export, and keep the gear list and the docs in step. They need the .NET 10 SDK, and keep what they download in `.claude/cache/`, which git ignores. The tools that read job files or the gear library need the RahvinGS engine at `data/common/RahvinGS/`, which this branch doesn't include.
* This branch (`selindrile`) also carries [Selindrile/GearSwap](https://github.com/Selindrile/GearSwap): the `libs/Sel-*` engine, the job files in `data/`, and the `data/Mytha/` gear files. `data/Vanar/Vanar_{Rdm,Blu,Thf}_Gear.lua` are copies of Mytha's. `.claude/selindrile-upstream.md` records the upstream commit the files came from and how to bring in later ones.

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
* gs stash <jobs> [unused] : Reads the file GearSwap would load for each job listed, such as `gs stash BLU RDM`, and moves the gear their sets use out of wardrobe and wardrobe2, into the first of case, sack, safe, safe2, storage and locker with room. With "unused", it moves everything else out of the two wardrobes instead. Equipped pieces stay. It stops with a message when every stash bag in reach is full.
* gs pull <jobs> : Reads the same files and moves the gear their sets use into wardrobe, then wardrobe2, from every other bag in reach, taking only the copies the wardrobes lack. The inventory, satchel, sack, case and wardrobes 3 to 8 are in reach anywhere; safe, safe2, storage and locker are in reach in the Mog House, and all but storage at a Nomad or Pilgrim Moogle. It stops with a message when both wardrobes are full.
* gs e, gs x and gs t are short for gs equip, gs export and gs test.

Purpose: To assist in the micromanaging of equipment!

Settings Files:  
There is no settings file for GearSwap.

Additional Assistance:
The Windower/addons/GearSwap/beta_examples_and_information folder has a file in it named Variables.xlsx that gives more specific information. If that is insufficient, you can go to BlueGartr's FFXI section or FFXIAH and ask for more assistance.
