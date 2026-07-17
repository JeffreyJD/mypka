---
# Identity
id: tsk-2026-07-17-001
title: "Fix reconciliation crash on fractional-share qty + journal int()-truncation bug (2026-07-16 Daily Fidelity Check FAIL)"

# Ownership & priority
assignee: pierce
priority: 1

# Status (mirrors folder location)
status: in-progress
blocked_reason: "Awaiting Ledger's independent SOP-022 Pre-deploy Fidelity Check on PR #38 (merged to dev at caeaca4) before merge to main -- this change touches config/fidelity_baseline.json, a config value, which per Pierce's own AGENTS.md hard rule gates on Ledger's PASS before promotion to main. Pierce cannot self-certify this check on his own work."
blocked_by: null

# Time
created: 2026-07-17T08:21:27Z
updated: 2026-07-17T09:10:00Z
due: null

# Provenance
created_by: pierce
source: hawkeye-dispatch-2026-07-17
parent: null

# Cross-references — REQUIRED, even if empty array. Seven slots. The act of filling these is the whole point.
linked_sops: ["SOP-022-deployment-fidelity-verification", "SOP-010-create-task", "SOP-012-close-task"]
linked_workstreams: []
linked_guidelines: []
linked_my_life: []
linked_session_logs: ["2026-07-16-22-45_hawkeye_weekly-strategy-report-deploy-and-fidelity-fixes"]
linked_journal_entries: ["2026-07-16-verify-live-third-party-state-not-just-the-registry-note"]
linked_deliverables: []

# Tagging
tags: ["prophet-trader", "reconciliation", "bug", "fractional-shares", "fidelity-check", "production"]
---

# Fix reconciliation crash on fractional-share qty + journal int()-truncation bug (2026-07-16 Daily Fidelity Check FAIL)

## What this is

2026-07-16's Daily Routine logged `Reconciliation failed (non-fatal): Unknown format code 'd' for object of type 'float'`, and the same day's Daily Fidelity Check FAILed its Reconciliation and Config/env checks. Root-caused via direct VPS inspection (routine log, `data/reconciliation/2026-07-16.json`, live Alpaca positions query, `data/trades.jsonl`):

