---
# Identity
id: tsk-2026-07-17-010
title: "risk_journal.py open-positions summary + deployed_pct use the same fictional trade schema as the P&L bug"

# Ownership & priority
assignee: pierce
priority: 3

# Status (mirrors folder location)
status: open
blocked_reason: null
blocked_by: null

# Time
created: 2026-07-17T10:49:54Z
updated: 2026-07-17T10:49:54Z
due: null

# Provenance
created_by: pierce
source: session
parent: null

# Cross-references — REQUIRED, even if empty array. Seven slots. The act of filling these is the whole point.
linked_sops: ["SOP-010-create-task", "SOP-012-close-task"]
linked_workstreams: []
linked_guidelines: []
linked_my_life: []
linked_session_logs: []
linked_journal_entries: []
linked_deliverables: []

# Tagging
tags: ["prophet-trader", "data-integrity", "risk-journal", "daily-alpha-brief"]
---

# risk_journal.py open-positions summary + deployed_pct use the same fictional trade schema as the P&L bug

## What this is

Follow-up finding from [[tsk-2026-07-14-001-risk-journal-pnl-schema-mismatch]] (GH #29). While confirming and fixing the day/week P&L schema mismatch in `src/briefs/fetchers/risk_journal.py::_compute_pnl()`, found that `_summarize_open_positions()` and the `deployed_pct` calculation in `fetch_risk_posture()` (same file) have the identical root-cause pattern: they key off `t.get("status") == "open"`, `t.get("size_pct")`, and `t.get("unrealized_pnl")` — none of which exist in the real `data/trades.jsonl` event schema (verified against live VPS data 2026-07-17). Real fill events use `is_open`/`is_close` booleans, `qty`, and `limit_price`; there is no `unrealized_pnl` field anywhere in the journal.

This means the Daily Alpha Brief's "open positions" list and "% deployed" figure have likely always been empty/0%, silently, the same way day/week P&L was always $0.00 — but this bug was **not** bundled into the PR #52 fix because it's a harder problem than a field-name swap:

- Identifying which symbols are *currently* open requires netting opening (`is_open: true, is_close: false`) fill events against later closing (`is_close: true`) events per symbol — there's no single record with a live "open" status to key off. `src/strategies/cross_sectional_momentum.py` does this netting against the broker's live position list (`market.positions`), not the journal, when deciding what to close next — the journal alone doesn't carry that state directly.
- `risk_journal.py`'s own docstring is explicit that this fetcher **deliberately never calls the broker** ("self-contained morning view derived from canonical local state, not a broker-API view"). That means a true mark-to-market `unrealized_pnl` cannot be computed locally at all — there's no current price source in the journal. Any fix needs to either (a) drop `unrealized_pnl` from the summary line and disclose that limitation explicitly (matching the disclosed-methodology pattern `src/journal/drawdown.py` already uses for its realized-P&L-only equity curve), or (b) get Klinger/Blake's input on whether this fetcher's broker-free constraint should be revisited.

## Context one click away

- Parent finding: [[tsk-2026-07-14-001-risk-journal-pnl-schema-mismatch]]
- Fixed sibling bug: `src/briefs/fetchers/risk_journal.py::_compute_pnl()` (PR #52, merged/pending — check parent task for current state)
- Reference for the netting pattern: `src/strategies/cross_sectional_momentum.py` (`to_close`/`to_open` set logic against `market.positions`)
- Reference for disclosed-methodology pattern: `src/journal/drawdown.py` module docstring
- Existing (currently-passing-but-not-meaningful) test: `tests/test_fetchers.py::TestRiskPosture::test_open_positions_summary` — annotated 2026-07-17 as testing the fetcher's current fictional-schema behavior, not real production behavior. Should be rewritten once this is fixed.

## Success criteria

- [ ] Decide open-positions design: journal-only netting (symbol-level, no live price) vs. some other locally-derivable proxy. Get sign-off if it touches the broker-free design constraint (design decision — flag to Hawkeye/Blake if this changes the "never calls the broker" boundary).
- [ ] Fix `_summarize_open_positions()` and `deployed_pct` to use the real schema.
- [ ] Regression test verified against real/synthetic data matching the confirmed live schema.
- [ ] Rewrite `test_open_positions_summary` to test real behavior, not the old fictional fixture.

## Updates

- 2026-07-17 10:49 (pierce) — created while closing out the sibling P&L bug; deliberately not bundled into PR #52 since the open-positions fix needs a design decision (broker-free constraint), not just a field-name swap.

## Outcome

_(filled when status flips to done — see SOP-012-close-task)_
