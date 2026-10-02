# FFXI gearing mechanics

How the game handles fast cast, casting time, recast, skill, accuracy and the other numbers gear sets are built around. This page records how things work, not which gear any job file uses. It was written while building Vanar's BLU and RDM files, so the examples come from those two jobs.

**Sources.** bg-wiki is the main source. Its bot check blocks automated reads, so its pages were read through search-engine extracts rather than directly. FFXIclopedia was read directly through its API. Rules that came from the player are marked **(player)**. Where sources disagree, both sides are given. Links are at the end.

## Casting time

### Fast Cast

- Fast Cast shortens casting time by its percentage. All sources add together: job traits, job point gifts and gear.
- Casting time reduction caps at 80%.
- Casting time is set when the cast starts, so for casting time, Fast Cast only has to be worn in the precast set. Recast is different; see below.

| Source | Fast Cast |
|---|---|
| RDM trait, Fast Cast I to V (levels 15, 35, 55, 76, 89) | 10, 15, 20, 25, 30% |
| RDM job point tiers, Fast Cast VI to IX (IX at 2000 job points spent) | 2% more each, up to 38% |
| BLU trait from set blue magic, tiers 0 to IV | 5, 10, 15, 20, 25% |

- A mastered RDM has Fast Cast IX, 38% before gear, so 42% from gear reaches the cap.
- BLU has no Fast Cast of its own. It gets the trait from set blue magic: Erratic Flutter on its own, or two of Bad Breath, Sub-zero Smash, Auroral Drape and Wind Breath. Setting more of them raises the tier. The tier changes with the spell set, so check the job traits list in game.
- Some item text only says `Enhances "Fast Cast" effect`, with no number. FFXIclopedia has the values: Chelona Boots 4%, Swith Cape 3%, Estoqueur's Earring 2% and Augur's Gaiters 2%. A scan of item descriptions misses these pieces.

### Spell-specific and school casting time

Separate stats shorten the casting time of one spell or one school of magic:

- "Cure spellcasting time −X%" and "Healing magic casting time −X%". Cure spellcasting time on gear Vanar owns: Doyen Pants −15%, Vanya Clogs (Path D) −15%, Pahtli Cape −8%, Serenity (augmented) −8%, Vanya Cuffs (Path B) −7% and Mendi. Earring −5%. The engine wears `sets.Precast.Cure` for every spell named Cure, Cura or Curaga, over the fast-cast set.
- "Song spellcasting time −X%"
- "Enhancing magic casting time −X%", for example Siegel Sash −8%
- "Stoneskin casting time −X%", for example Pukulatmuj −10%, Pukulatmuj +1 −11% and Doyen Pants −10%

This gear adds to Fast Cast for casting time, but it doesn't shorten recast. bg-wiki says so outright for songs.

Light Arts and Dark Arts are different: they shorten both casting time and recast by 10% for their own school, and lengthen the other school's casting time by 20%.

### Does anything break the 80% cap? (disputed)

- **(player)** School and spell-specific casting time gear breaks the 80% Fast Cast cap.
- **bg-wiki** (search extracts) says they share the 80% cap with Fast Cast:
  - The Cure page says all these effects together "cannot go past the hard cap of 80%".
  - The Song Spellcasting Time page says "the combined cap of Song Spellcasting Time and Fast Cast is still 80%".
  - The only gear it lists past 80% is Scholar's Grimoire spellcasting time gear (Pedagogy Mortarboard +3, Academic Loafers +3), which works as a separate multiplier.
- A precast set that reaches 80% with Fast Cast alone, and adds spell-specific pieces only in slots that cost no Fast Cast, is correct under either reading.

### Quick Magic

- Quick Magic gives a chance to cast instantly with no recast. Gear caps at 10% (bg-wiki).
- With GearSwap, an instant cast can go off before the midcast set is on, so the spell may land in precast gear. This is common GearSwap advice, not checked against a source.
- **(player)** Avoid Quick Magic pieces such as Impatiens and Perimede Cape. Witful Belt is the exception, because nothing else replaces its Fast Cast.

## Recast

bg-wiki, Spell Recast:

```
Recast = initial recast
       × (1 − Haste/1024 + Slow/1024)
       × (1 − floor(Fast Cast % / 2) / 100)
       × job ability modifiers (Composure, Hasso, Scholar abilities)
```

