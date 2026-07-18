---
# Identity
id: tsk-2026-07-17-014
title: "reconcile.py: add settlement grace window to avoid false-positive drift_detected on recently-filled orders"

# Ownership & priority
assignee: pierce
priority: 3

# Status (mirrors folder location)
status: in-progress
blocked_reason: null
blocked_by: null

# Time
created: 2026-07-17T18:20:00Z
updated: 2026-07-17T23:58:00Z
due: null

# Provenance
created_by: pierce
source: jeff-directive-2026-07-17
parent: null

# Cross-references — REQUIRED, even if empty array. Seven slots. The act of filling these is the whole point.
linked_sops: ["SOP-022-deployment-fidelity-verification", "SOP-010-create-task", "SOP-011-claim-task", "SOP-012-close-task"]
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

- [x] Design review held between Pierce, Ledger, and Blake — grace window duration, whether `pending_settlement` should be per-ticker or global, and alerting behavior all confirmed before code starts.
- [x] `scripts/reconcile.py::_compute_diff()` updated with the agreed grace-window logic; overall `status` no longer flips to `drift_detected` solely because of an in-window unsettled fill.
- [x] Regression test added in `tests/test_reconcile.py`: cases inside/outside the grace window, mismatches-bucket variant, next-day escalation, orphan exclusion — 25 new tests, 58/58 total passing.
- [x] PR opened on `dev` ([#57](https://github.com/JeffreyJD/prophet-trader/pull/57)), CI green.
- [ ] Ledger's SOP-022 Fidelity Check re-verification — **required before merge**, not yet run.
- [x] GitHub issue #56 updated with the finalized design and PR evidence (not yet closed — waiting on merge).

## Design (finalized 2026-07-17)

Synthesized from Ledger's and Blake's independent reviews (see full findings in Jeff's routing directive, this task's provenance):

1. Grace window (12 min, `SETTLEMENT_GRACE_WINDOW_MINUTES`) keyed on the ticker's most recent journal fill timestamp only. **No `status=="submitted"` filter** — Ledger grepped `daily_routine.py::_execute_approved` and confirmed that field is hardcoded at write time and never transitions to anything else; it would have added zero discrimination.
2. Covers **both** `missing_in_broker` and `mismatches` (Ledger finding #2 — a partial fill mid-settlement shows a nonzero-but-wrong qty at the broker, not zero).
3. `pending_settlement` is a distinct status value, never a rewrite of `missing_in_broker` (Blake's condition) — own report section in `_render_markdown()`, own WARN-level Telegram line in `daily_routine.py`, surfaced even on an otherwise-"clean" day. No bucket disappears silently (Ledger's SOP-022 rule).
4. **Next-day escalation**: `_load_prior_pending_tickers()` reads the most recent prior `data/reconciliation/*.json` report; any ticker still `pending_settlement` there and still unresolved today bypasses the grace window entirely and escalates straight to `drift_detected`, tagged `escalated_from_pending_settlement: true` (Ledger finding #4 — a timer must never mask a genuinely stuck order past a full day).
5. Overall JSON `status` field stays the existing two-value contract (`clean`/`drift_detected`) — a pending-only day counts `clean` toward `check_demotion_triggers.py` Trigger 4 and the Phase 2→3 gate clock, since it is not real drift (Blake finding #1). `n_pending_settlement` / `pending_settlement` list are always present in the JSON so a future Weekly Autopsy rollup can query recurrence without restructuring (Blake's ask).
6. Orphans (`orphaned_in_broker`) explicitly excluded from grace-window treatment — no fill timestamp to key a window off, never a settlement race by definition.
7. Adapter `get_order`/order-status enhancement (Ledger finding #5, the real long-term fix) filed as its own backlog item: GitHub issue [#58](https://github.com/JeffreyJD/prophet-trader/issues/58), not folded into this PR.

## Updates

- 2026-07-17 18:20 (pierce) — created per Jeff's approval to move forward on the settlement-grace-window design fix. GitHub issue [#56](https://github.com/JeffreyJD/prophet-trader/issues/56) opened first with full investigation findings; this task is the myPKA-side backlog mirror, cross-linked both directions. Explicitly NOT implementing yet — next step is a design review with Ledger and Blake per Jeff's direction, not code.
- 2026-07-17 (pierce) — design review synthesized (Ledger + Blake findings routed by Jeff), implemented in `scripts/reconcile.py` / `scripts/daily_routine.py` / `scripts/daily_fidelity_check.py` on branch `fix/reconcile-settlement-grace-window`. 25 new tests in `tests/test_reconcile.py`, 58/58 passing; full suite 602 passed / 2 skipped / 4 pre-existing unrelated failures (`test_anthropic_narrator.py`, missing `anthropic` package, confirmed pre-existing on `dev`). PR [#57](https://github.com/JeffreyJD/prophet-trader/pull/57) opened against `dev`, CI green. Adapter `get_order` enhancement filed separately as [#58](https://github.com/JeffreyJD/prophet-trader/issues/58) per Ledger's finding #5 — not scope-creeped into this fix. **Not self-merging** — flagged for Ledger's SOP-022 Fidelity Check re-verification, this touches financial reconciliation logic. Task remains open pending that review and merge.

## Outcome
_(filled when status flips to done — see SOP-012-close-task)_
