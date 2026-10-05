# Notes for Claude

- Read `docs/ffxi-mechanics.md` before building or changing gear sets. It covers the caps, formulas and placement rules sets are built around (casting time, recast, haste, accuracy and attack, magic accuracy, enhancing, enfeebling, magic damage, Cure, blue magic, weapon skills). The player's standing rules for Vanar's sets are in `data/Vanar/Vanar_notes.md`, with Vanar's merits, job points and Master Levels.
- Check `docs/gear-notes.md` for any piece you put in a set. It records what the help text and the export don't show: hidden values, set bonuses, conditions and slot or hand restrictions. `data/Vanar/Vanar_gear_notes.md` adds what is known of Vanar's own copy.
- For path-augmented gear (Nyame, Bunzi's, Gleti's and other "Path:" items), take values from `docs/rank-augments.md` at Vanar's rank, which `data/Vanar/Vanar_rank_augments.md` gives. `//gs export` shows the path but not the rank.
- `docs/` holds what is true for any character and names none. What is true for one character goes in that character's folder under `data/`, linked from its `<Character>_gear_list.md`.
- Building, changing or reviewing gear sets is the `gear-optimizer` agent's job (`.claude/agents/gear-optimizer.md`). `.claude/tools/README.md` lists the checks to run after any change to a job file, the gear list or the docs.
