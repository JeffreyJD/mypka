---
# Identity
id: tsk-2026-07-14-001
title: "Daily Alpha Brief's P&L calculation may always read $0.00 — trade schema mismatch in risk_journal.py"

# Ownership & priority
assignee: pierce
priority: 3

# Status (mirrors folder location)
status: done
blocked_reason: null
blocked_by: null

# Time
created: 2026-07-14T01:25:54Z
updated: 2026-07-17T16:20:00Z
due: 2026-07-21

# Provenance
created_by: hawkeye
source: session
parent: null

# Cross-references — REQUIRED, even if empty array. Seven slots. The act of filling these is the whole point.
linked_sops: ["SOP-010-create-task", "SOP-012-close-task", "SOP-022-deployment-fidelity-verification"]
linked_workstreams: []
linked_guidelines: []
linked_my_life: []
linked_session_logs: []
linked_journal_entries: []
linked_deliverables: ["2026-07-13-prophet-trader-deploy-cross-strategy-sweep", "2026-07-17-prophet-trader-deploy-risk-journal-pnl-schema-fix"]

# Tagging
tags: ["prophet-trader", "data-integrity", "risk-journal", "daily-alpha-brief"]
---

# Daily Alpha Brief's P&L calculation may always read $0.00 — trade schema mismatch in risk_journal.py

## What this is

Found (not fixed) during Pierce's broader cross-strategy-mixing sweep on 2026-07-13 ([[2026-07-13-prophet-trader-deploy-cross-strategy-sweep]]), triggered by Jeff's "identify and fix all bugs" directive after a live demotion-trigger bug surfaced the same day. This is a distinct bug class from the cross-strategy-mixing issues found elsewhere that day (fill attribution, regime persistence, decision aggregation) — deliberately not folded into that sweep's fixes.

`src/briefs/fetchers/risk_journal.py::_compute_pnl()` reads a trade schema that doesn't match the real shape of records in `data/trades.jsonl`. If confirmed, this means day/week P&L figures in the Daily Alpha Brief may have always read `0.0`, silently, rather than the actual realized P&L.

## Context one click away

- [[2026-07-13-prophet-trader-deploy-cross-strategy-sweep]] — where this was found, full detail on the broader sweep it was found during
- [[2026-07-17-prophet-trader-deploy-risk-journal-pnl-schema-fix]] — post-deploy confirmation (merge chain, CI, VPS HEAD match, log status)
- `C:\Users\jeff\dev\prophet-trader\src\briefs\fetchers\risk_journal.py` (`_compute_pnl()`)
- `C:\Users\jeff\dev\prophet-trader\data\trades.jsonl` (real schema to compare against)

## Success criteria

- [x] Confirm the actual schema mismatch — what field(s) `_compute_pnl()` expects vs. what `trades.jsonl` records actually contain.
- [x] Confirm the actual production impact — has the Daily Alpha Brief been silently reporting $0.00 P&L, or is there a fallback/different path that masks this in practice?
- [x] Fix the schema mismatch, with a regression test that would have caught it.
- [x] Confirm no other consumer of this same fetcher/schema has the identical problem.
- [x] Ledger's SOP-022 fidelity check on PR #52.
- [x] Merge to `main`, deploy, tail logs, confirm next Daily Alpha Brief run.

## Findings (confirmed, not a false alarm)

Verified directly against live `data/trades.jsonl` on `davisglobe-vps-ash-1` (2026-07-17), not just the task description. `_compute_pnl()` checked `status == "closed"` / `t["close_timestamp"]` / `t.get("pnl")`. None of those exist in the real event schema. Real fill records look like:
`{"event_type": "fill", "trade_id": "...", "is_open": true, "is_close": false, "timestamp": "...", "status": "submitted", ...}` — order-lifecycle `status` is never `"closed"`, the timestamp key is `timestamp` not `close_timestamp`, and there is no `pnl` key at all (realized P&L lives in `realized_pnl`, only present on `is_close: true` fills). `src/journal/drawdown.py` (used correctly by `check_demotion_triggers.py`, `weekly_strategy_report.py`, `weekly_autopsy.py`, `bootstrap_quarter_open_equity.py`) already uses the right schema — `risk_journal.py::_compute_pnl()` was the sole offender, unpatched since the initial Phase 2 commit (`0fe24a9`).

