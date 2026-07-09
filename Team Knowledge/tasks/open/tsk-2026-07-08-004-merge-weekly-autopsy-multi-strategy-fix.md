---
# Identity
id: tsk-2026-07-08-004
title: "Approve and merge PR #6 — weekly_autopsy.py multi-strategy fix"

# Ownership & priority
assignee: jeff
priority: 2

# Status (mirrors folder location)
status: open
blocked_reason: "needs Jeff's explicit approval before merge — changes the scheduled Sunday autopsy's output shape"
blocked_by: null

# Time
created: 2026-07-08T00:00:00Z
updated: 2026-07-08T00:00:00Z
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

## Outcome

_(filled when status flips to done — see SOP-012-close-task)_
