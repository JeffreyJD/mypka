---
# Identity
id: tsk-2026-07-17-014
title: "reconcile.py: add settlement grace window to avoid false-positive drift_detected on recently-filled orders"

# Ownership & priority
assignee: pierce
priority: 3

# Status (mirrors folder location)
status: open
blocked_reason: null
blocked_by: null

# Time
created: 2026-07-17T18:20:00Z
updated: 2026-07-17T18:20:00Z
due: null

# Provenance
created_by: pierce
source: jeff-directive-2026-07-17
parent: null

# Cross-references — REQUIRED, even if empty array. Seven slots. The act of filling these is the whole point.
linked_sops: ["SOP-022-deployment-fidelity-verification", "SOP-010-create-task", "SOP-012-close-task"]
linked_workstreams: []
linked_guidelines: []
linked_my_life: []
linked_session_logs: []
linked_journal_entries: []
linked_deliverables: []

# Tagging
tags: ["prophet-trader", "reconciliation", "fidelity-check", "design-review", "settlement-timing"]
---

# reconcile.py: add settlement grace window to avoid false-positive drift_detected on recently-filled orders

**GitHub issue:** [#56](https://github.com/JeffreyJD/prophet-trader/issues/56)

## What this is

Design-fix backlog item following the settlement-race investigation on [[tsk-2026-07-17-013-confirm-bac-reconciliation-clean-on-monday-run]]. That investigation confirmed — via live, directly-verified Alpaca queries, not assumption — that `scripts/reconcile.py` can classify a genuinely-filled order as `missing_in_broker` / `drift_detected` when reconciliation happens to query the broker before the fill has actually settled at the venue, even though the journal already logged the fill event. BAC on 2026-07-17: journal fill logged `13:30:52Z`, reconciliation ran `13:31:05Z`, Alpaca didn't confirm the fill until `13:33:51Z` — a ~2m46s gap the reconciliation script had no tolerance for. **Confirmed root cause: this is a point-in-time query race intrinsic to `reconcile.py`'s design, not a cron-scheduling issue.**

Recommended fix (option b, pending design review): a settlement grace window keyed off the journal fill timestamp. Journal entries whose most recent fill is younger than ~10-15 minutes get classified as a new status `pending_settlement` instead of being folded into `drift_detected` — visible in the report, but not alert-triggering, unless it's still unsettled on the *next* run.

**No code changes yet.** Jeff wants a design review between Pierce, Ledger, and Blake before implementation starts. This task and the linked GitHub issue are the concrete backlog item that review will work against.

## Context one click away

- Procedure/gate this touches: [[SOP-022-deployment-fidelity-verification]]
- Investigating task (root-cause evidence): [[tsk-2026-07-17-013-confirm-bac-reconciliation-clean-on-monday-run]]
- Related open reconcile.py issue (different bug, same file): [[tsk-2026-07-17-002-reconcile-qty-tolerance-boundary-risk]]
- Service note: [[PKM/Environment/Services/prophet-trader]]
- GitHub issue: [#56](https://github.com/JeffreyJD/prophet-trader/issues/56)
- Working artifacts: none yet — design-only stage.

## Success criteria

- [ ] Design review held between Pierce, Ledger, and Blake — grace window duration, whether `pending_settlement` should be per-ticker or global, and alerting behavior all confirmed before code starts.
- [ ] `scripts/reconcile.py::_compute_diff()` updated with the agreed grace-window logic; overall `status` no longer flips to `drift_detected` solely because of an in-window unsettled fill.
- [ ] Regression test added in `tests/test_reconcile.py`: one case inside the grace window (expect `pending_settlement`, not `drift_detected`), one case outside it (expect `drift_detected` unchanged from today's behavior).
- [ ] PR opened on `dev`, CI green, Ledger's SOP-022 Fidelity Check run if the change touches `config/fidelity_baseline.json` or scheduled-job behavior.
- [ ] GitHub issue #56 updated/closed with the shipped design and commit/PR evidence.

## Updates

- 2026-07-17 18:20 (pierce) — created per Jeff's approval to move forward on the settlement-grace-window design fix. GitHub issue [#56](https://github.com/JeffreyJD/prophet-trader/issues/56) opened first with full investigation findings; this task is the myPKA-side backlog mirror, cross-linked both directions. Explicitly NOT implementing yet — next step is a design review with Ledger and Blake per Jeff's direction, not code.

## Outcome
_(filled when status flips to done — see SOP-012-close-task)_
