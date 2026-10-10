# Vanar: gear notes

Notes on Vanar's own copies, for agents that build gear sets from Vanar's `//gs export`. They were written from [`data/export/Vanar 2026-10-01 22-41-03.lua`](../export/Vanar%202026-10-01%2022-41-03.lua). What holds for any copy of an item (hidden values, set bonuses, conditions, slot and hand restrictions) is in [gear-notes.md](../../docs/gear-notes.md), under the same headings, so read both. The entries here add what each augmented copy is for, each path item's rank, the pieces that another piece Vanar owns beats, and what Vanar lacks.

- **Coverage.** An entry is here only when there is something to say of Vanar's copy. Gear on storage slips, which exports list in `slip<N>` tables from 2026-10-04 on, has no entries yet, so read a slip piece's bg-wiki page before putting it in a set.
- **Reading an entry.** A note that starts with `Copy` applies only to the copy with the augments it quotes, or to the copy with none. "It" is the item the entry is named for.
- **Companion files.** [Vanar_notes.md](Vanar_notes.md) has the player's rules for these sets, Vanar's merits, job points and Master Levels, and the ranks the player has given. [Vanar_rank_augments.md](Vanar_rank_augments.md) has Vanar's path and rank for each path item, with the augments at that rank. [Vanar_gear_list.md](Vanar_gear_list.md) has every piece the job files wear.
- **Staged weapons.** The export doesn't show the stage of a staged weapon. Every stage shares the name, and `owned-gear.cs` shows the highest stage's help text, which may not be the stage Vanar holds. This affects `Almace`, `Tizona` and `Mpu Gandring`; their entries say what is known.

## Armor sets and set bonuses