- Fast Cast shortens recast by half its value, rounded down. 80% Fast Cast gives 40% recast.
- **(player)** For recast, 2% Fast Cast is worth 1% haste. This matches the formula.
- Gear haste shortens recast but not casting time.
- Recast reduction caps at 80% in total. Celerity and Alacrity with matching weather can take it to 90%.
- Recast is set when the spell goes off, so the haste and Fast Cast in the **midcast** set are what count. FFXIclopedia: Fast Cast gear "MUST remain equipped to gain the Recast Time effect". Fast Cast that is only in the precast set speeds up the cast, not the recast.
- Composure lengthens spell recast; it is one of the job ability modifiers in the formula.
- FFXIclopedia's Fast Cast page still gives older caps: recast 50%, and 25% from Fast Cast. bg-wiki's 80% and 40% are current.

## Haste and damage taken

- Gear haste is counted in 1/1024 units and caps at 256/1024 (25%).
- **(player)** In practice, the haste listed on gear has to add up to about 26% to reach the cap. Haste past that does nothing.
- Damage taken caps at −50%. Physical damage counts DT + PDT and magic damage counts DT + MDT, each capped at 50%. Anything past the cap does nothing.

## Skill and accuracy

### Combat skill

Accuracy from combat skill (bg-wiki, as pasted by the player):

| Skill | Accuracy from skill |
|---|---|
| up to 200 | skill |
| 201 to 400 | floor((skill − 200) × 0.9) + 200 |
| 401 to 600 | floor((skill − 400) × 0.8) + 380 |
| 601 and up | floor((skill − 600) × 0.9) + 540 |

- Combat skill also adds to attack, one point for one point.
- **(player)** At Master Level 25, BLU and RDM sword skill is past 600. Each point of sword skill on gear is then worth about 0.9 accuracy and 1 attack, so Sword skill +30 is about Acc +27 and Att +30.
- A combat skill only helps attacks with that weapon type. Sword skill gear does nothing while a club is in hand.

### Magic accuracy skill on weapons

- Item level weapons list "Magic Accuracy skill +X", for example +255 on Bunzi's Rod and +250 on Maxentius and Naegling. It adds to magic accuracy one for one **(player, bg-wiki)**.
- Only the main hand's Magic Accuracy skill counts. An offhand weapon's does nothing, so when dual wielding only its plain "Magic Accuracy +X" helps (bg-wiki, Magic Accuracy Skill and Dual Wield).

### Accuracy from set bonuses and abilities

- Atrophy +2, +3 and +4 pieces, and the Regal accessories, give Accuracy, Ranged Accuracy and Magic Accuracy +15, +30, +45 and +60 for 2, 3, 4 and 5 pieces worn.
- Composure (RDM) gives Accuracy +50 at level 99, plus 1 per level of the Composure Effect job point category, up to +70.

## Enhancing magic

### Skill

- Most enhancing spells stop improving at 500 skill:
  - Phalanx: −35 damage at 500.
  - Barspells.
  - Boost and Gain spells: +25 to the stat at 500 or more.
  - Aquaveil: 501 or more blocks 3 spell interruptions.
- Temper, Temper II and the Enspells have no known cap.
  - Temper II's triple attack % is floor((skill − 300) ÷ 10). The Temper II page lists 40% at 700 skill.
- Stoneskin depends on skill and MND; see Potency.
- RDM enhancing skill without gear is 404 at level 99, 420 with the job point skill category and 456 at job mastery. The job point gifts add +5, +8 and +10 at 80, 405 and 980 job points spent.
- **(player)** A RDM 99 at Master Level 24 has 480 enhancing skill without gear, 24 more than bg-wiki's job mastery figure.
- Skill on gear shows as "Enhancing magic skill +X" or "All magic skills +X". Weapons and shields carry it too: Pukulatmuj +1 +11, Forfend +1 Path A +10 at max rank, Secespita +10 and Gada +18.
- A subjob's enhancing skill is far below 500, so on another job, skill still raises potency.
- Potency is set when the spell lands, so skill gear goes in the midcast set.

### Enspells

- Base damage comes from enhancing skill: floor(skill ÷ 9) + 5 below 180 skill, and floor((skill − 180) ÷ 8) + 25 above it.
- Tier I damage is fixed at the cast, from the skill worn then. Skill gear, weapons included, only has to be on while casting.
- Tier II damage is worked out again every attack round, from the skill worn at that moment. Casting gear does nothing for it.
- "Sword enhancement spell damage +n" works during melee rounds, so it has to be worn while attacking. On armor it applies to both hands; on a weapon, only to that weapon.
- Composure triples base Enspell damage and any Enspell +n.

