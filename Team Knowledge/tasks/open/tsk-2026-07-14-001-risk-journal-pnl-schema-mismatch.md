---
# Identity
id: tsk-2026-07-14-001
title: "Daily Alpha Brief's P&L calculation may always read $0.00 — trade schema mismatch in risk_journal.py"

# Ownership & priority
assignee: pierce
priority: 3

# Status (mirrors folder location)
status: open
blocked_reason: null
blocked_by: null

# Time
created: 2026-07-14T01:25:54Z
updated: 2026-07-14T01:25:54Z
due: 2026-07-21

# Provenance
created_by: hawkeye
source: session
parent: null

# Cross-references — REQUIRED, even if empty array. Seven slots. The act of filling these is the whole point.
linked_sops: ["SOP-010-create-task", "SOP-012-close-task"]
linked_workstreams: []
linked_guidelines: []
linked_my_life: []
linked_session_logs: []
linked_journal_entries: []
linked_deliverables: ["2026-07-13-prophet-trader-deploy-cross-strategy-sweep"]

# Tagging
tags: ["prophet-trader", "data-integrity", "risk-journal", "daily-alpha-brief"]
---

# Daily Alpha Brief's P&L calculation may always read $0.00 — trade schema mismatch in risk_journal.py

## What this is

Found (not fixed) during Pierce's broader cross-strategy-mixing sweep on 2026-07-13 ([[2026-07-13-prophet-trader-deploy-cross-strategy-sweep]]), triggered by Jeff's "identify and fix all bugs" directive after a live demotion-trigger bug surfaced the same day. This is a distinct bug class from the cross-strategy-mixing issues found elsewhere that day (fill attribution, regime persistence, decision aggregation) — deliberately not folded into that sweep's fixes.

`src/briefs/fetchers/risk_journal.py::_compute_pnl()` reads a trade schema that doesn't match the real shape of records in `data/trades.jsonl`. If confirmed, this means day/week P&L figures in the Daily Alpha Brief may have always read `0.0`, silently, rather than the actual realized P&L.

## Context one click away

- [[2026-07-13-prophet-trader-deploy-cross-strategy-sweep]] — where this was found, full detail on the broader sweep it was found during
- `C:\Users\jeff\dev\prophet-trader\src\briefs\fetchers\risk_journal.py` (`_compute_pnl()`)
- `C:\Users\jeff\dev\prophet-trader\data\trades.jsonl` (real schema to compare against)

## Success criteria

- [ ] Confirm the actual schema mismatch — what field(s) `_compute_pnl()` expects vs. what `trades.jsonl` records actually contain.
- [ ] Confirm the actual production impact — has the Daily Alpha Brief been silently reporting $0.00 P&L, or is there a fallback/different path that masks this in practice?
- [ ] Fix the schema mismatch, with a regression test that would have caught it.
- [ ] Confirm no other consumer of this same fetcher/schema has the identical problem.

## Updates

- 2026-07-14 01:25 (hawkeye) — created per Jeff's explicit "we must have all bugs identified and fixed asap" directive, tracking this so it doesn't get lost now that the higher-priority report-script build and the healthchecks naming fix are in progress. Not urgent relative to those — the Daily Alpha Brief is a separate, lower-stakes surface than the demotion/reconciliation logic fixed same-day — but real and worth closing properly.

## Outcome

_(filled when status flips to done — see SOP-012-close-task)_
