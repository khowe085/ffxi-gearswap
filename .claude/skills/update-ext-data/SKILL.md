---
name: update-ext-data
description: Refreshes the outside data the gear tools read, all of it checked in under docs/ — Windower's resources and wsdist's gear data (fetch-sources), bg-wiki's rank tables (rank-tables), its simulated sets (simulated-sets) and every saved bg-wiki page (wiki --refresh) — then rewrites the rank documents (rank-doc) and runs the data checks (test data). Runs on Sonnet in a forked subagent and reports what changed and what the checks found; never commits. Use after a game update, when bg-wiki may have changed, after an export that adds a rank-augmented item, or before relying on saved pages that may be old. The caller may name only some of the steps in the arguments.
context: fork
agent: general-purpose
model: sonnet
effort: medium
background: false
---

# Update the outside data in docs

You are an executor. Run the steps below from the repository root, in order, and report. You have no conversation history; the request is complete or it is wrong.

## Request

$ARGUMENTS

## Steps

Run every step unless the request names some, then only those.

1. **Windower's resources and wsdist's gear data.** `dotnet run .claude/gear.cs -- fetch-sources` downloads Windower's `items.lua`, `item_descriptions.lua` and `spells.lua` into `docs/windower/`, and copies `gear.py` from IzaKastra/wsdist_beta, at the commit `docs/ffxi-mechanics.md` cites, into `docs/wsdist/`.
2. **Rank tables.** `dotnet run .claude/gear.cs -- rank-tables` reads bg-wiki's rank tables for every item in each character's newest export into `docs/wiki/rank-tables.json`. bg-wiki rate limits, and the tool waits and asks again on its own, so allow it up to 10 minutes.
3. **Simulated sets.** `dotnet run .claude/gear.cs -- simulated-sets` copies each job's simulated sets from IzaKastra/bg_job_guides, at the commit `docs/ffxi-mechanics.md` cites, into `docs/wiki/simulated-sets/`.
4. **Saved pages.** When `docs/wiki/page-titles.txt` exists, run `dotnet run .claude/gear.cs -- wiki --refresh` with every line of it as a title, each in double quotes.
5. **Rank documents.** `dotnet run .claude/gear.cs -- rank-doc` rewrites `docs/rank-augments.md` and each character's `<Character>_rank_augments.md` from the tables.
6. **Checks.** `dotnet run .claude/gear.cs -- test data` runs the data checks.

Exit code 2 means a step couldn't run: stop there and report its output. Exit code 1 means it found something: carry on, and report it.

## Rules

- Change nothing by hand: the tools write what changes. Don't fix what the checks report.
- Don't commit, stage, stash or push.

## Report

1. Each step's command, exit code, and the last lines of its output.
2. What changed: `git status --short -- docs data` and `git diff --stat -- docs data`.
3. The data checks' result, with every problem line verbatim.
