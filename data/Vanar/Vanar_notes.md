# Vanar: notes

What only holds for Vanar: the player's rules for these sets, the ranks the player has given, Vanar's jobs, merits and nation, and what the mechanics give at those values. How the game works is in [ffxi-mechanics.md](../../docs/ffxi-mechanics.md), and what holds for any copy of an item in [gear-notes.md](../../docs/gear-notes.md). Notes on Vanar's own copies are in [Vanar_gear_notes.md](Vanar_gear_notes.md), the path and rank of each path item in [Vanar_rank_augments.md](Vanar_rank_augments.md), and every piece the job files wear in [Vanar_gear_list.md](Vanar_gear_list.md). A fact the player gave is marked **(player, date)**.

## Rules for these sets

The player gave these rules for Vanar's sets. They are recorded here so they don't have to be explained again.

- **(player, 2026-10-05)** Melee sets by offense mode, in the player's words: "Overall damage (including WSD) can come first in TP as long as I hit a minimum of 1350 ACC, ACC comes first in ACC mode. DT in DT set." The 1350 floor has since been replaced (next lines).
  - **(player, 2026-10-10)** RDM's floor is 1250, from gear, food and weapon skill accuracy, with Composure not counted. Composure's +70 comes on top, 1320 in all. This replaces the 2026-10-09 rule, which counted Composure toward 1350. Composure is always up when RDM melees (player, 2026-10-09), and its +70 is 50 at level 99 and 20 more from its job point category ([bg-wiki](https://www.bg-wiki.com/ffxi/Composure)).
  - **(player, 2026-10-29)** RDM's floor is raised by 25, to 1275, counted the same way: gear, food and weapon skill accuracy, with Composure not counted (1345 with its +70). This replaces the 1250 floor above and in the rules below that name it.
  - **(player, 2026-10-10)** Every other job's floor is 1275: BLU's here.
  - **(player, 2026-10-10)** Weapon skill accuracy counts toward the floor: Karieyh Ring's +5, Fotia Gorget's and Fotia Belt's +10, and the like.
  - **(player, 2026-10-05)** The floor counts gear and food, not buffs.
  - **(player, 2026-10-08, kept 2026-10-10)** Fodder mode doesn't count toward the floor. Fodder is the first offense mode in `Vanar_Blu_Gear.lua`, so BLU starts in it.
  - **(player, 2026-10-07)** The weapon skill's first-swing +100 accuracy doesn't count toward the floor.
  - **(player, 2026-10-10)** Above the floor, a TP-mode engaged set is weighed by TP per round, the time to the next weapon skill, against a reference target evasion of 1350. Accuracy, Double, Triple and Quadruple Attack and Store TP trade against each other this way; DT, ACC and Fodder mode are unchanged. Per hand:
    - TP per round ∝ hit rate × expected hits × TP per hit.
    - Hit rate = 75 + floor((accuracy − 1350) ÷ 2) %, capped at 99% in the main hand (accuracy 1398) and 95% in the off hand (1390) ([Hit rate and the accuracy cap](../../docs/ffxi-mechanics.md#hit-rate-and-the-accuracy-cap)). Accuracy past the cap is worth nothing. The accuracy is the floor-counted one: gear, food and weapon skill accuracy, no buffs.
    - Expected hits ≈ 1 + 3 × Quadruple + 2 × Triple + Double Attack, rolled in that order, so Double Attack is worth a little less beside Triple and Quadruple ([Multi-attack](../../docs/ffxi-mechanics.md#multi-attack)).
    - TP per hit = base TP × (100 + Store TP) ÷ 100 ([TP gain and Store TP](../../docs/ffxi-mechanics.md#tp-gain-and-store-tp)).
    - Below the cap, 2 accuracy, 1% Double Attack and 1 Store TP are each worth roughly 1% TP per round; each one's value shrinks as the other two grow.
    - **(player, 2026-10-10)** A TP-mode engaged set keeps Damage taken at 36 or more. TP per round is weighed only among sets that do; a set that gains TP per round below DT 36 dies too often.
  - **(player, 2026-10-12)** For RDM this replaces the TP-per-round weighing above. In `sets.engaged`, `sets.engaged.DT` and the sets built on them, the only accuracy limit is the 1250 floor (gear and food, no Composure, Forfend +1's Unity accuracy at its +10 minimum) on the main hand of every weapon pair that wears the set. Past it, Double Attack and Store TP come first, and each set keeps its DT rule. Temper II's Triple Attack, about 33 to 35%, isn't counted unless a Double Attack cap is being hit. Maxentius gets no engaged sets of its own: the shared sets and the sets built on them take the trade with every weapon.
  - **(player, 2026-10-07)** Both jobs eat Oden or Grape Daifuku for melee, so a melee decision has to hold with either food. The job files' `Food` setting stays as it is.
  - **(player, 2026-10-11)** The hybrid mode doesn't pick the weapons: any of BLU's weapon sets can be on with `sets.engaged.DT`. So BLU's DT sets are built to do well with every weapon set, not for one of them.
  - **(player, 2026-10-18)** BLU melees with a mix of its weapon sets, so `sets.engaged` and `sets.engaged.DT` stay built for every weapon set, not for the Thibron off hands or the item-level ones.
  - **(player, 2026-10-11)** BLU's DEX/Crit Rosmerta's Cape (`gear.crit_jse_back`) is for weapon skills only. The TP sets, the Aftermath ones included, wear the DEX/Double Attack cape (`gear.da_jse_back`).
  - **(player, 2026-10-07)** The ACC-mode rebuild is approved: on both jobs, `sets.OffenseMode.ACC`, `sets.WS.ACC` and every weapon skill's own `.ACC` set take the most accuracy they can, ties going to the higher-damage piece. For magical weapon skills that means magic accuracy.
  - The engine wears the TP-mode weapon skill sets in DT mode too, since neither job file has a `sets.WS.DT`. In ACC mode it adds `sets.WS.ACC`, or a weapon skill's own `.ACC` set.
- Sets the line above doesn't cover keep the earlier order: accuracy, then magic accuracy, weapon skill damage, attack, magic attack and damage taken. Skip pieces that only add a secondary stat (STR, DEX, VIT, AGI, INT, MND, CHR).
  - **(player, 2026-10-02)** Optimizing for INT and MND is fine; just don't bring in dedicated pieces for it.
  - **(player, 2026-10-18)** Violent Flourish's stun is resisted more often than its hit misses, so both jobs' Violent Flourish sets keep magic accuracy over accuracy.
  - **(player, 2026-10-18)** RDM's TP-mode magical weapon skill sets (Sanguine Blade and those built on it) keep their damage pieces over Murky Ring's and Alabaster Earring's Mag. Acc.+7, and the Proc set keeps Prolix Ring over Murky Ring.
  - **(player, 2026-10-07)** Nuke sets are an exception: magic accuracy doesn't strictly come before magic attack there. Their waist and neck stay Eschan Stone and Sanctity Necklace. The magic accuracy margin wanted for nukes isn't recorded.
  - **(player, 2026-10-08)** MAB raises BLU's magical blue magic, and the rule above covers those nukes too.
  - **(player, 2026-10-18)** BLU's `midcast['Blue Magic'].Physical` and the stat sets built on it are for damage (Sinker Drill under Chain Affinity and the like). Physical spells cast for their added effect go in the Stun list, whose set takes magic accuracy and Blue magic skill.
    - **(player, 2026-10-19)** Tourbillion moved into Stun for its Defense Down, with Paralyzing Triad and Sub-zero Smash, which a check of the damage lists the player asked for found. Disseverment and Delta Thrust stay damage spells, in PhysicalDex and PhysicalVit.
  - **(player, 2026-10-10)** The rule covers the magic burst sets too: their neck and waist stay Sanctity Necklace and Eschan Stone.
  - **(player, 2026-10-10)** A Resistant burst adds the pieces that raise both magic accuracy and burst damage, through `sets.ResistantMagicBurst`: Atro. Chapeau +4 on RDM.
  - **(player, 2026-10-10)** On BLU with the weapons free, a burst outside Resistant, FullMacc and Proc takes Maxentius in the main hand and Bunzi's Rod in the sub, through the job file's `user_job_post_midcast`. Nothing changes the weapons while engaged or held by the weapon lock.
  - **(player, 2026-10-10)** In `Vanar_Rdm_Gear.lua`, the Normal-mode midcast sets valued for magic accuracy or enfeebling wear Ullr with the ammo slot empty, unless the set counts on Pemphredo Tathlum's INT or MAB. This covers the enfeebling, dark magic, Absorb and Stun sets and the like.
    - The Normal nuke and magic burst sets keep Pemphredo Tathlum, by the nuke rule above; their Resistant sets wear Ullr. Ullr gives 32 more Magic Accuracy than Pemphredo, which gives INT 4 and MAB 4.
    - Engaged, or with the range slot held empty by the weapon lock or the engaged hold, the job file's `user_job_post_midcast` swaps Pemphredo Tathlum in for Ullr, since equipping Ullr resets TP.
- Enhancing magic: skill to about 500, then duration over recast.
  - Refresh: Refresh +X, then duration, then recast.
    - **(player, 2026-10-02)** Terms: "Refresh +X" is MP the wearer receives passively each tick while the item is equipped. "Refresh potency" is a bonus to the recipients of a Refresh spell the player casts.
    - **(player, 2026-10-02)** When casting Refresh, prioritize Refresh potency gear. When idling, focus on passive refresh (Refresh +X).
    - So for the cast, the rule's first term is "Refresh" potency (Refresh), then duration, then recast. Refresh +X goes in idle sets.
  - Regen: Regen +X, then duration, then recast.
  - Temper, Temper II and the Enspells: as much skill as possible, with weapon swaps.
    - **(player, 2026-10-02)** Temper II's 700-skill cap (40%) is hard to reach, so it is in effect uncapped. The rule stands: as much skill as possible.
  - **(player, 2026-10-09)** Gear haste caps at 25.6%. Treat the cap as 26%, rounding up.
    - bg-wiki puts the gear haste cap at 256/1024, 25% ([ffxi-mechanics.md](../../docs/ffxi-mechanics.md#haste)). Either way, the listed haste to aim for is 26%.
  - **(player, 2026-10-09)** In `Vanar_Rdm_Gear.lua`, enhancing sets whose spell doesn't scale with skill wear as much gear haste as they can, up to the cap, for recast: Refresh, Haste, Regen, Flurry, Aquaveil, the Gain- and Bar- duration sets, Phalanx on others, Sneak and Invisible, the ComposureOther overlay and the like. Skill-based spells are excluded: Enspells, Temper, Phalanx on self, Stoneskin, and Bar-element potency at skill.
  - **(player, 2026-10-09)** Never trade enhancing duration or Refresh potency gear for haste. Haste goes only in slots those stats don't use.
  - **(player, 2026-10-09)** The player's example: the Refresh set, as worn after Sel layers it, reaches 24% with Lehko's Ring in place of Murky Ring.
    - `RDM.lua`'s `job_post_midcast` layers the base enhancing set, then ComposureOther (another player, under Composure), then the spell's own set. Layered that way, every set above already lists 26% with Murky Ring. The Refresh set's comes from Hasty Pinion 1, Amalric Coif +1 6, Alabaster Earring 5, Atrophy Tabard +4 3, Atro. Gloves +4 3, Leth. Fuseau +3 5 and Leth. Houseaux +3 3. The example's 24% matches the Refresh set's own three pieces (14) plus the ring (10), without the base set's 12 under them.
- Regen, Refresh, Temper and Enspell potency come first. Stoneskin potency and casting time are also priorities.
- No Enspell gear that has to stay on while meleeing; only gear for the cast.
- **(player)** Avoid Quick Magic pieces such as Impatiens and Perimede Cape. Witful Belt is the exception, because nothing else replaces its Fast Cast.
- Inventory: at most 160 unique pieces across BLU and RDM, ideally about 140.
  - **(player, 2026-10-11)** The Ayanmo +2 armor on storage slip 23 stays there unless a set would gain a great deal from it. The Adhemar Wristbands come out of the Mog Case for BLU's TP sets.
  - **(player, 2026-10-18)** Adhemar Wrist. +1 has replaced the Adhemar Wristbands, which are now in the Mog Safe 2.
- **(player, 2026-10-09)** Comments in `Vanar_Rdm_Gear.lua` and `Vanar_Blu_Gear.lua` state only a set's stats or effects, such as "FC 44, DT 49" or "Chain Affinity +50", kept short and on one line where possible. No bags or moves, no comparisons with rejected pieces, no rationale or history, no accuracy floor workings, no rank notes and no references to the notes.

## Ranks

The ranks the player has given, under the name the export prints. `//gs export` shows a path but never a rank. `.claude/tools/rank-doc.cs` reads this table and writes [Vanar_rank_augments.md](Vanar_rank_augments.md), which gives the augments at each rank and also lists the path items with no row here.

| Item | Path | Rank | Given |
|---|---|---|---|
| Nyame Helm | B | 20 | 2026-10-12 |
| Nyame Mail | B | 20 | 2026-10-04 |
| Nyame Gauntlets | B | 20 | 2026-10-08 |
| Nyame Flanchard | B | 20 | 2026-10-09 |
| Nyame Sollerets | B | 20 | 2026-10-04 |
| Gleti's Knife | A | 1 | 2026-10-05 |
| Crocea Mors | C | 1 | 2026-10-29 |
| Forfend +1 | A | 15 | 2026-10-04 |
| Coiste Bodhar | A | 20 | 2026-10-04 |
| Alabaster Earring | A | 11 | 2026-10-29 |
| Fi Follet Cape +1 | A | 11 | 2026-10-02 |
| Obstin. Sash | A | 17 | 2026-10-06 |
| Sailfi Belt +1 | A | 14 | 2026-10-04 |
| Dls. Torque +1 | A | 20 | 2026-10-05 |
| Mirage Stole +2 | A | 20 | 2026-10-05 |
| Tizona | A | 15 | 2026-10-05 |
| Murky Ring | A | 8 | 2026-10-29 |
| Almace | A | 2 | 2026-10-11 |

- **(player, 2026-10-04)** The Nyame Helm and Flanchard went from rank 2 to rank 11 on 2026-10-04.
- **(player, 2026-10-04)** Every Bunzi's and Gleti's piece, `Bunzi's Rod` and `Gleti's Knife` included, and `Kentarch Belt +1` aren't augmented yet: rank 0, with base stats only. `Demers. Degen +1`, `Kustawi +1`, `Marin Staff +1` and `Tanmogayi +1` aren't used.
- **(player, 2026-10-05)** `Gleti's Knife` has since gone to Path A rank 1, which the export of 2026-10-05 shows as `'Path: A'`. `Obstin. Sash` is rank 13, in place of the 20 recorded on 2026-10-04. `Dls. Torque +1` (rank 20) and `Tizona` (rank 15) are at their maximum ranks; `Mirage Stole +2` is rank 20 of 25. The other rows are unchanged.
- **(player, 2026-10-06)** The Nyame Gauntlets went from rank 10 to rank 17, and `Obstin. Sash` from rank 13 to rank 17.
- **(player, 2026-10-07)** The Nyame Flanchard went from rank 11 to rank 17.
- **(player, 2026-10-08)** The Nyame Gauntlets went from rank 17 to rank 20, and the Nyame Flanchard from rank 17 to rank 18.
- **(player, 2026-10-09)** The Nyame Flanchard went from rank 18 to rank 20, and the Nyame Helm from rank 11 to rank 14.
- **(player, 2026-10-02)** The other ranks aren't worth listing, because they change often. Ask the player when a set decision turns on one.
- **(player, 2026-10-11)** `Murky Ring` is rank 2. The Nyame Helm went from rank 14 to rank 18, and `Almace` is Path A rank 2.
- **(player, 2026-10-11)** `Mirage Stole +2` at rank 20 gives STR and DEX +20, Critical hit rate +4% and Store TP +6.
- **(player, 2026-10-12)** The Nyame Helm went from rank 18 to rank 20.
- **(player, 2026-10-18)** `Murky Ring` and `Alabaster Earring` both went from rank 2 to rank 7.
- `Tizona` and `Almace` export Path A, so both are Level 119 III. `Pukulatmuj +1` exports with no augments, so it is rank 0.

## Jobs, Master Levels and nation

- **(player, 2026-10-02)** Vanar's RDM and BLU are both Master Level 25. Each has 2,100 job points, so both are mastered: every job point category at 20 and every gift.
  - The player's `/checkparam` records of 2026-10-29 give RDM's Master Level as 26 ([Skill and accuracy: Accuracy](#skill-and-accuracy-accuracy)). The skill caps and estimates below are at 25; at 26 each RDM skill cap and base stat is 1 higher. BLU's isn't in them.
  - **(player, 2026-10-29)** RDM is Master Level 26 and BLU is Master Level 28. This replaces the 25 above; the caps and estimates below that assume 25 are low by 1 for RDM and 3 for BLU.
- At Master Level 25 the support job is level 54 (49 + floor(25 ÷ 5)).
- **(player, 2026-10-02)** Vanar is a citizen of Windurst. What that turns on and off is under [Enhancing magic: Refresh](#enhancing-magic-refresh) below.
- **(player, 2026-10-07)** Vanar is an Elvaan, on both jobs.
  - bg-wiki gives Elvaan only starting stats (level 1: STR 9, DEX 7, VIT 7, AGI 6, INT 4, MND 6, CHR 6, against a Hume's 8, 7, 6, 7, 5, 5, 6), and no level 99 values ([Base Stats](https://www.bg-wiki.com/ffxi/Category:Base_Stats)). So the accuracy estimates in these notes and the job files use wsdist's race-less job tables, and a `/checkparam` replaces them.
- **(player, 2026-10-07)** BLU's melee spell set gives Accuracy Bonus, Attack Bonus and Store TP; see [Blue magic: Traits from set spells](#blue-magic-traits-from-set-spells).
  - **(player, 2026-10-08)** The Accuracy Bonus is tier IV. The Attack Bonus and Store TP tiers aren't recorded.
- The support jobs aren't recorded. The estimates assume RDM/NIN (Dual Wield for the Thibron and Gleti's Knife modes) and BLU/WAR, as bg-wiki's simulated BLU sets do. The player's `/checkparam` records of 2026-10-10 were taken as BLU/WAR and as BLU/NIN ([Skill and accuracy: Accuracy](#skill-and-accuracy-accuracy)).
- **(player, 2026-10-11)** Vanar's THF has no Master Levels and 471 of 2,100 job points. It has learned Rudra's Storm. Its support job and merits aren't recorded.
- **(player, 2026-10-11)** THF's sets put the 1275 accuracy floor before damage, and have no Sneak Attack or Trick Attack set of their own for now.
  - **(player, 2026-10-18)** THF's Savage Blade set is the exception: it keeps Nyame Gauntlets and Karieyh Ring for damage, since a Naegling main hand can't reach the floor on THF (Skill and accuracy, below).
  - **(player, 2026-10-18)** THF's DT sets keep Nyame Gauntlets. Elite Royal Collar stays in the Mog Safe 2 rather than come out to make room for Adhemar Wrist. +1.

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
| Nyame Gauntlets | rank 25, Path B | rank 20, Path B | Attack 5 (it has 25 of 30), WSD 2% (it has 8% of 10%), Double Attack 2% (it has 2% of 4%), VIT +10 |
| Nyame Flanchard | rank 25, Path B | rank 20, Path B | Attack 5 (it has 25 of 30), WSD 2% (it has 9% of 11%), Double Attack 2% (it has 3% of 5%), STR +10 |
| Nyame Helm | rank 25, Path B | rank 20, Path B | Attack 5 (it has 25 of 30), WSD 2% (it has 8% of 10%), Double Attack 2% (it has 2% of 4%), Accuracy +5 |
| Bunzi's Robe | rank 30 | rank 0 | PDL +8%, Attack and Magic Damage +30, Accuracy and Magic Accuracy +15, DEX +5 |
| Bunzi's Gloves | rank 30 | rank 0 | Magic burst damage II +6, Attack and Magic Damage +30, Accuracy and Magic Accuracy +15, MND +5 |
| Bunzi's Hat | rank 30 | rank 0 | Store TP +8, Quadruple Attack +3%, Attack and Magic Damage +30, Accuracy and Magic Accuracy +15 |
| Bunzi's Rod | rank 30 | rank 0 | Magic Attack Bonus +30, Accuracy and Magic Accuracy +15, DMG +11 |
| Gleti's Cuirass, Gauntlets, Breeches, Boots | rank 30 | rank 0 | Each: Attack +30, Accuracy and Magic Accuracy +15. Plus Cuirass Double Attack +10%, Gauntlets Store TP +8 and DEX +5, Breeches Triple Attack +5%, Boots STR +5. PDL and crit rate are base stats, so Vanar's have them |
| Gleti's Knife | rank 30 | rank 1 | DMG +10, Attack +43, Accuracy and Magic Accuracy +15, Subtle Blow II +10 |
| Beithir Ring | rank 30 | rank 0 | Weapon Skill Accuracy +15, Attack +15, Skillchain damage +5% |

Where that matters:

- RDM's high-buff Death Blossom, Imperator, Requiescat and Black Halo wear Bunzi's Robe. The sim's rank 30 copy adds PDL +8% and Attack +30; Vanar's rank 0 copy has neither augment (its base Attack +40 and MND +43 remain).
- Nyame Gauntlets are in six RDM mid-buff sets, and in BLU Expiacion (mid), Imperator and Savage Blade (both). Vanar's rank 20 pair has WSD +8% of the sim's +10%, and Double Attack +2% of its +4%.
- Nyame Flanchard is in all 16 RDM physical non-crit sets and 6 of the 8 BLU ones, and Nyame Sollerets in 6 of the 8 BLU ones. Vanar's rank 20 Sollerets are 2% WSD and 5 Attack short. The rank 20 Flanchard is 2% WSD, 5 Attack and 2% Double Attack short.
- Bunzi's Rod (RDM nukes, Sanguine Blade on both jobs) is 30 Magic Attack Bonus short. Bunzi's Gloves in the RDM magic burst set lack their magic burst damage II. Bunzi's Hat in the RDM TP set lacks its Store TP and Quadruple Attack.
- Gleti's in the BLU sets keep their PDL at rank 0 but are 30 Attack and 15 Accuracy short each.
- Beithir Ring is in BLU's mid-buff Expiacion and Savage Blade, both Imperator sets and both Red Lotus Blade sets. Vanar's rank 0 copy has only its base STR, DEX, VIT and AGI +3 and Weapon skill damage +2%: 15 Weapon Skill Accuracy and 15 Attack short of the sims'.
- So the pages overvalue these pieces for Vanar. A substitution needs the lost values from rank-augments.md weighed against the next piece; the page totals can't be corrected by hand. The simulator has rank 0, 15, 20, 25 and 30 versions of each Nyame, Bunzi's and Gleti's piece and of Coiste Bodhar, and each Nyame path (IzaKastra/wsdist_beta, gear.py), so a run at Vanar's ranks is the clean check. Vanar's Nyame pieces are all rank 20, which it has. Alabaster Earring and Murky Ring (R30), Sailfi Belt +1 (R15) and Mirage Stole +2 (R25) have only their max-rank entry, so each of those needs an edited dict ([wsdist data errors](../../docs/ffxi-mechanics.md#wsdist-data-errors)). Dls. Torque +1's only entry, R20, is Vanar's rank (player, 2026-10-05).
- A data error, as one sign of the unknown quality: the simulator's rank 0 Bunzi's Rod has DMG 152 (144+8), but the item's own text says DMG 144 (IzaKastra/wsdist_beta, gear.py; bg-wiki, Bunzi's Rod; the item's help text). More under wsdist data errors.

Gear in the sets that Vanar doesn't own, most-used first:

- RDM: Crepuscular Pebble (every high-buff non-crit physical set), Hoxne Earring (10 weapon skills), Sroda Ring (7), Malignance Gloves (6), Sroda Tathlum (6), Malignance Earring (5), Orpheus's Sash (5), Dls. Torque +2 (4; Vanar has the +1), Metamor. Ring +1 (4). Weapons: Caliburnus, Excalibur, Mandau, Murgleis, Sequence, Daybreak, Sakpata's Sword, Crepuscular Knife.
- BLU: Hoxne Earring (6 weapon skills), Crepuscular Pebble (4), Sroda Ring (3), the Sworn armor in the TP and Requiescat sets, and the Adhemar pieces. Weapons: Caliburnus, Sequence, Archduke's Sword, Ice Brand, Zantetsuken, Sakpata's Sword.
- Capes. Vanar's augmented Sucellos's Capes are STR/WSD, DEX/Double Attack, MND/Magic Accuracy/Haste and INT/Magic Accuracy/Magic Attack Bonus. The sims also use MND/WSD (Requiescat, Sanguine Blade, high-buff Black Halo), DEX/WSD (high-buff Imperator), INT/WSD (Aeolian Edge), DEX/crit (Chant du Cygne, Evisceration) and DEX/Store TP (TP). Vanar's Rosmerta's Capes are STR/WSD, DEX/crit, DEX/Double Attack and INT/Magic Accuracy/Magic Attack Bonus. The sims also use INT/WSD (Sanguine Blade, Red Lotus Blade), MND/Double Attack (Requiescat), DEX/WSD (high-buff Imperator), DEX/Store TP and DEX/Dual Wield (TP).
- The pages assume upgraded relic, mythic and empyrean weapons ("Level 119 III") and stage 4 primes. Vanar's Tizona is Level 119 III like the sims', since it exports "Path: A", and rank 15, the maximum (player, 2026-10-05). His Almace exports "Path: A" too from the 2026-10-11 export on, so it is Level 119 III, at rank 2 (player, 2026-10-11). The export can't show the stage of his Mpu Gandring; ask the player.

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

- At Vanar's ranks: the Nyame Path B Sollerets (+2%) and Mail (+3%) at rank 20 give Double Attack, and so do the Gauntlets (+2%) and the Flanchard (+3%), both rank 20 **(player, 2026-10-08 and 2026-10-09)**; the Helm at rank 20 gives +2% **(player, 2026-10-12)**, Path B's Double Attack starting at rank 16. Every Bunzi's and Gleti's armor piece is rank 0, so Bunzi's Hat has no Quadruple Attack, Gleti's Cuirass no Double Attack and Gleti's Breeches no Triple Attack. Bunzi's Gloves (RDM) keep their base Double Attack +8%.
- Vanar's THF has Triple Attack 10% before gear, taking the player's 471 job points as spent: tier II's 6% and the gifts at 125 and 450 job points, 2% each ([ffxi-mechanics.md](../../docs/ffxi-mechanics.md#multi-attack)). Its Triple Attack Rate merits (+1% a level) aren't recorded.

### Subtle Blow

- Vanar's Gleti's Knife is rank 1 and his Gleti's Breeches rank 0, so the Knife has no Subtle Blow II, which starts at rank 21, and the Breeches none of their augment's Subtle Blow.

### Skill and accuracy: Combat skill

- Vanar's Bunzi's Rod is rank 0 and his Gleti's Knife rank 1. Both have their base skill, since no rank adds skill.
- Vanar's THF has no Master Levels and the 8/8 dagger and sword merits (player, 2026-10-02): a Tauret hand is 424 + 16 + 250 = 690 skill (621 accuracy from skill), a Gleti's Knife hand 695 (625) and a Naegling hand 334 + 16 + 250 = 600 (540). So a Naegling main hand reads 81 less accuracy than a Tauret one in the same set ([ffxi-mechanics.md](../../docs/ffxi-mechanics.md#combat-skill)).

### Skill and accuracy: Sword skill past 600 (disputed)

- The worked sword skill figures are Vanar's: Master Level 25 and 8/8 sword merits (player, 2026-10-02). Vanar's Almace is Level 119 III, since it exports Path A from the 2026-10-11 export on (rank 2, player, 2026-10-11), so a hand holding it has Sword skill +269.

### Skill and accuracy: Accuracy

Main-hand floor accuracy of the TP-mode sets in `Vanar_Rdm_Gear.lua` and `Vanar_Blu_Gear.lua` as the 2026-10-10 floor counts it: gear, Oden (the lower of the two foods), weapon skill accuracy, base stats, job point gifts and BLU's traits, with no buffs and no first-swing bonus. Grape Daifuku adds 6 or 7. The BLU rows, for the sets of 2026-10-11, come from the player's `/checkparam` records (next list) with Oden added. The RDM rows, for the sets of 2026-10-10, are estimates from wsdist's race-less job tables (no level 99 Elvaan values are in reach) as RDM/NIN, and a `/checkparam` replaces each.

| Set | Weapons | Floor accuracy | Floor |
|---|---|---|---|
| BLU TP (`sets.engaged`), with Adhemar Wrist. +1 (2026-10-18, by the formula below) | Tizona, Naegling, Almace + Thibron; Maxentius + Bunzi's Rod | 1513, 1518, 1521; 1477 | 1275 |
| BLU `sets.precast.WS` (Black Halo) | Maxentius + Bunzi's Rod | 1359 | 1275 |
| BLU Savage Blade, Expiacion | Naegling, Tizona + Thibron | 1361, 1356 | 1275 |
| BLU Requiescat | Naegling + Thibron | 1530 | 1275 |
| BLU Chant du Cygne | Almace + Thibron | 1484 | 1275 |
| RDM TP (`sets.engaged`) | Naegling, Maxentius + Thibron; Naegling + Gleti's Knife | 1346, 1277; 1397 | 1250 |
| RDM Savage Blade | Naegling + Thibron | 1256 | 1250 |
| RDM Black Halo | Maxentius + Thibron | 1250 | 1250 |
| RDM Requiescat | Naegling + Thibron | 1320 | 1250 |
| RDM Chant du Cygne and Evisceration | Tauret + Gleti's Knife | 1349 | 1250 |

- **The player's `/checkparam` records** (`data/audit/Vanar.jsonl`, 2026-10-10, unbuffed and unfed, as BLU/WAR and BLU/NIN) give both hands' accuracy for every BLU engaged set and weapon set. One formula gives all 54 of those records exactly, on both hands: floor(DEX × 0.75), plus the accuracy from the hand's skill ([Combat skill](../../docs/ffxi-mechanics.md#combat-skill)), plus Accuracy from gear and weapons, plus 96. What it takes:
  - DEX 152 with no gear as BLU/WAR (153 as BLU/NIN), 32 of it from the blue magic spell set. wsdist's race-less tables give 124, without the spells.
  - 96 accuracy from traits and job points: 12 more than Accuracy Bonus IV **(player, 2026-10-08)** and the gifts add up to (48 + 36). Accuracy Bonus V (+60) would account for it ([Traits from set spells](../../docs/ffxi-mechanics.md#traits-from-set-spells)), but the records can't say which source it is.
  - Sword skill 465 and club skill 429 before the weapon's own skill, as in the skill table above. Sword skill on armor reaches both hands: with Tizona and Almace the two hands read the same.
  - Tizona's Path A Accuracy +30 on both hands ([Tizona](../../docs/gear-notes.md#tizona)), and Mirage Stole +2's DEX +20 at rank 20 **(player, 2026-10-11)**.
  - With weapons only, as BLU/WAR (main hand / off hand): Tizona + Thibron 900 / 672, Tizona + Almace 937 / 937, Almace + Thibron 907 / 679, Naegling + Thibron 904 / 693, Naegling + Almace 941 / 958, Maxentius + Bunzi's Rod 901 / 893, Naegling + Bunzi's Rod 944 / 904. A Thibron off hand, with no skill of its own, reads 211 to 228 below its main hand.
- Each 4 DEX is about 3 accuracy. The Chant du Cygne row counts Almace's DEX+50, the Level 119 III value, which Vanar's Path A copy has.
- **(player, 2026-10-11)** BLU's `sets.precast.WS`, and with it the Savage Blade and Expiacion sets, wear Beithir Ring in place of Karieyh Ring: Weapon Skill Accuracy 5 lower and DEX 3 higher. The figures above count Beithir Ring, 2 or 3 below Karieyh Ring's.
- Bunzi's Rod in the off hand adds its Accuracy 40 to the main hand too ([Which hand a weapon's stats work from](../../docs/ffxi-mechanics.md#which-hand-a-weapons-stats-work-from)), and so does Gleti's Knife; Thibron and Ammurapi Shield add none, so the Thibron rows are each set's low end.
- RDM's hit rate has Composure's +70 on top, which the floor doesn't count (Rules for these sets).
- **RDM's `/checkparam` records** (`data/audit/Vanar.jsonl`, 2026-10-10, unbuffed and unfed, as RDM/NIN) fit the same formula with 22 in place of 96 (RDM's job point gifts; /NIN adds no accuracy trait) and DEX 124 with no gear. Weapons alone, main hand: Naegling or Tauret with Ammurapi Shield 786, Maxentius 717. So a Maxentius hand reads 69 below the other two: club 375 + 250 = 625 skill gives 562 accuracy against 620 at 689, and Maxentius has no DEX+15. `sets.engaged` and `sets.engaged.DT` read the same (722 each, with no weapons).
- **(player, 2026-10-12)** With Naegling and `sets.engaged`, Composure off: 1268 with Ammurapi Shield, 1301 with Forfend +1; with Composure up, 1338 and 1371. The 33 between the shields is the Forfend's rank 15 Accuracy+15 and its Unity accuracy, +18 that week. The formula above gives 1269 and 1302 unfed, so the readings are unfed. With Oden (+70 at its cap, and about 4 from its DEX+5) the set's floor accuracy is 1375 at Unity +18 and 1367 at +10, and 69 less with Maxentius (1306 and 1298). Grape Daifuku gives 6 more.
- The engaged sets rebuilt on 2026-10-12 under the floor-only rule (Rules for these sets), as floor accuracy with Oden at Unity +10: `sets.engaged` 1326 with Naegling or Tauret and Forfend +1, 1257 with Maxentius; `sets.engaged.DT` 1324 and 1255. `sets.engaged.DW` and `sets.engaged.DW.DT` are 18 below the 2026-10-10 sets with every dual-wield pair: Maxentius + Thibron (the Maxbron weapon set, which holds both sets back) 1255, Maxentius + Gleti's Knife 1306, Pukulatmuj +1 + Gleti's Knife 1316, Naegling + Thibron 1324, Naegling or Tauret + Bunzi's Rod 1364, Naegling or Tauret + Gleti's Knife 1375. Each pair's figure is its weapons-alone reading in the 2026-10-10 records, plus 482 for the 2026-10-10 armor (1268 − 786), plus 74 for Oden, less the change. They replace the RDM TP row above.
- With Murky Ring and Alabaster Earring at rank 7 **(player, 2026-10-18)**, by the formula above less 1, as the 2026-10-12 readings ran, with Oden at Unity +10: `sets.engaged.DT` is 1329 with Naegling or Tauret and Forfend +1, and 1260 with Maxentius. `sets.engaged` and `sets.engaged.DW` wear neither piece and stay as above. `sets.engaged.DW.DT` keeps Leth. Earring +1 **(player, 2026-10-19)**: Vanar's copy has Double Attack +5%, as Brutal Earring does, so Brutal Earring would give up its Accuracy+15 for Store TP +1 alone. With it, Maxentius + Thibron is 1265.
- By the same formula, with weapon skill accuracy counted (2026-10-18): Savage Blade 1252 with Naegling + Thibron, Requiescat 1316 with Naegling + Thibron, Chant du Cygne 1297 with Almace + Thibron and Evisceration 1293 with Tauret + Thibron. Black Halo is 1247 with Maxentius + Thibron, 3 under the floor (1253 with Grape Daifuku, 1272 with Forfend +1). The table's RDM weapon skill rows are the 2026-10-10 wsdist estimates.
- The 2026-10-10 weapon skill sets come from exhaustive searches over the wardrobe pieces: scratch `rdmws-search.cs` for RDM's Savage Blade, Black Halo and Requiescat, and a second model with the same formulas for the rest, which also checked those three. Each set was scored across TP, target AGI (300, 340, 400), evasion (1250, 1350) and buffs (none; attack ×1.3 + 250 and defense −10%), keeping the set with the best worst case. Modelled gains over the sets before: RDM Savage Blade +4%, Black Halo +8%, Chant du Cygne and Evisceration +3%; BLU Savage Blade +4%, Expiacion +3%, Black Halo +4.5%, Chant du Cygne +16%. Requiescat stayed on both jobs: at most 1% either way, and the two models disagree on RDM's.
- The TP sets weren't changed by those searches: both clear their floor with every weapon pair. BLU's was changed later that day **(player, 2026-10-10)**: Nyame Mail, Gauntlets and Flanchard for the Hashishin body, hands and legs, trading 69 gear Accuracy and 31 DEX (about 92 accuracy) for Double Attack 24 to 32, and losing Refresh 4, which moved to `sets.MP`. A scratch TP model that turns TP gain into weapon skills favoured, on RDM, the Atrophy +4 set (DT 40 to 5) for its accuracy on the skill-less Thibron off hand, and on BLU, Dual Wield and multi-attack pieces, by amounts that turn on the target's evasion and the magic haste received.
  - The `/checkparam` records show that change put a Thibron off hand at 1197 to 1219 with Oden, the 20% floor at 1350 evasion, where the Hashishin pieces had it at 1290 to 1311 (45 to 55%). The estimates of the time had it near the floor either way.
- BLU's engaged sets were rebuilt on 2026-10-11 from the formula above, by a scratch search over the wardrobe pieces and the Adhemar Wristbands with the TP per round formulas in Rules for these sets: 1350 evasion, Oden and Grape Daifuku, BLU/WAR's Double Attack 12%, the Store TP trait at +20 and Kentarch Belt +1's Unity Store TP at +1. Each set was weighed across every weapon set it can be worn with, keeping the set whose worst weapon set gained most over the set before. Under Tizona's Aftermath Lv.3 the main hand's extra attacks come after Double Attack, so Double Attack there counts a fifth ([Multi-attack](../../docs/ffxi-mechanics.md#multi-attack)). With Oden (main hand / off hand, and the off hand's hit rate at 1350 evasion):
  - `sets.engaged`, and `sets.engaged.AM` on it with nothing of its own: Tizona + Thibron 1490 / 1257 (28%), Almace + Thibron 1498 / 1265 (32%), Naegling + Thibron 1494 / 1278 (39%), Maxentius + Bunzi's Rod 1454 / 1446. TP per round over the sets before: +9 to +21% with a Thibron off hand, +2 to +4% with an Almace or Bunzi's Rod one; under Aftermath +13 to +15% with Thibron and +8% with Almace.
  - `sets.engaged.DT`, and `sets.engaged.DT.AM` on it with nothing of its own: Tizona + Thibron 1544 / 1311 (55%), Almace + Thibron 1551 / 1318 (59%), Naegling + Thibron 1548 / 1332 (66%). TP per round: +4.2 to +4.9% with a Thibron off hand, +1.6% with an Almace or Bunzi's Rod one; under Aftermath +6.5 to +7.0% with Thibron and +4.7% with Almace.
  - Every main hand and every Almace or Bunzi's Rod off hand is over its cap in these sets, so a Thibron off hand is the only hand where accuracy still counts: 2 accuracy is a point of its hit rate.
  - The ACC-mode sets (`sets.engaged.Acc` and those on it) give less TP per round than `sets.engaged` at 1350 evasion with every weapon set but the Thibron ones, where they give 3 to 6% more. They give more with most weapon sets from about 1525 evasion and with all of them from 1550, and with Maxentius + Bunzi's Rod from about 1475.
- The same search was run again on 2026-10-18, after Adhemar Wrist. +1 (Accuracy 52, DEX 44, Triple Attack +4%, Store TP +7) took the NQ Wristbands' place in `sets.engaged` and Murky Ring and Alabaster Earring reached rank 7. It covered the eight weapon sets in `Vanar_Blu_Gear.lua` and the wardrobe pieces, without Kentarch Belt +1, which is in storage. With Oden:
  - `sets.engaged` (and `sets.engaged.AM` on it), `sets.engaged.DT` and `sets.engaged.Acc.DT` stay: no other set gives more with every weapon set. `sets.engaged`: Tizona + Thibron 1513 / 1280 (40%), Almace + Thibron 1521 / 1288 (44%), Naegling + Thibron 1518 / 1302 (51%), Maxentius + Thibron 1437 / 1290 (45%), Maxentius + Bunzi's Rod 1477 / 1469; 10.4 to 11.3% more TP per round than with the NQ Wristbands with a Thibron off hand, 1.7% more with the others. `sets.engaged.DT`, with the same four Thibron pairs: 1549 / 1316 (58%), 1556 / 1323 (61%), 1553 / 1337 (68%), 1473 / 1326 (63%).
  - `sets.engaged.DT.AM` takes Honed Tathlum, Alabaster Earring, Adhemar Wrist. +1 and Nyame Sollerets over `sets.engaged.DT` (DT 52): 0.9% more TP per round with Tizona + Thibron and 3.4% more with Tizona + Almace under Aftermath Lv.3.
  - `sets.engaged.Acc` takes Murky Ring for Jhakri Ring: Accuracy 1 more on every hand, DT 28 to 38.
- **RDM's `/checkparam` records of 2026-10-29** (`data/audit/Vanar.jsonl`, which now holds only these: unfed, with Protect and Shell, as RDM/NIN at Master Level 26) fit the formula above on every record, taking DEX from the gear where a record's stats weren't refreshed: base DEX 125, each combat skill 1 above the skill table (sword and dagger 440, club 376 before the weapon's own skill) and 22 from the job point gifts. With no weapon in hand, `/checkparam` reads 124 where a hand's skill accuracy would be. Past the help text and the Ranks table, the records read:
  - Alabaster Earring at Accuracy 11 and Murky Ring at 8, 4 and 1 above their rank 7 values, on every record that wears them. That fits ranks 11 and 8, which the player confirmed the same day.
  - Forfend +1's Unity accuracy at +18 that week. The floor counts +10.
  - Rajas Ring's DEX at +5, its level 99 value ([gear-notes.md](../../docs/gear-notes.md#rajas-ring)), where `set-stats.cs` counts the low end of `DEX+2～5`.
  - `sets.resting` with Naji's Loop in the left ring in place of its Murky Ring. The record before it, `sets.HPCure`, wears Murky Ring in the right ring, and the swap left it there; the reading fits the gear worn.
- The engaged and physical weapon skill sets rebuilt on 2026-10-29 for the 1275 floor, as floor accuracy with Oden and Forfend +1's Unity at +10, by the formula and readings above (the rank 7 values in brackets where they differ), on the lowest main hand among the weapon pairs that wear each set:
  - `sets.engaged` 1282 and `sets.engaged.DT` 1280 (1276) with Maxentius + Forfend +1; `sets.engaged.DW` 1275 and `sets.engaged.DW.DT` 1283 (1278) with Maxentius + Thibron.
  - Savage Blade 1277 with Naegling + Thibron and 1293 with Crocea Mors + Thibron, and Black Halo 1278 with Maxentius + Thibron. Unchanged, and over the floor: Requiescat 1319 and `sets.precast.WS` 1296 with Naegling + Thibron, Chant du Cygne 1299 with Almace + Thibron, and Evisceration 1296 with Tauret + Thibron.
  - In the same set, a Crocea Mors main hand reads 15 or 16 above a Naegling one (Sword skill +269 against +250, and Accuracy 50 against Naegling's 40 and DEX 15), and a Maxentius one 69 or 70 below.
- **The weapon-locked records of 2026-10-29** (Composure up, unfed, RDM/NIN), taken as [sel.md](../../docs/frameworks/sel.md#auditing-a-set-with-weapons-in-hand) says. An RDM record's floor accuracy is its main-hand reading, less 70 when Composure is up, plus 74 for Oden on an unfed record, plus the set's weapon skill accuracy (Fotia Gorget and Fotia Belt 10 each, Karieyh Ring 5). Each measured pair came within 1 of the formula above:
  - Maxbron (Maxentius + Thibron): `sets.engaged.DW` 1276, `sets.engaged.DW.DT` 1283, Black Halo 1278. Maxentius Acc: Black Halo 1318.
  - Naegbron: Savage Blade 1278, `sets.engaged` 1327, `sets.engaged.DT` 1325, `sets.engaged.DW` 1345, `sets.engaged.DW.DT` 1352. Naegling Acc: Savage Blade 1315.
  - CroceaBron: Savage Blade 1293, `sets.engaged.DW` 1361. Crocea Acc: Savage Blade 1331.
  - The single-wield weapon sets (Maxentius, Naegling and Crocea, each with Forfend +1) weren't taken: on /NIN, Sel holds the weapon sets to the Dual group.
- Vanar's THF, by the same formula: its job point gifts add 13 (5 + 8, taking the 471 as spent) and it has no accuracy trait ([Combat skill](#skill-and-accuracy-combat-skill) has its hands' skill). Neither a `/checkparam` record nor its base DEX is recorded, so for the sets of 2026-10-18 these are the base DEX the 1275 floor (gear, food and weapon skill accuracy) needs, with Gleti's Knife in the off hand, with Oden (Grape Daifuku):
  - A Naegling main hand doesn't reach it: `sets.engaged` needs base DEX 160 (151), and Savage Blade's set would need 157 (148) even with Adhemar Wrist. +1 and Murky Ring, where Vanar's BLU/WAR has 120 with no gear at Master Level 25 (above).
  - With Tauret, `sets.engaged` needs 52 (43) and Evisceration's set 65 (56). `sets.precast.WS`, which Rudra's Storm wears, needs 98 (90), so whether it clears the floor waits on a `/checkparam`.

### Attack and pDIF: Physical damage limit

- Vanar's Bunzi's Robe is rank 0, so it has no PDL, and Vanar's Nyame pieces are Path B, which adds none. Vanar's rank 0 Gleti's pieces have their base PDL in full.

### Weapons and TP: Which hand a weapon's stats work from

- Vanar's RDM Chant du Cygne weapon mode puts Gleti's Knife in the off hand, so wsdist's crit pooling overstates the main-hand crits there.

### Weapon skills: Weapon skill damage (WSD)

- Nyame Path B's WSD at Vanar's ranks **(player, 2026-10-04; the Gauntlets 2026-10-08; the Flanchard 2026-10-09; the Helm 2026-10-12)**: Helm (rank 20) +8%, Mail (20) +10%, Gauntlets (20) +8%, Flanchard (20) +9%, Sollerets (20) +8%, 43% for the five.

### Magic accuracy: Macc needed to cap

- The example is Vanar's RDM: 501 enfeebling skill, +115 always on, and 10 to 15 less to find on Ice and Earth spells (assumed 5 levels in each).

### Magic accuracy: Skill by magic type

- Vanar's RDM before gear: enfeebling 501, elemental 419, dark 341, enhancing 481 and healing 409, each with 8 merit levels, and divine 325 with none. Vanar's BLU: blue magic 485, with no merits (player, 2026-10-02).

### Magic accuracy: Job sources

- Vanar's RDM has 5 levels in Magic Accuracy (player, 2026-10-02, changed), so its always-on total is the full +115.
- **(player, 2026-10-02)** Vanar's RDM Group 1 merits are Ice and Earth Magic Accuracy. The level count isn't recorded: only if all 10 levels are in Ice and Earth does the 5-level cap force 5 in each, and these notes assume that. So on Ice and Earth spells Vanar's always-on total is 125 to 130. Gravity, Silence, Sleep, Frazzle, Dia, Addle, Blind, Poison and the other nukes get only the 115.
- Vanar's BLU has 5 Magical Accuracy merits (player, 2026-10-02): +66 always on for magical blue magic.

### Magic accuracy: Odyssey augments below rank 30

- Four of Vanar's Odyssey pieces have augment macc at the ranks the player gave: Forfend +1 (rank 15, **player, 2026-10-04**) has Mag. Acc.+15, Obstin. Sash (rank 17, **player, 2026-10-06**) Mag. Acc.+15, and Alabaster Earring and Murky Ring (rank 7, **player, 2026-10-18**) Mag. Acc.+7 each. No other Odyssey piece of known rank in [Vanar_rank_augments.md](Vanar_rank_augments.md) has any: the Nyame pieces are Path B, Gleti's Knife is rank 1 (its Mag. Acc. starts at rank 16), and every other Bunzi's and Gleti's piece is rank 0.
- Of the items Oboro ranks up, Tizona at rank 15 adds Magic Accuracy +30 in the main hand (player, 2026-10-05); Dls. Torque +1's and Mirage Stole +2's augments have none.

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
- Vanar's Obstinate Sash is rank 17 **(player, 2026-10-06)**: Magic Accuracy +15 and enfeebling skill +2 (the skill starts at rank 16).
- RDM's potency set has 586 enfeebling skill: 501, plus Viti. Chapeau +4 (27), Leth. Ganth. +3 (29), Viti. Boots +4 (17), two Stikini Rings (10) and the sash (2). That puts Frazzle III's skill part at 108 of its 120 and Distract III's at 113 of 120. Rumination Sash's 7 skill would make them 110 and 114 ([Potency by spell](../../docs/ffxi-mechanics.md#potency-by-spell)).

### Enfeebling magic: Enfeebling duration

- Vanar's RDM has 0 levels of Enfeebling Magic Duration (player, 2026-10-02, changed), so the flat seconds are the job points' 20, with or without the relic head.

### Enfeebling magic: Immunobreak

- Vanar has 0 Immunobreak Chance levels (player, 2026-10-02), so the merit and the relic boots' augment add nothing.

### Magic burst: Burst damage

- None of Vanar's Nyame or Bunzi's pieces has Magic burst damage II: the Nyame are Path B and every Bunzi's piece is rank 0 **(player, 2026-10-04)**. Vanar's five rank 0 Bunzi's armor pieces still carry their base +150 MAB and +150 Magic Damage.
- How Sel layers the burst sets in Vanar's job files: `sets.MagicBurst` goes over the midcast set of any spell Sel's `is_nuke` accepts (elemental nukes, Drain and Aspir, and BLU's Magical spell maps), in every casting mode but Proc. Resistant modes wear `sets.ResistantMagicBurst` instead; BLU's FullMacc mode isn't a Resistant mode, so it wears `sets.MagicBurst`. On BLU, `sets.buff['Burst Affinity']` goes on after the burst set, so for blue magic under Burst Affinity the legs are Hashishin Tayt +3 and the feet Hashi. Basmak +3 whatever the burst set names, and the job file's `user_job_post_midcast` comes after that. In a defense mode in combat, the nuke's `.DT` set goes on after the burst set (`libs/Sel-Include.lua`, `general_post_midcast` and `default_post_midcast`; `data/BLU.lua`, `job_post_midcast`).
- RDM's burst totals (2026-10-10): the nuke set's Leth. Fuseau +3 and the overlay's Ea Houppelande and Jhakri Ring make magic burst damage 25, and 35 with Bunzi's Rod, plus Magic burst damage II 8 and the trait's 7. The neck stays Sanctity Necklace by the nuke rule **(player, 2026-10-10)**; Mizu. Kubikazari's 10 would have been about 3.7% more damage with the weapons free and 7% locked.
  - No mix of the owned burst pieces reaches 40 for less than it costs. The Sollerets, the cheapest Nyame piece for a Lethargy +3 piece, cost MAB 20, Magic Damage 30, INT 5 and Magic Accuracy 20 for 5: about 3.5% less damage with Magic Damage and INT in D (dINT 100 to 199, D about 1,850, M 3.85). These are from a scratch search over every mix.
  - The Resistant overlay's Atro. Chapeau +4 **(player, 2026-10-10)** raises the Resistant nuke sets' magic accuracy by 21 (Magic Accuracy 64 and elemental magic skill 18 against Leth. Chappel +3's 61) and burst damage by 10, to 25 and 35 with Bunzi's Rod, for MAB 56, Magic Damage 31 and DT 10: about 6% less damage on a nuke that lands unresisted.
- BLU's burst totals (2026-10-10): Hashi. Basmak +3 and the overlay's Jhakri Ring make 17 with the weapons held. With them free, the job file's hook adds Maxentius in the main hand (+4 a skillchain) and Bunzi's Rod in the sub (+10): 31 after a two-step chain, 35 after three and 39 after four, for 5 magic accuracy (Maxentius's Magic Accuracy skill 250 against Bunzi's Rod's 255).
  - On blue magic under Burst Affinity, each Nyame piece in place of a Hashishin +3 piece costs Magic Accuracy 21 to 27 and a Hashishin proc share, for no damage gain. The magical sets' traits and job point MAB aren't recorded; the ranking held from 45 to 76 base MAB and with the Magic Burst Bonus trait at 0 or +9%.
  - No owned BLU piece adds burst damage without lowering the Resistant sets' magic accuracy: Jhakri Ring costs 7 (against a Stikini Ring's Magic Accuracy 8 and Blue magic skill 5), Maxentius in the main hand 5, and each Nyame piece 21 to 27. So `sets.ResistantMagicBurst` adds nothing on BLU.

### Blue magic: Job points and merits

- **(player, 2026-10-02)** Vanar's BLU merits: 5 in Physical Potency, 5 in Magical Accuracy, 5 in Diffusion, 5 in Enchainment. That fills both groups, so Vanar has no Convergence and no Assimilation, and 75 set points.

### Blue magic: Chain Affinity, Burst Affinity, Efflux and Azure Lore

- Vanar has 5 Enchainment levels (player, 2026-10-02): +500, and +750 with Luhlaza Jubbah +1 on.

### Blue magic: Convergence, Diffusion and Unbridled Learning

- Vanar has 5 Diffusion levels (player, 2026-10-02) and Luhlaza Charuqs +1: +45%, so Vanar's Mighty Guard lasts 5:13.

### Blue magic: Traits from set spells

- **(player, 2026-10-07)** The melee spell set gives Accuracy Bonus, Attack Bonus and Store TP.
- **(player, 2026-10-08)** The Accuracy Bonus is tier IV, Accuracy +48 ([Traits from set spells](../../docs/ffxi-mechanics.md#traits-from-set-spells)). The Attack Bonus and Store TP tiers aren't recorded.
- The player's `/checkparam` records of 2026-10-10 fit 96 accuracy from traits and job points, 12 more than tier IV and the gifts give, and DEX +32 from the spell set's stat bonuses ([Skill and accuracy: Accuracy](#skill-and-accuracy-accuracy)).
- Vanar's BLU has 2,100 job points, so both Job Trait Bonus gifts apply, and a trait the spells unlock is at least tier III: bg-wiki's table puts tier III of all three within 5 or 6 set points at 1,200 job points ([Blue Mage Job Traits](https://www.bg-wiki.com/ffxi/Blue_Mage_Job_Traits)). For the two tiers not recorded, the estimates take that lowest one: Attack +35 and Store TP +20. Each tier past III adds 12 or 13 attack, and 5 Store TP.
- bg-wiki hedges how the gifts work ("seems to" add 8 trait points); for the Accuracy Bonus the player's tier IV settles it.
- /WAR's Attack Bonus I (+10) doesn't add to the spells' tier; the higher applies ([Traits from set spells](../../docs/ffxi-mechanics.md#traits-from-set-spells)).

### Community Red Mage Guide sets: What the guide assumes

- The guide assumes 2100 job points, full merits and Master Level 30. Vanar's RDM has the 2100 job points but is Master Level 25, so each of its skills is 5 below the guide's figures. Vanar has 8/8 merits in sword, dagger, club, enhancing, enfeebling, elemental, dark and healing (player, 2026-10-02), so in those the guide's full merits match and the gap is the 5.
- Vanar's Bunzi's and Gleti's pieces are rank 0, base stats only, Bunzi's Rod included. Gleti's Knife is rank 1: DMG +1 and Attack +2 over its base stats. Vanar's Marin Staff +1 exports with no augments (rank 0).
- Against the guide's Group 2 merits: Vanar (player, 2026-10-02, changed) has all 5 of its Magic Accuracy levels and none of its Immunobreak Chance; the other 5 levels (10 − 5) are in Enhancing Magic Duration.
- Against the guide's Group 1 merits: Vanar's are Ice and Earth (player, 2026-10-02). Vanar shares the guide's Ice; in place of Wind, Earth covers Slow, Slow II and Break. So Gravity and Silence get none of the guide's +15 Wind merit macc.

### Community Red Mage Guide sets: Enfeebling sets

- The rule to skip pieces that add only an attribute still applies to the guide's MND and INT sets.

### wsdist (Kastra's damage simulator): What it models

- wsdist's built-in merits against Vanar's: they match in sword, dagger, club, elemental and dark. wsdist also adds +16 to divine and blue magic skill, where Vanar has no merits, and to evasion, which isn't among Vanar's combat skill merits. Vanar's crit rate merits aren't recorded.
- wsdist's RDM merits against Vanar's: its Group 1 +15 fits only Vanar's Ice and Earth spells (at an assumed 5 levels and +3 a level), its 5/5 Group 2 Magic Accuracy matches, and its 5/5 En-spell Damage (+15) is 15 more than Vanar's 0.
- Vanar's Requiescat merit level isn't recorded (at least 1, since Vanar uses it).
