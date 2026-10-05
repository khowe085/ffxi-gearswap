# Vanar: notes

What only holds for Vanar: the player's rules for these sets, the ranks the player has given, Vanar's jobs, merits and nation, and what the mechanics give at those values. How the game works is in [ffxi-mechanics.md](../../docs/ffxi-mechanics.md), and what holds for any copy of an item in [gear-notes.md](../../docs/gear-notes.md). Notes on Vanar's own copies are in [Vanar_gear_notes.md](Vanar_gear_notes.md), the path and rank of each path item in [Vanar_rank_augments.md](Vanar_rank_augments.md), and every piece the job files wear in [Vanar_gear_list.md](Vanar_gear_list.md). A fact the player gave is marked **(player, date)**.

## Rules for these sets

The player gave these rules for Vanar's sets. They are recorded here so they don't have to be explained again.

- Stat priority: accuracy, then magic accuracy, weapon skill damage, attack, magic attack and damage taken. Skip pieces that only add a secondary stat (STR, DEX, VIT, AGI, INT, MND, CHR).
  - **(player, 2026-10-02)** Optimizing for INT and MND is fine; just don't bring in dedicated pieces for it.
- Enhancing magic: skill to about 500, then duration over recast.
  - Refresh: Refresh +X, then duration, then recast.
    - **(player, 2026-10-02)** Terms: "Refresh +X" is MP the wearer receives passively each tick while the item is equipped. "Refresh potency" is a bonus to the recipients of a Refresh spell the player casts.
    - **(player, 2026-10-02)** When casting Refresh, prioritize Refresh potency gear. When idling, focus on passive refresh (Refresh +X).
    - So for the cast, the rule's first term is "Refresh" potency (Refresh), then duration, then recast. Refresh +X goes in idle sets.
  - Regen: Regen +X, then duration, then recast.
  - Temper, Temper II and the Enspells: as much skill as possible, with weapon swaps.
    - **(player, 2026-10-02)** Temper II's 700-skill cap (40%) is hard to reach, so it is in effect uncapped. The rule stands: as much skill as possible.
- Regen, Refresh, Temper and Enspell potency come first. Stoneskin potency and casting time are also priorities.
- No Enspell gear that has to stay on while meleeing; only gear for the cast.
- **(player)** Avoid Quick Magic pieces such as Impatiens and Perimede Cape. Witful Belt is the exception, because nothing else replaces its Fast Cast.
- Inventory: at most 160 unique pieces across BLU and RDM, ideally about 140.

## Ranks

The ranks the player has given, under the name the export prints. `//gs export` shows a path but never a rank. `.claude/tools/rank-doc.cs` reads this table and writes [Vanar_rank_augments.md](Vanar_rank_augments.md), which gives the augments at each rank and also lists the path items with no row here.

| Item | Path | Rank | Given |
|---|---|---|---|
| Nyame Helm | B | 11 | 2026-10-04 |
| Nyame Mail | B | 20 | 2026-10-04 |
| Nyame Gauntlets | B | 10 | 2026-10-04 |
| Nyame Flanchard | B | 11 | 2026-10-04 |
| Nyame Sollerets | B | 20 | 2026-10-04 |
| Forfend +1 | A | 15 | 2026-10-04 |
| Coiste Bodhar | A | 20 | 2026-10-04 |
| Alabaster Earring | A | 2 | 2026-10-04 |
| Fi Follet Cape +1 | A | 11 | 2026-10-02 |
| Obstin. Sash | A | 20 | 2026-10-04 |
| Sailfi Belt +1 | A | 14 | 2026-10-04 |

- **(player, 2026-10-04)** The Nyame Helm and Flanchard went from rank 2 to rank 11 on 2026-10-04.
- **(player, 2026-10-04)** Every Bunzi's and Gleti's piece, `Bunzi's Rod` and `Gleti's Knife` included, and `Kentarch Belt +1` aren't augmented yet: rank 0, with base stats only. `Demers. Degen +1`, `Kustawi +1`, `Marin Staff +1` and `Tanmogayi +1` aren't used.
- **(player, 2026-10-02)** The other ranks aren't worth listing, because they change often. Ask the player when a set decision turns on one.
- The unrecorded ones are the path items that export a "Path:" line: `Murky Ring`, and `Dls. Torque +1`, `Mirage Stole +2` and `Tizona` (Path A, so Level 119 III). `Almace` and `Pukulatmuj +1` export with no augments, so they are rank 0, and Almace's stage is unknown.

