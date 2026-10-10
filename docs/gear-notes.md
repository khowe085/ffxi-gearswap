# Gear notes

For agents that build gear sets from a character's `//gs export`. The export lists only each item's name and augments. Each item's in-game help text, called "help text" below, is in Windower's item resources (`res/item_descriptions.lua`, matched by item ID); bg-wiki's item pages show the same text. These notes add what those don't: hidden values, set bonuses, conditions, slot and hand restrictions, and which set a piece belongs in. They hold for any copy of an item. What holds for one character's copies is in that character's `data/<Character>/<Character>_gear_notes.md`, under the same headings: what each augmented copy is for, each path item's rank, which of the character's other pieces beats a piece, and what the character lacks.

- **Coverage.** Every equippable piece in a character's bags that has something not obvious from its help text gets an entry under its slot. The pieces with nothing to add are named in the "No notes beyond the help text" line at the end of each slot. Gear on storage slips, which exports list in `slip<N>` tables, has no entries yet, so read a slip piece's bg-wiki page before putting it in a set.
- **Sources.** bg-wiki item and set pages, read on 2026-10-01 and 2026-10-02, plus FFXIclopedia where a note links it. A second agent checked every note against the page it cites. The RahvinGS gear library, [GearSets-Include.lua](https://github.com/khowe085/rahvin-gearswap/blob/a36cbf6/RahvinGS/GearSets-Include.lua), was used for leads only, never as a source.
- **Reading an entry.** The italic line under each heading gives the item's full name and, where it matters, which of RDM and BLU can wear it.
- **Companion docs.** [ffxi-mechanics.md](ffxi-mechanics.md) has the mechanics these notes rely on (fast cast, recast, duration, potency, caps). [rank-augments.md](rank-augments.md) has every rank's augments for the Odyssey pieces and the other path items in its table, and only the top-rank values for the items Oboro ranks up: `Dls. Torque +1`, `Mirage Stole +2`, `Tizona`, `Almace` and `Pukulatmuj +1` ([Oboro rank augments](rank-augments.md#oboro-rank-augments-maximum-only)).
- **Refresh terms.** "Refresh +X" is MP the wearer gets every tick while the piece is on. "Refresh potency" is a bonus for whoever receives a Refresh spell the wearer casts.
- **Staged weapons.** `//gs export` prints the same name for every stage of a staged weapon, so it doesn't show the stage. Every stage's item ID shares that name, so the help text a lookup by name finds may not be the held stage's. This affects `Almace`, `Tizona` and `Mpu Gandring`; their entries say what the stages differ in.
- **Simulated sets and wsdist.** An entry also lists the bg-wiki simulated sets (All Jobs Gear Sets) that wear the piece, and any error wsdist, the simulator that built them, makes with the piece (line numbers are at wsdist commit d12ac59). What the simulations assume is in [ffxi-mechanics.md](ffxi-mechanics.md#simulated-sets-bg-wiki-all-jobs-gear-sets), and wsdist itself in [its section there](ffxi-mechanics.md#wsdist-kastras-damage-simulator).

## Contents

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

## Armor sets and set bonuses

Set bonuses for the gear these notes cover. Each set below was checked on its bg-wiki page on 2026-10-02. The help text agrees: of the items covered, only these carry a `Set:` line.

How every set bonus works:

- The game counts the set pieces you have on at the moment it reads the stat. Pieces split between two GearSwap sets don't add up.
- So the pieces go in the set that is on at that moment. That means precast for casting time, and midcast for anything a spell reads when it lands (magic accuracy, duration, potency, damage). For melee, it means the engaged or weapon skill set.
- Each piece counts once. Past the top step, more pieces add nothing.
- A set bonus is only worth its slots if the total beats what other pieces would give in those slots. Compare whole sets, each piece's own stats included.

| Set | Bonus |
|---|---|
| [Atrophy](#atrophy-set) (RDM) | Accuracy, Ranged Accuracy and Magic Accuracy +15 per step |
| [Assimilator's](#assimilators-set) (BLU) | Accuracy, Ranged Accuracy and Magic Accuracy +15 per step |
| [Lethargy](#lethargy-set) (RDM) | Duration of enfeebles and of enhancing magic on others, with Composure |
| [Hashishin](#hashishin-set) (BLU) | Chance to triple a blue magic spell's WSC |
| [Jhakri](#jhakri-set) | Fast Cast +3% per step |
| [Serpentes](#serpentes-set) | Cure potency +5% |
| [Bladeborn and Steelflash](#bladeborn-and-steelflash-set) | Double Attack +7% |
| [Dudgeon and Heartseeker](#dudgeon-and-heartseeker-set) | Dual Wield +7% |
| [Lifestorm and Psystorm](#lifestorm-and-psystorm-set) | Magic Accuracy +12 |
| [Ayanmo](#ayanmo-set) | STR, VIT and MND +8 per step |
| [Amalric](#amalric-set) | Magic Atk. Bonus +20 for two pieces, +10 for each one more |
| [Carmine](#carmine-set) | Accuracy +20 for two pieces, +10 for each one more |
| [Adhemar](#adhemar-set) | Critical hit rate +4% for two pieces, +2% for each one more |
| [Rubeus](#rubeus-set) | Fast Cast +4% for two pieces, +10% for four |
| [Estoqueur's](#estoqueurs-set) | The Lethargy bonus, from +2 pieces only |
| [Regal](#regal-set) | One more piece toward an Artifact +2, +3 or +4 set |

### Atrophy set

RDM artifact armor. ([bg-wiki](https://www.bg-wiki.com/ffxi/Atrophy_Armor_Set))

| Pieces worn | Accuracy, Ranged Accuracy and Magic Accuracy |
|---|---|
| 2 | +15 |
| 3 | +30 |
| 4 | +45 |
| 5 or more | +60 |

- **What counts:** Atrophy +2, +3 and +4 pieces. NQ and +1 Atrophy have no set bonus. A Regal Earring counts as one more piece (see [Regal](#regal-set)). bg-wiki says +2 and +3 pieces mix ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Reforged_Artifact_Armor_%2B3)).
- **When:** whenever the stat is used. Put the pieces in the midcast set for magic accuracy on spells, or in the engaged or weapon skill set for melee accuracy.
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
- **Mixing tiers (unconfirmed for +4):** bg-wiki says +2 and +3 pieces mix. It gives the +4 tier the same bonus, but it never says that +4 pieces mix with +2 and +3 pieces. It very likely does (about 85%), but no source states it. A test in game would settle it: with a +4 piece and a +2 or +3 piece both on, Accuracy should be 15 higher than the two pieces' own Accuracy adds up to.
- **When:** whenever the stat is used. Put the pieces in the midcast set for magic accuracy on blue magic, or in the engaged or weapon skill set for melee accuracy.
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
- **Composure:** treat Composure as required. bg-wiki only presents the bonus as an augment to Composure: the set line says so, and the Composure page lists the set under equipment that modifies the ability. Neither page says outright that it does nothing without Composure. FFXIclopedia's Composure page lists the bonus as part of Composure's effect.

### Estoqueur's set

RDM empyrean armor from before Lethargy. ([bg-wiki](https://www.bg-wiki.com/ffxi/Estoqueur%27s_Attire_Set))

- Only the +2 tier has a set bonus. It is the same Composure bonus as Lethargy (+10/20/35/50% for 2/3/4/5 pieces), and +2 pieces count together with Lethargy pieces.
- `Estq. Earring` has the Estoqueur's name, but it isn't part of the set and has no set line, so it adds nothing to the Lethargy count.

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

### Serpentes set

Two pieces, worn by WHM, BLM, RDM, BRD, SMN, BLU, SCH and GEO. Level 80, with no item level. bg-wiki has no page for the set; the set line is on both item pages ([bg-wiki](https://www.bg-wiki.com/ffxi/Serpentes_Cuffs), [bg-wiki](https://www.bg-wiki.com/ffxi/Serpentes_Sabots)).

| Pieces worn | Bonus |
|---|---|
| Cuffs and Sabots | "Cure" potency +5% |

- The +5% is for the pair, not +5% from each piece. FFXIclopedia's set summary lists it once ([FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Serpentes_Armor_Set)). It is ordinary Cure potency, inside the 50% cap.
- **When:** in the Cure midcast set.
- Their latents are mirror images. The Cuffs give Regen by day and Refresh by night, and the Sabots give Refresh by day and Regen by night. Together they give Regen and Refresh at all hours.

### Bladeborn and Steelflash set

Two earrings, all jobs, level 99 with no item level. ([bg-wiki](https://www.bg-wiki.com/ffxi/Bladeborn_Earring), [bg-wiki](https://www.bg-wiki.com/ffxi/Steelflash_Earring))

| Pieces worn | Bonus |
|---|---|
| Both earrings | "Double Attack" +7% |

- The 7% is for the pair, not 7% from each earring. bg-wiki's Double Attack page lists the pair as one 7% source ([bg-wiki](https://www.bg-wiki.com/ffxi/Double_Attack)). Either earring alone gives only its own stats.
- **When:** in the engaged and weapon skill sets. Double Attack can go off up to twice per weapon skill (bg-wiki, Double Attack). The pair takes both ear slots.

### Dudgeon and Heartseeker set

Two earrings, all jobs, level 99 with no item level. ([bg-wiki](https://www.bg-wiki.com/ffxi/Dudgeon_Earring), [bg-wiki](https://www.bg-wiki.com/ffxi/Heartseeker_Earring))

| Pieces worn | Bonus |
|---|---|
| Both earrings | "Dual Wield" +7% |

- The 7% is for the pair. Either earring alone gives only its own stats.
- **When:** in the engaged set, and only while dual wielding. The pair takes both ear slots. `Suppanomimi` gives Dual Wield +5% from one ear.

### Lifestorm and Psystorm set

Two earrings, all jobs, level 99 with no item level. ([bg-wiki](https://www.bg-wiki.com/ffxi/Lifestorm_Earring), [bg-wiki](https://www.bg-wiki.com/ffxi/Psystorm_Earring))

| Pieces worn | Bonus |
|---|---|
| Both earrings | Magic Accuracy +12 |

- Each earring's text says `Set: Magic Accuracy+12`, and bg-wiki doesn't say whether that is +12 in total or +12 from each. The other earring pairs list their total, so +12 in total is the likely reading. That reading is unconfirmed.
- On their own, each earring has Enmity-1, and Lifestorm has MND+4 and Psystorm INT+4.
- **When:** in the midcast set, where magic accuracy is read. The pair takes both ear slots.

### Ayanmo set

Ambuscade armor. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Ambuscade_Rewards#Ayanmo_Armor_Sets))

| Pieces worn | STR, VIT and MND |
|---|---|
| 2 | +8 |
| 3 | +16 |
| 4 | +24 |
| 5 or 6 | +32 |

- **What counts:** Ayanmo +2 armor and the Ayanmo Ring. NQ and +1 armor don't count ([bg-wiki](https://www.bg-wiki.com/ffxi/Ayanmo_Ring)).

### Amalric set

([bg-wiki](https://www.bg-wiki.com/ffxi/Amalric_Attire_Set))

| Pieces worn | "Magic Atk. Bonus" |
|---|---|
| 2 | +20 |
| 3 | +30 |
| 4 | +40 |
| 5 | +50 |

- Only Amalric +1 pieces have the bonus.

### Carmine set

([bg-wiki](https://www.bg-wiki.com/ffxi/Carmine_Armor_Set))

| Pieces worn | Accuracy |
|---|---|
| 2 | +20 |
| 3 | +30 |
| 4 | +40 |
| 5 | +50 |

- Only Carmine +1 pieces have the bonus.

### Adhemar set

([bg-wiki](https://www.bg-wiki.com/ffxi/Adhemar_Attire_Set))

| Pieces worn | Critical hit rate |
|---|---|
| 2 | +4% |
| 3 | +6% |
| 4 | +8% |
| 5 | +10% |

- Only Adhemar +1 pieces have the bonus. NQ pieces have none.

### Rubeus set

([bg-wiki](https://www.bg-wiki.com/ffxi/Rubeus_Attire_Set))

| Pieces worn | Fast Cast |
|---|---|
| 2 or 3 | +4% |
| 4 or 5 | +10% |

### Regal set

The Regal accessories drop from Ou in Omen. Three of them carry a set line. It doesn't form a set of its own: it counts as one more piece toward any Reforged Artifact +2, +3 or +4 set, here [Atrophy](#atrophy-set) and [Assimilator's](#assimilators-set). The 5-piece cap of +60 still applies. ([bg-wiki](https://www.bg-wiki.com/ffxi/Regal_Earring), [bg-wiki](https://www.bg-wiki.com/ffxi/Category:Omen_Rewards))

- Of the three, only `Regal Earring` can be worn by RDM or BLU. Regal Ring is for melee jobs, and Regal Belt's bonus is for avatars only. The other Regal pieces have no set line.

### Sets with no set bonus

bg-wiki's set pages show no set bonus for these, and no help text of their items has a `Set:` line. Wearing several pieces together adds nothing beyond each piece's own stats and augments.

- Odyssey sets: Nyame ([bg-wiki](https://www.bg-wiki.com/ffxi/Nyame_Armor_Set)), Bunzi's ([bg-wiki](https://www.bg-wiki.com/ffxi/Bunzi%27s_Attire_Set)), Gleti's ([bg-wiki](https://www.bg-wiki.com/ffxi/Gleti%27s_Armor_Set)), and Sakpata's ([bg-wiki](https://www.bg-wiki.com/ffxi/Sakpata%27s_Armor_Set)).
  - Every Bunzi's and Gleti's armor piece's help text closes with a `Pet:` block: Accuracy, Ranged Accuracy and Magic Accuracy +50. Those are the pet's; bg-wiki's set pages list them as pet stats ([bg-wiki](https://www.bg-wiki.com/ffxi/Bunzi%27s_Attire_Set), [bg-wiki](https://www.bg-wiki.com/ffxi/Gleti%27s_Armor_Set)). The wearer's own values are Accuracy +40, Attack +40 and Magic Accuracy +40 per piece. The other lines after `Pet:` are the pet's too: Damage taken -8% on Gleti's Gauntlets, `Avatar: Lv.+1` on Bunzi's Sabots and `Summoned Pet: Lv.+1` on Gleti's Boots.
- Relic sets: Vitiation ([bg-wiki](https://www.bg-wiki.com/ffxi/Vitiation_Armor_Set)), Luhlaza ([bg-wiki](https://www.bg-wiki.com/ffxi/Luhlaza_Attire_Set)), Duelist's ([bg-wiki](https://www.bg-wiki.com/ffxi/Duelist%27s_Attire_Set)) and Mirage ([bg-wiki](https://www.bg-wiki.com/ffxi/Mirage_Attire_Set)). `Dls. Torque +1` and `Mirage Stole +2` are job necks and belong to no set.
- Other armor: Rawhide, Despair, Haruspex, Merlinic, Chironic, Herculean ([bg-wiki](https://www.bg-wiki.com/ffxi/Herculean_Armor_Set)), Telchine, Odyssean, Valorous, Vanya, Taeon, Psycloth, Gendewitha, Helios and Magna (the MG and MGM pieces). Each was checked on its bg-wiki set page.

## Weapons (main hand)

### Akademos

*Akademos. SCH only; not RDM or BLU.*

- wsdist: its only entry is "Akademos R15C", Nolan Path C at rank 15, which adds INT, Magic Accuracy and Magic Atk. Bonus +15 that an unaugmented copy lacks. The staff is SCH only, so it never enters a RDM or BLU run. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), line 131)

### Almace

*Almace.*

- The export prints only "Almace", a name nine items share, from the Level 80 stage (DMG:52, no stats) up to iL119 III, so the export can't tell which stage a character owns. ([bg-wiki](https://www.bg-wiki.com/ffxi/Almace), [bg-wiki](https://www.bg-wiki.com/ffxi/Almace_%28Level_80%29))
- The iL119 III stage has DMG:158, DEX+50, Magic Damage+186, Sword skill +269 and Magic Accuracy skill +255. ([bg-wiki](https://www.bg-wiki.com/ffxi/Almace_%28Level_119_III%29))
- The iL119 and iL119 II stages have DMG:114, DEX+20, Sword skill +242 and Magic Accuracy skill +215. ([bg-wiki](https://www.bg-wiki.com/ffxi/Almace_%28Level_119%29), [bg-wiki](https://www.bg-wiki.com/ffxi/Almace_%28Level_119_II%29))
- Chant du Cygne with Almace in the main hand gives an Aftermath. It procs only on Almace's own melee hits, Double and Triple Attack hits included, and never on weapon skills, Counters or Retaliations. ([bg-wiki](https://www.bg-wiki.com/ffxi/Empyrean_Aftermath))
- iL119 III's Aftermath triples damage on 30/40/50% of hits for 60/120/180 s at 1000-1999/2000-2999/3000 TP. iL119 and iL119 II double it for 30/60/90 s. The Level 80 stage has none. ([bg-wiki](https://www.bg-wiki.com/ffxi/Empyrean_Aftermath))
- TP Bonus doesn't raise the Aftermath tier, so Chant du Cygne at 1000 TP gives AM1 even with Thibron's TP Bonus +1000. ([bg-wiki](https://www.bg-wiki.com/ffxi/TP_Bonus))
- Any later Chant du Cygne overwrites AM1. AM2 yields only to AM3, and AM3 to nothing. ([bg-wiki](https://www.bg-wiki.com/ffxi/Aftermath))
- In the sub slot, Aftermath, Magic Accuracy skill and any REMA augment do nothing. ([bg-wiki](https://www.bg-wiki.com/ffxi/Dual_Wield))
- In the sub slot its DEX still counts for both hands (DEX+50 on iL119 III, +20 on iL119 and II; Accuracy from DEX is floor(DEX × 0.75)). Its DMG and Sword skill count only for its own off-hand hits. ([bg-wiki](https://www.bg-wiki.com/ffxi/Dual_Wield), [bg-wiki](https://www.bg-wiki.com/ffxi/Accuracy))
- RDM can hold it in the sub slot only with /NIN or /DNC for Dual Wield. ([bg-wiki](https://www.bg-wiki.com/ffxi/Dual_Wield))
- At rank 15 (max) the Ultimate Weapon (REMA) augment, which only the iL119 III stage takes, adds DMG+5, Chant du Cygne damage +10% and DEX/MND+20, all main hand only. A copy that shows no augment is rank 0, which says nothing about its stage. ([bg-wiki](https://www.bg-wiki.com/ffxi/BGWiki:Ultimate_Weapon_Augments), [rank-augments.md](rank-augments.md#oboro-rank-augments-maximum-only))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Chant du Cygne (Mid buff, High buff); Evisceration (Mid buff, High buff); BLU: Chant du Cygne (Mid buff, High buff). All of them assume Almace Level 119 III. In Evisceration it is the off hand, behind Tauret.
- wsdist: it has only the iL119 III stage. There is no iL119 or iL119 II entry (DMG 114, DEX+20), so a run overstates a copy that isn't III. Its "Almace R15 (sub)" entry also keeps the main-hand-only REMA DMG+5. "Select all File" keeps only the R15 entries, so a run loaded that way gives a copy with no REMA augment DMG+5, DEX and MND+20 and Chant du Cygne +10% in the main hand, and DMG+5 in the sub. "Import selections" can pick the plain "Almace" and "Almace (sub)" instead ([ffxi-mechanics.md](ffxi-mechanics.md#wsdist-kastras-damage-simulator), Getting a character's gear into the GUI). ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), lines 107-110; [gui_main.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gui_main.py), lines 490-491; [weapon_bonus.py](https://github.com/IzaKastra/wsdist_beta/blob/main/weapon_bonus.py), line 58)

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

- Its only path, Odyssey Path A, ranks up to 30; [rank-augments.md](rank-augments.md#bunzis-rod) gives every rank's values. ([bg-wiki](https://www.bg-wiki.com/ffxi/Bunzi%27s_Rod))
- Its Cure potency +30% counts toward the 50% Cure potency cap, not the separate 30% Cure potency II cap. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Cure_Spell))
- Its Cure potency also boosts blue magic heals such as Magic Fruit. ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Fruit))
- Its Magic burst damage +10 counts toward the 40% Magic Burst damage I cap. ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Burst))
- In the sub slot its Magic Accuracy skill +255 doesn't count, because only the main hand's does. Its DMG and Club skill count only for its own hits. ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Accuracy_Skill), [bg-wiki](https://www.bg-wiki.com/ffxi/Dual_Wield))
- In the sub slot, Accuracy+40, Magic Accuracy+40, Magic Atk. Bonus+35 and INT/MND+15 still apply. ([bg-wiki](https://www.bg-wiki.com/ffxi/Dual_Wield))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Sanguine Blade (Mid buff); Casting (Free Nuke, Magic Burst); BLU: Sanguine Blade (Mid buff, Ice Brand enabled). In Sanguine Blade it is the off hand.
- wsdist: its rank 0 entry has DMG 152 (144 plus the rank 15 +8); the base is 144. Only the rod's own physical hits are affected. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), line 102)

### Chac-chacs

*Chac-chacs.*

- Cosmetic only: swinging it shows music notes, the same effect as Maestro's Baton. It has no stats or combat use. ([bg-wiki](https://www.bg-wiki.com/ffxi/Chac-chacs))

### Chatoyant Staff

*Chatoyant Staff.*

- Hidden effects: Magic Accuracy+30 and magic potency +15% for every element, plus Iridescence 10%. ([bg-wiki](https://www.bg-wiki.com/ffxi/Chatoyant_Staff))
- Iridescence raises the weather bonus to 20% for single weather and 35% for double, and makes opposed-weather penalties larger too. An elemental obi forces the weather proc. Iridescence does nothing for the day bonus. ([bg-wiki](https://www.bg-wiki.com/ffxi/Iridescence))
- It has no item level, so it has no Magic Accuracy skill. As a staff it is two-handed, so it removes the sub. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Elemental_Staves), [bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Accuracy_Skill))
- Whether its hidden 15% boost also applies to Cures isn't settled on bg-wiki (Magic Fruit's page says light-affinity staves enhance it). ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Fruit), [bg-wiki](https://www.bg-wiki.com/ffxi/Cure_Formula))

### Chimeric Fleuret

*Chimeric Fleuret. RDM only.*

- The latent Double Attack +4% is on only while an Enspell buff is active. ([bg-wiki](https://www.bg-wiki.com/ffxi/Chimeric_Fleuret))
- Sword enhancement spell damage +7 adds only to this sword's own hits, and only while it is worn during the attack round. That makes it melee-time Enspell gear. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Enspell))

### Colada

*Colada.*

- Colada isn't Rare. With two copies, name each copy by its augments, because a bare "Colada" can equip either one. ([bg-wiki](https://www.bg-wiki.com/ffxi/Colada))
- Colada has Fast Cast +4% whatever its augments. It counts only when Colada is in the main hand at precast, so it helps casts started while Colada is the idle weapon, not casts started while engaged with other weapons. ([bg-wiki](https://www.bg-wiki.com/ffxi/Colada))

### Demers. Degen +1

*Demersal Degen +1. RDM, not BLU.*

- The "+25" in the help text is Dark resistance +25 (its icon is lost).
- Its Fast Cast +1 to 3% follows the Unity's weekly ranking (a higher rank gives more). Neither the export nor the help text shows the current value. ([bg-wiki](https://www.bg-wiki.com/ffxi/Demers._Degen_%2B1), [bg-wiki](https://www.bg-wiki.com/ffxi/Category:Unity_Concord))
- "Occasionally attacks twice" procs 45% of the time.
- Its melee hits are piercing, but its weapon skills stay slashing.
- At rank 15 its augment adds Accuracy and Magic Accuracy +45, DEX+10, and Sword enhancement spell damage +50% for this weapon's own Enspell hits. ([bg-wiki](https://www.bg-wiki.com/ffxi/Demers._Degen_%2B1))

### Enhancing Sword

*Enhancing Sword. RDM only.*

- The latent Accuracy+8 and Attack+16 need an Enspell buff active. ([bg-wiki](https://www.bg-wiki.com/ffxi/Enhancing_Sword))
- The +5 Enspell damage applies only to this sword's own hits, and only while it is worn during the attack round. That makes it melee-time Enspell gear. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Enspell))

### Fettering Blade

*Fettering Blade. RDM, not BLU.*

- In the sub slot, its Critical hit rate +4%, DMG and Sword skill count only for its own hits, and its Magic Accuracy skill +201 doesn't count at all.
- In the sub slot, STR/MND+12, Accuracy+27, Magic Accuracy+15 and Magic Atk. Bonus+14 apply to both hands. ([bg-wiki](https://www.bg-wiki.com/ffxi/Fettering_Blade), [bg-wiki](https://www.bg-wiki.com/ffxi/Dual_Wield))

### Gleti's Knife

*Gleti's Knife. RDM, not BLU.*

- Its only path, Odyssey Path A, ranks up to 30; [rank-augments.md](rank-augments.md#gletis-knife) gives every rank's values. ([bg-wiki](https://www.bg-wiki.com/ffxi/Gleti%27s_Knife))
- In the sub slot, its Critical hit rate +5%, DMG and Dagger skill apply only to Gleti's own hits: its off-hand swings and the extra off-hand weapon skill hit. So its Critical hit rate +5% doesn't raise Almace's or Tauret's crit rate.
- In the sub slot, its Magic Accuracy skill +242 doesn't count.
- In the sub slot, DEX/AGI+15, Accuracy+40, Attack+30, Magic Accuracy+40, Triple Attack+6% and Haste+2% apply to both hands.
- RDM needs /NIN or /DNC to dual wield it. ([bg-wiki](https://www.bg-wiki.com/ffxi/Dual_Wield), [bg-wiki](https://www.bg-wiki.com/ffxi/Gleti%27s_Knife))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Chant du Cygne (Mid buff, High buff); Mercy Stroke (Mid buff). In all three it is the off hand.
- wsdist: the stats are right at every rank, but in the sub slot its Critical hit rate +5% goes into one crit rate shared by both hands, so it also raises the main hand's melee and Chant du Cygne crits. ([create_player.py](https://github.com/IzaKastra/wsdist_beta/blob/main/create_player.py), lines 651-675)

### Heartbeater

*Heartbeater.*

- It isn't Rare.
- It's a stat-less 1-damage club with no RDM or BLU use. ([bg-wiki](https://www.bg-wiki.com/ffxi/Heartbeater))

### Ibushi Shinai

*Ibushi Shinai.*

- Its only use is the Feast of Swords seasonal event, where it absorbs the Armor's TP moves (Aetheral Toxin, Edge of Death).
- It has 1 charge, can be used 10 s after you equip it, and has a 15 s reuse. ([bg-wiki](https://www.bg-wiki.com/ffxi/Ibushi_Shinai))

### Iris

*Iris. BLU only.*

- Its Blue magic skill raises magical blue magic accuracy and potency and physical blue magic damage. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Blue_Magic))
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
- At Rank 15 its Unity/Odyssey augment adds Ranged Attack +20, Ranged Accuracy and Magic Accuracy +40 and Enmity -5. ([bg-wiki](https://www.bg-wiki.com/ffxi/Kustawi_%2B1))
- wsdist: its only entry is labeled R25, but the item ranks only to 15, and the values are rank 15's: Ranged Attack +20, Ranged Accuracy and Magic Accuracy +40 over an unaugmented copy. RDM and BLU can't equip it. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), line 174)

### Lightreaver

*Lightreaver. WAR only.*

- bg-wiki puts its Additional effect: Death at roughly 5% on ordinary monsters, a figure it flags as needing verification.
- bg-wiki says it never procs on NMs, Apex monsters, BCNMs, high-tier mission battlefields or Salvage. ([bg-wiki](https://www.bg-wiki.com/ffxi/Lightreaver))

### Marin Staff +1

*Marin Staff +1. RDM, not BLU.*

- Wind Elemental MAB +11 is 11% wind affinity. It works only on wind-element spells and sits in a separate damage multiplier from ordinary Magic Atk. Bonus, where it adds to Orpheus's Sash's affinity. ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Damage))
- The Unity INT bonus is between +10 and +15, depending on your Unity's faction rank, which is re-tallied every week. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Unity_Concord))
- At Rank 15 its Unity/Odyssey augment adds Magic Atk. Bonus +40, Accuracy and Magic Accuracy +40 and INT/MND +10. ([bg-wiki](https://www.bg-wiki.com/ffxi/Marin_Staff_%2B1))
- wsdist: its only entry is rank 15, which adds Magic Accuracy and Magic Atk. Bonus +40 and INT/MND +10 over a rank 0 copy, and assumes Unity INT +14. It also leaves out rank 15's Accuracy +40. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), line 100)

### Maxentius

*Maxentius.*

- The magic burst bonus is 4% per skillchain in the chain being burst: a two-weapon-skill chain gives 4%, and a four-weapon-skill chain to Double Light gives 12%. ([bg-wiki](https://www.bg-wiki.com/ffxi/Maxentius))
- The magic burst bonus works only in the main hand and counts toward the 40% Magic burst damage I cap. ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Burst))
- In the main hand it gives Black Halo with no club-skill or quest requirement. ([bg-wiki](https://www.bg-wiki.com/ffxi/Maxentius))
- Its +50% Black Halo damage applies to every hit, as a separate multiplier from weapon skill damage gear. ([bg-wiki](https://www.bg-wiki.com/ffxi/Weapon_Skill_Damage))
- In the sub slot its Black Halo, magic burst bonus and Magic Accuracy skill +250 do nothing, and its Club skill counts only for its own hits.
- In the sub slot, Accuracy and Magic Accuracy +40, Magic Atk. Bonus +21 and INT/MND/CHR +15 still count. ([bg-wiki](https://www.bg-wiki.com/ffxi/Dual_Wield))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Death Blossom (High buff); Black Halo (Mid buff, High buff); BLU: Requiescat (High buff). In Death Blossom and Requiescat it is the off hand.
- wsdist: it stores the burst bonus as a flat Magic burst damage +4 that also counts from the sub slot. In game it works only in the main hand, at 4% per skillchain. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), line 101)

### Mpu Gandring

*Mpu Gandring. RDM, not BLU.*

- Four prime-dagger stages share this name: Incomplete, Level 119, Level 119 II and Level 119 III. The export prints only the name, so the stage held is unknown. Item 21587, the Incomplete stage, is just the lowest ID with that name. ([bg-wiki](https://www.bg-wiki.com/ffxi/Mpu_Gandring))
- Incomplete: DMG 117, Dagger and Magic Accuracy skill +252, with no stats, Triple Attack or Aftermath. The other three add DEX/AGI/CHR, Accuracy and Magic Accuracy, Triple Attack and a Ruthless Stroke Aftermath. Level 119: DMG 124, stats +25, skills +260, Triple Attack +3%. Level 119 II: DMG 130, stats +30, skills +269, Triple Attack +4%. Level 119 III: DMG 137, stats +35, skills +277, Triple Attack +6%. (bg-wiki: [Incomplete](https://www.bg-wiki.com/ffxi/Mpu_Gandring_%28Incomplete%29), [Level 119](https://www.bg-wiki.com/ffxi/Mpu_Gandring_%28Level_119%29), [Level 119 II](https://www.bg-wiki.com/ffxi/Mpu_Gandring_%28Level_119_II%29), [Level 119 III](https://www.bg-wiki.com/ffxi/Mpu_Gandring_%28Level_119_III%29))
- The Incomplete stage's "Slowly devours your soul" drains 1 HP and 1 MP every tick and can kill you. A copy at that stage must never be left on in an idle set. The Level 119 stage's help text doesn't list it. ([bg-wiki](https://www.bg-wiki.com/ffxi/Mpu_Gandring_%28Incomplete%29))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Ruthless Stroke (Mid buff, High buff). Both assume Mpu Gandring Level 119 II.
- wsdist: it has only the Level 119 II ("Mpu Gandring IV") and 119 III ("V") stages, with no Incomplete or Level 119 entry. Its export import keeps "IV", so the dagger is simmed as Level 119 II. For a copy at the Incomplete stage, that adds DMG+13 and Dagger and Magic Accuracy skill +17, plus DEX/AGI/CHR +30, Accuracy and Magic Accuracy +30, Triple Attack 4%, a hidden damage proc and, given an aftermath level, prime aftermath PDL, none of which that stage has. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), lines 359-360; [actions.py](https://github.com/IzaKastra/wsdist_beta/blob/main/actions.py), lines 371-377; [create_player.py](https://github.com/IzaKastra/wsdist_beta/blob/main/create_player.py), lines 568-600)

### Naegling

*Naegling.*

- Its weapon skill attack bonus is +1% attack for each buff on you. It works only in the main hand and applies to every melee weapon skill, not just Savage Blade, but not to ranged weapon skills. ([bg-wiki](https://www.bg-wiki.com/ffxi/Naegling))
- In the main hand it gives Savage Blade with no skill or Old Wounds requirement. ([bg-wiki](https://www.bg-wiki.com/ffxi/Naegling))
- Its Savage Blade +15% applies to every hit, as a separate multiplier from weapon skill damage gear.
- Its Magic Damage +217 is not only for spells. bg-wiki's magical weapon skill formula adds the Magic Damage stat straight to base damage after fTP, and Magic Atk. Bonus multiplies it.
- So its Magic Damage and Magic Atk. Bonus +16 count for Sanguine Blade, Seraph Blade and Red Lotus Blade. Its weapon skill attack bonus does nothing for them. ([bg-wiki](https://www.bg-wiki.com/ffxi/Weapon_Skill_Damage))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Savage Blade (Mid buff, High buff); Naegling + Thibron TP (-50% DT, -25% DT); BLU: Savage Blade (Mid buff, High buff).

### Nibiru Cudgel

*Nibiru Cudgel.*

- Nibiru Cudgel is not Rare, so with two copies a set must name each copy by its augments. ([bg-wiki](https://www.bg-wiki.com/ffxi/Nibiru_Cudgel))

### Oynos Knife

*Oynos Knife. Not RDM or BLU.*

- Its Haste proc lasts the full 3 minutes and stays on after the knife is unequipped. ([bg-wiki](https://www.bg-wiki.com/ffxi/Oynos_Knife))

### Pukulatmuj +1

*Pukulatmuj +1.*

- Its Sword enhancement spell damage +11 adds only to the Enspell damage of Pukulatmuj's own hits, and only while it is worn during the attack round. It does nothing in a set worn just for the cast. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Enspell))
- At rank 15 (max) its Unity augment adds DMG +38, Accuracy and Magic Accuracy +30, and Sword enhancement spell damage +150%, which also counts only for this weapon's Enspell damage. ([bg-wiki](https://www.bg-wiki.com/ffxi/Pukulatmuj_%2B1), [rank-augments.md](rank-augments.md#oboro-rank-augments-maximum-only))
- Its Magic Accuracy skill +188 only counts in the main hand. ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Accuracy_Skill))
- wsdist: its only entry is rank 15, which adds DMG+36, Accuracy and Magic Accuracy +30 and Sword enhancement spell damage +150% over an unaugmented copy; bg-wiki gives the rank 15 DMG as +38. Its random-roll simulation also gives off-hand Enspell hits the main hand's Enspell damage %. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), line 133; [actions.py](https://github.com/IzaKastra/wsdist_beta/blob/main/actions.py), line 331)

### Ram Staff

*Ram Staff.*

- The Retrace enchantment has 1 charge, an 8 s cast, a 30 s equip delay and a 24-hour reuse. ([bg-wiki](https://www.bg-wiki.com/ffxi/Ram_Staff))

### Rounsey Wand

*Rounsey Wand.*

- The Teleport has an 8 s cast, a 30 s equip delay and a 7-day reuse.
- It only works if you have visited the Chocobo Circuit before. From there you can exit to Bastok, San d'Oria, Windurst or Jeuno, but not to Aht Urhgan Whitegate. ([bg-wiki](https://www.bg-wiki.com/ffxi/Rounsey_Wand))

### Secespita

*Secespita. RDM only.*

- Its Sword enhancement spell damage +8 adds only to the Enspell damage of its own hits, and only while it is worn during the attack round.
- In the sub slot that means tier I Enspells only: a tier II Enspell adds damage to the first main-hand hit of each round, never to off-hand hits. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Enspell), [bg-wiki](https://www.bg-wiki.com/ffxi/Dual_Wield))

### Serenity

*Serenity. RDM, not BLU.*

- It is a two-handed staff, so equipping it takes off the sub slot (shield or offhand weapon; only a grip can go with it) and resets TP. ([bg-wiki](https://www.bg-wiki.com/ffxi/Serenity), [FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Category:Grips))
- Its Cure potency is 25% before any augment, toward the 50% Cure potency cap. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Cure_Spell))
- Its Cure spellcasting time -8% only matters in precast. ([bg-wiki](https://www.bg-wiki.com/ffxi/Fast_Cast))
- bg-wiki lists the augment as MP+50, Enhancing magic skill +10, Cure potency +5% and Cure spellcasting time -10%. ([bg-wiki](https://www.bg-wiki.com/ffxi/Serenity))

### Tanmogayi +1

*Tanmogayi +1. BLU, not RDM.*

- Its Unity Ranking Fast Cast is +3% to +6%, set by the weekly ranking of the wearer's Unity (a higher rank gives more). ([bg-wiki](https://www.bg-wiki.com/ffxi/Tanmogayi_%2B1), [bg-wiki](https://www.bg-wiki.com/ffxi/Category:Unity_Concord))
- Rankings are tallied each week and apply to the following week, and only to members who earned at least a minimum number of accolades. Neither the export nor the help text shows the current value. ([FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Unity_Ranking))
- Swapping it into the main hand resets TP. ([mechanics](ffxi-mechanics.md#weapons-and-tp))
- Path A (added at Unity NPCs after Odyssey Sheol C) at rank 15 adds DMG +11, Accuracy and Magic Accuracy +40 and Attack +40. Accuracy and Magic Accuracy start at rank 6 and Attack at rank 11. ([bg-wiki](https://www.bg-wiki.com/ffxi/Tanmogayi_%2B1))
- Its Magic Accuracy skill +188 only counts in the main hand. ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Accuracy_Skill))
- wsdist: its only entry is rank 15, which adds DMG+11 and Accuracy, Magic Accuracy and Attack +40 over an unaugmented copy. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), line 310)

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
- A Thibron's augment is DMG +3 with TP Bonus +1000, with Weapon skill damage +10% or with Store TP +17. ([bg-wiki](https://www.bg-wiki.com/ffxi/Thibron))
- TP Bonus doesn't raise the Aftermath level, which counts actual TP only, so Expiacion at 1000 TP hits like 2000 but gives only Aftermath level 1. ([bg-wiki](https://www.bg-wiki.com/ffxi/Aftermath))
- Whether TP Bonus helps physical blue magic is disputed. The TP Bonus page says it does nothing, even under Chain Affinity or Azure Lore; the Moonshade Earring page says it can when Chain Affinity uses TP (bg-wiki: [TP Bonus](https://www.bg-wiki.com/ffxi/TP_Bonus), [Moonshade Earring](https://www.bg-wiki.com/ffxi/Moonshade_Earring); [ffxi-mechanics.md](ffxi-mechanics.md#physical-blue-magic)).
- In the sub slot it needs Dual Wield. BLU gets it from set blue magic; RDM has no Dual Wield trait and needs a NIN or DNC subjob. ([bg-wiki](https://www.bg-wiki.com/ffxi/Dual_Wield))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Savage Blade (Mid buff, High buff); Imperator (Mid buff, High buff); Red Lotus Blade (Mid buff); Ruthless Stroke (Mid buff, High buff); Black Halo (Mid buff, High buff); Aeolian Edge (Mid buff); Naegling + Thibron TP (-50% DT, -25% DT); BLU: Expiacion (Mid buff, High buff); Imperator (Mid buff, High buff); Savage Blade (Mid buff, High buff); Red Lotus Blade (Mid buff, Ice Brand enabled); Tizona + Thibron AM3 TP (-50% DT, -25% DT); Caliburnus + Thibron AM1 TP (-50% DT, -25% DT). The BLU page gives its Thibron as TP Bonus +1000.

### Thunder Hammer

*Thunder Hammer.*

- The Thunder enchantment does 100 damage when unresisted (bg-wiki marks this as unverified).
- It has a 2 s cast, a 30 s equip delay and a 10-minute reuse. ([bg-wiki](https://www.bg-wiki.com/ffxi/Thunder_Hammer))

### Tizona

*Tizona. BLU only.*

- "Path: A" exists only on the Oboro-augmented iLvl 119 III Tizona (DMG 147, Delay 236, Magic Accuracy +40, Magic Damage +186, Sword skill +269, Magic Accuracy skill +255), not on the level-75 version the help text shows. ([bg-wiki](https://www.bg-wiki.com/ffxi/Tizona_%28Level_119_III%29))
- Path A is the Ultimate Weapon (REMA) augment, and the only path. Only Level 119 III takes it, so a Tizona that exports with `'Path: A'` is Level 119 III. The export doesn't show the rank (1 to 15). At rank 15 (max) it gives DMG +18, Expiacion damage +15%, Accuracy +30 and Magic Accuracy +30, all main hand only. Below rank 15 it gives less, by amounts bg-wiki doesn't list. ([bg-wiki](https://www.bg-wiki.com/ffxi/BGWiki:Ultimate_Weapon_Augments), [rank-augments.md](rank-augments.md#oboro-rank-augments-maximum-only))
- Tizona has a hidden Expiacion damage +30% that multiplies with the rank-15 augment's +15%, for +49.5%. Both apply to every hit of Expiacion. ([bg-wiki](https://www.bg-wiki.com/ffxi/Tizona_%28Level_119_III%29))
- The MP drain procs on about 30% of normal melee hits (not weapon skills) and returns about 10-20% of that hit's damage as MP, even against monsters with no MP. ([bg-wiki](https://www.bg-wiki.com/ffxi/Tizona_%28Level_119_III%29))
- Expiacion Aftermath goes by actual TP only. Level 1 gives Accuracy floor(TP/50+10) (30-49) for 90 s. Level 2 gives Magic Accuracy 30-49 for 4.5 minutes. Level 3 makes attacks hit twice 40% or thrice 20% of the time for 3 minutes, and can also proc once on a physical weapon skill. ([bg-wiki](https://www.bg-wiki.com/ffxi/Mythic_Aftermath))
- Any Aftermath level overwrites level 1, only level 3 overwrites level 2, and nothing overwrites level 3. ([bg-wiki](https://www.bg-wiki.com/ffxi/Aftermath))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): BLU: Expiacion (Mid buff, High buff); Tizona + Thibron AM3 TP (-50% DT, -25% DT). Both assume Tizona Level 119 III.
- wsdist: it has only "Tizona" (no augment) and "Tizona R15" (DMG +18, Accuracy and Magic Accuracy +30, Expiacion +49.5% instead of +30%), and "Select all File" keeps only the R15 one. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), lines 163-164; [weapon_bonus.py](https://github.com/IzaKastra/wsdist_beta/blob/main/weapon_bonus.py), lines 87 and 108; [gui_main.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gui_main.py), lines 490-491)

### Treat Staff II

*Treat Staff II.*

- The Warp enchantment has 1 charge, an 8 s cast, a 30 s equip delay and a 20-hour reuse. ([bg-wiki](https://www.bg-wiki.com/ffxi/Treat_Staff_II))

### Twilight Knife

*Twilight Knife. RDM, not BLU.*

- The drain procs on about 5% of hits and splits HP 45%, MP 45%, TP 10%, for at most 45 HP, 45 MP or 10 TP.

### Warp Cudgel

*Warp Cudgel.*

- It is not Rare and holds 30 charges.
- Warp has an 8 s cast, only a 3 s equip delay and a 60 s reuse. That makes it a much faster repeat Warp than Treat Staff II (30 s equip delay, 20-hour reuse). ([bg-wiki](https://www.bg-wiki.com/ffxi/Warp_Cudgel))

### Wind Knife +1

*Wind Knife +1.*

- The Aero enchantment does 100 damage when unresisted (unverified on bg-wiki). It has a 2 s cast, a 30 s equip delay and a 10-minute reuse.
- The melee Wind proc fires about 80% of the time, but for very little damage. ([bg-wiki](https://www.bg-wiki.com/ffxi/Wind_Knife_%2B1))

No notes beyond the help text: Anahera Sword, Deathbane, Eosuchus Club, Extinction, Hofud, Iapetus, Kam'lanaut's Sword, Lament, Lehbrailg +2, Malignance Sword, Nehushtan, Nibiru Knife, Nihility, Sh. Moogle Rod, Soothsayer Staff, Taming Sari, Tokkosho, Twinned Blade.

## Shields and grips, ranged and ammo

### Ammurapi Shield

*Ammurapi Shield. RDM only.*

- Its `Enhancing magic duration +10%` is duration listed on gear; bg-wiki uses this shield as its example. It adds with other listed duration % and multiplies separately from augmented duration (Telchine, Ghostfyre).
- It counts when the spell lands, so it belongs in midcast.
- Changing the sub slot resets TP. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Enhancing_Magic))
- Whether a midcast set can put it on is up to the framework's weapon lock. Under Selindrile's, a locked weapon set keeps every other set's sub out of the slot, so a midcast set puts it on only with the weapons state at `None` or the lock off ([frameworks/sel.md](frameworks/sel.md#the-weapon-lock)).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Casting (Free Nuke, Magic Burst).

### Aureole

*Aureole.*

- A throwing weapon for the range slot. It takes no ammunition.
- Mismatched range and ammo items remove each other, so it can't be worn with a stat ammo such as Pemphredo Tathlum. ([FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Ammo))
- Equipping it in the range slot loses all TP. ([bg-wiki](https://www.bg-wiki.com/ffxi/Tactical_Points))

### Coiste Bodhar

*Coiste Bodhar.*

- Path A at max rank (30) adds Attack+15, STR+10 and DEX+10.
- Attack reaches +15 at rank 15. STR starts at rank 16 and DEX at rank 21. ([bg-wiki](https://www.bg-wiki.com/ffxi/Coiste_Bodhar))
- The export doesn't show a copy's rank. [rank-augments.md](rank-augments.md#coiste-bodhar) has every rank.
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Savage Blade (Mid buff); Death Blossom (Mid buff); Knights of Round (Mid buff); Imperator (Mid buff); Requiescat (Mid buff); Mercy Stroke (Mid buff); Ruthless Stroke (Mid buff); Black Halo (Mid buff); BLU: Expiacion (Mid buff); Chant du Cygne (Mid buff, High buff); Requiescat (Mid buff); Imperator (Mid buff); Savage Blade (Mid buff); Caliburnus + Thibron AM1 TP (-50% DT, -25% DT).
- wsdist: its rank 30 entry has DEX+5; rank 30 is DEX+10. Ranks 0 to 25 are right. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), line 456)

### Forfend +1

*Forfend +1. RDM only.*

- Path A at max rank (15) is Accuracy+15, Magic Accuracy+15 and Enhancing magic skill +10.
- The skill starts at rank 11, at +2 per rank, so a copy below rank 15 has +0 to +8. ([bg-wiki](https://www.bg-wiki.com/ffxi/Forfend_%2B1))
- The export doesn't show the rank. [rank-augments.md](rank-augments.md#forfend-1) has every rank.
- `Unity Ranking: Accuracy+10～20` depends on your Unity's weekly ranking. A higher-ranked Unity gives more, up to +20. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Unity_Concord))
- Like Ammurapi Shield, whether a midcast set can put it on is up to the framework's weapon lock ([frameworks/sel.md](frameworks/sel.md#the-weapon-lock)).

### Fulcio Grip

*Fulcio Grip.*

- A grip needs a two-handed main weapon.

### Genbu's Shield

*Genbu's Shield.*

- The two unlabeled numbers in the help text are element icons: Fire resistance -10 and Earth resistance +10. ([bg-wiki](https://www.bg-wiki.com/ffxi/Genbu%27s_Shield))
- Its Physical damage taken -10% is plain PDT. It adds with Damage taken -% toward the same -50% physical cap, so it does nothing in a set already at -50% physical. ([bg-wiki](https://www.bg-wiki.com/ffxi/Damage_Taken))
- The Synergy augments (Genbu Scrap) go up to Cure potency +5%, Cure spellcasting time -8%, Magic Accuracy+6, HP+25 and MP+32. ([bg-wiki](https://www.bg-wiki.com/ffxi/Genbu%27s_Shield))

### Hasty Pinion

*Hasty Pinion.*

- Its Haste+1% is gear haste, which shortens spell recast. So it belongs in a midcast set, where its Store TP -5 costs nothing. ([bg-wiki](https://www.bg-wiki.com/ffxi/Spell_Recast))
- It can be the last 1% toward 26% of listed gear haste, the total the player treats as the 256/1024 cap. ([ffxi-mechanics.md](ffxi-mechanics.md#haste))

### Impatiens

*Impatiens.*

- `Occ. quickens spellcasting +2%` is Quick Magic: 2% of spells cast instantly, with no casting or recast time.
- Quick Magic caps at 10%.
- On RDM, job points add a Conserve MP-style effect when Quick Magic goes off. ([bg-wiki](https://www.bg-wiki.com/ffxi/Occasionally_Quickens_Spellcasting))

### Incantor Stone

*Incantor Stone. WHM, PLD and SCH only; not RDM or BLU.*

- The unstated Fast Cast is +2%. ([bg-wiki](https://www.bg-wiki.com/ffxi/Incantor_Stone))

### Majorelle Shield

*Majorelle Shield. WAR, PLD and DRK only; not RDM or BLU.*

- The unstated Fast Cast is +5%. ([bg-wiki](https://www.bg-wiki.com/ffxi/Majorelle_Shield))

### Mavi Tathlum

*Mavi Tathlum. BLU only.*

- `Increases breath damage` is breath damage +5%, for BLU's breath spells such as Thunder Breath or Wind Breath.
- Blue Magic skill +5 raises the accuracy and potency of magical blue magic and goes into physical blue magic damage.
- Physical spell accuracy comes from Accuracy, DEX and the main weapon, not from skill. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Blue_Magic))

### Mephitis Grip

*Mephitis Grip.*

- A grip needs a two-handed main weapon, which on RDM or BLU means a staff.

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

No notes beyond the help text: Amar Cluster, Archduke's Shield, Ark Shield, Ginsen, Honed Tathlum, Hydrocera, Savant's Treatise, Tsoa. Crossbow, Twinned Shield.

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
- Set bonus: Amalric, see [Amalric set](#amalric-set) ([bg-wiki](https://www.bg-wiki.com/ffxi/Amalric_Attire_Set)).
- wsdist: its only entry is Nolan Path A at max, Magic Accuracy and Magic Atk. Bonus +20. Against a Path C copy that is 20 MAB high and 11 INT low, and Magic Accuracy 3 high on nukes (Path C's Elemental magic skill +17 is missing) and 20 high on magical weapon skills. The Magic Accuracy gap matters only against an enemy given Magic Evasion; every wsdist preset, the sims' "BG Wiki sets" included, has 0 ([ffxi-mechanics.md](ffxi-mechanics.md#where-wsdist-and-bg-wiki-disagree)). Its Amalric set-bonus code is right. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), line 620)

### Anwig Salade

*Anwig Salade. BLU, not RDM.*

- It is a level 75 piece with no item level.
- Its augments are two picks from a fixed menu: STR+4 with Weapon Skill Accuracy+15, and Accuracy+10 with Attack+5.
- Weapon Skill Accuracy only counts on physical weapon skills.

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

- Its only path, Odyssey Path A, adds Attack, Magic Damage and Store TP from rank 1, Accuracy and Magic Accuracy from rank 16, and Quadruple Attack from rank 21. For the values at each rank, see [rank-augments.md](rank-augments.md#bunzis-hat) ([bg-wiki](https://www.bg-wiki.com/ffxi/Bunzi%27s_Hat)).
- Magic burst damage +7 is the 40%-capped kind, not Magic burst damage II ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Burst)).
- No set bonus ([bg-wiki](https://www.bg-wiki.com/ffxi/Bunzi%27s_Attire_Set)).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Naegling + Thibron TP (-50% DT, -25% DT).

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

### Gleti's Mask

*Gleti's Mask. BLU, not RDM.*

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

- Oseem's magic path can add Fast Cast +1 to +5 (+6 with a Fern Stone) and Magic Attack Bonus up to +35.
- Dark Matter can add rarer augments, such as Treasure Hunter +1 to +2 or Refresh +1 to +2 (bg-wiki: [Arcane Glyptics Inscription](https://www.bg-wiki.com/ffxi/Category:Escha_Rewards/Arcane_Glyptics_Inscription), [Herculean Helm](https://www.bg-wiki.com/ffxi/Herculean_Helm)).

### Jhakri Coronal +2

*Jhakri Coronal +2.*

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
- The augment needs Convergence, a merit ability, so it does nothing without Convergence merits. The breath damage below still counts.
- Breath damage dealt +20% does apply to blue magic breath spells: bg-wiki's Bad Breath page says breath-damage gear enhances it.

### Merlinic Hood

*Merlinic Hood. RDM, not BLU.*

- The hood isn't Rare, so with two copies GearSwap must name each copy by its augments ([bg-wiki](https://www.bg-wiki.com/ffxi/Merlinic_Hood)).

### Nyame Helm

*Nyame Helm.*

- Path B's Accuracy augment only starts at rank 21, so a copy below rank 21 has none. For the other ranks and paths, see [rank-augments.md](rank-augments.md#nyame-helm) ([bg-wiki](https://www.bg-wiki.com/ffxi/Nyame_Helm)).
- Breath spells deal damage from current HP. Its HP+91 only adds breath damage if HP is already full with the helm on before the cast. A BLU guide on bg-wiki says HP gear needs full HP to count (bg-wiki: [Bad Breath](https://www.bg-wiki.com/ffxi/Bad_Breath), [Blue Magic Guide by Sabishii](https://www.bg-wiki.com/ffxi/Azure_Tomes:_Blue_Magic_Guide_by_Sabishii)).
- White Wind heals from max HP, so the helm's HP counts there even when it only goes on at midcast ([bg-wiki](https://www.bg-wiki.com/ffxi/White_Wind)).
- Magic burst damage +5 is the 40%-capped kind ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Burst)).
- Magic burst damage II comes only from Path C, so a Path B copy has none ([bg-wiki](https://www.bg-wiki.com/ffxi/Nyame_Helm)).
- No set bonus ([bg-wiki](https://www.bg-wiki.com/ffxi/Nyame_Armor_Set)).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Mercy Stroke (Mid buff, High buff); Ruthless Stroke (High buff).

### Rawhide Mask

*Rawhide Mask. BLU, not RDM.*

- No set bonus ([bg-wiki](https://www.bg-wiki.com/ffxi/Rawhide_Armor_Set)).

### Sukeroku Hachi.

*Sukeroku Hachimaki.*

- Weapon Skill Accuracy +30 only counts on physical weapon skills, not on Sanguine Blade or other magical weapon skills ([bg-wiki](https://www.bg-wiki.com/ffxi/Accuracy)).
- Conserve TP +8 is an 8% chance per weapon skill to keep 10 to 200 TP ([bg-wiki](https://www.bg-wiki.com/ffxi/Conserve_TP)).

### Telchine Cap

*Telchine Cap.*

- "Enh. Mag. eff. dur. +10" is augmented duration, so it multiplies separately from the duration % that gear lists natively.
- +10 is the Dusk-stone maximum.
- Regen potency comes from the same Dusk slot, so a copy can't have both.

### Vanya Hood

*Vanya Hood. RDM, not BLU.*

- The base hood has no Fast Cast.

### Viti. Chapeau +4

*Vitiation Chapeau +4. RDM only.*

- Both augments scale with RDM Group 2 merits.
- Enfeebling Magic duration adds 3 seconds of enfeebling duration per Enfeebling Magic Duration merit level (15 seconds at 5).
- Magic Accuracy adds Macc +3 per Magic Accuracy merit level (+15 at 5). The merit itself adds +5 a level.
- The augment reads only that Group 2 merit. Group 1 merits, such as Ice and Earth magic accuracy, are a separate bonus for those elements' spells and don't raise it.
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
- The help text names the condition `Citizen of San d'Oria`, so the Regen works only for a citizen of San d'Oria. Its DT -5% and VIT+10 work for anyone.

### Enhancing Torque

*Enhancing Torque.*

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
- RDM's Cure set lands on the 50% cap with it, from 45% without.

### Quanpur Necklace

*Quanpur Necklace.*

- `Earth Elemental "Magic Atk. Bonus"+5` is affinity: a 5% damage multiplier for earth-element spells only. It is separate from normal MAB and in the same term as Orpheus's Sash.
- On any other element the necklace is just MAB +7. ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Damage))

### Rep. Plat. Medal

*Republican Platinum Medal.*

- Regain +2 needs Bastok allegiance.
- A character has one allegiance at a time, so the Regain excludes Elite Royal Collar's San d'Oria Regen and Sibyl Scarf's Windurst Refresh.
- STR +10 and Attack +30 need no allegiance. ([FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Allegiance))
- The help text names the condition `Citizen of Bastok`, so the Regain works only for a citizen of Bastok.
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Savage Blade (Mid buff); Death Blossom (Mid buff); Knights of Round (Mid buff); Imperator (Mid buff); Mercy Stroke (Mid buff, High buff); Ruthless Stroke (Mid buff); Black Halo (Mid buff).

### Sanctity Necklace

*Sanctity Necklace.*

- wsdist: the entry has no Accuracy, but the necklace has Accuracy+10, so melee runs undercount it by 10. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), line 653)

### Sibyl Scarf

*Sibyl Scarf.*

- Refresh +1 needs Windurst allegiance.
- A character has one allegiance at a time, so the Refresh excludes Elite Royal Collar's Regen and Rep. Plat. Medal's Regain.
- INT +10 and MAB +10 apply to everyone. ([FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Allegiance))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Red Lotus Blade (Mid buff); Aeolian Edge (Mid buff); Casting (Free Nuke, Magic Burst); BLU: Sanguine Blade (Mid buff, Ice Brand enabled); Red Lotus Blade (Ice Brand enabled).

### Stoicheion Medal

*Stoicheion Medal.*

- Elemental magic casting time -3% only matters at precast and doesn't shorten recast. ([ffxi-mechanics.md](ffxi-mechanics.md#spell-specific-and-school-casting-time))
- bg-wiki caps casting time reduction at 80%. If school casting time counts inside that cap (bg-wiki's reading, disputed by the player), it adds nothing once Fast Cast alone reaches 80%.

### Weike Torque

*Weike Torque.*

- Enfeebling skill raises Distract III and Frazzle III potency by 6/21 per point, so +7 skill is only about 2 points of evasion or magic evasion down.
- For RDM enfeebling, Dls. Torque +1 (Magic Accuracy +25, potency ×1.07, augmented duration) is the stronger neck. ([bg-wiki](https://www.bg-wiki.com/ffxi/Distract_III))

No notes beyond the help text: Asperity Necklace, Chivalrous Chain, Houyi's Gorget, Imbodla Necklace, Kubira Beads, Loricate Torque, Marked Gorget, Shifting Neck. +1, Subtlety Spec., Torero Torque, Twilight Torque.

## Earrings

### Alabaster Earring

*Alabaster Earring.*

- The Accuracy, Ranged Accuracy and Magic Accuracy +15 in its help text are for the pet. The wearer gets accuracy only from Path A.
- At the maximum rank, 30, Path A gives Accuracy, Ranged Accuracy and Magic Accuracy +15 (ranks 1-15 add +1 each), All attributes +10 (ranks 16-25) and Store TP +5 (ranks 26-30).
- The export doesn't show the rank. For each rank's values, see [rank-augments.md](rank-augments.md#alabaster-earring) ([bg-wiki](https://www.bg-wiki.com/ffxi/Alabaster_Earring); [FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Alabaster_Earring)).
- Its Damage taken -5% is 12/256, about 4.7%. Damage taken is counted in 1/256 steps against a cap of 128/256 (-50%), so add 12, not a full 5%, when totalling DT toward the cap (bg-wiki: [Alabaster Earring](https://www.bg-wiki.com/ffxi/Alabaster_Earring), [Damage Taken](https://www.bg-wiki.com/ffxi/Damage_Taken)).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Chant du Cygne (Mid buff, High buff); Death Blossom (Mid buff, High buff); Knights of Round (Mid buff, High buff); Requiescat (Mid buff, High buff); Mercy Stroke (Mid buff, High buff); Evisceration (Mid buff, High buff); Naegling + Thibron TP (-50% DT, -25% DT); BLU: Requiescat (Mid buff, High buff); Tizona + Thibron AM3 TP (-50% DT, -25% DT); Caliburnus + Thibron AM1 TP (-50% DT, -25% DT).

### Arbatel Earring +1

*Arbatel Earring +1. SCH only.*

- Like its base stats, its augments work only in the right ear: bg-wiki lists them under "Right Ear".
- They roll Mag. Acc. +11 to 15 and Enmity -1 to -5 ([bg-wiki](https://www.bg-wiki.com/ffxi/Arbatel_Earring_%2B1)).

### Augment. Earring

*Augmenting Earring.*

- Its only stat is Enhancing magic skill +3.

### Bladeborn Earring

*Bladeborn Earring.*

- Its set bonus needs Steelflash Earring in the other ear. The two together give Double Attack +7% in total; either alone gives none (bg-wiki: [Bladeborn Earring](https://www.bg-wiki.com/ffxi/Bladeborn_Earring), [Double Attack](https://www.bg-wiki.com/ffxi/Double_Attack)).
- The pair takes both ears for DA 7%, Accuracy 8, Attack 8 and Store TP 2.
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
- Its random quest augments are minor. PDT, of which a copy can roll at most -2%, adds to DT toward the -50% physical cap (bg-wiki: [Darkness Earring](https://www.bg-wiki.com/ffxi/Darkness_Earring), [Scattered Shells, Scattered Mind](https://www.bg-wiki.com/ffxi/Scattered_Shells,_Scattered_Mind)).

### Dudgeon Earring

*Dudgeon Earring.*

- Its set bonus needs Heartseeker Earring in the other ear. The two together give Dual Wield +7% in total; either alone gives none.
- It only helps while dual wielding: RDM needs /NIN or /DNC, and BLU needs set blue magic that gives the Dual Wield trait.
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
- It rolls Accuracy and Magic Accuracy +11 to 15 and Double Attack +3 to 5% (bg-wiki: [Hashi. Earring +1](https://www.bg-wiki.com/ffxi/Hashi._Earring_%2B1), [Sortie rewards](https://www.bg-wiki.com/ffxi/Category:Sortie_Rewards)).
- Sword skill +11 only helps hits from a hand holding a sword.
- Past 600 sword skill each point is about 0.9 accuracy, so it is about Accuracy +9 to +10, and roughly as much attack.
- With Maxentius in the main hand it does nothing for main-hand hits.
- Physical blue magic takes its accuracy from the main-hand weapon plus DEX and Accuracy, so the sword skill helps it only with a sword in the main hand.
- Blue magic skill +11 raises physical blue magic's damage, and magical blue magic's accuracy (added effects included) and potency (bg-wiki: [Accuracy](https://www.bg-wiki.com/ffxi/Accuracy), [Attack](https://www.bg-wiki.com/ffxi/Attack), [Dual Wield](https://www.bg-wiki.com/ffxi/Dual_Wield), [Blue Magic](https://www.bg-wiki.com/ffxi/Category:Blue_Magic)).

### Heartseeker Earring

*Heartseeker Earring.*

- Its set bonus needs Dudgeon Earring in the other ear. The two together give Dual Wield +7% in total; either alone gives none.
- It only helps while dual wielding: RDM needs /NIN or /DNC, and BLU needs set blue magic that gives the Dual Wield trait.
- Set bonus: Dudgeon and Heartseeker, see [Dudgeon and Heartseeker set](#dudgeon-and-heartseeker-set).

### Hecate's Earring

*Hecate's Earring.*

- Its MAB +6 plus a 3% magic crit rate (+10 MAB on a crit) averages about +6.3 MAB on spells. Weapon skills can't magic-crit (bg-wiki: [Magic Critical Hit](https://www.bg-wiki.com/ffxi/Magic_Critical_Hit), [Friomisi Earring](https://www.bg-wiki.com/ffxi/Friomisi_Earring), [Novio Earring](https://www.bg-wiki.com/ffxi/Novio_Earring)).

### Hollow Earring

*Hollow Earring.*

- 'Sword enhancement spell' means the Enspells, which work with any weapon type.
- The +3 counts only while worn during each melee round. It does nothing at the cast.
- On an earring it applies to both hands, though tier II Enspells only add damage to the first main-hand hit of a round.
- Composure triples it (bg-wiki: [Enspell](https://www.bg-wiki.com/ffxi/Category:Enspell), [Composure](https://www.bg-wiki.com/ffxi/Composure)).

### Leth. Earring +1

*Lethargy Earring +1. RDM only.*

- Its augments are right-ear only too: bg-wiki lists them under "Right Ear" on the item page and in the Sortie +1 earring table. In the left ear the augments give nothing.
- The augments roll Accuracy and Magic Accuracy +11 to 15 and Double Attack +3 to 5%. bg-wiki says the two augment slots rise together (bg-wiki: [Leth. Earring +1](https://www.bg-wiki.com/ffxi/Leth._Earring_%2B1), [Sortie rewards](https://www.bg-wiki.com/ffxi/Category:Sortie_Rewards)).
- Fast Cast 8% shortens casting time from the precast set.
- Worn in a midcast set it also cuts recast by 4%.
- Its Enhancing magic duration +8% is listed (not augmented) duration, read when the spell lands. It adds to the other listed duration % in the same multiplier (bg-wiki: [Lethargy Armor Set](https://www.bg-wiki.com/ffxi/Lethargy_Armor_Set), [Spell Recast](https://www.bg-wiki.com/ffxi/Spell_Recast)).
- It is not a Lethargy armor piece, so it doesn't count toward the Composure set bonus; see [Lethargy set](#lethargy-set). Only the five Empyrean and Reforged Empyrean armor pieces count ([bg-wiki](https://www.bg-wiki.com/ffxi/Lethargy_Armor_Set)).

### Lifestorm Earring

*Lifestorm Earring.*

- Its set bonus, Magic Accuracy+12, only applies while Psystorm Earring is in the other ear.
- Neither wiki says whether +12 is the pair's total or each earring's. bg-wiki's Double Attack table counts the matching Steelflash/Bladeborn pair's 7% once, so assume +12 in total for the pair, plus this earring's MND+4 and Psystorm's INT+4 (bg-wiki: [Lifestorm Earring](https://www.bg-wiki.com/ffxi/Lifestorm_Earring), [Double Attack](https://www.bg-wiki.com/ffxi/Double_Attack); [FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Lifestorm_Earring)).
- The pair takes both ears.
- Set bonus: Lifestorm and Psystorm, see [Lifestorm and Psystorm set](#lifestorm-and-psystorm-set).

### Loquac. Earring

*Loquacious Earring.*

- Its "Enhances Fast Cast" is Fast Cast +2% ([bg-wiki](https://www.bg-wiki.com/ffxi/Loquac._Earring)).

### Lyc. Earring

*Lycopodium Earring.*

- Sword enhancement spell damage +2 applies during melee rounds, not at the cast, so it has to stay on while attacking.
- Composure multiplies it.
- On armor it applies to both hands and to any weapon type ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Enspell)).

### Macu. Earring +1

*Maculele Earring +1. DNC only.*

- Base stats and augments work only in the right ear.
- It rolls Accuracy/Magic Accuracy +11 to 15 and Store TP +3 to 5 ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Sortie_Rewards)).

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
- In physical blue magic, only the augment's Attack or Accuracy +4 is sure to count (bg-wiki: [TP Bonus](https://www.bg-wiki.com/ffxi/TP_Bonus), [Moonshade Earring](https://www.bg-wiki.com/ffxi/Moonshade_Earring), [Efflux](https://www.bg-wiki.com/ffxi/Efflux)).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Savage Blade (Mid buff, High buff); Imperator (Mid buff, High buff); Seraph Blade (Mid buff); Red Lotus Blade (Mid buff); Ruthless Stroke (Mid buff, High buff); Black Halo (Mid buff, High buff); Aeolian Edge (Mid buff); BLU: Expiacion (Mid buff, High buff); Imperator (Mid buff, High buff); Savage Blade (Mid buff, High buff); Red Lotus Blade (Mid buff, Ice Brand enabled).
- wsdist: its entry has Accuracy+4 and TP Bonus +250. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), line 728)

### Njordr Earring

*Njordr Earring.*

- Blue magic skill sets the magic accuracy and potency of magical blue magic, the accuracy of any blue magic spell's additional effect, and blue magic spell interruption rate.
- For physical blue magic it adds to damage, but the hit's accuracy comes from the main-hand weapon's accuracy, DEX and Accuracy.
- It does nothing for spells that aren't blue magic ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Blue_Magic)).

### Pel. Earring +1

*Peltast's Earring +1. DRG only.*

- Base stats and augments work only in the right ear.
- It rolls Accuracy/Magic Accuracy +11 to 15 and Critical hit rate +3 to 5% ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Sortie_Rewards)).

### Psystorm Earring

*Psystorm Earring.*

- Its set bonus, Magic Accuracy+12, only applies while Lifestorm Earring is in the other ear.
- Assume +12 in total for the pair. Neither wiki says, but bg-wiki counts the Steelflash/Bladeborn pair's bonus once.
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
- It rolls Accuracy/Magic Accuracy +11 to 15 and Store TP +3 to 5 ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Sortie_Rewards)).

### Skulker's Earring

*Skulker's Earring. THF only.*

- Base stats and augment work only in the right ear.
- It rolls Accuracy/Magic Accuracy +6 to 10 ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Sortie_Rewards)).

### Snotra Earring

*Snotra Earring. RDM only.*

- Its +10% is enfeebling duration listed on gear, read when the spell lands, so it belongs in the midcast set.
- bg-wiki's formula multiplies listed duration and augmented duration as separate terms. Snotra shares the listed term with Obstin. Sash (5%), while Dls. Torque +1's augmented enfeebling duration (+20% at rank 20) is its own multiplier.
- Dia's duration formula uses the same terms, so it lengthens Dia too (bg-wiki: [Enfeebling Magic](https://www.bg-wiki.com/ffxi/Category:Enfeebling_Magic), [Dls. Torque +1](https://www.bg-wiki.com/ffxi/Dls._Torque_%2B1)).
- Enfeebling duration also depends on how far the spell is resisted, so its Magic Accuracy+10 lengthens debuffs as well as landing them ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Enfeebling_Magic)).

### Steelflash Earring

*Steelflash Earring.*

- Its set bonus, Double Attack+7%, only applies while Bladeborn Earring (Attack+8, Store TP+1) is in the other ear. bg-wiki's Double Attack table counts the 7% once for the pair (bg-wiki: [Steelflash Earring](https://www.bg-wiki.com/ffxi/Steelflash_Earring), [Double Attack](https://www.bg-wiki.com/ffxi/Double_Attack)).
- The pair takes both ears, so it can't be worn with the right-ear-only Leth. Earring +1 (RDM: Acc+15, DA+5%) or Hashi. Earring +1 (BLU: Acc+12, DA+4%, Sword skill+11) (bg-wiki: [Bladeborn Earring](https://www.bg-wiki.com/ffxi/Bladeborn_Earring), [Leth. Earring +1](https://www.bg-wiki.com/ffxi/Leth._Earring_%2B1), [Hashi. Earring +1](https://www.bg-wiki.com/ffxi/Hashi._Earring_%2B1)).
- Set bonus: Bladeborn and Steelflash, see [Bladeborn and Steelflash set](#bladeborn-and-steelflash-set).

### Suppanomimi

*Suppanomimi.*

- "Enhances Dual Wield" is Dual Wield +5%.
- FFXIclopedia says it doesn't grant Dual Wield, so it only helps when Dual Wield comes from /NIN, /DNC or BLU's set spells.
- The Dudgeon + Heartseeker pair gives Dual Wield +7% but takes both ears (bg-wiki: [Suppanomimi](https://www.bg-wiki.com/ffxi/Suppanomimi), [Heartseeker Earring](https://www.bg-wiki.com/ffxi/Heartseeker_Earring); [FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Suppanomimi)).
- Sword skill +5 only helps with a sword in hand.
- Past 600 sword skill, bg-wiki's formulas make it worth Accuracy +4 or +5 (0.9 per point, rounded down) and Attack+5 (bg-wiki: [Accuracy](https://www.bg-wiki.com/ffxi/Accuracy), [Attack](https://www.bg-wiki.com/ffxi/Attack)).

### Triumph Earring

*Triumph Earring.*

- The two icon glyphs in its help text are elements: it gives Fire resistance +11 and Ice resistance +11, with STR+2 ([bg-wiki](https://www.bg-wiki.com/ffxi/Triumph_Earring); [FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Triumph_Earring)).

### Velocity Earring

*Velocity Earring.*

- How much Resist Slow it gives is unknown: bg-wiki lists '?'.
- Per bg-wiki, Resist Slow also fully resists Addle a percentage of the time ([bg-wiki](https://www.bg-wiki.com/ffxi/Resist_Slow)).

No notes beyond the help text: Andoaa Earring, Assuage Earring, Buckler Earring, Etiolation Earring, Friomisi Earring, Grit Earring, Infused Earring, Mimir Earring, Novia Earring, Novio Earring.

## Body

### Adhemar Jacket

*Adhemar Jacket. BLU, not RDM.*

- Path D is the caster path (HP+80, Fast Cast +7%, Magic damage taken -3%) ([bg-wiki](https://www.bg-wiki.com/ffxi/Nolan)).
- Set bonus: Adhemar, see [Adhemar set](#adhemar-set). Only +1 pieces count, so this NQ jacket never does ([bg-wiki](https://www.bg-wiki.com/ffxi/Adhemar_Attire_Set)).

### Argute Gown +2

*Argute Gown +2. SCH only; not RDM or BLU.*

- Its Sublimation bonus drains 2 more HP and charges 2 more MP per tick.
- Its Magian augment is the Enlightenment bonus (+2 per merit level to six magic skills) ([bg-wiki](https://www.bg-wiki.com/ffxi/Argute_Gown_%2B2)).

### Assim. Jubbah +4

*Assimilator's Jubbah +4. BLU only.*

- Set bonus: Assimilator's, see [Assimilator's set](#assimilators-set). bg-wiki gives +4 pieces the same bonus as +2 and +3, so this one counts ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Reforged_Artifact_Armor_%2B3)).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): BLU: Expiacion (High buff); Imperator (High buff).

### Atrophy Tabard +4

*Atrophy Tabard +4. RDM only.*

- "Refresh" potency +2 adds 2 MP per tick to the Refresh spells you cast.
- It is read when the spell lands, so it belongs in the Refresh midcast ([bg-wiki](https://www.bg-wiki.com/ffxi/Refresh)).
- Its separate "Refresh"+3 is Refresh +3: the wearer gets 3 MP per tick while it is on.
- Set bonus: Atrophy, see [Atrophy set](#atrophy-set).

### Bunzi's Robe

*Bunzi's Robe. RDM, not BLU.*

- Its only path, Odyssey Path A, adds Attack, Magic Damage and Physical damage limit from rank 1, Accuracy and Magic Accuracy from rank 16, and DEX from rank 21. For the values at each rank, see [rank-augments.md](rank-augments.md#bunzis-robe) ([bg-wiki](https://www.bg-wiki.com/ffxi/Bunzi%27s_Robe)).
- "Cure" potency +15% counts toward the 50% Cure potency cap, not the separate 30% Cure potency II cap ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Cure_Spell)).
- Magic burst damage +10 is tier I, so it counts toward the 40% gear cap.
- Only Magic burst damage II, the Magic Burst Bonus trait, job points and gifts go past that cap ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Burst)).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Death Blossom (High buff); Imperator (High buff); Requiescat (High buff); Black Halo (High buff).

### Councilor's Garb

*Councilor's Garb.*

- Only the single highest movement-speed bonus from equipment counts.
- Its +25% replaces any other movement-speed gear (such as an 18% piece) rather than adding to it ([bg-wiki](https://www.bg-wiki.com/ffxi/Movement_Speed)).

### Despair Mail

*Despair Mail.*

- At rank 15, Path B would add STR+12, VIT+7 and Haste+2%. Path D would add Attack+25, Magic Evasion+20 and Double Attack+3% ([bg-wiki](https://www.bg-wiki.com/ffxi/Nolan)).

### Ea Houppelande

*Ea Houppelande. RDM, not BLU.*

- Magic burst damage +8 counts toward the 40% gear cap. Magic burst damage II +8 is outside that cap and has no known cap of its own.
- Below the cap that is 16 against Bunzi's Robe's 10. Once other gear fills the 40%, it is still 8 against Bunzi's 0.
- Ea also has 9 more Magic Attack Bonus (39 vs 30) and 2 more Magic Accuracy. Bunzi's Robe keeps Magic Damage +30, DT -10% and 5 more INT ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Burst)).

### Gleti's Cuirass

*Gleti's Cuirass. BLU, not RDM.*

- Its only path, Odyssey Path A, adds Attack and Double Attack from rank 1, Accuracy and Magic Accuracy from rank 16, and "Occasionally increases resistance to status ailments" from rank 21. For the values at each rank, see [rank-augments.md](rank-augments.md#gletis-cuirass) ([bg-wiki](https://www.bg-wiki.com/ffxi/Gleti%27s_Cuirass)).
- "Waltz" potency +10% multiplies the HP restored by your Curing Waltz (from a DNC subjob).
- Waltz potency gear caps at 50%. Waltz potency received has its own 30% cap ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Waltz)).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): BLU: Chant du Cygne (Mid buff, High buff); Requiescat (High buff); Savage Blade (High buff).

### Hashishin Mintan +3

*Hashishin Mintan +3. BLU only.*

- Blue magic spellcasting time -16% shortens only blue magic casting time.
- It is read at precast. Unlike Fast Cast, it doesn't shorten recast ([bg-wiki](https://www.bg-wiki.com/ffxi/Hashishin_Mintan_%2B3)).
- Set bonus: Hashishin, see [Hashishin set](#hashishin-set).

### Jhakri Robe +2

*Jhakri Robe +2.*

- Set bonus: Jhakri, see [Jhakri set](#jhakri-set).
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
- bg-wiki doesn't say whether it is read when Chain Affinity is used or when the physical spell goes off. Only wearing it at both moments is sure to get it ([bg-wiki](https://www.bg-wiki.com/ffxi/Enchainment)).
- The help text's '"Refesh"+2' is a typo for Refresh +2 ([bg-wiki](https://www.bg-wiki.com/ffxi/Luhlaza_Jubbah_%2B1)).

### MG Jerkin +1

*MG Jerkin +1. Elvaan males only.*

- It belongs to the MGM set, so only Elvaan males can wear it, even though it lists all jobs.

### Nyame Mail

*Nyame Mail.*

- Path B's STR/VIT augment only starts at rank 21, so a copy below rank 21 has none. For the other ranks and paths, see [rank-augments.md](rank-augments.md#nyame-mail) ([bg-wiki](https://www.bg-wiki.com/ffxi/Nyame_Mail)).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Savage Blade (Mid buff, High buff); Death Blossom (Mid buff); Knights of Round (Mid buff, High buff); Imperator (Mid buff); Requiescat (Mid buff); Sanguine Blade (Mid buff); Seraph Blade (Mid buff); Red Lotus Blade (Mid buff); Mercy Stroke (Mid buff, High buff); Ruthless Stroke (Mid buff, High buff); Black Halo (Mid buff); Aeolian Edge (Mid buff); BLU: Expiacion (Mid buff); Requiescat (Mid buff); Imperator (Mid buff); Savage Blade (Mid buff); Sanguine Blade (Mid buff, Ice Brand enabled); Red Lotus Blade (Mid buff, Ice Brand enabled).

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

No notes beyond the help text: Akitu Shirt, Alliance Shirt, Chocobo Suit, Esthete's Coat, Gende. Bliaut +1, Helios Jacket, Herculean Vest, Ischemia Chasu., Ziamet Peti.

## Hands

### Adhemar Wristbands

*Adhemar Wristbands. BLU, not RDM.*

- Path A would give AGI+10, DEX+10 and Accuracy+15 instead, and Path D Accuracy+15, Attack+15 and Subtle Blow+7. ([bg-wiki](https://www.bg-wiki.com/ffxi/Nolan))
- Set bonus: Adhemar, see [Adhemar set](#adhemar-set). Only +1 pieces count, so these NQ wristbands never do ([bg-wiki](https://www.bg-wiki.com/ffxi/Adhemar_Attire_Set)).

### Asn. Armlets +2

*Assassin's Armlets +2. THF only.*

- Its optional Magian augment is Enhances "Perfect Dodge" (Perfect Dodge lasts 10 seconds longer). ([bg-wiki](https://www.bg-wiki.com/ffxi/Asn._Armlets_%2B2))

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

- Its only path, Odyssey Path A, adds Attack, Magic Damage and Magic burst damage II from rank 1, Accuracy and Magic Accuracy from rank 16, and MND from rank 21. For the values at each rank, see [rank-augments.md](rank-augments.md#bunzis-gloves). ([bg-wiki](https://www.bg-wiki.com/ffxi/Bunzi%27s_Gloves))
- Its Magic burst damage +8 is Magic Burst Damage I, which shares the 40% cap with all other MBD I gear.
- Magic burst damage II sits outside that cap and has no known cap of its own. On these gloves only the path augment adds it, so a rank 0 copy has none. ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Burst))
- "Double Attack"+8% is a base stat, so a rank 0 copy has it in full. ([bg-wiki](https://www.bg-wiki.com/ffxi/Bunzi%27s_Gloves))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Requiescat (Mid buff); Casting (Magic Burst).

### Chironic Gloves

*Chironic Gloves. RDM, not BLU.*

- Chironic Gloves are not Rare, so a character can hold several copies. ([ffxi-mechanics.md](ffxi-mechanics.md#gear-and-gearswap))

### Gazu Bracelets

*Gazu Bracelets.*

- Its "Unity Ranking" Accuracy is +10 to +15, set by your Unity's weekly rank (a higher rank gives more).
- Its total Accuracy is therefore 40 to 45, still with Attack -18. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Unity_Concord))

### Gleti's Gauntlets

*Gleti's Gauntlets. BLU, not RDM.*

- Its only path, Odyssey Path A, adds Attack and Store TP from rank 1, Accuracy and Magic Accuracy from rank 16, and DEX from rank 21. For the values at each rank, see [rank-augments.md](rank-augments.md#gletis-gauntlets). ([bg-wiki](https://www.bg-wiki.com/ffxi/Gleti%27s_Gauntlets))
- Physical damage limit +7% raises only the cap on pDIF, not pDIF itself. It adds damage only once attack is high enough to reach the cap. bg-wiki's Damage Limit+ page says so and lists these gauntlets.
- It also applies to physical and hybrid weapon skills. ([bg-wiki](https://www.bg-wiki.com/ffxi/Damage_Limit%2B))
- The help text's last line, Damage taken-8%, comes after the `Pet:` lines and is the pet's: bg-wiki's set page lists it with the hands' pet stats. Don't count it toward the wearer's DT. The wearer's only damage reduction from these gauntlets is Physical damage taken -7%. ([bg-wiki](https://www.bg-wiki.com/ffxi/Gleti%27s_Armor_Set))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): BLU: Expiacion (High buff); Chant du Cygne (High buff).

### Hashi. Bazu. +3

*Hashishin Bazubands +3. BLU only.*

- Blue magic recast delay -16% affects recast only. It never shortens casting time.
- bg-wiki likens it to Fast Cast worn when the spell goes off, so it counts only in the midcast set.
- It applies only to blue magic, not to subjob spells. ([bg-wiki](https://www.bg-wiki.com/ffxi/Hashi._Bazu._%2B3))
- Set bonus: Hashishin, see [Hashishin set](#hashishin-set).

### Herculean Gloves

*Herculean Gloves. BLU, not RDM.*

- Crit. hit damage (cap +4%, +5% with Fern stones) and Weapon skill damage (+1 to +4%, +5% with Fern stones) share the single special-stat slot, so a copy has one or the other.

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
- Quadruple Attack is a Dark Matter-only stat (QA +1 to +3).
- wsdist: its only entry is an Occult Acumen +11 roll. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), line 1086)

### MG Gauntlets +1

*MG Gauntlets +1.*

- Only an Elvaan male can wear it (bg-wiki's race list; Windower races=8). The help text doesn't say so.

### Nyame Gauntlets

*Nyame Gauntlets.*

- On these gauntlets, Path B adds Attack, Ranged Attack and Weapon skill damage from rank 1, Double Attack from rank 16 and VIT from rank 21. For the values at each rank on all four paths, see [rank-augments.md](rank-augments.md#nyame-gauntlets). ([bg-wiki](https://www.bg-wiki.com/ffxi/Nyame_Gauntlets))
- Its Magic burst damage +5 is Magic Burst Damage I, which shares the 40% cap. ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Burst))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Death Blossom (Mid buff); Knights of Round (Mid buff); Imperator (Mid buff); Mercy Stroke (Mid buff); Ruthless Stroke (Mid buff); Black Halo (Mid buff); BLU: Expiacion (Mid buff); Imperator (Mid buff, High buff); Savage Blade (Mid buff, High buff).

### Odyssean Gauntlets

*Odyssean Gauntlets. WAR, PLD and DRK only.*

- RDM and BLU can't wear it. ([bg-wiki](https://www.bg-wiki.com/ffxi/Odyssean_Gauntlets))

### Pinga Mittens

*Pinga Mittens. BLU, not RDM.*

- It is Superior Level 3 (Su3) gear: BLU must have earned its 500-job-point gift to equip it. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Superior_Equipment))

### Psycloth Manillas

*Psycloth Manillas.*

- Its augments are Nolan Path A at full rank (rank 15): MP+50, INT+7 and Conserve MP+6.
- Path B would give Mag. Acc.+10, Spell interruption rate -15% and MND+7 instead. ([bg-wiki](https://www.bg-wiki.com/ffxi/Nolan))

### Serpentes Cuffs

*Serpentes Cuffs.*

- Day and night are Vana'diel time: Regen from 6:00 to 18:00, Refresh from 18:00 to 6:00. ([bg-wiki](https://www.bg-wiki.com/ffxi/Days_of_the_Week))
- Serpentes Sabots work the other way round: Refresh by day, Regen by night.
- Worn together, the two give both Regen and Refresh at all hours. ([bg-wiki](https://www.bg-wiki.com/ffxi/Serpentes_Sabots))
- Set bonus: Serpentes, see [Serpentes set](#serpentes-set).

### Telchine Gloves

*Telchine Gloves.*

- Telchine Gloves are not Rare and copies share a name, so with two copies each set must name its copy by augments. ([bg-wiki](https://www.bg-wiki.com/ffxi/Telchine_Gloves))
- Each Telchine piece holds one Snow, one Leaf and one Dusk augment. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Alluvion_Skirmish_Armor))
- Its "Cure" potency +10% is plain Cure potency, which adds with other Cure potency gear toward a 50% cap. "Cure potency II" gear has its own 30% cap on top of that. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Cure_Spell))

### Vanya Cuffs

*Vanya Cuffs. RDM, not BLU.*

- In the Cure precast set, only its Cure spellcasting time -7% matters.
- Its Healing magic skill +20 raises the amount cured (cure power comes from MND, VIT and healing skill), but only if worn at midcast. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Cure_Spell))

### Viti. Gloves +4

*Vitiation Gloves +4. RDM only.*

- The relic augment adds 3 seconds of enhancing magic duration per Enhancing Magic Duration merit level, up to +15 seconds. The merit itself adds 6 seconds a level.
- The seconds go into the base before every multiplier (Composure, native %, augmented %).
- They count only if the gloves are on at midcast. (bg-wiki: [Viti. Gloves +4](https://www.bg-wiki.com/ffxi/Viti._Gloves_%2B4), [Lethargy Armor Set](https://www.bg-wiki.com/ffxi/Lethargy_Armor_Set))
- Gain spells reach their +25 cap at 500 enhancing skill: floor((skill - 300) / 10) + 5.
- bg-wiki lists these gloves apart from that formula, in a "Gain Stat +" table at +30. That implies their bonus comes on top of the skill cap.
- bg-wiki doesn't say whether the +30 is flat stat points or a percentage. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Gain_Spell))

### Ziamet Bazubands

*Ziamet Bazubands.*

- bg-wiki lists no hidden effects. DEF 1 is all it has, so it is only for appearance. ([bg-wiki](https://www.bg-wiki.com/ffxi/Ziamet_Bazubands))

No notes beyond the help text: Councilor's Cuffs, Pursuer's Cuffs.

## Rings

### Aquasoul Ring

*Aquasoul Ring.*

- Its "Resist Virus" is only +1% resistance to Disease and Plague, so in practice the ring is just MND+7 with DEX-3. ([bg-wiki](https://www.bg-wiki.com/ffxi/Resist_Virus))

### Ayanmo Ring

*Ayanmo Ring.*

- Set bonus: Ayanmo, see [Ayanmo set](#ayanmo-set) (bg-wiki: [Ayanmo Ring](https://www.bg-wiki.com/ffxi/Ayanmo_Ring), [Ambuscade Rewards](https://www.bg-wiki.com/ffxi/Category:Ambuscade_Rewards))

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

- Dark Ring isn't Rare, so with two copies name each copy by its augments in sets.
- Its augments are random Abyssea - Konschtat Gold Pyxis rolls. PDT rolls 1 to 6%.
- The PDT adds with DT toward the -50% physical cap. It does nothing against magic or breath damage.

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

- RDM can't equip it, so of RDM and BLU only BLU can use it. ([bg-wiki](https://www.bg-wiki.com/ffxi/Epona%27s_Ring))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): BLU: Chant du Cygne (High buff); Tizona + Thibron AM3 TP (-50% DT, -25% DT); Caliburnus + Thibron AM1 TP (-50% DT, -25% DT).

### Fencer's Ring

*Fencer's Ring. RDM only.*

- The latent needs HP at or below 75% and TP at or below 1000 at the same time. ([bg-wiki](https://www.bg-wiki.com/ffxi/Fencer%27s_Ring))
- With the latent on and an Enspell up, it adds +5 Enspell damage with any weapon type, on main and off hand alike.
- Tier II Enspells only hit the first main-hand swing of a round.
- Composure triples the +5 to +15. (bg-wiki: [Enspell](https://www.bg-wiki.com/ffxi/Category:Enspell), [Composure](https://www.bg-wiki.com/ffxi/Composure))
- It only works while worn during attack rounds, so it does nothing in a casting set. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Enspell))

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
- The export doesn't show the rank. For each rank's values, see [rank-augments.md](rank-augments.md#murky-ring).
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

No notes beyond the help text: Acumen Ring, Apate Ring, Corneus Ring, Enlivened Ring, Fortified Ring, Heed Ring, K'ayres Ring, Omega Ring, Perception Ring, Solemn Ring, Spiral Ring, Stikini Ring, Strendu Ring.

## Back

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
- `//gs export` doesn't show the rank. [rank-augments.md](rank-augments.md#fi-follet-cape-1) has every rank. ([bg-wiki](https://www.bg-wiki.com/ffxi/Fi_Follet_Cape_%2B1))
- Worn only at midcast, its Path A Fast Cast just shortens recast, by half its value rounded down. Casting time was already set at precast. ([bg-wiki](https://www.bg-wiki.com/ffxi/Spell_Recast))
- `Unity Ranking: MND+1～5` changes each week with the ranking of the wearer's Unity. A higher rank gives more MND. Don't count on +5. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Unity_Concord))

### Ghostfyre Cape

*Ghostfyre Cape. RDM only.*

- Enh. Mag. eff. dur. +20 is an augment with a 10-20 range.
- As augmented duration, it multiplies separately from listed (native) duration. bg-wiki's example is Haste II on self under Composure with +46% listed duration: 180 s × 3 × 1.2 × 1.46 = 946 s.
- Against Sucellos's Cape's native +20%, it gives more whenever the set's native total is larger than its other augmented total. The gain is 0.2 × (native - other augmented) × base duration.
- Example: with 103% native and 40% other augmented duration, it gives 3.25× base against 3.12× for Sucellos's Cape. ([bg-wiki](https://www.bg-wiki.com/ffxi/Ghostfyre_Cape))
- Its augment maximums are 10 each on Enhancing magic skill, Enfeebling magic skill and Magic Accuracy. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:JSE_Capes))
- Sword enhancement spell damage +5 only works while the cape is worn during melee rounds.
- On armor it applies to both hands and any weapon type, and Composure multiplies it.
- In a casting set it does nothing. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Enspell))

### Mecisto. Mantle

*Mecistopins Mantle.*

- Its capacity point bonus (up to 50%) only counts if the mantle is worn when the monster dies.
- Use `//gs disable back` to keep GearSwap from swapping it off. ([bg-wiki](https://www.bg-wiki.com/ffxi/Job_Points))
- Gear doesn't raise Exemplar points (Master Levels). bg-wiki names Corsair's Roll as the only way to boost them.
- On a mastered job the mantle adds capacity points but nothing toward Master Levels. ([bg-wiki](https://www.bg-wiki.com/ffxi/Master_Levels))

### Mending Cape

*Mending Cape. WHM only.*

- Its unnumbered Cursna bonus is +15. ([bg-wiki](https://www.bg-wiki.com/ffxi/Mending_Cape))

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
- [ffxi-mechanics.md](ffxi-mechanics.md#quick-magic) records, as unverified GearSwap advice, that an instant cast can land in precast gear. ([bg-wiki](https://www.bg-wiki.com/ffxi/Occasionally_Quickens_Spellcasting))

### Pahtli Cape

*Pahtli Cape.*

- Cure spellcasting time -8% cuts casting time, so it goes in the precast set a Cure spell wears (`sets.precast.FC.Cure` under Selindrile's framework; see [frameworks/sel.md](frameworks/sel.md#how-sel-picks-a-set)).
- bg-wiki's Cure page counts it with Fast Cast and Healing magic casting time under one 80% hard cap. The player holds that such cuts go past it ([ffxi-mechanics.md](ffxi-mechanics.md#does-anything-break-the-80-cap-disputed)). ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Cure_Spell))

### Perimede Cape

*Perimede Cape.*

- Quick Magic +4% (gear caps at 10%). A proc casts the spell instantly, with no casting time and no recast.

### Rosmerta's Cape

*Rosmerta's Cape. BLU only.*

- It isn't Rare, so with several copies sets must name each copy by its augments.
- Every copy carries the base "Efflux" TP bonus +250.
- Worn at midcast of a physical spell cast under Efflux, it adds to Efflux's 1000 TP bonus, alongside Hashishin Tayt (+650 to +800) and the Efflux job points (+10 per level).
- TP bonus past 3000 is lost. ([bg-wiki](https://www.bg-wiki.com/ffxi/Efflux))
- Monster correlation only matters when the spell's monster family is strong against the target's. That adds +0.25 to a physical spell's multiplier (to each hit's fTP on multi-hit spells).
- bg-wiki says the merit and Magus Keffiyeh correlation bonuses raise that figure and never worsen a weak match.
- Neither bg-wiki nor FFXIclopedia gives a value for this cape's +10, and the bg-wiki page is flagged outdated. ([bg-wiki](https://www.bg-wiki.com/ffxi/Calculating_Blue_Magic_Damage))
- bg-wiki says the Ambuscade cape's Damage taken -5% augment is really 12/256 (about 4.7%), so count 4.7% toward the 50% DT cap. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:JSE_Capes))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): the page names each cape only by its stat and main augment.

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

- It isn't Rare, so with several copies sets must name each copy by its augments.
- Every copy has the native Enfeebling magic effect +10: 10% more potency, rounded down, multiplied with Saboteur.
- Every copy also has native Enhancing magic duration +20%. ([bg-wiki](https://www.bg-wiki.com/ffxi/Sucellos%27s_Cape))
- That +20% is native, so it adds with the other native pieces such as Lethargy and Embla Sash.
- Ghostfyre Cape's augmented +20% multiplies separately, and gives more whenever the set's native total is larger than its other augmented duration. ([bg-wiki](https://www.bg-wiki.com/ffxi/Ghostfyre_Cape))
- bg-wiki says the Ambuscade cape's Damage taken -5% augment is really 12/256 (about 4.7%), so count 4.7% toward the 50% DT cap. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:JSE_Capes))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): the page names each cape only by its stat and main augment.

### Swith Cape

*Swith Cape.*

- Its unnumbered `Enhances "Fast Cast" effect` is 3% Fast Cast.

### Tengu Shawl

*Tengu Shawl.*

- It casts Sneak and Invisible.
- It needs 30 s equipped before use, takes 6 s to cast and recharges in 1 hour.
- It can also be used in the Mog Garden. ([bg-wiki](https://www.bg-wiki.com/ffxi/Tengu_Shawl))

### Twilight Cape

*Twilight Cape.*

- bg-wiki: it adds +0.05 to the Day & Weather multiplier when a matching day or weather bonus procs, never twice. That multiplier caps at 1.4.
- Its bg-wiki item page says the bonus also covers cure potency. ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Damage))
- FFXIclopedia disagrees on days: its +5% always applies to a spell that matches the day, proc or not. A weather match still needs the weather proc.
- FFXIclopedia also lists cures and elemental weapon skills, and says the cape doesn't touch penalties from an opposing day or weather. ([FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Twilight_Cape))
- Without an elemental obi or Hachirin-no-Obi, bg-wiki says day and weather bonuses proc only at random.

No notes beyond the help text: Altruistic Cape, Atheling Mantle, Boxer's Mantle, Izdubar Mantle, Merciful Cape, Potentia Cape, Refraction Cape, Toutatis's Cape, Trepidity Mantle, Tuilha Cape.

## Waist

### Cascade Belt

*Cascade Belt.*

- Its one use for both stats together is Stoneskin, which absorbs skill + 3 x MND - 190, capped at 350.

### Casso Sash

*Casso Sash.*

- Its Dark magic skill +5 is worth 5 Magic Accuracy on dark magic (1 skill = 1 Magic Accuracy). ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Accuracy))
- Dark magic skill also raises Drain and Aspir potency. RDM and BLU have those spells only from a /BLM, /DRK, /GEO or /SCH subjob. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Drain/Aspir_Spell))

### Channeler's Stone

*Channeler's Stone. RDM only.*

- For RDM precast, Embla Sash has more Fast Cast (5% vs 2%). BLU can't wear either one. ([bg-wiki](https://www.bg-wiki.com/ffxi/Channeler%27s_Stone), [bg-wiki](https://www.bg-wiki.com/ffxi/Embla_Sash))

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

- Its Unity Path A augment gives STR+10 and DEX+10 at rank 15 (STR first, DEX from rank 6). [rank-augments.md](rank-augments.md#kentarch-belt-1) gives every rank. ([bg-wiki](https://www.bg-wiki.com/ffxi/Kentarch_Belt_%2B1))
- Its "Store TP"+1~5 follows the weekly rank of the wearer's Unity faction. A higher rank gives more, up to +5, so it can change from week to week. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Unity_Concord), [bg-wiki](https://www.bg-wiki.com/ffxi/Category:Unity_Rewards))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Imperator (High buff); Ruthless Stroke (High buff); BLU: Imperator (Mid buff, High buff).
- wsdist: its only entry is "Kentarch Belt +1 R15", which adds STR and DEX +10 that an unaugmented copy lacks, and counts Store TP at the Unity maximum, 5. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), line 1246)

### Obstin. Sash

*Obstinate Sash. RDM only.*

- Path A at rank 30 adds Magic Accuracy+15 (full by rank 15), Enfeebling magic skill+15 (from rank 16) and Enmity-5 (from rank 21). [rank-augments.md](rank-augments.md#obstin-sash) gives every rank.
- Without the augment, the sash is only MND+5 and enfeebling duration +5%. ([bg-wiki](https://www.bg-wiki.com/ffxi/Obstin._Sash))
- BLU can't wear it: its jobs are WHM, RDM, BRD and SCH (Windower's item data).

### Ovate Rope

*Ovate Rope.*

- Its MAB-10 lowers all magic damage, spells and magical weapon skills alike, so it stays out of damage sets. ([bg-wiki](https://www.bg-wiki.com/ffxi/Ovate_Rope), [bg-wiki](https://www.bg-wiki.com/ffxi/Eschan_Stone), [bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Attack_Bonus))

### Plat. Mog. Belt

*Platinum Moogle Belt.*

- HP+10% applies after merits, gifts, Master Levels and HP from other gear, so it grows with the rest of an HP set.
- That suits it to max-HP sets such as White Wind's midcast. ([bg-wiki](https://www.bg-wiki.com/ffxi/Plat._Mog._Belt), [bg-wiki](https://www.bg-wiki.com/ffxi/White_Wind))

### Rumination Sash

*Rumination Sash.*

- On enfeebling magic, 1 point of enfeebling skill is 1 Magic Accuracy. So this sash is worth Magic Accuracy+10 on enfeebles (+3 plus skill +7), plus MND+4.
- On other magic it is only Magic Accuracy+3. ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Accuracy), [bg-wiki](https://www.bg-wiki.com/ffxi/Rumination_Sash))

### Sailfi Belt +1

*Sailfi Belt +1.*

- Path A at max rank 15 is STR+15 and Double Attack+5%.
- STR rises 1 per rank. Double Attack starts only at rank 6 (+1%) and gains 1% every two ranks (2% at 8, 3% at 10, 4% at 12, 5% at 14).
- The export doesn't show the rank. [rank-augments.md](rank-augments.md#sailfi-belt-1) gives every rank. ([bg-wiki](https://www.bg-wiki.com/ffxi/Sailfi_Belt_%2B1))
- Its Attack+10~15 follows the wearer's Unity faction's weekly ranking (a higher rank gives more), so it can be as low as +10. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Unity_Concord), [bg-wiki](https://www.bg-wiki.com/ffxi/Category:Unity_Rewards))
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Savage Blade (Mid buff, High buff); Death Blossom (Mid buff, High buff); Knights of Round (Mid buff, High buff); Imperator (Mid buff); Mercy Stroke (Mid buff, High buff); Ruthless Stroke (Mid buff); Black Halo (Mid buff, High buff); BLU: Expiacion (Mid buff, High buff); Savage Blade (Mid buff, High buff).

### Siegel Sash

*Siegel Sash.*

- "Enhances Stoneskin effect" is +20 HP absorbed. It goes past the 350 cap (up to 475 with other Stoneskin+ gear). ([bg-wiki](https://www.bg-wiki.com/ffxi/Stoneskin))
- Its Enhancing magic casting time -8% belongs in precast. ([bg-wiki](https://www.bg-wiki.com/ffxi/Siegel_Sash))
- The Stoneskin bonus works only on the Stoneskin spell, not BLU's Diamondhide or Metallic Body (bg-wiki: [Diamondhide](https://www.bg-wiki.com/ffxi/Diamondhide), [Metallic Body](https://www.bg-wiki.com/ffxi/Metallic_Body)). The sash only has to be on during the cast; bg-wiki doesn't cover that ([FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Siegel_Sash)).

### Witful Belt

*Witful Belt.*

- Its hidden Fast Cast value is 3%. Its Haste+3% is 31/1024. ([bg-wiki](https://www.bg-wiki.com/ffxi/Witful_Belt))
- Fast Cast gear cuts recast only if it is still on when the spell goes off. Worn in precast only, it cuts casting time only. ([bg-wiki](https://www.bg-wiki.com/ffxi/Spell_Recast))
- A Quick Magic proc (3%) makes the spell instant, with no casting or recast time. ([bg-wiki](https://www.bg-wiki.com/ffxi/Occasionally_Quickens_Spellcasting))
- After an instant cast, GearSwap has no casting time to swap in midcast gear, so the spell can land in precast gear. This is common GearSwap advice, not on bg-wiki. ([ffxi-mechanics.md](ffxi-mechanics.md#quick-magic))

No notes beyond the help text: Chaac Belt, Cornelia's Belt, Dynamic Belt +1, Eschan Stone, Flume Belt, Hurch'lan Sash, Olympus Sash, Oneiros Sash, Phasmida Belt, Porous Rope, Twilight Belt.

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
- Set bonus: Atrophy, see [Atrophy set](#atrophy-set) ([bg-wiki](https://www.bg-wiki.com/ffxi/Atrophy_Armor_Set)).

### Bunzi's Pants

*Bunzi's Pants. RDM, not BLU.*

- Its only path, Odyssey Path A, adds Attack, Magic Damage and "Blood Pact" damage from rank 1, Accuracy and Magic Accuracy from rank 16, and Pet: Damage taken from rank 21. For the values at each rank, see [rank-augments.md](rank-augments.md#bunzis-pants) ([bg-wiki](https://www.bg-wiki.com/ffxi/Bunzi%27s_Pants)).
- Its Magic burst damage +9 is the first kind, which caps at +40% across all gear. Magic burst damage II is a separate bonus with no known cap ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Burst)).

### Carmine Cuisses +1

*Carmine Cuisses +1.*

- Nolan Path D at rank 15 adds Accuracy+20, Attack+12 and "Dual Wield"+6, for totals of Accuracy+55, Attack+47 and Dual Wield+6, so a Path D copy also works as a dual-wield TP piece.
- The other paths are A: HP+80, STR+12, INT+12; B: Accuracy+12, DEX+12, MND+20; and C: MP+80, INT+12, MND+12 ([bg-wiki](https://www.bg-wiki.com/ffxi/Nolan)).
- Movement speed from equipment doesn't stack: only the highest piece counts. Its 18% is tied for the most RDM and BLU get from non-costume gear; Shneddick Ring is also 18% ([bg-wiki](https://www.bg-wiki.com/ffxi/Movement_Speed)).
- Set bonus: Carmine, see [Carmine set](#carmine-set) ([bg-wiki](https://www.bg-wiki.com/ffxi/Carmine_Armor_Set)).
- wsdist: its entry is the Path D copy, but the engine has no Carmine +1 set bonus at all. ([create_player.py](https://github.com/IzaKastra/wsdist_beta/blob/main/create_player.py), lines 651-735)

### Crimson Cuisses

*Crimson Cuisses.*

- The four unlabeled +20s in its help text are icon stats: Fire, Lightning, Water and Dark resistance +20 each.
- Its Fast Cast is a Synergy augment that ranges from +1 to +4 ([bg-wiki](https://www.bg-wiki.com/ffxi/Crimson_Cuisses)).
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

- Its only path, Odyssey Path A, adds Attack and "Subtle Blow" from rank 1, Accuracy and Magic Accuracy from rank 16, and "Triple Attack" from rank 21. For the values at each rank, see [rank-augments.md](rank-augments.md#gletis-breeches) ([bg-wiki](https://www.bg-wiki.com/ffxi/Gleti%27s_Breeches)).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): BLU: Chant du Cygne (Mid buff, High buff); Requiescat (High buff); Imperator (High buff).
- wsdist: its rank 0 entry has Subtle Blow 8, the rank 15 value; the base item has none. The engine never reads Subtle Blow, so results don't change. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), line 1689)

### Hashishin Tayt +3

*Hashishin Tayt +3. BLU only.*

- Its "Efflux" TP Bonus +800 only works while the legs stay equipped. So it belongs in the physical blue magic midcast set, where the Efflux-boosted spell goes off ([bg-wiki](https://www.bg-wiki.com/ffxi/Hashishin_Tayt_%2B3)).
- Efflux gives a 1000 TP bonus (+10 per Efflux job point level) to the next physical blue magic spell.
- Any TP bonus from Efflux past 3000 is lost ([bg-wiki](https://www.bg-wiki.com/ffxi/Efflux)).
- Set bonus: Hashishin, see [Hashishin set](#hashishin-set) ([bg-wiki](https://www.bg-wiki.com/ffxi/Hashishin_Attire_Set)).

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
- Magic critical hits only happen on Blue, Divine and Elemental magic. They add +10 MAB when they proc.
- So the augment does nothing for magical weapon skills. At +15% it averages about 1.5 MAB on blue magic nukes ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Critical_Hit)).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): BLU: Sanguine Blade (Mid buff, Ice Brand enabled); Red Lotus Blade (Mid buff, Ice Brand enabled).

### Merlinic Shalwar

*Merlinic Shalwar. RDM, not BLU.*

- Merlinic is Exclusive but not Rare.
- Two copies share a name, so a set that lists plain "Merlinic Shalwar" can pick up either one. A set must name the augmented copy by its augments ([bg-wiki](https://www.bg-wiki.com/ffxi/Merlinic_Shalwar)).

### MGM Chausses +1

*MGM Chausses +1. Elvaan males only.*

- Only Elvaan males can equip it, even though it lists all jobs.
- The Magna F and MGF +1 versions are for Elvaan females ([bg-wiki](https://www.bg-wiki.com/ffxi/Magna_Attire_Set)).

### Nyame Flanchard

*Nyame Flanchard.*

- Path B's Double Attack starts at rank 16 and its STR at rank 21. For every rank and path, see [rank-augments.md](rank-augments.md#nyame-flanchard).
- Its Magic burst damage +6 is the capped first kind.
- Magic burst damage II is a Path C augment, so a Path B copy has none ([bg-wiki](https://www.bg-wiki.com/ffxi/Nyame_Flanchard)).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Savage Blade (Mid buff, High buff); Death Blossom (Mid buff, High buff); Knights of Round (Mid buff, High buff); Imperator (Mid buff, High buff); Requiescat (Mid buff, High buff); Seraph Blade (Mid buff); Red Lotus Blade (Mid buff); Mercy Stroke (Mid buff, High buff); Ruthless Stroke (Mid buff, High buff); Black Halo (Mid buff, High buff); BLU: Expiacion (Mid buff, High buff); Requiescat (Mid buff); Imperator (Mid buff); Savage Blade (Mid buff, High buff).
- wsdist: its rank 15 Path B entry has Attack+19, the rank 14 value; rank 15 is +20. Its rank 20 to 30 Path B entries are right, as are the other Nyame pieces' rank 15 to 30 rows. wsdist has no entry between rank 0 and rank 15. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), line 1581)

### Odyssean Cuisses

*Odyssean Cuisses. Not RDM or BLU.*

- RDM and BLU can't equip it. Only WAR, PLD and DRK can.

### Orvail Pants +1

*Orvail Pants +1.*

- Its unnumbered "Enhances Fast Cast" is 5%.
- It can take an optional MP+60 augment ([bg-wiki](https://www.bg-wiki.com/ffxi/Orvail_Pants_%2B1)).

### Portent Pants

*Portent Pants.*

- It is level 88 with no item level.

### Rawhide Trousers

*Rawhide Trousers. BLU, not RDM.*

- At full Nolan rank (15), Path D gives MP+50, Fast Cast +5% and Refresh +1.
- Paths A to C are shared across the Rawhide set. A: DEX+10, STR+7, INT+7. B: HP+50, Accuracy+15, Evasion+20. C: Accuracy+15, Pet: Accuracy+15, Pet: "Double Attack"+3 ([bg-wiki](https://www.bg-wiki.com/ffxi/Nolan)).

### Samnuha Tights

*Samnuha Tights. BLU, not RDM.*

- The unlabeled +30 in its help text is an icon stat: Dark resistance +30.
- bg-wiki lists its augments as STR+10, DEX+10, Double Attack +3% and Triple Attack +3% ([bg-wiki](https://www.bg-wiki.com/ffxi/Samnuha_Tights)).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): BLU: Tizona + Thibron AM3 TP (-25% DT); Caliburnus + Thibron AM1 TP (-25% DT).
- wsdist: it uses bg-wiki's listed augments. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), line 1363)

### Tatsu. Sitagoromo

*Tatsumaki Sitagoromo. RDM, not BLU.*

- Its augments are two picks from a fixed menu given at the end of A Shantotto Ascension. Accuracy+7 and Haste+3% are those options' fixed values.
- bg-wiki shows the menu only as an image ([FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Tatsumaki_Sitagoromo)).
- It has no item level, and BLU can't wear it.

### Telchine Braconi

*Telchine Braconi.*

- Enh. Mag. eff. dur. +10 is augmented duration. bg-wiki multiplies it separately, after native duration gear and the Lethargy set's Composure bonus.
- Once any native duration % is worn, it is worth more than +10% listed natively ([bg-wiki](https://www.bg-wiki.com/ffxi/Lethargy_Armor_Set)).
- +10 is the top of the augment's roll (+1 to +10).
- It comes from a Dusk stone, and "Regen" potency (+1 to +3) comes from the same Dusk stone, so a copy has one or the other.
- A Leafdim stone in its Leaf slot can add Fast Cast (up to +5%) or Cure potency (up to +8%) ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Alluvion_Skirmish_Armor)).

### Ziamet Salvars

*Ziamet Salvars.*

- Cosmetic only. bg-wiki lists no hidden effects ([bg-wiki](https://www.bg-wiki.com/ffxi/Ziamet_Salvars)).

No notes beyond the help text: Chironic Hose, Esthete's Hose, Feast Hose, Herculean Trousers, Taeon Tights.

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

- Its only path, Odyssey Path A, adds Attack and Evasion from rank 1, Accuracy and Magic Accuracy from rank 16, and STR from rank 21. For the values at each rank, see [rank-augments.md](rank-augments.md#gletis-boots) ([bg-wiki](https://www.bg-wiki.com/ffxi/Gleti%27s_Boots)).
- Physical damage limit +5% raises the pDIF cap (gear PDL multiplies the cap), not pDIF itself.
- It only adds damage once attack is high enough for pDIF to reach that cap (bg-wiki: [PDIF](https://www.bg-wiki.com/ffxi/PDIF), [Damage Limit+](https://www.bg-wiki.com/ffxi/Damage_Limit%2B)).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): BLU: Chant du Cygne (High buff).

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

- It isn't Rare, so with several copies a set must name each copy by its augments exactly as the export prints them ([bg-wiki](https://www.bg-wiki.com/ffxi/Herculean_Boots), [ffxi-mechanics.md](ffxi-mechanics.md#gear-and-gearswap)).

### Inspirited Boots

*Inspirited Boots. RDM, not BLU.*

- The +15 is in seconds. It only applies to Refresh landing on the wearer: your own Refresh, or another player's Refresh while you wear it.
- Seconds go into the base before any multiplier.

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
- With 5 Diffusion merits a diffused buff gets the full +45%: 5 × 5% = 25% from the augment plus (5 − 1) × 5% = 20% from the merits.
- When to wear it is disputed. The Sabishii guide says when Diffusion is used, and the Diffusion and Charuqs pages give no timing. So wear it both in the Diffusion job ability set and in the diffused spell's midcast (bg-wiki: [Luhlaza Charuqs +1](https://www.bg-wiki.com/ffxi/Luhlaza_Charuqs_%2B1), [Diffusion](https://www.bg-wiki.com/ffxi/Diffusion), [Azure Tomes: Blue Magic Guide by Sabishii](https://www.bg-wiki.com/ffxi/Azure_Tomes:_Blue_Magic_Guide_by_Sabishii)).

### Merlinic Crackows

*Merlinic Crackows. RDM, not BLU.*

- Its base Fast Cast is 5%.
- The magic path can roll Fast Cast +6, or +7 with a Fern Stone ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Escha_Rewards/Arcane_Glyptics_Inscription)).
- wsdist: its only entry is an Occult Acumen +11 roll, and its base Magic Evasion is 116 where the item has 118. ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), line 1554)

### MGM Ledelsens +1

*MGM Ledelsens +1.*

- bg-wiki lists it as wearable only by Elvaan males.
- The MGM set +1 is the Elvaan male version of the Magna set (bg-wiki: [MGM Ledelsens +1](https://www.bg-wiki.com/ffxi/MGM_Ledelsens_%2B1), [Magna Attire Set](https://www.bg-wiki.com/ffxi/Magna_Attire_Set)).

### Nyame Sollerets

*Nyame Sollerets.*

- On Path B, Double Attack starts at rank 16 and Accuracy at rank 21, so a copy at rank 16 to 20 has Double Attack but no Accuracy. For the other ranks and paths, see [rank-augments.md](rank-augments.md#nyame-sollerets) ([bg-wiki](https://www.bg-wiki.com/ffxi/Nyame_Sollerets)).
- Its Magic burst damage +5 is the ordinary kind, which shares the 40% cap.
- Magic burst damage II is only on Path C, so a Path B copy has none (bg-wiki: [Nyame Sollerets](https://www.bg-wiki.com/ffxi/Nyame_Sollerets), [Magic Burst](https://www.bg-wiki.com/ffxi/Magic_Burst)).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): BLU: Expiacion (Mid buff, High buff); Imperator (Mid buff, High buff); Savage Blade (Mid buff, High buff).

### Odyssean Greaves

*Odyssean Greaves. Not RDM or BLU.*

- Only WAR, PLD and DRK can equip it.

### Powder Boots

*Powder Boots.*

- The Flee enchantment has 20 charges and a 3 s cast.
- It can be used 30 s after the boots are equipped and recasts in 10 minutes ([bg-wiki](https://www.bg-wiki.com/ffxi/Powder_Boots)).
- Flee overwrites the Quickening effect from Sprinter's Shoes.
- bg-wiki gives Thief's Flee ability +60% movement speed. Neither the Powder Boots page nor the Flee page gives the boots' own Flee strength or duration (bg-wiki: [Sprinter's Shoes](https://www.bg-wiki.com/ffxi/Sprinter%27s_Shoes), [Flee](https://www.bg-wiki.com/ffxi/Flee), [Powder Boots](https://www.bg-wiki.com/ffxi/Powder_Boots)).

### Rawhide Boots

*Rawhide Boots. BLU, not RDM.*

- Dual Wield +3 only helps BLU while set blue magic gives it Dual Wield.

### Rubeus Boots

*Rubeus Boots. RDM, not BLU.*

- Set bonus: Rubeus, see [Rubeus set](#rubeus-set) ([bg-wiki](https://www.bg-wiki.com/ffxi/Rubeus_Attire_Set)).

### Serpentes Sabots

*Serpentes Sabots.*

- By day it gives Refresh +1 MP per tick; at night it gives Regen.
- Serpentes Cuffs do the opposite (Regen by day, Refresh at night), so wearing both keeps Refresh up all the time (bg-wiki: [Refresh (Status)](https://www.bg-wiki.com/ffxi/Refresh_(Status)), [Serpentes Cuffs](https://www.bg-wiki.com/ffxi/Serpentes_Cuffs)).
- Set bonus: Serpentes, see [Serpentes set](#serpentes-set).

### Sprinter's Shoes

*Sprinter's Shoes.*

- Using it gives Quickening, +10% movement speed for 1 hour.
- The effect stays after the shoes come off or you zone, and stacks with movement speed gear and Mazurka.
- It ends on aggro, on any offensive action, on a job change or under a level cap. Flee overwrites it.
- The shoes have 15 charges, can be used 15 s after equipping and recast in 5 minutes ([bg-wiki](https://www.bg-wiki.com/ffxi/Sprinter%27s_Shoes)).

### Taeon Boots

*Taeon Boots.*

- A copy whose Dusk slot is used can't also have Phalanx received +3 ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Alluvion_Skirmish_Armor)).
- Dual Wield only does anything while a weapon is in the sub slot.
- BLU can only dual wield with Dual Wield from set blue magic. RDM has no Dual Wield trait and needs a /NIN or /DNC subjob ([bg-wiki](https://www.bg-wiki.com/ffxi/Dual_Wield)).

### Telchine Pigaches

*Telchine Pigaches.*

- "Regen" potency +3 is the Duskdim maximum.
- Telchine's Regen potency and Enhancing magic duration augments share the Dusk slot, so a copy with Regen potency has no duration augment (bg-wiki: [Alluvion Skirmish armor](https://www.bg-wiki.com/ffxi/Category:Alluvion_Skirmish_Armor), [Regen spells](https://www.bg-wiki.com/ffxi/Category:Regen_Spell)).
- Regen potency adds a flat +3 HP per tick, after any Embolden multiplier.
- RDM learns Regen at 21, so BLU/RDM can use it too (bg-wiki: [Regen spells](https://www.bg-wiki.com/ffxi/Category:Regen_Spell), [Regen](https://www.bg-wiki.com/ffxi/Regen)).

### Valorous Greaves

*Valorous Greaves. Not RDM or BLU.*

- Only WAR, PLD, DRK, BST, SAM and DRG can equip it ([bg-wiki](https://www.bg-wiki.com/ffxi/Valorous_Greaves)).

### Vanya Clogs

*Vanya Clogs. RDM, not BLU.*

- The casting time cut is read at precast and the potency at midcast ([bg-wiki](https://www.bg-wiki.com/ffxi/Vanya_Clogs)).
- Its Cure potency is the ordinary kind, capped at 50% in total. Cure potency II is a separate stat with a 30% cap ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Cure_Spell)).

### Viti. Boots +4

*Vitiation Boots +4. RDM only.*

- Enfeebling magic effect +10 raises potency by 10% (rounded down) for Addle, Blind, Distract, Frazzle, Gravity, Paralyze, Poison and Slow, and their higher tiers.
- On Dia it adds only to the damage over time, +1 HP per tick per point (+10 here), not to the defense down.
- It does nothing for Sleep, Bind, Silence or Break ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Enfeebling_Magic)).
- The Immunobreak augment adds +1% immunobreak chance per level of RDM's Group 2 Immunobreak Chance merit, up to +5%, on top of the merits' own 3% per level.
- Immunobreak can only happen when Bind, Blind, Break, Gravity, Paralyze, Poison, Silence, Sleep or Slow (or a higher tier) is resisted (bg-wiki: [Viti. Boots +4](https://www.bg-wiki.com/ffxi/Viti._Boots_%2B4), [Enfeebling Magic](https://www.bg-wiki.com/ffxi/Category:Enfeebling_Magic)).
- Simulated sets ([bg-wiki All Jobs Gear Sets](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets), Odyssey at rank 30, Nyame Path B rank 25): RDM: Casting (Free Nuke, Magic Burst).

No notes beyond the help text: Battlecast Gaiters, Kheper Gamashes, Psycloth Boots, Ziamet Nails.