Confirmed with zero fallback path: `_compute_pnl()` matched **zero records, unconditionally**, since the file was created. Every Daily Alpha Brief to date has read $0.00 day/week P&L regardless of actual trading activity.

**Historical-correction check:** production `data/trades.jsonl` currently has 8 events total, only 6 fills, and **zero closed fills** (all opens from the 2026-07-16 rebalance are still `is_close: false`). So no past brief's $0.00 P&L masked a real nonzero value — the bug was live but had zero realized impact to date by coincidence. No correction note needed for historical briefs. This fix matters starting with the first rebalance close.

**Bonus finding (not in scope, filed separately):** `_summarize_open_positions()` and `deployed_pct` in the same file have the identical schema-mismatch pattern (`status == "open"`, `size_pct`, `unrealized_pnl` — none of which exist either), plus the harder problem that this fetcher deliberately never calls the broker, so there's no local mark-to-market source for true unrealized P&L. Filed as [[tsk-2026-07-17-010-risk-journal-open-positions-schema-mismatch]] rather than bundled into this fix.

Also discovered the existing test (`test_open_positions_summary` in `tests/test_fetchers.py`) had been asserting against a fictional fixture schema that matched the buggy code's own wrong assumptions rather than the real event shape — meaning it gave false confidence and would never have caught this bug. Split it: the P&L portion is replaced by a new `test_day_pnl_from_real_closed_fill_schema` test built on the real schema (verified against copied live VPS data); the open-positions portion is kept but now explicitly annotated as testing known-broken behavior, not a green light.

## Fix

`fix/risk-journal-pnl-schema-mismatch` branch off `dev`, PR [#52](https://github.com/JeffreyJD/prophet-trader/pull/52) — `_compute_pnl()` now reads `event_type == "fill"`, `is_close`, `timestamp`, `realized_pnl`. CI (`pytest`) passing. Full suite: 577 passed, 2 skipped, 4 pre-existing unrelated failures (`test_anthropic_narrator.py` — missing `anthropic` package in this venv, unrelated to this change).

Financial-calculation code per Pierce's contract → requires Ledger's [[SOP-022-deployment-fidelity-verification]] PASS before merge to `main`. Requesting that now; flagging to Hawkeye in case Pierce cannot dispatch Ledger directly this session.

## Updates

- 2026-07-14 01:25 (hawkeye) — created per Jeff's explicit "we must have all bugs identified and fixed asap" directive, tracking this so it doesn't get lost now that the higher-priority report-script build and the healthchecks naming fix are in progress. Not urgent relative to those — the Daily Alpha Brief is a separate, lower-stakes surface than the demotion/reconciliation logic fixed same-day — but real and worth closing properly.
- 2026-07-17 11:10 (pierce) — confirmed the bug against live VPS `data/trades.jsonl` (not a false alarm); fixed `_compute_pnl()` in `src/briefs/fetchers/risk_journal.py`; added regression test built on the real schema; verified against a live copy of production trade data (correctly returns $0.00 because zero closed fills exist yet — no crash, no false positive); confirmed no other consumer of the journal reimplements the wrong schema; opened PR #52 on `dev`, CI green; filed follow-up [[tsk-2026-07-17-010-risk-journal-open-positions-schema-mismatch]] for the related-but-separate open-positions/deployed_pct bug in the same file; moved this task to in-progress pending Ledger's SOP-022 check and deploy.
- 2026-07-17 16:20 (pierce) — Ledger's SOP-022 check on PR #52 **PASSED** — safe to merge and deploy, with two non-blocking findings (see Outcome). Merged PR #52 into `dev` (commit `c8a148a`, merge `c80e423`). Per Jeff's direction, findings from Ledger's check were handled as immediate remediation rather than deferred backlog: removed the dead-code duplicate (`realized_edge()`) same-session in PR #54, opened+closed GH issue #55 with evidence, and filed+closed matching myPKA task [[tsk-2026-07-17-012-remove-dead-realized-edge]]. Opened release PR #53 (`dev` → `main`), CI green, merged at `ea5c677`. GitHub Actions deploy confirmed (`Deploy complete — ea5c677`); VPS `git rev-parse HEAD` independently confirmed matching. Closed GH issue #29 (auto-closed by PR #53's `Fixes #29`; added full fix-confirmation comment). Filed [[tsk-2026-07-17-011-council-intent-standdown-warning-first-live-trigger]] as a myPKA-task-only watch item for Ledger's informational finding #2 (no GH issue — not a bug/enhancement yet). Task done.