1. **Real bug, `scripts/reconcile.py`:** `_compute_journal_positions()` truncated fill quantities via `int(event.get("qty", 0))`. Since the 2026-06-19 fractional-shares fix (`src/risk/gates.py` rounds `suggested_qty` to 6 decimals for high-priced tickers), fills can be fractional. 2026-07-16 was the first day this actually produced fractional fills (AMAT 0.839349, AMD 0.912192, CAT 0.53571, MU 0.508585, CSCO 4.270219, GOOGL 1.390782 — all `cross_sectional_momentum`). Truncating those to `int()` corrupted the journal's "expected" position for every fractional fill (e.g. `int(0.839349) == 0`), producing false "orphaned in broker" / miscounted entries even though broker and journal actually agreed exactly.
2. **Crash bug, `scripts/reconcile.py::_render_markdown()`:** used the `:+d` format spec on qty values that can be floats — raises `ValueError` on any non-whole float. This is the exact traceback in the routine log. The JSON diff (`data/reconciliation/YYYY-MM-DD.json`) was already written correctly before the crash (write_reports() writes JSON first, then renders markdown), so the `drift_detected` verdict the Fidelity Check read was real, not a crash artifact — but it was a **false positive** caused by bug #1's truncation, not a genuine broker/journal mismatch.
3. **Same crash pattern also reachable from `scripts/weekly_autopsy.py`** (`_render_markdown()`'s "Open Positions at Week-End" table, same `:+d` on a qty value sourced from the same `_compute_journal_positions()`) — would have broken the next Sunday autopsy (2026-07-19) had any fractional position still been open at week-end. Fixed in the same pass since it's the same bug class, found during this investigation.

**Verified against live state, not assumption:** queried Alpaca directly on the VPS (`AlpacaStocksAdapter.positions()`) — broker holds exactly the six fractional positions journal recorded, same quantities to 6 decimals. No real capital/position exposure was ever wrong; the mismatch was entirely a reconciliation-logic artifact. No Blake escalation needed on capital grounds.

## Context one click away

- Guideline/procedure for the gate this fix should clear: [[SOP-022-deployment-fidelity-verification]]
- Most recent relevant session: [[2026-07-16-22-45_hawkeye_weekly-strategy-report-deploy-and-fidelity-fixes]]
- Prior learning applied: [[2026-07-16-verify-live-third-party-state-not-just-the-registry-note]] — re-queried live Alpaca/VPS state directly rather than trusting the reconciliation JSON's verdict at face value.
- Working artifacts: none yet — this is a fix-in-place task, PR link and post-deploy confirmation will be added to `## Updates` below.

## Success criteria

- [x] Exact crashing line found (`_render_markdown()`'s `:+d` format specs in `scripts/reconcile.py`) and root-caused to the 2026-06-19 fractional-shares change.
- [x] Root cause of the `int()` truncation bug in `_compute_journal_positions()` found and confirmed as the source of the false `drift_detected` verdict.
- [x] Confirmed directly against live Alpaca account + journal: no genuine position mismatch, no capital/risk exposure affected.
- [x] PR opened dev-branch → CI green → merged to `dev` (PR #38, `caeaca4`).
- [ ] **Ledger's independent SOP-022 Pre-deploy Fidelity Check** on PR #38 — required before merge to `main` per Pierce's own AGENTS.md hard rule (config-value change: `config/fidelity_baseline.json`). Not yet requested — needs Hawkeye to dispatch Ledger.
- [ ] Merge `dev` → `main`, deploy via GitHub Actions, VPS confirmed running the fix.
- [ ] Next weekday reconciliation run confirmed clean on the VPS post-deploy.
- [x] Tests added covering the float-formatting crash and the fractional-share truncation scenario (both `test_reconcile.py` and `test_weekly_autopsy.py`) — 44 new, 582 total passing.

## Updates

- 2026-07-17 08:21 (pierce) — created and immediately claimed (picked up, investigating in the same session per Jeff's explicit go-ahead relayed by Hawkeye). Root cause fully traced via VPS log/JSON inspection and a direct live Alpaca query before writing any code.
- 2026-07-17 08:55 (pierce) — fix implemented on branch `fix/reconcile-fractional-qty-format` off `dev`: `scripts/reconcile.py` (float qty end-to-end, new shared `format_qty()` helper, tolerance-based diff equality), `scripts/weekly_autopsy.py` (same `format_qty()` reused for its open-positions table). New regression tests in `tests/test_reconcile.py` and `tests/test_weekly_autopsy.py` covering the exact 2026-07-16 fractional-share scenario. Full local suite: 582 passed. Also updated `config/fidelity_baseline.json` in the same PR (Issue 2 from the dispatch: absorbed the 2 new env vars + crontab chain extension from the 2026-07-16 Weekly Strategy Report deploy, per direct live re-run of the fidelity check's own hash functions on the VPS — closes the "owed baseline update" noted in tsk-2026-07-13-001 and PKM/Environment/Accounts/healthchecks-io.md).
- 2026-07-17 09:05 (pierce) — PR #38 opened against `dev`, CI green (pytest, 30s), merged (squash, `caeaca4`). **Stopped here, did not merge to `main`.** `config/fidelity_baseline.json` is a config-value change, which per Pierce's own AGENTS.md hard rule gates on Ledger's independent SOP-022 Pre-deploy Fidelity Check before `main` promotion — Pierce cannot self-certify this on his own work, and this task-runner has no ability to dispatch Ledger directly (that's Hawkeye's routing call). Flagged to Hawkeye. Everything else in scope is complete and independently verified: bug fixed, tested, live-state confirmed on the VPS (both the reconciliation logic against real fractional-share Alpaca positions, and the config_hashes/crontab checks dry-run against the updated baseline both PASS).

## Outcome
_(filled when status flips to done — see SOP-012-close-task)_