### Duration

bg-wiki, Enhancing Magic (also on the Lethargy set page):

```
Duration = (base + 6s × RDM Group 2 merit + 3s × relic hands merit augment + RDM job points + gear seconds)
         × Composure bonus from the Lethargy set (spells on others)
         × (1 + duration % listed on gear + Naturalist's Roll)
         × (1 + augmented duration %)
         × Rune Fencer gifts
         × Perpetuance
```

- Duration that an item lists natively adds together. Augmented duration, such as Telchine's "Enh. Mag. eff. dur. +10", adds together in its own multiplier. So once some native duration is worn, +20% from an augment is worth more than +20% listed natively.
- Gear that lists seconds adds to the base before any multiplier: Telchine Chasuble (Regen +12s), Grapevine Cape (Refresh +30s), Gishdubar Sash (Refresh received +20s).
- Composure triples the duration of enhancing magic a RDM casts on itself, up to 30 minutes.
- The Lethargy set bonus (+1, +2 and +3; Estoqueur's +2 as well) gives Composure's bonus to enhancing magic cast on others and to enfeebling magic: +10, +20, +35 and +50% for 2, 3, 4 and 5 pieces. Spells you cast on yourself get nothing from it. It counts the pieces worn during the cast.
- Duration and potency gear is read when the spell lands, so it goes in the midcast set.

### Potency

- Refresh II gives 6 MP a tick and Refresh III gives 9, each for 150 seconds before duration gear. "Refresh" potency gear adds MP per tick: Lethargy Fuseau (+1 to +4 by upgrade), Amalric Coif (+1 or +2) and Atrophy Tabard +2 or +3 (+1 or +2).
- "Regen" potency gear, such as Telchine's `"Regen" potency+3` augment, adds HP per tick.
- Stoneskin, as pasted by the player from bg-wiki, where S = skill ÷ 3 + MND:

| S | Damage absorbed |
|---|---|
| below 80 | skill ÷ 3 + MND (bg-wiki says this is likely wrong, since it doesn't meet the next line) |
| 80 to 130 | 2 × skill ÷ 3 + 2 × MND − 60 |
| 130 and up | skill + 3 × MND − 190 |

- Stoneskin caps at 350. "Stoneskin +X" gear goes past the cap, up to 475.
- Siegel Sash's +20 only has to be worn during the cast, and it only works on the Stoneskin spell, not Diamondhide, Metallic Body or Earthen Ward (FFXIclopedia). Its casting time −8% belongs in precast, so it helps in both sets.

## Weapons and TP

- Changing the main, sub or range slot resets TP. Changing ammo doesn't, but ammo that doesn't fit the ranged weapon (anything but an arrow with a bow) unequips the weapon, which does.
- Effects marked "Main hand:", such as Maxentius's Black Halo +50% or Naegling's Savage Blade bonus, only work in the main hand. An offhand weapon's other stats still count, including TP Bonus (Thibron's +1000).
- A weapon in the sub slot needs Dual Wield. BLU only has it from set blue magic, so it changes with the spell set.

## Weapon skills

- Weapon skill damage (WSD) on gear only applies to the first hit. It adds together with job point gifts and Gyudon, and applies to the whole of a magical weapon skill. Belts and gorgets are the exception.
- Elemental gorgets and belts, Fotia included, list "Weapon skill damage +10%", but it is really +25/256 fTP (bg-wiki, Fotia Gorget and Expiacion). A weapon skill whose fTP carries to every hit, such as Chant du Cygne, Evisceration or Requiescat, gets it on every hit, about +10% each. Any other weapon skill gets it on the first hit only, so it adds about 1% to a high-fTP first hit such as Savage Blade's (4 to 13.75) or Expiacion's (3.8 to 12.2) and nothing to the later hits. Fotia's latent works with any weapon skill and also gives weapon skill accuracy +10.
- Bonuses that apply to every hit and multiply: Dragoon's WSD trait, Overwhelm, Building Flourish, and bonuses for one named weapon skill, such as "Savage Blade damage +X%".
- Chant du Cygne's critical hit rate rises with TP: +15, +25 and +40% at 1000, 2000 and 3000 TP.
- The Hashishin set bonus occasionally triples a blue magic spell's weapon skill coefficient, or quadruples it with Chain Affinity or Burst Affinity.

## Treasure Hunter

- A monster's Treasure Hunter level comes from the TH you have when you act on it. Melee rounds, ranged attacks, weapon skills, job abilities and spells all count, misses included: anything that puts you on its enmity list.
- On a main job other than Thief, TH from gear and traits caps at 4.
- Rahvin engine, Tag mode with a `TH_Whitelist` in the job file: only an action on the list (a spell, job ability or weapon skill, by name) or a ranged attack wears TH gear against an untagged monster, and only such an action marks it tagged. Engaging doesn't put TH on, and melee swings don't tag. Listed weapon skills, job abilities and ranged attacks wear it at precast, listed spells at midcast. Without a whitelist, Tag mode puts TH on as soon as you engage an untagged monster, because GearSwap gets no event before an auto-attack, and the first melee round tags it. Full Time keeps TH on while engaged either way. The engine forgets a tag when the monster dies, when you zone, and after three minutes without an action on it.

## Gear and GearSwap

- Leth. Earring +1 and Hashi. Earring +1: their item text says their bonuses only work in the right ear.
- `//gs export` shows a path augment ("Path: A") but not its rank.
- Odyssey gear such as Nyame raises its path augments with rank, up to rank 30. FFXIclopedia lists only rank 30, and bg-wiki's simulated sets assume it. Path B at rank 30: Attack +35, plus weapon skill damage and Double Attack of +13% and +7% on the Mail, +12% and +6% on the Flanchard, and +11% and +5% on the Helm, Gauntlets and Sollerets. At rank 20 (bg-wiki, through search extracts): Attack +25, with +10% and +2% on the Mail, and +8% and +2% on the Flanchard and Gauntlets. Each piece's fourth Path B line (STR, VIT or accuracy) didn't show at rank 20.
- When you own more than one copy of an item, name each copy by its augments, exactly as `//gs export` printed them.
- Rahvin engine: a set named for the exact spell, `sets.Midcast['<spell>']`, replaces the whole enhancing set for that spell. `sets.Midcast.Phalanx`, `.Refresh` and `.Regen` are also the family sets the engine merges over the enhancing set, and over the Others set off self, for every spell of that family. So the spells called Phalanx, Refresh and Regen wear that table alone. If those sets only list the slots they change, the first-tier spells lose all their duration gear; if they are full copies of the enhancing set, casts on others lose the Others set's Lethargy pieces. Keeping them short and putting the enhancing set back for those three spells in `midcast_custom` avoids both.
- Rahvin weapon lock: `Locked` holds the weapon mode's main and sub in every phase, idle and casting included, so idle and casting weapon sets never go on. `Unlocked` frees them out of combat and holds them while engaged, so a cast mid-fight never swaps weapons or costs TP, but it also skips any weapons its set names, such as enhancing skill weapons. The job file sets the starting value with `state.WeaponLock:set(...)`.
- GearSwap hands each `//gs` word it doesn't know to the functions a job file registers with `register_unhandled_command`, and a function that returns true keeps its "Command not found" line out. It does this only while the job file is on, and the Rahvin engine's `gs c test` turns the job file off for its 30 second hold, so a raw `addon command` handler is the only thing that sees a command typed during the hold.
- Rahvin AutoBuff `When`: `Engaged` and `Idle` follow your status (weapons drawn or not). `Combat` and `OutOfCombat` follow Windower's `in_combat` flag, which is on whenever battle music plays, so it is on while you fight a monster without engaging it, for example while nuking it.
- Two identical copies with no augments, such as two Stikini Rings, are safest swapped as a pair. Otherwise GearSwap can try to move the copy already worn in the other slot. Pinning each to its bag, for example `{ bag = "wardrobe" }`, also fixes it.

## Player rules for these jobs

The player gave these rules for Vanar's sets. They are recorded here so they don't have to be explained again.

- Stat priority: accuracy, then magic accuracy, weapon skill damage, attack, magic attack and damage taken. Skip pieces that only add a secondary stat (STR, DEX, VIT, AGI, INT, MND, CHR).
- Enhancing magic: skill to about 500, then duration over recast.
  - Refresh: Refresh +X, then duration, then recast.
  - Regen: Regen +X, then duration, then recast.
  - Temper, Temper II and the Enspells: as much skill as possible, with weapon swaps.
- Regen, Refresh, Temper and Enspell potency come first. Stoneskin potency and casting time are also priorities.
- No Enspell gear that has to stay on while meleeing; only gear for the cast.
- Inventory: at most 160 unique pieces across BLU and RDM, ideally about 140.

## Sources

bg-wiki, read through search extracts:
[Fast Cast](https://www.bg-wiki.com/ffxi/Fast_Cast),
[Spell Recast](https://www.bg-wiki.com/ffxi/Spell_Recast),
[Song Spellcasting Time](https://www.bg-wiki.com/ffxi/Song_Spellcasting_Time),
[Category:Cure Spell](https://www.bg-wiki.com/ffxi/Category:Cure_Spell),
[Casting Time Gauge](https://www.bg-wiki.com/ffxi/Casting_Time_Gauge),
[Community Scholar Guide](https://www.bg-wiki.com/ffxi/Community_Scholar_Guide),
[Category:Enhancing Magic](https://www.bg-wiki.com/ffxi/Category:Enhancing_Magic),
[Temper II](https://www.bg-wiki.com/ffxi/Temper_II),
[Category:Enspell](https://www.bg-wiki.com/ffxi/Category:Enspell),
[Composure](https://www.bg-wiki.com/ffxi/Composure),
[Lethargy Armor Set](https://www.bg-wiki.com/ffxi/Lethargy_Armor_Set),
[Atrophy Armor Set +4](https://www.bg-wiki.com/ffxi/Atrophy_Armor_Set_%2B4),
[Refresh III](https://www.bg-wiki.com/ffxi/Refresh_III),
[Category:Regen Spell](https://www.bg-wiki.com/ffxi/Category:Regen_Spell),
[Category:Boost Spell](https://www.bg-wiki.com/ffxi/Category:Boost_Spell),
[Phalanx](https://www.bg-wiki.com/ffxi/Phalanx),
[Stoneskin](https://www.bg-wiki.com/ffxi/Stoneskin),
[Red Mage](https://www.bg-wiki.com/ffxi/Red_Mage),
[Blue Mage Job Traits](https://www.bg-wiki.com/ffxi/Blue_Mage_Job_Traits),
[Magic Accuracy Skill](https://www.bg-wiki.com/ffxi/Magic_Accuracy_Skill),
[Dual Wield](https://www.bg-wiki.com/ffxi/Dual_Wield),
[Weapon Skill Damage](https://www.bg-wiki.com/bg/Weapon_Skill_Damage),
[Chant du Cygne](https://bg-wiki.com/bg/Chant_du_Cygne),
[Fotia Gorget](https://www.bg-wiki.com/ffxi/Fotia_Gorget),
[Expiacion](https://www.bg-wiki.com/ffxi/Expiacion),
[Treasure Hunter](https://www.bg-wiki.com/ffxi/Treasure_Hunter),
[Nyame Mail](https://www.bg-wiki.com/ffxi/Nyame_Mail),
[Nyame Flanchard](https://www.bg-wiki.com/ffxi/Nyame_Flanchard),
[Nyame Gauntlets](https://www.bg-wiki.com/ffxi/Nyame_Gauntlets).

Windower: [Scoreboard pull request 1264](https://github.com/Windower/Lua/pull/1264), on `in_combat`, through a search extract.

Forums, through search extracts: [Treasure hunter (FFXIAH)](https://www.ffxiah.com/forum/topic/26401/treasure-hunter), [TH Procing (Square Enix)](https://forum.square-enix.com/ffxi/threads/27974).

FFXIclopedia, read directly:
[Fast Cast](https://ffxiclopedia.fandom.com/wiki/Fast_Cast),
[Cast Time](https://ffxiclopedia.fandom.com/wiki/Cast_Time),
[Siegel Sash](https://ffxiclopedia.fandom.com/wiki/Siegel_Sash),
[Doyen Pants](https://ffxiclopedia.fandom.com/wiki/Doyen_Pants),
[Nyame Helm](https://ffxiclopedia.fandom.com/wiki/Nyame_Helm),
[Nyame Mail](https://ffxiclopedia.fandom.com/wiki/Nyame_Mail),
[Nyame Gauntlets](https://ffxiclopedia.fandom.com/wiki/Nyame_Gauntlets),
[Nyame Flanchard](https://ffxiclopedia.fandom.com/wiki/Nyame_Flanchard),
[Nyame Sollerets](https://ffxiclopedia.fandom.com/wiki/Nyame_Sollerets).

**Reading the wikis from an automated session.** bg-wiki answers automated requests with a bot check, and the Wayback Machine and archive.ph connections drop. FFXIclopedia's MediaWiki API works: `https://ffxiclopedia.fandom.com/api.php?action=parse&page=<Page_Name>&prop=wikitext&format=json`.