## Jobs, Master Levels and nation

- **(player, 2026-10-02)** Vanar's RDM and BLU are both Master Level 25. Each has 2,100 job points, so both are mastered: every job point category at 20 and every gift.
- At Master Level 25 the support job is level 54 (49 + floor(25 ÷ 5)).
- **(player, 2026-10-02)** Vanar is a citizen of Windurst. What that turns on and off is under [Enhancing magic: Refresh](#enhancing-magic-refresh) below.
- Nothing is recorded for Vanar's THF beyond its job file: no Master Level, merits or rules of its own.

## Merits

- **(player, 2026-10-02, changed)** RDM Group 2: Enhancing Magic Duration 5 and Magic Accuracy 5. That is all 10 levels the group allows (5 + 5 = 10), so Enfeebling Magic Duration, Accuracy, Immunobreak Chance and En-spell Damage are 0.
- **(player, 2026-10-02)** RDM Group 1: Ice and Earth magic accuracy. The player named the two categories, not the levels in each.
- **(player, 2026-10-02)** Magic Skills: 8 levels each in Healing, Enhancing, Enfeebling, Elemental and Dark magic.
- **(player, 2026-10-02)** Combat Skills: 8 levels each in Dagger, Sword and Club.
- **(player, 2026-10-02)** BLU: 5 levels each in Physical Potency, Magical Accuracy, Diffusion and Enchainment.
- The player listed no other magic or combat skill, so count no merits in Divine or Blue magic.
- Combat Skills merits also cover defensive skills such as Evasion, Parrying and Shield ([Merit Points](https://www.bg-wiki.com/ffxi/Merit_Points)). Read the same way, the player's list has none there, so count no merits in Evasion, Parrying or Shield. Their caps are in [ffxi-mechanics.md](../../docs/ffxi-mechanics.md#combat-skill).

### What the merits add

What the merits above add. Values are from bg-wiki's [Merit Points](https://www.bg-wiki.com/ffxi/Merit_Points) page unless a link says otherwise.

- **Skill merits.** Magic Skills and Combat Skills merits add +2 skill a level, so 8 levels add 16 (8 × 2). General merits carry across jobs, but only to skills the job has. BLU has no Dagger skill, so the dagger merits do nothing on BLU.
- **Group limits.** A job's Group 1 and Group 2 each take at most 5 levels per category and 10 levels in all (the page's category table).
- **RDM Group 1.** Each level adds magic accuracy to that element's spells: +2 on Merit Points, +3 on the [Red Mage](https://www.bg-wiki.com/ffxi/Red_Mage) page.
  - The level counts aren't recorded. Only if all 10 levels are in Ice and Earth does the 5-level cap force 5 in each. Then each element gets +10 (5 × 2), or +15 (5 × 3) by the Red Mage page. Treat that split as an assumption.
  - Ice covers Distract III, and Paralyze and Bind per the [Community Red Mage Guide](https://www.bg-wiki.com/ffxi/Community_Red_Mage_Guide). Earth covers Slow II and Break. Frazzle III is Dark, so neither merit helps it. (bg-wiki: [Distract III](https://www.bg-wiki.com/ffxi/Distract_III), [Slow II](https://www.bg-wiki.com/ffxi/Slow_II), [Break](https://www.bg-wiki.com/ffxi/Break), [Frazzle III](https://www.bg-wiki.com/ffxi/Frazzle_III))
  - No Vitiation augment reads Group 1. The relic augments read Group 2 only; see [Viti. Chapeau +4](../../docs/gear-notes.md#viti-chapeau-4), [Viti. Gloves +4](../../docs/gear-notes.md#viti-gloves-4) and [Viti. Boots +4](../../docs/gear-notes.md#viti-boots-4).
- **RDM Group 2.** Enhancing Magic Duration 5 and Magic Accuracy 5 fill the group (5 + 5 = 10), so Enfeebling Magic Duration, Accuracy, Immunobreak Chance and En-spell Damage are 0. The Magic Accuracy merit is +25 (5 × 5) on every spell.
- **BLU Group 1.** Physical Potency 5 and Magical Accuracy 5 fill the group (5 + 5 = 10), so Chain Affinity Recast, Burst Affinity Recast and Monster Correlation are 0.
  - Physical Potency: +2 "Blue Magic Accuracy" and +4/256 attack a level, so +10 (5 × 2) and +20/256 attack (about 7.8%). The Community Blue Mage Guide gives it only as attack, at the same rate.
  - Magical Accuracy: +2 magic accuracy for blue magic a level, so +10 (5 × 2).
- **BLU Group 2.** Diffusion 5 and Enchainment 5 fill the group (5 + 5 = 10), so Convergence and Assimilation are 0.
  - Convergence is a merit ability, so Vanar's BLU doesn't have it ([Convergence](https://www.bg-wiki.com/ffxi/Convergence)).
  - With no Assimilation, BLU has 55 + 20 (Blue Magic Point Bonus job points) = 75 set points, not 80 ([Blue Mage](https://www.bg-wiki.com/ffxi/Blue_Mage)).
  - Diffusion: each level after the first adds 5% buff duration, so +20% at 5 ((5 − 1) × 5%) ([Diffusion](https://www.bg-wiki.com/ffxi/Diffusion)). Luhlaza Charuqs +1 adds more; see [its entry](../../docs/gear-notes.md#luhlaza-charuqs-1).
  - Enchainment: +100 TP Bonus for Chain Affinity a level, so +500 (5 × 100) ([Enchainment](https://www.bg-wiki.com/ffxi/Enchainment)). Luhlaza Jubbah +1 adds more; see [its entry](../../docs/gear-notes.md#luhlaza-jubbah-1).

Vanar's skill caps at Master Level 25, before gear and before a weapon's own skill:

| Job and skill | Level 99 | Job point gifts | Master Levels | Merits | Total |
|---|---|---|---|---|---|
| RDM Enhancing | 404 | +36 | +25 | +16 | 481 |
| RDM Enfeebling | 424 | +36 | +25 | +16 | 501 |
| RDM Elemental | 378 | none | +25 | +16 | 419 |
| RDM Healing | 368 | none | +25 | +16 | 409 |
| RDM Dark | 300 | none | +25 | +16 | 341 |
| RDM Divine | 300 | none | +25 | none | 325 |
| RDM Sword | 398 | none | +25 | +16 | 439 |
| RDM Dagger | 398 | none | +25 | +16 | 439 |
| RDM Club | 334 | none | +25 | +16 | 375 |
| BLU Sword | 424 | none | +25 | +16 | 465 |
| BLU Club | 388 | none | +25 | +16 | 429 |
| BLU Blue magic | 424 | +36 | +25 | none | 485 |

- Sources: the skill tables on bg-wiki's [Red Mage](https://www.bg-wiki.com/ffxi/Red_Mage) and [Blue Mage](https://www.bg-wiki.com/ffxi/Blue_Mage) pages, where the job mastery column is level 99 plus the gifts; [Master Levels](https://www.bg-wiki.com/ffxi/Master_Levels), +1 to every skill cap the job has per level; Merit Points, +2 a level.
- Of these skills, only RDM's enhancing and enfeebling and BLU's blue magic have skill gifts, +36 each ([ffxi-mechanics.md](../../docs/ffxi-mechanics.md#skill-by-magic-type)). Neither job's gifts add combat skill ([ffxi-mechanics.md](../../docs/ffxi-mechanics.md#combat-skill)).
- These are caps. They assume each skill is leveled to its cap; the in-game Skills menu shows the real value.
- The player's 480 enhancing at Master Level 24 fits: 404 + 36 + 16 + 24 = 480. With the merits now recorded, the 481 at Master Level 25 no longer rests on assuming 8 enhancing merits.
- An item-level weapon adds its own skill to its own hand. For example, a Naegling hand is 439 + 250 = 689 on RDM and 465 + 250 = 715 on BLU, while a Thibron hand, with no skill of its own, stays at 439 or 465, under 600 ([ffxi-mechanics.md](../../docs/ffxi-mechanics.md#combat-skill)).

## bg-wiki's simulated sets against Vanar's gear

bg-wiki's simulated sets (All Jobs Gear Sets) assume stronger Odyssey copies than Vanar's (player, 2026-10-04). What the sets assume is in [ffxi-mechanics.md](../../docs/ffxi-mechanics.md#simulated-sets-bg-wiki-all-jobs-gear-sets), and values per rank are in [rank-augments.md](../../docs/rank-augments.md).

| Piece | Sims | Vanar | What Vanar's copy lacks next to the sim's |
|---|---|---|---|
| Nyame Mail, Sollerets | rank 25, Path B | rank 20, Path B | Each: 5 Attack, 2% WSD, 2% Double Attack, and the fourth line (Mail STR and VIT +5, Sollerets Accuracy +8) |
| Nyame Gauntlets | rank 25, Path B | rank 10, Path B | Attack 15 (of 30), WSD 5% (of 10%), Double Attack +4%, VIT +10 |
| Nyame Helm, Flanchard | rank 25, Path B | rank 11, Path B | Attack 14 (it has 16 of 30), WSD 5% (it has 5% of 10% and 6% of 11%), Double Attack +4% and +5%, and the fourth line (Helm Accuracy +5, Flanchard STR +10) |
| Bunzi's Robe | rank 30 | rank 0 | PDL +8%, Attack and Magic Damage +30, Accuracy and Magic Accuracy +15, DEX +5 |
| Bunzi's Gloves | rank 30 | rank 0 | Magic burst damage II +6, Attack and Magic Damage +30, Accuracy and Magic Accuracy +15, MND +5 |
| Bunzi's Hat | rank 30 | rank 0 | Store TP +8, Quadruple Attack +3%, Attack and Magic Damage +30, Accuracy and Magic Accuracy +15 |
| Bunzi's Rod | rank 30 | rank 0 | Magic Attack Bonus +30, Accuracy and Magic Accuracy +15, DMG +11 |
| Gleti's Cuirass, Gauntlets, Breeches, Boots | rank 30 | rank 0 | Each: Attack +30, Accuracy and Magic Accuracy +15. Plus Cuirass Double Attack +10%, Gauntlets Store TP +8 and DEX +5, Breeches Triple Attack +5%, Boots STR +5. PDL and crit rate are base stats, so Vanar's have them |
| Gleti's Knife | rank 30 | rank 0 | DMG +11, Attack +45, Accuracy and Magic Accuracy +15, Subtle Blow II +10 |

Where that matters:

- RDM's high-buff Death Blossom, Imperator, Requiescat and Black Halo wear Bunzi's Robe. The sim's rank 30 copy adds PDL +8% and Attack +30; Vanar's rank 0 copy has neither augment (its base Attack +40 and MND +43 remain).
- Nyame Gauntlets are in six RDM mid-buff sets, and in BLU Expiacion (mid), Imperator and Savage Blade (both). Vanar's rank 10 pair has WSD +5% of the sim's +10%, and none of its Double Attack.
- Nyame Flanchard is in all 16 RDM physical non-crit sets and 6 of the 8 BLU ones, and Nyame Sollerets in 6 of the 8 BLU ones. Vanar's rank 20 Sollerets are 2% WSD and 5 Attack short. The rank 11 Flanchard is 5% WSD, 14 Attack and all 5% of the Double Attack short.
- Bunzi's Rod (RDM nukes, Sanguine Blade on both jobs) is 30 Magic Attack Bonus short. Bunzi's Gloves in the RDM magic burst set lack their magic burst damage II. Bunzi's Hat in the RDM TP set lacks its Store TP and Quadruple Attack.
- Gleti's in the BLU sets keep their PDL at rank 0 but are 30 Attack and 15 Accuracy short each.
- So the pages overvalue these pieces for Vanar. A substitution needs the lost values from rank-augments.md weighed against the next piece; the page totals can't be corrected by hand. The simulator has rank 0, 15, 20, 25 and 30 versions of each Nyame, Bunzi's and Gleti's piece and of Coiste Bodhar, and each Nyame path (IzaKastra/wsdist_beta, gear.py), so a run at Vanar's ranks is the clean check. It has no entry for a Nyame piece at rank 10 or 11, and Alabaster Earring and Murky Ring (R30), Sailfi Belt +1 (R15), Mirage Stole +2 (R25) and Dls. Torque +1 (R20) have only their max-rank entry, so each of those needs an edited dict ([wsdist data errors](../../docs/ffxi-mechanics.md#wsdist-data-errors)).
- A data error, as one sign of the unknown quality: the simulator's rank 0 Bunzi's Rod has DMG 152 (144+8), but the item's own text says DMG 144 (IzaKastra/wsdist_beta, gear.py; bg-wiki, Bunzi's Rod; the item's help text). More under wsdist data errors.

Gear in the sets that Vanar doesn't own, most-used first:

- RDM: Crepuscular Pebble (every high-buff non-crit physical set), Hoxne Earring (10 weapon skills), Sroda Ring (7), Malignance Gloves (6), Sroda Tathlum (6), Malignance Earring (5), Orpheus's Sash (5), Dls. Torque +2 (4; Vanar has the +1), Metamor. Ring +1 (4). Weapons: Caliburnus, Excalibur, Mandau, Murgleis, Crocea Mors, Sequence, Daybreak, Sakpata's Sword, Crepuscular Knife.
- BLU: Hoxne Earring (6 weapon skills), Beithir Ring (4), Crepuscular Pebble (4), Sroda Ring (3), the Sworn armor in the TP and Requiescat sets, and the Adhemar pieces. Weapons: Caliburnus, Sequence, Archduke's Sword, Ice Brand, Zantetsuken, Sakpata's Sword.
- Capes. Vanar's augmented Sucellos's Capes are STR/WSD, DEX/Double Attack, MND/Magic Accuracy/Haste and INT/Magic Accuracy/Magic Attack Bonus. The sims also use MND/WSD (Requiescat, Sanguine Blade, high-buff Black Halo), DEX/WSD (high-buff Imperator), INT/WSD (Aeolian Edge), DEX/crit (Chant du Cygne, Evisceration) and DEX/Store TP (TP). Vanar's Rosmerta's Capes are STR/WSD, DEX/crit, DEX/Double Attack and INT/Magic Accuracy/Magic Attack Bonus. The sims also use INT/WSD (Sanguine Blade, Red Lotus Blade), MND/Double Attack (Requiescat), DEX/WSD (high-buff Imperator), DEX/Store TP and DEX/Dual Wield (TP).
- The pages assume upgraded relic, mythic and empyrean weapons ("Level 119 III") and stage 4 primes. Vanar's Tizona is Level 119 III like the sims', since it exports "Path: A". The export can't show the stage of his Almace or Mpu Gandring; ask the player.

## What the mechanics give at Vanar's values

Vanar's numbers under the formulas in [ffxi-mechanics.md](../../docs/ffxi-mechanics.md). Each heading names the section of that doc the lines belong to.

### Casting time: BLU's Fast Cast trait

- Vanar's BLU is Master Level 25, so its /RDM is level 54 and gives Fast Cast 15%, and it has both Job Trait Bonus gifts.

### Casting time: Fast Cast the item text doesn't show

- **(player, 2026-10-02)** Vanar's Fi Follet Cape +1 is Path A at rank 11: Fast Cast 8%, Spell interruption rate −3%.

### Haste and Dual Wield: Dual Wield

- Vanar's RDM and BLU are Master Level 25, so their support jobs are level 54: no Dual Wield tier past what level 49 gives.

### TP gain and Store TP

- Vanar's Bunzi's Hat and Gleti's Gauntlets are rank 0, so they have no Store TP.

### Multi-attack

- At Vanar's ranks: the Nyame Path B Sollerets (+2%) and Mail (+3%) at rank 20 give Double Attack; the Helm and Flanchard at rank 11 and the Gauntlets at rank 10 give none, since Path B's Double Attack starts at rank 16. Every Bunzi's and Gleti's piece is rank 0, so Bunzi's Hat has no Quadruple Attack, Gleti's Cuirass no Double Attack and Gleti's Breeches no Triple Attack. Bunzi's Gloves (RDM) keep their base Double Attack +8%.

### Subtle Blow

- Vanar's Gleti's Knife and Gleti's Breeches are rank 0, so the Knife has no Subtle Blow II and the Breeches none of their augment's Subtle Blow.

### Skill and accuracy: Combat skill

- Vanar's Bunzi's Rod and Gleti's Knife are rank 0: they have their base skill and none of the rank augments.

### Skill and accuracy: Sword skill past 600 (disputed)

- The worked sword skill figures are Vanar's: Master Level 25 and 8/8 sword merits (player, 2026-10-02). They assume Vanar's Almace is at least Level 119, which the export doesn't show.

### Attack and pDIF: Physical damage limit

- Vanar's Bunzi's Robe is rank 0, so it has no PDL, and Vanar's Nyame pieces are Path B, which adds none. Vanar's rank 0 Gleti's pieces have their base PDL in full.

### Weapons and TP: Which hand a weapon's stats work from

- Vanar's RDM Chant du Cygne weapon mode puts Gleti's Knife in the off hand, so wsdist's crit pooling overstates the main-hand crits there.

### Weapon skills: Weapon skill damage (WSD)

- Nyame Path B's WSD at Vanar's ranks **(player, 2026-10-04)**: Helm (rank 11) +5%, Mail (20) +10%, Gauntlets (10) +5%, Flanchard (11) +6%, Sollerets (20) +8%, 34% for the five.

### Magic accuracy: Macc needed to cap

- The example is Vanar's RDM: 501 enfeebling skill, +115 always on, and 10 to 15 less to find on Ice and Earth spells (assumed 5 levels in each).

### Magic accuracy: Skill by magic type

- Vanar's RDM before gear: enfeebling 501, elemental 419, dark 341, enhancing 481 and healing 409, each with 8 merit levels, and divine 325 with none. Vanar's BLU: blue magic 485, with no merits (player, 2026-10-02).

### Magic accuracy: Job sources

- Vanar's RDM has 5 levels in Magic Accuracy (player, 2026-10-02, changed), so its always-on total is the full +115.
- **(player, 2026-10-02)** Vanar's RDM Group 1 merits are Ice and Earth Magic Accuracy. The level count isn't recorded: only if all 10 levels are in Ice and Earth does the 5-level cap force 5 in each, and these notes assume that. So on Ice and Earth spells Vanar's always-on total is 125 to 130. Gravity, Silence, Sleep, Frazzle, Dia, Addle, Blind, Poison and the other nukes get only the 115.
- Vanar's BLU has 5 Magical Accuracy merits (player, 2026-10-02): +66 always on for magical blue magic.

### Magic accuracy: Odyssey augments below rank 30

- Three of Vanar's Odyssey pieces have augment macc at the ranks the player gave **(player, 2026-10-04)**: Forfend +1 (rank 15) and Obstin. Sash (rank 20) have Mag. Acc.+15 each, and Alabaster Earring (rank 2) has Mag. Acc.+2. No other piece in [Vanar_rank_augments.md](Vanar_rank_augments.md) has any: the Nyame pieces are Path B, and every Bunzi's and Gleti's piece is rank 0. The one unknown is Murky Ring, whose rank isn't recorded.

### Enhancing magic: Enhancing skill

- Vanar's Forfend +1 is rank 15, so it has the full Enhancing magic skill +10 **(player, 2026-10-04)**. Vanar's RDM has 481 enhancing skill before gear at Master Level 25.

### Enhancing magic: Enspells

- Vanar's Demersal Degen +1 and Pukulatmuj +1 are rank 0, so neither has its Enspell damage % augment.
- Vanar has 0 En-spell Damage merits (player, 2026-10-02), so the Enspell base gets only the gifts' +23, and the Vitiation Tights' augment adds nothing.

### Enhancing magic: Enhancing duration

- Vanar's RDM has 5 levels of Enhancing Magic Duration (player, 2026-10-02, changed) and the job point category at 20: 50 flat seconds, or 65 with Vitiation Gloves.

### Enhancing magic: Refresh

- **(player, 2026-10-02)** When casting Refresh, prioritize Refresh potency gear. When idling, focus on passive refresh (Refresh +X).
  - So the Refresh midcast set takes the potency table above first; Atrophy Tabard +4 counts there for its potency +2, not its "Refresh"+3. Idle sets take "Refresh"+N.
- **(player, 2026-10-02)** Vanar is a citizen of Windurst.
  - So Sibyl Scarf's `Citizen of Windurst: "Refresh"+1` works for him in idle sets; its INT +10 and MAB +10 work anywhere (item text).
  - His other nation latents don't: Elite Royal Collar's `Citizen of San d'Oria: "Regen"+3` and Rep. Plat. Medal's `Citizen of Bastok: "Regain"+2`. Their other stats still apply (item text; gear-notes.md). These three are the only nation latents in his exported items.

### Enhancing magic: Stoneskin

- Vanar's BLU, at Master Level 25, has a level 54 subjob, so it can't cast Stoneskin as /RUN, which needs level 55.

### Spell interruption

- Vanar's Fi Follet Cape +1 is rank 11, so its Spell interruption rate is −3% (player, 2026-10-02).

### Enfeebling magic: Enfeebling skill

- Vanar's RDM is that case (player, 2026-10-02): 501 enfeebling skill before gear, so gear needs +109 for Distract III's cap and +124 for Frazzle III's.
- Vanar's Obstinate Sash is rank 20 **(player, 2026-10-04)**: Magic Accuracy +15 and enfeebling skill +5.

### Enfeebling magic: Enfeebling duration

- Vanar's RDM has 0 levels of Enfeebling Magic Duration (player, 2026-10-02, changed), so the flat seconds are the job points' 20, with or without the relic head.

### Enfeebling magic: Immunobreak

- Vanar has 0 Immunobreak Chance levels (player, 2026-10-02), so the merit and the relic boots' augment add nothing.

### Magic burst: Burst damage

- None of Vanar's Nyame or Bunzi's pieces has Magic burst damage II: the Nyame are Path B and every Bunzi's piece is rank 0 **(player, 2026-10-04)**. Vanar's five rank 0 Bunzi's armor pieces still carry their base +150 MAB and +150 Magic Damage.

### Blue magic: Job points and merits

- **(player, 2026-10-02)** Vanar's BLU merits: 5 in Physical Potency, 5 in Magical Accuracy, 5 in Diffusion, 5 in Enchainment. That fills both groups, so Vanar has no Convergence and no Assimilation, and 75 set points.

### Blue magic: Chain Affinity, Burst Affinity, Efflux and Azure Lore

- Vanar has 5 Enchainment levels (player, 2026-10-02): +500, and +750 with Luhlaza Jubbah +1 on.

### Blue magic: Convergence, Diffusion and Unbridled Learning

- Vanar has 5 Diffusion levels (player, 2026-10-02) and Luhlaza Charuqs +1: +45%, so Vanar's Mighty Guard lasts 5:13.

### Community Red Mage Guide sets: What the guide assumes

- The guide assumes 2100 job points, full merits and Master Level 30. Vanar's RDM has the 2100 job points but is Master Level 25, so each of its skills is 5 below the guide's figures. Vanar has 8/8 merits in sword, dagger, club, enhancing, enfeebling, elemental, dark and healing (player, 2026-10-02), so in those the guide's full merits match and the gap is the 5.
- Vanar's Bunzi's and Gleti's pieces, both weapons included, are rank 0: base stats only. Vanar's Marin Staff +1 exports with no augments (rank 0).
- Against the guide's Group 2 merits: Vanar (player, 2026-10-02, changed) has all 5 of its Magic Accuracy levels and none of its Immunobreak Chance; the other 5 levels (10 − 5) are in Enhancing Magic Duration.
- Against the guide's Group 1 merits: Vanar's are Ice and Earth (player, 2026-10-02). Vanar shares the guide's Ice; in place of Wind, Earth covers Slow, Slow II and Break. So Gravity and Silence get none of the guide's +15 Wind merit macc.

### Community Red Mage Guide sets: Enfeebling sets

- The rule to skip pieces that add only an attribute still applies to the guide's MND and INT sets.

### wsdist (Kastra's damage simulator): What it models

- wsdist's built-in merits against Vanar's: they match in sword, dagger, club, elemental and dark. wsdist also adds +16 to divine and blue magic skill, where Vanar has no merits, and to evasion, which isn't among Vanar's combat skill merits. Vanar's crit rate merits aren't recorded.
- wsdist's RDM merits against Vanar's: its Group 1 +15 fits only Vanar's Ice and Earth spells (at an assumed 5 levels and +3 a level), its 5/5 Group 2 Magic Accuracy matches, and its 5/5 En-spell Damage (+15) is 15 more than Vanar's 0.
- Vanar's Requiescat merit level isn't recorded (at least 1, since Vanar uses it).
