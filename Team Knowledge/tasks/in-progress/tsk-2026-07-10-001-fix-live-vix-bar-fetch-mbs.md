---
# Identity
id: tsk-2026-07-10-001
title: "Fix live VIX bar fetch for momentum_breakout_stocks — filter currently permanent no-op in paper trading"

# Ownership & priority
assignee: pierce
priority: 1

# Status (mirrors folder location)
status: in-progress
blocked_reason: "True VIX index bars confirmed unfetchable via Alpaca (IEX + SIP, both empty). Only path forward is VIXY proxy, which trips the task's hard guardrail on vix_threshold — need Jeff/Blake decision among Options A/B/C in the debug deliverable before writing the fallback code."
blocked_by: null

# Time
created: 2026-07-10T07:29:06Z
updated: 2026-07-10T08:10:00Z
due: 2026-07-10

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
linked_journal_entries: ["2026-07-08-verify-deployed-config-field-by-field-against-the-backtest-that-passed", "2026-07-10-alpaca-has-no-true-vix-index-data"]
linked_deliverables: ["2026-07-10-mbs-vix-filter-operational-gap", "2026-07-10-prophet-trader-debug-vix-bars-alpaca-unavailable"]

# Tagging
tags: ["prophet-trader", "momentum-breakout-stocks", "vix", "data-pipeline", "operational-readiness"]
---

# Fix live VIX bar fetch for momentum_breakout_stocks — filter currently permanent no-op in paper trading

## What this is

Blake's assessment ([[2026-07-10-mbs-vix-filter-operational-gap]]) confirms a structural gap between the Phase 1 gate-passing backtest and live paper trading: `momentum_breakout_stocks`'s internal VIX filter has been a permanent no-op since deployment. `scripts/daily_routine.py` builds `bars_by_ticker` strictly from `SP100_UNIVERSE`, which does not include VIX — so `market.bars.get("VIX", [])` always returns empty and the strategy fail-opens (skips the filter) every day it reaches that check. This surfaced as a new warning on 2026-07-09 because PR #5 (regime-config fix, merged 07-08) restored `range-bound` as an eligible regime, likely the first live day the code path actually reached the VIX check.

The VIX filter was one of 5 validated filters in the gate-passing wf_v9 backtest (Sharpe 1.455, PF 1.519) and specifically addressed two volatility-spike folds per the strategy config's own comments. This is not a strategy performance issue and does not trigger IPS Section 6.2 Review — but it is a real live/backtest fidelity gap, the second on this strategy in one week (sibling: [[Team Knowledge/tasks/done/2026/07/tsk-2026-07-08-002-merge-mbs-regime-config-fix]]).

**Jeff wants this fixed before today's (2026-07-10) daily routine run, which fires at 09:30 ET.**

## Context one click away

- Full assessment: [[2026-07-10-mbs-vix-filter-operational-gap]]
- Investigation / stop point: [[2026-07-10-prophet-trader-debug-vix-bars-alpaca-unavailable]]
- Journal precedent (this task): [[2026-07-10-alpaca-has-no-true-vix-index-data]]
- Working artifacts:
  - [[2026-07-10-mbs-vix-filter-operational-gap]]
  - [[2026-07-10-prophet-trader-debug-vix-bars-alpaca-unavailable]]
- Sibling fidelity-gap task (done): [[Team Knowledge/tasks/done/2026/07/tsk-2026-07-08-002-merge-mbs-regime-config-fix]]
- Related open task: [[tsk-2026-07-09-004-deflated-sharpe-retrospective-mbs]]
- Pierce's journal precedent: [[2026-07-08-verify-deployed-config-field-by-field-against-the-backtest-that-passed]]
- IPS: [[PKM/Documents/prophet-trader/investment-policy-statement]] Sections 3.2, 3.5, 6.2, 7.7

## Success criteria (per Blake's implementation spec)

- [ ] Extend the live market snapshot builder (`scripts/daily_routine.py`, `_generate_proposals`) to fetch VIX as **daily bars** (not just a quote) and inject into `bars_by_ticker["VIX"]` so `momentum_breakout_stocks`'s internal check actually resolves. — BLOCKED, see below.
- [x] Confirm whether Alpaca's data API supports a true VIX index bar series directly (preferred — avoids all downstream complications) or whether a proxy (e.g. VIXY) is required. — Confirmed NOT available: empirically tested `VIX` symbol against `StockBarsRequest`/`StockLatestQuoteRequest`/`StockLatestTradeRequest` on both IEX and SIP feeds via the live account — all return empty (no error, zero data). `VIXY` returns real bars immediately on the same account. See [[2026-07-10-prophet-trader-debug-vix-bars-alpaca-unavailable]].
- [ ] **If a proxy is used:** flag back to Blake before shipping — VIXY doesn't map 1:1 to VIX levels, `vix_threshold: 25` may need recalibration or explicit conversion, and any threshold change is a parameter change requiring a new Phase 1 walk-forward per IPS Section 6.3/7.7. Do not ship a proxy-based threshold change without Blake's sign-off. — Flagged. Stopped here per the guardrail; three options written up for Jeff/Blake in the debug deliverable. No code written for the proxy path.
- [ ] No config change otherwise — `vix_filter: true` / `vix_threshold: 25` stay as-is if true VIX is fetchable. This is a data-pipeline fix, not a strategy parameter change; it does not reopen Phase 1. — N/A yet; no config touched, nothing shipped.
- [x] Confirm via log check whether 07-06/07/08 show the regime-skip debug line rather than reaching the VIX check, closing the loop on the timing explanation in Blake's memo. — Checked local `data/logs/routine-2026-07-0{6,7,8,9}.log`. Production runs at INFO, not DEBUG, so the literal debug line isn't visible for any day; but 07-06/07/08 show only a generic "no proposals today (regime gate or ...)" summary with no VIX warning, and 07-09 explicitly logs the VIX fail-open WARNING — circumstantially consistent with Blake's timing explanation, not a byte-for-byte proof. Detail in the debug deliverable.
- [ ] Deployed to the VPS and verified live before the 09:30 ET 2026-07-10 daily routine run. — NOT MET. Will not make today's window; see Updates below.

## Updates

- 2026-07-10 07:29 (hawkeye) — created from Blake's assessment; routing to Pierce now given the tight window before today's 09:30 ET run.
- 2026-07-10 08:10 (pierce) — investigated. Confirmed empirically that true VIX index bars/quotes are not fetchable via Alpaca's stock data API on this account (IEX and SIP both empty for symbol `VIX`; `VIXY` works fine). This trips the task's hard guardrail — proxy required, so I stopped before writing the fallback code or touching `vix_threshold`, and did not open a PR. Full findings and three options (A/B/C) for Jeff/Blake in [[2026-07-10-prophet-trader-debug-vix-bars-alpaca-unavailable]]. Task moved to `in-progress`, `blocked_reason` set. Will not make the 09:30 ET 2026-07-10 window — status quo (fail-open) continues today, which Blake's memo already assesses as benign/non-urgent. No VPS changes made; no deploy attempted.

## Outcome

_(filled when status flips to done — see SOP-012-close-task)_
