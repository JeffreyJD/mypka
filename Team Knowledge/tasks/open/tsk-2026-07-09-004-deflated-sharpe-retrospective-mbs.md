---
# Identity
id: tsk-2026-07-09-004
title: "Deflated Sharpe Ratio retrospective on momentum_breakout_stocks (wf_v2-v9)"

# Ownership & priority
assignee: blake
priority: 3

# Status (mirrors folder location)
status: open
blocked_reason: null
blocked_by: null

# Time
created: 2026-07-09T02:44:00Z
updated: 2026-07-09T02:44:00Z
due: null

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
linked_deliverables: ["2026-07-08-systematic-trading-bot-edge-vs-prophet-trader-storm-research"]

tags: ["prophet-trader", "phase1", "analysis"]
---

# Deflated Sharpe Ratio retrospective on momentum_breakout_stocks

## What this is

Direct follow-up from the STORM research ([[2026-07-08-systematic-trading-bot-edge-vs-prophet-trader-storm-research]]): Bailey & López de Prado's Deflated Sharpe Ratio / Probability of Backtest Overfitting framework (peer-reviewed, the strongest-evidence finding in the whole report) says reported Sharpe ratios must be statistically discounted for the number of trials/configurations tested before being trusted.

`momentum_breakout_stocks` went through nine walk-forward iterations (wf_v2 through wf_v9) before landing on the config that passed Phase 1 (Sharpe 1.455, PF 1.519). That number has been cited everywhere since — the IPS, the autopsy, task history — without ever being corrected for the 9-trial search that produced it. This task gets an honest, statistically-adjusted confidence level instead.

## Context one click away

- Research: [[2026-07-08-systematic-trading-bot-edge-vs-prophet-trader-storm-research]]
- Backtest data: `data/phase_reviews/momentum_breakout_stocks_wf_v2.json` through `_v9.json` in the prophet-trader repo
- IPS: `PKM/Documents/prophet-trader/investment-policy-statement.md` Section 2.2

## Success criteria

- Apply the Deflated Sharpe Ratio calculation (Bailey & López de Prado, 2014) to the wf_v9 result, correcting for the effective number of independent trials across wf_v2-v9 (not naively 9, since later iterations built on earlier ones rather than being fully independent — Blake's judgment call on the right correction, documented with reasoning).
- Written evaluation brief in `Deliverables/YYYY-MM-DD-strategy-eval-mbs-deflated-sharpe.md` per Blake's standard deliverable structure: the corrected/deflated Sharpe estimate, what it means for confidence in the Phase 1 pass, and whether it changes anything about Phase 2/3 readiness timing.
- Does not retroactively fail or reopen the Phase 1 gate — this is a confidence-calibration exercise for Jeff and Blake, not a new pass/fail criterion sprung after the fact (would violate IPS Section 7.1's anti-pattern discipline).

## Updates

- 2026-07-09 (hawkeye) — created per Jeff's approval to act on the STORM research findings.

## Outcome

_(filled when status flips to done — see SOP-012-close-task)_