What Vanar holds of each set. How each bonus works is in [gear-notes.md](../../docs/gear-notes.md#armor-sets-and-set-bonuses).

| Set | Vanar's counting pieces | Vanar's best |
|---|---|---|
| [Atrophy](../../docs/gear-notes.md#atrophy-set) (RDM) | 4 | +45 |
| [Assimilator's](../../docs/gear-notes.md#assimilators-set) (BLU) | 3 | +30 |
| [Lethargy](../../docs/gear-notes.md#lethargy-set) (RDM) | 5 | +50% |
| [Hashishin](../../docs/gear-notes.md#hashishin-set) (BLU) | 5 | 5% |
| [Jhakri](../../docs/gear-notes.md#jhakri-set) | 6 | +12% |
| [Serpentes](../../docs/gear-notes.md#serpentes-set) | 2 | +5% |
| [Bladeborn and Steelflash](../../docs/gear-notes.md#bladeborn-and-steelflash-set) | 2 | +7% |
| [Dudgeon and Heartseeker](../../docs/gear-notes.md#dudgeon-and-heartseeker-set) | 2 | +7% |
| [Lifestorm and Psystorm](../../docs/gear-notes.md#lifestorm-and-psystorm-set) | 2 | +12 |
| [Ayanmo](../../docs/gear-notes.md#ayanmo-set), [Amalric](../../docs/gear-notes.md#amalric-set), [Carmine](../../docs/gear-notes.md#carmine-set), [Adhemar](../../docs/gear-notes.md#adhemar-set), [Rubeus](../../docs/gear-notes.md#rubeus-set) | 0 or 1 | none: out of reach |
| [Estoqueur's](../../docs/gear-notes.md#estoqueurs-set), [Regal](../../docs/gear-notes.md#regal-set) | 0 | none: Vanar owns no piece |

### Atrophy set

- Vanar's Atrophy pieces are all +4, so whether tiers mix doesn't matter here.
- **Vanar owns:** `Atro. Chapeau +4`, `Atrophy Tabard +4`, `Atro. Gloves +4` and `Atro. Tights +4`. He has no Atrophy Boots and no Regal Earring. His maximum is +45, and only with all four on.
- **In Vanar_Rdm_Gear.lua:** all four (+45) in Step, Violent Flourish, the ACC engaged set, the ACC-mode weapon skill sets and the magical weapon skills' ACC sets; the head and gloves (+15) in Black Halo; the body and legs (+15) in the enfeebling magic accuracy sets. Two or more are the cheapest accuracy RDM has, each piece adding its own Acc 59 to 65 and 15 more. With Composure counted toward the floor **(player, 2026-10-09)**, Savage Blade and the default set need only the gloves (no bonus) and take Viti. Chapeau +4's WSD back.

### Assimilator's set

- **Mixing tiers (confirmed, player, 2026-10-09):** the player's test in game, Accuracy with no gear 343, with the Bazubands only 424 (+81), with the Jubbah only 439 (+96), with both 536. The two alone add up to 520, so both together give 16 more: the two-piece +15, and 1 more that is presumably DEX-to-accuracy rounding (the two pieces' DEX 45 and 49 floor separately, 33 + 36, but together 70). So the +4 Jubbah mixes with the +3 Bazubands, and by the same rule with the +2 Charuqs.
- **Vanar owns:** `Assim. Jubbah +4`, `Assim. Bazu. +3` and `Assim. Charuqs +2` count. `Assim. Keffiyeh +1` and `Assim. Shalwar +1` don't. He has no Regal Earring. His maximum is +30, with the body, hands and feet on.
- **(player, 2026-10-08)** The Bazubands, Charuqs, Shalwar and Keffiyeh are moving from the Mog Case to a wardrobe.
- **In Vanar_Blu_Gear.lua:** the accuracy sets wear the Jubbah and the Bazubands together, for +15 (gear-notes.md's table). That puts the hands at Accuracy 48 + 15 and DEX 45, against Hashi. Bazu. +3's 62 and DEX 43, about 2 ahead, now that the test above shows the tiers mixing. The Charuqs as a third piece come out about even with Hashi. Basmak +3 (Acc 60, DEX 30), so they go on only for Chain Affinity.
- **Four or five pieces:** out of reach. The Keffiyeh +1 and Shalwar +1 have no set line, so they count for nothing, and Vanar has no Regal Earring.
- **Magic accuracy:** the bonus adds Magic Accuracy too, but the Bazubands and Charuqs have none of their own. Two or three pieces give Macc +15 or +30 against Hashi. Bazu. +3's 62 and Hashi. Basmak +3's 60, so the magic accuracy, Resistant and Violent Flourish sets keep the Hashishin hands and feet.

### Lethargy set

- Vanar's RDM.lua assumes Composure must be up.
- **Vanar owns all five:** `Leth. Chappel +3`, `Lethargy Sayon +3`, `Leth. Ganth. +3`, `Leth. Fuseau +3` and `Leth. Houseaux +3`. His maximum is +50%. See [Atrophy](../../docs/gear-notes.md#atrophy-set) for how the two sets share slots.

### Estoqueur's set

- Vanar owns no Estoqueur's armor.

### Hashishin set

- **Vanar owns all five:** `Hashishin Kavuk +3`, `Hashishin Mintan +3`, `Hashi. Bazu. +3`, `Hashishin Tayt +3` and `Hashi. Basmak +3`. His maximum is 5%. See [Assimilator's](../../docs/gear-notes.md#assimilators-set) for how the two sets share slots.

### Jhakri set

- **Vanar owns:** `Jhakri Coronal +2`, `Jhakri Robe +2`, `Jhakri Cuffs +2`, `Jhakri Slops +2`, `Jhakri Pigaches +2` and `Jhakri Ring`. Any five of the six give the maximum, +12%.

### Serpentes set

- **Vanar owns both:** `Serpentes Cuffs` and `Serpentes Sabots`.

### Bladeborn and Steelflash set

- **Vanar owns both:** `Bladeborn Earring` and `Steelflash Earring`.

### Dudgeon and Heartseeker set

- **Vanar owns both:** `Dudgeon Earring` and `Heartseeker Earring`.

### Lifestorm and Psystorm set

- **Vanar owns both:** `Lifestorm Earring` and `Psystorm Earring`. [Lifestorm Earring](../../docs/gear-notes.md#lifestorm-earring) and [Psystorm Earring](../../docs/gear-notes.md#psystorm-earring) compare the pair with Vanar's other ear pairings.

### Ayanmo set

- **Vanar owns:** only `Ayanmo Ring`, so the bonus never applies. The ring's own stats still count.

### Amalric set

- **Vanar owns:** only `Amalric Coif +1`, so the bonus never applies.

### Carmine set

- **Vanar owns:** only `Carmine Cuisses +1`, so the bonus never applies.

### Adhemar set

- **Vanar owns:** `Adhemar Bonnet`, `Adhemar Jacket` and `Adhemar Wristbands`, all NQ, so the bonus never applies. These NQ pieces can't be worn on RDM anyway.

### Rubeus set

- **Vanar owns:** only `Rubeus Boots`, so the bonus never applies. BLU can't wear the boots.

### Regal set

- **Vanar owns no Regal accessory.** A Regal Earring would raise his Atrophy maximum to +60 and his Assimilator's maximum to +45.

### Sets with no set bonus

- Vanar owns no Sakpata's piece. Vanar's Nyame pieces are all Path B, and every Bunzi's and Gleti's piece, `Bunzi's Rod` included, is rank 0, with base stats only **(player, 2026-10-04)**. `Gleti's Knife` was too, and is Path A rank 1 from 2026-10-05 **(player)**. [Vanar_rank_augments.md](Vanar_rank_augments.md) has each piece's rank and its augments at that rank.

## Weapons (main hand)

### Almace

- No augment shows on Vanar's copy, so it is rank 0 and lacks the REMA augment. Rank 0 says nothing about the stage.
- The simulated sets assume Almace Level 119 III, and the export doesn't show Vanar's stage.
- Vanar's copy has no REMA augment, so in wsdist pick the plain "Almace" and "Almace (sub)", not the R15 entries "Select all File" keeps ([gear-notes.md](../../docs/gear-notes.md#almace)).

### Bunzi's Rod

- Vanar's copy is rank 0 (player, 2026-10-02). It exports with no "Path: A" and no augments, so it has only the base stats in its help text.
- Vanar's copy is rank 0, without the rank 30 augment (DMG+11, Magic Atk. Bonus +30, Accuracy and Magic Accuracy +15, Enmity-5), so the sims overvalue it ([rank-augments.md](../../docs/rank-augments.md#bunzis-rod)).

### Chatoyant Staff

- Vanar's Bunzi's Rod beats it for nukes and enfeebles: Magic Accuracy+40 plus Magic Accuracy skill 255 vs +30, Magic Atk. Bonus+35 and Magic Damage+248 vs a hidden 15% boost, and INT/MND+15 vs +5. ([bg-wiki](https://www.bg-wiki.com/ffxi/Bunzi%27s_Rod))
- For Cure it isn't a clear-cut win over Bunzi's Rod, which has the higher Cure potency (+30% vs +10%).

### Chimeric Fleuret

- The player's rules exclude melee-time Enspell gear such as this ([rules](Vanar_notes.md#rules-for-these-sets)).
- Vanar's Pukulatmuj +1 beats it for every RDM use: Sword enhancement spell damage +11 vs +7, Enhancing magic skill +11 for the Enspell cast, and iL119 with Sword skill +242 and DMG:116. Chimeric is level 89 with no skill bonus. ([bg-wiki](https://www.bg-wiki.com/ffxi/Pukulatmuj_%2B1))

### Colada

- Vanar owns two copies, so sets name each by its augments.
- Copy `'Weapon skill damage +2%','DEX+4','Accuracy+12','Attack+10','DMG:+14'`: an Oseem melee-path roll. WSD +2% (known max +3), DEX+4 (max 10, or 15 with Taupe Stones), Accuracy+12 and Attack+10 (max 20, or 25 with Pellucid Stones), DMG+14 (max 20). ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Escha_Rewards/Arcane_Glyptics_Inscription))
- Copy `'Weapon skill damage +2%','DEX+4','Accuracy+12','Attack+10','DMG:+14'`: in the sub slot its WSD, DEX, Accuracy and Attack apply to both hands, and its DMG only to its own hits. ([bg-wiki](https://www.bg-wiki.com/ffxi/Dual_Wield))
- Copy `'"Refresh"+2','Mag. Acc.+11','"Mag.Atk.Bns."+12','DMG:+1'`: an Oseem magic-path roll. Refresh +2 is the top of Colada's known Refresh range (+1 to 2). Mag. Acc.+11 and Magic Atk. Bonus+12 are mid rolls (max 20, or 25 with Pellucid Stones). ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Escha_Rewards/Arcane_Glyptics_Inscription))
- Copy `'"Refresh"+2','Mag. Acc.+11','"Mag.Atk.Bns."+12','DMG:+1'`: equipping anything in main or sub resets TP. If this copy goes in the main hand whenever you're not engaged, any TP left when you disengage is lost. ([bg-wiki](https://www.bg-wiki.com/ffxi/TP))

### Demers. Degen +1

- Colada's fixed Fast Cast +4% beats it for precast. ([bg-wiki](https://www.bg-wiki.com/ffxi/Colada))
- Vanar's copy shows no rank.

### Enhancing Sword

- The player's rules exclude melee-time Enspell gear such as this ([rules](Vanar_notes.md#rules-for-these-sets)).
- Vanar's Pukulatmuj +1 beats it for every RDM use: Sword enhancement spell damage +11 vs +5, Enhancing magic skill +11, and an iL119 Sword skill +242. Enhancing Sword is level 68 with no skill bonus. ([bg-wiki](https://www.bg-wiki.com/ffxi/Pukulatmuj_%2B1))

### Eosuchus Club

- Vanar's Bunzi's Rod matches or beats it on every stat it has, in either hand: Magic Accuracy skill 255 vs 215, Magic Accuracy+40 vs +10, Magic Damage+248 vs +100, INT/MND+15 vs +6, and the same Club skill +242.
- Bunzi's Rod also adds Accuracy+40 and Magic Atk. Bonus+35, so this club has no RDM or BLU use. ([bg-wiki](https://www.bg-wiki.com/ffxi/Eosuchus_Club), [bg-wiki](https://www.bg-wiki.com/ffxi/Bunzi%27s_Rod))

### Gleti's Knife

- **(player, 2026-10-05)** Vanar's copy is Path A rank 1: DMG+1 and Attack+2 over its base stats. It was rank 0, exporting with no augments, up to 2026-10-04.
- At rank 1 it lacks DMG+10, Attack+43, Accuracy and Magic Accuracy +15 and Subtle Blow II +10 of the rank 30 augment, so the sims overvalue it ([rank-augments.md](../../docs/rank-augments.md#gletis-knife)).
- As RDM's casting off hand, against Maxentius (`sets.Weapons.CastingDualWield`): both have Magic Accuracy +40, which counts from the sub slot. The knife adds Mag. Acc. +1 a rank from rank 16 (+15 at rank 30) and no INT or MND. Maxentius adds INT and MND +15, worth up to 15 macc while the caster's stat is within 10 of the target's, about 7.5 from 10 to 30 below, 3.75 from 30 to 70 below, and nothing past that ([ffxi-mechanics.md](../../docs/ffxi-mechanics.md#dstat)). So for landing a spell the knife passes Maxentius at rank 16 when the caster's stat is more than 70 below the target's, at rank 19 when 30 to 70 below, and at rank 23 when 10 to 30 below; within 10, it only ties at rank 30. At Vanar's rank 1, Maxentius stays.

### Heartbeater

- Vanar has two identical unaugmented copies, both in the Mog Safe.

### Iris

- This copy carries Nolan's Path D at its Rank 15 values, so it is fully ranked. Totals: Blue magic skill +30 (15 native + 15), Magic Accuracy +15 and Magic Atk. Bonus +29. ([bg-wiki](https://www.bg-wiki.com/ffxi/Nolan))
- It is Vanar's only weapon with Blue magic skill.

### Kustawi +1

- Vanar's copy has no Unity/Odyssey augment.

### Lehbrailg +2

- Vanar's Marin Staff +1 strictly beats it. Both have INT/MND +12 and Magic Accuracy skill +228, but Marin Staff +1 adds Magic Accuracy +15 (this has none), Magic Atk. Bonus +28 vs +22, Magic Damage +217 vs +202, higher DMG, Fast Cast +3% and Unity INT. ([bg-wiki](https://www.bg-wiki.com/ffxi/Marin_Staff_%2B1))
- This copy has none of the Skirmish (Wailing Stone) augments it can take. ([bg-wiki](https://www.bg-wiki.com/ffxi/Lehbrailg_%2B2))

### Marin Staff +1

- Vanar's copy has no Unity/Odyssey augment.

### Maxentius

- Vanar's BLU `sets.Weapons.Casting` puts it in the sub slot, where wsdist counts its burst bonus and the game doesn't.

### Mpu Gandring

- If Vanar's copy is the Incomplete stage, his Gleti's Knife outclasses it for RDM dagger melee: Dagger skill +255 vs +252, Accuracy +40, Attack +30 and Triple Attack +6% at the same damage per delay. The higher stages have more Dagger skill (+260 to +277) and DMG (124 to 137). ([bg-wiki](https://www.bg-wiki.com/ffxi/Gleti%27s_Knife))
- If Vanar's copy is the Incomplete stage, his Bunzi's Rod outclasses it as a magic-accuracy main hand: Magic Accuracy skill +255 plus Magic Accuracy +40, against +252 and none. Level 119 has +260 and +25, so the rod still leads on these two stats (295 against 285). Level 119 II has +269 and +30 (299), and Level 119 III +277 and +35 (312), so both pass it. ([bg-wiki](https://www.bg-wiki.com/ffxi/Bunzi%27s_Rod), [Level 119](https://www.bg-wiki.com/ffxi/Mpu_Gandring_%28Level_119%29))
- The simulated sets assume Level 119 II, and the export doesn't show Vanar's stage.
- wsdist sims Vanar's dagger as Level 119 II, whatever its stage ([gear-notes.md](../../docs/gear-notes.md#mpu-gandring)).

### Nehushtan

- Vanar's Maxentius strictly beats it: DMG 200 vs 184, delay 288 vs 352, INT/MND +15 vs +6, Accuracy +40 vs +27, Magic Accuracy +40 and Magic Atk. Bonus +21 (this has neither), Magic Damage +232 vs +130, Club skill +250 vs +228 and Magic Accuracy skill +250 vs +188. ([bg-wiki](https://www.bg-wiki.com/ffxi/Maxentius))
- This copy has none of the Alluvion Skirmish stone augments it can take. ([bg-wiki](https://www.bg-wiki.com/ffxi/Nehushtan))

### Nibiru Cudgel

- Vanar owns two, with different paths.
- Copy `'MND+10','Mag. Acc.+15','"Cure" potency +15%'`: Nolan's Path A at its Rank 15 values. Totals: Cure potency +25% (10 native + 15), MND +21 and Magic Accuracy +22. ([bg-wiki](https://www.bg-wiki.com/ffxi/Nolan))
- Copy `'MND+10','Mag. Acc.+15','"Cure" potency +15%'`: Cure potency counts toward the 50% Cure potency cap and belongs in the midcast set. Vanar's Bunzi's Rod gives Cure potency +30% in the same slot. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Cure_Spell))
- Copy `'Accuracy+15','Mag. Acc.+15','"Fast Cast"+3'`: Nolan's Path C at its Rank 15 values. Totals: Accuracy +15, Magic Accuracy +22 and Fast Cast +3%. It keeps the native Cure potency +10%. ([bg-wiki](https://www.bg-wiki.com/ffxi/Nolan))
- Copy `'Accuracy+15','Mag. Acc.+15','"Fast Cast"+3'`: the Fast Cast shortens casting time from the precast set, and only shortens recast if the cudgel is still worn at midcast. ([bg-wiki](https://www.bg-wiki.com/ffxi/Fast_Cast))

### Pukulatmuj +1

- Vanar's copy shows no augment, so its Unity augment is at rank 0.

### Secespita

- Pukulatmuj +1 beats it in the main hand: Enhancing skill +11 vs +10, and Magic Accuracy skill +188 vs +84 (that stat only counts in the main hand). ([bg-wiki](https://www.bg-wiki.com/ffxi/Secespita))
- Its only other use is as a second skill weapon in the sub slot. That needs Dual Wield, which RDM only gets from a NIN or DNC subjob. There it gives +10, the same as Forfend +1 Path A at rank 15, a shield that needs no Dual Wield. ([bg-wiki](https://www.bg-wiki.com/ffxi/Forfend_%2B1), [bg-wiki](https://www.bg-wiki.com/ffxi/Dual_Wield))

### Serenity

- With the 4% from this copy's augment, its Cure potency is 29%.
- Vanar's copy has MP+45, Enhancing magic skill +9, Cure potency +4% and Cure spellcasting time -8%, each a little under the augment bg-wiki lists.
- For Cure midcast, Vanar's Bunzi's Rod (Cure potency +30%, one-handed) beats its 29% and leaves the sub slot for a shield. ([bg-wiki](https://www.bg-wiki.com/ffxi/Bunzi%27s_Rod))
- For enhancing skill, Pukulatmuj +1 (+11) with Forfend +1 (+10 at Path A rank 15) beats its +9. ([bg-wiki](https://www.bg-wiki.com/ffxi/Forfend_%2B1))
- What it still adds over those is Cure spellcasting time -8% and Enmity -5. ([bg-wiki](https://www.bg-wiki.com/ffxi/Serenity))

### Soothsayer Staff

- Vanar's Bunzi's Rod with Ammurapi Shield beats it on every magic stat, with any grip Vanar owns: Magic Accuracy 333 vs at most 170 (counting the main-hand Magic Accuracy skill; Niobid Strap or Mephitis Grip add 5), Magic Atk. Bonus 73 vs at most 24, Magic Damage 248 vs 151, INT and MND 28 vs 18 and 19, and MP 98 vs at most 70. ([bg-wiki](https://www.bg-wiki.com/ffxi/Bunzi%27s_Rod), [bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Accuracy_Skill))
- As a staff, Serenity beats or ties it on every magic stat except MP (45 vs 50). That leaves it no RDM use. ([bg-wiki](https://www.bg-wiki.com/ffxi/Serenity))

### Taming Sari

- This copy's useful augment is Treasure Hunter +1, the value bg-wiki lists for this augment, so it only belongs in a THF, BRD or DNC Treasure Hunter set. ([bg-wiki](https://www.bg-wiki.com/ffxi/Taming_Sari))

### Tanmogayi +1

- Colada has a fixed Fast Cast +4%, so it beats Tanmogayi +1 at +3%, ties at +4%, and loses only at +5% or +6%. ([bg-wiki](https://www.bg-wiki.com/ffxi/Colada))
- Vanar's copy shows no augment.

### Thibron

- Vanar's copy has TP Bonus +1000, the augment the BLU page's simulated sets use.

### Tizona

- Vanar's Tizona exports with `'Path: A'`, so it is Level 119 III. **(player, 2026-10-05)** It is rank 15, the maximum: main hand DMG +18, Expiacion damage +15%, Accuracy +30 and Magic Accuracy +30 ([rank-augments.md](../../docs/rank-augments.md#oboro-rank-augments-maximum-only)).
- The simulated sets assume Level 119 III, the stage Vanar's `'Path: A'` copy is.

### Twilight Knife

- For any RDM melee use, Gleti's Knife (DMG 133, Accuracy +40, Attack +30, Triple Attack +6%) and Tauret beat this level-90, DMG 40 dagger. ([bg-wiki](https://www.bg-wiki.com/ffxi/Twilight_Knife))

## Shields and grips, ranged and ammo

### Amar Cluster

- RDM can't equip Honed Tathlum (Accuracy+15), so of Vanar's ammo this is RDM's highest Accuracy piece (+10). On BLU, Honed Tathlum has 5 more Accuracy. ([bg-wiki](https://www.bg-wiki.com/ffxi/Honed_Tathlum))
- Accuracy from DEX is floor(DEX × 0.75), so Coiste Bodhar's DEX+10 at Path A rank 30 would be worth 7 or 8 Accuracy. Vanar's is rank 20 **(player, 2026-10-04)**, with no DEX.
- Vanar's Coiste Bodhar (rank 20: Attack+15, STR+5, no DEX) has no Accuracy, so Amar Cluster's Accuracy+10 is a straight gain. Swapping it in trades Coiste's Double Attack 3%, Store TP 3, Attack+15 and STR+5 for 10 Accuracy. ([bg-wiki](https://www.bg-wiki.com/ffxi/Accuracy))

### Ammurapi Shield

- Vanar's RDM.lua sets Weapon Lock `Unlocked` (2026-10-02), so the shield goes on for casts made while not engaged. BLU.lua sets `Locked`, so no midcast set puts it on there.

### Aureole

- Since the two can't be worn together, Pemphredo Tathlum in the ammo slot (Magic Accuracy+8, INT+4, Magic Atk. Bonus+4, Conserve MP+4) beats it on both jobs. On RDM, Ullr's Magic Accuracy+40 also beats it in the range slot. ([bg-wiki](https://www.bg-wiki.com/ffxi/Pemphredo_Tathlum))

### Coiste Bodhar

- **(player, 2026-10-04)** Vanar's copy is rank 20: Attack+15 and STR+5, no DEX.

### Forfend +1

- **(player, 2026-10-04)** Vanar's copy is rank 15: Accuracy+15, Magic Accuracy+15, Enhancing magic skill +10.
- Vanar's RDM.lua sets `Unlocked`, so it goes on only for casts made while not engaged.

### Fulcio Grip

- The two-handed combat weapons in Vanar's export are staves: Chatoyant Staff on both jobs, and Marin Staff +1, Lehbrailg +2, Serenity and Soothsayer Staff on RDM only.
- For Enhancing magic skill, a staff with this grip loses on BLU, and on RDM, where Forfend +1 is rank 15. The best staff pairing is 12: Serenity's augmented 9 plus this grip's 3.
- RDM's Pukulatmuj +1 (11) with Forfend +1 gives 13 at rank 11, up to 21 at rank 15. Vanar's Forfend is rank 15 **(player, 2026-10-04)**, so the pair gives 21 and beats Serenity with this grip. At rank 10 or below Forfend adds no skill. BLU's Pukulatmuj +1 alone gives 11. ([FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Category:Grips), [rank-augments.md](../../docs/rank-augments.md#forfend-1))

### Genbu's Shield

- Vanar's copy has no augments.

### Impatiens

- The player's rule is to avoid Quick Magic pieces such as Impatiens, because an instant cast can land in precast gear. ([ffxi-mechanics.md](../../docs/ffxi-mechanics.md#quick-magic))

### Mavi Tathlum

- It is the only ammo in Vanar's export with Blue Magic skill or breath damage. ([bg-wiki](https://www.bg-wiki.com/ffxi/Mavi_Tathlum))

### Mephitis Grip

- On RDM, a staff and this grip give up Bunzi's Rod with Ammurapi Shield: Magic Accuracy 333 (40 + 38, plus the Rod's main-hand Magic Accuracy skill 255). These are the Rod's base stats, at Vanar's rank 0; [rank-augments.md](../../docs/rank-augments.md#bunzis-rod) has the other ranks.
- The best staff pairing is Serenity (Magic Accuracy 25, Magic Accuracy skill 228) plus this grip (Magic Accuracy 5, Enfeebling magic skill 5): 258 in total, 75 short of the Rod and Shield. ([FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Category:Grips))

### Niobid Strap

- Its Accuracy, Magic Accuracy and Magic Atk. Bonus +5 are far below the one-handed casting pairs in Vanar's export, such as Bunzi's Rod with Ammurapi Shield (Magic Accuracy 78, or 333 with the Rod's main-hand Magic Accuracy skill 255; Magic Atk. Bonus 73). Those are the Rod's base stats, at Vanar's rank 0; [rank-augments.md](../../docs/rank-augments.md#bunzis-rod) has the other ranks. ([FFXIclopedia](https://ffxiclopedia.fandom.com/wiki/Category:Grips))

## Head

### Amalric Coif +1

- Its augments are Nolan Path C below rank 15: INT+11 and Elemental and Dark magic skill +17, against +12, +20 and +20 at the maximum.
- Those skills add nothing to its Fast Cast, Refresh potency or Aquaveil uses ([bg-wiki](https://www.bg-wiki.com/ffxi/Nolan)).
- Vanar owns no other Amalric piece, so the set bonus never applies.
- Vanar's copy is Path C, which wsdist has no entry for ([gear-notes.md](../../docs/gear-notes.md#amalric-coif-1)).

### Anwig Salade

- Hashishin Kavuk +3 (Accuracy 61, Attack 61) outclasses it for every BLU use. The Salade's only extra is Subtle Blow +3 (bg-wiki: [Anwig Salade](https://www.bg-wiki.com/ffxi/Anwig_Salade), [Accuracy](https://www.bg-wiki.com/ffxi/Accuracy)).

### Bunzi's Hat

- Vanar's copy is rank 0 (player, 2026-10-02): no augments, only the base stats in its help text. The export prints no augments for it, not even `'Path: A'`.
- Vanar's copy is rank 0, without the rank 30 augment (Attack and Magic Damage +30, Store TP +8, Accuracy and Magic Accuracy +15, Quadruple Attack +3%), so the sims overvalue it ([rank-augments.md](../../docs/rank-augments.md#bunzis-hat)).

### Gende. Caubeen

- Enmity-8 is its only edge over Vanar's Vanya Hood, which also has Cure potency +10%, plus Fast Cast 10% and Conserve MP 6 (bg-wiki: [Cure spells](https://www.bg-wiki.com/ffxi/Category:Cure_Spell), [Gende. Caubeen](https://www.bg-wiki.com/ffxi/Gende._Caubeen)).

### Gleti's Mask

- Vanar's copy is rank 0 (player, 2026-10-02): no augments, only the base stats in its help text. The export prints no augments for it, not even `'Path: A'`.

### Haruspex Hat

- For fast cast, Amalric Coif +1 (11%) beats its 8% on both jobs, and Atro. Chapeau +4 (16%) beats it on RDM.
- Over the Coif it only adds Enmity-4 and a few points of STR, DEX, VIT, AGI and CHR ([bg-wiki](https://www.bg-wiki.com/ffxi/Haruspex_Hat)).

### Herculean Helm

- Vanar's copy has no augments.
- Unaugmented, it loses to Amalric Coif +1 (Fast Cast 11%) for fast cast, and to Hashishin Kavuk +3 for melee and nukes (MAB 51 vs 10, Attack 61 vs 15) ([bg-wiki](https://www.bg-wiki.com/ffxi/Hashishin_Kavuk_%2B3)).

### Jhakri Coronal +2

- Apart from attributes, Skillchain Bonus +7 is the only stat it has that Hashishin Kavuk +3 (BLU) and Leth. Chappel +3 (RDM) lack. Both beat it on Accuracy, Attack, Macc and MAB ([bg-wiki](https://www.bg-wiki.com/ffxi/Jhakri_Coronal_%2B2)).

### Luh. Keffiyeh +1

- Vanar has no Convergence merits: Diffusion 5 and Enchainment 5 (player, 2026-10-02) fill BLU Group 2's 10 levels. So this augment does nothing for Vanar ([merits](Vanar_notes.md#merits)).
- It is the only head in Vanar's export with this stat ([bg-wiki](https://www.bg-wiki.com/ffxi/Bad_Breath)).

### Merlinic Hood

- Vanar owns two copies.
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

- Vanar's copy is Path B at rank 14 **(player, 2026-10-09)**: Attack+19, Ranged Attack+19 and Weapon skill damage +6%, with no Double Attack (it starts at rank 16). It was rank 11 from 2026-10-04. The export prints the path but not the rank.
- Vanar's copy is rank 14 Path B, so the sims overvalue it: rank 25 has 11 more Attack, 4% more Weapon skill damage, Double Attack +4% and Accuracy+5 ([rank-augments.md](../../docs/rank-augments.md#nyame-helm)).
- At rank 14 it still loses every weapon skill head slot it competes for. On BLU, Hashishin Kavuk +3 has WSD 12 and Acc and Att 61 against its 6, 40 and 49. On RDM, the floor-built Savage Blade search kept other heads ([Vanar_notes.md](Vanar_notes.md#skill-and-accuracy-accuracy)). The magical weapon skills keep their MAB heads (Kavuk MAB 51, Leth. Chappel +3 MAB 56 against its 30).

### Rawhide Mask

- Its augments are Nolan Path B at rank 15, the path's maximums ([bg-wiki](https://www.bg-wiki.com/ffxi/Nolan)).
- Its Refresh +1 makes it the only head in Vanar's export that BLU can wear with Refresh.
- With this copy's HP+50 it has HP 86 ([bg-wiki](https://www.bg-wiki.com/ffxi/Rawhide_Mask)).

### Sukeroku Hachi.

- It has no Accuracy, Attack or WSD, so Hashishin Kavuk +3 (BLU) and Viti. Chapeau +4 or Leth. Chappel +3 (RDM) beat it for weapon skills ([bg-wiki](https://www.bg-wiki.com/ffxi/Sukeroku_Hachi.)).

### Telchine Cap

- Its Leaf slot (for example Fast Cast +1 to +5%) and Snow slot are empty (bg-wiki: [Alluvion Skirmish armor](https://www.bg-wiki.com/ffxi/Category:Alluvion_Skirmish_Armor), [Lethargy Armor Set](https://www.bg-wiki.com/ffxi/Lethargy_Armor_Set)).

### Vanya Hood

- Its augments are Nolan Path D at rank 15, the path's maximums ([bg-wiki](https://www.bg-wiki.com/ffxi/Nolan)).
- Vanar's copy has Fast Cast 10%, Haste 8%, Cure potency 10% (the 50%-capped kind), Conserve MP 6 and Magic damage taken -2%.
- For plain fast cast on RDM, Atro. Chapeau +4 (16%) is better ([bg-wiki](https://www.bg-wiki.com/ffxi/Vanya_Hood)).

### Viti. Chapeau +4

- Vanar has Enfeebling Magic Duration 0 and Magic Accuracy 5 **(player, 2026-10-02, changed)**.
- At Vanar's 0 levels of Enfeebling Magic Duration the augment adds 0 seconds (0 × 3), and the merit itself adds 0 (0 × 6), so that augment does nothing for Vanar.
- At Vanar's 5 levels of Magic Accuracy the augment gives the full +15 (5 × 3), on top of the merit's own +25 (5 × 5).

### Zelus Tiara

- Vanar's Despair Helm (Haste 10% with its Path B augment, wearable by RDM and BLU) beats it on every stat, so it has no place in RDM or BLU sets (bg-wiki: [Despair Helm](https://www.bg-wiki.com/ffxi/Despair_Helm), [Nolan](https://www.bg-wiki.com/ffxi/Nolan)).

## Neck

### Aesir Torque

- Vanar's RDM has 341 dark magic skill without gear (300 + 25 Master Levels + 16 merits; [Vanar's merits and skills](Vanar_notes.md#merits)), so he is always past 300 and gets the +4 HP figure: 7 × 5/8 ≈ 4.4.

### Dls. Torque +1

- **(player, 2026-10-05)** Vanar's copy is Path A rank 20, the +1's maximum: INT and MND +12, and enhancing and enfeebling magic effect duration +20% each, as augmented duration. RDM's enhancing duration total already counted the 20%.
- Against Sanctity Necklace in RDM's nuke set: Magic Accuracy +25 against +10, and INT +12 against MAB +10. On a tier V nuke at dINT 50 to 199, INT is worth 3.75 to 5 to D a point, so +12 adds about 45 to 60; at dINT 100 to 199, where D is about 1,600 to 2,100, that is 2 to 3%. MAB +10 at about 400 MAB is ×1.02. bg-wiki gives no M values below 0 dINT, where INT is worth less ([ffxi-mechanics.md](../../docs/ffxi-mechanics.md#d-magic-damage-and-int)).
- **(player, 2026-10-07)** The nuke set's neck stays Sanctity Necklace: magic accuracy doesn't strictly come first in nuke sets. In ACC mode, where it does, the torque takes the magical weapon skills' neck for its Magic Accuracy +25.

### Elite Royal Collar

- Vanar is a citizen of Windurst (player, 2026-10-02), so this Regen never works for Vanar.

### Enhancing Torque

- It is the only neck in Vanar's export with Enhancing magic skill.

### Loricate Torque

- Elite Royal Collar strictly beats it: the same Damage taken -5%, plus DEF 30 (more than this neck's best Unity DEF +15) and VIT +10. ([bg-wiki](https://www.bg-wiki.com/ffxi/Elite_Royal_Collar))

### Mirage Stole +2

- **(player, 2026-10-05)** Vanar's copy is Path A rank 20 of 25. bg-wiki gives the augment only at rank 25 (STR and DEX +25, Store TP +7, Critical hit rate +5%), so the rank 20 values have to be read off the item in game ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:JSE_Necks)).
- **(player, 2026-10-08)** The nuke rule covers BLU's magical blue magic, so those sets keep Sanctity Necklace ([Rules](Vanar_notes.md#rules-for-these-sets)). The stole's Macc 25 and Blue magic skill 20 go to the magic accuracy, breath and stun sets and to the nukes' Resistant mode.

### Rep. Plat. Medal

- Vanar is a citizen of Windurst (player, 2026-10-02), so the Regain never works for Vanar.

### Sibyl Scarf

- **(player, 2026-10-02)** Vanar is a citizen of Windurst.
  - The help text names the condition `Citizen of Windurst`, so the Refresh +1 works for him. It is the only nation latent in his export that does.
  - It is passive Refresh +X, so by the player's Refresh priorities ([rules](Vanar_notes.md#rules-for-these-sets)) it belongs in idle sets, not the Refresh midcast.

### Stoicheion Medal

- Vanar's RDM fast-cast set is at 82%, so under bg-wiki's reading it adds nothing on RDM.
- For midcast, Sanctity Necklace's MAB 10 and Macc 10 beat its MAB 8 and Macc 2. ([bg-wiki](https://www.bg-wiki.com/ffxi/Fast_Cast))

### Twilight Torque

- Loricate Torque and Elite Royal Collar both have the same Damage taken -5% plus more (DEF, or DEF and VIT), so both strictly beat it. ([bg-wiki](https://www.bg-wiki.com/ffxi/Twilight_Torque))

## Earrings

### Alabaster Earring

- **(player, 2026-10-04)** Vanar's copy is rank 2: Accuracy, Ranged Accuracy and Magic Accuracy +2, and none of the attribute or Store TP augments.
- In both jobs' ACC-mode sets, where accuracy comes first **(player, 2026-10-07)**, it takes the left ear: Accuracy+2 is the most of any earring in Vanar's wardrobes that fits the left ear. Heartseeker and Steelflash Earrings (Accuracy+8) and Assuage Earring (Accuracy+7) are in the Mog Safe 2.

### Arbatel Earring +1

- Vanar's copy has Mag. Acc. +13 and Enmity -3.

### Augment. Earring

- Andoaa Earring (+5 and MP+30) and Mimir Earring (+10), both in Vanar's export, beat it, so it never makes an enhancing set (bg-wiki: [Augment. Earring](https://www.bg-wiki.com/ffxi/Augment._Earring), [Andoaa Earring](https://www.bg-wiki.com/ffxi/Andoaa_Earring), [Mimir Earring](https://www.bg-wiki.com/ffxi/Mimir_Earring)).

### Bladeborn Earring

- On BLU, Brutal Earring (DA 5%, STP 1) plus Vanar's Hashi. Earring +1 in the right ear (DA 4%, Acc 12, Mag. Acc. 12, Sword skill +11) gives DA 9% and more accuracy.
- With a sword in the main hand, that combination beats the pair on everything but Store TP, since the sword skill also adds about +10 attack.
- Combat skill only counts for hits from a hand holding that weapon type. So with Maxentius in the main hand, the pair also keeps its Attack +8 (bg-wiki: [Double Attack](https://www.bg-wiki.com/ffxi/Double_Attack), [Hashi. Earring +1](https://www.bg-wiki.com/ffxi/Hashi._Earring_%2B1), [Attack](https://www.bg-wiki.com/ffxi/Attack), [Dual Wield](https://www.bg-wiki.com/ffxi/Dual_Wield)).

### Darkness Earring

- Vanar's copy rolled PDT -1% and Resist Petrify +3.

### Dudgeon Earring

- Suppanomimi, also in Vanar's export, gives Dual Wield +5% from a single ear (bg-wiki: [Dudgeon Earring](https://www.bg-wiki.com/ffxi/Dudgeon_Earring), [Dual Wield](https://www.bg-wiki.com/ffxi/Dual_Wield), [Suppanomimi](https://www.bg-wiki.com/ffxi/Suppanomimi)).

### Friomisi Earring

- Against Snotra Earring (Magic Accuracy+10) in RDM's nuke set, by the calculation under [Obstin. Sash](#obstin-sash): at a level 145 foe with a 100% rank, Friomisi's MAB+10 is about 2% more damage on a free cast with either melee food, and on an engaged cast with Oden; engaged with Grape Daifuku the set is 36 short of the cap and Snotra is 9% ahead. Against a level 150 foe, or a 30% rank, Snotra is 5 to 16% ahead.
- Jhakri Ring (Magic Accuracy+6, MAB+3) for a Stikini Ring (Magic Accuracy+8 and all magic skills +5, so 13 on a nuke) follows the same pattern at about 0.6% a ring. The earring and both rings together are about 3% more at a level 145 foe when the set has 24 to spare.
- The player hasn't given the magic accuracy margin wanted for nukes **(player, 2026-10-07)**, so the nuke set keeps Snotra Earring and the Stikini Rings.

### Hashi. Earring +1

- Vanar's copy rolled Accuracy and Magic Accuracy +12 and Double Attack +4%.
- Use the plain `gear.hashishinEarringPlusOne`. The library's `gear.hashishinEarringPlusOneDA` lists max-roll augments (Accuracy+15, Mag. Acc.+15, "Dbl.Atk."+5) that Vanar's copy doesn't have, so GearSwap wouldn't match it to this earring ([GearSets-Include.lua](https://github.com/khowe085/rahvin-gearswap/blob/a36cbf6/RahvinGS/GearSets-Include.lua), lines 4287 and 4519).

### Heartseeker Earring

- Suppanomimi, also in Vanar's export, gives Dual Wield +5% from a single ear (bg-wiki: [Heartseeker Earring](https://www.bg-wiki.com/ffxi/Heartseeker_Earring), [Dual Wield](https://www.bg-wiki.com/ffxi/Dual_Wield), [Suppanomimi](https://www.bg-wiki.com/ffxi/Suppanomimi)).

### Hecate's Earring

- Friomisi Earring (MAB +10) and Novio Earring (MAB +7), both in Vanar's export, fill both ears with more MAB, so it never makes a nuke or magical weapon skill set.

### Hollow Earring

- The player's rule against Enspell gear that must stay on while meleeing rules it out ([ffxi-mechanics.md](Vanar_notes.md#rules-for-these-sets)).

### Leth. Earring +1

- Vanar's copy has the top roll: Accuracy and Magic Accuracy +15 and Double Attack +5%, in the export of 2026-10-03.

### Lifestorm Earring

- On RDM, Leth. Earring +1 (right ear; Vanar's copy Magic Accuracy+15) plus Snotra Earring (Magic Accuracy+10, MND+8) gives Magic Accuracy+25 against the pair's +12.
- On BLU, Vanar's Hashi. Earring +1 (right ear; Magic Accuracy+12, Blue magic skill+11) matches the pair's +12 by itself (if +12 is the pair's total). It leaves the left ear free, for example for Choleric Earring (Magic Accuracy+2) or, for blue magic, Njordr Earring (Blue magic skill+10).
- The pair only adds INT+4 and MND+4 over those (bg-wiki: [Snotra Earring](https://www.bg-wiki.com/ffxi/Snotra_Earring), [Hashi. Earring +1](https://www.bg-wiki.com/ffxi/Hashi._Earring_%2B1), [Choleric Earring](https://www.bg-wiki.com/ffxi/Choleric_Earring)).

### Lyc. Earring

- The player's rule against Enspell gear while meleeing leaves it no role ([ffxi-mechanics.md](Vanar_notes.md#rules-for-these-sets)).
- For Enspell damage, Vanar's Hollow Earring is better: Sword enhancement spell damage +3 against this earring's +2, plus Accuracy+3 and DEX+2.
- Lyc.'s only edge is Magic Accuracy+1, which bg-wiki says does count toward each Enspell hit's magic accuracy (bg-wiki: [Hollow Earring](https://www.bg-wiki.com/ffxi/Hollow_Earring), [Enspell](https://www.bg-wiki.com/ffxi/Category:Enspell)).

### Macu. Earring +1

- Vanar's copy rolled Accuracy/Magic Accuracy +12 and Store TP +4.

### Moonshade Earring

- wsdist's entry has Accuracy+4 where Vanar's copy has Attack+4. TP Bonus +250 matches.

### Novio Earring

- For magic damage, Vanar's Friomisi Earring (Magic Atk. Bonus+10, Enmity+2) beats it. Novio's only edge is having no Enmity+2 ([bg-wiki](https://www.bg-wiki.com/ffxi/Friomisi_Earring)).

### Pel. Earring +1

- Vanar's copy rolled Accuracy/Magic Accuracy +13 and Critical hit rate +4%.

### Psystorm Earring

- The pair takes both ears. On RDM, Leth. Earring +1 plus Snotra Earring (Magic Accuracy+25 together) beats it.
- On BLU, Hashi. Earring +1 alone (right ear, Magic Accuracy+12, Blue magic skill+11) matches its Magic Accuracy and frees the left ear (bg-wiki: [Psystorm Earring](https://www.bg-wiki.com/ffxi/Psystorm_Earring), [Double Attack](https://www.bg-wiki.com/ffxi/Double_Attack), [Hashi. Earring +1](https://www.bg-wiki.com/ffxi/Hashi._Earring_%2B1)).

### Skulk. Earring +1

- Vanar's copy has the lowest rolls: Accuracy/Magic Accuracy +11 and Store TP +3.

## Body

### Adhemar Jacket

- Its augments are Nolan Path B at rank 15, the path's maximums. Mezzotint stats grow with rank, so this copy is fully ranked.
- Vanar's copy doesn't have Path D, the caster path.

### Argute Gown +2

- Vanar's copy has no Magian augment, so it lacks the Enlightenment bonus.

### Atrophy Tabard +4

- By the player's Refresh priorities ([rules](Vanar_notes.md#rules-for-these-sets)), it fits both sets: its potency in the Refresh midcast and its Refresh +3 in idle sets.

### Bunzi's Robe

- Vanar's copy is rank 0 (player, 2026-10-02): no augments, only the base stats in its help text. The export prints no augments for it, not even `'Path: A'`.
- Vanar's copy is rank 0, without the rank 30 augment (Attack and Magic Damage +30, Physical damage limit +8%, Accuracy and Magic Accuracy +15, DEX+5), so the sims overvalue it ([rank-augments.md](../../docs/rank-augments.md#bunzis-robe)).

### Despair Mail

- This copy has no Nolan path, so it is unaugmented.
- As it is, Hashishin Mintan +3 (BLU) and Lethargy Sayon +3 (RDM) match or beat it in every combat stat (Accuracy 64 vs 23).
- It keeps only more HP (121 vs 87) and, against the Sayon, 1% more haste. For HP, Nyame Mail has more still (136) ([bg-wiki](https://www.bg-wiki.com/ffxi/Despair_Mail)).

### Gende. Bliaut +1

- Unaugmented.
- For RDM, Bunzi's Robe beats it for Cure (+15% vs +8%, plus DT -10%), and Lethargy Sayon +3 beats it for Refresh +X (+4 vs +2). Another piece Vanar owns covers each of its uses ([bg-wiki](https://www.bg-wiki.com/ffxi/Gende._Bliaut_%2B1)).

### Gleti's Cuirass

- Vanar's copy is rank 0 (player, 2026-10-02): no augments, only the base stats in its help text. The export prints no augments for it, not even `'Path: A'`.
- Vanar's copy is rank 0, without the rank 30 augment (Attack+30, Double Attack +10%, Accuracy and Magic Accuracy +15, status ailment resistance +10), so the sims overvalue it ([rank-augments.md](../../docs/rank-augments.md#gletis-cuirass)).

### Helios Jacket

- Unaugmented.
- For fast cast, its 3% loses to Luhlaza Jubbah +1 (7%) on BLU and Viti. Tabard +4 (15%) on RDM ([bg-wiki](https://www.bg-wiki.com/ffxi/Helios_Jacket)).

### Herculean Vest

- This copy is built for critical hits. Crit hit rate +5 is the Fern-stone maximum for its slot, for 8% in total.
- Its combined Accuracy+15 Attack+15 is below that slot's cap of 25.
- Pet: STR and Mag. Acc./MAB +3 are wasted ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Escha_Rewards/Arcane_Glyptics_Inscription)).
- For crit weapon skills, Gleti's Cuirass matches its 8% crit rate with more Accuracy (40 vs 30), Attack (40 vs 23) and STR (39 vs 28), plus Physical damage limit +9% ([bg-wiki](https://www.bg-wiki.com/ffxi/Herculean_Vest)).

### Ischemia Chasu.

- For RDM, Atrophy Tabard +4 beats it in every stat: Enfeebling skill 22 vs 18, Refresh +3 vs +2, Magic Accuracy 65 vs 15.
- For BLU, Hashishin Mintan +3 beats it in everything except enfeebling skill: Refresh +4, Accuracy and Magic Accuracy 64 ([bg-wiki](https://www.bg-wiki.com/ffxi/Ischemia_Chasu.)).

### Jhakri Robe +2

- Lethargy Sayon +3 (RDM) and Hashishin Mintan +3 (BLU) match its Refresh +4. They beat it in Accuracy, Attack, Magic Accuracy, Magic Attack Bonus, haste and DT.
- Jhakri keeps only 3 more STR, 3 to 5 more INT, and its count toward the Jhakri Fast Cast set bonus ([bg-wiki](https://www.bg-wiki.com/ffxi/Jhakri_Robe_%2B2)).

### Luhlaza Jubbah +1

- Vanar has 5 Enchainment merits (player, 2026-10-02), so Vanar gets the full amount: 5 × 100 = +500 from the merits and 5 × 50 = +250 from the augment, +750 in all, the maximum bg-wiki's [Enchainment](https://www.bg-wiki.com/ffxi/Enchainment) page gives.

### MG Jerkin +1

- If Vanar isn't an Elvaan male, he can't equip it ([bg-wiki](https://www.bg-wiki.com/ffxi/Magna_Attire_Set)).

### Nyame Mail

- Vanar's copy is Path B at rank 20 (player, 2026-10-04): Attack+25, Ranged Attack+25, Weapon skill damage +10% and Double Attack +3%. The export prints the path but not the rank.
- Vanar's copy is rank 20 Path B, so the sims overvalue it: rank 25 has 5 more Attack, 2% more Weapon skill damage and Double Attack, and STR and VIT +5 ([rank-augments.md](../../docs/rank-augments.md#nyame-mail)).

### Telchine Chas.

- This copy is the Regen-potency one. It has no Leaf or Snow augments and lacks the augmented 10% enhancing duration ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Alluvion_Skirmish_Armor)).

## Hands

### Adhemar Wristbands

- Its augments are Nolan Path B. Nolan gear ranks up to 15, and these are Path B's full values, so this copy is at rank 15.

### Asn. Armlets +2

- Vanar's copy lacks the Magian augment, so it is plain Treasure Hunter +2.

### Bunzi's Gloves

- Vanar's copy is rank 0 (player, 2026-10-02): no augments, only the base stats in its help text. Vanar's augmented Odyssey pieces export with `'Path: X'`; this one exports with no augments at all.
- It is the only multi-attack on Vanar's Bunzi's armor, since the Hat's Quadruple Attack is an augment from rank 21.
- Vanar's copy is rank 0, without the rank 30 augment (Attack and Magic Damage +30, Magic burst damage II +6, Accuracy and Magic Accuracy +15, MND+5), so the sims overvalue it ([rank-augments.md](../../docs/rank-augments.md#bunzis-gloves)).

### Chironic Gloves

- Vanar owns three copies.
- Copy `'"Fast Cast"+4','Mag. Acc.+9'`:
  - This is a Fast Cast roll. Chironic's Fast Cast augment rolls +1 to +6 (+7 with Fern stones), so this copy is 3 short of the best. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Escha_Rewards/Arcane_Glyptics_Inscription))
  - It gives Fast Cast 4% in precast. It shortens recast by only 2%, and only if it is also worn at midcast. ([ffxi-mechanics.md](../../docs/ffxi-mechanics.md#recast))
- Copy `'Mag. Acc.+20 "Mag.Atk.Bns."+20','"Conserve MP"+1','CHR+7','"Mag.Atk.Bns."+9'`:
  - This is a nuke and magic accuracy roll: Magic Accuracy 35 and MAB 44 in total with the native 15 and 15.
  - For RDM nukes and enfeebles, Leth. Ganth. +3 has more of each (Macc 62, MAB 52), plus Magic Damage +32 and DT -11%.
  - This copy keeps only the native Enhancing magic skill +15 and Spell interruption rate down 20%. ([bg-wiki](https://www.bg-wiki.com/ffxi/Chironic_Attire_Set))
- Copy with no augments:
  - Both augmented copies have every native stat this copy has, Spell interruption rate down 20% included, plus their augments, so either one beats it for every purpose. ([bg-wiki](https://www.bg-wiki.com/ffxi/Chironic_Gloves))
  - It has no augments to name it by, so a set asking for plain "Chironic Gloves" can get either augmented copy instead. ([ffxi-mechanics.md](../../docs/ffxi-mechanics.md#gear-and-gearswap))

### Gazu Bracelets

- On BLU, Assim. Bazu. +3 beats it on every stat: Accuracy 48 against 40 to 45, no Attack penalty, the same Haste+5%, more of every attribute, Evasion and Magic Evasion, and Damage taken -6% on top.
- On RDM, nothing Vanar owns beats it outright. (Help text of both pieces.)

### Gleti's Gauntlets

- Vanar's copy is rank 0 (player, 2026-10-02): no augments, only the base stats in its help text.
- Vanar's copy is rank 0, without the rank 30 augment (Attack+30, Store TP +8, Accuracy and Magic Accuracy +15, DEX+5), so the sims overvalue it ([rank-augments.md](../../docs/rank-augments.md#gletis-gauntlets)).

### Herculean Gloves

- This is a critical weapon skill roll.
- Vanar's copy has Crit. hit damage +4%, so it can't also have Weapon skill damage.
- STR+9 is 1 under the normal cap of 10 (15 with Taupe stones).
- Accuracy+18 Attack+18 is the combined Accuracy and Attack augment, which caps at 25. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Escha_Rewards/Arcane_Glyptics_Inscription))

### Merlinic Dastanas

- This copy's only MAB and Magic Accuracy are the augment's +18 each. ([bg-wiki](https://www.bg-wiki.com/ffxi/Merlinic_Attire_Set))
- This is a melee and nuke hybrid roll.
- It lacks Merlinic's caster rolls: Magic burst damage (up to +10%, +11% with Fern stones) and Fast Cast (up to +6, +7 with Fern stones).
- For RDM nukes, Leth. Ganth. +3 (Macc 62, MAB 52) is far ahead. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Escha_Rewards/Arcane_Glyptics_Inscription))
- wsdist's only entry has none of Vanar's augments: STR+12, DEX+6, Quadruple Attack +2, Accuracy and Attack +11, and Magic Accuracy and Magic Atk. Bonus +18.

### MG Gauntlets +1

- Leth. Ganth. +3 (RDM) and Hashi. Bazu. +3 (BLU) beat it on Accuracy, Attack, Magic Accuracy, MAB and DT.
- It is ahead only on Haste (+4% vs +3%), ranged stats, STR, AGI and MP. ([bg-wiki](https://www.bg-wiki.com/ffxi/MG_Gauntlets_%2B1))

### Nyame Gauntlets

- Vanar's copy is Path B at rank 20 **(player, 2026-10-08)**: Attack+25, Ranged Attack+25, Weapon skill damage +8% and Double Attack +2%. It was rank 17 from 2026-10-06. Vanar's Mail, Sollerets and Flanchard are Path B rank 20 and the Helm rank 14.
- Vanar's copy is rank 20 Path B, so the sims overvalue it: rank 25 has 5 more Attack, 2% more Weapon skill damage and Double Attack, and VIT+10 ([rank-augments.md](../../docs/rank-augments.md#nyame-gauntlets)).
- Against Jhakri Cuffs +2 in BLU's weapon skill set, at rank 17 (Vanar's rank from 2026-10-06 to 2026-10-08): the same WSD 7%, Attack 52 against 43, Double Attack +1%, MND 40 against 35 and DT -7%, for Accuracy 40 against 43 and INT 28 against 36. Expected damage at 2250 TP on bg-wiki's test enemy (1350 evasion, 1500 defense), from a calculation with the formulas in [ffxi-mechanics.md](../../docs/ffxi-mechanics.md), wsdist's race-less base stats, BLU/WAR, the melee spell set's Accuracy and Attack Bonus III and no buffs: Savage Blade +0.9 to +1.0%, Expiacion -0.2% with Grape Daifuku and +0.1% with Oden, Black Halo +1.2%, each for 2 to 3 less accuracy. So at rank 17 BLU wore them for Savage Blade only: Expiacion's two foods disagreed, and Black Halo's set is under the 1350 floor, where accuracy comes first.
- At rank 20 (Attack 55, WSD 8%, Double Attack +2%) they add about 0.8 to 0.9% to Savage Blade over rank 17, and beat Jhakri Cuffs +2 by about 0.6 to 0.7% on Expiacion for 2 less accuracy, both worked out with Accuracy Bonus III. With the spells' Accuracy Bonus IV **(player, 2026-10-08)**, Expiacion's set (with the Flanchard) is at about 1,391 with Grape Daifuku and 1,385 with Oden, so [Vanar_Blu_Gear.lua](Vanar_Blu_Gear.lua) wears them for Expiacion too. Black Halo with Maxentius and Bunzi's Rod is at about 1,365 and 1,359 with them, so its weapon skill set, the default one, wears them as well ([Vanar_notes.md](Vanar_notes.md#skill-and-accuracy-accuracy)).
- Against Atrophy Gloves +4 in RDM's weapon skill set they lose up to rank 21, so at rank 20 RDM keeps the gloves: WSD 9% and Accuracy 63 against 8% and 40, about 18% less Savage Blade damage on this calculation, and 5% less with Composure. From rank 22 their WSD matches or passes the gloves', with 23 less accuracy at every rank.

### Odyssean Gauntlets

- Vanar's copy is unaugmented, and neither RDM nor BLU can wear it, so it does nothing for those jobs.

### Pursuer's Cuffs

- This copy has no Nolan path augment. ([bg-wiki](https://www.bg-wiki.com/ffxi/Pursuer%27s_Cuffs))

### Telchine Gloves

- Vanar owns two copies.
- Copy `'"Regen" potency+3'`:
  - "Regen" potency+3 is the Dusk-stone maximum (+1 to +3). ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Alluvion_Skirmish_Armor))
  - It adds HP to each Regen tick and is read when the spell lands, so it goes in midcast Regen sets. ([ffxi-mechanics.md](../../docs/ffxi-mechanics.md#regen))
  - Regen potency and Enhancing magic duration are both Dusk augments, so this copy can never also have duration.
  - Its Leaf and Snow slots are empty. Leaf could add Haste up to +3%, Fast Cast up to +5% or Cure potency up to +8%. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Alluvion_Skirmish_Armor))
- Copy `'Haste+3','Enh. Mag. eff. dur. +10'`:
  - Both augments are at their maximums: Leaf Haste +1 to +3% and Dusk Enhancing magic duration +1 to +10%. The Snow slot is empty.
  - With the Dusk slot used for duration, this copy can't have Regen potency. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Alluvion_Skirmish_Armor))
  - The +10% duration is an augment, so it multiplies separately from native duration such as Atro. Gloves +4's 20%. ([bg-wiki](https://www.bg-wiki.com/ffxi/Lethargy_Armor_Set))
  - Its gear haste is 6% in total (3% native, 3% augment), which shortens recast when worn at midcast. ([ffxi-mechanics.md](../../docs/ffxi-mechanics.md#recast))

### Vanya Cuffs

- Its augments are Nolan Path B at full rank (rank 15). ([bg-wiki](https://www.bg-wiki.com/ffxi/Nolan))
- Neither of Vanar's jobs wears it since 2026-10-02 (player): RDM's fast cast already reaches 82% before any Cure piece, and RDM's Cure set takes Viti. Tabard +4's Healing magic skill +24 instead.

### Viti. Gloves +4

- Vanar has 5 levels **(player, 2026-10-02, changed)**, so the augment adds the full 15 seconds (5 × 3), on top of the merit's own 30 (5 × 6).
- Vanar's RDM has 481 enhancing skill without gear (404 + 36 gifts + 16 merits + 25 Master Levels; [Vanar's merits and skills](Vanar_notes.md#merits)). So 19 skill from gear reaches the cap, and these gloves' Enhancing magic skill +25 does it alone (481 + 25 = 506).

## Rings

### Ayanmo Ring

- Vanar owns no Ayanmo armor, so the set bonus never applies.
- It ties Jhakri Ring at Accuracy+6 in the ACC-mode sets; Jhakri's Attack+6 takes the slot. Lehko's Ring's DEX+10 is about 2 more accuracy than either, so RDM's Step set takes Lehko's too. Enlivened Ring (Accuracy+7, DEX+2) is in storage.

### Dark Ring

- Vanar owns two copies with different augments.
- Copy `'Phys. dmg. taken -3%','Breath dmg. taken -4%'`: Breath damage taken also rolls 1 to 6%, so this copy's -3% and -4% are mid-range.
- Copy `'Phys. dmg. taken -3%','Spell interruption rate down -3%'`: Spell interruption rate down rolls 1 to 5%. ([bg-wiki](https://www.bg-wiki.com/ffxi/Dark_Ring))
- Copy `'Phys. dmg. taken -3%','Breath dmg. taken -4%'`: The Breath -4% adds with DT toward the -50% breath cap. ([bg-wiki](https://www.bg-wiki.com/ffxi/Damage_Taken))

### Fencer's Ring

- The player's rule against Enspell gear that has to stay on while meleeing rules it out. ([ffxi-mechanics.md](Vanar_notes.md#rules-for-these-sets))

### Novennial Ring

- Vanar's Echad Ring beats it: +150% with a 30,000 cap, unlimited charges and a 120-minute reuse, against +100% with a 9,000 cap.
- Vanar's Caliber Ring (+150%, 30,000 cap) also beats it while Caliber has charges left. Caliber holds 3 and can't be recharged. (bg-wiki: [Experience Points](https://www.bg-wiki.com/ffxi/Experience_Points), [Caliber Ring](https://www.bg-wiki.com/ffxi/Caliber_Ring))

### Omega Ring

- Vanar's two Stikini Rings fill both ring slots with more magic accuracy (+8 plus +5 to every magic skill, against +3) and more MND.
- Against them, Omega adds only INT and CHR +3. Bringing it in just for that INT is what the player's rule rules out: no dedicated INT or MND pieces (player, 2026-10-02). ([bg-wiki](https://www.bg-wiki.com/ffxi/Stikini_Ring), [ffxi-mechanics.md](Vanar_notes.md#rules-for-these-sets))

### Perception Ring

- Stikini Ring strictly beats it: MND+5 against +2, Magic Accuracy+8 against +6, plus All magic skills +5.
- Vanar owns two Stikinis, enough for both ring slots. ([bg-wiki](https://www.bg-wiki.com/ffxi/Stikini_Ring))

### Stikini Ring

- Vanar's two unaugmented copies are both in the same bag (wardrobe) in both 2026-10-01 exports.
- If one fails to equip, pinning them with `{ bag = "wardrobe" }` and `{ bag = "wardrobe2" }` only works after one copy is moved to wardrobe 2.
- Until then, swap them as a pair. A set may wear one copy, but a set wearing both should not directly follow a set wearing one: GearSwap's copy matching can then pick the copy already worn for the other slot. ([export](../export/Vanar%202026-10-01%2022-41-03.lua))

## Back

### Atheling Mantle

- For melee, Vanar's Double Attack Ambuscade capes beat it outright: Rosmerta's on BLU and Sucellos's on RDM. Each has Accuracy+30, Attack+20, Double Attack+10% and Damage taken-5%.
- Its own Attack+20 and Double Attack+3% add nothing those capes lack. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:JSE_Capes))

### Fi Follet Cape +1

- **(player, 2026-10-02)** Vanar's copy is rank 11: Fast Cast 8%, Spell interruption rate -3%.
- In precast, its Fast Cast beats Swith Cape's 3% from rank 4 up and ties at rank 3.
- That matters on BLU, whose fast-cast set stays under the 80% cap: Fast Cast 52 from gear with this cape, plus at most 25% from BLU's trait.
- RDM's Stoneskin precast set reaches 89% with it and 81% without a back piece, so the cape changes nothing there; it replaced Swith Cape, which leaves both jobs' sets. ([bg-wiki](https://www.bg-wiki.com/ffxi/Swith_Cape))

### Ghostfyre Cape

- Vanar's copy has Enh. Mag. eff. dur. +20, the top of the range.
- Vanar's copy is below the maximum on each: Enhancing magic skill +5, Enfeebling magic skill +8 and Magic Accuracy +8.
- The player's rule excludes Enspell gear worn for melee ([rules](Vanar_notes.md#rules-for-these-sets)).

### Izdubar Mantle

- For nukes, the INT Ambuscade capes beat it outright: Sucellos's on RDM and Rosmerta's on BLU, with INT+20, Magic Accuracy+30, Magic Damage+20 and Magic Atk. Bonus+10.
- All it adds over them is MP+25 and Conserve MP+2. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:JSE_Capes))

### Mecisto. Mantle

- Vanar's copy has +48%, near the 50% maximum.

### Merciful Cape

- Fi Follet Cape +1 beats it for Enhancing magic skill (+9 vs +5) and MP (+45 vs +25).
- For Dark magic skill, Perimede Cape's +7 is higher, but Perimede carries Quick Magic +4%, which the player avoids. ([bg-wiki](https://www.bg-wiki.com/ffxi/Fi_Follet_Cape_%2B1))

### Ogapepo Cape

- The player avoids Quick Magic pieces ([rules](Vanar_notes.md#rules-for-these-sets)).
- For magic accuracy, Vanar's Ambuscade casting capes beat its +10 outright: Sucellos's MND and INT copies and Rosmerta's INT copy each have Magic Accuracy+30. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:JSE_Capes))

### Pahtli Cape

- Neither of Vanar's jobs wears it since 2026-10-02 (player): RDM's fast cast already reaches 82% before any Cure piece, and on BLU it only ties Fi Follet Cape +1's Fast Cast 8.

### Perimede Cape

- The player names this cape as one to avoid ([ffxi-mechanics.md](../../docs/ffxi-mechanics.md#quick-magic)). ([bg-wiki](https://www.bg-wiki.com/ffxi/Occasionally_Quickens_Spellcasting))
- Fi Follet Cape +1 beats it for Enhancing magic skill (+9 vs +7).
- Its Dark magic skill +7 is the highest on any back piece in Vanar's export. Merciful Cape has +5. ([bg-wiki](https://www.bg-wiki.com/ffxi/Fi_Follet_Cape_%2B1))

### Potentia Cape

- It has only STR+6 and INT+6. Vanar's Ambuscade capes give far more of each (STR+30 on the WSD copies, INT+20 on the INT copies) plus accuracy, so it has no RDM or BLU use. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:JSE_Capes))

### Refraction Cape

- For MND or INT work on RDM, Sucellos's MND and INT copies beat it outright: +20 of the stat against its +8, and Magic Accuracy+30 against its +3. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:JSE_Capes))

### Rosmerta's Cape

- Vanar owns four copies.
- Vanar has no Monster Correlation merits: Physical Potency 5 and Magical Accuracy 5 (player, 2026-10-02) fill BLU Group 1's 10 levels ([Vanar's merits and skills](Vanar_notes.md#merits)).
- Every copy carries "Efflux" TP bonus +250 in its base text. Vanar_Blu_Gear.lua's Efflux overlay names the Double Attack copy, as Mytha's names her Double Attack cape **(player, 2026-10-09)**.
- Copy `'DEX+20','Accuracy+20 Attack+20','DEX+10','Crit.hit rate+10'`: it has no Resin (fifth) augment, so unlike the Double Attack copy it has no Damage taken-5%. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:JSE_Capes))
- Copy `'INT+20','Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+10','"Mag.Atk.Bns."+10'`:
  - It has no Resin augment, and its Dye went to Magic Accuracy+10 instead of INT+10.
  - Its Magic Damage+20 adds to a spell's base damage (the D term) before any multiplier. ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Damage))
- Copy `'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%'`: it has no Resin (fifth) augment, so it carries no damage taken reduction. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:JSE_Capes))
- Copy `'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Dbl.Atk."+10','Damage taken-5%'`:
  - It is fully augmented.
  - Its Damage taken -5% is really 12/256 (about 4.7%), so count 4.7% toward the 50% DT cap.
- Simulated sets: the page names each cape only by its stat and main augment. How Vanar's copies match them:
  - Copy `'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%'`: matches the sims' STR, Weapon Skill Damage cape. BLU: Expiacion (Mid buff, High buff); Savage Blade (Mid buff, High buff).
  - Copy `'DEX+20','Accuracy+20 Attack+20','DEX+10','Crit.hit rate+10'`: matches the sims' DEX, Crit Rate cape. BLU: Chant du Cygne (Mid buff, High buff).
  - The other sets use capes with different augments from all of Vanar's copies. BLU: Caliburnus + Thibron AM1 TP [DEX, Dual Wield] (-50% DT); Tizona + Thibron AM3 TP [DEX, Store TP] (-50% DT); Imperator [DEX, Weapon Skill Damage] (High buff); Sanguine Blade [INT, Weapon Skill Damage] (Mid buff, Ice Brand enabled); Red Lotus Blade [INT, Weapon Skill Damage] (Mid buff, Ice Brand enabled); Requiescat [MND, DA] (Mid buff, High buff).
  - Vanar's INT/Magic Accuracy/Magic Atk. Bonus and DEX/Double Attack copies are in no simulated set.

### Sucellos's Cape

- Vanar owns five copies.
- Copy with no augments: it adds nothing the four augmented copies lack, and it sits in the Mog Safe, out of GearSwap's reach. ([bg-wiki](https://www.bg-wiki.com/ffxi/Sucellos%27s_Cape))
- Copy `'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%','Damage taken-5%'`: it is fully augmented.
- Copy `'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Dbl.Atk."+10','Damage taken-5%'`: it is fully augmented.
- Copy `'MND+20','Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+10','Haste+10'`:
  - Haste+10 is the Sap augment's maximum, 10% gear haste.
  - Worn at midcast, it shortens the enfeeble's recast and counts toward the 25% gear haste cap.
  - It has no Resin augment. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:JSE_Capes))
  - The native Enfeebling magic effect +10 makes it a potency piece as well as the accuracy cape. ([bg-wiki](https://www.bg-wiki.com/ffxi/Sucellos%27s_Cape))
- Copy `'INT+20','Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+10','"Mag.Atk.Bns."+10'`:
  - It has no Resin augment, and its Dye went to Magic Accuracy+10 instead of INT+10.
  - Its Magic Damage+20 adds to a spell's base damage (the D term) before any multiplier. ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Damage))
- Simulated sets: the page names each cape only by its stat and main augment. How Vanar's copies match them:
  - Copy `'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%','Damage taken-5%'`: matches the sims' STR, Weapon Skill Damage cape. RDM: Savage Blade (Mid buff, High buff); Death Blossom (Mid buff, High buff); Knights of Round (Mid buff, High buff); Seraph Blade (Mid buff); Red Lotus Blade (Mid buff); Mercy Stroke (Mid buff, High buff); Black Halo (Mid buff).
  - Copy `'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%','Damage taken-5%'`: for the magical weapon skills, Seraph Blade and Red Lotus Blade, the page doesn't say whether the sims' cape has Accuracy and Attack +20, as this copy does, or Magic Accuracy and Magic Damage +20. Current wsdist has both versions ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), lines 1204 and 1209).
  - Copy `'INT+20','Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+10','"Mag.Atk.Bns."+10'`: the nearest to the sims' INT, Magic Attack cape. RDM: Casting (Free Nuke, Magic Burst). Current wsdist builds that cape with INT+30 where this copy has INT+20 and Magic Accuracy+10 ([gear.py](https://github.com/IzaKastra/wsdist_beta/blob/main/gear.py), line 1220).
  - The other sets use capes with different augments from all of Vanar's copies. RDM: Chant du Cygne [DEX, Crit Rate] (Mid buff, High buff); Evisceration [DEX, Crit Rate] (Mid buff, High buff); Naegling + Thibron TP [DEX, Store TP] (-50% DT, -25% DT); Imperator [DEX, Weapon Skill Damage] (High buff); Aeolian Edge [INT, Weapon Skill Damage] (Mid buff); Requiescat [MND, Weapon Skill Damage] (Mid buff, High buff); Sanguine Blade [MND, Weapon Skill Damage] (Mid buff); Black Halo [MND, Weapon Skill Damage] (High buff).
  - Vanar's DEX/Double Attack and MND/Magic Accuracy/Haste copies, and the copy with no augments, are in no simulated set.

### Swith Cape

- Fi Follet Cape +1 (Path A) gives more from rank 4 up, reaching +10% at rank 15. Vanar's is rank 11 (Fast Cast 8%), so neither job wears Swith Cape. ([bg-wiki](https://www.bg-wiki.com/ffxi/Swith_Cape))

### Toutatis's Cape

- Copy with no augments: Vanar holds two, both in the Mog Safe. ([bg-wiki](https://www.bg-wiki.com/ffxi/Toutatis%27s_Cape))
- Copy `'DEX+20','Accuracy+20 Attack+20','Accuracy+10','Crit.hit rate+10'`: a crit build with no Resin augment. ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:JSE_Capes))

### Twilight Cape

- Vanar's export has neither (its only obi is Fucho-no-Obi), so under bg-wiki's reading the cape's bonus applies only some of the time. ([bg-wiki](https://www.bg-wiki.com/ffxi/Magic_Damage))

## Waist

### Cascade Belt

- On RDM and BLU, other waists Vanar owns beat each of its stats. Olympus Sash has more Enhancing magic skill (+5 vs +3). Porous Rope has the same MND+7 plus Magic Accuracy+5. ([bg-wiki](https://www.bg-wiki.com/ffxi/Olympus_Sash), [bg-wiki](https://www.bg-wiki.com/ffxi/Porous_Rope))
- RDM's enhancing set has 545 skill at Master Level 25: 481 without gear (404 + 36 gifts + 16 merits + 25 Master Levels) plus Viti. Tabard +4's 24, Leth. Houseaux +3's 35 and Ghostfyre Cape's 5.
- That caps Stoneskin with skill alone (545 - 190 = 355), so Siegel Sash's +20 past the cap is worth more there. ([bg-wiki](https://www.bg-wiki.com/ffxi/Stoneskin), [bg-wiki](https://www.bg-wiki.com/ffxi/Siegel_Sash))

### Casso Sash

- Rumination Sash beats it for enfeebling: skill +7 vs +5, plus Magic Accuracy+3 and MND+4. ([bg-wiki](https://www.bg-wiki.com/ffxi/Rumination_Sash))
- For dark magic accuracy, Eschan Stone's 7 beats its 5.

### Dynamic Belt +1

- On BLU, Hurch'lan Sash beats it (Accuracy+15 vs +11, Haste+7% vs +6%), leaving Dynamic only its STR+4. RDM can't wear Hurch'lan Sash. ([bg-wiki](https://www.bg-wiki.com/ffxi/Hurch%27lan_Sash), [bg-wiki](https://www.bg-wiki.com/ffxi/Dynamic_Belt_%2B1))

### Kentarch Belt +1

- Vanar's copy has no augments (rank 0), so it lacks the Unity Path A augment.

### Obstin. Sash

- **(player, 2026-10-06)** Vanar's copy is rank 17: Magic Accuracy+15 and Enfeebling magic skill +2, and no Enmity (from rank 21). It was rank 13 on 2026-10-05, which replaced the rank 20 recorded on 2026-10-04.
- At rank 17 it is worth Magic Accuracy+17 on enfeebles (15, plus the 2 skill), against Rumination Sash's +10, and +15 on dark, divine and elemental magic, against Eschan Stone's +7. So it stays RDM's waist for enfeebling, dark and divine magic and the elemental debuffs, as the player had it at rank 20 **(player, 2026-10-04)**.
- Against Rumination Sash it gives up 5 enfeebling skill and Spell interruption rate down 10%. At Vanar's 586 skill in the potency set (Master Level 25), that is two points of Frazzle III (108 against 110) and one of Distract III (113 against 114) ([ffxi-mechanics.md](../../docs/ffxi-mechanics.md#potency-by-spell)). With Saboteur on a normal monster and the set's effect +45%, that is 349 against 355 and 363 against 366, if dMND is past +50.
  - With their innate +150, Frazzle III and Distract III have about 1,600 magic accuracy in that set engaged, and 1,680 with the casting weapons (with Crepe B. Helene, dMND not counted). A level 150 foe at a 100% rank needs about 1,400 ([ffxi-mechanics.md](../../docs/ffxi-mechanics.md#macc-needed-to-cap)), so the sash's extra magic accuracy does nothing on those two spells, and what it gains there is its 5% duration.
- Against Eschan Stone in RDM's nuke set, by a calculation with the hit rate, resist and MAB formulas in [ffxi-mechanics.md](../../docs/ffxi-mechanics.md#magic-hit-rate) (dINT not counted):
  - Eschan's MAB 7 is worth 1.3% to 1.5%. The sash's 8 more magic accuracy only pays while the set is short of the 95% hit rate cap, and it beats Eschan once the set is 3 or more short.
  - With the casting weapons and Crepe B. Helene the set has 1,365 magic accuracy, and 1,290 engaged with Naegling and Thibron. That caps a level 145 foe at a 100% rank (by 89, and by 14 engaged), so Eschan wins there and against anything weaker.
  - Against a level 150 foe, or a level 135 foe at a 30% rank, the set is 35 to 112 short, and the sash would add 6% to 12%.
  - The magic burst set has 39 less, before a burst's own magic accuracy bonus. At rank 13 the sash's 6 more magic accuracy gave the same winner against every one of these foes, so the rank doesn't change the nuke set.
  - With the melee foods in place of Crepe B. Helene, the set has 1,385 magic accuracy free and 1,310 engaged with Oden, and 1,315 and 1,240 with Grape Daifuku, which leaves an engaged cast 36 short of a level 145 foe.
  - **(player, 2026-10-07)** The nuke set's waist stays Eschan Stone: magic accuracy doesn't strictly come first in nuke sets.
- In RDM's magical weapon skill sets, Eschan Stone (MAB 7, about 1.4% on Sanguine Blade) and Fotia Belt (+25/256 fTP, 2% to 4% of the fTP part at the TP the weapon modes reach, plus Magic Accuracy+10) stay in TP mode. The sash has 8 and 5 more magic accuracy than they do, which pays only below the cap, and how much magic accuracy these weapon skills get is unsettled ([ffxi-mechanics.md](../../docs/ffxi-mechanics.md#where-wsdist-and-bg-wiki-disagree)), so how far they are from the cap can't be worked out. In ACC mode, where magic accuracy comes first **(player, 2026-10-07)**, the sash takes the waist of all four.
- BLU can't wear it, so BLU's enfeebling waist stays Rumination Sash.

### Oneiros Sash

- For RDM, Eschan Stone beats it on every stat: MAB+7 vs +4, the same HP+20 and MP+20, plus Magic Accuracy+7 and Accuracy/Attack+15. BLU can't wear Oneiros Sash. ([bg-wiki](https://www.bg-wiki.com/ffxi/Eschan_Stone), [bg-wiki](https://www.bg-wiki.com/ffxi/Oneiros_Sash))

### Ovate Rope

- For spells that only need to land, it has 1 more Magic Accuracy than Eschan Stone (+8 vs +7), plus MND+4.
- For RDM's enfeebling magic, Rumination Sash is better, and Obstin. Sash at Vanar's rank 17 better still.

### Phasmida Belt

- Dynamic Belt +1 beats it for melee on both jobs: Accuracy+11 vs +6, the same Haste+6%, plus STR+4. Only Phasmida's Evasion+6 is extra. ([bg-wiki](https://www.bg-wiki.com/ffxi/Dynamic_Belt_%2B1))
- On BLU, Hurch'lan Sash (Accuracy+15, Haste+7%) also beats it. ([bg-wiki](https://www.bg-wiki.com/ffxi/Hurch%27lan_Sash))

### Rumination Sash

- On enfeebles its +10 is more than Eschan Stone (+7) or Ovate Rope (+8).
- Obstin. Sash took its place in RDM's sets **(player, 2026-10-04)**. At Vanar's rank 17 **(player, 2026-10-06)** it is worth +17 on enfeebles against this sash's +10. BLU can't wear Obstin. Sash, so this is still BLU's enfeebling waist.

### Sailfi Belt +1

- **(player, 2026-10-04)** Vanar's copy is rank 14: STR+14 and Double Attack+5%.

### Twilight Belt

- On BLU, Sailfi Belt +1 beats it at any Path A rank: Haste+9% vs +7%, and Triple Attack+2% instead of Double Attack+2%, plus Path A Double Attack from rank 6. RDM can't wear Twilight Belt. ([bg-wiki](https://www.bg-wiki.com/ffxi/Twilight_Belt), [bg-wiki](https://www.bg-wiki.com/ffxi/Sailfi_Belt_%2B1))

### Witful Belt

- It is the only Fast Cast waist in Vanar's export that BLU can wear. Embla Sash and Channeler's Stone are not BLU gear. ([bg-wiki](https://www.bg-wiki.com/ffxi/Embla_Sash), [bg-wiki](https://www.bg-wiki.com/ffxi/Channeler%27s_Stone))

## Legs

### Assim. Shalwar +1

- Its "Burst Affinity"+12 adds 0.12 to the WSC multiplier under Burst Affinity, with Hashi. Basmak +3's +21: 2.33 in place of 2 ([gear-notes.md](../../docs/gear-notes.md#assim-shalwar-1)). Vanar_Blu_Gear.lua wears it in the Burst Affinity overlay **(player, 2026-10-09: Mytha's buff-set pieces, in Vanar's tier)**, and for its Spell interruption rate down 20% in the magical SIRD set.
- **(player, 2026-10-08)** It is moving from the Mog Case to a wardrobe.

### Atro. Tights +4

- Its Enhancing magic skill +22 is the most of any legs Vanar owns. Carmine Cuisses +1 has +18, Portent Pants +15 and Rawhide Trousers +10 (help text, with augments from the [export](../export/Vanar%202026-10-01%2022-41-03.lua)).

### Bunzi's Pants

- Vanar's copy is rank 0 (player, 2026-10-02): no augments, only the base stats in its help text. The export prints no augments for it, not even `'Path: A'`.

### Carmine Cuisses +1

- Vanar's copy is Nolan Path D at full rank.
- Vanar owns no other Carmine +1 piece, so the set bonus never applies.
- wsdist's entry matches Vanar's Path D copy. Its missing Carmine +1 set bonus doesn't matter, since Vanar owns only the cuisses.

### Chironic Hose

- This is a Healing-path magic accuracy copy. Its Mag. Acc.+28 sits in bg-wiki's Healing-path range of +1 to +40.
- MND+12 is in the base-stat roll, which caps at +10 (+15 with Taupe Stones).
- It has no special-stat augment. That slot rolls one stat, such as Cure potency, Cure spellcasting time or Fast Cast (Fern Stone caps: +11%, -11% and +7) ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Escha_Rewards/Arcane_Glyptics_Inscription)).
- Totals are Magic Accuracy+48, MND+41 and Enfeebling skill +13.
- Leth. Fuseau +3 (Magic Accuracy 63, MND 43) and Atro. Tights +4 (Magic Accuracy 59 plus the Atrophy set, MND 44) beat it on both. Its only case for enfeebling is its skill (help text, with augments from the [export](../export/Vanar%202026-10-01%2022-41-03.lua)).

### Crimson Cuisses

- Vanar's copy has the minimum, Fast Cast +1.
- Carmine Cuisses +1 beats its movement speed in the same slot (18% vs 12%).
- For fast cast, Enif Cosciales (8%, BLU but not RDM) and Orvail Pants +1 (5%) beat its +1.

### Gleti's Breeches

- Vanar's copy is rank 0 (player, 2026-10-02): no augments, only the base stats in its help text. The export prints no augments for it, not even `'Path: A'`.
- Vanar's copy is rank 0, without the rank 30 augment (Attack+30, Subtle Blow +15, Accuracy and Magic Accuracy +15, Triple Attack +5%), so the sims overvalue it ([rank-augments.md](../../docs/rank-augments.md#gletis-breeches)).

### Hashishin Tayt +3

- Its "Efflux" TP Bonus +800 goes in the Efflux overlay with the Double Attack Rosmerta's Cape (+250). Vanar's BLU has every job point, so its Efflux category is at 20 (+200): an Efflux cast has 1000 + 800 + 250 + 200 = 2250 TP bonus ([ffxi-mechanics.md](../../docs/ffxi-mechanics.md#chain-affinity-burst-affinity-efflux-and-azure-lore)).

### Herculean Trousers

- This is a physical weapon skill copy.
- Accuracy+18 Attack+18 is in the combined slot, which caps at 25.
- Weapon skill damage +4% is at the normal cap (5% with Fern Stones).
- The extra Accuracy+13 is in a slot that caps at 15 ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Escha_Rewards/Arcane_Glyptics_Inscription)).
- Vanar's Nyame Flanchard (Path B, rank 20) beats it in all four: Accuracy 40 vs 31, Attack 55 vs 33, STR 43 vs 40 and WSD 9% vs 4%; see [rank-augments.md](../../docs/rank-augments.md#nyame-flanchard) for each rank.
- Luh. Shalwar +4 has WSD +12% and Accuracy+50. So this copy has no use in BLU weapon skill sets ([bg-wiki](https://www.bg-wiki.com/ffxi/Nyame_Flanchard)).

### Luh. Shalwar +4

- Vanar has no Assimilation merits: Diffusion 5 and Enchainment 5 (player, 2026-10-02) fill BLU Group 2's 10 levels. So the augment gives him 0% (0 × 3%); the +15% figure below assumes 5 merits he doesn't have ([Vanar's merits and skills](Vanar_notes.md#merits)).

### Merlinic Shalwar

- Vanar has two copies: an augmented one in storage and a bare one in safe2.
- Copy `'Mag. Acc.+25 "Mag.Atk.Bns."+25','Magic burst dmg.+1%','INT+7','Mag. Acc.+11','"Mag.Atk.Bns."+13'`:
  - This is a nuking copy. Its Mag. Acc.+25 MAB+25 is at the combined slot's cap.
  - Its Magic burst damage +1% is the bottom of a roll that goes up to +10% (+11% with Fern Stones), so it is weak for bursting ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Escha_Rewards/Arcane_Glyptics_Inscription)).
  - Leth. Fuseau +3 beats it on every nuke and burst stat except INT (48 vs 50) and Enmity: Magic Accuracy 63 vs 56, MAB 58 vs 53, Magic Damage 33 vs 13, Magic burst damage 15 vs 1 (help text, with augments from the [export](../export/Vanar%202026-10-01%2022-41-03.lua)).
- Copy with no augments:
  - The augmented copy has the same base stats plus Magic Accuracy+36, MAB+38, INT+7 and Magic burst damage +1%. So it strictly beats this one (help text, with augments from the [export](../export/Vanar%202026-10-01%2022-41-03.lua)).

### Nyame Flanchard

- Vanar's copy is Path B at rank 20 **(player, 2026-10-09)**: Attack+25, Ranged Attack+25, Weapon skill damage +9% and Double Attack +3%. It was rank 18 from 2026-10-08, rank 17 from 2026-10-07 and rank 11 from 2026-10-04. The export prints the path but not the rank.
- It is RDM's weapon skill legs, as in bg-wiki's set **(player, 2026-10-04)**. Rank 17 added about 1.6% to Savage Blade and Black Halo over rank 11, on the calculation under [Nyame Gauntlets](#nyame-gauntlets).
  - Leth. Fuseau +3 would trade its Weapon skill damage +9%, Double Attack +3% and Damage taken -8% for Accuracy 63 vs 40, Attack 63 vs 55 and STR+MND 81 vs 75.
  - That calculation puts RDM's weapon skill set at about 1,242 accuracy for Savage Blade and 1,173 for Black Halo with Grape Daifuku, and 6 or 7 less with Oden **(player, 2026-10-07: RDM eats one of the two)**: under the player's 1350 floor, where the rule puts accuracy first. There the Fuseau is worth about 12% more Savage Blade and 22% more Black Halo without buffs, and with Composure's +70 accuracy about 3% less Savage Blade and 12% more Black Halo. The player's `/checkparam` decides it.
  - **In Vanar_Rdm_Gear.lua:** the weapon skill sets hold the floor, the player's later rule. Since Composure's +70 counts toward it **(player, 2026-10-09)**, Savage Blade, the default set and Requiescat wear the Flanchard again. Black Halo, whose club hand is about 70 behind, keeps Leth. Fuseau +3 ([Vanar_notes.md](Vanar_notes.md#skill-and-accuracy-accuracy)).
- Against Luh. Shalwar +4 in BLU's weapon skill sets, at rank 17 (rank 20 adds Attack +3, WSD +1% and Double Attack +2%): WSD 8% against 12%, Attack 52 against none, Double Attack +1%, MND 32 against 27 and DT -8%, for Accuracy 40 against 50 and STR 43 against 46.
  - Expected damage on the same calculation, with the melee spell set's Accuracy Bonus III and Attack Bonus III **(player, 2026-10-07: the set gives both; tier not recorded)**: Savage Blade (with the Nyame Gauntlets) +0.8% with Grape Daifuku and +1.1% with Oden, Expiacion +0.5% and +0.6%, Black Halo +1.2% and +1.4%. At rank 20 the first two would be about +1.0%. The Accuracy Bonus has since turned out to be tier IV **(player, 2026-10-08)**; these weren't worked out again.
  - At tier IV the 10 accuracy leaves Savage Blade's set at about 1,395 and Expiacion's at 1,393 with Grape Daifuku, 6 less with Oden, so both wear the Flanchard. Black Halo keeps the Shalwar: with Maxentius, Bunzi's Rod and the Nyame Gauntlets it is at about 1,365 and 1,359, and the Flanchard's 10 would put it at about 1,349 with Oden, under the 1350 floor. With Thibron in the off hand, as in the rahvin branch's `sets.WS`, it is 1,327 and 1,321 ([Vanar_notes.md](Vanar_notes.md#skill-and-accuracy-accuracy)).
- Vanar's copy is rank 20 Path B, so the sims overvalue it: rank 25 has 5 more Attack, 2% more Weapon skill damage, 2% more Double Attack and STR+10 ([rank-augments.md](../../docs/rank-augments.md#nyame-flanchard)).
- wsdist has a rank 20 entry, Vanar's rank.

### Odyssean Cuisses

- This copy is unaugmented ([bg-wiki](https://www.bg-wiki.com/ffxi/Odyssean_Cuisses)).

### Orvail Pants +1

- Vanar's copy lacks the optional MP+60 augment.
- On BLU, Enif Cosciales (Fast Cast 8%) beats it.
- On RDM it is the best Fast Cast legs Vanar owns. The only other is Crimson Cuisses, at +1 (help text, with augments from the [export](../export/Vanar%202026-10-01%2022-41-03.lua)).

### Portent Pants

- Its Enhancing skill +15 is below Atro. Tights +4 (+22) and Carmine Cuisses +1 (+18).
- Its Enfeebling skill +15 is the most of any legs Vanar owns (Chironic Hose has +13), but it has no magic accuracy (help text, with augments from the [export](../export/Vanar%202026-10-01%2022-41-03.lua)).

### Rawhide Trousers

- This copy is unaugmented.

### Samnuha Tights

- Vanar's copy has STR+9, DEX+8, DA +2% and TA +2%.
- wsdist's entry is 1 STR, 2 DEX, 1% Double Attack and 1% Triple Attack above Vanar's copy.

### Taeon Tights

- Its Accuracy+18 Attack+18 is near its cap of 20, and its Dual Wield+5 is at its cap of 5 ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Alluvion_Skirmish_Armor)).
- As a dual-wield TP piece, Carmine Cuisses +1 (Path D) beats it: DW+6 vs +5, Accuracy+55 vs +25, Attack+47 vs +18.
- Taeon only adds Triple Attack +2% (help text, with augments from the [export](../export/Vanar%202026-10-01%2022-41-03.lua)).

### Tatsu. Sitagoromo

- Leth. Fuseau +3 beats it in every stat: Haste+5% vs +3%, Accuracy+63 vs +7, INT/MND/CHR 48/43/30 vs 2 each. So it has no use for RDM (help text, with augments from the [export](../export/Vanar%202026-10-01%2022-41-03.lua)).

### Telchine Braconi

- Vanar's copy has duration. Vanar's Telchine Chasuble, Pigaches and one of the Telchine Gloves have Regen potency +3.
- The Leaf slot of Vanar's copy is empty.

## Feet

### Assim. Charuqs +2

- Its "Chain Affinity"+22 adds 22 to the base damage of every hit of a physical spell under Chain Affinity, past the spell's damage cap ([gear-notes.md](../../docs/gear-notes.md#assim-charuqs-2)). Vanar_Blu_Gear.lua wears it in the Chain Affinity overlay, Mytha's piece and tier **(player, 2026-10-09)**. Hashishin Kavuk +3's +28 is in the physical sets' head.
- **(player, 2026-10-08)** It is moving from the Mog Case to a wardrobe.

### Bunzi's Sabots

- Vanar's copy is rank 0 (player, 2026-10-02): no augments, only the base stats in its help text. The export prints no augments for it, not even `'Path: A'`.

### Eschite Greaves

- This copy has no Nolan path augment ([bg-wiki](https://www.bg-wiki.com/ffxi/Eschite_Greaves)).

### Gleti's Boots

- Vanar's copy is rank 0 (player, 2026-10-02): no augments, only the base stats in its help text. The export prints no augments for it, not even `'Path: A'`.
- Vanar's copy is rank 0, without the rank 30 augment (Attack+30, Evasion+15, Accuracy and Magic Accuracy +15, STR+5), so the sims overvalue it ([rank-augments.md](../../docs/rank-augments.md#gletis-boots)).

### Hashi. Basmak +3

- Its "Burst Affinity"+21 adds 0.21 to the WSC multiplier under Burst Affinity ([ffxi-mechanics.md](../../docs/ffxi-mechanics.md#chain-affinity-burst-affinity-efflux-and-azure-lore)). It is the magical sets' feet anyway, and the Burst Affinity overlay names it with Assim. Shalwar +1 (+12): 2.33 in all.

### Herculean Boots

- Vanar owns three copies.
- Copy `'Weapon skill damage +4%','Pet: Haste+3','Accuracy+5 Attack+5'`: the weapon skill copy. WSD +4% (the slot caps at 5% with a Fern Stone), but its combined roll is only Accuracy+5 Attack+5 of a possible +25, for totals of Accuracy 15 and Attack 15.
- Copy `'Weapon skill damage +4%','Pet: Haste+3','Accuracy+5 Attack+5'`: its Pet: Haste line does nothing for BLU ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Escha_Rewards/Arcane_Glyptics_Inscription)).
- Copy `'Weapon skill damage +4%','Pet: Haste+3','Accuracy+5 Attack+5'`: Vanar's Nyame Sollerets beats it in every BLU weapon skill set. At its Path B rank 20 the Sollerets have WSD +8% and Attack 55. For other ranks, see [rank-augments.md](../../docs/rank-augments.md#nyame-sollerets) ([bg-wiki](https://www.bg-wiki.com/ffxi/Nyame_Sollerets)).
- Copy `'Accuracy+21 Attack+21','"Triple Atk."+2','Attack+10'`: the melee TP copy. Totals: Accuracy 31, Attack 41, Triple Attack 4% (2 base + 2 augmented) and Haste 4%.
- Copy `'Accuracy+21 Attack+21','"Triple Atk."+2','Attack+10'`: the Triple Attack augment caps at 3, or 4 with a Fern Stone ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Escha_Rewards/Arcane_Glyptics_Inscription)).
- Copy `'Accuracy+23 Attack+23','Crit. hit damage +1%','DEX+3','Accuracy+9','Attack+12'`: the accuracy copy, with Accuracy 42 and Attack 45 in total.
- Copy `'Accuracy+23 Attack+23','Crit. hit damage +1%','DEX+3','Accuracy+9','Attack+12'`: its special-stat slot rolled only Crit. hit damage +1% (cap 4%, or 5% with a Fern Stone), so it has no WSD or multi-attack augment ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:Escha_Rewards/Arcane_Glyptics_Inscription)).

### Inspirited Boots

- On Vanar's self-cast Refresh III, the base is 150 s + 30 s (5 Enhancing Magic Duration merits × 6) + 20 s (job points) = 200 s, so +15 s is +7.5% (15 / 200). With Viti. Gloves +4's +15 s (5 × 3) the base is 215 s, and it is about +7% (15 / 215). For self-cast Refresh that is less than the native +40% from Leth. Houseaux +3 (bg-wiki: [Refresh](https://www.bg-wiki.com/ffxi/Refresh), [Refresh III](https://www.bg-wiki.com/ffxi/Refresh_III), [Lethargy Armor Set](https://www.bg-wiki.com/ffxi/Lethargy_Armor_Set)).

### Luhlaza Charuqs +1

- Vanar has 5 Diffusion merits (player, 2026-10-02), so a diffused buff gets the full +45%.

### Merlinic Crackows

- This copy is a nuking roll: Magic Accuracy 35 and MAB 45 in total, plus Enmity-2.
- Vanar's copy has no Fast Cast augment, so precast gets only the base 5%.
- For RDM nukes, Leth. Houseaux +3 (Magic Accuracy 60, MAB 50, Magic Damage 30, INT 30) beats it on every nuking stat.
- That leaves this copy its base Fast Cast 5% and Drain/Aspir potency +7 (bg-wiki: [Merlinic Crackows](https://www.bg-wiki.com/ffxi/Merlinic_Crackows), [Leth. Houseaux +3](https://www.bg-wiki.com/ffxi/Leth._Houseaux_%2B3)).
- Against Vanar's copy, wsdist's only entry is 35 Magic Accuracy and 30 Magic Atk. Bonus short for nukes. The Magic Accuracy gap matters only against an enemy given Magic Evasion; every wsdist preset, the sims' "BG Wiki sets" included, has 0 ([ffxi-mechanics.md](../../docs/ffxi-mechanics.md#where-wsdist-and-bg-wiki-disagree)).

### Nyame Sollerets

- Vanar's copy is Path B at rank 20 (player, 2026-10-04): Attack+25, Ranged Attack+25, Weapon skill damage +8% and Double Attack +2%. The export prints the path but not the rank.
- Vanar's copy is rank 20 Path B, so the sims overvalue it: rank 25 has 5 more Attack, 2% more Weapon skill damage and Double Attack, and Accuracy+8 ([rank-augments.md](../../docs/rank-augments.md#nyame-sollerets)).

### Odyssean Greaves

- This copy is unaugmented ([bg-wiki](https://www.bg-wiki.com/ffxi/Odyssean_Greaves)).

### Rawhide Boots

- Vanar's Taeon Boots (Dual Wield +8, Accuracy 32) give more of both.
- Rawhide is ahead only on Waltz potency +8% and a few points of STR, DEX, MND and CHR (bg-wiki: [Rawhide Boots](https://www.bg-wiki.com/ffxi/Rawhide_Boots), [Taeon Boots](https://www.bg-wiki.com/ffxi/Taeon_Boots), [Alluvion Skirmish armor](https://www.bg-wiki.com/ffxi/Category:Alluvion_Skirmish_Armor)).

### Rubeus Boots

- Vanar owns no other Rubeus piece, so the set bonus never applies.
- Vanar's other RDM feet beat each magic skill on it that RDM uses, all against its +10: Leth. Houseaux +3 has Enhancing magic skill +35, Viti. Boots +4 Enfeebling magic skill +17 and Vanya Clogs Healing magic skill +20 (bg-wiki: [Rubeus Boots](https://www.bg-wiki.com/ffxi/Rubeus_Boots), [Leth. Houseaux +3](https://www.bg-wiki.com/ffxi/Leth._Houseaux_%2B3), [Viti. Boots +4](https://www.bg-wiki.com/ffxi/Viti._Boots_%2B4), [Vanya Clogs](https://www.bg-wiki.com/ffxi/Vanya_Clogs)).

### Taeon Boots

- This copy is at or near max on each stone: Accuracy+25 (the Snowslit cap), Dual Wield +4 (Leaf cap +5) and STR+7 VIT+7 (the Dusk cap). Totals: Dual Wield +8 and Accuracy 32.

### Vanya Clogs

- This copy has the full Nolan Path D: Cure potency 10% in total (5 base + 5), Cure spellcasting time -15% and Conserve MP+6.

### Viti. Boots +4

- Vanar's Group 2 merits (Enhancing Magic Duration 5, Magic Accuracy 5) fill all 10 of the group's levels (5 + 5 = 10). So he has no Immunobreak Chance merits, and this augment adds nothing for him (0 × 1% = 0%).

## Pieces the simulated sets use that Vanar doesn't own

Gear in bg-wiki's simulated sets ([Red Mage](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets/Red_Mage), [Blue Mage](https://www.bg-wiki.com/ffxi/All_Jobs_Gear_Sets/Blue_Mage)) that Vanar doesn't own: it is in no bag and on no storage slip of the 2026-10-04 export. Names are as the pages print them. A bracket gives the path the page names, or a cape's stat and main augment. What the sets assume is in [ffxi-mechanics.md](../../docs/ffxi-mechanics.md#simulated-sets-bg-wiki-all-jobs-gear-sets).

**RDM**

| Piece | Sets that use it |
|---|---|
| Alabaster Mantle | Imperator, Ruthless Stroke |
| Anu Torque | Naegling + Thibron TP |
| Archduke's Sword | EnSpell |
| Archon Ring | Sanguine Blade |
| Aurgelmir Orb +1 | Naegling + Thibron TP |
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

- Capes: of the sims' Ambuscade capes, Vanar's Sucellos's Capes match only the STR, Weapon Skill Damage one (the Seraph Blade and Red Lotus Blade sims may use its Magic Accuracy and Magic Damage version) and come nearest to the INT, Magic Attack one (INT+20 and Magic Accuracy+10 where the sims' cape has INT+30). His Rosmerta's Capes match only the STR, Weapon Skill Damage and DEX, Crit Rate ones. See [Sucellos's Cape](../../docs/gear-notes.md#sucelloss-cape) and [Rosmerta's Cape](../../docs/gear-notes.md#rosmertas-cape).
- Staged weapons: the sims use Almace Level 119 III and Mpu Gandring Level 119 II. The export doesn't show Vanar's stage of either, so neither is listed here; see [Almace](../../docs/gear-notes.md#almace) and [Mpu Gandring](../../docs/gear-notes.md#mpu-gandring). Vanar's Tizona is Level 119 III like the sims', because only that stage takes its `'Path: A'` augment.
- Lower versions Vanar does own: `Dls. Torque +1` (the sims use the +2), the NQ `Adhemar Bonnet` and `Adhemar Wristbands` (the sims use the +1s), and the NQ `Ea Houppelande` (the sims use `Ea Houppe. +1` in RDM Casting (Magic Burst)).
- Odyssey pieces Vanar owns at a lower rank than the sims' are in their entries, not here: every Nyame, Bunzi's and Gleti's piece the sims use.
