# Testy: rank augments

Testy's path and rank for each rank-augmented item in the export `data/export/Testy 2026-01-02 08-00-00.lua`, with the augments that rank gives. `.claude/tools/rank-doc.cs` writes this file from the Ranks table in [Testy_notes.md](Testy_notes.md#ranks) and from bg-wiki's rank tables in [rank-augments.md](../../docs/rank-augments.md), which has every other rank. Don't edit it by hand: change the Ranks table and run the tool.

- `//gs export` prints the path (`'Path: B'`) but never the rank, so a rank is the player's word, with the day it was given.
- A copy that exports with no augments at all hasn't been ranked: it is rank 0, with only the base stats in its help text.
- A path item with no row in the Ranks table shows as unknown: the player hasn't given its rank. Ask before a set decision turns on it.

| Item | Slot | Path | Rank | Given | Augments at that rank |
|---|---|---|---|---|---|
| [Nyame Helm](../../docs/rank-augments.md#nyame-helm) | head | B | 2 | 2026-01-03 | Attack+4 Rng. Atk.+4, Weapon skill damage +1% |
| [Coiste Bodhar](../../docs/rank-augments.md#coiste-bodhar) | ammo | A | unknown |  |  |
| [Eschan Stone](../../docs/rank-augments.md#eschan-stone) | waist | none | 0 |  | none (base stats only) |
| [Obstin. Sash](../../docs/rank-augments.md#obstin-sash) | waist | A | 20 | 2026-01-02 | Mag. Acc.+15, Enfb. mag. skill +5 |

## Items Oboro ranks up

bg-wiki gives these items' augments at maximum rank only: [rank-augments.md](../../docs/rank-augments.md#oboro-rank-augments-maximum-only). A copy that exports with no augments is rank 0. One that exports with a path has a rank the export doesn't show.

| Item | Slot | Max rank | Testy's copy |
|---|---|---|---|
| Almace | main | 15 | no augments: rank 0, stage unknown |
