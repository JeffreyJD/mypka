---
# Identity
id: tsk-2026-07-09-005
title: "Research brief: optimal stock universe breadth for cross_sectional_momentum and momentum_breakout_stocks"

# Ownership & priority
assignee: bj
priority: 4

# Status (mirrors folder location)
status: open
blocked_reason: null
blocked_by: null

# Time
created: 2026-07-09T00:00:00Z
updated: 2026-07-09T00:00:00Z
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

tags: ["prophet-trader", "research", "phase1"]
---

# Research brief: optimal universe breadth for the two active strategies

## What this is

Current live universe is 120 names for both `cross_sectional_momentum` and `momentum_breakout_stocks`. This is narrow relative to how the peer-reviewed literature validates cross-sectional ranking strategies specifically — the academic momentum studies referenced in the STORM research (Jegadeesh & Titman; Moskowitz, Ooi & Pedersen 2012) rank against the full NYSE/AMEX/NASDAQ universe, not a few hundred names. Blake flagged a real case for expanding it, with a real cost: universe composition is a strategy parameter, so changing it triggers a new Phase 1 walk-forward and resets whichever strategy's clock changes.

**This is prep research, not a trigger for immediate action.** Do not treat this brief as authorization to start a new Phase 1 cycle — Blake evaluates the brief and issues a structured go/no-go per his standard method (regime validity, walk-forward discipline, position-sizing fit, correlation with existing strategies, operational readiness) before anything changes. The intent is to have this research ready to combine with the Phase 3 survivorship-clean data source upgrade (already an IPS gate) as one bundled re-validation cycle, rather than two separate clock resets at different times.

## Context one click away

- STORM research: [[2026-07-08-systematic-trading-bot-edge-vs-prophet-trader-storm-research/report.html]]
- IPS: `PKM/Documents/prophet-trader/investment-policy-statement.md` Section 2.4 Gate 4 (survivorship-clean universe), Section 6.3 (parameter changes)
- Service: [[prophet-trader]]

## Success criteria

Research brief answering, with citations:

1. What universe breadth (number of names, market-cap/liquidity range) does the peer-reviewed literature actually use to validate cross-sectional momentum ranking strategies, and does a 120-name universe undermine the statistical validity of a top-6 ranking approach?
2. For a Donchian-breakout strategy specifically (not ranking-based — each name evaluated independently), what's the evidence on opportunity-set size vs. signal quality as universe grows? Does more names simply mean more (possibly lower-quality) signals, or does breadth help here too?
3. What liquidity/market-cap floor should scale with universe size to avoid introducing untradeable micro-caps (current filter: `min_adv_dollars: 5000000`)?
4. How does universe breadth interact with the Phase 3 survivorship-clean data source requirement (Polygon or equivalent) — is there a natural universe size that data source supports well, so the two upgrades can land together?

Delivered as a standard B.J. research brief to `Deliverables/`, handed to Blake for evaluation — not actioned directly.

## Updates

- 2026-07-09 (hawkeye) — created per Jeff's approval, explicitly sequenced as prep work for a future bundled Phase 1 cycle with the Phase 3 data-source upgrade, not immediate action.

## Outcome

_(filled when status flips to done — see SOP-012-close-task)_
