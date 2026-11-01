# Selindrile upstream

Branch `selindrile` holds a copy of https://github.com/Selindrile/GearSwap laid over stock Windower GearSwap.

## Current sync point

| Upstream commit | Commit date | Synced on |
|---|---|---|
| `c6e78e7d42a46fcb1a4cb577f8ab6299130a60b2` | 2026-10-27 | 2026-10-31 |

## How the initial copy was done (README steps 1–8)

- Every file tracked upstream was copied over ours, and upstream won on files both repos have. Only `README.md` actually changed; `libs/organizer-lib.lua` was identical.
- Files that only we have stayed as they were (core `*.lua`, `libs/Mote-*`, `libs/rev1/`, `beta_examples_and_information/`).
- **Upstream's `.gitignore` was NOT copied.** It ignores `*_Gear.lua`, `README.md`, the core files, and more.
- The old `data/Instructions.txt` was deleted (README step 5).
- `data/Vanar/Vanar_{Rdm,Blu,Thf}_Gear.lua` were copied from `data/Mytha/Mytha_{Rdm,Blu,Thf}_Gear.lua` and renamed.

## Local edits to upstream files

Re-apply these after copying in an upstream version of the file, unless upstream has made the same fix.

- `data/BLU.lua`: `'Orcish Counterstance'` → `'O. Counterstance'` in `blue_magic_maps.Buff` (Windower's resources name for spell 696).
- `libs/Sel-Display.lua`: in `update_job_states`:
  - The two loop bodies are the local functions `append_bool` and `append_mode`, so the line can be built in a fixed order for every job: Auto Trust, Auto Buff, Offense and Weapons (each only if the job lists it), then Auto WS, then the job's booleans and its other modes in its `init_job_states` order. Upstream prints all the booleans, then all the modes, in the job's order.
  - Auto WS is `state.AutoWS`, the melee auto-ws mode from `data/User/User-Globals.lua`, drawn whenever it exists: `Auto WS: <choice>`, white at OFF and yellow otherwise. Upstream has no such mode.
  - The `Weapons` entry reads `Weapons: <weapon> (L)` (white) or `(U)` (light blue) from `state.UnlockWeapons`, so the line always shows the weapon lock state, with the `state.WeaponSets` name before the weapon when it isn't Default or None. Upstream prints "Unlocked" and the `WeaponSets` name before the label, and nothing when locked.
- `libs/Sel-Include.lua`: `state.MiniQueue` starts off. Upstream starts it on, and its hold for a press made too soon after an action or while moving delayed or lost casts.
- `libs/Sel-Utility.lua`: in `check_recast`, the two MiniQueue branches that held a job ability or spell with under 5 seconds of recast and sent it when ready are commented out. Such a press is now refused with "waiting on recast" like a longer recast, so a held press can't go off after the player has moved on to another action.
- `libs/Sel-Include.lua`, `libs/Sel-Utility.lua`: `can_dual_wield` is `nil` until `set_dual_wield` has looked, not upstream's `''`. An empty string is true in Lua, so a job without Dual Wield would count as having it until the first check.

## Pulling in later upstream commits

1. Fetch upstream, without adding a remote:
   ```bash
   git fetch https://github.com/Selindrile/GearSwap.git master
   ```
2. List what changed since the sync point:
   ```bash
   git diff --name-status <sync point> FETCH_HEAD
   ```
3. Save the changes as a patch outside the repo, leaving out `.gitignore`, and apply it three-way. Copying upstream's files over ours would lose the local edits, which reach more files than are listed above: the `AutoFoodMode`/`AutoTrustMode` lists also changed `libs/Sel-Include.lua` and every job file's `init_job_states`.
   ```bash
   git diff --full-index --binary <sync point> FETCH_HEAD -- . ':!.gitignore' > /var/tmp/claude/upstream.patch
   ```
   ```bash
   git apply --3way /var/tmp/claude/upstream.patch
   ```
4. If `data/Mytha/Mytha_{Rdm,Blu,Thf}_Gear.lua` changed, the `data/Vanar/` copies do not update themselves. Diff the Mytha change and port it into `Vanar_*_Gear.lua` by hand, so Vanar's own gear edits survive.
5. Check `git diff` for anything that overwrote a local edit, especially `README.md` and `libs/`.
6. Update the sync-point table above to the new upstream commit (`git log -1 --format='%H %cs' FETCH_HEAD`).
