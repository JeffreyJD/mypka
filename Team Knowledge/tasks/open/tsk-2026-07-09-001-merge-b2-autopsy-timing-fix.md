---
# Identity
id: tsk-2026-07-09-001
title: "Approve and merge PR #7 — push weekly autopsy to B2 same-day"

# Ownership & priority
assignee: jeff
priority: 1

# Status (mirrors folder location)
status: open
blocked_reason: "needs Jeff's explicit approval before merge — changes production automation"
blocked_by: null

# Time
created: 2026-07-09T00:00:00Z
updated: 2026-07-09T00:00:00Z
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

tags: ["prophet-trader", "b2", "phase2"]
---

# Approve and merge PR #7 — B2 autopsy timing fix

## What this is

The nightly B2 backup runs 00:00 ET, before the Sunday 10:00 ET autopsy generates its output — so autopsy files wouldn't reach B2 until up to 24h after generation. The [[prophet-trader-weekly-strategy-report]] cloud routine fires the same day at 18:00 ET and reads directly from B2, so it needs same-day data. PR #7 adds an immediate, targeted `rclone copy` of just that day's autopsy files right after a successful run, non-fatal on failure (nightly sync still catches it as fallback).

**This is priority 1, not 2** — unlike the other recent PRs, this one gates whether the Weekly Strategy Report's first live fire (2026-07-12) finds real data or writes a SKIPPED note for lack of it.

## Context one click away

- PR: https://github.com/JeffreyJD/prophet-trader/pull/7
- Related: [[prophet-trader-weekly-strategy-report]], [[backblaze-b2]]

## Success criteria

- Jeff reviews PR #7, confirms no objection
- Merged to `main`, GitHub Actions deploy confirmed, VPS commit verified
- Post-deploy confirmation written per Pierce's deliverable structure
- Ideally merged before 2026-07-13 09:30 ET (next Sunday's autopsy run) so the very first B2 push happens correctly

## Updates

- 2026-07-09 (hawkeye) — created as part of building the B2-based data pipeline for the Weekly Strategy Report routine, replacing the git-credential approach that was rejected for its trust-boundary expansion.

## Outcome

_(filled when status flips to done — see SOP-012-close-task)_
