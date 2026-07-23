---
# Identity
id: tsk-2026-07-22-002
title: "Blake: evaluate risk-based (stop-distance-normalized) position sizing at next quarterly risk parameter review"

# Ownership & priority
assignee: blake
priority: 4

# Status (mirrors folder location)
status: open
blocked_reason: null
blocked_by: null

# Time
created: 2026-07-23T01:53:45Z
updated: 2026-07-23T01:53:45Z
due: null

# Provenance
created_by: hawkeye
source: session
parent: null

# Cross-references — REQUIRED, even if empty array. Seven slots. The act of filling these is the whole point.
linked_sops: ["SOP-010-create-task", "SOP-012-close-task"]
linked_workstreams: []
linked_guidelines: []
linked_my_life: ["investing"]
linked_session_logs: []
linked_journal_entries: []
linked_deliverables: ["2026-06-23-blake-risk-limits-spec"]

# Tagging
tags: ["prophet-trader", "risk-doctrine", "position-sizing", "quarterly-review", "low-urgency"]
---

# Blake: evaluate risk-based (stop-distance-normalized) position sizing at next quarterly risk parameter review

## What this is

Screening a YouTube video on swing trading (Lance / TheOneLance) for Prophet Trader relevance, Blake identified a real sizing doctrine gap while checking actual configs: `momentum_breakout_stocks.yaml` sets `stop_atr_mult: 1.5` (stop distance varies per ticker by ATR) but `suggested_size_pct: 0.01` (fixed 1% of equity regardless of that ATR width). IPS §4.1 confirms Prophet Trader's sizing is fixed-percent-of-equity, not risk-based (dollars-at-risk normalized to stop distance).

Net effect: a wide-ATR name and a narrow-ATR name get the same notional exposure but carry different dollar risk to their stops. This is the same failure mode the video's presenter described from his own transition to wider-stop trading — just without the intraday-to-daily migration context, since Prophet Trader already only trades daily bars.

Blake's own framing: this is a legitimate gap, not a crisis. Current fixed-% sizing is conservative and within budget — it's just not risk-normalized across tickers. Blake explicitly declined to amend IPS §4.1 reactively (would be exactly the kind of ad hoc mid-cycle exception the IPS exists to prevent). Blake's AGENTS.md decision-rights table already lists "volatility-scaling rules" as part of the sizing doctrine mandate, but the IPS as written doesn't yet codify one — this task exists so the gap doesn't get lost before the next scheduled review.

## Context one click away

- IPS: `PKM/Documents/prophet-trader/investment-policy-statement.md` — §4.1 (current fixed-percent sizing), §7.7 (mid-phase parameter change restarts Phase 1 from zero — why this waits for the scheduled review instead of a reactive change)
- Working artifacts: [[2026-06-23-blake-risk-limits-spec]] — Blake's existing risk limits spec, likely the natural home for a stop-distance-normalized sizing rule
- Config referenced: `momentum_breakout_stocks.yaml` (`stop_atr_mult: 1.5`, `suggested_size_pct: 0.01`)
- Service: [[prophet-trader]]

## Success criteria

At the next quarterly risk parameter review, Blake evaluates and documents a decision on:

1. Whether to introduce a risk-based (dollars-at-risk normalized to stop distance) sizing rule as an alternative/supplement to fixed-percent-of-equity sizing.
2. If adopted: which strategies it applies to, and whether it triggers a Phase 1 restart for any currently-running strategy under IPS §7.7.
3. If declined: brief rationale recorded so this doesn't get re-raised without new information.

## Updates

- 2026-07-23 01:53 (hawkeye) — created, following Jeff's confirmation to open this task after Blake's screening of a YouTube-sourced swing trading video. Deliberately scoped to ride the existing quarterly cadence, not urgent.

## Outcome

_(filled when status flips to done — see SOP-012-close-task)_
