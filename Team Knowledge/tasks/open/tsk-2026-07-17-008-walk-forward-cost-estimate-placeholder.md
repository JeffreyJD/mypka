---
# Identity
id: tsk-2026-07-17-008
title: "walk_forward.py _stress_test() cost-estimate placeholder needs a proper version"

# Ownership & priority
assignee: pierce
priority: 4

# Status (mirrors folder location)
status: open
blocked_reason: null
blocked_by: null

# Time
created: 2026-07-17T10:00:00Z
updated: 2026-07-17T10:00:00Z
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
tags: ["prophet-trader", "backtest", "walk-forward", "tech-debt", "low-urgency"]
---

# walk_forward.py _stress_test() cost-estimate placeholder needs a proper version

**GitHub issue:** [#49](https://github.com/JeffreyJD/prophet-trader/issues/49)

## What this is

`src/backtest/walk_forward.py::_stress_test()` approximates cost stress (elevated fees/slippage) by subtracting a scaled delta from each fold's return, rather than re-running the simulator with the higher costs and letting positions evolve differently. The function's own docstring says: *"This is still a first-order approximation. A true stress test would re-run the simulator with the higher costs and let positions evolve differently. The proper version is TODO; this estimate is conservative for fail-fast use."*

This is a known, documented, deliberate simplification (not a silent bug) used for fast fail-fast stress testing during walk-forward validation. It has never been tracked as a standing item.

## Context one click away

- Code: `src/backtest/walk_forward.py::_stress_test()` (see the docstring and cost-scaling comment around line 258)
- Working artifacts: none yet
- GitHub issue: [#49](https://github.com/JeffreyJD/prophet-trader/issues/49)

## Success criteria

- [ ] Implement a full re-simulation stress test: re-run the fold simulator with elevated `fee_bps`/`slippage_bps` and let position sizing/exits evolve under the higher costs, rather than the current linear-delta approximation.
- [ ] Compare the new stress test's output against the current approximation on at least one existing gate-passed strategy's walk-forward data (e.g. `momentum_breakout_stocks` wf_v9) to confirm the approximation was in fact conservative, as claimed, or document if it wasn't.
- [ ] Keep the current linear approximation available as a fast fail-fast pre-check if the full re-simulation is meaningfully slower — Pierce's call on whether to replace or supplement.
- [ ] Regression tests updated/added; CI green.
- [ ] Does not retroactively invalidate any existing Phase gate — this improves stress-test fidelity going forward, it isn't grounds to reopen a passed gate on its own.

## Updates

- 2026-07-17 10:00 (pierce) — created while building the consolidated GitHub Issues backlog per Jeff's directive, tracking a documented TODO that had never been filed.
- 2026-07-17 (pierce) — filed as GitHub issue [#49](https://github.com/JeffreyJD/prophet-trader/issues/49); real tech-debt/enhancement, qualifies as backlog-worthy under the bugs/enhancements-only backlog scope.

## Outcome

_(filled when status flips to done — see SOP-012-close-task)_
