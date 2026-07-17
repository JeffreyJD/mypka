---
# Identity
id: tsk-2026-07-17-006
title: "Demotion Trigger 4 (reconciliation drift) is portfolio-wide, not per-strategy — open design question"

# Ownership & priority
assignee: blake
priority: 3

# Status (mirrors folder location)
status: open
blocked_reason: null
blocked_by: null

# Time
created: 2026-07-17T09:56:00Z
updated: 2026-07-17T09:56:00Z
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
tags: ["prophet-trader", "demotion-triggers", "reconciliation", "design-question", "risk"]
---

# Demotion Trigger 4 (reconciliation drift) is portfolio-wide, not per-strategy — open design question

**GitHub issue:** [#47](https://github.com/JeffreyJD/prophet-trader/issues/47)

## What this is

`scripts/check_demotion_triggers.py` implements Demotion Trigger 4 as "reconciliation drift events > 2 in 30 days" (see `data/demotion_checks/*.md`, e.g. `T4 | Reconciliation drift events > 2 in 30 days | PASS | 0 | 2`). The check counts drift events across the whole account/portfolio, not scoped to the individual strategy being evaluated for demotion. With two live strategies (`cross_sectional_momentum`, `momentum_breakout_stocks`) sharing one paper account, a reconciliation drift caused entirely by one strategy's fills would currently count against both strategies' T4 tallies equally — a strategy with a clean execution record could be pushed toward demotion by a sibling strategy's drift.

This has not fired yet (0 drift events to date, per `data/demotion_checks/`), so it's a latent design gap, not an active bug. It is a real open design question, not obviously wrong either way (portfolio-wide could be a deliberate "shared infrastructure health" signal) — Blake's call on whether T4 should be re-scoped per-strategy or is intentionally portfolio-wide.

## Context one click away

- Code: `scripts/check_demotion_triggers.py`, `tests/test_demotion_triggers.py`
- Data: `data/demotion_checks/YYYY-MM-DD.md` (T4 row, e.g. `data/demotion_checks/2026-07-06.md`)
- Service: [[prophet-trader]]
- CIO owner: Blake (evaluation); Pierce (implementation once decided)
- GitHub issue: [#47](https://github.com/JeffreyJD/prophet-trader/issues/47)

## Success criteria

- [ ] Blake issues a written ruling: T4 stays portfolio-wide by design, or gets re-scoped to count only drift events attributable to the strategy under evaluation.
- [ ] If re-scoped: Pierce implements the per-strategy attribution (requires drift events to be tagged by which strategy's fills/positions caused them, which may itself require a schema change — confirm with Margaret if `data/reconciliation/` needs a new field).
- [ ] Regression test added covering the chosen behavior (multi-strategy drift attribution, or explicit portfolio-wide-by-design test asserting the current behavior is intentional).
- [ ] If implementation is needed, gated by Ledger's SOP-022 fidelity check per Pierce's standard config/data-touching change discipline.

## Updates

- 2026-07-17 09:56 (pierce) — created while building the consolidated GitHub Issues backlog per Jeff's directive; confirmed via `scripts/check_demotion_triggers.py` and `data/demotion_checks/` that T4 is currently computed portfolio-wide with 0 drift events fired to date (latent, not active).
- 2026-07-17 (pierce) — filed as GitHub issue [#47](https://github.com/JeffreyJD/prophet-trader/issues/47) per Jeff's clarification: this is a real design flaw (correctness gap) in existing trigger logic, not just an open question — issue is scoped to the fix, with Blake's ruling as one required step within it, not the primary framing.

## Outcome

_(filled when status flips to done — see SOP-012-close-task)_
