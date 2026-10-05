# Vanar: rank augments

Vanar's path and rank for each rank-augmented item in the export `data/export/Vanar 2026-10-04 20-01-43.lua`, with the augments that rank gives. `.claude/tools/rank-doc.cs` writes this file from the Ranks table in [Vanar_notes.md](Vanar_notes.md#ranks) and from bg-wiki's rank tables in [rank-augments.md](../../docs/rank-augments.md), which has every other rank. Don't edit it by hand: change the Ranks table and run the tool.

- `//gs export` prints the path (`'Path: B'`) but never the rank, so a rank is the player's word, with the day it was given.
- A copy that exports with no augments at all hasn't been ranked: it is rank 0, with only the base stats in its help text.
- A path item with no row in the Ranks table shows as unknown: the player hasn't given its rank. Ask before a set decision turns on it.

| Item | Slot | Path | Rank | Given | Augments at that rank |
|---|---|---|---|---|---|
| [Nyame Helm](../../docs/rank-augments.md#nyame-helm) | head | B | 11 | 2026-10-04 | Attack+16 Rng. Atk.+16, Weapon skill damage +5% |
| [Nyame Mail](../../docs/rank-augments.md#nyame-mail) | body | B | 20 | 2026-10-04 | Attack+25 Rng. Atk.+25, Weapon skill damage +10%, "Double Attack"+3% |
| [Nyame Gauntlets](../../docs/rank-augments.md#nyame-gauntlets) | hands | B | 10 | 2026-10-04 | Attack+15 Rng. Atk.+15, Weapon skill damage +5% |
| [Nyame Flanchard](../../docs/rank-augments.md#nyame-flanchard) | legs | B | 11 | 2026-10-04 | Attack+16 Rng. Atk.+16, Weapon skill damage +6% |
| [Nyame Sollerets](../../docs/rank-augments.md#nyame-sollerets) | feet | B | 20 | 2026-10-04 | Attack+25 Rng. Atk.+25, Weapon skill damage +8%, "Double Attack"+2% |
| [Bunzi's Rod](../../docs/rank-augments.md#bunzis-rod) | main | none | 0 |  | none (base stats only) |
| [Bunzi's Hat](../../docs/rank-augments.md#bunzis-hat) | head | none | 0 |  | none (base stats only) |
| [Bunzi's Robe](../../docs/rank-augments.md#bunzis-robe) | body | none | 0 |  | none (base stats only) |
| [Bunzi's Gloves](../../docs/rank-augments.md#bunzis-gloves) | hands | none | 0 |  | none (base stats only) |
| [Bunzi's Pants](../../docs/rank-augments.md#bunzis-pants) | legs | none | 0 |  | none (base stats only) |
| [Bunzi's Sabots](../../docs/rank-augments.md#bunzis-sabots) | feet | none | 0 |  | none (base stats only) |
| [Gleti's Knife](../../docs/rank-augments.md#gletis-knife) | main | none | 0 |  | none (base stats only) |
| [Gleti's Mask](../../docs/rank-augments.md#gletis-mask) | head | none | 0 |  | none (base stats only) |
| [Gleti's Cuirass](../../docs/rank-augments.md#gletis-cuirass) | body | none | 0 |  | none (base stats only) |
| [Gleti's Gauntlets](../../docs/rank-augments.md#gletis-gauntlets) | hands | none | 0 |  | none (base stats only) |
| [Gleti's Breeches](../../docs/rank-augments.md#gletis-breeches) | legs | none | 0 |  | none (base stats only) |
| [Gleti's Boots](../../docs/rank-augments.md#gletis-boots) | feet | none | 0 |  | none (base stats only) |
| [Demers. Degen +1](../../docs/rank-augments.md#demers-degen-1) | main | none | 0 |  | none (base stats only) |
| [Kustawi +1](../../docs/rank-augments.md#kustawi-1) | main | none | 0 |  | none (base stats only) |
| [Marin Staff +1](../../docs/rank-augments.md#marin-staff-1) | main | none | 0 |  | none (base stats only) |
| [Tanmogayi +1](../../docs/rank-augments.md#tanmogayi-1) | main | none | 0 |  | none (base stats only) |
| [Forfend +1](../../docs/rank-augments.md#forfend-1) | sub | A | 15 | 2026-10-04 | Accuracy+15, Mag. Acc.+15, Enha. mag. skill +10 |
| [Coiste Bodhar](../../docs/rank-augments.md#coiste-bodhar) | ammo | A | 20 | 2026-10-04 | Attack+15, STR+5 |
| [Alabaster Earring](../../docs/rank-augments.md#alabaster-earring) | ear | A | 2 | 2026-10-04 | Accuracy+2 Rng. Acc.+2 Mag. Acc.+2 |
| [Murky Ring](../../docs/rank-augments.md#murky-ring) | ring | A | unknown |  |  |
| [Fi Follet Cape +1](../../docs/rank-augments.md#fi-follet-cape-1) | back | A | 11 | 2026-10-02 | "Fast Cast" +8%, Spell Interruption Rate -3% |
| [Kentarch Belt +1](../../docs/rank-augments.md#kentarch-belt-1) | waist | none | 0 |  | none (base stats only) |
| [Obstin. Sash](../../docs/rank-augments.md#obstin-sash) | waist | A | 20 | 2026-10-04 | Mag. Acc.+15, Enfb. mag. skill +5 |
| [Sailfi Belt +1](../../docs/rank-augments.md#sailfi-belt-1) | waist | A | 14 | 2026-10-04 | STR+14, Double Attack +5% |

## Items Oboro ranks up

bg-wiki gives these items' augments at maximum rank only: [rank-augments.md](../../docs/rank-augments.md#oboro-rank-augments-maximum-only). A copy that exports with no augments is rank 0. One that exports with a path has a rank the export doesn't show.

| Item | Slot | Max rank | Vanar's copy |
|---|---|---|---|
| Dls. Torque +1 | neck | 20 | `'Path: A'`, rank unknown |
| Mirage Stole +2 | neck | 25 | `'Path: A'`, rank unknown |
| Tizona | main | 15 | `'Path: A'` (so Level 119 III), rank unknown |
| Almace | main | 15 | no augments: rank 0, stage unknown |
| Pukulatmuj +1 | main | 15 | no augments: rank 0 |
