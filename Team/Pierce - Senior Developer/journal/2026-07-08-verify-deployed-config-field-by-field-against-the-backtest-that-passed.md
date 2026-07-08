---
agent_id: pierce
type: journal-entry
created: 2026-07-08T21:00:00Z
updated: 2026-07-08T21:00:00Z
topic: config-deployment-fidelity
tags: [prophet-trader, config, phase-gates, deployment]
linked_session_logs: []
linked_tasks: [tsk-2026-07-08-002-merge-mbs-regime-config-fix]
related_journal_entries: []
status: durable
---

# When rolling a validated backtest's parameters into a live strategy config, diff the WHOLE file against the winning backtest run — not just the parameters you were actively changing.

## Context
`momentum_breakout_stocks` went through walk-forward iterations v2 through v9, adding filters one at a time (SPY trend gate, volume confirmation, sector breadth, VIX suppression, ADX). v9 finally passed the Phase 1 gate (Sharpe 1.455, PF 1.519) with `preferred_regimes: [trending-bull, range-bound]`. But the live deployed YAML kept `preferred_regimes: [trending-bull]` — the value from the original Phase 0 starting point, before any walk-forward iteration touched it. Every other parameter got carried forward correctly across v2→v9; this one line, sitting at the top of the file before the filter blocks that were actively being edited, never got touched again. It silently deployed the wf_v7 configuration — the one that FAILED gate criteria (Sharpe 0.871, PF 1.27) — while the IPS and every deliverable cited the wf_v9 numbers as if they described what was live.

## What I learned
Iterative backtest tuning naturally focuses edits on whatever's being actively changed (the new filter block being added). Parameters that were set early and never revisited — especially ones near the top of the file, away from the active edit zone — are exactly the ones that silently go stale. The fix isn't "be more careful" in the abstract; it's a specific verification step: **before marking a Phase 1 gate as passed and deploying to Phase 2, diff the full `chosen_params` dict of the winning backtest fold against the actual deployed YAML, field by field, not just eyeball the fields that were part of the current iteration's focus.** A partial review (checking only the new ADX/VIX/sector filters, which were the point of v9) missed the one field that mattered as much as any of them.

This went undetected for over two weeks because it produced no errors — the strategy just... didn't trade, which looked like reasonable regime-gated quiet, not like a bug. Silent failure modes that look like correct conservative behavior are the hardest to catch without an explicit diff step.

## When this applies
- Any time a strategy config gets updated to reflect a newly-passed walk-forward/backtest result, especially across multiple iterative versions (v2, v3, ... vN).
- Before writing "Phase 1 passed" anywhere (IPS, session log, deliverable) — verify the citation matches what's actually deployed, not what was tested in isolation.

## When this does NOT apply
- One-shot config changes with no iterative backtest history — there's no "which version is really live" ambiguity to create this failure mode.

## Evidence
- [[2026-07-08-strategy-autopsy]] — full writeup of the discovery and fix
- [[tsk-2026-07-08-002-merge-mbs-regime-config-fix]] — the fix itself, PR #5
- `data/phase_reviews/momentum_breakout_stocks_wf_v7.json` (failed, trending-bull only) vs `_v9.json` (passed, trending-bull + range-bound) — the exact before/after evidence
