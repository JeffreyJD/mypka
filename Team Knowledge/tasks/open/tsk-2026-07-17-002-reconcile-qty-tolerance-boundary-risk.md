---
# Identity
id: tsk-2026-07-17-002
title: "Widen scripts/reconcile.py QTY_TOLERANCE boundary (strict > at exactly 1e-6 can silently mask a genuine drift)"

# Ownership & priority
assignee: pierce
priority: 3

# Status (mirrors folder location)
status: open
blocked_reason: null
blocked_by: null

# Time
created: 2026-07-17T09:20:00Z
updated: 2026-07-17T09:20:00Z
due: null

# Provenance
created_by: pierce
source: ledger-sop-022-recheck-pr-38
parent: null

# Cross-references — REQUIRED, even if empty array. Seven slots. The act of filling these is the whole point.
linked_sops: ["SOP-022-deployment-fidelity-verification", "SOP-010-create-task"]
linked_workstreams: []
linked_guidelines: []
linked_my_life: []
linked_session_logs: []
linked_journal_entries: ["2026-07-16-verify-live-third-party-state-not-just-the-registry-note"]
linked_deliverables: []

# Tagging
tags: ["prophet-trader", "reconciliation", "fractional-shares", "edge-case", "low-urgency"]
---

# Widen scripts/reconcile.py QTY_TOLERANCE boundary (strict > at exactly 1e-6 can silently mask a genuine drift)

**GitHub issue:** [#43](https://github.com/JeffreyJD/prophet-trader/issues/43)

## What this is

Surfaced as a non-blocking [MODERATE] finding in Ledger's SOP-022 re-check of PR #38 (`fix: reconciliation crash + false-positive drift on fractional-share fills`), which otherwise returned an overall PASS.

`scripts/reconcile.py` defines `QTY_TOLERANCE = 1e-6` and uses strict `>` in two places:

- Line ~249: `{k: v for k, v in positions.items() if abs(v) > QTY_TOLERANCE}` — decides whether a position counts as "open" vs. treated as closed/zero.
- Line ~344: `elif abs(e - a) > QTY_TOLERANCE:` — decides whether an expected-vs-actual quantity diff counts as a mismatch.

`src/risk/gates.py` rounds `suggested_qty` to exactly 6 decimal places for fractional-share fills. That means a position of precisely `0.000001` (1e-6) fails the strict `>` test and would be silently treated as closed/zero even though it is a real, nonzero position. Symmetrically, a genuine expected-vs-actual delta of exactly `1e-6` would not register as a mismatch, when it arguably should.

**Not currently triggered:** all six live fractional-share positions on `davisglobe-vps-ash-1` (AMAT 0.839349, AMD 0.912192, CAT 0.53571, MU 0.508585, CSCO 4.270219, GOOGL 1.390782) are well above this threshold. No live impact today. This is a latent edge case, not an active bug.

## Context one click away

- Guideline/procedure for the gate this originated from: [[SOP-022-deployment-fidelity-verification]]
- Related closed task (the fix this finding was raised against): [[tsk-2026-07-17-001-reconciliation-fractional-share-format-bug]]
- Prior learning applied: [[2026-07-16-verify-live-third-party-state-not-just-the-registry-note]]
- Working artifacts: none yet.
- GitHub issue: [#43](https://github.com/JeffreyJD/prophet-trader/issues/43)

## Success criteria

- [ ] Decide the correct fix: widen the comparison to `>=`, or shrink `QTY_TOLERANCE` to a smaller epsilon (e.g. `1e-9`) so 6-decimal-rounded fractional quantities can never land exactly on the boundary — pick one deliberately, don't just flip the operator without reasoning about which is more correct given gates.py's 6-decimal rounding.
- [ ] Add a boundary regression test in `tests/test_reconcile.py` covering a position/delta of exactly the tolerance value, confirming it is correctly classified (not silently dropped).
- [ ] Confirm no other caller of `QTY_TOLERANCE`-adjacent logic (e.g. `scripts/weekly_autopsy.py`'s reuse of `_compute_journal_positions`/`format_qty`) has the same boundary issue.
- [ ] PR opened on `dev`, CI green, merged. Does not require a fresh Ledger SOP-022 check unless it touches `config/fidelity_baseline.json` (it shouldn't — pure logic/test change).

## Updates

- 2026-07-17 09:20 (pierce) — created from Ledger's SOP-022 re-check finding #2 on PR #38. Deliberately deferred rather than rushed into the PR #38/#39/#40 deploy pass — this deserves its own careful pass with a boundary test per Hawkeye's direction.
- 2026-07-17 (pierce) — filed as GitHub issue [#43](https://github.com/JeffreyJD/prophet-trader/issues/43) per Jeff's consolidated-backlog directive; concrete bug fix, qualifies as backlog-worthy under the bugs/enhancements-only backlog scope.

## Outcome
_(filled when status flips to done — see SOP-012-close-task)_
