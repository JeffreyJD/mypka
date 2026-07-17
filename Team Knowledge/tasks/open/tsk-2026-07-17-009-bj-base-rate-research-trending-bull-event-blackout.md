---
# Identity
id: tsk-2026-07-17-009
title: "B.J. base-rate research: trending-bull and event-blackout frequency from Phase 1 backtest period"

# Ownership & priority
assignee: bj
priority: 4

# Status (mirrors folder location)
status: open
blocked_reason: null
blocked_by: null

# Time
created: 2026-07-17T10:02:00Z
updated: 2026-07-17T10:02:00Z
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
linked_deliverables: ["2026-07-08-strategy-autopsy"]

# Tagging
tags: ["prophet-trader", "research", "base-rate", "regime", "low-urgency"]
---

# B.J. base-rate research: trending-bull and event-blackout frequency from Phase 1 backtest period

## What this is

Recommendation 3 from Blake's 2026-07-08 autopsy ([[2026-07-08-strategy-autopsy]]): "Have B.J. pull historical base-rate frequency of `trending-bull` and event-blackout overlap from the Phase 1 backtest period, to replace the current 7-week anecdotal read with an evidence-based expectation of trade frequency." The autopsy's own estimate that `event-driven` blackouts remove roughly 20-30% of trading days was explicitly anecdotal, not measured — this research replaces that guess with a real number pulled from the historical data the Phase 1 walk-forwards were validated against.

This directly feeds [[tsk-2026-07-17-005-event-driven-regime-csm-formal-evaluation]] — Blake's formal evaluation of whether `cross_sectional_momentum` should trade through event-driven windows benefits from real frequency data rather than the anecdotal estimate.

## Context one click away

- Working artifacts: [[2026-07-08-strategy-autopsy]] — recommendation 3, source of this task
- Feeds into: [[tsk-2026-07-17-005-event-driven-regime-csm-formal-evaluation]]
- Data: `config/calendar.yaml` (event blackout dates), historical regime classification data used in the Phase 1 walk-forward backtests
- Service: [[prophet-trader]]

## Success criteria

Research brief answering, with citations/data sourcing shown:

1. Over the Phase 1 backtest period, what fraction of trading days fell in a `trending-bull` regime? What fraction were within an `event-driven` blackout window (FOMC/CPI/NFP/PPI/GDP/CB events within 48 hours)?
2. What fraction of days had regime AND event-blackout overlap (i.e., days that would be excluded from trading under the current gating regardless of which factor is considered)?
3. How does the measured frequency compare to the autopsy's anecdotal 20-30% estimate?

Delivered as a standard B.J. research brief to `Deliverables/`, handed to Blake — feeds [[tsk-2026-07-17-005-event-driven-regime-csm-formal-evaluation]], not actioned directly.

## Updates

- 2026-07-17 10:02 (pierce) — created while building the consolidated GitHub Issues backlog per Jeff's directive, formalizing Blake's autopsy recommendation 3 into a tracked task.
- 2026-07-17 (pierce) — Jeff clarified the GitHub Issues backlog is for bugs/enhancements only, not research activities. This is a B.J. research brief, so it stays myPKA-task-only — no GitHub issue filed.

## Outcome

_(filled when status flips to done — see SOP-012-close-task)_
