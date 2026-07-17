---
# Identity
id: tsk-2026-07-17-011
title: "Verify council_intent.py's week_pnl_pct stand-down warning displays correctly the first time a real closed loss triggers it"

# Ownership & priority
assignee: pierce
priority: 4

# Status (mirrors folder location)
status: open
blocked_reason: null
blocked_by: null

# Time
created: 2026-07-17T15:40:00Z
updated: 2026-07-17T15:40:00Z
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
tags: ["prophet-trader", "risk-journal", "council-intent", "monitoring", "informational"]
---

# Verify council_intent.py's week_pnl_pct stand-down warning displays correctly the first time a real closed loss triggers it

## What this is

Follow-up from Ledger's SOP-022 fidelity check on PR #52 ([[tsk-2026-07-14-001-risk-journal-pnl-schema-mismatch]]), finding #2. PR #52 fixed `risk_journal.py::_compute_pnl()`'s schema mismatch, which means `week_pnl_pct` now feeds `council_intent.py`'s stand-down warning text (triggers at -3%/-5% week P&L) with a real, correct value for the first time in production — previously `week_pnl_pct` was always pinned at 0.0 due to the bug, so that warning branch has never fired live. This is display-only text; it does not touch the actual G5 halt gate, which is separately correct and unaffected.

Not a bug and not yet an enhancement — nothing is wrong today, there's just an untested-in-production code path that needs eyes on it the first time it actually fires. Per the corrected backlog rule (CLAUDE.md, PR #50: GitHub Issues are scoped to bugs/enhancements only), this kind of future verification effort belongs in a myPKA task, not a GitHub issue.

## Context one click away

- Procedure: [[SOP-022-deployment-fidelity-verification]]
- Parent finding: [[tsk-2026-07-14-001-risk-journal-pnl-schema-mismatch]] (Ledger's SOP-022 PASS on PR #52, finding #2)
- Source file: `C:\Users\jeff\dev\prophet-trader\src\council_intent.py` (stand-down warning text, -3%/-5% week P&L thresholds)
- Source file: `C:\Users\jeff\dev\prophet-trader\src\briefs\fetchers\risk_journal.py` (`_compute_pnl()`, now-correct `week_pnl_pct` source)

## Success criteria

- The next time production week P&L goes negative enough to cross -3% and/or -5% with at least one real closed (realized) fill, confirm `council_intent.py`'s stand-down warning text renders correctly (correct threshold matched, correct percentage displayed, no crash, no malformed string).
- Confirm the actual G5 halt gate (separate from this display text) continues to behave correctly and independently of this warning text, as it always has.
- Note the outcome (fired cleanly, or found a bug) — if a bug is found at that point, file it as a proper GitHub issue per the bugs/enhancements rule, since at that point it would be a real bug.

## Updates

- 2026-07-17 15:40 (pierce) — created per Jeff's corrected backlog-scoping rule (non-bug/non-enhancement future work effort must be logged as a myPKA task); low priority, no due date, fires whenever week P&L next goes negative with a real closed loss.

## Outcome

_(filled when status flips to done — see SOP-012-close-task, after a real closed loss crosses -3%/-5% week P&L and the warning text is confirmed)_
