# Rank augments

Augment values at every rank for each rank-augmented item in the exports under `data/export/`. The Odyssey pieces (Nyame, Bunzi's, Gleti's and the other Sheol rewards) rank up to 30. Most other path items here rank up to 15 or 30. Every value comes from the item's own bg-wiki page, from the per-rank table under its augments (the `Augment Rank Table` template), read on 2026-01-03 and copied by script, not by hand. Items Oboro ranks up (JSE necks, Ultimate Weapons, Unity weapons) come last, at maximum rank only, because bg-wiki has no per-rank table for them. A character's own path and rank for each item are in that character's folder, in `data/<Character>/<Character>_rank_augments.md`.

- `//gs export` prints the path (`'Path: B'`) but never the rank. A copy that exports with no augments at all hasn't been ranked: it has only the base stats in its help text.
- Ranks are cumulative: the row for a rank is the item's whole augment at that rank, not an increase over the rank before it. A blank cell means that augment line hasn't unlocked yet.
- A path is fixed once chosen. Changing it means discarding the item and starting over (bg-wiki, Nyame Mail).

## Items

| Item | Slot | Paths | Max rank |
|---|---|---|---|
| [Nyame Helm](#nyame-helm) | head | A, B, C | 30 |
| [Coiste Bodhar](#coiste-bodhar) | ammo | A | 30 |
| [Eschan Stone](#eschan-stone) | waist | A | 15 |
| [Obstin. Sash](#obstin-sash) | waist | A | 30 |

## Nyame

### Nyame Helm

Nyame Helm, head. Ranks 1 to 30. Source: [bg-wiki](https://www.bg-wiki.com/ffxi/Nyame_Helm).

Path A:

| Rank | Augment 1 |
|---|---|
| 1 | Accuracy+1 |

Path B:

| Rank | Augment 1 | Augment 2 |
|---|---|---|
| 1 | Attack+3 Rng. Atk.+3 |  |
| 2 | Attack+4 Rng. Atk.+4 | Weapon skill damage +1% |
| 15 | Attack+20 Rng. Atk.+20 | Weapon skill damage +7% |
| 20 | Attack+25 Rng. Atk.+25 | Weapon skill damage +8% |

Path C:

| Rank | Augment 1 | Augment 2 |
|---|---|---|
| 15 | "Mag. Atk. Bns."+20 | INT/MND/CHR+5 |

## Other path items

### Coiste Bodhar

Coiste Bodhar, ammo. Ranks 1 to 30. Source: [bg-wiki](https://www.bg-wiki.com/ffxi/Coiste_Bodhar).

| Rank | Augment 1 |
|---|---|
| 1 | Attack+1 |

### Eschan Stone

Eschan Stone, waist. Ranks 1 to 15. Source: [bg-wiki](https://www.bg-wiki.com/ffxi/Eschan_Stone).

| Rank | Augment 1 |
|---|---|
| 1 | Accuracy+1 |

### Obstin. Sash

Obstinate Sash, waist. Ranks 1 to 30. Source: [bg-wiki](https://www.bg-wiki.com/ffxi/Obstin._Sash).

| Rank | Augment 1 | Augment 2 |
|---|---|---|
| 1 | Mag. Acc.+1 |  |
| 20 | Mag. Acc.+15 | Enfb. mag. skill +5 |

## Oboro rank augments (maximum only)

Oboro in Port Jeuno ranks up JSE necks, Ultimate Weapons (Relic, Mythic, Empyrean and Aeonic at Level 119 III) and Unity weapons. bg-wiki lists only each item's augments at its maximum rank, not rank by rank, so an item below its cap has less than these values by an amount the wiki doesn't give. A copy that exports with no augments is rank 0. A copy that exports with `'Path: A'` has been ranked, and its rank has to come from the player.

- JSE necks: NQ necks cap at rank 15, +1 necks at rank 20 and +2 necks at rank 25 ([bg-wiki](https://www.bg-wiki.com/ffxi/Category:JSE_Necks)).
- Ultimate Weapons cap at rank 15, and only a Level 119 III weapon can start. The export prints `'Path: A'` on them, but Path A is the only path. The augments work in the main hand only. The weapon skill damage augment applies to every hit of that weapon skill, and it multiplies with the weapon's hidden weapon skill bonus ([bg-wiki](https://www.bg-wiki.com/ffxi/BGWiki:Ultimate_Weapon_Augments)).
- `//gs export` prints the same name for every stage of a Relic, Mythic, Empyrean or Ergon weapon. Almace, Tizona and Mpu Gandring each share their export name with 4 to 11 item IDs, so the export doesn't show the stage. An Ultimate Weapon with `'Path: A'` must be Level 119 III, because only that stage takes the augment.

| Item | Slot | Max rank | Augments at max rank |
|---|---|---|---|
| Dls. Torque +1 | neck | 20 | INT and MND +12, Enhancing magic effect duration +20%, Enfeebling magic effect duration +20% ([bg-wiki](https://www.bg-wiki.com/ffxi/Dls._Torque_%2B1)) |
| Mirage Stole +2 | neck | 25 | STR and DEX +25, Store TP +7, Critical hit rate +5% ([bg-wiki](https://www.bg-wiki.com/ffxi/Mirage_Stole_%2B2)) |
| Tizona | main | 15 | Main hand: DMG +18, Expiacion damage +15%, Accuracy +30, Magic Accuracy +30. With the weapon's hidden Expiacion +30%, the total at rank 15 is +49.5%, because the two multiply ([bg-wiki](https://www.bg-wiki.com/ffxi/Tizona_(Level_119_III))) |
| Almace | main | 15 | Main hand: DMG +5, Chant du Cygne damage +10%, DEX and MND +20 ([bg-wiki](https://www.bg-wiki.com/ffxi/BGWiki:Ultimate_Weapon_Augments)) |
| Pukulatmuj +1 | main | 15 | DMG +38, Accuracy and Magic Accuracy +30, Sword enhancement spell damage +150% (its own enspell damage only) ([bg-wiki](https://www.bg-wiki.com/ffxi/Pukulatmuj_%2B1)) |
