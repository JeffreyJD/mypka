---
# Identity
id: tsk-2026-07-17-012
title: "Remove dead code: realized_edge() in strategies/base.py, confirmed unreferenced by Ledger's SOP-022 check on PR #52"

# Ownership & priority
assignee: pierce
priority: 4

# Status (mirrors folder location)
status: done
blocked_reason: null
blocked_by: null

# Time
created: 2026-07-17T15:55:00Z
updated: 2026-07-17T16:10:00Z
due: null

# Provenance
created_by: pierce
source: session
parent: tsk-2026-07-14-001

# Cross-references — REQUIRED, even if empty array. Seven slots. The act of filling these is the whole point.
linked_sops: ["SOP-010-create-task", "SOP-012-close-task", "SOP-022-deployment-fidelity-verification"]
linked_workstreams: []
linked_guidelines: []
linked_my_life: []
linked_session_logs: []
linked_journal_entries: []
linked_deliverables: []

# Tagging
tags: ["prophet-trader", "tech-debt", "dead-code", "risk-journal"]
---

# Remove dead code: realized_edge() in strategies/base.py, confirmed unreferenced by Ledger's SOP-022 check on PR #52

## What this is

Follow-up finding #1 from Ledger's SOP-022 fidelity check on PR #52 ([[tsk-2026-07-14-001-risk-journal-pnl-schema-mismatch]]). Ledger found `src/strategies/base.py::realized_edge()` (lines 100-126) has the identical fictional trade schema bug (`status == "closed"`, `t["pnl"]`) that PR #52 just fixed in `risk_journal.py`, but confirmed via grep it is never called anywhere in production — dead code, not a live bug. Per Jeff's corrected direction, remediation touching code always gets a tracked GitHub issue and myPKA task, even when the fix ships same-session rather than being deferred to backlog.

## Context one click away

- Procedure: [[SOP-022-deployment-fidelity-verification]]
- Parent task: [[tsk-2026-07-14-001-risk-journal-pnl-schema-mismatch]]
- GitHub issue: JeffreyJD/prophet-trader#55 (created and closed same-session)
- PR: JeffreyJD/prophet-trader#54 (merged to `dev`, commit `13be8de`, merge commit `2955690`)

## Success criteria

- [x] Own independent grep pass confirms `realized_edge()` has zero callers, zero imports, zero test references, zero doc references beyond two stale comments.
- [x] `realized_edge()` deleted from `src/strategies/base.py`.
- [x] Stale comments in `gap_fade_stocks.py` and `momentum_breakout_stocks.py` updated so they don't dangle-reference removed code.
- [x] Full local test suite green: 577 passed, 2 skipped, same 4 pre-existing unrelated failures as PR #52 baseline (missing `anthropic` package in this venv) — no new failures.
- [x] PR #54 merged to `dev`.
- [x] GitHub issue #55 opened and closed same-session with commit/PR evidence.

## Updates

- 2026-07-17 15:55 (pierce) — created per Jeff's corrected direction (code-touch remediation gets a GitHub issue + myPKA task even when fixed same-session, not just an Outcome note on the parent task).
- 2026-07-17 16:10 (pierce) — done: deleted `realized_edge()`, cleaned up the two stale comments, full suite green, PR #54 merged to `dev` (commit `13be8de`, merge `2955690`), GH issue #55 opened and closed with evidence.

## Outcome

What shipped: removed the dead-code duplicate of the risk_journal P&L schema bug from `src/strategies/base.py::realized_edge()` (never called in production), and cleaned up the two stale comments in `gap_fade_stocks.py` / `momentum_breakout_stocks.py` that referenced it.

Where it lives: PR [#54](https://github.com/JeffreyJD/prophet-trader/pull/54), merged to `dev` at commit `2955690` (fix commit `13be8de`). GitHub issue [#55](https://github.com/JeffreyJD/prophet-trader/issues/55), opened and closed same-session with the commit/PR evidence attached.

Follow-ups: none — fully closed, no open thread either in GitHub or myPKA.

Lessons: none new; reinforces the existing lesson that a schema bug found in one file is worth grepping for elsewhere in the codebase before considering it fully closed (this is how the duplicate was caught in the first place, by Ledger's SOP-022 check).

Archived deliverables: none (`linked_deliverables: []`).
