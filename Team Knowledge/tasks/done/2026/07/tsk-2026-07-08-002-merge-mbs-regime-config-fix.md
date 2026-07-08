---
# Identity
id: tsk-2026-07-08-002
title: "Approve and merge PR #5 — restore momentum_breakout_stocks gate-passing regime config"

# Ownership & priority
assignee: jeff
priority: 1

# Status (mirrors folder location)
status: done
blocked_reason: null
blocked_by: null

# Time
created: 2026-07-08T00:00:00Z
updated: 2026-07-08T15:52:00Z
due: null

# Provenance
created_by: hawkeye
source: session
parent: null

linked_sops: []
linked_workstreams: []
linked_guidelines: []
linked_my_life: []
linked_session_logs: []
linked_journal_entries: ["2026-07-08-verify-deployed-config-field-by-field-against-the-backtest-that-passed"]
linked_deliverables: ["2026-07-08-strategy-autopsy", "2026-07-08-prophet-trader-deploy-mbs-regime-fix"]

tags: ["prophet-trader", "config", "phase2"]
---

# Approve and merge PR #5 — momentum_breakout_stocks regime config fix

## What this is

`momentum_breakout_stocks.yaml` was live with `preferred_regimes: [trending-bull]` only — the exact config that FAILED Phase 1 (Sharpe 0.871, PF 1.27). The actual gate-passing config (wf_v9, Sharpe 1.455, PF 1.519, cited in the IPS) requires `[trending-bull, range-bound]`. PR #5 restores it. Zero live trades occurred under the wrong config, so nothing is invalidated by fixing it now.

PR also extends `config/calendar.yaml` through September 2026 and fixes an EARNINGS-kind filter mismatch so a calendar entry marked "treat as event-driven" is actually honored.

## Context one click away

- PR: https://github.com/JeffreyJD/prophet-trader/pull/5
- Autopsy: [[2026-07-08-strategy-autopsy]]
- Service: [[prophet-trader]]

## Success criteria

- Jeff reviews PR #5 and confirms no objection to the corrected regime set
- PR merged to `main`, GitHub Actions deploy confirmed, VPS commit verified
- Post-deploy confirmation written per Pierce's deliverable structure

## Updates

- 2026-07-08 (hawkeye) — created after finding and fixing the config drift during a Prophet Trader deep-dive session.
- 2026-07-08 15:52 (hawkeye) — Jeff approved. Merged PR #5 to `main` (`98b1422`), CI green (2/2), deploy workflow succeeded, VPS confirmed at `98b1422` with correct config content verified directly (not just deploy-log trust).

## Outcome

What shipped: `momentum_breakout_stocks` restored to its actual Phase-1-gate-passing configuration (`preferred_regimes: [trending-bull, range-bound]`), plus a calendar extension through September 2026 and an EARNINGS-classification fix. Live on VPS as of 2026-07-08 15:52 UTC.

Where it lives: PR https://github.com/JeffreyJD/prophet-trader/pull/5, merge commit `98b1422`. Post-deploy confirmation: [[2026-07-08-prophet-trader-deploy-mbs-regime-fix]].

Follow-ups: none required. Optional: B.J. to pull historical trending-bull/range-bound base rates (referenced in the autopsy) to set realistic trade-frequency expectations going forward — not blocking, no task opened yet.

Lessons: [[2026-07-08-verify-deployed-config-field-by-field-against-the-backtest-that-passed]] (Pierce's journal) — iterative backtest tuning leaves early-set parameters vulnerable to going stale while active edits focus elsewhere; verify the full param dict against the winning fold, not just the fields in this iteration's focus.

Archived deliverables: none archived yet — [[2026-07-08-strategy-autopsy]] and [[2026-07-08-prophet-trader-deploy-mbs-regime-fix]] both stay active in `Deliverables/` since the autopsy is a living/recurring document type, not a one-off task artifact.
