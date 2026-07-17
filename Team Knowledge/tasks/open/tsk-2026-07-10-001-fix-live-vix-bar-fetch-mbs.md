---
# Identity
id: tsk-2026-07-10-001
title: "Source true VIX index data (non-Alpaca) for momentum_breakout_stocks — VIXY proxy rejected"

# Ownership & priority
assignee: pierce
priority: 3

# Status (mirrors folder location)
status: open
blocked_reason: null
blocked_by: null

# Time
created: 2026-07-10T07:29:06Z
updated: 2026-07-10T08:35:00Z
due: 2026-08-07

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
linked_deliverables: ["2026-07-10-mbs-vix-filter-operational-gap", "2026-07-10-prophet-trader-debug-vix-bars-alpaca-unavailable", "2026-07-10-mbs-vix-proxy-decision"]

# Tagging
tags: ["prophet-trader", "momentum-breakout-stocks", "vix", "data-pipeline", "operational-readiness"]
---

# Source true VIX index data (non-Alpaca) for momentum_breakout_stocks — VIXY proxy rejected

**GitHub issue:** [#44](https://github.com/JeffreyJD/prophet-trader/issues/44)

## What this is

Blake's original assessment ([[2026-07-10-mbs-vix-filter-operational-gap]]) confirmed a structural gap between the Phase 1 gate-passing backtest and live paper trading: `momentum_breakout_stocks`'s internal VIX filter has been a permanent no-op since deployment (VIX isn't in the strategy's universe, so `market.bars.get("VIX", [])` always returns empty and the strategy fail-opens).

Pierce investigated and confirmed true VIX index bars are not fetchable via Alpaca on any feed tier ([[2026-07-10-prophet-trader-debug-vix-bars-alpaca-unavailable]]) — only a VIXY proxy is available, which trips the task's guardrail since VIXY doesn't map 1:1 to the strategy's `vix_threshold: 25`.

**Blake's ruling** ([[2026-07-10-mbs-vix-proxy-decision]]): rejected both the "ship VIXY, revalidate later" and "ship VIXY with a conversion I sign off on" options — per IPS 7.7, "a parameter is a parameter, change it and restart the clock," and a conversion formula isn't out-of-sample evidence regardless of who blesses it. The correct path is sourcing **true** VIX data from a non-Alpaca provider (FRED VIXCLS, or a Polygon indices add-on that may double-solve Phase 3 prerequisite #4) — zero parameter changes, zero new Phase 1 cycle required. No capital is at risk in the interim (Phase 2 paper trading); the filter stays fail-open, which was already assessed as benign.

**No urgency** — soft target of 3-4 weeks, comfortably ahead of the strategy's Phase 3 eligibility date (2026-09-20).

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
- GitHub issue: [#44](https://github.com/JeffreyJD/prophet-trader/issues/44)

## Success criteria (re-scoped per Blake's decision)

- [x] Confirm whether Alpaca's data API supports a true VIX index bar series directly (preferred — avoids all downstream complications) or whether a proxy (e.g. VIXY) is required. — Confirmed NOT available: empirically tested `VIX` symbol against `StockBarsRequest`/`StockLatestQuoteRequest`/`StockLatestTradeRequest` on both IEX and SIP feeds via the live account — all return empty (no error, zero data). `VIXY` returns real bars immediately on the same account. See [[2026-07-10-prophet-trader-debug-vix-bars-alpaca-unavailable]].
- [x] Get a ruling on the VIXY-proxy path before writing any fallback code. — Ruled out. Blake rejected both proxy options (VIXY-now-revalidate-later, and VIXY-with-a-blessed-conversion) per IPS 7.7 — see [[2026-07-10-mbs-vix-proxy-decision]].
- [x] Confirm via log check whether 07-06/07/08 show the regime-skip debug line rather than reaching the VIX check, closing the loop on the timing explanation in Blake's memo. — Checked local `data/logs/routine-2026-07-0{6,7,8,9}.log`. Production runs at INFO, not DEBUG, so the literal debug line isn't visible for any day; but 07-06/07/08 show only a generic "no proposals today (regime gate or ...)" summary with no VIX warning, and 07-09 explicitly logs the VIX fail-open WARNING — circumstantially consistent with Blake's timing explanation, not a byte-for-byte proof. Detail in the debug deliverable.
- [ ] **New primary task:** evaluate FRED VIXCLS and/or a Polygon indices add-on for true VIX bars. Report feasibility (cost, latency, data quality, integration effort) before wiring anything into `daily_routine.py`.
- [ ] Once a true VIX source is confirmed feasible: extend the live market snapshot builder to fetch it as daily bars and inject into `bars_by_ticker["VIX"]`, exactly as originally spec'd — this part of the original plan is unchanged, only the data source changed.
- [ ] No config change — `vix_filter: true` / `vix_threshold: 25` stay as-is throughout. This remains a data-pipeline fix, not a strategy parameter change; it does not reopen Phase 1.
- [ ] Deployed to the VPS and verified live. No hard deadline — soft target within the due date above.

## Updates

- 2026-07-10 07:29 (hawkeye) — created from Blake's assessment; routing to Pierce now given the tight window before today's 09:30 ET run.
- 2026-07-10 08:10 (pierce) — investigated. Confirmed empirically that true VIX index bars/quotes are not fetchable via Alpaca's stock data API on this account (IEX and SIP both empty for symbol `VIX`; `VIXY` works fine). This trips the task's hard guardrail — proxy required, so I stopped before writing the fallback code or touching `vix_threshold`, and did not open a PR. Full findings and three options (A/B/C) for Jeff/Blake in [[2026-07-10-prophet-trader-debug-vix-bars-alpaca-unavailable]]. Task moved to `in-progress`, `blocked_reason` set. Will not make the 09:30 ET 2026-07-10 window — status quo (fail-open) continues today, which Blake's memo already assesses as benign/non-urgent. No VPS changes made; no deploy attempted.
- 2026-07-17 (pierce) — filed as GitHub issue [#44](https://github.com/JeffreyJD/prophet-trader/issues/44) per Jeff's consolidated-backlog directive; concrete replace-the-data-source enhancement, qualifies as backlog-worthy under the bugs/enhancements-only backlog scope.
- 2026-07-10 08:35 (hawkeye) — Jeff routed the A/B/C decision to Blake explicitly ("that is why we hired him"). **Blake rejected both proxy options** (Option A: VIXY now + revalidate later; Option B: VIXY + a threshold conversion he signs off on) — full reasoning in [[2026-07-10-mbs-vix-proxy-decision]]: per IPS 7.7 "a parameter is a parameter, change it and restart the clock," and a conversion formula isn't out-of-sample evidence regardless of who blesses it, including Blake himself. Also ruled the VIX.csv provenance gap (the original backtest's VIX data can't be reproduced from live Alpaca) material but not IPS-2.2-fail-triggering — it independently reinforces that VIXY is the wrong scale to substitute, since the original filter was validated against a different, currently-unidentified source. That gets tracked as a separate low-priority task, not blocking this one. Re-scoped this task per Blake's explicit handoff: dropped same-day due date and priority-1 (no capital risk, filter stays fail-open, already assessed benign), retitled from "fix live VIX bar fetch" to "source true VIX index data (non-Alpaca)," new due date 2026-08-07 (~4 weeks, comfortably ahead of the strategy's 2026-09-20 Phase 3 eligibility), priority dropped to 3, moved back to `open/` (nothing actively in-progress right now — new primary task is evaluating FRED VIXCLS / Polygon indices, not yet started).

## Outcome

_(filled when status flips to done — see SOP-012-close-task)_
