---
# Identity
id: tsk-2026-07-17-007
title: "Fidelity check hash doesn't cover phase_state.json preferred_regimes — can silently drift again undetected"

# Ownership & priority
assignee: pierce
priority: 4

# Status (mirrors folder location)
status: open
blocked_reason: null
blocked_by: null

# Time
created: 2026-07-17T09:58:00Z
updated: 2026-07-17T09:58:00Z
due: null

# Provenance
created_by: pierce
source: session
parent: null

# Cross-references — REQUIRED, even if empty array. Seven slots. The act of filling these is the whole point.
linked_sops: ["SOP-022-deployment-fidelity-verification", "SOP-010-create-task", "SOP-012-close-task"]
linked_workstreams: []
linked_guidelines: []
linked_my_life: []
linked_session_logs: []
linked_journal_entries: []
linked_deliverables: ["2026-07-14-prophet-trader-daily-routine-and-fidelity-check-first-live-fire-analysis"]

# Tagging
tags: ["prophet-trader", "fidelity-check", "phase-state", "cosmetic", "low-urgency"]
---

# Fidelity check hash doesn't cover phase_state.json preferred_regimes — can silently drift again undetected

**GitHub issue:** [#48](https://github.com/JeffreyJD/prophet-trader/issues/48)

## What this is

`config/phase_state.json`'s `preferred_regimes` annotation for `momentum_breakout_stocks` was found stale on 2026-07-14 (reading `["trending-bull"]` when the live gating YAML had already been corrected to `["trending-bull", "range-bound"]` on 2026-07-08 per PR #5) and was fixed the same day (commit `93d3820`). That fix was confirmed cosmetic-only — the strategy reads `config/strategies/*.yaml` directly for gating, not this annotation — but the commit message itself flags the durable gap this task tracks: `daily_fidelity_check.py`'s `phase_state_phases` hash only covers the per-strategy `phase` field, not `preferred_regimes`. That means this specific field has **no fidelity-check coverage** and can drift out of sync with the live YAML again, silently, with nothing catching it — exactly the failure mode that produced the 2026-07-14 finding in the first place.

Currently both strategies' `preferred_regimes` in `phase_state.json` match their live YAML configs (confirmed 2026-07-17). This task is about closing the detection gap, not fixing an active drift.

## Context one click away

- Procedure: [[SOP-022-deployment-fidelity-verification]]
- Prior finding this gap was noted in: [[2026-07-14-prophet-trader-daily-routine-and-fidelity-check-first-live-fire-analysis]]
- Code: `scripts/daily_fidelity_check.py` (hash coverage), `config/phase_state.json` (the field), `config/strategies/*.yaml` (source of truth for gating)
- Working artifacts: none yet
- GitHub issue: [#48](https://github.com/JeffreyJD/prophet-trader/issues/48)

## Success criteria

- [ ] Extend `daily_fidelity_check.py`'s hash coverage (or add a dedicated lint/check) to detect when any strategy's `phase_state.json` `preferred_regimes` annotation diverges from its `config/strategies/<name>.yaml` gating config.
- [ ] Decide the failure mode when divergence is caught: NEEDS REVIEW (non-blocking, since it's cosmetic) vs. a harder FAIL — Pierce's call, documented with reasoning, consistent with how other cosmetic-vs-functional findings are classified in SOP-022.
- [ ] Regression test covering both a matching and a deliberately-diverged case.
- [ ] Deployed and verified live per Pierce's standard config-change discipline (Ledger SOP-022 sign-off, since this touches the fidelity check's own logic).

## Updates

- 2026-07-17 09:58 (pierce) — created while building the consolidated GitHub Issues backlog per Jeff's directive; confirmed both strategies currently match (no active drift) before filing — this tracks the detection gap, not a live bug.
- 2026-07-17 (pierce) — filed as GitHub issue [#48](https://github.com/JeffreyJD/prophet-trader/issues/48); small real data-integrity gap (fidelity-check coverage), qualifies as backlog-worthy under the bugs/enhancements-only backlog scope.

## Outcome

_(filled when status flips to done — see SOP-012-close-task)_
