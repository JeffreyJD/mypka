---
# Identity
id: tsk-2026-07-08-004
title: "Approve and merge PR #6 — weekly_autopsy.py multi-strategy fix"

# Ownership & priority
assignee: jeff
priority: 2

# Status (mirrors folder location)
status: done
blocked_reason: null
blocked_by: null

# Time
created: 2026-07-08T00:00:00Z
updated: 2026-07-09T00:32:00Z
due: "2026-07-12"

# Provenance
created_by: hawkeye
source: session
parent: null

linked_sops: []
linked_workstreams: []
linked_guidelines: []
linked_my_life: []
linked_session_logs: []
linked_journal_entries: []
linked_deliverables: []

tags: ["prophet-trader", "config", "phase2"]
---

# Approve and merge PR #6 — weekly_autopsy.py multi-strategy fix

## What this is

`scripts/weekly_autopsy.py` defaulted to `cross_sectional_momentum` only — `momentum_breakout_stocks` has never gotten a single automated weekly autopsy since going live 2026-06-22. PR #6 fixes this: reads active (Phase >= 2) strategies from `phase_state.json`, writes one report per strategy, output filenames now include the strategy name.

This also feeds the new [[prophet-trader-weekly-strategy-report]] cloud routine, which expects one autopsy file per active strategy — without this fix, the pipeline is incomplete even once the VPS-push piece is built.

## Context one click away

- PR: https://github.com/JeffreyJD/prophet-trader/pull/6
- Related: [[prophet-trader-weekly-strategy-report]]

## Success criteria

- Jeff reviews PR #6, confirms no objection to the output-shape change (two files per week instead of one)
- Merged to `main`, GitHub Actions deploy confirmed, VPS commit verified
- Post-deploy confirmation written per Pierce's deliverable structure

## Updates

- 2026-07-08 (hawkeye) — created. Due before 2026-07-12 (next Sunday autopsy run) so it fires correctly for both strategies from the start.
- 2026-07-09 00:31 (hawkeye) — Jeff approved. Merged PR #6 to `main` (`d503ef4`), CI green (2/2), deploy succeeded, VPS confirmed at `d503ef4` with the fix's actual code verified present (not just the commit hash trusted).

## Outcome

What shipped: `weekly_autopsy.py` now generates one report per active Phase-2+ strategy instead of defaulting to `cross_sectional_momentum` only. `momentum_breakout_stocks` gets its first automated weekly autopsy this Sunday (2026-07-13).

Where it lives: PR https://github.com/JeffreyJD/prophet-trader/pull/6, merge commit `d503ef4`. Post-deploy confirmation: [[2026-07-09-prophet-trader-deploy-weekly-autopsy-multi-strategy]].

Follow-ups: none required for this task. The VPS→mypka data-push piece this fix's output feeds into remains unbuilt (git-credential-scope decision pending, tracked in [[prophet-trader-weekly-strategy-report]]'s Open questions).

Archived deliverables: none (linked_deliverables was empty).
