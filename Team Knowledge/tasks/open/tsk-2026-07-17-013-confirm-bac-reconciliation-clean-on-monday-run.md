---
# Identity
id: tsk-2026-07-17-013
title: "Confirm BAC reconciles clean on the next automated Daily Fidelity Check run (2026-07-17 FAIL 5/6, settlement-timing theory)"

# Ownership & priority
assignee: pierce
priority: 3

# Status (mirrors folder location)
status: open
blocked_reason: null
blocked_by: null

# Time
created: 2026-07-17T15:10:00Z
updated: 2026-07-17T15:10:00Z
due: 2026-07-20

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
linked_deliverables: []

# Tagging
tags: ["prophet-trader", "reconciliation", "fidelity-check", "watch-item", "bac"]
---

# Confirm BAC reconciles clean on the next automated Daily Fidelity Check run (2026-07-17 FAIL 5/6, settlement-timing theory)

## What this is

2026-07-17's Daily Fidelity Check returned **FAIL (5/6)** — a CRITICAL finding on the Reconciliation sub-check: `status=drift_detected`, one position `missing_in_broker` (BAC, journal expected qty `8.105355`, broker showed `0`, delta `-8.105355`). Reconciliation ran at `2026-07-17T13:31:05Z`, only ~13 seconds after the BAC order was submitted (`13:31:01Z` per Alpaca's own order record; the journal's `fill` event was logged at `13:30:52Z`). Initial read: **likely a settlement/execution-timing artifact**, not a genuine broker/journal mismatch — reconciliation queried the broker before the limit order had actually filled at the venue.

This is a watch item, not a confirmed bug. Same-day live re-check (see Updates) strongly supports the timing theory but a manual SSH re-check is not the same signal as the automated Daily Fidelity Check itself passing clean. This task tracks confirming a clean automated run.

## Context one click away

- Procedure/gate: [[SOP-022-deployment-fidelity-verification]]
- Related prior fix (different root cause, same reconciliation sub-check): [[tsk-2026-07-17-001-reconciliation-fractional-share-format-bug]]
- Related open follow-up: [[tsk-2026-07-17-002-reconcile-qty-tolerance-boundary-risk]]
- Service note: [[PKM/Environment/Services/prophet-trader]]
- Working artifacts: none — this is a monitoring/verification task, not a code-touch task (no fix has been made or is currently believed necessary).

## Success criteria

- [ ] Next automated (cron-fired, not manual) Daily Fidelity Check run reconciles BAC (and all other open positions) clean — `status=clean`, 0 mismatches, 0 missing, 0 orphaned.
- [ ] Given tomorrow (2026-07-18) is a Saturday with no cron fire, the next real weekday run is **Monday 2026-07-20 09:30 ET**. That is the confirming run this task is waiting on.
- [ ] If clean: close this task, note it as the second and stronger piece of evidence (after today's live manual re-check) that this was a one-off settlement-timing artifact, not a recurring defect.
- [ ] If it recurs (BAC or any other position shows the same missing-in-broker pattern shortly after a fill again): escalate to a real investigation — this stops being a timing artifact and becomes a genuine reconciliation-timing or order-lifecycle bug (e.g. reconciliation running before Alpaca's fill webhook/poll settles, needing a retry/backoff rather than a single point-in-time query).

## Updates

- 2026-07-17 15:10 (pierce) — created per Jeff's request as a watch-item task (task-only, no GitHub issue) following today's 5/6 Daily Fidelity Check FAIL. Same-session investigation performed immediately rather than waiting for tomorrow:
  - Read today's reconciliation JSON directly on the VPS (`data/reconciliation/2026-07-17.json`): `missing_in_broker: [{ticker: BAC, expected: 8.105355, actual: 0, delta: -8.105355}]`, reconciliation timestamp `2026-07-17T13:31:05Z`.
  - Read the journal fill event in `data/trades.jsonl`: BAC fill logged at `2026-07-17T13:30:52Z`, `qty: 8.105355`, `status: submitted` (note: journal's own status field said "submitted" at log-time, not "filled" — a separate observation, not investigated further here since it's not in scope and the position now matches exactly).
  - Live re-query directly against Alpaca (`alpaca.trading.client.TradingClient`, not inferred from any cached state), several hours-adjacent to the fill but same day, ~11:04 ET / hours after 09:30 ET market open:
    - `get_all_positions()`: BAC now shows `qty=8.105355, avg_entry_price=60.798117` — **exact match to the journal's expected qty.**
    - `get_orders()` by `client_order_id=prophet-20260717-133052-BAC-169aaf`: `status=OrderStatus.FILLED`, `qty=8.105355`, `filled_qty=8.105355`, `filled_avg_price=60.798117`, `submitted_at=2026-07-17 13:31:01Z`, `filled_at=2026-07-17 13:33:51Z`.
  - **Finding: the order was not actually filled at the venue until `13:33:51Z` — 2 minutes 46 seconds AFTER the reconciliation check ran (`13:31:05Z`).** The reconciliation script queried Alpaca for the BAC position before the broker had confirmed the fill, even though the journal had already logged a `fill` event ~13 seconds after order submission. This is strong, directly-verified evidence for the settlement-timing theory, not assumption-based. **Resolved as of this live check** — BAC now reconciles correctly at the broker. Leaving this task open per Jeff's instruction until one full automated (cron-fired) Daily Fidelity Check run confirms clean, since a manual SSH re-check is a different signal than the automated gate passing on its own schedule. Lowering urgency accordingly (priority 3, not 1/2) — this is monitoring, not an active incident.

## Outcome

_(filled when status flips to done — expected trigger: Monday 2026-07-20 09:30 ET automated Daily Fidelity Check result)_
