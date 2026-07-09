---
# Identity
id: tsk-2026-07-09-003
title: "Instrument agent-council decision divergence vs. a bare regime+momentum rule"

# Ownership & priority
assignee: pierce
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

tags: ["prophet-trader", "agent-council", "analysis"]
---

# Instrument agent-council decision divergence vs. a bare regime+momentum rule

## What this is

Direct follow-up from the STORM research's Frontier Question ([[2026-07-08-systematic-trading-bot-edge-vs-prophet-trader-storm-research.html]]): no AI agent-council trading system has independent evidence of adding edge, and multi-agent LLM systems have documented correlated-failure modes. Prophet Trader has never measured whether its own council (CEO/Analyst/Strategist/Risk Officer/Executor/Auditor) actually diverges from what a bare regime+momentum rule would decide, or just rubber-stamps it.

With `momentum_breakout_stocks` able to trade again (regime config fix, 2026-07-08) and both strategies active, real decision data is about to start flowing for the first time — this is the moment to start capturing the comparison, not after months of ungathered data.

## Context one click away

- Research: [[2026-07-08-systematic-trading-bot-edge-vs-prophet-trader-storm-research.html]]
- Service: [[prophet-trader]]
- CIO owner: Blake

## Success criteria

- On every daily routine run, alongside the council's actual approve/veto decision, compute and log what a bare rule (preferred_regimes gate + momentum signal only, no council deliberation) would have proposed.
- Both decisions land in a comparable, queryable form (e.g., a new field in the existing decisions JSON, or a parallel log) — not just prose.
- After a meaningful sample accumulates (Blake to judge — likely several weeks), Blake can answer: does the council ever diverge from the bare rule, and are the divergences net-positive or net-negative in hindsight?
- Does not change any live trading behavior — this is observation-only instrumentation, not a new gate or filter.

## Updates

- 2026-07-09 (hawkeye) — created per Jeff's approval to act on the STORM research findings.

## Outcome

_(filled when status flips to done — see SOP-012-close-task)_
