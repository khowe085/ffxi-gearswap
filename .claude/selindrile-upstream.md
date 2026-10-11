# Selindrile upstream

Branch `selindrile` holds a copy of https://github.com/Selindrile/GearSwap laid over stock Windower GearSwap.

## Current sync point

| Upstream commit | Commit date | Synced on |
|---|---|---|
| `2cda6efc69244bb559e0f98f0584f3ba03097a08` | 2026-10-07 | 2026-10-07 |

## How the initial copy was done (README steps 1–8)

- Every file tracked upstream was copied over ours, and upstream won on files both repos have. Only `README.md` actually changed; `libs/organizer-lib.lua` was identical.
- Files that only we have stayed as they were (core `*.lua`, `libs/Mote-*`, `libs/rev1/`, `beta_examples_and_information/`).
- **Upstream's `.gitignore` was NOT copied.** It ignores `*_Gear.lua`, `README.md`, the core files, and more.
- The old `data/Instructions.txt` was deleted (README step 5).
- `data/Vanar/Vanar_{Rdm,Blu,Thf}_Gear.lua` were copied from `data/Mytha/Mytha_{Rdm,Blu,Thf}_Gear.lua` and renamed.

## Local edits to upstream files

Re-apply these after copying in an upstream version of the file, unless upstream has made the same fix.

- `data/BLU.lua`: `'Orcish Counterstance'` → `'O. Counterstance'` in `blue_magic_maps.Buff` (Windower's resources name for spell 696).
- `libs/Sel-Display.lua`: in `update_job_states`, the `Weapons` entry shows "Locked" (white) when `state.UnlockWeapons` is off, so the HUD always shows the weapon lock state; upstream shows only "Unlocked".
- `libs/Sel-Utility.lua`: in `check_recast`, the two MiniQueue branches that held a job ability or spell with under 5 seconds of recast and sent it when ready are commented out. Such a press is now refused with "waiting on recast" like a longer recast, so a held press can't go off after the player has moved on to another action.

## Pulling in later upstream commits

1. Clone or fetch upstream outside the repo, e.g. in a scratch directory:
   ```bash
   git clone https://github.com/Selindrile/GearSwap.git selindrile-upstream
   ```
2. List what changed since the sync point:
   ```bash
   git -C selindrile-upstream diff --name-status 2cda6efc69244bb559e0f98f0584f3ba03097a08 HEAD
   ```
3. For each path:
   - `A`/`M`: copy the upstream file over ours. Skip `.gitignore`.
   - `D`: delete our copy, unless we have changed it locally.
   - `R`: delete the old path and copy in the new one.
4. If `data/Mytha/Mytha_{Rdm,Blu,Thf}_Gear.lua` changed, the `data/Vanar/` copies do not update themselves. Diff the Mytha change and port it into `Vanar_*_Gear.lua` by hand, so Vanar's own gear edits survive.
5. Check `git diff` for anything that overwrote a local edit, especially `README.md` and `libs/`.
6. Update the sync-point table above to the new upstream `HEAD` (`git -C selindrile-upstream log -1 --format='%H %cs'`).