## Outcome

What shipped: `_compute_pnl()` in `src/briefs/fetchers/risk_journal.py` now reads the real trade schema (`event_type == "fill"`, `is_close`, `timestamp`, `realized_pnl"`) instead of the fictional one it had used since the initial Phase 2 commit (`status == "closed"`, `close_timestamp`, `pnl`), which matched zero records unconditionally — every Daily Alpha Brief to date read $0.00 day/week P&L regardless of actual activity. Historical-correction check confirmed no past brief masked a real nonzero value (production `trades.jsonl` has zero closed fills to date) — the bug was live but had zero realized impact by coincidence; this fix matters starting with the first rebalance close. Added regression test `test_day_pnl_from_real_closed_fill_schema` built on the real schema.

Where it lives: PR [#52](https://github.com/JeffreyJD/prophet-trader/pull/52) → `dev` (`c8a148a`/`c80e423`). Release PR [#53](https://github.com/JeffreyJD/prophet-trader/pull/53) → `main` at `ea5c677`. GitHub Actions "Deploy complete — ea5c677" confirmed; VPS `git rev-parse HEAD` = `ea5c677a2b31e4d0cf6bc969d773f6ef9a25f2ba`, matching. GitHub issue [#29](https://github.com/JeffreyJD/prophet-trader/issues/29) closed with fix confirmation. Full end-to-end verification with a real nonzero realized P&L awaits the first closed fill in production (zero exist as of this close) — the code path is deployed and correct, just not yet exercised with nonzero data.

**Ledger's SOP-022 verdict:** PASS — safe to merge and deploy. Two findings:
1. **[LOW, remediated same-session]** Dead-code duplicate of this exact schema bug in `src/strategies/base.py::realized_edge()` (never called in production, only referenced in two stale comments). Per Jeff's corrected direction (any code-touch remediation gets a tracked GitHub issue + myPKA task, even when fixed immediately), this was deleted in PR [#54](https://github.com/JeffreyJD/prophet-trader/pull/54) (`dev` commit `13be8de`/`2955690`), tracked via GH issue #55 (opened and closed same-session with evidence) and myPKA task [[tsk-2026-07-17-012-remove-dead-realized-edge]] (created and closed done same-session). No open thread remains for this finding.
2. **[LOW/informational]** The now-correct `week_pnl_pct` feeds `council_intent.py`'s stand-down warning text (-3%/-5% week P&L thresholds) for the first time ever in production — previously always pinned at 0.0, so that branch never fired. Display-only; does not touch the separately-correct G5 halt gate. Per Jeff's clarified backlog rule (future work effort that is neither a bug nor an enhancement still needs a myPKA task, just not a GitHub issue), tracked as [[tsk-2026-07-17-011-council-intent-standdown-warning-first-live-trigger]] — a watch item for the first time a real closed loss crosses those thresholds.

Follow-ups: [[tsk-2026-07-17-010-risk-journal-open-positions-schema-mismatch]] (pre-existing, separate bug class — `_summarize_open_positions()`/`deployed_pct` schema mismatch, still open, not part of this fix). [[tsk-2026-07-17-011-council-intent-standdown-warning-first-live-trigger]] (new, open watch item). [[tsk-2026-07-17-012-remove-dead-realized-edge]] (new, closed done same-session).

Lessons: none new beyond what's already captured in the Findings section above — the existing lesson (grep for schema-mismatch duplicates elsewhere in the codebase once one is found) is what surfaced both the dead-code duplicate and the open-positions follow-up.

Archived deliverables:
  - `2026-07-13-prophet-trader-deploy-cross-strategy-sweep` → checked for sharing against other open/in-progress tasks; none found referencing it, archived to `Deliverables/_archive/2026/07/2026-07-13-prophet-trader-deploy-cross-strategy-sweep.md`.
  - `2026-07-17-prophet-trader-deploy-risk-journal-pnl-schema-fix` (post-deploy confirmation, written at close) → archived directly to `Deliverables/_archive/2026/07/2026-07-17-prophet-trader-deploy-risk-journal-pnl-schema-fix.md`.
