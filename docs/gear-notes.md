# Gear notes

For agents that build gear sets from Vanar's `//gs export`, [`data/export/Vanar 2026-10-01 22-41-03.lua`](../data/export/Vanar%202026-10-01%2022-41-03.lua). The export lists only each item's name and augments. Each item's in-game help text, called "help text" below, is in Windower's item resources (`res/item_descriptions.lua`, matched by item ID); bg-wiki's item pages show the same text. These notes add what those don't: hidden values, set bonuses, conditions, slot and hand restrictions, which set a piece belongs in, what each augmented copy is for, and pieces that another piece Vanar owns strictly beats.

- **Coverage.** Every equippable piece in the 2026-10-01 export that has something not obvious from its help text and augments gets an entry under its slot. The pieces with nothing to add are named in the "No notes beyond the help text" line at the end of each slot.
- **Sources.** bg-wiki item and set pages, read on 2026-10-01 and 2026-10-02, plus FFXIclopedia where a note links it. A second agent checked every note against the page it cites. The RahvinGS gear library, [GearSets-Include.lua](https://github.com/khowe085/rahvin-gearswap/blob/a36cbf6/RahvinGS/GearSets-Include.lua), was used for leads only, never as a source.
- **Reading an entry.** The italic line under each heading gives the item's full name and, where it matters, which of RDM and BLU can wear it. A note that starts with `Copy` applies only to the copy with the augments it quotes, or to the copy with none.
- **Companion docs.** [ffxi-mechanics.md](ffxi-mechanics.md) has the mechanics these notes rely on (fast cast, recast, duration, potency, caps) and the player's standing rules for Vanar's sets. [rank-augments.md](rank-augments.md) has every rank's augments for the Odyssey pieces and the other path items in its table, and only the top-rank values for the items Oboro ranks up: `Dls. Torque +1`, `Mirage Stole +2`, `Tizona`, `Almace` and `Pukulatmuj +1` ([Oboro rank augments](rank-augments.md#oboro-rank-augments-maximum-only)).
- **Vanar's Odyssey ranks (player, 2026-10-02).** `Nyame Helm`, `Nyame Mail`, `Nyame Flanchard` and `Nyame Sollerets` are Path B at rank 20. `Nyame Gauntlets` and every Bunzi's and Gleti's piece, `Bunzi's Rod` and `Gleti's Knife` included, are rank 0, with base stats only. The export prints the path but never the rank.
- **Vanar's Master Levels and merits (player, 2026-10-02).** RDM and BLU are both Master Level 25. RDM's Group 2 merits are Enhancing Magic Duration 5 and Magic Accuracy 5 **(player, 2026-10-02, changed)**. That is all 10 levels the group allows (5 + 5 = 10), so Enfeebling Magic Duration, Accuracy, Immunobreak Chance and En-spell Damage are 0.
- **Refresh terms (player, 2026-10-02).** "Refresh +X" is MP the wearer gets every tick while the piece is on. "Refresh potency" is a bonus for whoever receives a Refresh spell the wearer casts.
- **Refresh priorities (player, 2026-10-02).** When casting Refresh, prioritize "Refresh" potency gear. When idling, focus on passive refresh (Refresh +X).
  - So the Refresh midcast set puts potency first, and idle sets carry the Refresh +X pieces. This settles which term the Refresh rule in [ffxi-mechanics.md](ffxi-mechanics.md#player-rules-for-these-jobs) ("Refresh +X, then duration, then recast") means for the spell: potency.
- **Vanar's nation and job points (player, 2026-10-02).** Vanar is a citizen of Windurst. RDM and BLU both have 2,100 job points (mastered).
- **Vanar's merits (player, 2026-10-02).**
  - RDM Group 1: Ice and Earth magic accuracy. The player named the two categories, not the levels in each.
  - Magic Skills: 8 levels each in Healing, Enhancing, Enfeebling, Elemental and Dark magic.
  - Combat Skills: 8 levels each in Dagger, Sword and Club.
  - BLU: 5 levels each in Physical Potency, Magical Accuracy, Diffusion and Enchainment.
  - The player listed no other magic or combat skill, so count no merits in Divine or Blue magic. What each merit adds, and Vanar's skill totals, are in [Vanar's merits and skills](#vanars-merits-and-skills).
  - Combat Skills merits also cover defensive skills such as Evasion, Parrying and Shield ([Merit Points](https://www.bg-wiki.com/ffxi/Merit_Points)). Read the same way, the player's list has none there, so count no merits in Evasion, Parrying or Shield. Their caps are in [ffxi-mechanics.md](ffxi-mechanics.md#combat-skill).
- **Other path ranks (player, 2026-10-02).** Ranks other than the Odyssey ranks above aren't worth listing, because they change often.
  - So entries don't record them. When a set decision turns on one, ask the player.
- **Staged weapons.** `//gs export` prints the same name for every stage of a staged weapon, so it doesn't show the stage. Matching the name to an item ID gives the lowest stage's ID and help text, which may not be Vanar's. This affects `Almace`, `Tizona` and `Mpu Gandring`; their entries say what is known.
- **Simulated sets and wsdist.** An entry also lists the bg-wiki simulated sets (All Jobs Gear Sets) that wear the piece, and any error wsdist, the simulator that built them, makes with the piece (line numbers are at wsdist commit d12ac59). What the simulations assume is in [ffxi-mechanics.md](ffxi-mechanics.md#simulated-sets-bg-wiki-all-jobs-gear-sets), and wsdist itself in [its section there](ffxi-mechanics.md#wsdist-kastras-damage-simulator).

## Contents

- [Vanar's merits and skills](#vanars-merits-and-skills)
- [Armor sets and set bonuses](#armor-sets-and-set-bonuses)
- [Weapons (main hand)](#weapons-main-hand)
- [Shields and grips, ranged and ammo](#shields-and-grips-ranged-and-ammo)
- [Head](#head)
- [Neck](#neck)
- [Earrings](#earrings)
- [Body](#body)
- [Hands](#hands)
- [Rings](#rings)
- [Back](#back)
- [Waist](#waist)
- [Legs](#legs)
- [Feet](#feet)
- [Pieces the simulated sets use that Vanar doesn't own](#pieces-the-simulated-sets-use-that-vanar-doesnt-own)

## Vanar's merits and skills

What the merits in the header add. Values are from bg-wiki's [Merit Points](https://www.bg-wiki.com/ffxi/Merit_Points) page unless a link says otherwise.

- **Skill merits.** Magic Skills and Combat Skills merits add +2 skill a level, so 8 levels add 16 (8 × 2). General merits carry across jobs, but only to skills the job has. BLU has no Dagger skill, so the dagger merits do nothing on BLU.
- **Group limits.** A job's Group 1 and Group 2 each take at most 5 levels per category and 10 levels in all (the page's category table).
- **RDM Group 1.** Each level adds magic accuracy to that element's spells: +2 on Merit Points, +3 on the [Red Mage](https://www.bg-wiki.com/ffxi/Red_Mage) page.
  - The level counts aren't recorded. Only if all 10 levels are in Ice and Earth does the 5-level cap force 5 in each. Then each element gets +10 (5 × 2), or +15 (5 × 3) by the Red Mage page. Treat that split as an assumption.
  - Ice covers Distract III, and Paralyze and Bind per the [Community Red Mage Guide](https://www.bg-wiki.com/ffxi/Community_Red_Mage_Guide). Earth covers Slow II and Break. Frazzle III is Dark, so neither merit helps it. (bg-wiki: [Distract III](https://www.bg-wiki.com/ffxi/Distract_III), [Slow II](https://www.bg-wiki.com/ffxi/Slow_II), [Break](https://www.bg-wiki.com/ffxi/Break), [Frazzle III](https://www.bg-wiki.com/ffxi/Frazzle_III))
  - No Vitiation augment reads Group 1. The relic augments read Group 2 only; see [Viti. Chapeau +4](#viti-chapeau-4), [Viti. Gloves +4](#viti-gloves-4) and [Viti. Boots +4](#viti-boots-4).
- **RDM Group 2.** Enhancing Magic Duration 5 and Magic Accuracy 5 fill the group (5 + 5 = 10), so Enfeebling Magic Duration, Accuracy, Immunobreak Chance and En-spell Damage are 0. The Magic Accuracy merit is +25 (5 × 5) on every spell.
- **BLU Group 1.** Physical Potency 5 and Magical Accuracy 5 fill the group (5 + 5 = 10), so Chain Affinity Recast, Burst Affinity Recast and Monster Correlation are 0.
  - Physical Potency: +2 "Blue Magic Accuracy" and +4/256 attack a level, so +10 (5 × 2) and +20/256 attack (about 7.8%). The Community Blue Mage Guide gives it only as attack, at the same rate.
  - Magical Accuracy: +2 magic accuracy for blue magic a level, so +10 (5 × 2).
- **BLU Group 2.** Diffusion 5 and Enchainment 5 fill the group (5 + 5 = 10), so Convergence and Assimilation are 0.
  - Convergence is a merit ability, so Vanar's BLU doesn't have it ([Convergence](https://www.bg-wiki.com/ffxi/Convergence)).
  - With no Assimilation, BLU has 55 + 20 (Blue Magic Point Bonus job points) = 75 set points, not 80 ([Blue Mage](https://www.bg-wiki.com/ffxi/Blue_Mage)).
  - Diffusion: each level after the first adds 5% buff duration, so +20% at 5 ((5 − 1) × 5%) ([Diffusion](https://www.bg-wiki.com/ffxi/Diffusion)). Luhlaza Charuqs +1 adds more; see [its entry](#luhlaza-charuqs-1).
  - Enchainment: +100 TP Bonus for Chain Affinity a level, so +500 (5 × 100) ([Enchainment](https://www.bg-wiki.com/ffxi/Enchainment)). Luhlaza Jubbah +1 adds more; see [its entry](#luhlaza-jubbah-1).

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
- Of these skills, only RDM's enhancing and enfeebling and BLU's blue magic have skill gifts, +36 each ([ffxi-mechanics.md](ffxi-mechanics.md#skill-by-magic-type)). Neither job's gifts add combat skill ([ffxi-mechanics.md](ffxi-mechanics.md#combat-skill)).
- These are caps. They assume each skill is leveled to its cap; the in-game Skills menu shows the real value.
- The player's 480 enhancing at Master Level 24 fits: 404 + 36 + 16 + 24 = 480. With the merits now recorded, the 481 at Master Level 25 no longer rests on assuming 8 enhancing merits.
- An item-level weapon adds its own skill to its own hand. For example, a Naegling hand is 439 + 250 = 689 on RDM and 465 + 250 = 715 on BLU, while a Thibron hand, with no skill of its own, stays at 439 or 465, under 600 ([ffxi-mechanics.md](ffxi-mechanics.md#combat-skill)).

## Armor sets and set bonuses

Set bonuses for the gear in Vanar's export. Each set below was checked on its bg-wiki page on 2026-10-02. The help text agrees: of the items in the export, only these carry a `Set:` line.

How every set bonus works:

- The game counts the set pieces you have on at the moment it reads the stat. Pieces split between two GearSwap sets don't add up.
- So the pieces go in the set that is on at that moment. That means precast for casting time, and midcast for anything a spell reads when it lands (magic accuracy, duration, potency, damage). For melee, it means the engaged or weapon skill set.
- Each piece counts once. Past the top step, more pieces add nothing.
- A set bonus is only worth its slots if the total beats what other pieces would give in those slots. Compare whole sets, each piece's own stats included.

| Set | Bonus | Vanar's counting pieces | Vanar's best |
|---|---|---|---|
| [Atrophy](#atrophy-set) (RDM) | Accuracy, Ranged Accuracy and Magic Accuracy +15 per step | 4 | +45 |
| [Assimilator's](#assimilators-set) (BLU) | Accuracy, Ranged Accuracy and Magic Accuracy +15 per step | 3 | +30 |
| [Lethargy](#lethargy-set) (RDM) | Duration of enfeebles and of enhancing magic on others, with Composure | 5 | +50% |
| [Hashishin](#hashishin-set) (BLU) | Chance to triple a blue magic spell's WSC | 5 | 5% |
| [Jhakri](#jhakri-set) | Fast Cast +3% per step | 6 | +12% |
| [Serpentes](#serpentes-set) | Cure potency +5% | 2 | +5% |
| [Bladeborn and Steelflash](#bladeborn-and-steelflash-set) | Double Attack +7% | 2 | +7% |
| [Dudgeon and Heartseeker](#dudgeon-and-heartseeker-set) | Dual Wield +7% | 2 | +7% |
| [Lifestorm and Psystorm](#lifestorm-and-psystorm-set) | Magic Accuracy +12 | 2 | +12 |
| [Ayanmo](#ayanmo-set), [Amalric](#amalric-set), [Carmine](#carmine-set), [Adhemar](#adhemar-set), [Rubeus](#rubeus-set) | Out of reach | 0 or 1 | none |
| [Estoqueur's](#estoqueurs-set), [Regal](#regal-set) | Vanar owns no piece | 0 | none |

### Atrophy set

RDM artifact armor. ([bg-wiki](https://www.bg-wiki.com/ffxi/Atrophy_Armor_Set))

| Pieces worn | Accuracy, Ranged Accuracy and Magic Accuracy |
|---|---|
| 2 | +15 |
| 3 | +30 |
| 4 | +45 |
| 5 or more | +60 |

- **What counts:** Atrophy +2, +3 and +4 pieces. NQ and +1 Atrophy have no set bonus. A Regal Earring counts as one more piece (see [Regal](#regal-set)). bg-wiki says +2 and +3 pieces mix ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Reforged_Artifact_Armor_%2B3)). Vanar's pieces are all +4, so mixing doesn't matter here.
- **When:** whenever the stat is used. Put the pieces in the midcast set for magic accuracy on spells, or in the engaged or weapon skill set for melee accuracy.
- **Vanar owns:** `Atro. Chapeau +4`, `Atrophy Tabard +4`, `Atro. Gloves +4` and `Atro. Tights +4`. He has no Atrophy Boots and no Regal Earring. His maximum is +45, and only with all four on.
- **Slot conflict with Lethargy:** Atrophy uses the head, body, hands and legs slots, and Lethargy uses those four plus the feet. One set can't hold both bonuses at full strength:

| Atrophy pieces | Lethargy pieces | Accuracy and Magic Accuracy | Lethargy duration |
|---|---|---|---|
| 4 | 1 (feet) | +45 | none |
| 3 | 2 | +30 | +10% |
| 2 | 3 | +15 | +20% |
| 1 | 4 | none | +35% |
| 0 | 5 | none | +50% |

### Assimilator's set

BLU artifact armor. ([bg-wiki](https://www.bg-wiki.com/ffxi/Assimilator%27s_Attire_Set))

| Pieces worn | Accuracy, Ranged Accuracy and Magic Accuracy |
|---|---|
| 2 | +15 |
| 3 | +30 |
| 4 | +45 |
| 5 or more | +60 |

- **What counts:** Assimilator's +2, +3 and +4 pieces. NQ and +1 pieces have no set bonus. A Regal Earring counts as one more piece (see [Regal](#regal-set)).
- **Mixing tiers (unconfirmed for +4):** bg-wiki says +2 and +3 pieces mix. It gives the +4 tier the same bonus, but it never says that +4 pieces mix with +2 and +3 pieces. Vanar's three counting pieces are one of each tier, so his +30 depends on that mix working. It very likely does (about 85%), but no source states it. A test in game would settle it: with the Jubbah and the Charuqs both on, Accuracy should be 15 higher than the two pieces' own Accuracy adds up to.
- **When:** whenever the stat is used. Put the pieces in the midcast set for magic accuracy on blue magic, or in the engaged or weapon skill set for melee accuracy.
- **Vanar owns:** `Assim. Jubbah +4`, `Assim. Bazu. +3` and `Assim. Charuqs +2` count. `Assim. Keffiyeh +1` and `Assim. Shalwar +1` don't. He has no Regal Earring. His maximum is +30, with the body, hands and feet on.
- **Slot conflict with Hashishin:** the three counting pieces leave only the head and legs for Hashishin.

| Assimilator's pieces | Hashishin pieces | Accuracy and Magic Accuracy | Hashishin chance |
|---|---|---|---|
| 3 (body, hands, feet) | 2 (head, legs) | +30 | 2% |
| 2 | 3 | +15 | 3% |
| 1 | 4 | none | 4% |
| 0 | 5 | none | 5% |

### Lethargy set

RDM empyrean armor. The set line reads `Augments "Composure"`. ([bg-wiki](https://www.bg-wiki.com/ffxi/Lethargy_Armor_Set))

| Pieces worn | Extra duration |
|---|---|
| 2 | +10% |
| 3 | +20% |
| 4 | +35% |
| 5 | +50% |

- **What it lengthens:** enfeebling magic, and enhancing magic you cast on someone else. Enhancing magic you cast on yourself gets nothing from it. Composure itself triples self-cast enhancing duration instead, up to 30 minutes ([bg-wiki](https://www.bg-wiki.com/ffxi/Composure)).
- **How it stacks:** it is its own multiplier, separate from duration % listed on gear and from augmented duration %. Gear that lists seconds adds to the base before any of them (formula on the set page and in ffxi-mechanics.md, [Enhancing duration](ffxi-mechanics.md#enhancing-duration) and [Enfeebling duration](ffxi-mechanics.md#enfeebling-duration)).
- **What counts:** Lethargy pieces of every tier (NQ, +1, +2, +3) and Estoqueur's +2 pieces, in any mix. `Leth. Earring +1` is not an armor piece and doesn't count.
- **When:** bg-wiki counts the pieces worn when the spell is cast, so they go in the midcast set.
- **Composure:** treat Composure as required. bg-wiki only presents the bonus as an augment to Composure: the set line says so, and the Composure page lists the set under equipment that modifies the ability. Neither page says outright that it does nothing without Composure. FFXIclopedia's Composure page lists the bonus as part of Composure's effect, and RDM.lua's comments assume Composure must be up.
- **Vanar owns all five:** `Leth. Chappel +3`, `Lethargy Sayon +3`, `Leth. Ganth. +3`, `Leth. Fuseau +3` and `Leth. Houseaux +3`. His maximum is +50%. See [Atrophy](#atrophy-set) for how the two sets share slots.

### Estoqueur's set

RDM empyrean armor from before Lethargy. ([bg-wiki](https://www.bg-wiki.com/ffxi/Estoqueur%27s_Attire_Set))

- Only the +2 tier has a set bonus. It is the same Composure bonus as Lethargy (+10/20/35/50% for 2/3/4/5 pieces), and +2 pieces count together with Lethargy pieces.
- Vanar owns no Estoqueur's armor. `Estq. Earring` has the Estoqueur's name, but it isn't part of the set and has no set line, so it adds nothing to the Lethargy count.

### Hashishin set

BLU empyrean armor. The set line reads `Occ. augments Blue magic spells`. ([bg-wiki](https://www.bg-wiki.com/ffxi/Hashishin_Attire_Set))

| Pieces worn | Chance per spell |
|---|---|
| 2 | 2% |
| 3 | 3% |
| 4 | 4% |
| 5 | 5% |

- **Effect:** when it goes off, the blue magic spell's WSC (its stat modifier) is tripled. With Chain Affinity or Burst Affinity up, it is quadrupled.
- **What counts:** Hashishin pieces of every tier (NQ to +3) and Mavi +2 pieces, in any mix ([bg-wiki](https://www.bg-wiki.com/ffxi/Mavi_Attire_Set)). `Hashi. Earring +1` and `Mavi Tathlum` are not set pieces and don't count.
- **When:** bg-wiki gives no timing. The bonus changes the spell's damage, so wear the pieces in the blue magic midcast set. This is an inference, not a sourced rule.
- **Vanar owns all five:** `Hashishin Kavuk +3`, `Hashishin Mintan +3`, `Hashi. Bazu. +3`, `Hashishin Tayt +3` and `Hashi. Basmak +3`. His maximum is 5%. See [Assimilator's](#assimilators-set) for how the two sets share slots.

### Jhakri set

Ambuscade armor, worn by BLM, RDM, BLU, SCH and GEO. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Ambuscade_Rewards#Jhakri_Armor_Sets))

| Pieces worn | Fast Cast |
|---|---|
| 2 | +3% |
| 3 | +6% |
| 4 | +9% |
| 5 or 6 | +12% |

- **What counts:** Jhakri +2 armor and the Jhakri Ring. NQ and +1 Jhakri armor don't count. The ring plus any one +2 piece makes two pieces ([bg-wiki](https://www.bg-wiki.com/ffxi/Jhakri_Ring)).
- **When:** in the precast set, to shorten casting time. If the pieces are also on in the midcast set, the Fast Cast cuts recast by half its value, rounded down ([ffxi-mechanics.md](ffxi-mechanics.md#recast)).
- **Cost:** no Jhakri piece has Fast Cast of its own. The first piece adds nothing and each piece after it adds 3%. Dedicated Fast Cast pieces in the same slots usually give much more, for example `Atro. Chapeau +4` at 16% or `Amalric Coif +1` at 11%.
- **Vanar owns:** `Jhakri Coronal +2`, `Jhakri Robe +2`, `Jhakri Cuffs +2`, `Jhakri Slops +2`, `Jhakri Pigaches +2` and `Jhakri Ring`. Any five of the six give the maximum, +12%.

### Serpentes set

Two pieces, worn by WHM, BLM, RDM, BRD, SMN, BLU, SCH and GEO. Level 80, with no item level. bg-wiki has no page for the set; the set line is on both item pages ([bg-wiki](https://www.bg-wiki.com/ffxi/Serpentes_Cuffs), [bg-wiki](https://www.bg-wiki.com/ffxi/Serpentes_Sabots)).

| Pieces worn | Bonus |
|---|---|
| Cuffs and Sabots | "Cure" potency +5% |

- The +5% is for the pair, not +5% from each piece. FFXIclopedia's set summary lists it once ([FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Serpentes_Armor_Set)). It is ordinary Cure potency, inside the 50% cap.
- **When:** in the Cure midcast set.
- Their latents are mirror images. The Cuffs give Regen by day and Refresh by night, and the Sabots give Refresh by day and Regen by night. Together they give Regen and Refresh at all hours.
- **Vanar owns both:** `Serpentes Cuffs` and `Serpentes Sabots`.

### Bladeborn and Steelflash set

Two earrings, all jobs, level 99 with no item level. ([bg-wiki](https://www.bg-wiki.com/ffxi/Bladeborn_Earring), [bg-wiki](https://www.bg-wiki.com/ffxi/Steelflash_Earring))

| Pieces worn | Bonus |
|---|---|
| Both earrings | "Double Attack" +7% |

- The 7% is for the pair, not 7% from each earring. bg-wiki's Double Attack page lists the pair as one 7% source ([bg-wiki](https://www.bg-wiki.com/ffxi/Double_Attack)). Either earring alone gives only its own stats.
- **When:** in the engaged and weapon skill sets. Double Attack can go off up to twice per weapon skill (bg-wiki, Double Attack). The pair takes both ear slots.
- **Vanar owns both:** `Bladeborn Earring` and `Steelflash Earring`.

### Dudgeon and Heartseeker set

Two earrings, all jobs, level 99 with no item level. ([bg-wiki](https://www.bg-wiki.com/ffxi/Dudgeon_Earring), [bg-wiki](https://www.bg-wiki.com/ffxi/Heartseeker_Earring))

| Pieces worn | Bonus |
|---|---|
| Both earrings | "Dual Wield" +7% |

- The 7% is for the pair. Either earring alone gives only its own stats.
- **When:** in the engaged set, and only while dual wielding. The pair takes both ear slots. `Suppanomimi` gives Dual Wield +5% from one ear.
- **Vanar owns both:** `Dudgeon Earring` and `Heartseeker Earring`.

### Lifestorm and Psystorm set

Two earrings, all jobs, level 99 with no item level. ([bg-wiki](https://www.bg-wiki.com/ffxi/Lifestorm_Earring), [bg-wiki](https://www.bg-wiki.com/ffxi/Psystorm_Earring))

| Pieces worn | Bonus |
|---|---|
| Both earrings | Magic Accuracy +12 |

- Each earring's text says `Set: Magic Accuracy+12`, and bg-wiki doesn't say whether that is +12 in total or +12 from each. The other earring pairs list their total, so +12 in total is the likely reading. That reading is unconfirmed.
- On their own, each earring has Enmity-1, and Lifestorm has MND+4 and Psystorm INT+4.
- **When:** in the midcast set, where magic accuracy is read. The pair takes both ear slots.
- **Vanar owns both:** `Lifestorm Earring` and `Psystorm Earring`. [Lifestorm Earring](#lifestorm-earring) and [Psystorm Earring](#psystorm-earring) compare the pair with Vanar's other ear pairings.

### Ayanmo set

Ambuscade armor. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Ambuscade_Rewards#Ayanmo_Armor_Sets))

| Pieces worn | STR, VIT and MND |
|---|---|
| 2 | +8 |
| 3 | +16 |
| 4 | +24 |
| 5 or 6 | +32 |

- **What counts:** Ayanmo +2 armor and the Ayanmo Ring. NQ and +1 armor don't count ([bg-wiki](https://www.bg-wiki.com/ffxi/Ayanmo_Ring)).
- **Vanar owns:** only `Ayanmo Ring`, so the bonus never applies. The ring's own stats still count.

### Amalric set

([bg-wiki](https://www.bg-wiki.com/ffxi/Amalric_Attire_Set))

| Pieces worn | "Magic Atk. Bonus" |
|---|---|
| 2 | +20 |
| 3 | +30 |
| 4 | +40 |
| 5 | +50 |

- Only Amalric +1 pieces have the bonus.
- **Vanar owns:** only `Amalric Coif +1`, so the bonus never applies.

### Carmine set

([bg-wiki](https://www.bg-wiki.com/ffxi/Carmine_Armor_Set))

| Pieces worn | Accuracy |
|---|---|
| 2 | +20 |
| 3 | +30 |
| 4 | +40 |
| 5 | +50 |

- Only Carmine +1 pieces have the bonus.
- **Vanar owns:** only `Carmine Cuisses +1`, so the bonus never applies.

### Adhemar set

([bg-wiki](https://www.bg-wiki.com/ffxi/Adhemar_Attire_Set))

| Pieces worn | Critical hit rate |
|---|---|
| 2 | +4% |
| 3 | +6% |
| 4 | +8% |
| 5 | +10% |

- Only Adhemar +1 pieces have the bonus. NQ pieces have none.
- **Vanar owns:** `Adhemar Bonnet`, `Adhemar Jacket` and `Adhemar Wristbands`, all NQ, so the bonus never applies. These NQ pieces can't be worn on RDM anyway.

### Rubeus set

([bg-wiki](https://www.bg-wiki.com/ffxi/Rubeus_Attire_Set))

| Pieces worn | Fast Cast |
|---|---|
| 2 or 3 | +4% |
| 4 or 5 | +10% |

- **Vanar owns:** only `Rubeus Boots`, so the bonus never applies. BLU can't wear the boots.

### Regal set

The Regal accessories drop from Ou in Omen. Three of them carry a set line. It doesn't form a set of its own: it counts as one more piece toward any Reforged Artifact +2, +3 or +4 set, here [Atrophy](#atrophy-set) and [Assimilator's](#assimilators-set). The 5-piece cap of +60 still applies. ([bg-wiki](https://www.bg-wiki.com/ffxi/Regal_Earring), [bg-wiki](https://www.bg-wiki.com/ffxi/Category:Omen_Rewards))

- Of the three, only `Regal Earring` can be worn by RDM or BLU. Regal Ring is for melee jobs, and Regal Belt's bonus is for avatars only. The other Regal pieces have no set line.
- **Vanar owns no Regal accessory.** A Regal Earring would raise his Atrophy maximum to +60 and his Assimilator's maximum to +45.

### Sets with no set bonus

bg-wiki's set pages show no set bonus for these, and no help text of their items in the export has a `Set:` line. Wearing several pieces together adds nothing beyond each piece's own stats and augments.

- Odyssey sets: Nyame ([bg-wiki](https://www.bg-wiki.com/ffxi/Nyame_Armor_Set)), Bunzi's ([bg-wiki](https://www.bg-wiki.com/ffxi/Bunzi%27s_Attire_Set)), Gleti's ([bg-wiki](https://www.bg-wiki.com/ffxi/Gleti%27s_Armor_Set)), and Sakpata's ([bg-wiki](https://www.bg-wiki.com/ffxi/Sakpata%27s_Armor_Set)), which Vanar doesn't own.
  - Vanar's ranks **(player, 2026-10-02):** `Nyame Helm`, `Nyame Mail`, `Nyame Flanchard` and `Nyame Sollerets` are Path B at rank 20. `Nyame Gauntlets` and every Bunzi's and Gleti's piece, including `Bunzi's Rod` and `Gleti's Knife`, are rank 0, with base stats only. [rank-augments.md](rank-augments.md) has their augments at his ranks and at every other rank.
  - Every Bunzi's and Gleti's armor piece's help text closes with a `Pet:` block: Accuracy, Ranged Accuracy and Magic Accuracy +50. Those are the pet's; bg-wiki's set pages list them as pet stats ([bg-wiki](https://www.bg-wiki.com/ffxi/Bunzi%27s_Attire_Set), [bg-wiki](https://www.bg-wiki.com/ffxi/Gleti%27s_Armor_Set)). The wearer's own values are Accuracy +40, Attack +40 and Magic Accuracy +40 per piece. The other lines after `Pet:` are the pet's too: Damage taken -8% on Gleti's Gauntlets, `Avatar: Lv.+1` on Bunzi's Sabots and `Summoned Pet: Lv.+1` on Gleti's Boots.
- Relic sets: Vitiation ([bg-wiki](https://www.bg-wiki.com/ffxi/Vitiation_Armor_Set)), Luhlaza ([bg-wiki](https://www.bg-wiki.com/ffxi/Luhlaza_Attire_Set)), Duelist's ([bg-wiki](https://www.bg-wiki.com/ffxi/Duelist%27s_Attire_Set)) and Mirage ([bg-wiki](https://www.bg-wiki.com/ffxi/Mirage_Attire_Set)). `Dls. Torque +1` and `Mirage Stole +2` are job necks and belong to no set.
- Other armor: Rawhide, Despair, Haruspex, Merlinic, Chironic, Herculean ([bg-wiki](https://www.bg-wiki.com/ffxi/Herculean_Armor_Set)), Telchine, Odyssean, Valorous, Vanya, Taeon, Psycloth, Gendewitha, Helios and Magna (the MG and MGM pieces). Each was checked on its bg-wiki set page.

## Weapons (main hand)

### Akademos

*Akademos. SCH only; not RDM or BLU.*

- wsdist: its only entry is "Akademos R15C", Nolan Path C at rank 15, which adds INT, Magic Accuracy and Magic Atk. Bonus +15 that Vanar's unaugmented copy lacks. The staff is SCH only, so it never enters a RDM or BLU run. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), line 131)

### Almace

*Almace.*

- The export prints only "Almace", a name nine items share, from the Level 80 stage up to iL119 III. The help text that name matches (DMG:52, no stats) is the Level 80 stage's, so the export can't tell which stage Vanar owns. ([bg-wiki](https://www.bg-wiki.com/ffxi/Almace), [bg-wiki](https://www.bg-wiki.com/ffxi/Almace_%28Level_80%29))
- The iL119 III stage has DMG:158, DEX+50, Magic Damage+186, Sword skill +269 and Magic Accuracy skill +255. ([bg-wiki](https://www.bg-wiki.com/ffxi/Almace_%28Level_119_III%29))
- The iL119 and iL119 II stages have DMG:114, DEX+20, Sword skill +242 and Magic Accuracy skill +215. ([bg-wiki](https://www.bg-wiki.com/ffxi/Almace_%28Level_119%29), [bg-wiki](https://www.bg-wiki.com/ffxi/Almace_%28Level_119_II%29))
- Chant du Cygne with Almace in the main hand gives an Aftermath. It procs only on Almace's own melee hits, Double and Triple Attack hits included, and never on weapon skills, Counters or Retaliations. ([bg-wiki](https://www.bg-wiki.com/ffxi/Empyrean_Aftermath))
- iL119 III's Aftermath triples damage on 30/40/50% of hits for 60/120/180 s at 1000-1999/2000-2999/3000 TP. iL119 and iL119 II double it for 30/60/90 s. The Level 80 stage has none. ([bg-wiki](https://www.bg-wiki.com/ffxi/Empyrean_Aftermath))
- TP Bonus doesn't raise the Aftermath tier, so Chant du Cygne at 1000 TP gives AM1 even with Thibron's TP Bonus +1000. ([bg-wiki](https://www.bg-wiki.com/ffxi/TP_Bonus))
- Any later Chant du Cygne overwrites AM1. AM2 yields only to AM3, and AM3 to nothing. ([bg-wiki](https://www.bg-wiki.com/ffxi/Aftermath))
- In the sub slot, Aftermath, Magic Accuracy skill and any REMA augment do nothing. ([bg-wiki](https://www.bg-wiki.com/ffxi/Dual_Wield))
- In the sub slot its DEX still counts for both hands (DEX+50 on iL119 III, +20 on iL119 and II; Accuracy from DEX is floor(DEX × 0.75)). Its DMG and Sword skill count only for its own off-hand hits. ([bg-wiki](https://www.bg-wiki.com/ffxi/Dual_Wield), [bg-wiki](https://www.bg-wiki.com/ffxi/Accuracy))
- RDM can hold it in the sub slot only with /NIN or /DNC for Dual Wield. ([bg-wiki](https://www.bg-wiki.com/ffxi/Dual_Wield))
- No augment shows on this copy, so it is rank 0. It lacks the Ultimate Weapon (REMA) augment, which only the iL119 III stage takes. Rank 0 says nothing about the stage. At rank 15 (max) the augment adds DMG+5, Chant du Cygne damage +10% and DEX/MND+20, all main hand only. ([bg-wiki](https://www.bg-wiki.com/ffxi/BGWiki:Ultimate_Weapon_Augments), [rank-augments.md](rank-augments.md#oboro-rank-augments-maximum-only))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Chant du Cygne (Mid buff, High buff); Evisceration (Mid buff, High buff); BLU: Chant du Cygne (Mid buff, High buff). All of them assume Almace Level 119 III, and the export doesn't show Vanar's stage (above). In Evisceration it is the off hand, behind Tauret.
- wsdist: it has only the iL119 III stage. There is no iL119 or iL119 II entry (DMG 114, DEX+20), so a run overstates Vanar's copy if it isn't III. Its "Almace R15 (sub)" entry also keeps the main-hand-only REMA DMG+5. Vanar's copy has no REMA augment, but "Select all File" keeps only the R15 entries, so a run loaded that way gives him DMG+5, DEX and MND+20 and Chant du Cygne +10% in the main hand, and DMG+5 in the sub. "Import selections" can pick the plain "Almace" and "Almace (sub)" instead ([ffxi-mechanics.md](ffxi-mechanics.md#wsdist-kastras-damage-simulator), Getting Vanar's gear into the GUI). ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), lines 107-110; [gui_main.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gui_main.py), lines 490-491; [weapon_bonus.py](https://github.com/IzaKastra/wsdist_beta/blob/main/weapon_bonus.py), line 58)

### Apkallu Scepter

*Apkallu Scepter.*

- Costume item: it turns you into a random Apkallu. It has no combat use.
- Usable 30 s after you equip it, then once an hour (3600 s reuse). ([bg-wiki](https://www.bg-wiki.com/ffxi/Apkallu_Scepter))

### Ark Saber

*Ark Saber.*

- Costume item for the Ark Angel HM costume. It has no combat use.
- Usable 30 s after you equip it, with a 1 h reuse. ([bg-wiki](https://www.bg-wiki.com/ffxi/Ark_Saber))

### Ark Sword

*Ark Sword.*

- Costume item for the Ark Angel EV costume. It has no combat use.
- Usable 30 s after you equip it, with a 1 h reuse. ([bg-wiki](https://www.bg-wiki.com/ffxi/Ark_Sword))

### Ark Tabar

*Ark Tabar.*

- Costume item for the Ark Angel MR costume. It has no combat use.
- Usable 30 s after you equip it, with a 1 h reuse. ([bg-wiki](https://www.bg-wiki.com/ffxi/Ark_Tabar))

### Ark Tachi

*Ark Tachi.*

- Costume item for the Ark Angel GK costume. It has no combat use.
- Usable 30 s after you equip it, with a 1 h reuse. ([bg-wiki](https://www.bg-wiki.com/ffxi/Ark_Tachi))

### Bunzi's Rod

*Bunzi's Rod.*

- Vanar's copy is rank 0 (player, 2026-10-02). It exports with no "Path: A" and no augments, so it has only the base stats in its help text. Path A ranks up to 30; [rank-augments.md](rank-augments.md#bunzis-rod) gives every rank's values. ([bg-wiki](https://www.bg-wiki.com/ffxi/Bunzi%27s_Rod))
- Its Cure potency +30% counts toward the 50% Cure potency cap, not the separate 30% Cure potency II cap. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Cure_Spell))
- Its Cure potency also boosts blue magic heals such as Magic Fruit. ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Fruit))
- Its Magic burst damage +10 counts toward the 40% Magic Burst damage I cap. ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Burst))
- In the sub slot its Magic Accuracy skill +255 doesn't count, because only the main hand's does. Its DMG and Club skill count only for its own hits. ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Accuracy_Skill), [bg-wiki](https://www.bg-wiki.com/ffxi/Dual_Wield))
- In the sub slot, Accuracy+40, Magic Accuracy+40, Magic Atk. Bonus+35 and INT/MND+15 still apply. ([bg-wiki](https://www.bg-wiki.com/ffxi/Dual_Wield))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Sanguine Blade (Mid buff); Casting (Free Nuke, Magic Burst); BLU: Sanguine Blade (Mid buff, Ice Brand enabled). In Sanguine Blade it is the off hand. Vanar's copy is rank 0, without the rank 30 augment (DMG+11, Magic Atk. Bonus +30, Accuracy and Magic Accuracy +15, Enmity-5), so the sims overvalue it ([rank-augments.md](rank-augments.md#bunzis-rod)).
- wsdist: its rank 0 entry has DMG 152 (144 plus the rank 15 +8); the base is 144. Only the rod's own physical hits are affected. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), line 102)

### Chac-chacs

*Chac-chacs.*

- Cosmetic only: swinging it shows music notes, the same effect as Maestro's Baton. It has no stats or combat use. ([bg-wiki](https://www.bg-wiki.com/ffxi/Chac-chacs))

### Chatoyant Staff

*Chatoyant Staff.*

- Hidden effects: Magic Accuracy+30 and magic potency +15% for every element, plus Iridescence 10%. ([bg-wiki](https://www.bg-wiki.com/ffxi/Chatoyant_Staff))
- Iridescence raises the weather bonus to 20% for single weather and 35% for double, and makes opposed-weather penalties larger too. An elemental obi forces the weather proc. Iridescence does nothing for the day bonus. ([bg-wiki](https://www.bg-wiki.com/ffxi/Iridescence))
- It has no item level, so it has no Magic Accuracy skill. As a staff it is two-handed, so it removes the sub. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Elemental_Staves), [bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Accuracy_Skill))
- Vanar's Bunzi's Rod beats it for nukes and enfeebles: Magic Accuracy+40 plus Magic Accuracy skill 255 vs +30, Magic Atk. Bonus+35 and Magic Damage+248 vs a hidden 15% boost, and INT/MND+15 vs +5. ([bg-wiki](https://www.bg-wiki.com/ffxi/Bunzi%27s_Rod))
- For Cure it isn't a clear-cut win. Bunzi's Rod has the higher Cure potency (+30% vs +10%), but bg-wiki doesn't settle whether the staff's hidden 15% boost also applies to Cures (Magic Fruit's page says light-affinity staves enhance it). ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Fruit), [bg-wiki](https://www.bg-wiki.com/ffxi/Cure_Formula))

### Chimeric Fleuret

*Chimeric Fleuret. RDM only.*

- The latent Double Attack +4% is on only while an Enspell buff is active. ([bg-wiki](https://www.bg-wiki.com/ffxi/Chimeric_Fleuret))
- Sword enhancement spell damage +7 adds only to this sword's own hits, and only while it is worn during the attack round. That makes it melee-time Enspell gear, which the [player's rules](ffxi-mechanics.md#player-rules-for-these-jobs) exclude. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Enspell))
- Vanar's Pukulatmuj +1 beats it for every RDM use: Sword enhancement spell damage +11 vs +7, Enhancing magic skill +11 for the Enspell cast, and iL119 with Sword skill +242 and DMG:116. Chimeric is level 89 with no skill bonus. ([bg-wiki](https://www.bg-wiki.com/ffxi/Pukulatmuj_%2B1))

### Colada

*Colada.*

- Colada isn't Rare, and Vanar owns two copies. Name each copy by its augments, because a bare "Colada" can equip either one. ([bg-wiki](https://www.bg-wiki.com/ffxi/Colada))
- Both copies have Fast Cast +4%. It counts only when Colada is in the main hand at precast, so it helps casts started while Colada is the idle weapon, not casts started while engaged with other weapons. ([bg-wiki](https://www.bg-wiki.com/ffxi/Colada))
- Copy `'Weapon skill damage +2%','DEX+4','Accuracy+12','Attack+10','DMG:+14'`: an Oseem melee-path roll. WSD +2% (known max +3), DEX+4 (max 10, or 15 with Taupe Stones), Accuracy+12 and Attack+10 (max 20, or 25 with Pellucid Stones), DMG+14 (max 20). ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Escha_Rewards/Arcane_Glyptics_Inscription))
- Copy `'Weapon skill damage +2%','DEX+4','Accuracy+12','Attack+10','DMG:+14'`: in the sub slot its WSD, DEX, Accuracy and Attack apply to both hands, and its DMG only to its own hits. ([bg-wiki](https://www.bg-wiki.com/ffxi/Dual_Wield))
- Copy `'"Refresh"+2','Mag. Acc.+11','"Mag.Atk.Bns."+12','DMG:+1'`: an Oseem magic-path roll. Refresh +2 is the top of Colada's known Refresh range (+1 to 2). Mag. Acc.+11 and Magic Atk. Bonus+12 are mid rolls (max 20, or 25 with Pellucid Stones). ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Escha_Rewards/Arcane_Glyptics_Inscription))
- Copy `'"Refresh"+2','Mag. Acc.+11','"Mag.Atk.Bns."+12','DMG:+1'`: equipping anything in main or sub resets TP. If this copy goes in the main hand whenever you're not engaged, any TP left when you disengage is lost. ([bg-wiki](https://www.bg-wiki.com/ffxi/TP))

### Demers. Degen +1

*Demersal Degen +1. RDM, not BLU.*

- The "+25" in the help text is Dark resistance +25 (its icon is lost).
- Its Fast Cast +1 to 3% follows the Unity's weekly ranking (a higher rank gives more). Neither the export nor the help text shows the current value. ([bg-wiki](https://www.bg-wiki.com/ffxi/Demers._Degen_%2B1), [bg-wiki](https://www.bg-wiki.com/ffxi/Category:Unity_Concord))
- Colada's fixed Fast Cast +4% beats it for precast. ([bg-wiki](https://www.bg-wiki.com/ffxi/Colada))
- "Occasionally attacks twice" procs 45% of the time.
- Its melee hits are piercing, but its weapon skills stay slashing.
- This copy shows no rank. Rank 15 would add Accuracy and Magic Accuracy +45, DEX+10, and Sword enhancement spell damage +50% for this weapon's own Enspell hits. ([bg-wiki](https://www.bg-wiki.com/ffxi/Demers._Degen_%2B1))

### Enhancing Sword

*Enhancing Sword. RDM only.*

- The latent Accuracy+8 and Attack+16 need an Enspell buff active. ([bg-wiki](https://www.bg-wiki.com/ffxi/Enhancing_Sword))
- The +5 Enspell damage applies only to this sword's own hits, and only while it is worn during the attack round. That makes it melee-time Enspell gear, which the [player's rules](ffxi-mechanics.md#player-rules-for-these-jobs) exclude. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Enspell))
- Vanar's Pukulatmuj +1 beats it for every RDM use: Sword enhancement spell damage +11 vs +5, Enhancing magic skill +11, and an iL119 Sword skill +242. Enhancing Sword is level 68 with no skill bonus. ([bg-wiki](https://www.bg-wiki.com/ffxi/Pukulatmuj_%2B1))

### Eosuchus Club

*Eosuchus Club.*

- Vanar's Bunzi's Rod matches or beats it on every stat it has, in either hand: Magic Accuracy skill 255 vs 215, Magic Accuracy+40 vs +10, Magic Damage+248 vs +100, INT/MND+15 vs +6, and the same Club skill +242.
- Bunzi's Rod also adds Accuracy+40 and Magic Atk. Bonus+35, so this club has no RDM or BLU use. ([bg-wiki](https://www.bg-wiki.com/ffxi/Eosuchus_Club), [bg-wiki](https://www.bg-wiki.com/ffxi/Bunzi%27s_Rod))

### Fettering Blade

*Fettering Blade. RDM, not BLU.*

- In the sub slot, its Critical hit rate +4%, DMG and Sword skill count only for its own hits, and its Magic Accuracy skill +201 doesn't count at all.
- In the sub slot, STR/MND+12, Accuracy+27, Magic Accuracy+15 and Magic Atk. Bonus+14 apply to both hands. ([bg-wiki](https://www.bg-wiki.com/ffxi/Fettering_Blade), [bg-wiki](https://www.bg-wiki.com/ffxi/Dual_Wield))

### Gleti's Knife

*Gleti's Knife. RDM, not BLU.*

- Vanar's copy is rank 0 (player, 2026-10-02). It exports with no "Path: A" and no augments, so it has only the base stats in its help text. Path A ranks up to 30; [rank-augments.md](rank-augments.md#gletis-knife) gives every rank's values. ([bg-wiki](https://www.bg-wiki.com/ffxi/Gleti%27s_Knife))
- In the sub slot, its Critical hit rate +5%, DMG and Dagger skill apply only to Gleti's own hits: its off-hand swings and the extra off-hand weapon skill hit. So its Critical hit rate +5% doesn't raise Almace's or Tauret's crit rate.
- In the sub slot, its Magic Accuracy skill +242 doesn't count.
- In the sub slot, DEX/AGI+15, Accuracy+40, Attack+30, Magic Accuracy+40, Triple Attack+6% and Haste+2% apply to both hands.
- RDM needs /NIN or /DNC to dual wield it. ([bg-wiki](https://www.bg-wiki.com/ffxi/Dual_Wield), [bg-wiki](https://www.bg-wiki.com/ffxi/Gleti%27s_Knife))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Chant du Cygne (Mid buff, High buff); Mercy Stroke (Mid buff). In all three it is the off hand. Vanar's copy is rank 0, without the rank 30 augment (DMG+11, Attack+45, Accuracy and Magic Accuracy +15, Subtle Blow II +10), so the sims overvalue it ([rank-augments.md](rank-augments.md#gletis-knife)).
- wsdist: the stats are right at every rank, but in the sub slot its Critical hit rate +5% goes into one crit rate shared by both hands, so it also raises the main hand's melee and Chant du Cygne crits. ([create_player.py](https://github.com/IzaKastra/wsdist_beta/blob/main/create_player.py), lines 651-675)

### Heartbeater

*Heartbeater.*

- Not Rare: Vanar has two identical unaugmented copies, both in the Mog Safe.
- It's a stat-less 1-damage club with no RDM or BLU use. ([bg-wiki](https://www.bg-wiki.com/ffxi/Heartbeater))

### Ibushi Shinai

*Ibushi Shinai.*

- Its only use is the Feast of Swords seasonal event, where it absorbs the Armor's TP moves (Aetheral Toxin, Edge of Death).
- It has 1 charge, can be used 10 s after you equip it, and has a 15 s reuse. ([bg-wiki](https://www.bg-wiki.com/ffxi/Ibushi_Shinai))

### Iris

*Iris. BLU only.*

- This copy carries Nolan's Path D at its Rank 15 values, so it is fully ranked. Totals: Blue magic skill +30 (15 native + 15), Magic Accuracy +15 and Magic Atk. Bonus +29. ([bg-wiki](https://www.bg-wiki.com/ffxi/Nolan))
- It is Vanar's only weapon with Blue magic skill, which raises magical blue magic accuracy and potency and physical blue magic damage. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Blue_Magic))
- "Chain Affinity"+25 adds +25 base damage to every hit of a physical blue magic spell cast under Chain Affinity. Unlike blue magic skill, this bonus is not limited by the spell's damage cap.
- That spell consumes all your TP, and changing the main weapon resets TP, so swapping Iris in just for the cast throws that TP away. The bonus fits only when Iris is already the engaged weapon. ([bg-wiki](https://www.bg-wiki.com/ffxi/Chain_Affinity))
- Its Blue magic spellcasting time -7% stacks with Fast Cast. As a casting-time stat, it only needs to be worn at precast. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Blue_Magic))

### Joyeuse

*Joyeuse. RDM, not BLU.*

- "Occasionally attacks twice" procs about 45% of the time.
- Its melee hits deal piercing damage, but weapon skills stay slashing. ([bg-wiki](https://www.bg-wiki.com/ffxi/Joyeuse))
- The glyph before +14 in the help text is the Dark element icon: Dark resistance +14. ([FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Joyeuse))

### Jugo Kukri

*Jugo Kukri. THF only.*

- The Unity AGI bonus is between +10 and +15, depending on your Unity's faction rank, which is re-tallied every week. ([bg-wiki](https://www.bg-wiki.com/ffxi/Jugo_Kukri), [bg-wiki](https://www.bg-wiki.com/ffxi/Category:Unity_Concord))
- The glyph before +15 is the Wind element icon: Wind resistance +15. ([FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Template:Resist))

### Kgd. Signet Staff

*Kingdom Signet Staff.*

- It holds 25 charges of Signet, usable 30 s after you equip it, with a 1 s cast and a 10 s reuse, on yourself or a party or alliance member. ([bg-wiki](https://www.bg-wiki.com/ffxi/Kgd._Signet_Staff))
- Signet earns Conquest Points and crystal drops only outside the Aht Urhgan and Wings of the Goddess areas, which use Sanction and Sigil instead. ([bg-wiki](https://www.bg-wiki.com/ffxi/Signet))

### Kustawi +1

*Kustawi +1. Not RDM or BLU.*

- The Unity Rapid Shot bonus is between +3 and +7, depending on your Unity's faction rank.
- This copy has no Unity/Odyssey augment. At Rank 15 that augment would add Ranged Attack +20, Ranged Accuracy and Magic Accuracy +40 and Enmity -5. ([bg-wiki](https://www.bg-wiki.com/ffxi/Kustawi_%2B1))
- wsdist: its only entry is labeled R25, but the item ranks only to 15, and the values are rank 15's: Ranged Attack +20, Ranged Accuracy and Magic Accuracy +40 over Vanar's unaugmented copy. RDM and BLU can't equip it. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), line 174)

### Lehbrailg +2

*Lehbrailg +2. RDM, not BLU.*

- Vanar's Marin Staff +1 strictly beats it. Both have INT/MND +12 and Magic Accuracy skill +228, but Marin Staff +1 adds Magic Accuracy +15 (this has none), Magic Atk. Bonus +28 vs +22, Magic Damage +217 vs +202, higher DMG, Fast Cast +3% and Unity INT. ([bg-wiki](https://www.bg-wiki.com/ffxi/Marin_Staff_%2B1))
- This copy has none of the Skirmish (Wailing Stone) augments it can take. ([bg-wiki](https://www.bg-wiki.com/ffxi/Lehbrailg_%2B2))

### Lightreaver

*Lightreaver. WAR only.*

- bg-wiki puts its Additional effect: Death at roughly 5% on ordinary monsters, a figure it flags as needing verification.
- bg-wiki says it never procs on NMs, Apex monsters, BCNMs, high-tier mission battlefields or Salvage. ([bg-wiki](https://www.bg-wiki.com/ffxi/Lightreaver))

### Marin Staff +1

*Marin Staff +1. RDM, not BLU.*

- Wind Elemental MAB +11 is 11% wind affinity. It works only on wind-element spells and sits in a separate damage multiplier from ordinary Magic Atk. Bonus, where it adds to Orpheus's Sash's affinity. ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Damage))
- The Unity INT bonus is between +10 and +15, depending on your Unity's faction rank, which is re-tallied every week. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Unity_Concord))
- This copy has no Unity/Odyssey augment. At Rank 15 that augment would add Magic Atk. Bonus +40, Accuracy and Magic Accuracy +40 and INT/MND +10. ([bg-wiki](https://www.bg-wiki.com/ffxi/Marin_Staff_%2B1))
- wsdist: its only entry is rank 15, which adds Magic Accuracy and Magic Atk. Bonus +40 and INT/MND +10 over Vanar's rank 0 copy, and assumes Unity INT +14. It also leaves out rank 15's Accuracy +40. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), line 100)

### Maxentius

*Maxentius.*

- The magic burst bonus is 4% per skillchain in the chain being burst: a two-weapon-skill chain gives 4%, and a four-weapon-skill chain to Double Light gives 12%. ([bg-wiki](https://www.bg-wiki.com/ffxi/Maxentius))
- The magic burst bonus works only in the main hand and counts toward the 40% Magic burst damage I cap. ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Burst))
- In the main hand it gives Black Halo with no club-skill or quest requirement. ([bg-wiki](https://www.bg-wiki.com/ffxi/Maxentius))
- Its +50% Black Halo damage applies to every hit, as a separate multiplier from weapon skill damage gear. ([bg-wiki](https://www.bg-wiki.com/ffxi/Weapon_Skill_Damage))
- In the sub slot its Black Halo, magic burst bonus and Magic Accuracy skill +250 do nothing, and its Club skill counts only for its own hits.
- In the sub slot, Accuracy and Magic Accuracy +40, Magic Atk. Bonus +21 and INT/MND/CHR +15 still count. ([bg-wiki](https://www.bg-wiki.com/ffxi/Dual_Wield))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Death Blossom (High buff); Black Halo (Mid buff, High buff); BLU: Requiescat (High buff). In Death Blossom and Requiescat it is the off hand.
- wsdist: it stores the burst bonus as a flat Magic burst damage +4 that also counts from the sub slot, where BLU's `sets.Weapons.Casting` puts it. In game it works only in the main hand, at 4% per skillchain. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), line 101)

### Mpu Gandring

*Mpu Gandring. RDM, not BLU.*

- Four prime-dagger stages share this name: Incomplete, Level 119, Level 119 II and Level 119 III. The export prints only the name, so Vanar's stage is unknown. Item 21587, the Incomplete stage, is just the lowest ID with that name. ([bg-wiki](https://www.bg-wiki.com/ffxi/Mpu_Gandring))
- Incomplete: DMG 117, Dagger and Magic Accuracy skill +252, with no stats, Triple Attack or Aftermath. The other three add DEX/AGI/CHR, Accuracy and Magic Accuracy, Triple Attack and a Ruthless Stroke Aftermath. Level 119: DMG 124, stats +25, skills +260, Triple Attack +3%. Level 119 II: DMG 130, stats +30, skills +269, Triple Attack +4%. Level 119 III: DMG 137, stats +35, skills +277, Triple Attack +6%. (bg-wiki: [Incomplete](https://www.bg-wiki.com/ffxi/Mpu_Gandring_%28Incomplete%29), [Level 119](https://www.bg-wiki.com/ffxi/Mpu_Gandring_%28Level_119%29), [Level 119 II](https://www.bg-wiki.com/ffxi/Mpu_Gandring_%28Level_119_II%29), [Level 119 III](https://www.bg-wiki.com/ffxi/Mpu_Gandring_%28Level_119_III%29))
- The Incomplete stage's "Slowly devours your soul" drains 1 HP and 1 MP every tick and can kill you. If Vanar's copy is that stage, it must never be left on in an idle set. The Level 119 stage's help text doesn't list it. ([bg-wiki](https://www.bg-wiki.com/ffxi/Mpu_Gandring_%28Incomplete%29))
- If Vanar's copy is the Incomplete stage, his Gleti's Knife outclasses it for RDM dagger melee: Dagger skill +255 vs +252, Accuracy +40, Attack +30 and Triple Attack +6% at the same damage per delay. The higher stages have more Dagger skill (+260 to +277) and DMG (124 to 137). ([bg-wiki](https://www.bg-wiki.com/ffxi/Gleti%27s_Knife))
- If Vanar's copy is the Incomplete stage, his Bunzi's Rod outclasses it as a magic-accuracy main hand: Magic Accuracy skill +255 plus Magic Accuracy +40, against +252 and none. Level 119 has +260 and +25, so the rod still leads on these two stats (295 against 285). Level 119 II has +269 and +30 (299), and Level 119 III +277 and +35 (312), so both pass it. ([bg-wiki](https://www.bg-wiki.com/ffxi/Bunzi%27s_Rod), [Level 119](https://www.bg-wiki.com/ffxi/Mpu_Gandring_%28Level_119%29))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Ruthless Stroke (Mid buff, High buff). Both assume Mpu Gandring Level 119 II, and the export doesn't show Vanar's stage (above).
- wsdist: it has only the Level 119 II ("Mpu Gandring IV") and 119 III ("V") stages, with no Incomplete or Level 119 entry. Its export import keeps "IV", so Vanar's dagger is simmed as Level 119 II. If his copy is the Incomplete stage, that adds DMG+13 and Dagger and Magic Accuracy skill +17, plus DEX/AGI/CHR +30, Accuracy and Magic Accuracy +30, Triple Attack 4%, a hidden damage proc and, given an aftermath level, prime aftermath PDL, none of which that stage has. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), lines 359-360; [actions.py](https://github.com/IzaKastra/wsdist_beta/blob/main/actions.py), lines 371-377; [create_player.py](https://github.com/IzaKastra/wsdist_beta/blob/main/create_player.py), lines 568-600)

### Naegling

*Naegling.*

- Its weapon skill attack bonus is +1% attack for each buff on you. It works only in the main hand and applies to every melee weapon skill, not just Savage Blade, but not to ranged weapon skills. ([bg-wiki](https://www.bg-wiki.com/ffxi/Naegling))
- In the main hand it gives Savage Blade with no skill or Old Wounds requirement. ([bg-wiki](https://www.bg-wiki.com/ffxi/Naegling))
- Its Savage Blade +15% applies to every hit, as a separate multiplier from weapon skill damage gear.
- Its Magic Damage +217 is not only for spells. bg-wiki's magical weapon skill formula adds the Magic Damage stat straight to base damage after fTP, and Magic Atk. Bonus multiplies it.
- So its Magic Damage and Magic Atk. Bonus +16 count for Sanguine Blade, Seraph Blade and Red Lotus Blade. Its weapon skill attack bonus does nothing for them. ([bg-wiki](https://www.bg-wiki.com/ffxi/Weapon_Skill_Damage))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Savage Blade (Mid buff, High buff); Naegling + Thibron TP (-50% DT, -25% DT); BLU: Savage Blade (Mid buff, High buff).

### Nehushtan

*Nehushtan.*

- Vanar's Maxentius strictly beats it: DMG 200 vs 184, delay 288 vs 352, INT/MND +15 vs +6, Accuracy +40 vs +27, Magic Accuracy +40 and Magic Atk. Bonus +21 (this has neither), Magic Damage +232 vs +130, Club skill +250 vs +228 and Magic Accuracy skill +250 vs +188. ([bg-wiki](https://www.bg-wiki.com/ffxi/Maxentius))
- This copy has none of the Alluvion Skirmish stone augments it can take. ([bg-wiki](https://www.bg-wiki.com/ffxi/Nehushtan))

### Nibiru Cudgel

*Nibiru Cudgel.*

- Nibiru Cudgel is not Rare, and Vanar owns two with different paths, so a set must name each copy by its augments. ([bg-wiki](https://www.bg-wiki.com/ffxi/Nibiru_Cudgel))
- Copy `'MND+10','Mag. Acc.+15','"Cure" potency +15%'`: Nolan's Path A at its Rank 15 values. Totals: Cure potency +25% (10 native + 15), MND +21 and Magic Accuracy +22. ([bg-wiki](https://www.bg-wiki.com/ffxi/Nolan))
- Copy `'MND+10','Mag. Acc.+15','"Cure" potency +15%'`: Cure potency counts toward the 50% Cure potency cap and belongs in the midcast set. Vanar's Bunzi's Rod gives Cure potency +30% in the same slot. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Cure_Spell))
- Copy `'Accuracy+15','Mag. Acc.+15','"Fast Cast"+3'`: Nolan's Path C at its Rank 15 values. Totals: Accuracy +15, Magic Accuracy +22 and Fast Cast +3%. It keeps the native Cure potency +10%. ([bg-wiki](https://www.bg-wiki.com/ffxi/Nolan))
- Copy `'Accuracy+15','Mag. Acc.+15','"Fast Cast"+3'`: the Fast Cast shortens casting time from the precast set, and only shortens recast if the cudgel is still worn at midcast. ([bg-wiki](https://www.bg-wiki.com/ffxi/Fast_Cast))

### Oynos Knife

*Oynos Knife. Not RDM or BLU.*

- Its Haste proc lasts the full 3 minutes and stays on after the knife is unequipped. ([bg-wiki](https://www.bg-wiki.com/ffxi/Oynos_Knife))

### Pukulatmuj +1

*Pukulatmuj +1.*

- Its Sword enhancement spell damage +11 adds only to the Enspell damage of Pukulatmuj's own hits, and only while it is worn during the attack round. It does nothing in a set worn just for the cast. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Enspell))
- Vanar's copy shows no augment, so its Unity augment is at rank 0. At rank 15 (max) the augment adds DMG +38, Accuracy and Magic Accuracy +30, and Sword enhancement spell damage +150%, which also counts only for this weapon's Enspell damage. ([bg-wiki](https://www.bg-wiki.com/ffxi/Pukulatmuj_%2B1), [rank-augments.md](rank-augments.md#oboro-rank-augments-maximum-only))
- Its Magic Accuracy skill +188 only counts in the main hand. ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Accuracy_Skill))
- wsdist: its only entry is rank 15, which adds DMG+36, Accuracy and Magic Accuracy +30 and Sword enhancement spell damage +150% over Vanar's unaugmented copy; bg-wiki gives the rank 15 DMG as +38. Its random-roll simulation also gives off-hand Enspell hits the main hand's Enspell damage %. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), line 133; [actions.py](https://github.com/IzaKastra/wsdist_beta/blob/main/actions.py), line 331)

### Ram Staff

*Ram Staff.*

- The Retrace enchantment has 1 charge, an 8 s cast, a 30 s equip delay and a 24-hour reuse. ([bg-wiki](https://www.bg-wiki.com/ffxi/Ram_Staff))

### Rounsey Wand

*Rounsey Wand.*

- The Teleport has an 8 s cast, a 30 s equip delay and a 7-day reuse.
- It only works if you have visited the Chocobo Circuit before. From there you can exit to Bastok, San d'Oria, Windurst or Jeuno, but not to Aht Urhgan Whitegate. ([bg-wiki](https://www.bg-wiki.com/ffxi/Rounsey_Wand))

### Secespita

*Secespita. RDM only.*

- Pukulatmuj +1 beats it in the main hand: Enhancing skill +11 vs +10, and Magic Accuracy skill +188 vs +84 (that stat only counts in the main hand). ([bg-wiki](https://www.bg-wiki.com/ffxi/Secespita))
- Its only other use is as a second skill weapon in the sub slot. That needs Dual Wield, which RDM only gets from a NIN or DNC subjob. There it gives +10, the same as Forfend +1 Path A at rank 15, a shield that needs no Dual Wield. ([bg-wiki](https://www.bg-wiki.com/ffxi/Forfend_%2B1), [bg-wiki](https://www.bg-wiki.com/ffxi/Dual_Wield))
- Its Sword enhancement spell damage +8 adds only to the Enspell damage of its own hits, and only while it is worn during the attack round.
- In the sub slot that means tier I Enspells only: a tier II Enspell adds damage to the first main-hand hit of each round, never to off-hand hits. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Enspell), [bg-wiki](https://www.bg-wiki.com/ffxi/Dual_Wield))

### Serenity

*Serenity. RDM, not BLU.*

- It is a two-handed staff, so equipping it takes off the sub slot (shield or offhand weapon; only a grip can go with it) and resets TP. ([bg-wiki](https://www.bg-wiki.com/ffxi/Serenity), [FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Category:Grips))
- Its Cure potency is 25% plus 4% from this copy's augment: 29% toward the 50% Cure potency cap. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Cure_Spell))
- Its Cure spellcasting time -8% only matters in precast. ([bg-wiki](https://www.bg-wiki.com/ffxi/Fast_Cast))
- bg-wiki lists the augment as MP+50, Enhancing magic skill +10, Cure potency +5% and Cure spellcasting time -10%. This copy has MP+45, +9, +4% and -8%. ([bg-wiki](https://www.bg-wiki.com/ffxi/Serenity))
- For Cure midcast, Vanar's Bunzi's Rod (Cure potency +30%, one-handed) beats its 29% and leaves the sub slot for a shield. ([bg-wiki](https://www.bg-wiki.com/ffxi/Bunzi%27s_Rod))
- For enhancing skill, Pukulatmuj +1 (+11) with Forfend +1 (+10 at Path A rank 15) beats its +9. ([bg-wiki](https://www.bg-wiki.com/ffxi/Forfend_%2B1))
- What it still adds over those is Cure spellcasting time -8% and Enmity -5. ([bg-wiki](https://www.bg-wiki.com/ffxi/Serenity))

### Soothsayer Staff

*Soothsayer Staff. RDM, not BLU.*

- Vanar's Bunzi's Rod with Ammurapi Shield beats it on every magic stat, with any grip Vanar owns: Magic Accuracy 333 vs at most 170 (counting the main-hand Magic Accuracy skill; Niobid Strap or Mephitis Grip add 5), Magic Atk. Bonus 73 vs at most 24, Magic Damage 248 vs 151, INT and MND 28 vs 18 and 19, and MP 98 vs at most 70. ([bg-wiki](https://www.bg-wiki.com/ffxi/Bunzi%27s_Rod), [bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Accuracy_Skill))
- As a staff, Serenity beats or ties it on every magic stat except MP (45 vs 50). That leaves it no RDM use. ([bg-wiki](https://www.bg-wiki.com/ffxi/Serenity))

### Taming Sari

*Taming Sari. THF, BRD and DNC only.*

- This copy's useful augment is Treasure Hunter +1, the value bg-wiki lists for this augment, so it only belongs in a THF, BRD or DNC Treasure Hunter set. ([bg-wiki](https://www.bg-wiki.com/ffxi/Taming_Sari))

### Tanmogayi +1

*Tanmogayi +1. BLU, not RDM.*

- Its Unity Ranking Fast Cast is +3% to +6%, set by the weekly ranking of Vanar's Unity (a higher rank gives more). ([bg-wiki](https://www.bg-wiki.com/ffxi/Tanmogayi_%2B1), [bg-wiki](https://www.bg-wiki.com/ffxi/Category:Unity_Concord))
- Rankings are tallied each week and apply to the following week, and only to members who earned at least a minimum number of accolades. Neither the export nor the help text shows the current value. ([FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Unity_Ranking))
- Swapping it into the main hand resets TP. ([mechanics](ffxi-mechanics.md#weapons-and-tp))
- Colada has a fixed Fast Cast +4%, so it beats Tanmogayi +1 at +3%, ties at +4%, and loses only at +5% or +6%. ([bg-wiki](https://www.bg-wiki.com/ffxi/Colada))
- Vanar's copy shows no augment. Path A (added at Unity NPCs after Odyssey Sheol C) at rank 15 would add DMG +11, Accuracy and Magic Accuracy +40 and Attack +40. Accuracy and Magic Accuracy start at rank 6 and Attack at rank 11. ([bg-wiki](https://www.bg-wiki.com/ffxi/Tanmogayi_%2B1))
- Its Magic Accuracy skill +188 only counts in the main hand. ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Accuracy_Skill))
- wsdist: its only entry is rank 15, which adds DMG+11 and Accuracy, Magic Accuracy and Attack +40 over Vanar's unaugmented copy. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), line 310)

### Tauret

*Tauret. RDM, not BLU.*

- Tauret grants Evisceration only while it is in the main hand, whatever the Dagger skill and without the Cloak and Dagger quest.
- Its Evisceration damage +50% applies to every hit of the weapon skill.
- Its low-TP critical hit bonus is +50% at 0 TP and falls to +0% at 3000 TP. It applies only to Tauret's own main-hand hits and is off during weapon skills. ([bg-wiki](https://www.bg-wiki.com/ffxi/Tauret))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Evisceration (Mid buff, High buff); Aeolian Edge (Mid buff).
- wsdist: in a melee round it adds the low-TP crit bonus to every hit, off hand included; in game only Tauret's own hits get it. It is rightly off during weapon skills. ([actions.py](https://github.com/IzaKastra/wsdist_beta/blob/main/actions.py), line 248)

### Tengu War Fan

*Tengu War Fan.*

- The Costume enchantment (a Yagudo model) has a 1 s cast, a 30 s equip delay and a 1-hour reuse. ([bg-wiki](https://www.bg-wiki.com/ffxi/Tengu_War_Fan))

### Thibron

*Thibron.*

- TP Bonus from an augment on a Magian weapon works from the sub slot for every weapon skill, whatever is in the main hand. Effective TP still caps at 3000. ([bg-wiki](https://www.bg-wiki.com/ffxi/TP_Bonus))
- Other Thibron copies can carry DMG +3 with Weapon skill damage +10% or with Store TP +17 instead. ([bg-wiki](https://www.bg-wiki.com/ffxi/Thibron))
- TP Bonus doesn't raise the Aftermath level, which counts actual TP only, so Expiacion at 1000 TP hits like 2000 but gives only Aftermath level 1. ([bg-wiki](https://www.bg-wiki.com/ffxi/Aftermath))
- Whether TP Bonus helps physical blue magic is disputed. The TP Bonus page says it does nothing, even under Chain Affinity or Azure Lore; the Moonshade Earring page says it can when Chain Affinity uses TP (bg-wiki: [TP Bonus](https://www.bg-wiki.com/ffxi/TP_Bonus), [Moonshade Earring](https://www.bg-wiki.com/ffxi/Moonshade_Earring); [ffxi-mechanics.md](ffxi-mechanics.md#physical-blue-magic)).
- In the sub slot it needs Dual Wield. BLU gets it from set blue magic; RDM has no Dual Wield trait and needs a NIN or DNC subjob. ([bg-wiki](https://www.bg-wiki.com/ffxi/Dual_Wield))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Savage Blade (Mid buff, High buff); Imperator (Mid buff, High buff); Red Lotus Blade (Mid buff); Ruthless Stroke (Mid buff, High buff); Black Halo (Mid buff, High buff); Aeolian Edge (Mid buff); Naegling + Thibron TP (-50% DT, -25% DT); BLU: Expiacion (Mid buff, High buff); Imperator (Mid buff, High buff); Savage Blade (Mid buff, High buff); Red Lotus Blade (Mid buff, Ice Brand enabled); Tizona + Thibron AM3 TP (-50% DT, -25% DT); Caliburnus + Thibron AM1 TP (-50% DT, -25% DT). The BLU page gives its Thibron as TP Bonus +1000, the same augment as Vanar's copy.

### Thunder Hammer

*Thunder Hammer.*

- The Thunder enchantment does 100 damage when unresisted (bg-wiki marks this as unverified).
- It has a 2 s cast, a 30 s equip delay and a 10-minute reuse. ([bg-wiki](https://www.bg-wiki.com/ffxi/Thunder_Hammer))

### Tizona

*Tizona. BLU only.*

- "Path: A" exists only on the Oboro-augmented iLvl 119 III Tizona (DMG 147, Delay 236, Magic Accuracy +40, Magic Damage +186, Sword skill +269, Magic Accuracy skill +255), not on the level-75 version the help text shows. ([bg-wiki](https://www.bg-wiki.com/ffxi/Tizona_%28Level_119_III%29))
- Path A is the Ultimate Weapon (REMA) augment, and the only path. Only Level 119 III takes it, so Vanar's Tizona is Level 119 III. His rank (1 to 15) isn't recorded, since ranks change often, and the export doesn't show it; ask the player when a set decision turns on it. At rank 15 (max) it gives DMG +18, Expiacion damage +15%, Accuracy +30 and Magic Accuracy +30, all main hand only. Below rank 15 it gives less, by amounts bg-wiki doesn't list. ([bg-wiki](https://www.bg-wiki.com/ffxi/BGWiki:Ultimate_Weapon_Augments), [rank-augments.md](rank-augments.md#oboro-rank-augments-maximum-only))
- Tizona has a hidden Expiacion damage +30% that multiplies with the rank-15 augment's +15%, for +49.5%. Both apply to every hit of Expiacion. ([bg-wiki](https://www.bg-wiki.com/ffxi/Tizona_%28Level_119_III%29))
- The MP drain procs on about 30% of normal melee hits (not weapon skills) and returns about 10-20% of that hit's damage as MP, even against monsters with no MP. ([bg-wiki](https://www.bg-wiki.com/ffxi/Tizona_%28Level_119_III%29))
- Expiacion Aftermath goes by actual TP only. Level 1 gives Accuracy floor(TP/50+10) (30-49) for 90 s. Level 2 gives Magic Accuracy 30-49 for 4.5 minutes. Level 3 makes attacks hit twice 40% or thrice 20% of the time for 3 minutes, and can also proc once on a physical weapon skill. ([bg-wiki](https://www.bg-wiki.com/ffxi/Mythic_Aftermath))
- Any Aftermath level overwrites level 1, only level 3 overwrites level 2, and nothing overwrites level 3. ([bg-wiki](https://www.bg-wiki.com/ffxi/Aftermath))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): BLU: Expiacion (Mid buff, High buff); Tizona + Thibron AM3 TP (-50% DT, -25% DT). Both assume Tizona Level 119 III, the stage Vanar's `'Path: A'` copy is (above).
- wsdist: it has only "Tizona" (no augment) and "Tizona R15" (DMG +18, Accuracy and Magic Accuracy +30, Expiacion +49.5% instead of +30%), and "Select all File" keeps only the R15 one. Vanar's rank (1 to 15) isn't recorded. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), lines 163-164; [weapon_bonus.py](https://github.com/IzaKastra/wsdist_beta/blob/main/weapon_bonus.py), lines 87 and 108; [gui_main.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gui_main.py), lines 490-491)

### Treat Staff II

*Treat Staff II.*

- The Warp enchantment has 1 charge, an 8 s cast, a 30 s equip delay and a 20-hour reuse. ([bg-wiki](https://www.bg-wiki.com/ffxi/Treat_Staff_II))

### Twilight Knife

*Twilight Knife. RDM, not BLU.*

- The drain procs on about 5% of hits and splits HP 45%, MP 45%, TP 10%, for at most 45 HP, 45 MP or 10 TP.
- For any RDM melee use, Gleti's Knife (DMG 133, Accuracy +40, Attack +30, Triple Attack +6%) and Tauret beat this level-90, DMG 40 dagger. ([bg-wiki](https://www.bg-wiki.com/ffxi/Twilight_Knife))

### Warp Cudgel

*Warp Cudgel.*

- It is not Rare and holds 30 charges.
- Warp has an 8 s cast, only a 3 s equip delay and a 60 s reuse. That makes it a much faster repeat Warp than Treat Staff II (30 s equip delay, 20-hour reuse). ([bg-wiki](https://www.bg-wiki.com/ffxi/Warp_Cudgel))

### Wind Knife +1

*Wind Knife +1.*

- The Aero enchantment does 100 damage when unresisted (unverified on bg-wiki). It has a 2 s cast, a 30 s equip delay and a 10-minute reuse.
- The melee Wind proc fires about 80% of the time, but for very little damage. ([bg-wiki](https://www.bg-wiki.com/ffxi/Wind_Knife_%2B1))

No notes beyond the help text: Anahera Sword, Deathbane, Extinction, Hofud, Iapetus, Kam'lanaut's Sword, Lament, Malignance Sword, Nibiru Knife, Nihility, Sh. Moogle Rod, Tokkosho, Twinned Blade.

## Shields and grips, ranged and ammo

### Amar Cluster

*Amar Cluster.*

- RDM can't equip Honed Tathlum (Accuracy+15), so of Vanar's ammo this is RDM's highest Accuracy piece (+10). On BLU, Honed Tathlum has 5 more Accuracy. ([bg-wiki](https://www.bg-wiki.com/ffxi/Honed_Tathlum))
- Accuracy from DEX is floor(DEX × 0.75), so Coiste Bodhar's DEX+10 at Path A rank 30 is worth 7 or 8 Accuracy. Vanar's Coiste rank isn't recorded.
- Against Coiste Bodhar at Path A rank 30, its Accuracy edge is small. Swapping it in for Coiste trades Coiste's Double Attack 3%, Store TP 3 and Attack+15 for about 2 or 3 Accuracy. ([bg-wiki](https://www.bg-wiki.com/ffxi/Accuracy))

### Ammurapi Shield

*Ammurapi Shield. RDM only.*

- Its `Enhancing magic duration +10%` is duration listed on gear; bg-wiki uses this shield as its example. It adds with other listed duration % and multiplies separately from augmented duration (Telchine, Ghostfyre).
- It counts when the spell lands, so it belongs in midcast.
- Changing the sub slot resets TP. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Enhancing_Magic))
- The Rahvin engine's Weapon Lock (engine f58021c) decides whether this shield can go on. Under `Locked`, the weapon mode's main and sub go back over every precast and midcast set, engaged or not, so a midcast set never puts it on. Under `Unlocked`, they go back only while you are engaged, so it goes on for casts made while not engaged. RDM.lua sets `Unlocked` (2026-10-02), so it goes on for casts made while not engaged; BLU.lua sets `Locked`, which is also the engine's default for a file that sets nothing. ([builders.lua](https://github.com/khowe085/rahvin-gearswap/blob/f58021c/RahvinGS/builders.lua) and [equip.lua](https://github.com/khowe085/rahvin-gearswap/blob/f58021c/RahvinGS/equip.lua); default in [interface.lua](https://github.com/khowe085/rahvin-gearswap/blob/f58021c/RahvinGS/interface.lua))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Casting (Free Nuke, Magic Burst).

### Aureole

*Aureole.*

- A throwing weapon for the range slot. It takes no ammunition.
- Mismatched range and ammo items remove each other, so it can't be worn with a stat ammo such as Pemphredo Tathlum. ([FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Ammo))
- Equipping it in the range slot loses all TP. ([bg-wiki](https://www.bg-wiki.com/ffxi/Tactical_Points))
- Since the two can't be worn together, Pemphredo Tathlum in the ammo slot (Magic Accuracy+8, INT+4, Magic Atk. Bonus+4, Conserve MP+4) beats it on both jobs. On RDM, Ullr's Magic Accuracy+40 also beats it in the range slot. ([bg-wiki](https://www.bg-wiki.com/ffxi/Pemphredo_Tathlum))

### Coiste Bodhar

*Coiste Bodhar.*

- Path A at max rank (30) adds Attack+15, STR+10 and DEX+10.
- Attack reaches +15 at rank 15. STR starts at rank 16 and DEX at rank 21. ([bg-wiki](https://www.bg-wiki.com/ffxi/Coiste_Bodhar))
- The export doesn't show this copy's rank, and Vanar's rank isn't recorded, since ranks change often; ask the player when a set decision turns on it. [rank-augments.md](rank-augments.md#coiste-bodhar) has every rank.
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Savage Blade (Mid buff); Death Blossom (Mid buff); Knights of Round (Mid buff); Imperator (Mid buff); Requiescat (Mid buff); Mercy Stroke (Mid buff); Ruthless Stroke (Mid buff); Black Halo (Mid buff); BLU: Expiacion (Mid buff); Chant du Cygne (Mid buff, High buff); Requiescat (Mid buff); Imperator (Mid buff); Savage Blade (Mid buff); Caliburnus + Thibron AM1 TP (-50% DT, -25% DT).
- wsdist: its rank 30 entry has DEX+5; rank 30 is DEX+10. Ranks 0 to 25 are right. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), line 456)

### Forfend +1

*Forfend +1. RDM only.*

- Path A at max rank (15) is Accuracy+15, Magic Accuracy+15 and Enhancing magic skill +10.
- The skill starts at rank 11, at +2 per rank, so a copy below rank 15 has +0 to +8. ([bg-wiki](https://www.bg-wiki.com/ffxi/Forfend_%2B1))
- The export doesn't show the rank, and Vanar's rank isn't recorded, since ranks change often; ask the player when a set decision turns on it. [rank-augments.md](rank-augments.md#forfend-1) has every rank.
- `Unity Ranking: Accuracy+10～20` depends on your Unity's weekly ranking. A higher-ranked Unity gives more, up to +20. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Unity_Concord))
- Like Ammurapi Shield, a midcast set never puts it on under the engine's Weapon Lock `Locked` (the default), and under `Unlocked`, which RDM.lua sets, only for casts made while not engaged. ([builders.lua](https://github.com/khowe085/rahvin-gearswap/blob/f58021c/RahvinGS/builders.lua) and [equip.lua](https://github.com/khowe085/rahvin-gearswap/blob/f58021c/RahvinGS/equip.lua); default in [interface.lua](https://github.com/khowe085/rahvin-gearswap/blob/f58021c/RahvinGS/interface.lua))

### Fulcio Grip

*Fulcio Grip.*

- A grip needs a two-handed main weapon.
- The two-handed combat weapons in Vanar's export are staves: Chatoyant Staff on both jobs, and Marin Staff +1, Lehbrailg +2, Serenity and Soothsayer Staff on RDM only.
- For Enhancing magic skill, a staff with this grip loses on BLU, and on RDM if Forfend +1 is rank 11 or higher. The best staff pairing is 12: Serenity's augmented 9 plus this grip's 3.
- RDM's Pukulatmuj +1 (11) with Forfend +1 gives 13 at rank 11, up to 21 at rank 15. At rank 10 or below Forfend adds no skill, so Pukulatmuj +1's 11 loses to Serenity with this grip. Vanar's Forfend rank isn't recorded, since ranks change often; ask the player when this choice matters. BLU's Pukulatmuj +1 alone gives 11. ([FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Category:Grips), [rank-augments.md](rank-augments.md#forfend-1))

### Genbu's Shield

*Genbu's Shield.*

- The two unlabeled numbers in the help text are element icons: Fire resistance -10 and Earth resistance +10. ([bg-wiki](https://www.bg-wiki.com/ffxi/Genbu%27s_Shield))
- Its Physical damage taken -10% is plain PDT. It adds with Damage taken -% toward the same -50% physical cap, so it does nothing in a set already at -50% physical. ([bg-wiki](https://www.bg-wiki.com/ffxi/Damage_Taken))
- Vanar's copy has no augments. The Synergy augments (Genbu Scrap) go up to Cure potency +5%, Cure spellcasting time -8%, Magic Accuracy+6, HP+25 and MP+32. ([bg-wiki](https://www.bg-wiki.com/ffxi/Genbu%27s_Shield))

### Hasty Pinion

*Hasty Pinion.*

- Its Haste+1% is gear haste, which shortens spell recast. So it belongs in a midcast set, where its Store TP -5 costs nothing. ([bg-wiki](https://www.bg-wiki.com/ffxi/Spell_Recast))
- It can be the last 1% toward 26% of listed gear haste, the total the player treats as the 256/1024 cap. ([ffxi-mechanics.md](ffxi-mechanics.md#haste))

### Impatiens

*Impatiens.*

- `Occ. quickens spellcasting +2%` is Quick Magic: 2% of spells cast instantly, with no casting or recast time.
- Quick Magic caps at 10%.
- On RDM, job points add a Conserve MP-style effect when Quick Magic goes off. ([bg-wiki](https://www.bg-wiki.com/ffxi/Occasionally_Quickens_Spellcasting))
- The player's rule is to avoid Quick Magic pieces such as Impatiens, because an instant cast can land in precast gear. ([ffxi-mechanics.md](ffxi-mechanics.md#quick-magic))

### Incantor Stone

*Incantor Stone. WHM, PLD and SCH only; not RDM or BLU.*

- The unstated Fast Cast is +2%. ([bg-wiki](https://www.bg-wiki.com/ffxi/Incantor_Stone))

### Majorelle Shield

*Majorelle Shield. WAR, PLD and DRK only; not RDM or BLU.*

- The unstated Fast Cast is +5%. ([bg-wiki](https://www.bg-wiki.com/ffxi/Majorelle_Shield))

### Mavi Tathlum

*Mavi Tathlum. BLU only.*

- `Increases breath damage` is breath damage +5%, for BLU's breath spells such as Thunder Breath or Wind Breath.
- It is the only ammo in Vanar's export with Blue Magic skill or breath damage. ([bg-wiki](https://www.bg-wiki.com/ffxi/Mavi_Tathlum))
- Blue Magic skill +5 raises the accuracy and potency of magical blue magic and goes into physical blue magic damage.
- Physical spell accuracy comes from Accuracy, DEX and the main weapon, not from skill. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Blue_Magic))

### Mephitis Grip

*Mephitis Grip.*

- A grip needs a two-handed main weapon, which on RDM or BLU means a staff.
- On RDM, a staff and this grip give up Bunzi's Rod with Ammurapi Shield: Magic Accuracy 333 (40 + 38, plus the Rod's main-hand Magic Accuracy skill 255). These are the Rod's base stats, at Vanar's rank 0; [rank-augments.md](rank-augments.md#bunzis-rod) has the other ranks.
- The best staff pairing is Serenity (Magic Accuracy 25, Magic Accuracy skill 228) plus this grip (Magic Accuracy 5, Enfeebling magic skill 5): 258 in total, 75 short of the Rod and Shield. ([FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Category:Grips))

### Moggiebag

*Moggiebag.*

- The enchantment works only inside Mog Garden and gives 100 to 10,000 gil.
- Usable 10 s after equipping. 8 charges, 3-day (259,200 s) reuse. ([bg-wiki](https://www.bg-wiki.com/ffxi/Moggiebag))

### Mogratuity

*Mogratuity.*

- The enchantment works only inside Mog Garden and gives 100 to 10,000 gil.
- Usable 10 s after equipping. 10 charges, 3-day (259,200 s) reuse. ([bg-wiki](https://www.bg-wiki.com/ffxi/Mogratuity))

### Moogle Moolah

*Pouch of Moogle Moolah.*

- The enchantment works only inside Mog Garden and gives 100 to 10,000 gil.
- Usable 10 s after equipping. 11 charges, 3-day (259,200 s) reuse. ([bg-wiki](https://www.bg-wiki.com/ffxi/Moogle_Moolah))

### Moogle's Largesse

*Moogle's Largesse.*

- The enchantment works only inside Mog Garden and gives 100 to 10,000 gil.
- Usable 10 s after equipping. 9 charges, 3-day (259,200 s) reuse. ([bg-wiki](https://www.bg-wiki.com/ffxi/Moogle%27s_Largesse))

### Niobid Strap

*Niobid Strap.*

- A grip needs a two-handed main weapon, which on RDM or BLU means a staff.
- Its Accuracy, Magic Accuracy and Magic Atk. Bonus +5 are far below the one-handed casting pairs in Vanar's export, such as Bunzi's Rod with Ammurapi Shield (Magic Accuracy 78, or 333 with the Rod's main-hand Magic Accuracy skill 255; Magic Atk. Bonus 73). Those are the Rod's base stats, at Vanar's rank 0; [rank-augments.md](rank-augments.md#bunzis-rod) has the other ranks. ([FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Category:Grips))

### Oshasha's Treatise

*Oshasha's Treatise.*

- Its Weapon skill damage +3% applies only to the first hit of a physical weapon skill, but to all of a magical one.
- So it is worth more on magical weapon skills (Sanguine Blade, Seraph Blade, Aeolian Edge) than on multi-hit ones such as Chant du Cygne or Requiescat. ([bg-wiki](https://www.bg-wiki.com/ffxi/Weapon_Skill_Damage))

### Pemphredo Tathlum

*Pemphredo Tathlum.*

- On RDM it can't be worn with Ullr. Ullr is a bow, and mismatched range and ammo items remove each other, so equipping this tathlum takes Ullr off. ([FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Ammo))

### Per. Lucky Egg

*Perfect Lucky Egg.*

- On any main job other than THF, Treasure Hunter caps at +4.
- TH gear only has to be on for the first action that draws the monster's enmity. It can come off after that. ([bg-wiki](https://www.bg-wiki.com/ffxi/Treasure_Hunter))

### Raider's Bmrng.

*Raider's Boomerang. THF only; not RDM or BLU.*

- `Enhances "Dual Wield" effect` is Dual Wield +3%. ([bg-wiki](https://www.bg-wiki.com/ffxi/Raider%27s_Bmrng.))

### Ullr

*Ullr. RDM only.*

- Ullr is a bow, so only arrows match it in the ammo slot.
- Mismatched range and ammo items remove each other, so any other ammo (Coiste Bodhar, Pemphredo Tathlum, a tathlum) takes Ullr off. A set worn with it needs `ammo = empty`. ([FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Ammo))
- Equipping Ullr loses all TP, so it is only worn for casts made while not engaged. ([bg-wiki](https://www.bg-wiki.com/ffxi/Tactical_Points))

### Vivid Strap

*Vivid Strap.*

- The unstated Fast Cast is +1%. ([bg-wiki](https://www.bg-wiki.com/ffxi/Vivid_Strap))
- As a grip it needs a two-handed main weapon, which on RDM or BLU means a staff. It can't go with a sword or club. ([FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Category:Grips))

No notes beyond the help text: Archduke's Shield, Ark Shield, Ginsen, Honed Tathlum, Hydrocera, Savant's Treatise, Tsoa. Crossbow, Twinned Shield.

## Head

### Adhemar Bonnet

*Adhemar Bonnet. BLU, not RDM.*

- Its augments are Nolan Path B at rank 15, the path's maximums. With them it totals Attack 41, STR 29 and DEX 31 ([bg-wiki](https://www.bg-wiki.com/ffxi/Nolan)).
- Set bonus: Adhemar, see [Adhemar set](#adhemar-set). Only +1 pieces count, so this NQ bonnet never does ([bg-wiki](https://www.bg-wiki.com/ffxi/Adhemar_Attire_Set)).

### Amalric Coif +1

*Amalric Coif +1.*

- "Refresh" potency +2 adds 2 MP per tick to the Refresh spells you cast, for whoever receives them. It is not Refresh +2: it gives the wearer no MP by itself.
- bg-wiki says it also enhances BLU's Battery Charge.
- "Aquaveil"+2 blocks 2 more interruptions on top of the 1 to 3 that skill gives (3 at 501+ skill).
- Refresh potency and Aquaveil+ are read when the spell lands, so they belong in midcast (bg-wiki: [Amalric Coif +1](https://www.bg-wiki.com/ffxi/Amalric_Coif_%2B1), [Aquaveil](https://www.bg-wiki.com/ffxi/Aquaveil), [Refresh](https://www.bg-wiki.com/ffxi/Refresh), [Battery Charge](https://www.bg-wiki.com/ffxi/Battery_Charge)).
- Its augments are Nolan Path C below rank 15: INT+11 and Elemental and Dark magic skill +17, against +12, +20 and +20 at the maximum.
- Those skills add nothing to its Fast Cast, Refresh potency or Aquaveil uses ([bg-wiki](https://www.bg-wiki.com/ffxi/Nolan)).
- Set bonus: Amalric, see [Amalric set](#amalric-set). Vanar owns no other Amalric piece, so it never applies ([bg-wiki](https://www.bg-wiki.com/ffxi/Amalric_Attire_Set)).
- wsdist: its only entry is Nolan Path A at max, Magic Accuracy and Magic Atk. Bonus +20. Against Vanar's Path C copy that is 20 MAB high and 11 INT low, and Magic Accuracy 3 high on nukes (Path C's Elemental magic skill +17 is missing) and 20 high on magical weapon skills. The Magic Accuracy gap matters only against an enemy given Magic Evasion; every wsdist preset, the sims' "BG Wiki sets" included, has 0 ([ffxi-mechanics.md](ffxi-mechanics.md#where-wsdist-and-bg-wiki-disagree)). Its Amalric set-bonus code is right. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), line 620)

### Anwig Salade

*Anwig Salade. BLU, not RDM.*

- It is a level 75 piece with no item level.
- Its augments are two picks from a fixed menu: STR+4 with Weapon Skill Accuracy+15, and Accuracy+10 with Attack+5.
- Weapon Skill Accuracy only counts on physical weapon skills.
- Hashishin Kavuk +3 (Accuracy 61, Attack 61) outclasses it for every BLU use. The Salade's only extra is Subtle Blow +3 (bg-wiki: [Anwig Salade](https://www.bg-wiki.com/ffxi/Anwig_Salade), [Accuracy](https://www.bg-wiki.com/ffxi/Accuracy)).

### Appetence Crown

*Appetence Crown.*

- "Enhances Drain and Aspir" means Drain and Aspir potency +10%.
- RDM and BLU don't learn Drain or Aspir, so it only helps with a BLM, DRK, SCH or GEO subjob.
- It is level 88 with no item level (bg-wiki: [Appetence Crown](https://www.bg-wiki.com/ffxi/Appetence_Crown), [Aspir](https://www.bg-wiki.com/ffxi/Aspir)).

### Assim. Keffiyeh +1

*Assimilator's Keffiyeh +1. BLU only.*

- Monster correlation effects+5 adds 0.05 to a blue magic spell's multiplier when the spell's monster family preys on the target's family, for example MP Drainkiss on a Colibri.
- It has to be on when the spell lands ([bg-wiki](https://www.bg-wiki.com/ffxi/Assim._Keffiyeh_%2B1)).
- Hashishin Kavuk +3 is higher on every stat this hat has: Macc 61 vs 18, MAB 51 vs 18, HP, every attribute, evasion and MDB, with equal Haste. The correlation +5 is this hat's only extra ([bg-wiki](https://www.bg-wiki.com/ffxi/Hashishin_Kavuk_%2B3)).
- Set bonus: Assimilator's, see [Assimilator's set](#assimilators-set). As a +1 piece this hat doesn't count ([bg-wiki](https://www.bg-wiki.com/ffxi/Assimilator%27s_Attire_Set)).

### Atro. Chapeau +4

*Atrophy Chapeau +4. RDM only.*

- Magic burst damage +10 is the first kind, which shares the 40% gear cap. It isn't Magic burst damage II ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Burst)).
- Set bonus: Atrophy, see [Atrophy set](#atrophy-set).

### Bunzi's Hat

*Bunzi's Hat. RDM, not BLU.*

- Vanar's copy is rank 0 (player, 2026-10-02): no augments, only the base stats in its help text. The export prints no augments for it, not even `'Path: A'`.
- Its only path, Odyssey Path A, adds Attack, Magic Damage and Store TP from rank 1, Accuracy and Magic Accuracy from rank 16, and Quadruple Attack from rank 21. For the values at each rank, see [rank-augments.md](rank-augments.md#bunzis-hat) ([bg-wiki](https://www.bg-wiki.com/ffxi/Bunzi%27s_Hat)).
- Magic burst damage +7 is the 40%-capped kind, not Magic burst damage II ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Burst)).
- No set bonus ([bg-wiki](https://www.bg-wiki.com/ffxi/Bunzi%27s_Attire_Set)).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Naegling + Thibron TP (-50% DT, -25% DT). Vanar's copy is rank 0, without the rank 30 augment (Attack and Magic Damage +30, Store TP +8, Accuracy and Magic Accuracy +15, Quadruple Attack +3%), so the sims overvalue it ([rank-augments.md](rank-augments.md#bunzis-hat)).

### Despair Helm

*Despair Helm.*

- Its augments are Nolan Path B at rank 15, the path's maximums. That gives it Haste 10% in total ([bg-wiki](https://www.bg-wiki.com/ffxi/Nolan)).
- No set bonus ([bg-wiki](https://www.bg-wiki.com/ffxi/Despair_Armor_Set)).
- Its Accuracy and Attack +20 trail far behind Hashishin Kavuk +3 on BLU and Leth. Chappel +3 on RDM, which both have Accuracy and Attack 61.
- Its only higher stats are STR 33 and Haste 10%, plus VIT 27 against the Chappel's 25.
- Its extra Haste only helps a set that is still under the gear haste cap (bg-wiki: [Despair Helm](https://www.bg-wiki.com/ffxi/Despair_Helm), [Hashishin Kavuk +3](https://www.bg-wiki.com/ffxi/Hashishin_Kavuk_%2B3), [Leth. Chappel +3](https://www.bg-wiki.com/ffxi/Leth._Chappel_%2B3)).

### Gende. Caubeen

*Gendewitha Caubeen. RDM, not BLU.*

- "Cure" potency +10% is the kind that caps at 50%, not Cure potency II. It is read at midcast.
- Enmity-8 is its only edge over Vanar's Vanya Hood, which also has Cure potency +10%, plus Fast Cast 10% and Conserve MP 6 (bg-wiki: [Cure spells](https://www.bg-wiki.com/ffxi/Category:Cure_Spell), [Gende. Caubeen](https://www.bg-wiki.com/ffxi/Gende._Caubeen)).

### Gleti's Mask

*Gleti's Mask. BLU, not RDM.*

- Vanar's copy is rank 0 (player, 2026-10-02): no augments, only the base stats in its help text. The export prints no augments for it, not even `'Path: A'`.
- Its only path, Odyssey Path A, adds Attack and Counter from rank 1, Accuracy and Magic Accuracy from rank 16, and Regen from rank 21. For the values at each rank, see [rank-augments.md](rank-augments.md#gletis-mask) ([bg-wiki](https://www.bg-wiki.com/ffxi/Gleti%27s_Mask)).
- Physical damage taken -6% is PDT. It counts toward the 50% physical cap together with DT, but does nothing against magic ([bg-wiki](https://www.bg-wiki.com/ffxi/Damage_Taken)).
- Regain +2 gives 2 TP per 3-second tick ([bg-wiki](https://www.bg-wiki.com/ffxi/Regain_(Status))).
- No set bonus ([bg-wiki](https://www.bg-wiki.com/ffxi/Gleti%27s_Armor_Set)).

### Glory Crown

*Glory Crown.*

- Hidden effect: if it is worn when you receive Sanction, that Sanction's EXP bonus and chosen bonus (Regen, Refresh or food duration) use an Imperial Defense level one higher, up to the cap of 8. At level 8 it does nothing.
- It can come off once Sanction is applied.
- It only matters in Treasures of Aht Urhgan areas (bg-wiki: [Glory Crown](https://www.bg-wiki.com/ffxi/Glory_Crown), [Sanction](https://www.bg-wiki.com/ffxi/Sanction)).

### Haruspex Hat

*Haruspex Hat.*

- For fast cast, Amalric Coif +1 (11%) beats its 8% on both jobs, and Atro. Chapeau +4 (16%) beats it on RDM.
- Over the Coif it only adds Enmity-4 and a few points of STR, DEX, VIT, AGI and CHR ([bg-wiki](https://www.bg-wiki.com/ffxi/Haruspex_Hat)).
- Neither Haruspex tier has a set bonus ([bg-wiki](https://www.bg-wiki.com/ffxi/Haruspex_Attire_Set)).

### Hashishin Kavuk +3

*Hashishin Kavuk +3. BLU only.*

- "Chain Affinity"+28 adds 28 to the base damage of a physical blue magic spell cast under Chain Affinity. It applies to every hit and isn't limited by the spell's damage cap.
- bg-wiki says it must stay equipped, so it belongs in the physical blue magic midcast (bg-wiki: [Hashishin Kavuk +3](https://www.bg-wiki.com/ffxi/Hashishin_Kavuk_%2B3), [Chain Affinity](https://www.bg-wiki.com/ffxi/Chain_Affinity)).
- Sword skill +30 only helps attacks made with a sword. It does nothing for a club in the main hand (bg-wiki: [Accuracy](https://www.bg-wiki.com/ffxi/Accuracy), [Attack](https://www.bg-wiki.com/ffxi/Attack)).
- Set bonus: Hashishin, see [Hashishin set](#hashishin-set).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): BLU: Expiacion (Mid buff, High buff); Requiescat (Mid buff); Imperator (Mid buff, High buff); Savage Blade (Mid buff, High buff); Sanguine Blade (Mid buff, Ice Brand enabled); Red Lotus Blade (Mid buff, Ice Brand enabled).
- wsdist: the entry lacks Sword skill +30, so each hand holding a sword is 30 Attack short. Accuracy is about 27 short for a main-hand sword with its own skill (Tizona, Naegling, Caliburnus, Sequence) and 24 for an off-hand Thibron. Thibron's entry has no Sword skill, so that hand stays under 600 skill, where a point is 0.8 Accuracy instead of 0.9. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), lines 117 and 593; [create_player.py](https://github.com/IzaKastra/wsdist_beta/blob/main/create_player.py), lines 69-82 and 133-138)

### Herculean Helm

*Herculean Helm. BLU, not RDM.*

- Vanar's copy has no augments.
- Oseem's magic path can add Fast Cast +1 to +5 (+6 with a Fern Stone) and Magic Attack Bonus up to +35.
- Dark Matter can add rarer augments, such as Treasure Hunter +1 to +2 or Refresh +1 to +2 (bg-wiki: [Arcane Glyptics Inscription](https://www.bg-wiki.com/ffxi/Category:Escha_Rewards/Arcane_Glyptics_Inscription), [Herculean Helm](https://www.bg-wiki.com/ffxi/Herculean_Helm)).
- Unaugmented, it loses to Amalric Coif +1 (Fast Cast 11%) for fast cast, and to Hashishin Kavuk +3 for melee and nukes (MAB 51 vs 10, Attack 61 vs 15) ([bg-wiki](https://www.bg-wiki.com/ffxi/Hashishin_Kavuk_%2B3)).

### Jhakri Coronal +2

*Jhakri Coronal +2.*

- Apart from attributes, Skillchain Bonus +7 is the only stat it has that Hashishin Kavuk +3 (BLU) and Leth. Chappel +3 (RDM) lack. Both beat it on Accuracy, Attack, Macc and MAB ([bg-wiki](https://www.bg-wiki.com/ffxi/Jhakri_Coronal_%2B2)).
- Set bonus: Jhakri, see [Jhakri set](#jhakri-set).

### Leth. Chappel +3

*Lethargy Chappel +3. RDM only.*

- Enfeebling magic casting time -17% is a casting-time stat, so it only counts in a precast set. It adds to Fast Cast. bg-wiki's Enfeebling Magic page says it shares the 80% casting-time cap with Fast Cast; the player holds that it breaks the cap ([ffxi-mechanics.md](ffxi-mechanics.md#does-anything-break-the-80-cap-disputed)) (bg-wiki: [Fast Cast](https://www.bg-wiki.com/ffxi/Fast_Cast), [Leth. Chappel +3](https://www.bg-wiki.com/ffxi/Leth._Chappel_%2B3), [Enfeebling Magic](https://www.bg-wiki.com/ffxi/Category:Enfeebling_Magic)).
- Set bonus: Lethargy, see [Lethargy set](#lethargy-set).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Seraph Blade (Mid buff); Red Lotus Blade (Mid buff); Aeolian Edge (Mid buff); Casting (Free Nuke).

### Luh. Keffiyeh +1

*Luhlaza Keffiyeh +1. BLU only.*

- "Enhances Convergence" adds 2% to Convergence's magic damage bonus per Convergence merit level, so +10% at 5 merits (25% becomes 35%).
- Convergence boosts the next magical blue spell, so the hat has to be on for that spell's midcast (bg-wiki: [Convergence](https://www.bg-wiki.com/ffxi/Convergence), [Luh. Keffiyeh +1](https://www.bg-wiki.com/ffxi/Luh._Keffiyeh_%2B1)).
- Vanar has no Convergence merits: Diffusion 5 and Enchainment 5 (player, 2026-10-02) fill BLU Group 2's 10 levels. Convergence is a merit ability, so he doesn't have it, and this augment does nothing for him ([Vanar's merits and skills](#vanars-merits-and-skills)). The breath damage below still counts.
- Breath damage dealt +20% does apply to blue magic breath spells: bg-wiki's Bad Breath page says breath-damage gear enhances it.
- It is the only head in Vanar's export with this stat ([bg-wiki](https://www.bg-wiki.com/ffxi/Bad_Breath)).

### Merlinic Hood

*Merlinic Hood. RDM, not BLU.*

- Vanar owns two copies. The hood isn't Rare, so GearSwap must name each copy by its augments ([bg-wiki](https://www.bg-wiki.com/ffxi/Merlinic_Hood)).
- Copy `'Mag. Acc.+24','"Drain" and "Aspir" potency +7','"Mag.Atk.Bns."+7'`:
  - This is the Drain/Aspir copy. In total it has Macc 39, MAB 17 and Fast Cast 8%.
  - "Drain" and "Aspir" potency +7 raises the amount drained by 7% on each. bg-wiki's Aspir formula multiplies by (1 + potency). Its Drain page gives no potency term, but its Drain/Aspir category page multiplies both spells by the potency gear ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Drain/Aspir_Spell)).
  - The augment goes up to +10, or +11 with a Fern Stone.
  - RDM only gets Drain and Aspir from a BLM, DRK, SCH or GEO subjob (bg-wiki: [Aspir](https://www.bg-wiki.com/ffxi/Aspir), [Drain](https://www.bg-wiki.com/ffxi/Drain), [Arcane Glyptics Inscription](https://www.bg-wiki.com/ffxi/Category:Escha_Rewards/Arcane_Glyptics_Inscription)).
- Copy `'Mag. Acc.+20 "Mag.Atk.Bns."+20','"Occult Acumen"+10','Mag. Acc.+15','"Mag.Atk.Bns."+5'`:
  - This is the nuke copy: Macc 50 and MAB 35 in total.
  - Occult Acumen +10 gives 10 TP per 100 MP of the spell's base cost on elemental or dark spells that deal damage. The cost is counted before Conserve MP, and Store TP raises the TP.
  - RDM has no Occult Acumen trait of its own. A DRK subjob adds tier I (25 TP per 100 MP).
  - It lacks the Magic burst damage augment (up to +10%, or +11% with a Fern Stone) that nuke Merlinics roll (bg-wiki: [Occult Acumen](https://www.bg-wiki.com/ffxi/Occult_Acumen), [Arcane Glyptics Inscription](https://www.bg-wiki.com/ffxi/Category:Escha_Rewards/Arcane_Glyptics_Inscription)).
  - Leth. Chappel +3 (Macc 61, MAB 56, Magic Damage 31) beats it for nukes, and Atro. Chapeau +4 (Fast Cast 16%) beats it for fast cast ([bg-wiki](https://www.bg-wiki.com/ffxi/Leth._Chappel_%2B3)).

### Nyame Helm

*Nyame Helm.*

- Vanar's copy is Path B at rank 20 (player, 2026-10-02): Attack+25, Ranged Attack+25, Weapon skill damage +8% and Double Attack +2%. The export prints the path but not the rank.
- Path B's Accuracy augment only starts at rank 21, so this copy has none. For the other ranks and paths, see [rank-augments.md](rank-augments.md#nyame-helm) ([bg-wiki](https://www.bg-wiki.com/ffxi/Nyame_Helm)).
- Breath spells deal damage from current HP. Its HP+91 only adds breath damage if HP is already full with the helm on before the cast. A BLU guide on bg-wiki says HP gear needs full HP to count (bg-wiki: [Bad Breath](https://www.bg-wiki.com/ffxi/Bad_Breath), [Blue Magic Guide by Sabishii](https://www.bg-wiki.com/ffxi/Azure_Tomes:_Blue_Magic_Guide_by_Sabishii)).
- White Wind heals from max HP, so the helm's HP counts there even when it only goes on at midcast ([bg-wiki](https://www.bg-wiki.com/ffxi/White_Wind)).
- Magic burst damage +5 is the 40%-capped kind ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Burst)).
- Magic burst damage II comes only from Path C, so this Path B copy has none ([bg-wiki](https://www.bg-wiki.com/ffxi/Nyame_Helm)).
- No set bonus ([bg-wiki](https://www.bg-wiki.com/ffxi/Nyame_Armor_Set)).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Mercy Stroke (Mid buff, High buff); Ruthless Stroke (High buff). Vanar's copy is rank 20 Path B, so the sims overvalue it: rank 25 has 5 more Attack, 2% more Weapon skill damage and Double Attack, and Accuracy+5 ([rank-augments.md](rank-augments.md#nyame-helm)).

### Rawhide Mask

*Rawhide Mask. BLU, not RDM.*

- Its augments are Nolan Path B at rank 15, the path's maximums ([bg-wiki](https://www.bg-wiki.com/ffxi/Nolan)).
- Its Refresh +1 makes it the only head in Vanar's export that BLU can wear with Refresh.
- With this copy's HP+50 it has HP 86 ([bg-wiki](https://www.bg-wiki.com/ffxi/Rawhide_Mask)).
- No set bonus ([bg-wiki](https://www.bg-wiki.com/ffxi/Rawhide_Armor_Set)).

### Sukeroku Hachi.

*Sukeroku Hachimaki.*

- Weapon Skill Accuracy +30 only counts on physical weapon skills, not on Sanguine Blade or other magical weapon skills ([bg-wiki](https://www.bg-wiki.com/ffxi/Accuracy)).
- Conserve TP +8 is an 8% chance per weapon skill to keep 10 to 200 TP ([bg-wiki](https://www.bg-wiki.com/ffxi/Conserve_TP)).
- It has no Accuracy, Attack or WSD, so Hashishin Kavuk +3 (BLU) and Viti. Chapeau +4 or Leth. Chappel +3 (RDM) beat it for weapon skills ([bg-wiki](https://www.bg-wiki.com/ffxi/Sukeroku_Hachi.)).

### Telchine Cap

*Telchine Cap.*

- "Enh. Mag. eff. dur. +10" is augmented duration, so it multiplies separately from the duration % that gear lists natively.
- +10 is the Dusk-stone maximum.
- Regen potency comes from the same Dusk slot, so this copy can't have both.
- Its Leaf slot (for example Fast Cast +1 to +5%) and Snow slot are empty (bg-wiki: [Alluvion Skirmish armor](https://www.bg-wiki.com/ffxi/Category:Alluvion_Skirmish_Armor), [Lethargy Armor Set](https://www.bg-wiki.com/ffxi/Lethargy_Armor_Set)).

### Vanya Hood

*Vanya Hood. RDM, not BLU.*

- Its augments are Nolan Path D at rank 15, the path's maximums ([bg-wiki](https://www.bg-wiki.com/ffxi/Nolan)).
- The base hood has no Fast Cast. This copy has Fast Cast 10%, Haste 8%, Cure potency 10% (the 50%-capped kind), Conserve MP 6 and Magic damage taken -2%.
- For plain fast cast on RDM, Atro. Chapeau +4 (16%) is better ([bg-wiki](https://www.bg-wiki.com/ffxi/Vanya_Hood)).

### Viti. Chapeau +4

*Vitiation Chapeau +4. RDM only.*

- Both augments scale with RDM Group 2 merits. Vanar has Enfeebling Magic Duration 0 and Magic Accuracy 5 **(player, 2026-10-02, changed)**.
- Enfeebling Magic duration adds 3 seconds of enfeebling duration per Enfeebling Magic Duration merit level (15 seconds at 5). At Vanar's 0 levels that is 0 seconds (0 × 3), and the merit itself adds 0 (0 × 6), so this augment does nothing for him.
- Magic Accuracy adds Macc +3 per Magic Accuracy merit level (+15 at 5). At Vanar's 5 levels that is the full +15 (5 × 3), on top of the merit's own +25 (5 × 5).
- The augment reads only that Group 2 merit. Vanar's Group 1 merits, Ice and Earth magic accuracy (player, 2026-10-02), are a separate bonus for those elements' spells and don't raise it ([Vanar's merits and skills](#vanars-merits-and-skills)).
- Both are read when the spell lands (bg-wiki: [Viti. Chapeau +4](https://www.bg-wiki.com/ffxi/Viti._Chapeau_%2B4), [Merit Points](https://www.bg-wiki.com/ffxi/Merit_Points)).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Savage Blade (Mid buff, High buff); Death Blossom (Mid buff, High buff); Knights of Round (Mid buff, High buff); Imperator (Mid buff, High buff); Requiescat (Mid buff); Ruthless Stroke (Mid buff); Black Halo (Mid buff, High buff).

### Wh. Rarab Cap +1

*White Rarab Cap +1.*

- Treasure Hunter goes on the monster as a debuff with your first aggressive action and stays after you swap out. TH gear only needs to be on for the tagging action.
- With any main job except THF, gear and traits together cap at TH+4 ([bg-wiki](https://www.bg-wiki.com/ffxi/Treasure_Hunter)).
- Enchantment: Reraise has an 8-second cast. It can be used only after the cap has been on for 30 seconds, then has a 20-hour (72,000 s) reuse ([bg-wiki](https://www.bg-wiki.com/ffxi/Wh._Rarab_Cap_%2B1)).

### Zelus Tiara

*Zelus Tiara.*

- Haste+8% is its only useful stat. It is a level 90 piece with no item level ([bg-wiki](https://www.bg-wiki.com/ffxi/Zelus_Tiara)).
- Vanar's Despair Helm (Haste 10% with its Path B augment, wearable by RDM and BLU) beats it on every stat, so it has no place in RDM or BLU sets (bg-wiki: [Despair Helm](https://www.bg-wiki.com/ffxi/Despair_Helm), [Nolan](https://www.bg-wiki.com/ffxi/Nolan)).

No notes beyond the help text: Abyssal Mask, Arthro's Cap, Cait Sith Cap, Carbie Cap, Chocobo Masque, Cumulus Masque, Empress Hairpin, Esthete's Masque, Voyager Sallet, Ziamet Khud.

## Neck

### Adoulin's Refuge +1

*Adoulin's Refuge +1.*

- The help text puts only `Damage taken-8%` under `Reives:`, but bg-wiki lists the Auto-Reraise as Reives-only too. Outside Reives the neck does nothing.
- Auto-Reraise is not a status effect. It is granted when you are KO'd while wearing the neck, so the neck must be on at the moment of KO. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Reraise))

### Aesir Torque

*Aesir Torque.*

- Neither bg-wiki nor FFXIclopedia says whether the Darksday skill +10 replaces the base +7 or adds to it. ([bg-wiki](https://www.bg-wiki.com/ffxi/Aesir_Torque))
- Dark magic skill sets Drain's maximum potency: skill + 20 up to 300 skill, then skill × 5/8 + 132.5.
- Above 300 skill, +7 skill is only about +4 HP at max roll. ([bg-wiki](https://www.bg-wiki.com/ffxi/Drain))
- Vanar's RDM has 341 dark magic skill without gear (300 + 25 Master Levels + 16 merits; [Vanar's merits and skills](#vanars-merits-and-skills)), so he is always past 300 and gets the +4 HP figure: 7 × 5/8 ≈ 4.4.

### Agasaya's Collar

*Agasaya's Collar. Not RDM or BLU.*

- Neither RDM nor BLU can equip it. ([bg-wiki](https://www.bg-wiki.com/ffxi/Agasaya%27s_Collar))

### Bathy Choker

*Bathy Choker.*

- `Unity Ranking: Evasion+5～15` follows your Unity's faction rank, which is set each week. A higher rank gives more. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Unity_Concord))
- Its Subtle Blow +10 is the first tier.
- Subtle Blow caps at 50% on its own. Subtle Blow and Subtle Blow II cap at 75% combined. ([bg-wiki](https://www.bg-wiki.com/ffxi/Subtle_Blow))

### Dls. Torque +1

*Duelist's Torque +1. RDM only.*

- Path A at max rank (R20, the +1's cap) adds INT and MND +12, Enh. Mag. eff. dur. +20% and Enf. Mag. eff. dur. +20%.
- The export doesn't show the rank. Lower ranks give less: bg-wiki's enhancing duration table lists the augment as 1~20%. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:JSE_Necks))
- bg-wiki counts both duration lines as augmented duration. In both the enhancing and the enfeebling duration formulas they multiply separately from native duration % on other gear, so +20% here is worth more than +20% listed natively.
- Duration is read when the spell lands, so this neck belongs in midcast. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Enhancing_Magic))
- Enfeebling Magic effect +7 is +7% potency. It goes into the single gear term of bg-wiki's potency formula, `floor(floor(base × Saboteur + dStat) × effect gear)`, together with the effect on other gear.
- It only affects Addle, Blind, Dia (the DoT, +1 HP per tick per 1%, not the defense down), Distract, Frazzle, Gravity, Paralyze, Poison and Slow. Sleep, Bind, Silence and Break get nothing from it. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Enfeebling_Magic))
- Distract III's -130 evasion cap applies before enfeebling potency gear, so this neck's +7% still adds past it. ([bg-wiki](https://www.bg-wiki.com/ffxi/Distract_III))
- `"Dispel"+1` makes Dispel remove one more beneficial effect, two in total. ([bg-wiki](https://www.bg-wiki.com/ffxi/Dispel))

### Elite Royal Collar

*Elite Royal Collar.*

- Regen +3 needs San d'Oria allegiance.
- A character has one allegiance at a time, so the Regen can't be active together with Rep. Plat. Medal's Bastok Regain or Sibyl Scarf's Windurst Refresh. ([FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Allegiance))
- The help text names the condition `Citizen of San d'Oria`. Vanar is a citizen of Windurst (player, 2026-10-02), so this Regen never works for him. Its DT -5% and VIT+10 still do.

### Enhancing Torque

*Enhancing Torque.*

- It is the only neck in Vanar's export with Enhancing magic skill.
- Skill is read when the spell lands, so it belongs in midcast skill sets.
- Its Earth resistance (the icon `+5` in the help text) does nothing for those sets. ([bg-wiki](https://www.bg-wiki.com/ffxi/Enhancing_Torque))

### Fotia Gorget

*Fotia Gorget.*

- The latent turns on for any weapon skill that has a skillchain property.
- Its `Weapon skill damage +10%` is not real WSD. It adds 25/256 (about 0.098) fTP to the first hit.
- fTP-replicating weapon skills copy that to every hit; Requiescat, Chant du Cygne, Evisceration and Vorpal Blade are on the list. On weapon skills that don't replicate, such as Savage Blade, only the first hit gains. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:FTP_Replicating_WS))
- The latent Accuracy +10 applies to every hit of the weapon skill.
- Its 1% chance to keep TP stacks with Fotia Belt's. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Elemental_Gorgets))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Chant du Cygne (Mid buff, High buff); Knights of Round (High buff); Requiescat (Mid buff, High buff); Seraph Blade (Mid buff); Evisceration (Mid buff, High buff); BLU: Requiescat (Mid buff, High buff).

### Homeric Gorget

*Homeric Gorget. WAR, PLD and DRK only.*

- Neither RDM nor BLU can equip it. ([bg-wiki](https://www.bg-wiki.com/ffxi/Homeric_Gorget))

### Loricate Torque

*Loricate Torque.*

- Elite Royal Collar strictly beats it: the same Damage taken -5%, plus DEF 30 (more than this neck's best Unity DEF +15) and VIT +10. ([bg-wiki](https://www.bg-wiki.com/ffxi/Elite_Royal_Collar))

### Magoraga Beads

*Magoraga Bead Necklace. RDM, not BLU.*

- bg-wiki says its Utsusemi casting time -10% does not break the 80% Fast Cast cap. ([bg-wiki](https://www.bg-wiki.com/ffxi/Magoraga_Beads))
- Under that reading it adds nothing to RDM/NIN Utsusemi, since RDM's fast-cast set is already at 82%.
- The player holds that spell-specific casting time does break the cap. ([ffxi-mechanics.md](ffxi-mechanics.md#does-anything-break-the-80-cap-disputed))

### Mirage Stole +2

*Mirage Stole +2. BLU only.*

- Path A at max rank (R25, the +2's cap) adds STR and DEX +25, Store TP +7 and Critical hit rate +5%.
- The export doesn't show the rank, and lower ranks give less.
- The RahvinGS library's comment for it (STP 6, Crit 4) gives the Mirage Stole +1's max-rank values, not the +2's. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:JSE_Necks))
- Blue magic skill adds to physical blue magic damage and sets the accuracy of magical spells and added effects.
- Physical spells' accuracy comes from melee Accuracy and DEX instead, so in physical sets the Accuracy +25 and the path's DEX are what count. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Blue_Magic))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): BLU: Expiacion (Mid buff, High buff); Chant du Cygne (Mid buff, High buff); Imperator (Mid buff, High buff); Savage Blade (Mid buff, High buff); Tizona + Thibron AM3 TP (-50% DT, -25% DT); Caliburnus + Thibron AM1 TP (-50% DT, -25% DT).

### Mizu. Kubikazari

*Mizukage-no-Kubikazari. RDM, not BLU.*

- Its Magic burst damage +10 is the first tier, which shares the 40% gear cap.
- It is not Magic Burst Damage II, which has no known cap. ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Burst))

### Nefarious Collar

*Nefarious Collar.*

- `Increases magic critical hit damage` is +5 MAB on a magic crit, on top of the base +10 (cap +40).
- Magic crits only happen on blue, divine and elemental magic.
- At a 3% rate that averages under 0.5 MAB, so this is not a nuking piece. ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Critical_Hit))

### Nodens Gorget

*Nodens Gorget. RDM, not BLU.*

- Its `"Stoneskin"+30` is read when the spell lands. It can take Stoneskin past its 350 cap, up to 475. ([bg-wiki](https://www.bg-wiki.com/ffxi/Stoneskin))
- Its Cure potency +5% counts toward the 50% Cure potency cap, not the separate 30% Cure potency II cap. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Cure_Spell))
- RDM's Cure set already reaches 55% without it, so it adds nothing there.

### Quanpur Necklace

*Quanpur Necklace.*

- `Earth Elemental "Magic Atk. Bonus"+5` is affinity: a 5% damage multiplier for earth-element spells only. It is separate from normal MAB and in the same term as Orpheus's Sash.
- On any other element the necklace is just MAB +7. ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Damage))

### Rep. Plat. Medal

*Republican Platinum Medal.*

- Regain +2 needs Bastok allegiance.
- A character has one allegiance at a time, so the Regain excludes Elite Royal Collar's San d'Oria Regen and Sibyl Scarf's Windurst Refresh.
- STR +10 and Attack +30 need no allegiance. ([FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Allegiance))
- The help text names the condition `Citizen of Bastok`. Vanar is a citizen of Windurst (player, 2026-10-02), so the Regain never works for him.
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Savage Blade (Mid buff); Death Blossom (Mid buff); Knights of Round (Mid buff); Imperator (Mid buff); Mercy Stroke (Mid buff, High buff); Ruthless Stroke (Mid buff); Black Halo (Mid buff).

### Sanctity Necklace

*Sanctity Necklace.*

- wsdist: the entry has no Accuracy, but the necklace has Accuracy+10, so melee runs undercount it by 10. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), line 653)

### Sibyl Scarf

*Sibyl Scarf.*

- Refresh +1 needs Windurst allegiance.
- A character has one allegiance at a time, so the Refresh excludes Elite Royal Collar's Regen and Rep. Plat. Medal's Regain.
- INT +10 and MAB +10 apply to everyone. ([FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Allegiance))
- **(player, 2026-10-02)** Vanar is a citizen of Windurst.
  - The help text names the condition `Citizen of Windurst`, so the Refresh +1 works for him. It is the only nation latent in his export that does.
  - It is passive Refresh +X, so by the player's Refresh priorities (header) it belongs in idle sets, not the Refresh midcast.
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Red Lotus Blade (Mid buff); Aeolian Edge (Mid buff); Casting (Free Nuke, Magic Burst); BLU: Sanguine Blade (Mid buff, Ice Brand enabled); Red Lotus Blade (Ice Brand enabled).

### Stoicheion Medal

*Stoicheion Medal.*

- Elemental magic casting time -3% only matters at precast and doesn't shorten recast. ([ffxi-mechanics.md](ffxi-mechanics.md#spell-specific-and-school-casting-time))
- bg-wiki caps casting time reduction at 80%. If school casting time counts inside that cap (bg-wiki's reading, disputed by the player), it adds nothing on RDM, whose fast-cast set is at 82%.
- For midcast, Sanctity Necklace's MAB 10 and Macc 10 beat its MAB 8 and Macc 2. ([bg-wiki](https://www.bg-wiki.com/ffxi/Fast_Cast))

### Twilight Torque

*Twilight Torque.*

- Loricate Torque and Elite Royal Collar both have the same Damage taken -5% plus more (DEF, or DEF and VIT), so both strictly beat it. ([bg-wiki](https://www.bg-wiki.com/ffxi/Twilight_Torque))

### Weike Torque

*Weike Torque.*

- Enfeebling skill raises Distract III and Frazzle III potency by 6/21 per point, so +7 skill is only about 2 points of evasion or magic evasion down.
- For RDM enfeebling, Dls. Torque +1 (Magic Accuracy +25, potency ×1.07, augmented duration) is the stronger neck. ([bg-wiki](https://www.bg-wiki.com/ffxi/Distract_III))

No notes beyond the help text: Asperity Necklace, Chivalrous Chain, Houyi's Gorget, Imbodla Necklace, Kubira Beads, Marked Gorget, Shifting Neck. +1, Subtlety Spec., Torero Torque.

## Earrings

### Alabaster Earring

*Alabaster Earring.*

- The Accuracy, Ranged Accuracy and Magic Accuracy +15 in its help text are for the pet. The wearer gets accuracy only from Path A.
- At the maximum rank, 30, Path A gives Accuracy, Ranged Accuracy and Magic Accuracy +15 (ranks 1-15 add +1 each), All attributes +10 (ranks 16-25) and Store TP +5 (ranks 26-30).
- The export doesn't show the rank, and Vanar's rank isn't recorded, since ranks change often; ask the player when a set decision turns on it. A lower-rank copy loses the Store TP first, then the attributes, then the accuracy. For each rank's values, see [rank-augments.md](rank-augments.md#alabaster-earring) ([bg-wiki](https://www.bg-wiki.com/ffxi/Alabaster_Earring); [FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Alabaster_Earring)).
- Its Damage taken -5% is 12/256, about 4.7%. Damage taken is counted in 1/256 steps against a cap of 128/256 (-50%), so add 12, not a full 5%, when totalling DT toward the cap (bg-wiki: [Alabaster Earring](https://www.bg-wiki.com/ffxi/Alabaster_Earring), [Damage Taken](https://www.bg-wiki.com/ffxi/Damage_Taken)).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Chant du Cygne (Mid buff, High buff); Death Blossom (Mid buff, High buff); Knights of Round (Mid buff, High buff); Requiescat (Mid buff, High buff); Mercy Stroke (Mid buff, High buff); Evisceration (Mid buff, High buff); Naegling + Thibron TP (-50% DT, -25% DT); BLU: Requiescat (Mid buff, High buff); Tizona + Thibron AM3 TP (-50% DT, -25% DT); Caliburnus + Thibron AM1 TP (-50% DT, -25% DT).

### Arbatel Earring +1

*Arbatel Earring +1. SCH only.*

- Like its base stats, its augments work only in the right ear: bg-wiki lists them under "Right Ear".
- They roll Mag. Acc. +11 to 15 and Enmity -1 to -5. This copy has +13 and -3 ([bg-wiki](https://www.bg-wiki.com/ffxi/Arbatel_Earring_%2B1)).

### Augment. Earring

*Augmenting Earring.*

- Its only stat is Enhancing magic skill +3.
- Andoaa Earring (+5 and MP+30) and Mimir Earring (+10), both in Vanar's export, beat it, so it never makes an enhancing set (bg-wiki: [Augment. Earring](https://www.bg-wiki.com/ffxi/Augment._Earring), [Andoaa Earring](https://www.bg-wiki.com/ffxi/Andoaa_Earring), [Mimir Earring](https://www.bg-wiki.com/ffxi/Mimir_Earring)).

### Bladeborn Earring

*Bladeborn Earring.*

- Its set bonus needs Steelflash Earring, which Vanar owns, in the other ear. The two together give Double Attack +7% in total; either alone gives none (bg-wiki: [Bladeborn Earring](https://www.bg-wiki.com/ffxi/Bladeborn_Earring), [Double Attack](https://www.bg-wiki.com/ffxi/Double_Attack)).
- The pair takes both ears for DA 7%, Accuracy 8, Attack 8 and Store TP 2.
- On BLU, Brutal Earring (DA 5%, STP 1) plus Vanar's Hashi. Earring +1 in the right ear (DA 4%, Acc 12, Mag. Acc. 12, Sword skill +11) gives DA 9% and more accuracy.
- With a sword in the main hand, that combination beats the pair on everything but Store TP, since the sword skill also adds about +10 attack.
- Combat skill only counts for hits from a hand holding that weapon type. So with Maxentius in the main hand, the pair also keeps its Attack +8 (bg-wiki: [Double Attack](https://www.bg-wiki.com/ffxi/Double_Attack), [Hashi. Earring +1](https://www.bg-wiki.com/ffxi/Hashi._Earring_%2B1), [Attack](https://www.bg-wiki.com/ffxi/Attack), [Dual Wield](https://www.bg-wiki.com/ffxi/Dual_Wield)).
- Set bonus: Bladeborn and Steelflash, see [Bladeborn and Steelflash set](#bladeborn-and-steelflash-set).

### Brutal Earring

*Brutal Earring.*

- The unnumbered 'Enhances "Double Attack" effect' is Double Attack +5% (bg-wiki: [Brutal Earring](https://www.bg-wiki.com/ffxi/Brutal_Earring), [Double Attack](https://www.bg-wiki.com/ffxi/Double_Attack)).

### Calamitous Earring

*Calamitous Earring.*

- The icon in its help text is Wind resistance +10.
- Conserve MP +4 is a 4% chance per cast to cut that spell's MP cost by 6.25% to 50% (about 28% on average). That saves roughly 1% of MP overall (bg-wiki: [Calamitous Earring](https://www.bg-wiki.com/ffxi/Calamitous_Earring), [Conserve MP](https://www.bg-wiki.com/ffxi/Conserve_MP)).

### Choleric Earring

*Choleric Earring.*

- 'Increases magic critical hit damage' is +10, so a magic crit adds +20 MAB instead of the base +10.
- At a 10% rate that averages about +2 MAB, far below Friomisi Earring's flat MAB +10.
- Only blue, divine and elemental magic can magic-crit, so its crit stats do nothing for magical weapon skills or enfeebling magic (bg-wiki: [Choleric Earring](https://www.bg-wiki.com/ffxi/Choleric_Earring), [Magic Critical Hit](https://www.bg-wiki.com/ffxi/Magic_Critical_Hit)).

### Darkness Earring

*Darkness Earring.*

- The icon in its help text is Dark resistance +15.
- This copy's random quest augments are minor. PDT -1% (a copy can roll at most -2%) adds to DT toward the -50% physical cap. The other is Resist Petrify +3 (bg-wiki: [Darkness Earring](https://www.bg-wiki.com/ffxi/Darkness_Earring), [Scattered Shells, Scattered Mind](https://www.bg-wiki.com/ffxi/Scattered_Shells,_Scattered_Mind)).

### Dudgeon Earring

*Dudgeon Earring.*

- Its set bonus needs Heartseeker Earring, which Vanar owns, in the other ear. The two together give Dual Wield +7% in total; either alone gives none.
- It only helps while dual wielding: RDM needs /NIN or /DNC, and BLU needs set blue magic that gives the Dual Wield trait.
- Suppanomimi, also in Vanar's export, gives Dual Wield +5% from a single ear (bg-wiki: [Dudgeon Earring](https://www.bg-wiki.com/ffxi/Dudgeon_Earring), [Dual Wield](https://www.bg-wiki.com/ffxi/Dual_Wield), [Suppanomimi](https://www.bg-wiki.com/ffxi/Suppanomimi)).
- Set bonus: Dudgeon and Heartseeker, see [Dudgeon and Heartseeker set](#dudgeon-and-heartseeker-set).

### Estq. Earring

*Estoqueur's Earring. RDM only.*

- The unnumbered 'Enhances "Fast Cast" effect' is Fast Cast +2%, the same as Loquac. Earring.
- It has Magic Accuracy +3 where Loquac. has MP+30, so on RDM the two are interchangeable for Fast Cast (bg-wiki: [Estq. Earring](https://www.bg-wiki.com/ffxi/Estq._Earring), [Fast Cast](https://www.bg-wiki.com/ffxi/Fast_Cast), [Loquac. Earring](https://www.bg-wiki.com/ffxi/Loquac._Earring)).

### Halasz Earring

*Halasz Earring.*

- Magic critical hit rate +14% only works on blue, divine and elemental magic.
- Each crit adds +10 MAB, so it averages about +1.4 MAB, well below Friomisi Earring's flat +10 ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Critical_Hit)).

### Hashi. Earring +1

*Hashishin Earring +1. BLU only.*

- It only works in the right ear, augments included: bg-wiki lists the Accuracy/Magic Accuracy and Double Attack augments under "Right Ear" too. In the left ear it gives nothing.
- This copy rolled Accuracy and Magic Accuracy +12 (range 11-15) and Double Attack +4% (range 3-5%) (bg-wiki: [Hashi. Earring +1](https://www.bg-wiki.com/ffxi/Hashi._Earring_%2B1), [Sortie rewards](https://www.bg-wiki.com/ffxi/Category:Sortie_Rewards)).
- Sword skill +11 only helps hits from a hand holding a sword.
- Past 600 sword skill each point is about 0.9 accuracy, so it is about Accuracy +9 to +10, and roughly as much attack.
- With Maxentius in the main hand it does nothing for main-hand hits.
- Physical blue magic takes its accuracy from the main-hand weapon plus DEX and Accuracy, so the sword skill helps it only with a sword in the main hand.
- Blue magic skill +11 raises physical blue magic's damage, and magical blue magic's accuracy (added effects included) and potency (bg-wiki: [Accuracy](https://www.bg-wiki.com/ffxi/Accuracy), [Attack](https://www.bg-wiki.com/ffxi/Attack), [Dual Wield](https://www.bg-wiki.com/ffxi/Dual_Wield), [Blue Magic](https://www.bg-wiki.com/ffxi/Category:Blue_Magic)).
- Use the plain `gear.hashishinEarringPlusOne`. The library's `gear.hashishinEarringPlusOneDA` lists max-roll augments (Accuracy+15, Mag. Acc.+15, "Dbl.Atk."+5) that Vanar's copy doesn't have, so GearSwap wouldn't match it to this earring ([GearSets-Include.lua](https://github.com/khowe085/rahvin-gearswap/blob/a36cbf6/RahvinGS/GearSets-Include.lua), lines 4287 and 4519).

### Heartseeker Earring

*Heartseeker Earring.*

- Its set bonus needs Dudgeon Earring, which Vanar owns, in the other ear. The two together give Dual Wield +7% in total; either alone gives none.
- It only helps while dual wielding: RDM needs /NIN or /DNC, and BLU needs set blue magic that gives the Dual Wield trait.
- Suppanomimi, also in Vanar's export, gives Dual Wield +5% from a single ear (bg-wiki: [Heartseeker Earring](https://www.bg-wiki.com/ffxi/Heartseeker_Earring), [Dual Wield](https://www.bg-wiki.com/ffxi/Dual_Wield), [Suppanomimi](https://www.bg-wiki.com/ffxi/Suppanomimi)).
- Set bonus: Dudgeon and Heartseeker, see [Dudgeon and Heartseeker set](#dudgeon-and-heartseeker-set).

### Hecate's Earring

*Hecate's Earring.*

- Friomisi Earring (MAB +10) and Novio Earring (MAB +7), both in Vanar's export, fill both ears with more MAB, so it never makes a nuke or magical weapon skill set.
- Its MAB +6 plus a 3% magic crit rate (+10 MAB on a crit) averages about +6.3 MAB on spells. Weapon skills can't magic-crit (bg-wiki: [Magic Critical Hit](https://www.bg-wiki.com/ffxi/Magic_Critical_Hit), [Friomisi Earring](https://www.bg-wiki.com/ffxi/Friomisi_Earring), [Novio Earring](https://www.bg-wiki.com/ffxi/Novio_Earring)).

### Hollow Earring

*Hollow Earring.*

- 'Sword enhancement spell' means the Enspells, which work with any weapon type.
- The +3 counts only while worn during each melee round. It does nothing at the cast.
- On an earring it applies to both hands, though tier II Enspells only add damage to the first main-hand hit of a round.
- Composure triples it (bg-wiki: [Enspell](https://www.bg-wiki.com/ffxi/Category:Enspell), [Composure](https://www.bg-wiki.com/ffxi/Composure)).
- The player's rule against Enspell gear that must stay on while meleeing rules it out ([ffxi-mechanics.md](ffxi-mechanics.md#player-rules-for-these-jobs)).

### Leth. Earring +1

*Lethargy Earring +1. RDM only.*

- Its augments are right-ear only too: bg-wiki lists them under "Right Ear" on the item page and in the Sortie +1 earring table. In the left ear this copy gives nothing.
- This copy has the lowest roll: Accuracy and Magic Accuracy +11 (range 11-15) and Double Attack +3% (range 3-5%). bg-wiki says the two augment slots rise together (bg-wiki: [Leth. Earring +1](https://www.bg-wiki.com/ffxi/Leth._Earring_%2B1), [Sortie rewards](https://www.bg-wiki.com/ffxi/Category:Sortie_Rewards)).
- Fast Cast 8% shortens casting time from the precast set.
- Worn in a midcast set it also cuts recast by 4%.
- Its Enhancing magic duration +8% is listed (not augmented) duration, read when the spell lands. It adds to the other listed duration % in the same multiplier (bg-wiki: [Lethargy Armor Set](https://www.bg-wiki.com/ffxi/Lethargy_Armor_Set), [Spell Recast](https://www.bg-wiki.com/ffxi/Spell_Recast)).
- It is not a Lethargy armor piece, so it doesn't count toward the Composure set bonus; see [Lethargy set](#lethargy-set). Only the five Empyrean and Reforged Empyrean armor pieces count ([bg-wiki](https://www.bg-wiki.com/ffxi/Lethargy_Armor_Set)).

### Lifestorm Earring

*Lifestorm Earring.*

- Its set bonus, Magic Accuracy+12, only applies while Psystorm Earring, which Vanar owns, is in the other ear.
- Neither wiki says whether +12 is the pair's total or each earring's. bg-wiki's Double Attack table counts the matching Steelflash/Bladeborn pair's 7% once, so assume +12 in total for the pair, plus this earring's MND+4 and Psystorm's INT+4 (bg-wiki: [Lifestorm Earring](https://www.bg-wiki.com/ffxi/Lifestorm_Earring), [Double Attack](https://www.bg-wiki.com/ffxi/Double_Attack); [FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Lifestorm_Earring)).
- The pair takes both ears.
- On RDM, Leth. Earring +1 (right ear; Vanar's copy Magic Accuracy+11) plus Snotra Earring (Magic Accuracy+10, MND+8) gives Magic Accuracy+21 against the pair's +12.
- On BLU, Vanar's Hashi. Earring +1 (right ear; Magic Accuracy+12, Blue magic skill+11) matches the pair's +12 by itself (if +12 is the pair's total). It leaves the left ear free, for example for Choleric Earring (Magic Accuracy+2) or, for blue magic, Njordr Earring (Blue magic skill+10).
- The pair only adds INT+4 and MND+4 over those (bg-wiki: [Snotra Earring](https://www.bg-wiki.com/ffxi/Snotra_Earring), [Hashi. Earring +1](https://www.bg-wiki.com/ffxi/Hashi._Earring_%2B1), [Choleric Earring](https://www.bg-wiki.com/ffxi/Choleric_Earring)).
- Set bonus: Lifestorm and Psystorm, see [Lifestorm and Psystorm set](#lifestorm-and-psystorm-set).

### Loquac. Earring

*Loquacious Earring.*

- Its "Enhances Fast Cast" is Fast Cast +2% ([bg-wiki](https://www.bg-wiki.com/ffxi/Loquac._Earring)).

### Lyc. Earring

*Lycopodium Earring.*

- Sword enhancement spell damage +2 applies during melee rounds, not at the cast, so it has to stay on while attacking.
- Composure multiplies it.
- On armor it applies to both hands and to any weapon type ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Enspell)).
- The player's rule against Enspell gear while meleeing leaves it no role ([ffxi-mechanics.md](ffxi-mechanics.md#player-rules-for-these-jobs)).
- For Enspell damage, Vanar's Hollow Earring is better: Sword enhancement spell damage +3 against this earring's +2, plus Accuracy+3 and DEX+2.
- Lyc.'s only edge is Magic Accuracy+1, which bg-wiki says does count toward each Enspell hit's magic accuracy (bg-wiki: [Hollow Earring](https://www.bg-wiki.com/ffxi/Hollow_Earring), [Enspell](https://www.bg-wiki.com/ffxi/Category:Enspell)).

### Macu. Earring +1

*Maculele Earring +1. DNC only.*

- Base stats and augments work only in the right ear.
- This copy rolled Accuracy/Magic Accuracy +12 (range 11-15) and Store TP +4 (range 3-5) ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Sortie_Rewards)).

### Mendi. Earring

*Mendicant's Earring.*

- In the Cure precast set, only its Cure spellcasting time -5% does anything. bg-wiki counts it together with Fast Cast toward the 80% cap.
- Cure potency +5% counts toward the 50% Cure potency cap (Cure potency II has its own 30% cap).
- Like other potency stats, Cure potency only counts if worn when the Cure goes off, in the midcast set.
- Conserve MP+2 is a 2% chance per spell to cut its MP cost by 6.25-50% (about 28% on average) (bg-wiki: [Cure spells](https://www.bg-wiki.com/ffxi/Category:Cure_Spell), [Conserve MP](https://www.bg-wiki.com/ffxi/Conserve_MP)).

### Moonshade Earring

*Moonshade Earring.*

- Effective TP caps at 3000, so TP Bonus +250 shrinks above 2750 TP.
- Thibron's TP Bonus +1000 is an augment, so it counts from the sub slot for every weapon skill. With Thibron in the sub slot, Moonshade adds nothing at 2000 TP or more and only part of its 250 between 1750 and 2000.
- TP Bonus doesn't raise Aftermath. Its level comes only from the TP actually held when the weapon skill goes off, so Moonshade doesn't change the Aftermath from a weapon such as Tizona ([bg-wiki](https://www.bg-wiki.com/ffxi/TP_Bonus)).
- bg-wiki disagrees with itself on blue magic. The TP Bonus page says TP Bonus gear doesn't affect physical blue magic, even under Chain Affinity or Azure Lore. The Moonshade page says it can when Chain Affinity uses TP.
- Efflux grants its TP Bonus without consuming TP, so the Moonshade page's exception doesn't cover it either. Efflux's own bonus is raised only by "Efflux TP Bonus" gear (Hashishin Tayt, Rosmerta's Cape).
- In physical blue magic, only Attack+4 is sure to count (bg-wiki: [TP Bonus](https://www.bg-wiki.com/ffxi/TP_Bonus), [Moonshade Earring](https://www.bg-wiki.com/ffxi/Moonshade_Earring), [Efflux](https://www.bg-wiki.com/ffxi/Efflux)).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Savage Blade (Mid buff, High buff); Imperator (Mid buff, High buff); Seraph Blade (Mid buff); Red Lotus Blade (Mid buff); Ruthless Stroke (Mid buff, High buff); Black Halo (Mid buff, High buff); Aeolian Edge (Mid buff); BLU: Expiacion (Mid buff, High buff); Imperator (Mid buff, High buff); Savage Blade (Mid buff, High buff); Red Lotus Blade (Mid buff, Ice Brand enabled).
- wsdist: its entry has Accuracy+4 where Vanar's copy has Attack+4. TP Bonus +250 matches. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), line 728)

### Njordr Earring

*Njordr Earring.*

- Blue magic skill sets the magic accuracy and potency of magical blue magic, the accuracy of any blue magic spell's additional effect, and blue magic spell interruption rate.
- For physical blue magic it adds to damage, but the hit's accuracy comes from the main-hand weapon's accuracy, DEX and Accuracy.
- It does nothing for spells that aren't blue magic ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Blue_Magic)).

### Novio Earring

*Novio Earring.*

- For magic damage, Vanar's Friomisi Earring (Magic Atk. Bonus+10, Enmity+2) beats it. Novio's only edge is having no Enmity+2 ([bg-wiki](https://www.bg-wiki.com/ffxi/Friomisi_Earring)).

### Pel. Earring +1

*Peltast's Earring +1. DRG only.*

- Base stats and augments work only in the right ear.
- This copy rolled Accuracy/Magic Accuracy +13 (range 11-15) and Critical hit rate +4% (range 3-5%) ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Sortie_Rewards)).

### Psystorm Earring

*Psystorm Earring.*

- Its set bonus, Magic Accuracy+12, only applies while Lifestorm Earring, which Vanar owns, is in the other ear.
- Assume +12 in total for the pair. Neither wiki says, but bg-wiki counts the Steelflash/Bladeborn pair's bonus once.
- The pair takes both ears. On RDM, Leth. Earring +1 plus Snotra Earring (Magic Accuracy+21 together) beats it.
- On BLU, Hashi. Earring +1 alone (right ear, Magic Accuracy+12, Blue magic skill+11) matches its Magic Accuracy and frees the left ear (bg-wiki: [Psystorm Earring](https://www.bg-wiki.com/ffxi/Psystorm_Earring), [Double Attack](https://www.bg-wiki.com/ffxi/Double_Attack), [Hashi. Earring +1](https://www.bg-wiki.com/ffxi/Hashi._Earring_%2B1)).
- Set bonus: Lifestorm and Psystorm, see [Lifestorm and Psystorm set](#lifestorm-and-psystorm-set).

### Reraise Earring

*Reraise Earring.*

- It gives Reraise I: on KO you are raised with 10% HP and get back half the lost EXP.
- FFXIclopedia says the effect lasts 2 hours, doesn't overwrite a Reraise from the spell, and isn't removed by Level Sync or level restriction (bg-wiki: [Reraise category](https://www.bg-wiki.com/ffxi/Category:Reraise), [Reraise](https://www.bg-wiki.com/ffxi/Reraise); [FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Reraise_Earring)).
- It has 10 charges.
- bg-wiki lists an 8-second use time, a 30-second wait after equipping before it can be used, and a 60-second reuse. FFXIclopedia agrees on 30 seconds and 1 minute.
- A GearSwap swap that takes it off restarts the 30-second wait, so lock the ear slot while waiting ([bg-wiki](https://www.bg-wiki.com/ffxi/Reraise_Earring); [FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Reraise_Earring)).

### Signal Pearl

*Signal Pearl.*

- It calls your Adventuring Fellow. It has 1 charge and a 6-hour recast (21,600 s).
- bg-wiki lists a 10-second wait after equipping and a 3-second use time. FFXIclopedia lists a 30-second wait.
- FFXIclopedia says it can't be used under Level Sync or level restriction, and that you can put your normal earring back on after the call ([bg-wiki](https://www.bg-wiki.com/ffxi/Signal_Pearl); [FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Signal_Pearl)).

### Skulk. Earring +1

*Skulker's Earring +1. THF only.*

- Base stats and augments work only in the right ear.
- This copy has the lowest rolls: Accuracy/Magic Accuracy +11 (range 11-15) and Store TP +3 (range 3-5) ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Sortie_Rewards)).

### Skulker's Earring

*Skulker's Earring. THF only.*

- Base stats and augment work only in the right ear.
- This copy rolled Accuracy/Magic Accuracy +9 (range 6-10) ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Sortie_Rewards)).

### Snotra Earring

*Snotra Earring. RDM only.*

- Its +10% is enfeebling duration listed on gear, read when the spell lands, so it belongs in the midcast set.
- bg-wiki's formula multiplies listed duration and augmented duration as separate terms. Snotra shares the listed term with Vanar's Obstin. Sash (5%), while Dls. Torque +1's augmented enfeebling duration (+20% at rank 20) is its own multiplier.
- Dia's duration formula uses the same terms, so it lengthens Dia too (bg-wiki: [Enfeebling Magic](https://www.bg-wiki.com/ffxi/Category:Enfeebling_Magic), [Dls. Torque +1](https://www.bg-wiki.com/ffxi/Dls._Torque_%2B1)).
- Enfeebling duration also depends on how far the spell is resisted, so its Magic Accuracy+10 lengthens debuffs as well as landing them ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Enfeebling_Magic)).

### Steelflash Earring

*Steelflash Earring.*

- Its set bonus, Double Attack+7%, only applies while Bladeborn Earring (which Vanar owns: Attack+8, Store TP+1) is in the other ear. bg-wiki's Double Attack table counts the 7% once for the pair (bg-wiki: [Steelflash Earring](https://www.bg-wiki.com/ffxi/Steelflash_Earring), [Double Attack](https://www.bg-wiki.com/ffxi/Double_Attack)).
- The pair takes both ears, so it can't be worn with the right-ear-only Leth. Earring +1 (RDM: Acc+11, DA+3%) or Hashi. Earring +1 (BLU: Acc+12, DA+4%, Sword skill+11) (bg-wiki: [Bladeborn Earring](https://www.bg-wiki.com/ffxi/Bladeborn_Earring), [Leth. Earring +1](https://www.bg-wiki.com/ffxi/Leth._Earring_%2B1), [Hashi. Earring +1](https://www.bg-wiki.com/ffxi/Hashi._Earring_%2B1)).
- Set bonus: Bladeborn and Steelflash, see [Bladeborn and Steelflash set](#bladeborn-and-steelflash-set).

### Suppanomimi

*Suppanomimi.*

- "Enhances Dual Wield" is Dual Wield +5%.
- FFXIclopedia says it doesn't grant Dual Wield, so it only helps when Dual Wield comes from /NIN, /DNC or BLU's set spells.
- Vanar's Dudgeon + Heartseeker pair gives Dual Wield +7% but takes both ears (bg-wiki: [Suppanomimi](https://www.bg-wiki.com/ffxi/Suppanomimi), [Heartseeker Earring](https://www.bg-wiki.com/ffxi/Heartseeker_Earring); [FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Suppanomimi)).
- Sword skill +5 only helps with a sword in hand.
- Past 600 sword skill, bg-wiki's formulas make it worth Accuracy +4 or +5 (0.9 per point, rounded down) and Attack+5 (bg-wiki: [Accuracy](https://www.bg-wiki.com/ffxi/Accuracy), [Attack](https://www.bg-wiki.com/ffxi/Attack)).

### Triumph Earring

*Triumph Earring.*

- The two icon glyphs in its help text are elements: it gives Fire resistance +11 and Ice resistance +11, with STR+2 ([bg-wiki](https://www.bg-wiki.com/ffxi/Triumph_Earring); [FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Triumph_Earring)).

### Velocity Earring

*Velocity Earring.*

- How much Resist Slow it gives is unknown: bg-wiki lists '?'.
- Per bg-wiki, Resist Slow also fully resists Addle a percentage of the time ([bg-wiki](https://www.bg-wiki.com/ffxi/Resist_Slow)).

No notes beyond the help text: Andoaa Earring, Assuage Earring, Buckler Earring, Etiolation Earring, Friomisi Earring, Grit Earring, Infused Earring, Mimir Earring, Novia Earring.

## Body

### Adhemar Jacket

*Adhemar Jacket. BLU, not RDM.*

- Its augments are Nolan Path B at rank 15, the path's maximums. Mezzotint stats grow with rank, so this copy is fully ranked.
- Path D is the caster path (HP+80, Fast Cast +7%, Magic damage taken -3%). This copy doesn't have it ([bg-wiki](https://www.bg-wiki.com/ffxi/Nolan)).
- Set bonus: Adhemar, see [Adhemar set](#adhemar-set). Only +1 pieces count, so this NQ jacket never does ([bg-wiki](https://www.bg-wiki.com/ffxi/Adhemar_Attire_Set)).

### Argute Gown +2

*Argute Gown +2. SCH only; not RDM or BLU.*

- Its Sublimation bonus drains 2 more HP and charges 2 more MP per tick.
- This copy has no Magian augment, so it lacks the Enlightenment bonus (+2 per merit level to six magic skills) ([bg-wiki](https://www.bg-wiki.com/ffxi/Argute_Gown_%2B2)).

### Assim. Jubbah +4

*Assimilator's Jubbah +4. BLU only.*

- Set bonus: Assimilator's, see [Assimilator's set](#assimilators-set). bg-wiki gives +4 pieces the same bonus as +2 and +3, so this one counts ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Reforged_Artifact_Armor_%2B3)).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): BLU: Expiacion (High buff); Imperator (High buff).

### Atrophy Tabard +4

*Atrophy Tabard +4. RDM only.*

- "Refresh" potency +2 adds 2 MP per tick to the Refresh spells you cast.
- It is read when the spell lands, so it belongs in the Refresh midcast ([bg-wiki](https://www.bg-wiki.com/ffxi/Refresh)).
- Its separate "Refresh"+3 is Refresh +3: the wearer gets 3 MP per tick while it is on.
- By the player's Refresh priorities (header), it fits both sets: its potency in the Refresh midcast and its Refresh +3 in idle sets.
- Set bonus: Atrophy, see [Atrophy set](#atrophy-set).

### Bunzi's Robe

*Bunzi's Robe. RDM, not BLU.*

- Vanar's copy is rank 0 (player, 2026-10-02): no augments, only the base stats in its help text. The export prints no augments for it, not even `'Path: A'`.
- Its only path, Odyssey Path A, adds Attack, Magic Damage and Physical damage limit from rank 1, Accuracy and Magic Accuracy from rank 16, and DEX from rank 21. For the values at each rank, see [rank-augments.md](rank-augments.md#bunzis-robe) ([bg-wiki](https://www.bg-wiki.com/ffxi/Bunzi%27s_Robe)).
- "Cure" potency +15% counts toward the 50% Cure potency cap, not the separate 30% Cure potency II cap ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Cure_Spell)).
- Magic burst damage +10 is tier I, so it counts toward the 40% gear cap.
- Only Magic burst damage II, the Magic Burst Bonus trait, job points and gifts go past that cap ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Burst)).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Death Blossom (High buff); Imperator (High buff); Requiescat (High buff); Black Halo (High buff). Vanar's copy is rank 0, without the rank 30 augment (Attack and Magic Damage +30, Physical damage limit +8%, Accuracy and Magic Accuracy +15, DEX+5), so the sims overvalue it ([rank-augments.md](rank-augments.md#bunzis-robe)).

### Councilor's Garb

*Councilor's Garb.*

- Only the single highest movement-speed bonus from equipment counts.
- Its +25% replaces any other movement-speed gear (such as an 18% piece) rather than adding to it ([bg-wiki](https://www.bg-wiki.com/ffxi/Movement_Speed)).

### Despair Mail

*Despair Mail.*

- This copy has no Nolan path, so it is unaugmented.
- At rank 15, Path B would add STR+12, VIT+7 and Haste+2%. Path D would add Attack+25, Magic Evasion+20 and Double Attack+3% ([bg-wiki](https://www.bg-wiki.com/ffxi/Nolan)).
- As it is, Hashishin Mintan +3 (BLU) and Lethargy Sayon +3 (RDM) match or beat it in every combat stat (Accuracy 64 vs 23).
- It keeps only more HP (121 vs 87) and, against the Sayon, 1% more haste. For HP, Nyame Mail has more still (136) ([bg-wiki](https://www.bg-wiki.com/ffxi/Despair_Mail)).

### Ea Houppelande

*Ea Houppelande. RDM, not BLU.*

- Magic burst damage +8 counts toward the 40% gear cap. Magic burst damage II +8 is outside that cap and has no known cap of its own.
- Below the cap that is 16 against Bunzi's Robe's 10. Once other gear fills the 40%, it is still 8 against Bunzi's 0.
- Ea also has 9 more Magic Attack Bonus (39 vs 30) and 2 more Magic Accuracy. Bunzi's Robe keeps Magic Damage +30, DT -10% and 5 more INT ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Burst)).

### Gende. Bliaut +1

*Gendewitha Bliaut +1. RDM, not BLU.*

- Unaugmented.
- For RDM, Bunzi's Robe beats it for Cure (+15% vs +8%, plus DT -10%), and Lethargy Sayon +3 beats it for Refresh +X (+4 vs +2). Another piece Vanar owns covers each of its uses ([bg-wiki](https://www.bg-wiki.com/ffxi/Gende._Bliaut_%2B1)).

### Gleti's Cuirass

*Gleti's Cuirass. BLU, not RDM.*

- Vanar's copy is rank 0 (player, 2026-10-02): no augments, only the base stats in its help text. The export prints no augments for it, not even `'Path: A'`.
- Its only path, Odyssey Path A, adds Attack and Double Attack from rank 1, Accuracy and Magic Accuracy from rank 16, and "Occasionally increases resistance to status ailments" from rank 21. For the values at each rank, see [rank-augments.md](rank-augments.md#gletis-cuirass) ([bg-wiki](https://www.bg-wiki.com/ffxi/Gleti%27s_Cuirass)).
- "Waltz" potency +10% multiplies the HP restored by your Curing Waltz (from a DNC subjob).
- Waltz potency gear caps at 50%. Waltz potency received has its own 30% cap ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Waltz)).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): BLU: Chant du Cygne (Mid buff, High buff); Requiescat (High buff); Savage Blade (High buff). Vanar's copy is rank 0, without the rank 30 augment (Attack+30, Double Attack +10%, Accuracy and Magic Accuracy +15, status ailment resistance +10), so the sims overvalue it ([rank-augments.md](rank-augments.md#gletis-cuirass)).

### Hashishin Mintan +3

*Hashishin Mintan +3. BLU only.*

- Blue magic spellcasting time -16% shortens only blue magic casting time.
- It is read at precast. Unlike Fast Cast, it doesn't shorten recast ([bg-wiki](https://www.bg-wiki.com/ffxi/Hashishin_Mintan_%2B3)).
- Set bonus: Hashishin, see [Hashishin set](#hashishin-set).

### Helios Jacket

*Helios Jacket.*

- Unaugmented.
- For fast cast, its 3% loses to Luhlaza Jubbah +1 (7%) on BLU and Viti. Tabard +4 (15%) on RDM ([bg-wiki](https://www.bg-wiki.com/ffxi/Helios_Jacket)).

### Herculean Vest

*Herculean Vest. BLU, not RDM.*

- This copy is built for critical hits. Crit hit rate +5 is the Fern-stone maximum for its slot, for 8% in total.
- Its combined Accuracy+15 Attack+15 is below that slot's cap of 25.
- Pet: STR and Mag. Acc./MAB +3 are wasted ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Escha_Rewards/Arcane_Glyptics_Inscription)).
- For crit weapon skills, Gleti's Cuirass matches its 8% crit rate with more Accuracy (40 vs 30), Attack (40 vs 23) and STR (39 vs 28), plus Physical damage limit +9% ([bg-wiki](https://www.bg-wiki.com/ffxi/Herculean_Vest)).

### Ischemia Chasu.

*Ischemia Chasuble.*

- For RDM, Atrophy Tabard +4 beats it in every stat: Enfeebling skill 22 vs 18, Refresh +3 vs +2, Magic Accuracy 65 vs 15.
- For BLU, Hashishin Mintan +3 beats it in everything except enfeebling skill: Refresh +4, Accuracy and Magic Accuracy 64 ([bg-wiki](https://www.bg-wiki.com/ffxi/Ischemia_Chasu.)).

### Jhakri Robe +2

*Jhakri Robe +2.*

- Set bonus: Jhakri, see [Jhakri set](#jhakri-set).
- Lethargy Sayon +3 (RDM) and Hashishin Mintan +3 (BLU) match its Refresh +4. They beat it in Accuracy, Attack, Magic Accuracy, Magic Attack Bonus, haste and DT.
- Jhakri keeps only 3 more STR, 3 to 5 more INT, and its count toward the Jhakri Fast Cast set bonus ([bg-wiki](https://www.bg-wiki.com/ffxi/Jhakri_Robe_%2B2)).
- wsdist: it has gear haste 4% where the item has Haste+1%. That only changes a run whose set is under wsdist's 25% gear haste cap. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), line 903)

### Lethargy Sayon +3

*Lethargy Sayon +3. RDM only.*

- Enfeebling magic effect +18% multiplies the potency of Blind, Slow, Paralyze, Addle, Frazzle, Distract and Poison. Poison II's page gives the same formula.
- It also multiplies Gravity's potency, which nothing but Saboteur and this stat raises.
- Sleep, Silence, Bind, Break and Dispel have no variable potency for it to raise (bg-wiki: [Enfeebling Magic](https://www.bg-wiki.com/ffxi/Category:Enfeebling_Magic), [Gravity](https://www.bg-wiki.com/ffxi/Gravity), [Poison II](https://www.bg-wiki.com/ffxi/Poison_II)).
- On Dia, Dia II and Dia III it adds only to the damage over time, +1 HP per tick per 1% (+18 here) ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Enfeebling_Magic)). The Dia III page alone says +1 per effect worn, without saying per piece or per 1%.
- No page says it changes any Dia's defense down ([bg-wiki](https://www.bg-wiki.com/ffxi/Dia_III)).
- Set bonus: Lethargy, see [Lethargy set](#lethargy-set).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Casting (Free Nuke).

### Luhlaza Jubbah +1

*Luhlaza Jubbah +1. BLU only.*

- The Enchainment augment adds +50 TP Bonus per Enchainment merit level to Chain Affinity, on top of the merits' own +100 per level. At 5/5 merits that is +250, for +750 in total.
- Vanar has 5 Enchainment merits (player, 2026-10-02). So he gets the full amount: 5 × 100 = +500 from the merits and 5 × 50 = +250 from the augment, +750 in all, the maximum bg-wiki's [Enchainment](https://www.bg-wiki.com/ffxi/Enchainment) page gives.
- bg-wiki doesn't say whether it is read when Chain Affinity is used or when the physical spell goes off. Only wearing it at both moments is sure to get it ([bg-wiki](https://www.bg-wiki.com/ffxi/Enchainment)).
- The help text's '"Refesh"+2' is a typo for Refresh +2 ([bg-wiki](https://www.bg-wiki.com/ffxi/Luhlaza_Jubbah_%2B1)).

### MG Jerkin +1

*MG Jerkin +1. Elvaan males only.*

- It belongs to the MGM set, so only Elvaan males can wear it, even though it lists all jobs.
- If Vanar isn't an Elvaan male, he can't equip it ([bg-wiki](https://www.bg-wiki.com/ffxi/Magna_Attire_Set)).

### Nyame Mail

*Nyame Mail.*

- Vanar's copy is Path B at rank 20 (player, 2026-10-02): Attack+25, Ranged Attack+25, Weapon skill damage +10% and Double Attack +3%. The export prints the path but not the rank.
- Path B's STR/VIT augment only starts at rank 21, so this copy has none. For the other ranks and paths, see [rank-augments.md](rank-augments.md#nyame-mail) ([bg-wiki](https://www.bg-wiki.com/ffxi/Nyame_Mail)).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Savage Blade (Mid buff, High buff); Death Blossom (Mid buff); Knights of Round (Mid buff, High buff); Imperator (Mid buff); Requiescat (Mid buff); Sanguine Blade (Mid buff); Seraph Blade (Mid buff); Red Lotus Blade (Mid buff); Mercy Stroke (Mid buff, High buff); Ruthless Stroke (Mid buff, High buff); Black Halo (Mid buff); Aeolian Edge (Mid buff); BLU: Expiacion (Mid buff); Requiescat (Mid buff); Imperator (Mid buff); Savage Blade (Mid buff); Sanguine Blade (Mid buff, Ice Brand enabled); Red Lotus Blade (Mid buff, Ice Brand enabled). Vanar's copy is rank 20 Path B, so the sims overvalue it: rank 25 has 5 more Attack, 2% more Weapon skill damage and Double Attack, and STR and VIT +5 ([rank-augments.md](rank-augments.md#nyame-mail)).

### Qaaxo Harness

*Qaaxo Harness. BLU, not RDM.*

- Its augments are Delve II mezzotint Path B at rank 15, the path's maximum: Accuracy+15, STR+7 and Physical damage taken -3%.
- Accuracy reaches 15 and PDT reaches -3% only at rank 15 ([bg-wiki](https://www.bg-wiki.com/ffxi/Delve_II_Rewards/Mezzotinting)).

### Rawhide Vest

*Rawhide Vest. BLU, not RDM.*

- Its augments are Nolan Path D at rank 15, the path's maximum. That brings Triple Attack to 4% in total ([bg-wiki](https://www.bg-wiki.com/ffxi/Nolan)).

### Telchine Chas.

*Telchine Chasuble.*

- "Regen" effect duration +12 means 12 seconds (4 ticks) on Regen I-IV. It is added to the base before duration multipliers.
- Regen potency +3 adds 3 HP per tick to the Regen spells you cast ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Regen_Spell)).
- Regen potency +3 (the maximum) and Enh. Mag. eff. dur. +10 both come from the Dusk-stone slot, so one Telchine Chasuble can't carry both.
- This copy is the Regen-potency one. It has no Leaf or Snow augments and lacks the augmented 10% enhancing duration ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Alluvion_Skirmish_Armor)).

### Tidal Talisman

*Tidal Talisman.*

- It has one charge and an 8-second cast. It must be equipped for 30 seconds before use and recharges in 72,000 seconds (20 hours).
- Party members are only teleported to a destination they have already visited ([bg-wiki](https://www.bg-wiki.com/ffxi/Tidal_Talisman)).

### Vatic Byrnie

*Vatic Byrnie. Not RDM or BLU.*

- RDM and BLU can't equip it. Only WAR, PLD, DRK, BST, SAM, NIN and DRG can ([bg-wiki](https://www.bg-wiki.com/ffxi/Vatic_Byrnie)).

### Viti. Tabard +4

*Vitiation Tabard +4. RDM only.*

- The Chainspell augment adds 20 seconds to Chainspell's 60-second duration.
- It is a bonus to the job ability, so it goes in the Chainspell job-ability set ([bg-wiki](https://www.bg-wiki.com/ffxi/Viti._Tabard_%2B4)).

### Volte Jupon

*Volte Jupon.*

- With RDM or BLU as main job, Treasure Hunter from all sources caps at +4 (+8 with THF main).
- TH goes on as a debuff with an aggressive action taken while it is worn. The gear can come off after that first action ([bg-wiki](https://www.bg-wiki.com/ffxi/Treasure_Hunter)).

No notes beyond the help text: Akitu Shirt, Alliance Shirt, Chocobo Suit, Esthete's Coat, Ziamet Peti.

## Hands

### Adhemar Wristbands

*Adhemar Wristbands. BLU, not RDM.*

- Its augments are Nolan Path B. Nolan gear ranks up to 15, and these are Path B's full values, so this copy is at rank 15.
- Path A would give AGI+10, DEX+10 and Accuracy+15 instead, and Path D Accuracy+15, Attack+15 and Subtle Blow+7. ([bg-wiki](https://www.bg-wiki.com/ffxi/Nolan))
- Set bonus: Adhemar, see [Adhemar set](#adhemar-set). Only +1 pieces count, so these NQ wristbands never do ([bg-wiki](https://www.bg-wiki.com/ffxi/Adhemar_Attire_Set)).

### Asn. Armlets +2

*Assassin's Armlets +2. THF only.*

- This copy lacks the optional Magian augment, Enhances "Perfect Dodge" (Perfect Dodge lasts 10 seconds longer), so it is plain Treasure Hunter +2. ([bg-wiki](https://www.bg-wiki.com/ffxi/Asn._Armlets_%2B2))

### Assim. Bazu. +3

*Assimilator's Bazubands +3. BLU only.*

- Set bonus: Assimilator's, see [Assimilator's set](#assimilators-set).

### Atro. Gloves +4

*Atrophy Gloves +4. RDM only.*

- Its Enhancing magic duration +20% is native, so it adds into the native duration total.
- Telchine's "Enh. Mag. eff. dur." augments go into the separate augmented multiplier instead. ([bg-wiki](https://www.bg-wiki.com/ffxi/Lethargy_Armor_Set))
- Set bonus: Atrophy, see [Atrophy set](#atrophy-set).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Savage Blade (Mid buff, High buff); Knights of Round (High buff); Imperator (High buff); Black Halo (High buff).

### Bunzi's Gloves

*Bunzi's Gloves. RDM, not BLU.*

- Vanar's copy is rank 0 (player, 2026-10-02): no augments, only the base stats in its help text. Vanar's augmented Odyssey pieces export with `'Path: X'`; this one exports with no augments at all.
- Its only path, Odyssey Path A, adds Attack, Magic Damage and Magic burst damage II from rank 1, Accuracy and Magic Accuracy from rank 16, and MND from rank 21. For the values at each rank, see [rank-augments.md](rank-augments.md#bunzis-gloves). ([bg-wiki](https://www.bg-wiki.com/ffxi/Bunzi%27s_Gloves))
- Its Magic burst damage +8 is Magic Burst Damage I, which shares the 40% cap with all other MBD I gear.
- Magic burst damage II sits outside that cap and has no known cap of its own. On these gloves only the path augment adds it, so Vanar's rank-0 copy has none. ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Burst))
- "Double Attack"+8% is a base stat, so Vanar's rank-0 copy has it in full. It is the only multi-attack on his Bunzi's armor, since the Hat's Quadruple Attack is an augment from rank 21. ([bg-wiki](https://www.bg-wiki.com/ffxi/Bunzi%27s_Gloves))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Requiescat (Mid buff); Casting (Magic Burst). Vanar's copy is rank 0, without the rank 30 augment (Attack and Magic Damage +30, Magic burst damage II +6, Accuracy and Magic Accuracy +15, MND+5), so the sims overvalue it ([rank-augments.md](rank-augments.md#bunzis-gloves)).

### Chironic Gloves

*Chironic Gloves. RDM, not BLU.*

- Vanar owns three copies, and Chironic Gloves are not Rare. ([ffxi-mechanics.md](ffxi-mechanics.md#gear-and-gearswap))
- Copy `'"Fast Cast"+4','Mag. Acc.+9'`:
  - This is a Fast Cast roll. Chironic's Fast Cast augment rolls +1 to +6 (+7 with Fern stones), so this copy is 3 short of the best. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Escha_Rewards/Arcane_Glyptics_Inscription))
  - It gives Fast Cast 4% in precast. It shortens recast by only 2%, and only if it is also worn at midcast. ([ffxi-mechanics.md](ffxi-mechanics.md#recast))
- Copy `'Mag. Acc.+20 "Mag.Atk.Bns."+20','"Conserve MP"+1','CHR+7','"Mag.Atk.Bns."+9'`:
  - This is a nuke and magic accuracy roll: Magic Accuracy 35 and MAB 44 in total with the native 15 and 15.
  - For RDM nukes and enfeebles, Leth. Ganth. +3 has more of each (Macc 62, MAB 52), plus Magic Damage +32 and DT -11%.
  - This copy keeps only the native Enhancing magic skill +15 and Spell interruption rate down 20%. ([bg-wiki](https://www.bg-wiki.com/ffxi/Chironic_Attire_Set))
- Copy with no augments:
  - Both augmented copies have every native stat this copy has, Spell interruption rate down 20% included, plus their augments, so either one beats it for every purpose. ([bg-wiki](https://www.bg-wiki.com/ffxi/Chironic_Gloves))
  - It has no augments to name it by, so a set asking for plain "Chironic Gloves" can get either augmented copy instead. ([ffxi-mechanics.md](ffxi-mechanics.md#gear-and-gearswap))

### Gazu Bracelets

*Gazu Bracelets.*

- Its "Unity Ranking" Accuracy is +10 to +15, set by your Unity's weekly rank (a higher rank gives more).
- Its total Accuracy is therefore 40 to 45, still with Attack -18. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Unity_Concord))
- On BLU, Assim. Bazu. +3 beats it on every stat: Accuracy 48 against 40 to 45, no Attack penalty, the same Haste+5%, more of every attribute, Evasion and Magic Evasion, and Damage taken -6% on top.
- On RDM, nothing Vanar owns beats it outright. (Help text of both pieces.)

### Gleti's Gauntlets

*Gleti's Gauntlets. BLU, not RDM.*

- Vanar's copy is rank 0 (player, 2026-10-02): no augments, only the base stats in its help text.
- Its only path, Odyssey Path A, adds Attack and Store TP from rank 1, Accuracy and Magic Accuracy from rank 16, and DEX from rank 21. For the values at each rank, see [rank-augments.md](rank-augments.md#gletis-gauntlets). ([bg-wiki](https://www.bg-wiki.com/ffxi/Gleti%27s_Gauntlets))
- Physical damage limit +7% raises only the cap on pDIF, not pDIF itself. It adds damage only once attack is high enough to reach the cap. bg-wiki's Damage Limit+ page says so and lists these gauntlets.
- It also applies to physical and hybrid weapon skills. ([bg-wiki](https://www.bg-wiki.com/ffxi/Damage_Limit%2B))
- The help text's last line, Damage taken-8%, comes after the `Pet:` lines and is the pet's: bg-wiki's set page lists it with the hands' pet stats. Don't count it toward Vanar's DT. His only damage reduction from these gauntlets is Physical damage taken -7%. ([bg-wiki](https://www.bg-wiki.com/ffxi/Gleti%27s_Armor_Set))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): BLU: Expiacion (High buff); Chant du Cygne (High buff). Vanar's copy is rank 0, without the rank 30 augment (Attack+30, Store TP +8, Accuracy and Magic Accuracy +15, DEX+5), so the sims overvalue it ([rank-augments.md](rank-augments.md#gletis-gauntlets)).

### Hashi. Bazu. +3

*Hashishin Bazubands +3. BLU only.*

- Blue magic recast delay -16% affects recast only. It never shortens casting time.
- bg-wiki likens it to Fast Cast worn when the spell goes off, so it counts only in the midcast set.
- It applies only to blue magic, not to subjob spells. ([bg-wiki](https://www.bg-wiki.com/ffxi/Hashi._Bazu._%2B3))
- Set bonus: Hashishin, see [Hashishin set](#hashishin-set).

### Herculean Gloves

*Herculean Gloves. BLU, not RDM.*

- This is a critical weapon skill roll.
- Crit. hit damage +4% fills the single special-stat slot (cap +4%, +5% with Fern stones), so this copy can't also have Weapon skill damage (+1 to +4%, +5% with Fern stones).
- STR+9 is 1 under the normal cap of 10 (15 with Taupe stones).
- Accuracy+18 Attack+18 is the combined Accuracy and Attack augment, which caps at 25. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Escha_Rewards/Arcane_Glyptics_Inscription))

### Jhakri Cuffs +2

*Jhakri Cuffs +2.*

- Set bonus: Jhakri, see [Jhakri set](#jhakri-set).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Sanguine Blade (Mid buff); Red Lotus Blade (Mid buff); Aeolian Edge (Mid buff); BLU: Sanguine Blade (Mid buff, Ice Brand enabled); Red Lotus Blade (Mid buff, Ice Brand enabled).

### Leth. Ganth. +3

*Lethargy Gantherots +3. RDM only.*

- Saboteur +14 raises Saboteur's bonus to enfeebling potency and base duration from +100% to +114% on normal monsters, and from +25% to +39% on NMs.
- The gloves must be on at midcast. They don't need to be on when Saboteur is used.
- Saboteur doesn't affect the dMND or dINT part of a spell's potency, for example on Distract or Frazzle. (bg-wiki: [Saboteur](https://www.bg-wiki.com/ffxi/Saboteur), [Leth. Ganth. +3](https://www.bg-wiki.com/ffxi/Leth._Ganth._%2B3))
- Magic Damage +32 is added straight to a nuke's base damage (D), before any multiplier, MAB included.
- So it is worth the most on spells with low base damage, such as low-tier nukes and helices. ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Damage_%28Statistic%29))
- Set bonus: Lethargy, see [Lethargy set](#lethargy-set).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Seraph Blade (Mid buff); Casting (Free Nuke).

### Luh. Bazubands +1

*Luhlaza Bazubands +1. BLU only.*

- The augment adds 10 seconds to Azure Lore, taking it from 30 to 40 seconds.
- It belongs in the Azure Lore job ability set. (bg-wiki: [Azure Lore](https://www.bg-wiki.com/ffxi/Azure_Lore), [Luh. Bazubands +1](https://www.bg-wiki.com/ffxi/Luh._Bazubands_%2B1))

### Merlinic Dastanas

*Merlinic Dastanas. RDM, not BLU.*

- The help text's "Magic Atk. Bonus"+20 and Enmity+5 come after "Avatar:", so they are Avatar stats and give the wearer nothing.
- This copy's only MAB and Magic Accuracy are the augment's +18 each. ([bg-wiki](https://www.bg-wiki.com/ffxi/Merlinic_Attire_Set))
- This is a melee and nuke hybrid roll.
- Quadruple Attack +2 is a Dark Matter-only stat (QA +1 to +3).
- It lacks Merlinic's caster rolls: Magic burst damage (up to +10%, +11% with Fern stones) and Fast Cast (up to +6, +7 with Fern stones).
- For RDM nukes, Leth. Ganth. +3 (Macc 62, MAB 52) is far ahead. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Escha_Rewards/Arcane_Glyptics_Inscription))
- wsdist: its only entry is an Occult Acumen +11 roll, with none of Vanar's augments: STR+12, DEX+6, Quadruple Attack +2, Accuracy and Attack +11, and Magic Accuracy and Magic Atk. Bonus +18. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), line 1086)

### MG Gauntlets +1

*MG Gauntlets +1.*

- Only an Elvaan male can wear it (bg-wiki's race list; Windower races=8). The help text doesn't say so.
- Leth. Ganth. +3 (RDM) and Hashi. Bazu. +3 (BLU) beat it on Accuracy, Attack, Magic Accuracy, MAB and DT.
- It is ahead only on Haste (+4% vs +3%), ranged stats, STR, AGI and MP. ([bg-wiki](https://www.bg-wiki.com/ffxi/MG_Gauntlets_%2B1))

### Nyame Gauntlets

*Nyame Gauntlets.*

- Vanar's copy is rank 0 (player, 2026-10-02): no path and no augments, only the base stats in its help text. This differs from Vanar's Nyame Helm, Mail, Flanchard and Sollerets, which are Path B at rank 20.
- On these gauntlets, Path B adds Attack, Ranged Attack and Weapon skill damage from rank 1, Double Attack from rank 16 and VIT from rank 21. For the values at each rank on all four paths, see [rank-augments.md](rank-augments.md#nyame-gauntlets). ([bg-wiki](https://www.bg-wiki.com/ffxi/Nyame_Gauntlets))
- Its Magic burst damage +5 is Magic Burst Damage I, which shares the 40% cap. ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Burst))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Death Blossom (Mid buff); Knights of Round (Mid buff); Imperator (Mid buff); Mercy Stroke (Mid buff); Ruthless Stroke (Mid buff); Black Halo (Mid buff); BLU: Expiacion (Mid buff); Imperator (Mid buff, High buff); Savage Blade (Mid buff, High buff). Vanar's copy is rank 0, without the rank 25 Path B augment (Attack+30, Weapon skill damage +10%, Double Attack +4%, VIT+10), so the sims overvalue it ([rank-augments.md](rank-augments.md#nyame-gauntlets)).

### Odyssean Gauntlets

*Odyssean Gauntlets. WAR, PLD and DRK only.*

- RDM and BLU can't wear it, and this copy is unaugmented, so it does nothing for Vanar. ([bg-wiki](https://www.bg-wiki.com/ffxi/Odyssean_Gauntlets))

### Pinga Mittens

*Pinga Mittens. BLU, not RDM.*

- It is Superior Level 3 (Su3) gear: BLU must have earned its 500-job-point gift to equip it. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Superior_Equipment))

### Psycloth Manillas

*Psycloth Manillas.*

- Its augments are Nolan Path A at full rank (rank 15): MP+50, INT+7 and Conserve MP+6.
- Path B would give Mag. Acc.+10, Spell interruption rate -15% and MND+7 instead. ([bg-wiki](https://www.bg-wiki.com/ffxi/Nolan))

### Pursuer's Cuffs

*Pursuer's Cuffs. THF, RNG, NIN and COR only.*

- This copy has no Nolan path augment. ([bg-wiki](https://www.bg-wiki.com/ffxi/Pursuer%27s_Cuffs))

### Serpentes Cuffs

*Serpentes Cuffs.*

- Day and night are Vana'diel time: Regen from 6:00 to 18:00, Refresh from 18:00 to 6:00. ([bg-wiki](https://www.bg-wiki.com/ffxi/Days_of_the_Week))
- Vanar also owns Serpentes Sabots, which work the other way round: Refresh by day, Regen by night.
- Worn together, the two give both Regen and Refresh at all hours. ([bg-wiki](https://www.bg-wiki.com/ffxi/Serpentes_Sabots))
- Set bonus: Serpentes, see [Serpentes set](#serpentes-set).

### Telchine Gloves

*Telchine Gloves.*

- Vanar owns two copies. Telchine Gloves are not Rare and the copies share a name, so each set must name its copy by augments. ([bg-wiki](https://www.bg-wiki.com/ffxi/Telchine_Gloves))
- Each Telchine piece holds one Snow, one Leaf and one Dusk augment. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Alluvion_Skirmish_Armor))
- Its "Cure" potency +10% is plain Cure potency, which adds with other Cure potency gear toward a 50% cap. "Cure potency II" gear has its own 30% cap on top of that. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Cure_Spell))
- Copy `'"Regen" potency+3'`:
  - "Regen" potency+3 is the Dusk-stone maximum (+1 to +3). ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Alluvion_Skirmish_Armor))
  - It adds HP to each Regen tick and is read when the spell lands, so it goes in midcast Regen sets. ([ffxi-mechanics.md](ffxi-mechanics.md#regen))
  - Regen potency and Enhancing magic duration are both Dusk augments, so this copy can never also have duration.
  - Its Leaf and Snow slots are empty. Leaf could add Haste up to +3%, Fast Cast up to +5% or Cure potency up to +8%. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Alluvion_Skirmish_Armor))
- Copy `'Haste+3','Enh. Mag. eff. dur. +10'`:
  - Both augments are at their maximums: Leaf Haste +1 to +3% and Dusk Enhancing magic duration +1 to +10%. The Snow slot is empty.
  - With the Dusk slot used for duration, this copy can't have Regen potency. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Alluvion_Skirmish_Armor))
  - The +10% duration is an augment, so it multiplies separately from native duration such as Atro. Gloves +4's 20%. ([bg-wiki](https://www.bg-wiki.com/ffxi/Lethargy_Armor_Set))
  - Its gear haste is 6% in total (3% native, 3% augment), which shortens recast when worn at midcast. ([ffxi-mechanics.md](ffxi-mechanics.md#recast))

### Vanya Cuffs

*Vanya Cuffs. RDM, not BLU.*

- Its augments are Nolan Path B at full rank (rank 15). ([bg-wiki](https://www.bg-wiki.com/ffxi/Nolan))
- In the Cure precast set, only its Cure spellcasting time -7% matters.
- Its Healing magic skill +20 raises the amount cured (cure power comes from MND, VIT and healing skill), but only if worn at midcast. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Cure_Spell))

### Viti. Gloves +4

*Vitiation Gloves +4. RDM only.*

- The relic augment adds 3 seconds of enhancing magic duration per Enhancing Magic Duration merit level, up to +15 seconds. Vanar has 5 levels **(player, 2026-10-02, changed)**, so it adds the full 15 seconds (5 × 3), on top of the merit's own 30 (5 × 6).
- The seconds go into the base before every multiplier (Composure, native %, augmented %).
- They count only if the gloves are on at midcast. (bg-wiki: [Viti. Gloves +4](https://www.bg-wiki.com/ffxi/Viti._Gloves_%2B4), [Lethargy Armor Set](https://www.bg-wiki.com/ffxi/Lethargy_Armor_Set))
- Gain spells reach their +25 cap at 500 enhancing skill: floor((skill - 300) / 10) + 5.
- Vanar's RDM has 481 enhancing skill without gear (404 + 36 gifts + 16 merits + 25 Master Levels; [Vanar's merits and skills](#vanars-merits-and-skills)). So 19 skill from gear reaches the cap, and these gloves' Enhancing magic skill +25 does it alone (481 + 25 = 506).
- bg-wiki lists these gloves apart from that formula, in a "Gain Stat +" table at +30. That implies their bonus comes on top of the skill cap.
- bg-wiki doesn't say whether the +30 is flat stat points or a percentage. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Gain_Spell))

### Ziamet Bazubands

*Ziamet Bazubands.*

- bg-wiki lists no hidden effects. DEF 1 is all it has, so it is only for appearance. ([bg-wiki](https://www.bg-wiki.com/ffxi/Ziamet_Bazubands))

No notes beyond the help text: Councilor's Cuffs.

## Rings

### Aquasoul Ring

*Aquasoul Ring.*

- Its "Resist Virus" is only +1% resistance to Disease and Plague, so in practice the ring is just MND+7 with DEX-3. ([bg-wiki](https://www.bg-wiki.com/ffxi/Resist_Virus))

### Ayanmo Ring

*Ayanmo Ring.*

- Set bonus: Ayanmo, see [Ayanmo set](#ayanmo-set). Vanar owns no Ayanmo armor, so it never applies. (bg-wiki: [Ayanmo Ring](https://www.bg-wiki.com/ffxi/Ayanmo_Ring), [Ambuscade Rewards](https://www.bg-wiki.com/ffxi/Category:Ambuscade_Rewards))

### Caliber Ring

*Caliber Ring.*

- It has 3 charges, can't be recharged and has a 15-minute reuse.
- After equipping it, wait 5 s before using it. The use is a 1 s cast. ([bg-wiki](https://www.bg-wiki.com/ffxi/Caliber_Ring))
- Its Dedication buff can't be dispelled and doesn't wear off on death or job change.
- The buff ends after 720 min, after 30,000 bonus EXP, or when another ring that gives Dedication or Commitment is used. So Echad Ring, Novennial Ring or the capacity ring Trizek Ring overwrites it. (bg-wiki: [Experience Points](https://www.bg-wiki.com/ffxi/Experience_Points), [Job Points](https://www.bg-wiki.com/ffxi/Job_Points))
- EXP bonus rings don't raise Exemplar Points (Master Levels). bg-wiki says only Corsair's Roll does.
- They do raise Limit Points. (bg-wiki: [Master Levels](https://www.bg-wiki.com/ffxi/Master_Levels), [Experience Points](https://www.bg-wiki.com/ffxi/Experience_Points))

### Dark Ring

*Dark Ring.*

- Vanar owns two copies with different augments. Dark Ring isn't Rare, so name each copy by its augments in sets.
- Both copies' augments are random Abyssea - Konschtat Gold Pyxis rolls. PDT rolls 1 to 6%.
- Copy `'Phys. dmg. taken -3%','Breath dmg. taken -4%'`: Breath damage taken also rolls 1 to 6%, so this copy's -3% and -4% are mid-range.
- Copy `'Phys. dmg. taken -3%','Spell interruption rate down -3%'`: Spell interruption rate down rolls 1 to 5%. ([bg-wiki](https://www.bg-wiki.com/ffxi/Dark_Ring))
- The PDT adds with DT toward the -50% physical cap. It does nothing against magic or breath damage.
- Copy `'Phys. dmg. taken -3%','Breath dmg. taken -4%'`: The Breath -4% adds with DT toward the -50% breath cap. ([bg-wiki](https://www.bg-wiki.com/ffxi/Damage_Taken))

### Dim. Ring (Dem)

*Dimensional Ring (Dem).*

- Reuse is 10 minutes.
- It must be equipped 8 s before it can be used. The teleport is then an 8 s cast. ([bg-wiki](https://www.bg-wiki.com/ffxi/Dim._Ring_%28Dem%29))

### Dim. Ring (Holla)

*Dimensional Ring (Holla).*

- Reuse is 10 minutes.
- It must be equipped 8 s before it can be used. The teleport is then an 8 s cast. ([bg-wiki](https://www.bg-wiki.com/ffxi/Dim._Ring_%28Holla%29))

### Dim. Ring (Mea)

*Dimensional Ring (Mea).*

- Reuse is 10 minutes.
- It must be equipped 8 s before it can be used. The teleport is then an 8 s cast. ([bg-wiki](https://www.bg-wiki.com/ffxi/Dim._Ring_%28Mea%29))

### Echad Ring

*Echad Ring.*

- It has unlimited charges and a 2-hour reuse.
- After equipping it, wait 5 s before using it. The use is a 1 s cast. (bg-wiki: [Experience Points](https://www.bg-wiki.com/ffxi/Experience_Points), [Echad Ring](https://www.bg-wiki.com/ffxi/Echad_Ring))
- Its Dedication buff can't be dispelled and doesn't wear off on death or job change.
- The buff ends after 720 min, after 30,000 bonus EXP, or when another ring that gives Dedication or Commitment is used. So Caliber Ring, Novennial Ring or the capacity ring Trizek Ring overwrites it. (bg-wiki: [Experience Points](https://www.bg-wiki.com/ffxi/Experience_Points), [Job Points](https://www.bg-wiki.com/ffxi/Job_Points))
- EXP bonus rings don't raise Exemplar Points (Master Levels). bg-wiki says only Corsair's Roll does.
- They do raise Limit Points. (bg-wiki: [Master Levels](https://www.bg-wiki.com/ffxi/Master_Levels), [Experience Points](https://www.bg-wiki.com/ffxi/Experience_Points))

### Emporox's Ring

*Emporox's Ring.*

- Emporox's Gift lasts 24 Earth hours.
- While you are at the merit point cap, it gives 1 potpourri for every 10,000 limit points, with no limit per charge.
- It has 3 charges, can't be recharged and has a 2-hour reuse.
- After equipping it, wait 5 s before using it. The use is a 1 s cast. ([bg-wiki](https://www.bg-wiki.com/ffxi/Emporox%27s_Ring))

### Epaminondas's Ring

*Epaminondas's Ring.*

- Its WSD +5% is gear WSD. On a physical weapon skill it raises only the first hit; on a magical one it raises all the damage.
- So it is worth most on magical weapon skills: Sanguine Blade, Seraph Blade and Red Lotus Blade. ([bg-wiki](https://www.bg-wiki.com/ffxi/Weapon_Skill_Damage))
- Worn only for the weapon skill, its Store TP -10 just trims the TP the weapon skill itself returns.
- Store TP applies to physical weapon skills, which return full TP for the first hit and 10 TP per later hit.
- Keep it out of engaged sets. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Weapon_Skills))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Savage Blade (Mid buff, High buff); Death Blossom (Mid buff, High buff); Knights of Round (Mid buff, High buff); Imperator (Mid buff, High buff); Sanguine Blade (Mid buff); Seraph Blade (Mid buff); Red Lotus Blade (Mid buff); Mercy Stroke (Mid buff, High buff); Ruthless Stroke (Mid buff, High buff); Black Halo (Mid buff, High buff); Aeolian Edge (Mid buff); BLU: Expiacion (Mid buff, High buff); Imperator (Mid buff, High buff); Savage Blade (Mid buff, High buff); Sanguine Blade (Mid buff, Ice Brand enabled); Red Lotus Blade (Mid buff, Ice Brand enabled).

### Epona's Ring

*Epona's Ring. BLU, not RDM.*

- RDM can't equip it, so of Vanar's two jobs only BLU can use it. ([bg-wiki](https://www.bg-wiki.com/ffxi/Epona%27s_Ring))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): BLU: Chant du Cygne (High buff); Tizona + Thibron AM3 TP (-50% DT, -25% DT); Caliburnus + Thibron AM1 TP (-50% DT, -25% DT).

### Fencer's Ring

*Fencer's Ring. RDM only.*

- The latent needs HP at or below 75% and TP at or below 1000 at the same time. ([bg-wiki](https://www.bg-wiki.com/ffxi/Fencer%27s_Ring))
- With the latent on and an Enspell up, it adds +5 Enspell damage with any weapon type, on main and off hand alike.
- Tier II Enspells only hit the first main-hand swing of a round.
- Composure triples the +5 to +15. (bg-wiki: [Enspell](https://www.bg-wiki.com/ffxi/Category:Enspell), [Composure](https://www.bg-wiki.com/ffxi/Composure))
- It only works while worn during attack rounds, so it does nothing in a casting set. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Enspell))
- The player's rule against Enspell gear that has to stay on while meleeing rules it out. ([ffxi-mechanics.md](ffxi-mechanics.md#player-rules-for-these-jobs))

### Hercules' Ring

*Hercules' Ring. WAR and PLD only.*

- Neither RDM nor BLU can equip it.
- The latent turns on at HP 50% or below and gives Refresh 1 MP/tick and Regen 3 HP/tick. ([bg-wiki](https://www.bg-wiki.com/ffxi/Hercules%27_Ring))

### Jelly Ring

*Jelly Ring.*

- It has a hidden Breath damage taken +5%.
- So it cuts only physical damage, and raises both magic and breath damage by 5%. ([bg-wiki](https://www.bg-wiki.com/ffxi/Jelly_Ring))

### Jhakri Ring

*Jhakri Ring.*

- Set bonus: Jhakri, see [Jhakri set](#jhakri-set).
- Its Magic burst damage +2 is the first tier (Magic Burst Damage I), which shares the 40% gear cap. It is not Magic Burst Damage II.
- It only helps when the nuke bursts. ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Burst))

### Jubilee Ring

*Jubilee Ring.*

- The skill-up bonus appears to double each skill gain, and seems to cap at +1.0 per skill-up. bg-wiki hedges both.
- It covers combat and magic skills, automaton skills included, but not crafting or fishing. ([bg-wiki](https://www.bg-wiki.com/ffxi/Jubilee_Ring))

### Karieyh Ring

*Karieyh Ring.*

- Regain is TP per 3-second tick, so Regain+5 gives 5 TP a tick (100 TP a minute).
- bg-wiki lists no engaged or weapon-drawn condition for this ring, so it builds TP while idle.
- In a weapon skill set only its WSD+3% and WS Accuracy+5 matter.
- Gear WSD applies to the first hit of a physical weapon skill, or to all of a magical one. (bg-wiki: [Regain](https://www.bg-wiki.com/ffxi/Regain_%28Status%29), [Weapon Skill Damage](https://www.bg-wiki.com/ffxi/Weapon_Skill_Damage))
- The RahvinGS library's comment for it says WSD 5, but the ring has WSD+3%.
- Even Karieyh Ring +1 has only +4%. ([bg-wiki](https://www.bg-wiki.com/ffxi/Karieyh_Ring_%2B1))

### Lehko's Ring

*Lehko Habhoka's Ring.*

- Its Critical hit rate +10% helps melee swings.
- A weapon skill can only crit if its text says crit chance varies with TP, as Chant du Cygne, Evisceration and Vorpal Blade do.
- Requiescat ("Attack power varies with TP") can't crit. There the ring gives only DEX+10 and Store TP+10. (bg-wiki: [Critical Hit Rate](https://www.bg-wiki.com/ffxi/Critical_Hit_Rate), [Requiescat](https://www.bg-wiki.com/ffxi/Requiescat))

### Levia. Ring

*Leviathan Ring.*

- The private-use glyph (U+E005) in the help text is the Water element icon, so the second stat is Water resistance +15.
- bg-wiki shows it as the Water icon, and FFXIclopedia lists it as Water resistance +15. ([bg-wiki](https://www.bg-wiki.com/ffxi/Levia._Ring), [FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Leviathan_Ring))

### Murky Ring

*Murky Ring.*

- The help text's Accuracy, Ranged Accuracy and Magic Accuracy +15 sit under "Pet:". The wearer's own accuracy comes only from Path A.
- Path A ranks 1 to 15 give Accuracy, Ranged Accuracy and Magic Accuracy +1 per rank (+15 at rank 15).
- Ranks 16 to 25 add Evasion and Magic Evasion, up to +10.
- Ranks 26 to 30 add Critical hit rate, up to +5%.
- The export doesn't show this copy's rank. For each rank's values, see [rank-augments.md](rank-augments.md#murky-ring).
- bg-wiki gives its exact DT as 25/256, about 9.8%, a little under the listed 10%.
- That matters for a set built to exactly the 50% DT cap. ([bg-wiki](https://www.bg-wiki.com/ffxi/Murky_Ring))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Chant du Cygne (Mid buff); Evisceration (Mid buff, High buff); BLU: Chant du Cygne (Mid buff).

### Naji's Loop

*Naji's Loop.*

- Its Cure potency +1% counts toward the 50% Cure potency cap.
- Its Cure potency II +1% counts toward a separate 30% cap, which applies regardless of the first. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Cure_Spell))
- In a midcast set its Fast Cast +1% only affects recast, which drops by floor(total Fast Cast / 2)%.
- So it cuts recast by 1% only when it makes the set's total Fast Cast even, and by nothing otherwise. ([bg-wiki](https://www.bg-wiki.com/ffxi/Spell_Recast))

### Novennial Ring

*Novennial Ring.*

- Enchantment: 10 charges, usable 15 s after equipping, 3 s cast, 60-minute reuse. ([bg-wiki](https://www.bg-wiki.com/ffxi/Novennial_Ring))
- The EXP bonus is a buff. It stays on after the ring comes off, survives death and job changes, and can't be dispelled.
- It ends after 720 min or 9,000 EXP, or when another Dedication or Commitment ring is used. ([bg-wiki](https://www.bg-wiki.com/ffxi/Experience_Points))
- Vanar's Echad Ring beats it: +150% with a 30,000 cap, unlimited charges and a 120-minute reuse, against +100% with a 9,000 cap.
- Vanar's Caliber Ring (+150%, 30,000 cap) also beats it while Caliber has charges left. Caliber holds 3 and can't be recharged. (bg-wiki: [Experience Points](https://www.bg-wiki.com/ffxi/Experience_Points), [Caliber Ring](https://www.bg-wiki.com/ffxi/Caliber_Ring))

### Omega Ring

*Omega Ring.*

- Vanar's two Stikini Rings fill both ring slots with more magic accuracy (+8 plus +5 to every magic skill, against +3) and more MND.
- Against them, Omega adds only INT and CHR +3. Bringing it in just for that INT is what the player's rule rules out: no dedicated INT or MND pieces (player, 2026-10-02). ([bg-wiki](https://www.bg-wiki.com/ffxi/Stikini_Ring), [ffxi-mechanics.md](ffxi-mechanics.md#player-rules-for-these-jobs))

### Perception Ring

*Perception Ring.*

- Stikini Ring strictly beats it: MND+5 against +2, Magic Accuracy+8 against +6, plus All magic skills +5.
- Vanar owns two Stikinis, enough for both ring slots. ([bg-wiki](https://www.bg-wiki.com/ffxi/Stikini_Ring))

### Prolix Ring

*Prolix Ring.*

- "Enhances Fast Cast" means Fast Cast +2%. ([bg-wiki](https://www.bg-wiki.com/ffxi/Prolix_Ring))
- In a midcast set that only shortens recast, by 1%: recast drops by floor(Fast Cast / 2)%. ([bg-wiki](https://www.bg-wiki.com/ffxi/Spell_Recast))

### Rajas Ring

*Rajas Ring.*

- STR and DEX start at +2 at level 30 and rise by 1 every 15 levels.
- That makes them +5 from level 75, so +5 at 99. ([bg-wiki](https://www.bg-wiki.com/ffxi/Rajas_Ring))

### Resonance Ring

*Resonance Ring.*

- Magic critical hit rate only works on blue, divine and elemental magic.
- A magic crit adds +10 MAB to that cast. Without magic crit damage gear, +5% is worth about +0.5 MAB on average. ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Critical_Hit))

### Stikini Ring

*Stikini Ring.*

- Vanar's two unaugmented copies are both in the same bag (wardrobe) in both 2026-10-01 exports.
- If one fails to equip, pinning them with `{ bag = "wardrobe" }` and `{ bag = "wardrobe2" }` only works after one copy is moved to wardrobe 2.
- Until then, swap them as a pair. ([export](../data/export/Vanar%202026-10-01%2022-41-03.lua))

### Tavnazian Ring

*Tavnazian Ring.*

- Enchantment: 1 charge, usable 30 s after equipping, 8 s cast, 24-hour reuse.
- It lands at (I-8) on the main level of Tavnazian Safehold. ([bg-wiki](https://www.bg-wiki.com/ffxi/Tavnazian_Ring))

### Trizek Ring

*Trizek Ring.*

- Enchantment: 1 charge, usable 5 s after equipping, 1 s cast, 2-hour reuse. ([bg-wiki](https://www.bg-wiki.com/ffxi/Trizek_Ring))
- The CP bonus is a buff. It stays on after the ring comes off, survives death and job changes, and can't be dispelled.
- It ends after 720 min or 30,000 CP, or when another Dedication (EXP) or Commitment (CP) ring is used.
- So it never belongs in a gear set. ([bg-wiki](https://www.bg-wiki.com/ffxi/Job_Points))

### Warden's Ring

*Warden's Ring.*

- Physical damage taken and Damage taken add together in one term that bottoms out at 50%.
- So its -3% shares the 50% physical cap with DT gear, and does nothing once DT alone reaches it. ([bg-wiki](https://www.bg-wiki.com/ffxi/Damage_Taken))

### Warp Ring

*Warp Ring.*

- Enchantment: 1 charge, usable 8 s after equipping, 8 s cast, 10-minute reuse. ([bg-wiki](https://www.bg-wiki.com/ffxi/Warp_Ring))

No notes beyond the help text: Acumen Ring, Apate Ring, Corneus Ring, Enlivened Ring, Fortified Ring, Heed Ring, K'ayres Ring, Solemn Ring, Spiral Ring, Strendu Ring.

## Back

### Atheling Mantle

*Atheling Mantle.*

- For melee, Vanar's Double Attack Ambuscade capes beat it outright: Rosmerta's on BLU and Sucellos's on RDM. Each has Accuracy+30, Attack+20, Double Attack+10% and Damage taken-5%.
- Its own Attack+20 and Double Attack+3% add nothing those capes lack. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:JSE_Capes))

### Cheviot Cape

*Cheviot Cape.*

- Hidden effect: at night its Physical damage taken is -10% instead of -5%. FFXIclopedia lists the same night effect. ([bg-wiki](https://www.bg-wiki.com/ffxi/Cheviot_Cape))

### Cornflower Cape

*Cornflower Cape. BLU only.*

- Blue Magic skill +10 is the top of the Reive augment's 1-10 range, so the cape gives Blue magic skill +15 in all.
- MP+29 is close to the 30 cap.
- DEX+1 (out of 5) and Accuracy+3 (out of 7) are low rolls, but a Blue magic skill set doesn't need them. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:JSE_Capes))

### Fi Follet Cape +1

*Fi Follet Cape +1.*

- At max rank (15), Path A adds Fast Cast +10% and Spell interruption rate -5%.
- Fast Cast rises 1% per rank up to rank 5, then 1% every second rank.
- Spell interruption starts at -1% at rank 6 and reaches -5% at rank 14.
- //gs export doesn't show the rank, and Vanar's rank isn't recorded, since ranks change often; ask the player when a set decision turns on it. [rank-augments.md](rank-augments.md#fi-follet-cape-1) has every rank. ([bg-wiki](https://www.bg-wiki.com/ffxi/Fi_Follet_Cape_%2B1))
- Worn only at midcast, its Path A Fast Cast just shortens recast, by half its value rounded down. Casting time was already set at precast. ([bg-wiki](https://www.bg-wiki.com/ffxi/Spell_Recast))
- In precast, its Fast Cast beats Swith Cape's 3% from rank 4 up and ties at rank 3.
- That matters on BLU, whose fast-cast set stays under the 80% cap: Fast Cast 46 from gear plus at most 25% from BLU's trait.
- RDM's Stoneskin precast set reaches 84% with Swith Cape and 81% without it, so the back changes nothing there. ([bg-wiki](https://www.bg-wiki.com/ffxi/Swith_Cape))
- `Unity Ranking: MND+1～5` changes each week with the ranking of Vanar's Unity. A higher rank gives more MND. Don't count on +5. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Unity_Concord))

### Ghostfyre Cape

*Ghostfyre Cape. RDM only.*

- Enh. Mag. eff. dur. +20 is an augment, already at the top of its 10-20 range.
- As augmented duration, it multiplies separately from listed (native) duration. bg-wiki's example is Haste II on self under Composure with +46% listed duration: 180 s × 3 × 1.2 × 1.46 = 946 s.
- Against Sucellos's Cape's native +20%, it gives more whenever the set's native total is larger than its other augmented total. The gain is 0.2 × (native - other augmented) × base duration.
- Example: with 103% native and 40% other augmented duration, it gives 3.25× base against 3.12× for Sucellos's Cape. ([bg-wiki](https://www.bg-wiki.com/ffxi/Ghostfyre_Cape))
- This copy is below the augment maximum (10 each) on Enhancing magic skill (+5), Enfeebling magic skill (+8) and Magic Accuracy (+8). ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:JSE_Capes))
- Sword enhancement spell damage +5 only works while the cape is worn during melee rounds.
- On armor it applies to both hands and any weapon type, and Composure multiplies it.
- In a casting set it does nothing, and the player's rule excludes Enspell gear worn for melee. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Enspell))

### Izdubar Mantle

*Izdubar Mantle.*

- For nukes, the INT Ambuscade capes beat it outright: Sucellos's on RDM and Rosmerta's on BLU, with INT+20, Magic Accuracy+30, Magic Damage+20 and Magic Atk. Bonus+10.
- All it adds over them is MP+25 and Conserve MP+2. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:JSE_Capes))

### Mecisto. Mantle

*Mecistopins Mantle.*

- Its capacity point bonus (+48% on this copy, near the 50% maximum) only counts if the mantle is worn when the monster dies.
- Use `//gs disable back` to keep GearSwap from swapping it off. ([bg-wiki](https://www.bg-wiki.com/ffxi/Job_Points))
- Gear doesn't raise Exemplar points (Master Levels). bg-wiki names Corsair's Roll as the only way to boost them.
- On Vanar's mastered RDM the mantle adds capacity points but nothing toward Master Levels. ([bg-wiki](https://www.bg-wiki.com/ffxi/Master_Levels))

### Mending Cape

*Mending Cape. WHM only.*

- Its unnumbered Cursna bonus is +15. ([bg-wiki](https://www.bg-wiki.com/ffxi/Mending_Cape))

### Merciful Cape

*Merciful Cape.*

- Fi Follet Cape +1 beats it for Enhancing magic skill (+9 vs +5) and MP (+45 vs +25).
- For Dark magic skill, Perimede Cape's +7 is higher, but Perimede carries Quick Magic +4%, which the player avoids. ([bg-wiki](https://www.bg-wiki.com/ffxi/Fi_Follet_Cape_%2B1))

### Nexus Cape

*Nexus Cape.*

- It teleports you to the party leader.
- In most field zones you land where the leader stands.
- You land at a fixed spot instead in towns, in the zones bg-wiki marks (Adoulin's field zones among them), and in some zones when the leader is inside a battlefield.
- It can't take you into dungeon zones, and you must have entered the leader's zone before.
- It needs 30 s equipped before use, takes 8 s to cast and recharges in 20 hours. ([bg-wiki](https://www.bg-wiki.com/ffxi/Nexus_Cape))

### Ogapepo Cape

*Ogapepo Cape.*

- Quick Magic +2% (gear caps at 10%). A proc casts the spell instantly, with no casting time and no recast.
- The player avoids Quick Magic pieces. [ffxi-mechanics.md](ffxi-mechanics.md#quick-magic) also records, as unverified GearSwap advice, that an instant cast can land in precast gear. ([bg-wiki](https://www.bg-wiki.com/ffxi/Occasionally_Quickens_Spellcasting))
- For magic accuracy, Vanar's Ambuscade casting capes beat its +10 outright: Sucellos's MND and INT copies and Rosmerta's INT copy each have Magic Accuracy+30. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:JSE_Capes))

### Pahtli Cape

*Pahtli Cape.*

- Cure spellcasting time -8% cuts casting time, so it goes in `sets.Precast.Cure`. The engine wears that set for Cure, Cura and Curaga.
- bg-wiki's Cure page counts it with Fast Cast and Healing magic casting time under one 80% hard cap. The player holds that such cuts go past it ([ffxi-mechanics.md](ffxi-mechanics.md#does-anything-break-the-80-cap-disputed)). ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Cure_Spell))

### Perimede Cape

*Perimede Cape.*

- Quick Magic +4% (gear caps at 10%). A proc casts the spell instantly, with no casting time and no recast.
- The player names this cape as one to avoid ([ffxi-mechanics.md](ffxi-mechanics.md#quick-magic)). ([bg-wiki](https://www.bg-wiki.com/ffxi/Occasionally_Quickens_Spellcasting))
- Fi Follet Cape +1 beats it for Enhancing magic skill (+9 vs +7).
- Its Dark magic skill +7 is the highest on any back piece in Vanar's export. Merciful Cape has +5. ([bg-wiki](https://www.bg-wiki.com/ffxi/Fi_Follet_Cape_%2B1))

### Potentia Cape

*Potentia Cape.*

- It has only STR+6 and INT+6. Vanar's Ambuscade capes give far more of each (STR+30 on the WSD copies, INT+20 on the INT copies) plus accuracy, so it has no RDM or BLU use. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:JSE_Capes))

### Refraction Cape

*Refraction Cape.*

- For MND or INT work on RDM, Sucellos's MND and INT copies beat it outright: +20 of the stat against its +8, and Magic Accuracy+30 against its +3. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:JSE_Capes))

### Rosmerta's Cape

*Rosmerta's Cape. BLU only.*

- It isn't Rare, and Vanar owns four copies, so sets must name each copy by its augments.
- Every copy carries the base "Efflux" TP bonus +250.
- Worn at midcast of a physical spell cast under Efflux, it adds to Efflux's 1000 TP bonus, alongside Hashishin Tayt (+650 to +800) and the Efflux job points (+10 per level).
- TP bonus past 3000 is lost. ([bg-wiki](https://www.bg-wiki.com/ffxi/Efflux))
- Monster correlation only matters when the spell's monster family is strong against the target's. That adds +0.25 to a physical spell's multiplier (to each hit's fTP on multi-hit spells).
- bg-wiki says the merit and Magus Keffiyeh correlation bonuses raise that figure and never worsen a weak match.
- Vanar has no Monster Correlation merits: Physical Potency 5 and Magical Accuracy 5 (player, 2026-10-02) fill BLU Group 1's 10 levels ([Vanar's merits and skills](#vanars-merits-and-skills)).
- Neither bg-wiki nor FFXIclopedia gives a value for this cape's +10, and the bg-wiki page is flagged outdated. ([bg-wiki](https://www.bg-wiki.com/ffxi/Calculating_Blue_Magic_Damage))
- Copy `'DEX+20','Accuracy+20 Attack+20','DEX+10','Crit.hit rate+10'`: it has no Resin (fifth) augment, so unlike the Double Attack copy it has no Damage taken-5%. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:JSE_Capes))
- Copy `'INT+20','Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+10','"Mag.Atk.Bns."+10'`:
  - It has no Resin augment, and its Dye went to Magic Accuracy+10 instead of INT+10.
  - Its Magic Damage+20 adds to a spell's base damage (the D term) before any multiplier. ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Damage))
- Copy `'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%'`: it has no Resin (fifth) augment, so it carries no damage taken reduction. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:JSE_Capes))
- Copy `'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Dbl.Atk."+10','Damage taken-5%'`:
  - It is fully augmented.
  - bg-wiki says the Ambuscade cape's Damage taken -5% is really 12/256 (about 4.7%), so count 4.7% toward the 50% DT cap. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:JSE_Capes))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): the page names each cape only by its stat and main augment.
  - Copy `'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%'`: matches the sims' STR, Weapon Skill Damage cape. BLU: Expiacion (Mid buff, High buff); Savage Blade (Mid buff, High buff).
  - Copy `'DEX+20','Accuracy+20 Attack+20','DEX+10','Crit.hit rate+10'`: matches the sims' DEX, Crit Rate cape. BLU: Chant du Cygne (Mid buff, High buff).
  - The other sets use capes with different augments from all of Vanar's copies. BLU: Caliburnus + Thibron AM1 TP [DEX, Dual Wield] (-50% DT); Tizona + Thibron AM3 TP [DEX, Store TP] (-50% DT); Imperator [DEX, Weapon Skill Damage] (High buff); Sanguine Blade [INT, Weapon Skill Damage] (Mid buff, Ice Brand enabled); Red Lotus Blade [INT, Weapon Skill Damage] (Mid buff, Ice Brand enabled); Requiescat [MND, DA] (Mid buff, High buff).
  - Vanar's INT/Magic Accuracy/Magic Atk. Bonus and DEX/Double Attack copies are in no simulated set.

### Shadow Mantle

*Shadow Mantle.*

- It annuls physical damage about 6% of the time, from player testing on bg-wiki. FFXIclopedia estimates 5-10%. ([bg-wiki](https://www.bg-wiki.com/ffxi/Shadow_Mantle))

### Solemnity Cape

*Solemnity Cape.*

- Its Cure potency +7% is the plain kind, capped at 50% in total. It is not Cure potency II, which has its own 30% cap.
- It counts when the spell lands, so it goes in the midcast set. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Cure_Spell))
- White Wind heals floor(MaxHP/7) × 2, from max HP rather than current HP.
- White Wind is raised by cure potency gear, obis and weather, but not by Healing magic skill or MND. ([bg-wiki](https://www.bg-wiki.com/ffxi/White_Wind))
- Magic Fruit is also raised by cure potency gear, but unlike White Wind it ignores day, weather and obis. ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Fruit))

### Sucellos's Cape

*Sucellos's Cape. RDM only.*

- It isn't Rare, and Vanar owns five copies, so sets must name each copy by its augments.
- Every copy has the native Enfeebling magic effect +10: 10% more potency, rounded down, multiplied with Saboteur.
- Every copy also has native Enhancing magic duration +20%. ([bg-wiki](https://www.bg-wiki.com/ffxi/Sucellos%27s_Cape))
- That +20% is native, so it adds with the other native pieces such as Lethargy and Embla Sash.
- Ghostfyre Cape's augmented +20% multiplies separately, and gives more whenever the set's native total is larger than its other augmented duration. ([bg-wiki](https://www.bg-wiki.com/ffxi/Ghostfyre_Cape))
- Copy with no augments: it adds nothing the four augmented copies lack, and it sits in the Mog Safe, out of GearSwap's reach. ([bg-wiki](https://www.bg-wiki.com/ffxi/Sucellos%27s_Cape))
- Copy `'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%','Damage taken-5%'`: it is fully augmented.
- Copy `'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Dbl.Atk."+10','Damage taken-5%'`: it is fully augmented.
- On those two copies, bg-wiki says Damage taken -5% is really 12/256 (about 4.7%), so count 4.7% toward the 50% DT cap. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:JSE_Capes))
- Copy `'MND+20','Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+10','Haste+10'`:
  - Haste+10 is the Sap augment's maximum, 10% gear haste.
  - Worn at midcast, it shortens the enfeeble's recast and counts toward the 25% gear haste cap.
  - It has no Resin augment. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:JSE_Capes))
  - The native Enfeebling magic effect +10 makes it a potency piece as well as the accuracy cape. ([bg-wiki](https://www.bg-wiki.com/ffxi/Sucellos%27s_Cape))
- Copy `'INT+20','Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+10','"Mag.Atk.Bns."+10'`:
  - It has no Resin augment, and its Dye went to Magic Accuracy+10 instead of INT+10.
  - Its Magic Damage+20 adds to a spell's base damage (the D term) before any multiplier. ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Damage))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): the page names each cape only by its stat and main augment.
  - Copy `'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%','Damage taken-5%'`: matches the sims' STR, Weapon Skill Damage cape. RDM: Savage Blade (Mid buff, High buff); Death Blossom (Mid buff, High buff); Knights of Round (Mid buff, High buff); Seraph Blade (Mid buff); Red Lotus Blade (Mid buff); Mercy Stroke (Mid buff, High buff); Black Halo (Mid buff).
  - Copy `'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%','Damage taken-5%'`: for the magical weapon skills, Seraph Blade and Red Lotus Blade, the page doesn't say whether the sims' cape has Accuracy and Attack +20, as this copy does, or Magic Accuracy and Magic Damage +20. Current wsdist has both versions ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), lines 1204 and 1209).
  - Copy `'INT+20','Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+10','"Mag.Atk.Bns."+10'`: the nearest to the sims' INT, Magic Attack cape. RDM: Casting (Free Nuke, Magic Burst). Current wsdist builds that cape with INT+30 where this copy has INT+20 and Magic Accuracy+10 ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), line 1220).
  - The other sets use capes with different augments from all of Vanar's copies. RDM: Chant du Cygne [DEX, Crit Rate] (Mid buff, High buff); Evisceration [DEX, Crit Rate] (Mid buff, High buff); Naegling + Thibron TP [DEX, Store TP] (-50% DT, -25% DT); Imperator [DEX, Weapon Skill Damage] (High buff); Aeolian Edge [INT, Weapon Skill Damage] (Mid buff); Requiescat [MND, Weapon Skill Damage] (Mid buff, High buff); Sanguine Blade [MND, Weapon Skill Damage] (Mid buff); Black Halo [MND, Weapon Skill Damage] (High buff).
  - Vanar's DEX/Double Attack and MND/Magic Accuracy/Haste copies, and the copy with no augments, are in no simulated set.

### Swith Cape

*Swith Cape.*

- Its unnumbered `Enhances "Fast Cast" effect` is 3% Fast Cast.
- Fi Follet Cape +1 (Path A) gives more from rank 4 up, reaching +10% at rank 15. Its rank isn't recorded, so ask the player before keeping Swith Cape in precast. ([bg-wiki](https://www.bg-wiki.com/ffxi/Swith_Cape))

### Tengu Shawl

*Tengu Shawl.*

- It casts Sneak and Invisible.
- It needs 30 s equipped before use, takes 6 s to cast and recharges in 1 hour.
- It can also be used in the Mog Garden. ([bg-wiki](https://www.bg-wiki.com/ffxi/Tengu_Shawl))

### Toutatis's Cape

*Toutatis's Cape. THF only.*

- Copy with no augments: Vanar holds two, both in the Mog Safe. ([bg-wiki](https://www.bg-wiki.com/ffxi/Toutatis%27s_Cape))
- Copy `'DEX+20','Accuracy+20 Attack+20','Accuracy+10','Crit.hit rate+10'`: a crit build with no Resin augment. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:JSE_Capes))

### Twilight Cape

*Twilight Cape.*

- bg-wiki: it adds +0.05 to the Day & Weather multiplier when a matching day or weather bonus procs, never twice. That multiplier caps at 1.4.
- Its bg-wiki item page says the bonus also covers cure potency. ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Damage))
- FFXIclopedia disagrees on days: its +5% always applies to a spell that matches the day, proc or not. A weather match still needs the weather proc.
- FFXIclopedia also lists cures and elemental weapon skills, and says the cape doesn't touch penalties from an opposing day or weather. ([FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Twilight_Cape))
- Without an elemental obi or Hachirin-no-Obi, bg-wiki says day and weather bonuses proc only at random.
- Vanar's export has neither (its only obi is Fucho-no-Obi), so under bg-wiki's reading the cape's bonus applies only some of the time. ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Damage))

No notes beyond the help text: Altruistic Cape, Boxer's Mantle, Trepidity Mantle, Tuilha Cape.

## Waist

### Cascade Belt

*Cascade Belt.*

- On RDM and BLU, other waists Vanar owns beat each of its stats. Olympus Sash has more Enhancing magic skill (+5 vs +3). Porous Rope has the same MND+7 plus Magic Accuracy+5. ([bg-wiki](https://www.bg-wiki.com/ffxi/Olympus_Sash), [bg-wiki](https://www.bg-wiki.com/ffxi/Porous_Rope))
- Its one use for both stats together is Stoneskin, which absorbs skill + 3 x MND - 190, capped at 350.
- RDM's enhancing set has 545 skill at Master Level 25: 481 without gear (404 + 36 gifts + 16 merits + 25 Master Levels) plus Viti. Tabard +4's 24, Leth. Houseaux +3's 35 and Ghostfyre Cape's 5. RDM.lua's comment gives 544, counted at Master Level 24.
- That caps Stoneskin with skill alone (545 - 190 = 355), so Siegel Sash's +20 past the cap is worth more there. ([bg-wiki](https://www.bg-wiki.com/ffxi/Stoneskin), [bg-wiki](https://www.bg-wiki.com/ffxi/Siegel_Sash))

### Casso Sash

*Casso Sash.*

- Rumination Sash beats it for enfeebling: skill +7 vs +5, plus Magic Accuracy+3 and MND+4. ([bg-wiki](https://www.bg-wiki.com/ffxi/Rumination_Sash))
- Its Dark magic skill +5 is worth 5 Magic Accuracy on dark magic (1 skill = 1 Magic Accuracy). Eschan Stone gives 7. ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Accuracy))
- Dark magic skill also raises Drain and Aspir potency. RDM and BLU have those spells only from a /BLM, /DRK, /GEO or /SCH subjob. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Drain/Aspir_Spell))

### Channeler's Stone

*Channeler's Stone. RDM only.*

- For RDM precast, Embla Sash has more Fast Cast (5% vs 2%). BLU can't wear either one. ([bg-wiki](https://www.bg-wiki.com/ffxi/Channeler%27s_Stone), [bg-wiki](https://www.bg-wiki.com/ffxi/Embla_Sash))

### Dynamic Belt +1

*Dynamic Belt +1.*

- On BLU, Hurch'lan Sash beats it (Accuracy+15 vs +11, Haste+7% vs +6%), leaving Dynamic only its STR+4. RDM can't wear Hurch'lan Sash. ([bg-wiki](https://www.bg-wiki.com/ffxi/Hurch%27lan_Sash), [bg-wiki](https://www.bg-wiki.com/ffxi/Dynamic_Belt_%2B1))

### Embla Sash

*Embla Sash. RDM only.*

- "Sublimation"+3 drains 3 more HP a tick to store 3 more MP a tick while Sublimation charges.
- RDM has Sublimation only from a /SCH subjob. There the base is 2 HP drained for 3 MP stored a tick, so the sash doubles the MP stored per tick (3 to 6) and raises the HP drain from 2 to 5. ([bg-wiki](https://www.bg-wiki.com/ffxi/Sublimation))
- Its Enhancing magic duration +10% is listed natively. It adds to the other native duration % (bg-wiki's worked example adds it to Ammurapi Shield's), not to the separate augmented-duration multiplier. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Enhancing_Magic))

### Fotia Belt

*Fotia Belt.*

- The latent needs a weapon skill with any skillchain property. Chant du Cygne, Requiescat, Evisceration and Vorpal Blade all have one.
- Its "Weapon skill damage +10%" is really +25/256 (0.098) fTP. All four of those weapon skills are fTP-replicating, so it is added to every hit's fTP.
- The gain per hit is 0.098 / the weapon skill's fTP, not a flat +10%: about +9.8% for Requiescat (fTP 1.0), +7.8% for Evisceration (1.25), +7.1% for Vorpal Blade (1.375) and +6.0% for Chant du Cygne (1.633). ([bg-wiki](https://www.bg-wiki.com/ffxi/Fotia_Belt), [bg-wiki](https://www.bg-wiki.com/ffxi/Category:FTP_Replicating_WS))
- Its Weapon Skill Accuracy+10 is not the usual Weapon Skill Accuracy stat. It also raises the accuracy of magical weapon skills. ([bg-wiki](https://www.bg-wiki.com/ffxi/Fotia_Belt))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Chant du Cygne (Mid buff, High buff); Requiescat (Mid buff, High buff); Evisceration (Mid buff, High buff); BLU: Chant du Cygne (Mid buff, High buff); Requiescat (Mid buff, High buff).
- wsdist: the data is right, but it stores the latent accuracy as ordinary Weapon Skill Accuracy, which the engine adds only to physical and ranged weapon skills. So it undervalues the belt on magical weapon skills with a skillchain property, such as Seraph Blade, Red Lotus Blade and Aeolian Edge, but only against an enemy given Magic Evasion. Every wsdist preset, the sims' "BG Wiki sets" included, has 0, and there every magical hit lands ([ffxi-mechanics.md](ffxi-mechanics.md#where-wsdist-and-bg-wiki-disagree)). ([actions.py](https://github.com/IzaKastra/wsdist_beta/blob/main/actions.py), lines 1759-1760 and 2244)

### Fucho-no-Obi

*Fucho-no-Obi.*

- The latent Refresh+1 needs MP below 50% of a base that counts MP+ only from the main, sub, ammo, head, neck, body, hands, waist (itself), legs and feet slots, and no MP% gear.
- Ear, ring and back MP is left out. With Etiolation Earring (MP+50) and Murky Ring (MP+30) on, the latent comes on at about 50 x (max MP - 80) / max MP percent, a few points below `player.mpp` 50. ([bg-wiki](https://www.bg-wiki.com/ffxi/Fucho-no-Obi), [bg-wiki](https://www.bg-wiki.com/ffxi/Etiolation_Earring))
- "Drain" and "Aspir" potency +8 is 8% on each. It multiplies the amount drained, so a 100\~200 range becomes 108\~216 ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Drain/Aspir_Spell)).
- Only BLM, DRK, GEO and SCH have Drain and Aspir, so RDM and BLU use it only with one of those subjobs. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Drain/Aspir_Spell))

### Kentarch Belt +1

*Kentarch Belt +1.*

- Vanar's copy has no augments (rank 0), so it lacks the Unity Path A augment: STR+10 and DEX+10 at rank 15 (STR first, DEX from rank 6). [rank-augments.md](rank-augments.md#kentarch-belt-1) gives every rank. ([bg-wiki](https://www.bg-wiki.com/ffxi/Kentarch_Belt_%2B1))
- Its "Store TP"+1~5 follows the weekly rank of Vanar's Unity faction. A higher rank gives more, up to +5, so it can change from week to week. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Unity_Concord), [bg-wiki](https://www.bg-wiki.com/ffxi/Category:Unity_Rewards))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Imperator (High buff); Ruthless Stroke (High buff); BLU: Imperator (Mid buff, High buff).
- wsdist: its only entry is "Kentarch Belt +1 R15", which adds STR and DEX +10 that Vanar's unaugmented copy lacks, and counts Store TP at the Unity maximum, 5. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), line 1246)

### Obstin. Sash

*Obstinate Sash. RDM only.*

- Vanar's copy has no Odyssey augments (rank 0). Path A at rank 30 adds Magic Accuracy+15 (full by rank 15), Enfeebling magic skill+15 (from rank 16) and Enmity-5 (from rank 21). [rank-augments.md](rank-augments.md#obstin-sash) gives every rank.
- Without the augment, the sash is only MND+5 and enfeebling duration +5%. ([bg-wiki](https://www.bg-wiki.com/ffxi/Obstin._Sash))

### Oneiros Sash

*Oneiros Sash. RDM only.*

- For RDM, Eschan Stone beats it on every stat: MAB+7 vs +4, the same HP+20 and MP+20, plus Magic Accuracy+7 and Accuracy/Attack+15. BLU can't wear Oneiros Sash. ([bg-wiki](https://www.bg-wiki.com/ffxi/Eschan_Stone), [bg-wiki](https://www.bg-wiki.com/ffxi/Oneiros_Sash))

### Ovate Rope

*Ovate Rope.*

- For spells that only need to land, it has 1 more Magic Accuracy than Eschan Stone (+8 vs +7), plus MND+4.
- For RDM's enfeebling magic, Rumination Sash is better still.
- Its MAB-10 lowers all magic damage, spells and magical weapon skills alike, so it stays out of damage sets. ([bg-wiki](https://www.bg-wiki.com/ffxi/Ovate_Rope), [bg-wiki](https://www.bg-wiki.com/ffxi/Eschan_Stone), [bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Attack_Bonus))

### Phasmida Belt

*Phasmida Belt.*

- Dynamic Belt +1 beats it for melee on both jobs: Accuracy+11 vs +6, the same Haste+6%, plus STR+4. Only Phasmida's Evasion+6 is extra. ([bg-wiki](https://www.bg-wiki.com/ffxi/Dynamic_Belt_%2B1))
- On BLU, Hurch'lan Sash (Accuracy+15, Haste+7%) also beats it. ([bg-wiki](https://www.bg-wiki.com/ffxi/Hurch%27lan_Sash))

### Plat. Mog. Belt

*Platinum Moogle Belt.*

- HP+10% applies after merits, gifts, Master Levels and HP from other gear, so it grows with the rest of an HP set.
- That suits it to max-HP sets such as White Wind's midcast. ([bg-wiki](https://www.bg-wiki.com/ffxi/Plat._Mog._Belt), [bg-wiki](https://www.bg-wiki.com/ffxi/White_Wind))

### Rumination Sash

*Rumination Sash.*

- On enfeebling magic, 1 point of enfeebling skill is 1 Magic Accuracy. So this sash is worth Magic Accuracy+10 on enfeebles (+3 plus skill +7), more than Eschan Stone (+7) or Ovate Rope (+8), plus MND+4.
- On other magic it is only Magic Accuracy+3. ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Accuracy), [bg-wiki](https://www.bg-wiki.com/ffxi/Rumination_Sash))

### Sailfi Belt +1

*Sailfi Belt +1.*

- Path A at max rank 15 is STR+15 and Double Attack+5%.
- STR rises 1 per rank. Double Attack starts only at rank 6 (+1%) and gains 1% every two ranks (2% at 8, 3% at 10, 4% at 12, 5% at 14).
- The export doesn't show the rank, and Vanar's rank isn't recorded, since ranks change often; ask the player when a set decision turns on it. [rank-augments.md](rank-augments.md#sailfi-belt-1) gives every rank. ([bg-wiki](https://www.bg-wiki.com/ffxi/Sailfi_Belt_%2B1))
- Its Attack+10~15 follows Vanar's Unity faction's weekly ranking (a higher rank gives more), so it can be as low as +10. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Unity_Concord), [bg-wiki](https://www.bg-wiki.com/ffxi/Category:Unity_Rewards))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Savage Blade (Mid buff, High buff); Death Blossom (Mid buff, High buff); Knights of Round (Mid buff, High buff); Imperator (Mid buff); Mercy Stroke (Mid buff, High buff); Ruthless Stroke (Mid buff); Black Halo (Mid buff, High buff); BLU: Expiacion (Mid buff, High buff); Savage Blade (Mid buff, High buff).

### Siegel Sash

*Siegel Sash.*

- "Enhances Stoneskin effect" is +20 HP absorbed. It goes past the 350 cap (up to 475 with other Stoneskin+ gear). ([bg-wiki](https://www.bg-wiki.com/ffxi/Stoneskin))
- Its Enhancing magic casting time -8% belongs in precast. ([bg-wiki](https://www.bg-wiki.com/ffxi/Siegel_Sash))
- The Stoneskin bonus works only on the Stoneskin spell, not BLU's Diamondhide or Metallic Body (bg-wiki: [Diamondhide](https://www.bg-wiki.com/ffxi/Diamondhide), [Metallic Body](https://www.bg-wiki.com/ffxi/Metallic_Body)). The sash only has to be on during the cast; bg-wiki doesn't cover that ([FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Siegel_Sash)).

### Twilight Belt

*Twilight Belt. BLU only.*

- On BLU, Sailfi Belt +1 beats it at any Path A rank: Haste+9% vs +7%, and Triple Attack+2% instead of Double Attack+2%, plus Path A Double Attack from rank 6. RDM can't wear Twilight Belt. ([bg-wiki](https://www.bg-wiki.com/ffxi/Twilight_Belt), [bg-wiki](https://www.bg-wiki.com/ffxi/Sailfi_Belt_%2B1))

### Witful Belt

*Witful Belt.*

- Its hidden Fast Cast value is 3%. Its Haste+3% is 31/1024. ([bg-wiki](https://www.bg-wiki.com/ffxi/Witful_Belt))
- Fast Cast gear cuts recast only if it is still on when the spell goes off. Worn in precast only, it cuts casting time only. ([bg-wiki](https://www.bg-wiki.com/ffxi/Spell_Recast))
- A Quick Magic proc (3%) makes the spell instant, with no casting or recast time. ([bg-wiki](https://www.bg-wiki.com/ffxi/Occasionally_Quickens_Spellcasting))
- After an instant cast, GearSwap has no casting time to swap in midcast gear, so the spell can land in precast gear. This is common GearSwap advice, not on bg-wiki. ([ffxi-mechanics.md](ffxi-mechanics.md#quick-magic))
- It is the only Fast Cast waist in Vanar's export that BLU can wear. Embla Sash and Channeler's Stone are not BLU gear. ([bg-wiki](https://www.bg-wiki.com/ffxi/Embla_Sash), [bg-wiki](https://www.bg-wiki.com/ffxi/Channeler%27s_Stone))

No notes beyond the help text: Chaac Belt, Cornelia's Belt, Eschan Stone, Flume Belt, Hurch'lan Sash, Olympus Sash, Porous Rope.

## Legs

### Assiduity Pants

*Assiduity Pants. Not RDM or BLU.*

- RDM and BLU can't equip it.
- Its Unity "Refresh"+1 isn't fixed. Unity stats scale with your Unity faction's ranking ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Unity_Rewards)).

### Assim. Shalwar +1

*Assimilator's Shalwar +1. BLU only.*

- bg-wiki lists its "Burst Affinity"+12 as WSC +0.12.
- Burst Affinity doubles the WSC of the next magical blue magic spell. With these legs the multiplier is 2.12 instead of 2 ([bg-wiki](https://www.bg-wiki.com/ffxi/Burst_Affinity)).
- Set bonus: Assimilator's, see [Assimilator's set](#assimilators-set). As a +1 piece it doesn't count ([bg-wiki](https://www.bg-wiki.com/ffxi/Assimilator%27s_Attire_Set)).

### Atro. Tights +4

*Atrophy Tights +4. RDM only.*

- "Cure" potency +12% counts toward the 50% Cure potency cap. Cure potency II is a separate bonus, capped at 30% ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Cure_Spell)).
- Its Enhancing magic skill +22 is the most of any legs Vanar owns. Carmine Cuisses +1 has +18, Portent Pants +15 and Rawhide Trousers +10 (help text, with augments from the [export](../data/export/Vanar%202026-10-01%2022-41-03.lua)).
- Set bonus: Atrophy, see [Atrophy set](#atrophy-set) ([bg-wiki](https://www.bg-wiki.com/ffxi/Atrophy_Armor_Set)).

### Bunzi's Pants

*Bunzi's Pants. RDM, not BLU.*

- Vanar's copy is rank 0 (player, 2026-10-02): no augments, only the base stats in its help text. The export prints no augments for it, not even `'Path: A'`.
- Its only path, Odyssey Path A, adds Attack, Magic Damage and "Blood Pact" damage from rank 1, Accuracy and Magic Accuracy from rank 16, and Pet: Damage taken from rank 21. For the values at each rank, see [rank-augments.md](rank-augments.md#bunzis-pants) ([bg-wiki](https://www.bg-wiki.com/ffxi/Bunzi%27s_Pants)).
- Its Magic burst damage +9 is the first kind, which caps at +40% across all gear. Magic burst damage II is a separate bonus with no known cap ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Burst)).

### Carmine Cuisses +1

*Carmine Cuisses +1.*

- Its augments are Nolan Path D at full rank. Nolan augments go from rank 1 to 15, and Accuracy+20, Attack+12 and "Dual Wield"+6 are the rank 15 values.
- Totals are Accuracy+55, Attack+47 and Dual Wield+6, so it also works as a dual-wield TP piece.
- The other paths are A: HP+80, STR+12, INT+12; B: Accuracy+12, DEX+12, MND+20; and C: MP+80, INT+12, MND+12 ([bg-wiki](https://www.bg-wiki.com/ffxi/Nolan)).
- Movement speed from equipment doesn't stack: only the highest piece counts. Its 18% is tied for the most RDM and BLU get from non-costume gear; Shneddick Ring is also 18% ([bg-wiki](https://www.bg-wiki.com/ffxi/Movement_Speed)).
- Set bonus: Carmine, see [Carmine set](#carmine-set). Vanar owns no other Carmine +1 piece, so it never applies ([bg-wiki](https://www.bg-wiki.com/ffxi/Carmine_Armor_Set)).
- wsdist: the entry matches Vanar's Path D copy, but the engine has no Carmine +1 set bonus at all. Vanar owns only the cuisses, so that doesn't affect him. ([create_player.py](https://github.com/IzaKastra/wsdist_beta/blob/main/create_player.py), lines 651-735)

### Chironic Hose

*Chironic Hose. RDM, not BLU.*

- This is a Healing-path magic accuracy copy. Its Mag. Acc.+28 sits in bg-wiki's Healing-path range of +1 to +40.
- MND+12 is in the base-stat roll, which caps at +10 (+15 with Taupe Stones).
- It has no special-stat augment. That slot rolls one stat, such as Cure potency, Cure spellcasting time or Fast Cast (Fern Stone caps: +11%, -11% and +7) ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Escha_Rewards/Arcane_Glyptics_Inscription)).
- Totals are Magic Accuracy+48, MND+41 and Enfeebling skill +13.
- Leth. Fuseau +3 (Magic Accuracy 63, MND 43) and Atro. Tights +4 (Magic Accuracy 59 plus the Atrophy set, MND 44) beat it on both. Its only case for enfeebling is its skill (help text, with augments from the [export](../data/export/Vanar%202026-10-01%2022-41-03.lua)).

### Crimson Cuisses

*Crimson Cuisses.*

- The four unlabeled +20s in its help text are icon stats: Fire, Lightning, Water and Dark resistance +20 each.
- Its Fast Cast is a Synergy augment that ranges from +1 to +4. This copy has the minimum ([bg-wiki](https://www.bg-wiki.com/ffxi/Crimson_Cuisses)).
- Carmine Cuisses +1 beats its movement speed in the same slot (18% vs 12%).
- For fast cast, Enif Cosciales (8%, BLU but not RDM) and Orvail Pants +1 (5%) beat its +1.
- It has no item level, so it has no use for RDM or BLU ([bg-wiki](https://www.bg-wiki.com/ffxi/Movement_Speed)).

### Doyen Pants

*Doyen Pants.*

- Its Cure (-15%) and Stoneskin (-10%) spellcasting time cuts only shorten casting time, which is fixed at precast.
- bg-wiki's recast formula has terms only for haste, Fast Cast and job abilities. So these cuts do nothing for recast and belong in the precast sets ([bg-wiki](https://www.bg-wiki.com/ffxi/Spell_Recast)).
- bg-wiki's Cure page says Cure spellcasting time adds to Fast Cast 1% for 1%, and that all casting time cuts together can't pass the 80% cap. The player holds that such cuts go past it ([ffxi-mechanics.md](ffxi-mechanics.md#does-anything-break-the-80-cap-disputed)) ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Cure_Spell)).

### Duelist's Tights

*Duelist's Tights. RDM only.*

- The Spikes bonus adds floor(INT × 6/256) to Blaze Spikes base damage and floor(INT × 3/256) to Ice and Shock Spikes. That is about +4 and +2 at 200 INT.
- It only works while worn when the spikes hit, not at the cast ([bg-wiki](https://www.bg-wiki.com/ffxi/Duelist%27s_Tights)).

### Enif Cosciales

*Enif Cosciales. BLU, not RDM.*

- Its unnumbered "Enhances Fast Cast" is 8%.
- It has no item level, so its only use is BLU's precast fast-cast set ([bg-wiki](https://www.bg-wiki.com/ffxi/Enif_Cosciales)).

### Gleti's Breeches

*Gleti's Breeches. BLU, not RDM.*

- Vanar's copy is rank 0 (player, 2026-10-02): no augments, only the base stats in its help text. The export prints no augments for it, not even `'Path: A'`.
- Its only path, Odyssey Path A, adds Attack and "Subtle Blow" from rank 1, Accuracy and Magic Accuracy from rank 16, and "Triple Attack" from rank 21. For the values at each rank, see [rank-augments.md](rank-augments.md#gletis-breeches) ([bg-wiki](https://www.bg-wiki.com/ffxi/Gleti%27s_Breeches)).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): BLU: Chant du Cygne (Mid buff, High buff); Requiescat (High buff); Imperator (High buff). Vanar's copy is rank 0, without the rank 30 augment (Attack+30, Subtle Blow +15, Accuracy and Magic Accuracy +15, Triple Attack +5%), so the sims overvalue it ([rank-augments.md](rank-augments.md#gletis-breeches)).
- wsdist: its rank 0 entry has Subtle Blow 8, the rank 15 value; the base item has none. The engine never reads Subtle Blow, so results don't change. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), line 1689)

### Hashishin Tayt +3

*Hashishin Tayt +3. BLU only.*

- Its "Efflux" TP Bonus +800 only works while the legs stay equipped. So it belongs in the physical blue magic midcast set, where the Efflux-boosted spell goes off ([bg-wiki](https://www.bg-wiki.com/ffxi/Hashishin_Tayt_%2B3)).
- Efflux gives a 1000 TP bonus (+10 per Efflux job point level) to the next physical blue magic spell.
- Any TP bonus from Efflux past 3000 is lost ([bg-wiki](https://www.bg-wiki.com/ffxi/Efflux)).
- Set bonus: Hashishin, see [Hashishin set](#hashishin-set) ([bg-wiki](https://www.bg-wiki.com/ffxi/Hashishin_Attire_Set)).

### Herculean Trousers

*Herculean Trousers. BLU, not RDM.*

- This is a physical weapon skill copy.
- Accuracy+18 Attack+18 is in the combined slot, which caps at 25.
- Weapon skill damage +4% is at the normal cap (5% with Fern Stones).
- The extra Accuracy+13 is in a slot that caps at 15 ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Escha_Rewards/Arcane_Glyptics_Inscription)).
- Vanar's Nyame Flanchard (Path B, rank 20) beats it in every weapon skill stat: Accuracy 40 vs 31, Attack 55 vs 33, WSD 9% vs 4%, STR 43 vs 40. A Path B Flanchard does so from rank 9 up; see [rank-augments.md](rank-augments.md#nyame-flanchard) for each rank.
- Luh. Shalwar +4 has WSD +12% and Accuracy+50. So this copy has no use in BLU weapon skill sets ([bg-wiki](https://www.bg-wiki.com/ffxi/Nyame_Flanchard)).

### Jhakri Slops +2

*Jhakri Slops +2.*

- Set bonus: Jhakri, see [Jhakri set](#jhakri-set) ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Ambuscade_Rewards)).

### Leth. Fuseau +3

*Lethargy Fuseau +3. RDM only.*

- "Refresh" potency +4 adds 4 MP per tick to every Refresh spell you cast. So it must be on when Refresh lands (midcast) ([bg-wiki](https://www.bg-wiki.com/ffxi/Leth._Fuseau_%2B3)).
- Its Magic burst damage +15 is the first kind, which caps at +40% across all gear ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Burst)).
- Set bonus: Lethargy, see [Lethargy set](#lethargy-set) ([bg-wiki](https://www.bg-wiki.com/ffxi/Lethargy_Armor_Set)).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Sanguine Blade (Mid buff); Aeolian Edge (Mid buff); Casting (Free Nuke).

### Luh. Shalwar +4

*Luhlaza Shalwar +4. BLU only.*

- The 'Enhances "Assimilation" effect' augment gives Magic Critical Hit Rate +3% per Assimilation merit level, up to +15% at five merits ([bg-wiki](https://www.bg-wiki.com/ffxi/Luh._Shalwar_%2B4)).
- Vanar has no Assimilation merits: Diffusion 5 and Enchainment 5 (player, 2026-10-02) fill BLU Group 2's 10 levels. So the augment gives him 0% (0 × 3%); the +15% figure below assumes 5 merits he doesn't have ([Vanar's merits and skills](#vanars-merits-and-skills)).
- Magic critical hits only happen on Blue, Divine and Elemental magic. They add +10 MAB when they proc.
- So the augment does nothing for magical weapon skills. At +15% it averages about 1.5 MAB on blue magic nukes ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Critical_Hit)).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): BLU: Sanguine Blade (Mid buff, Ice Brand enabled); Red Lotus Blade (Mid buff, Ice Brand enabled).

### Merlinic Shalwar

*Merlinic Shalwar. RDM, not BLU.*

- Merlinic is Exclusive but not Rare, and Vanar has two copies: an augmented one in storage and a bare one in safe2.
- Both copies share a name, so a set that lists plain "Merlinic Shalwar" can pick up either one. A set must name the augmented copy by its augments ([bg-wiki](https://www.bg-wiki.com/ffxi/Merlinic_Shalwar)).
- Copy `'Mag. Acc.+25 "Mag.Atk.Bns."+25','Magic burst dmg.+1%','INT+7','Mag. Acc.+11','"Mag.Atk.Bns."+13'`:
  - This is a nuking copy. Its Mag. Acc.+25 MAB+25 is at the combined slot's cap.
  - Its Magic burst damage +1% is the bottom of a roll that goes up to +10% (+11% with Fern Stones), so it is weak for bursting ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Escha_Rewards/Arcane_Glyptics_Inscription)).
  - Leth. Fuseau +3 beats it on every nuke and burst stat except INT (48 vs 50) and Enmity: Magic Accuracy 63 vs 56, MAB 58 vs 53, Magic Damage 33 vs 13, Magic burst damage 15 vs 1 (help text, with augments from the [export](../data/export/Vanar%202026-10-01%2022-41-03.lua)).
- Copy with no augments:
  - The augmented copy has the same base stats plus Magic Accuracy+36, MAB+38, INT+7 and Magic burst damage +1%. So it strictly beats this one (help text, with augments from the [export](../data/export/Vanar%202026-10-01%2022-41-03.lua)).

### MGM Chausses +1

*MGM Chausses +1. Elvaan males only.*

- Only Elvaan males can equip it, even though it lists all jobs.
- The Magna F and MGF +1 versions are for Elvaan females ([bg-wiki](https://www.bg-wiki.com/ffxi/Magna_Attire_Set)).

### Nyame Flanchard

*Nyame Flanchard.*

- Vanar's copy is Path B at rank 20 (player, 2026-10-02): Attack+25, Ranged Attack+25, Weapon skill damage +9% and Double Attack +3%. The export prints the path but not the rank.
- Path B's Double Attack starts at rank 16 and its STR at rank 21, so this copy has no STR. For the other ranks and paths, see [rank-augments.md](rank-augments.md#nyame-flanchard).
- Its Magic burst damage +6 is the capped first kind.
- Magic burst damage II is a Path C augment, so this Path B copy has none ([bg-wiki](https://www.bg-wiki.com/ffxi/Nyame_Flanchard)).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Savage Blade (Mid buff, High buff); Death Blossom (Mid buff, High buff); Knights of Round (Mid buff, High buff); Imperator (Mid buff, High buff); Requiescat (Mid buff, High buff); Seraph Blade (Mid buff); Red Lotus Blade (Mid buff); Mercy Stroke (Mid buff, High buff); Ruthless Stroke (Mid buff, High buff); Black Halo (Mid buff, High buff); BLU: Expiacion (Mid buff, High buff); Requiescat (Mid buff); Imperator (Mid buff); Savage Blade (Mid buff, High buff). Vanar's copy is rank 20 Path B, so the sims overvalue it: rank 25 has 5 more Attack, 2% more Weapon skill damage and Double Attack, and STR+10 ([rank-augments.md](rank-augments.md#nyame-flanchard)).
- wsdist: its rank 15 Path B entry has Attack+19, the rank 14 value; rank 15 is +20. Its rank 20 Path B entry, Vanar's, is right, as are the other Nyame rank 15 to 30 rows. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), line 1581)

### Odyssean Cuisses

*Odyssean Cuisses. Not RDM or BLU.*

- RDM and BLU can't equip it. Only WAR, PLD and DRK can.
- This copy is unaugmented ([bg-wiki](https://www.bg-wiki.com/ffxi/Odyssean_Cuisses)).

### Orvail Pants +1

*Orvail Pants +1.*

- Its unnumbered "Enhances Fast Cast" is 5%.
- This copy lacks the optional MP+60 augment ([bg-wiki](https://www.bg-wiki.com/ffxi/Orvail_Pants_%2B1)).
- On BLU, Enif Cosciales (Fast Cast 8%) beats it.
- On RDM it is the best Fast Cast legs Vanar owns. The only other is Crimson Cuisses, at +1 (help text, with augments from the [export](../data/export/Vanar%202026-10-01%2022-41-03.lua)).

### Portent Pants

*Portent Pants.*

- It is level 88 with no item level.
- Its Enhancing skill +15 is below Atro. Tights +4 (+22) and Carmine Cuisses +1 (+18).
- Its Enfeebling skill +15 is the most of any legs Vanar owns (Chironic Hose has +13), but it has no magic accuracy (help text, with augments from the [export](../data/export/Vanar%202026-10-01%2022-41-03.lua)).

### Rawhide Trousers

*Rawhide Trousers. BLU, not RDM.*

- This copy is unaugmented.
- At full Nolan rank (15), Path D gives MP+50, Fast Cast +5% and Refresh +1.
- Paths A to C are shared across the Rawhide set. A: DEX+10, STR+7, INT+7. B: HP+50, Accuracy+15, Evasion+20. C: Accuracy+15, Pet: Accuracy+15, Pet: "Double Attack"+3 ([bg-wiki](https://www.bg-wiki.com/ffxi/Nolan)).

### Samnuha Tights

*Samnuha Tights. BLU, not RDM.*

- The unlabeled +30 in its help text is an icon stat: Dark resistance +30.
- bg-wiki lists its augments as STR+10, DEX+10, Double Attack +3% and Triple Attack +3%. This copy has STR+9, DEX+8, DA +2% and TA +2% ([bg-wiki](https://www.bg-wiki.com/ffxi/Samnuha_Tights)).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): BLU: Tizona + Thibron AM3 TP (-25% DT); Caliburnus + Thibron AM1 TP (-25% DT).
- wsdist: it uses bg-wiki's listed augments, 1 STR, 2 DEX, 1% Double Attack and 1% Triple Attack above Vanar's copy. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), line 1363)

### Taeon Tights

*Taeon Tights.*

- Its Accuracy+18 Attack+18 is near its cap of 20, and its Dual Wield+5 is at its cap of 5 ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Alluvion_Skirmish_Armor)).
- As a dual-wield TP piece, Carmine Cuisses +1 (Path D) beats it: DW+6 vs +5, Accuracy+55 vs +25, Attack+47 vs +18.
- Taeon only adds Triple Attack +2% (help text, with augments from the [export](../data/export/Vanar%202026-10-01%2022-41-03.lua)).

### Tatsu. Sitagoromo

*Tatsumaki Sitagoromo. RDM, not BLU.*

- Its augments are two picks from a fixed menu given at the end of A Shantotto Ascension. Accuracy+7 and Haste+3% are those options' fixed values.
- bg-wiki shows the menu only as an image ([FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Tatsumaki_Sitagoromo)).
- It has no item level, and BLU can't wear it.
- Leth. Fuseau +3 beats it in every stat: Haste+5% vs +3%, Accuracy+63 vs +7, INT/MND/CHR 48/43/30 vs 2 each. So it has no use for RDM (help text, with augments from the [export](../data/export/Vanar%202026-10-01%2022-41-03.lua)).

### Telchine Braconi

*Telchine Braconi.*

- Enh. Mag. eff. dur. +10 is augmented duration. bg-wiki multiplies it separately, after native duration gear and the Lethargy set's Composure bonus.
- Once any native duration % is worn, it is worth more than +10% listed natively ([bg-wiki](https://www.bg-wiki.com/ffxi/Lethargy_Armor_Set)).
- +10 is the top of the augment's roll (+1 to +10).
- It comes from a Dusk stone, and "Regen" potency (+1 to +3) comes from the same Dusk stone, so a copy has one or the other. This one has duration. Vanar's Telchine Chasuble, Pigaches and one of his Telchine Gloves have Regen potency +3.
- Its Leaf slot is empty. A Leafdim stone could add Fast Cast (up to +5%) or Cure potency (up to +8%) ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Alluvion_Skirmish_Armor)).

### Ziamet Salvars

*Ziamet Salvars.*

- Cosmetic only. bg-wiki lists no hidden effects ([bg-wiki](https://www.bg-wiki.com/ffxi/Ziamet_Salvars)).

No notes beyond the help text: Esthete's Hose, Feast Hose.

## Feet

### Assim. Charuqs +2

*Assimilator's Charuqs +2. BLU only.*

- "Chain Affinity"+22 adds 22 to the base damage of a physical blue magic spell cast under Chain Affinity.
- It applies to every hit and isn't held back by the spell's damage cap.
- Wear it in that spell's midcast ([bg-wiki](https://www.bg-wiki.com/ffxi/Chain_Affinity)).
- Set bonus: Assimilator's, see [Assimilator's set](#assimilators-set). As a +2 piece it counts ([bg-wiki](https://www.bg-wiki.com/ffxi/Assimilator%27s_Attire_Set)).

### Augur's Gaiters

*Augur's Gaiters. RDM, not BLU.*

- bg-wiki gives the hidden Fast Cast as 3%, from a BlueGartr test, and [ffxi-mechanics.md](ffxi-mechanics.md#fast-cast) uses the same 3% ([bg-wiki](https://www.bg-wiki.com/ffxi/Augur%27s_Gaiters)).
- For RDM precast, Merlinic Crackows (Fast Cast 5%) and Chelona Boots (4%) both give more Fast Cast (bg-wiki: [Chelona Boots](https://www.bg-wiki.com/ffxi/Chelona_Boots), [Merlinic Crackows](https://www.bg-wiki.com/ffxi/Merlinic_Crackows)).

### Bunzi's Sabots

*Bunzi's Sabots. RDM, not BLU.*

- Vanar's copy is rank 0 (player, 2026-10-02): no augments, only the base stats in its help text. The export prints no augments for it, not even `'Path: A'`.
- Its only path, Odyssey Path A, adds Attack, Magic Damage and "Regen" potency from rank 1, Accuracy and Magic Accuracy from rank 16, and Avatar: All Attr. from rank 21. For the values at each rank, see [rank-augments.md](rank-augments.md#bunzis-sabots) ([bg-wiki](https://www.bg-wiki.com/ffxi/Bunzi%27s_Sabots)).
- Its Magic burst damage +6 is the ordinary kind, which shares the 40% gear cap. It isn't Magic burst damage II ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Burst)).

### Chelona Boots

*Chelona Boots.*

- The hidden Fast Cast is 4%, from a BlueGartr test.
- It is only needed in precast, where its -6 to STR, DEX, VIT and AGI costs nothing ([bg-wiki](https://www.bg-wiki.com/ffxi/Chelona_Boots)).

### Desert Boots

*Desert Boots.*

- The +12% movement speed works in any earth weather, including the Scholar spell Sandstorm, not only in double-earth sandstorms.
- This comes from FFXIclopedia; the bg-wiki page has no note on it ([FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Desert_Boots)).

### Eschite Greaves

*Eschite Greaves. Not RDM or BLU.*

- Only WAR, PLD and DRK can equip it.
- This copy has no Nolan path augment ([bg-wiki](https://www.bg-wiki.com/ffxi/Eschite_Greaves)).

### Eurus' Ledelsens

*Eurus' Ledelsens. RDM, not BLU.*

- It is a level 92 piece with no item level.
- Its "Store TP"-3 slows TP gain.
- For RDM melee, Taeon Boots give the same Haste 4% plus Accuracy and Dual Wield, without the penalty (bg-wiki: [Eurus' Ledelsens](https://www.bg-wiki.com/ffxi/Eurus%27_Ledelsens), [Taeon Boots](https://www.bg-wiki.com/ffxi/Taeon_Boots)).

### Fajin Boots

*Fajin Boots. Not RDM or BLU.*

- Only THF and RNG can equip it ([bg-wiki](https://www.bg-wiki.com/ffxi/Fajin_Boots)).

### Gleti's Boots

*Gleti's Boots. BLU, not RDM.*

- Vanar's copy is rank 0 (player, 2026-10-02): no augments, only the base stats in its help text. The export prints no augments for it, not even `'Path: A'`.
- Its only path, Odyssey Path A, adds Attack and Evasion from rank 1, Accuracy and Magic Accuracy from rank 16, and STR from rank 21. For the values at each rank, see [rank-augments.md](rank-augments.md#gletis-boots) ([bg-wiki](https://www.bg-wiki.com/ffxi/Gleti%27s_Boots)).
- Physical damage limit +5% raises the pDIF cap (gear PDL multiplies the cap), not pDIF itself.
- It only adds damage once attack is high enough for pDIF to reach that cap (bg-wiki: [PDIF](https://www.bg-wiki.com/ffxi/PDIF), [Damage Limit+](https://www.bg-wiki.com/ffxi/Damage_Limit%2B)).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): BLU: Chant du Cygne (High buff). Vanar's copy is rank 0, without the rank 30 augment (Attack+30, Evasion+15, Accuracy and Magic Accuracy +15, STR+5), so the sims overvalue it ([rank-augments.md](rank-augments.md#gletis-boots)).

### Hashi. Basmak +3

*Hashishin Basmak +3. BLU only.*

- "Burst Affinity"+21 raises the WSC of a spell cast under Burst Affinity by 21% (+0.21).
- It has to be worn in that spell's midcast (bg-wiki: [Hashi. Basmak +3](https://www.bg-wiki.com/ffxi/Hashi._Basmak_%2B3), [Burst Affinity](https://www.bg-wiki.com/ffxi/Burst_Affinity)).
- Its Magic burst damage +15 is the ordinary kind, which shares the 40% gear cap.
- Magical blue magic can only magic burst under Burst Affinity or Azure Lore.
- Azure Lore doesn't give Burst Affinity's WSC bonus, so the "Burst Affinity"+21 only works with Burst Affinity itself (bg-wiki: [Magic Burst](https://www.bg-wiki.com/ffxi/Magic_Burst), [Burst Affinity](https://www.bg-wiki.com/ffxi/Burst_Affinity), [Azure Lore](https://www.bg-wiki.com/ffxi/Azure_Lore)).
- Set bonus: Hashishin, see [Hashishin set](#hashishin-set).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): BLU: Sanguine Blade (Mid buff, Ice Brand enabled); Red Lotus Blade (Mid buff, Ice Brand enabled).

### Hct. Leggings

*Hecatomb Leggings. Not RDM or BLU.*

- RDM and BLU can't equip it ([bg-wiki](https://www.bg-wiki.com/ffxi/Hct._Leggings)).

### Herculean Boots

*Herculean Boots. BLU, not RDM.*

- It isn't Rare, and Vanar owns three copies, so a set must name each copy by its augments exactly as the export prints them ([bg-wiki](https://www.bg-wiki.com/ffxi/Herculean_Boots), [ffxi-mechanics.md](ffxi-mechanics.md#gear-and-gearswap)).
- Copy `'Weapon skill damage +4%','Pet: Haste+3','Accuracy+5 Attack+5'`: the weapon skill copy. WSD +4% (the slot caps at 5% with a Fern Stone), but its combined roll is only Accuracy+5 Attack+5 of a possible +25, for totals of Accuracy 15 and Attack 15.
- Copy `'Weapon skill damage +4%','Pet: Haste+3','Accuracy+5 Attack+5'`: its Pet: Haste line does nothing for BLU ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Escha_Rewards/Arcane_Glyptics_Inscription)).
- Copy `'Weapon skill damage +4%','Pet: Haste+3','Accuracy+5 Attack+5'`: Vanar's Nyame Sollerets beats it in every BLU weapon skill set. At its Path B rank 20 the Sollerets have WSD +8% and Attack 55. For other ranks, see [rank-augments.md](rank-augments.md#nyame-sollerets) ([bg-wiki](https://www.bg-wiki.com/ffxi/Nyame_Sollerets)).
- Copy `'Accuracy+21 Attack+21','"Triple Atk."+2','Attack+10'`: the melee TP copy. Totals: Accuracy 31, Attack 41, Triple Attack 4% (2 base + 2 augmented) and Haste 4%.
- Copy `'Accuracy+21 Attack+21','"Triple Atk."+2','Attack+10'`: the Triple Attack augment caps at 3, or 4 with a Fern Stone ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Escha_Rewards/Arcane_Glyptics_Inscription)).
- Copy `'Accuracy+23 Attack+23','Crit. hit damage +1%','DEX+3','Accuracy+9','Attack+12'`: the accuracy copy, with Accuracy 42 and Attack 45 in total.
- Copy `'Accuracy+23 Attack+23','Crit. hit damage +1%','DEX+3','Accuracy+9','Attack+12'`: its special-stat slot rolled only Crit. hit damage +1% (cap 4%, or 5% with a Fern Stone), so it has no WSD or multi-attack augment ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Escha_Rewards/Arcane_Glyptics_Inscription)).

### Inspirited Boots

*Inspirited Boots. RDM, not BLU.*

- The +15 is in seconds. It only applies to Refresh landing on the wearer: your own Refresh, or another player's Refresh while you wear it.
- Seconds go into the base before any multiplier.
- On Vanar's self-cast Refresh III, the base is 150 s + 30 s (5 Enhancing Magic Duration merits × 6) + 20 s (job points) = 200 s, so +15 s is +7.5% (15 / 200). With Viti. Gloves +4's +15 s (5 × 3) the base is 215 s, and it is about +7% (15 / 215). For self-cast Refresh that is less than the native +40% from Leth. Houseaux +3 (bg-wiki: [Refresh](https://www.bg-wiki.com/ffxi/Refresh), [Refresh III](https://www.bg-wiki.com/ffxi/Refresh_III), [Lethargy Armor Set](https://www.bg-wiki.com/ffxi/Lethargy_Armor_Set)).

### Jhakri Pigaches +2

*Jhakri Pigaches +2.*

- Its Magic burst damage +7 is the ordinary kind, which shares the 40% gear cap ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Burst)).
- Set bonus: Jhakri, see [Jhakri set](#jhakri-set).

### Leth. Houseaux +3

*Lethargy Houseaux +3. RDM only.*

- Enhancing magic duration +40% is native duration. It applies to spells on any target and adds together with other native duration %.
- Augmented duration, such as Telchine's "Enh. Mag. eff. dur.", multiplies separately (bg-wiki: [Leth. Houseaux +3](https://www.bg-wiki.com/ffxi/Leth._Houseaux_%2B3), [Lethargy Armor Set](https://www.bg-wiki.com/ffxi/Lethargy_Armor_Set)).
- Set bonus: Lethargy, see [Lethargy set](#lethargy-set).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Savage Blade (Mid buff, High buff); Death Blossom (Mid buff, High buff); Knights of Round (Mid buff, High buff); Imperator (Mid buff, High buff); Sanguine Blade (Mid buff); Seraph Blade (Mid buff); Red Lotus Blade (Mid buff); Mercy Stroke (Mid buff, High buff); Ruthless Stroke (Mid buff, High buff); Black Halo (Mid buff, High buff); Aeolian Edge (Mid buff).

### Luhlaza Charuqs +1

*Luhlaza Charuqs +1. BLU only.*

- The Diffusion augment lengthens the buff Diffusion spreads by 5% per Diffusion merit level (+25% at 5/5), for every party member it reaches.
- bg-wiki's Diffusion page says "maximum of +45%". That matches the augment's 25% plus the merits' own +5% per rank after the first (20%), though the page doesn't spell this out.
- Vanar has 5 Diffusion merits (player, 2026-10-02), so a diffused buff gets the full +45%: 5 × 5% = 25% from the augment plus (5 − 1) × 5% = 20% from the merits.
- When to wear it is disputed. The Sabishii guide says when Diffusion is used, and the Diffusion and Charuqs pages give no timing. So wear it both in the Diffusion job ability set and in the diffused spell's midcast (bg-wiki: [Luhlaza Charuqs +1](https://www.bg-wiki.com/ffxi/Luhlaza_Charuqs_%2B1), [Diffusion](https://www.bg-wiki.com/ffxi/Diffusion), [Azure Tomes: Blue Magic Guide by Sabishii](https://www.bg-wiki.com/ffxi/Azure_Tomes:_Blue_Magic_Guide_by_Sabishii)).

### Merlinic Crackows

*Merlinic Crackows. RDM, not BLU.*

- This copy is a nuking roll: Magic Accuracy 35 and MAB 45 in total, plus Enmity-2.
- It has no Fast Cast augment, so precast gets only the base 5%.
- The magic path can roll Fast Cast +6, or +7 with a Fern Stone ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Escha_Rewards/Arcane_Glyptics_Inscription)).
- For RDM nukes, Leth. Houseaux +3 (Magic Accuracy 60, MAB 50, Magic Damage 30, INT 30) beats it on every nuking stat.
- That leaves this copy its base Fast Cast 5% and Drain/Aspir potency +7 (bg-wiki: [Merlinic Crackows](https://www.bg-wiki.com/ffxi/Merlinic_Crackows), [Leth. Houseaux +3](https://www.bg-wiki.com/ffxi/Leth._Houseaux_%2B3)).
- wsdist: its only entry is an Occult Acumen +11 roll. Against Vanar's copy it is 35 Magic Accuracy and 30 Magic Atk. Bonus short for nukes, and its base Magic Evasion is 116 where the item has 118. The Magic Accuracy gap matters only against an enemy given Magic Evasion; every wsdist preset, the sims' "BG Wiki sets" included, has 0 ([ffxi-mechanics.md](ffxi-mechanics.md#where-wsdist-and-bg-wiki-disagree)). ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), line 1554)

### MGM Ledelsens +1

*MGM Ledelsens +1.*

- bg-wiki lists it as wearable only by Elvaan males.
- The MGM set +1 is the Elvaan male version of the Magna set (bg-wiki: [MGM Ledelsens +1](https://www.bg-wiki.com/ffxi/MGM_Ledelsens_%2B1), [Magna Attire Set](https://www.bg-wiki.com/ffxi/Magna_Attire_Set)).

### Nyame Sollerets

*Nyame Sollerets.*

- Vanar's copy is Path B at rank 20 (player, 2026-10-02): Attack+25, Ranged Attack+25, Weapon skill damage +8% and Double Attack +2%. The export prints the path but not the rank.
- On Path B, Double Attack starts at rank 16 and Accuracy at rank 21, so this copy has Double Attack but no Accuracy. For the other ranks and paths, see [rank-augments.md](rank-augments.md#nyame-sollerets) ([bg-wiki](https://www.bg-wiki.com/ffxi/Nyame_Sollerets)).
- Its Magic burst damage +5 is the ordinary kind, which shares the 40% cap.
- Magic burst damage II is only on Path C, so this Path B copy has none (bg-wiki: [Nyame Sollerets](https://www.bg-wiki.com/ffxi/Nyame_Sollerets), [Magic Burst](https://www.bg-wiki.com/ffxi/Magic_Burst)).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): BLU: Expiacion (Mid buff, High buff); Imperator (Mid buff, High buff); Savage Blade (Mid buff, High buff). Vanar's copy is rank 20 Path B, so the sims overvalue it: rank 25 has 5 more Attack, 2% more Weapon skill damage and Double Attack, and Accuracy+8 ([rank-augments.md](rank-augments.md#nyame-sollerets)).

### Odyssean Greaves

*Odyssean Greaves. Not RDM or BLU.*

- Only WAR, PLD and DRK can equip it.
- This copy is unaugmented ([bg-wiki](https://www.bg-wiki.com/ffxi/Odyssean_Greaves)).

### Powder Boots

*Powder Boots.*

- The Flee enchantment has 20 charges and a 3 s cast.
- It can be used 30 s after the boots are equipped and recasts in 10 minutes ([bg-wiki](https://www.bg-wiki.com/ffxi/Powder_Boots)).
- Flee overwrites the Quickening effect from Sprinter's Shoes.
- bg-wiki gives Thief's Flee ability +60% movement speed. Neither the Powder Boots page nor the Flee page gives the boots' own Flee strength or duration (bg-wiki: [Sprinter's Shoes](https://www.bg-wiki.com/ffxi/Sprinter%27s_Shoes), [Flee](https://www.bg-wiki.com/ffxi/Flee), [Powder Boots](https://www.bg-wiki.com/ffxi/Powder_Boots)).

### Rawhide Boots

*Rawhide Boots. BLU, not RDM.*

- Dual Wield +3 only helps BLU while set blue magic gives it Dual Wield.
- Vanar's Taeon Boots (Dual Wield +8, Accuracy 32) give more of both.
- Rawhide is ahead only on Waltz potency +8% and a few points of STR, DEX, MND and CHR (bg-wiki: [Rawhide Boots](https://www.bg-wiki.com/ffxi/Rawhide_Boots), [Taeon Boots](https://www.bg-wiki.com/ffxi/Taeon_Boots), [Alluvion Skirmish armor](https://www.bg-wiki.com/ffxi/Category:Alluvion_Skirmish_Armor)).

### Rubeus Boots

*Rubeus Boots. RDM, not BLU.*

- Set bonus: Rubeus, see [Rubeus set](#rubeus-set). Vanar owns no other Rubeus piece, so it never applies ([bg-wiki](https://www.bg-wiki.com/ffxi/Rubeus_Attire_Set)).
- Vanar's other RDM feet beat each magic skill on it that RDM uses, all against its +10: Leth. Houseaux +3 has Enhancing magic skill +35, Viti. Boots +4 Enfeebling magic skill +17 and Vanya Clogs Healing magic skill +20 (bg-wiki: [Rubeus Boots](https://www.bg-wiki.com/ffxi/Rubeus_Boots), [Leth. Houseaux +3](https://www.bg-wiki.com/ffxi/Leth._Houseaux_%2B3), [Viti. Boots +4](https://www.bg-wiki.com/ffxi/Viti._Boots_%2B4), [Vanya Clogs](https://www.bg-wiki.com/ffxi/Vanya_Clogs)).

### Serpentes Sabots

*Serpentes Sabots.*

- By day it gives Refresh +1 MP per tick; at night it gives Regen.
- Serpentes Cuffs, which Vanar also owns, do the opposite (Regen by day, Refresh at night), so wearing both keeps Refresh up all the time (bg-wiki: [Refresh (Status)](https://www.bg-wiki.com/ffxi/Refresh_(Status)), [Serpentes Cuffs](https://www.bg-wiki.com/ffxi/Serpentes_Cuffs)).
- Set bonus: Serpentes, see [Serpentes set](#serpentes-set).

### Sprinter's Shoes

*Sprinter's Shoes.*

- Using it gives Quickening, +10% movement speed for 1 hour.
- The effect stays after the shoes come off or you zone, and stacks with movement speed gear and Mazurka.
- It ends on aggro, on any offensive action, on a job change or under a level cap. Flee overwrites it.
- The shoes have 15 charges, can be used 15 s after equipping and recast in 5 minutes ([bg-wiki](https://www.bg-wiki.com/ffxi/Sprinter%27s_Shoes)).

### Taeon Boots

*Taeon Boots.*

- This copy is at or near max on each stone: Accuracy+25 (the Snowslit cap), Dual Wield +4 (Leaf cap +5) and STR+7 VIT+7 (the Dusk cap). Totals: Dual Wield +8 and Accuracy 32.
- Because the Dusk slot is used, it can't also have Phalanx received +3 ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Alluvion_Skirmish_Armor)).
- Dual Wield only does anything while a weapon is in the sub slot.
- BLU can only dual wield with Dual Wield from set blue magic. RDM has no Dual Wield trait and needs a /NIN or /DNC subjob ([bg-wiki](https://www.bg-wiki.com/ffxi/Dual_Wield)).

### Telchine Pigaches

*Telchine Pigaches.*

- "Regen" potency +3 is the Duskdim maximum.
- Telchine's Regen potency and Enhancing magic duration augments share the Dusk slot, so this copy has no duration augment (bg-wiki: [Alluvion Skirmish armor](https://www.bg-wiki.com/ffxi/Category:Alluvion_Skirmish_Armor), [Regen spells](https://www.bg-wiki.com/ffxi/Category:Regen_Spell)).
- Regen potency adds a flat +3 HP per tick, after any Embolden multiplier.
- RDM learns Regen at 21, so BLU/RDM can use it too (bg-wiki: [Regen spells](https://www.bg-wiki.com/ffxi/Category:Regen_Spell), [Regen](https://www.bg-wiki.com/ffxi/Regen)).

### Valorous Greaves

*Valorous Greaves. Not RDM or BLU.*

- Only WAR, PLD, DRK, BST, SAM and DRG can equip it ([bg-wiki](https://www.bg-wiki.com/ffxi/Valorous_Greaves)).

### Vanya Clogs

*Vanya Clogs. RDM, not BLU.*

- This copy has the full Nolan Path D: Cure potency 10% in total (5 base + 5), Cure spellcasting time -15% and Conserve MP+6.
- The casting time cut is read at precast and the potency at midcast ([bg-wiki](https://www.bg-wiki.com/ffxi/Vanya_Clogs)).
- Its Cure potency is the ordinary kind, capped at 50% in total. Cure potency II is a separate stat with a 30% cap ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Cure_Spell)).

### Viti. Boots +4

*Vitiation Boots +4. RDM only.*

- Enfeebling magic effect +10 raises potency by 10% (rounded down) for Addle, Blind, Distract, Frazzle, Gravity, Paralyze, Poison and Slow, and their higher tiers.
- On Dia it adds only to the damage over time, +1 HP per tick per point (+10 here), not to the defense down.
- It does nothing for Sleep, Bind, Silence or Break ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Enfeebling_Magic)).
- The Immunobreak augment adds +1% immunobreak chance per level of RDM's Group 2 Immunobreak Chance merit, up to +5%, on top of the merits' own 3% per level.
- Vanar's Group 2 merits (Enhancing Magic Duration 5, Magic Accuracy 5) fill all 10 of the group's levels (5 + 5 = 10). So he has no Immunobreak Chance merits, and this augment adds nothing for him (0 × 1% = 0%).
- Immunobreak can only happen when Bind, Blind, Break, Gravity, Paralyze, Poison, Silence, Sleep or Slow (or a higher tier) is resisted (bg-wiki: [Viti. Boots +4](https://www.bg-wiki.com/ffxi/Viti._Boots_%2B4), [Enfeebling Magic](https://www.bg-wiki.com/ffxi/Category:Enfeebling_Magic)).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Casting (Free Nuke, Magic Burst).

No notes beyond the help text: Battlecast Gaiters, Kheper Gamashes, Psycloth Boots, Ziamet Nails.

## Pieces the simulated sets use that Vanar doesn't own

Gear in bg-wiki's simulated sets ([Red Mage](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets/Red_Mage), [Blue Mage](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets/Blue_Mage)) that isn't in the 2026-10-01 export. Names are as the pages print them. A bracket gives the path the page names, or a cape's stat and main augment. What the sets assume is in [ffxi-mechanics.md](ffxi-mechanics.md#simulated-sets-bg-wiki-all-jobs-gear-sets).

**RDM**

| Piece | Sets that use it |
|---|---|
| Alabaster Mantle | Imperator, Ruthless Stroke |
| Anu Torque | Naegling + Thibron TP |
| Archduke's Sword | EnSpell |
| Archon Ring | Sanguine Blade |
| Aurgelmir Orb +1 | Naegling + Thibron TP |
| Aya. Manopolas +2 | EnSpell |
| Baetyl Pendant | Sanguine Blade |
| Begrudging Ring | Chant du Cygne, Evisceration |
| Blistering Sallet +1 | Chant du Cygne, Evisceration |
| Cacoethic Ring +1 | Chant du Cygne |
| Caliburnus (Level 119 II) | Imperator |
| Chirich Ring +1 | Naegling + Thibron TP |
| Crepuscular Knife | Knights of Round, Mercy Stroke |
| Crepuscular Pebble | Black Halo, Death Blossom, Imperator, Knights of Round, Mercy Stroke, Requiescat, Ruthless Stroke, Savage Blade |
| Crocea Mors | EnSpell |
| Crocea Mors [Path C] | Red Lotus Blade, Sanguine Blade, Seraph Blade |
| Daybreak | Requiescat, Seraph Blade |
| Dls. Torque +2 | Black Halo, Death Blossom, Imperator, Savage Blade |
| Ea Hat +1 | Casting |
| Ea Houppe. +1 | Casting |
| Ea Slops +1 | Casting |
| Eabani Earring | Naegling + Thibron TP |
| Excalibur (Level 119 III) | Knights of Round |
| Freke Ring | Aeolian Edge, Casting, Red Lotus Blade |
| Ghastly Tathlum +1 | Casting |
| Hetairoi Ring | Chant du Cygne |
| Hoxne Earring | Black Halo, Chant du Cygne, Death Blossom, Evisceration, Imperator, Knights of Round, Mercy Stroke, Requiescat, Ruthless Stroke, Savage Blade |
| Ilabrat Ring | Imperator, Ruthless Stroke |
| Malignance Earring | Aeolian Edge, Casting, Red Lotus Blade, Sanguine Blade, Seraph Blade |
| Malignance Gloves | Chant du Cygne, Death Blossom, Evisceration, Mercy Stroke, Requiescat, Ruthless Stroke |
| Malignance Tabard | Chant du Cygne, Evisceration |
| Mandau (Level 119 III) | Mercy Stroke |
| Metamor. Ring +1 | Casting, Death Blossom, Imperator, Requiescat |
| Moepapa Medal | Ruthless Stroke |
| Mujin Band | Casting |
| Murgleis (Level 119 III) | Death Blossom |
| Null Masque | Requiescat |
| Orpheus's Sash | Aeolian Edge, EnSpell, Red Lotus Blade, Sanguine Blade, Seraph Blade |
| Pixie Hairpin +1 | Sanguine Blade |
| Regal Earring | Casting, Sanguine Blade |
| Reiki Yotai | Naegling + Thibron TP |
| Rufescent Ring | Requiescat |
| Sakpata's Sword | Death Blossom, Knights of Round, Requiescat |
| Sequence | Requiescat |
| Skrymir Cord +1 | Casting |
| Sroda Ring | Black Halo, Death Blossom, Knights of Round, Mercy Stroke, Requiescat, Ruthless Stroke, Savage Blade |
| Sroda Tathlum | Aeolian Edge, Casting, EnSpell, Red Lotus Blade, Sanguine Blade, Seraph Blade |
| Sucellos's Cape [DEX, Crit Rate] | Chant du Cygne, Evisceration |
| Sucellos's Cape [DEX, Store TP] | Naegling + Thibron TP |
| Sucellos's Cape [DEX, Weapon Skill Damage] | Imperator |
| Sucellos's Cape [INT, Weapon Skill Damage] | Aeolian Edge |
| Sucellos's Cape [MND, Weapon Skill Damage] | Black Halo, Requiescat, Sanguine Blade |
| Sworn Brais | EnSpell, Naegling + Thibron TP |
| Sworn Crown | EnSpell |
| Sworn Gauntlets | Naegling + Thibron TP |
| Sworn Platemail | Chant du Cygne, EnSpell, Evisceration, Naegling + Thibron TP |
| Sworn Sabatons | Chant du Cygne, EnSpell, Naegling + Thibron TP, Requiescat |
| Thereoid Greaves | Evisceration |
| Weather. Ring +1 | Seraph Blade |
| Yetshila +1 | Chant du Cygne, Evisceration |
| Zoar Subligar +1 | Chant du Cygne, Evisceration |

**BLU**

| Piece | Sets that use it |
|---|---|
| Adhemar Bonnet +1 [Path B] | Chant du Cygne |
| Adhemar Wrist. +1 | Tizona + Thibron AM3 TP |
| Adhemar Wrist. +1 [Path A] | Caliburnus + Thibron AM1 TP |
| Adhemar Wrist. +1 [Path B] | Chant du Cygne |
| Alabaster Mantle | Imperator |
| Archduke's Sword | Sanguine Blade |
| Archon Ring | Sanguine Blade |
| Aurgelmir Orb +1 | Tizona + Thibron AM3 TP |
| Baetyl Pendant | Red Lotus Blade |
| Begrudging Ring | Chant du Cygne |
| Beithir Ring | Expiacion, Imperator, Red Lotus Blade, Savage Blade |
| Caliburnus (Level 119 II) | Caliburnus + Thibron AM1 TP, Imperator |
| Chirich Ring +1 | Caliburnus + Thibron AM1 TP, Tizona + Thibron AM3 TP |
| Crepuscular Pebble | Expiacion, Imperator, Requiescat, Savage Blade |
| Dedition Earring | Caliburnus + Thibron AM1 TP |
| Eabani Earring | Tizona + Thibron AM3 TP |
| Ghastly Tathlum +1 | Red Lotus Blade, Sanguine Blade |
| Hoxne Earring | Chant du Cygne, Expiacion, Imperator, Requiescat, Sanguine Blade, Savage Blade |
| Ice Brand | Red Lotus Blade, Sanguine Blade |
| Metamor. Ring +1 | Requiescat |
| Null Masque | Requiescat |
| Null Shawl | Caliburnus + Thibron AM1 TP, Tizona + Thibron AM3 TP |
| Odr Earring | Chant du Cygne |
| Orpheus's Sash | Red Lotus Blade, Sanguine Blade |
| Petrov Ring | Caliburnus + Thibron AM1 TP |
| Regal Earring | Red Lotus Blade, Sanguine Blade |
| Reiki Yotai | Caliburnus + Thibron AM1 TP, Tizona + Thibron AM3 TP |
| Rosmerta's Cape [DEX, Dual Wield] | Caliburnus + Thibron AM1 TP |
| Rosmerta's Cape [DEX, Store TP] | Tizona + Thibron AM3 TP |
| Rosmerta's Cape [DEX, Weapon Skill Damage] | Imperator |
| Rosmerta's Cape [INT, Weapon Skill Damage] | Red Lotus Blade, Sanguine Blade |
| Rosmerta's Cape [MND, DA] | Requiescat |
| Rufescent Ring | Requiescat |
| Sakpata's Sword | Requiescat |
| Sequence | Red Lotus Blade, Requiescat |
| Sroda Ring | Expiacion, Requiescat, Savage Blade |
| Sworn Brais | Caliburnus + Thibron AM1 TP, Tizona + Thibron AM3 TP |
| Sworn Crown | Caliburnus + Thibron AM1 TP, Tizona + Thibron AM3 TP |
| Sworn Gauntlets | Requiescat, Tizona + Thibron AM3 TP |
| Sworn Platemail | Caliburnus + Thibron AM1 TP, Tizona + Thibron AM3 TP |
| Sworn Sabatons | Caliburnus + Thibron AM1 TP, Requiescat, Tizona + Thibron AM3 TP |
| Thereoid Greaves | Chant du Cygne |
| Windbuffet Belt +1 | Caliburnus + Thibron AM1 TP |
| Zantetsuken | Chant du Cygne |

- Capes: of the sims' Ambuscade capes, Vanar's Sucellos's Capes match only the STR, Weapon Skill Damage one (the Seraph Blade and Red Lotus Blade sims may use its Magic Accuracy and Magic Damage version) and come nearest to the INT, Magic Attack one (INT+20 and Magic Accuracy+10 where the sims' cape has INT+30). His Rosmerta's Capes match only the STR, Weapon Skill Damage and DEX, Crit Rate ones. See [Sucellos's Cape](#sucelloss-cape) and [Rosmerta's Cape](#rosmertas-cape).
- Staged weapons: the sims use Almace Level 119 III and Mpu Gandring Level 119 II. The export doesn't show Vanar's stage of either, so neither is listed here; see [Almace](#almace) and [Mpu Gandring](#mpu-gandring). Vanar's Tizona is Level 119 III like the sims', because only that stage takes its `'Path: A'` augment.
- Lower versions Vanar does own: `Dls. Torque +1` (the sims use the +2), the NQ `Adhemar Bonnet` and `Adhemar Wristbands` (the sims use the +1s), and the NQ `Ea Houppelande` (the sims use `Ea Houppe. +1` in RDM Casting (Magic Burst)).
- Odyssey pieces Vanar owns at a lower rank than the sims' are in their entries, not here: every Nyame, Bunzi's and Gleti's piece the sims use.
