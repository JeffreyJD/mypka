---
# Identity
id: tsk-2026-07-12-001
title: "Update fidelity baseline after first live Monday run, then dispatch Ledger's required SOP-022 follow-up recheck"

# Ownership & priority
assignee: pierce
priority: 2

# Status (mirrors folder location)
status: done
blocked_reason: null
blocked_by: null

# Time
created: 2026-07-12T10:05:31Z
updated: 2026-07-15T02:40:00Z
due: 2026-07-15

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
linked_deliverables: ["2026-07-11-prophet-trader-deploy-daily-fidelity-check", "2026-07-14-prophet-trader-debug-fidelity-check-red-alert", "2026-07-14-prophet-trader-deploy-fidelity-baseline-and-hygiene-fixes"]

# Tagging
tags: ["prophet-trader", "ledger", "fidelity-check", "davisglobe-vps-ash-1", "follow-up"]
---

# Update fidelity baseline after first live Monday run, then dispatch Ledger's required SOP-022 follow-up recheck

## What this is

PR #13 (Daily Fidelity Check, deployed 2026-07-11) shipped with `config/fidelity_baseline.json` deliberately captured from **pre-deploy** live state — meaning the very first live chained run (Monday 2026-07-13, since the cron doesn't fire on weekends) will correctly show a one-time expected drift finding (the new cron line, the two new env vars this PR itself added). That's a true positive by Ledger's own design, not a bug.

Two things need to happen after that first real run, in order, and neither should be skipped or assumed:

1. **Pierce updates the baseline** to reflect the new, correct post-deploy state — once he's confirmed the first live run's drift finding matches exactly what was expected (nothing else, no surprise findings).
2. **Ledger runs his own follow-up SOP-022 check** on that baseline update. Per his explicit statement in the PR #13 Fidelity Check report: *"I will not accept that update on say-so; when it happens, it needs its own SOP-022 pass or at minimum a spot recheck."*

This task exists specifically so step 2 doesn't quietly get skipped — Pierce's own report described this as "I'll flag back to Hawkeye," which is exactly the kind of informal, easy-to-forget handoff this whole thread (starting from "why can't there be a deep dive review after each daily run") was about closing.

## Context one click away

- [[2026-07-11-prophet-trader-deploy-daily-fidelity-check]] — Pierce's post-deploy confirmation
- [[tsk-2026-07-11-001-automate-fidelity-non-clean-surfacing]] — sibling open task from the same PR's Ledger review (different finding, same review)
- Session log covering the Ledger hire and this whole thread: [[2026-07-10-18-19_hawkeye_ledger-hire-and-prophet-trader-fidelity-fixes]]

## Success criteria

- [x] Monday 2026-07-13's chained daily routine + fidelity check run confirmed to have actually fired — it did, and produced a real **FAIL (3/6)**, not the expected clean one-time-drift result. One failure was the (now-fixed) healthchecks slug bug — Monday's run used pre-fix code. The other two (crontab, config/env-hash) are the genuinely expected pre-deploy-vs-post-deploy drift this task exists to close.
- [x] Root cause of the ongoing red alert confirmed: a non-PASS verdict fires a `/fail` ping to healthchecks.io, which flips the check red immediately, independent of schedule/grace timing — not a display artifact, an unacknowledged fail signal sitting since Monday. Full detail: [[2026-07-14-prophet-trader-debug-fidelity-check-red-alert]].
- [x] Today's (2026-07-14) 09:30 ET run confirmed — Routine sub-check passed clean (fix deployed); crontab/config-hash sub-checks failed again for exactly the predicted, already-diagnosed baseline-staleness reason, nothing new. See [[2026-07-14-prophet-trader-daily-routine-and-fidelity-check-first-live-fire-analysis]].
- [x] Pierce updated `config/fidelity_baseline.json` (and, bundled into the same PR, corrected a separate stale `config/phase_state.json` annotation found during the same review) — as its own commit, deliberately after today's run. Branch `fix/fidelity-baseline-post-deploy-update` → PR [#22](https://github.com/JeffreyJD/prophet-trader/pull/22), CI green. **Not merged** — held per SOP-022/Pierce's own contract until Ledger's independent pass.
- [x] Hawkeye dispatches Ledger for the required SOP-022 §1 pre-deploy fidelity check on PR #22 — not accepted on Pierce's say-so.
- [x] Ledger's verdict recorded: **PASS** — independently recomputed every hash on the VPS, confirmed the `phase_state.json` annotation change is genuinely cosmetic.
- [x] PR #22 merged into `dev` (`4771d43`), then cherry-picked onto `main` via PR #24 (`5332ce1`) — kept separate from `dev`'s unrelated in-flight Weekly Strategy Report work, same pattern as PR #23.
- [x] Deploy confirmed on VPS, healthchecks.io Daily Fidelity Check red alert cleared and independently confirmed via the live Management API. Full write-up: [[2026-07-14-prophet-trader-deploy-fidelity-baseline-and-hygiene-fixes]].

## Updates

- 2026-07-12 10:05 (hawkeye) — created immediately after PR #13's deploy, converting Pierce's informal "I'll flag back to Hawkeye" commitment into a tracked task so it survives past this session even if nobody happens to think to ask.
- 2026-07-14 12:20 (hawkeye) — Jeff shared a healthchecks.io dashboard screenshot showing a live red-alert bell on this exact check. Dispatched Pierce to investigate rather than assume; confirmed the alert is real and explained (Monday's genuine FAIL 3/6, never cleared since no ping has landed since), not a false alarm. Jeff chose to wait for today's 09:30 ET run before updating the baseline, to get one more clean confirmation data point rather than race a deadline that's already unreachable. Due date pushed to 2026-07-15 accordingly.
- 2026-07-14 20:10 (pierce) — Today's 09:30 ET chained cron fire confirmed exactly as predicted (Routine PASS, Crontab/Config-hash FAIL for the known reason, nothing new). Two independent confirmations now exist, so updated `config/fidelity_baseline.json` to current live state — hashes captured via `scripts/daily_fidelity_check.py`'s own live-hashing functions run directly on the VPS, not hand-computed. Also found and fixed a related but separate stale annotation in `config/phase_state.json` (`momentum_breakout_stocks.preferred_regimes` still `["trending-bull"]`, should be `["trending-bull", "range-bound"]` per the 2026-07-08 PR #5 fix) — confirmed cosmetic-only (doesn't affect the fidelity-check hash or live gating) but bundled into the same PR since both are `config/*.json` edits under the same Ledger gate. Opened PR #22, CI green, explicitly held (not merged) pending Ledger. **Do not merge to main without Ledger's SOP-022 PASS — Ledger has stated he will not accept this on say-so.**
  - Note for whoever picks up the eventual deploy: `dev` currently also carries an unrelated in-flight commit (Weekly Strategy Report feature, separate concurrent session, see [[2026-07-14-prophet-trader-adr-weekly-strategy-report-build]]) not yet confirmed deploy-ready. When PR #22 is ready to ship, do not promote all of `dev` to `main` as a bundle — either wait for that work to also be ready, or cherry-pick PR #22's commit onto a `main`-based branch the same way `deploy/firecrawl-scrape-retry` (PR #23) was handled for the Firecrawl fix today.
  - Separately (not part of this task, no Ledger gate needed): investigated and fixed the Firecrawl scrape failure flagged in the same 09:30 ET analysis — recurring (not one-off) intermittent Firecrawl-side 500 on the Fed press-releases page, fixed with a retry-with-backoff in `FirecrawlClient.scrape()`. Deployed to production `main` @ `ff89a3b`. Full writeup: [[2026-07-14-prophet-trader-deploy-firecrawl-scrape-retry]].
- 2026-07-15 02:40 (pierce) — Ledger returned PASS on PR #22 (independently recomputed every hash on the VPS, confirmed the `phase_state.json` change is cosmetic). Merged PR #22 to `dev` (`4771d43`), cherry-picked onto `main` via PR #24 (`5332ce1`), same pattern as PR #23. Also picked up and shipped Ledger's two LOW findings from the same review (chmod bit commit + `.gitignore` gaps, no Ledger gate needed): PR #25→`dev` (`15fe6bc`), cherry-picked onto `main` via PR #26 (`40e9662`). **Mid-deploy incident:** PR #26's first Actions run failed — VPS working tree's uncommitted chmod drift collided with the incoming commit; fixed via SSH (discarded the local mode-only diff, re-pulled, converged on identical end state, re-ran the Action clean). Post-deploy: VPS confirmed at `40e9662`, working tree clean, script executable, both previously-untracked files now gitignored. Manually ran `daily_fidelity_check.py --date 2026-07-14` on the VPS — CLEAN (6/6), fired a `/success` ping; independently confirmed via the live healthchecks.io Management API (`status: up`, `last_ping` matching to the second). **Red alert cleared.** One item deliberately not resolved: `.env.bak-2026-07-11` gitignored but not deleted — flagged for Vex's judgment on credential retention rather than decided unilaterally. Full write-up: [[2026-07-14-prophet-trader-deploy-fidelity-baseline-and-hygiene-fixes]]. Task closed.

## Outcome

What shipped: PR #22 (fidelity baseline update, Ledger SOP-022 PASS) merged to `dev` and cherry-picked to `main` (`40e9662` final state after two follow-on PRs); healthchecks.io's Daily Fidelity Check red alert (open since Monday 2026-07-13) cleared and confirmed live via the Management API. Bundled in the same deploy pass: Ledger's two LOW findings from the PR #22 review — committed the `install/run_fidelity_check.sh` chmod +x bit, added `.env.bak*`/`data/fidelity_checks/` to `.gitignore`.

Where it lives: [[2026-07-14-prophet-trader-deploy-fidelity-baseline-and-hygiene-fixes]] (deploy confirmation, includes the mid-deploy incident and fix). VPS at commit `40e9662`. PRs [#22](https://github.com/JeffreyJD/prophet-trader/pull/22)/[#24](https://github.com/JeffreyJD/prophet-trader/pull/24)/[#25](https://github.com/JeffreyJD/prophet-trader/pull/25)/[#26](https://github.com/JeffreyJD/prophet-trader/pull/26).

Follow-ups: none opened by Pierce. One item flagged for Vex — `.env.bak-2026-07-11` retention judgment (not a task yet; routing via Hawkeye).

Lessons: committing a chmod bit that was previously live-only-uncommitted drift converts a silent risk into a loud, one-time, immediately-fixable deploy failure the moment the drift and the fix collide — confirmed live during this same deploy (PR #26's first Actions run failed exactly as Ledger's LOW finding predicted, fixed in minutes via SSH). Worth remembering next time uncommitted VPS drift is found: expect the eventual commit of that drift to trigger exactly this failure mode on deploy, not just in theory.

Archived deliverables:
  - `2026-07-14-prophet-trader-debug-fidelity-check-red-alert` → archived to `Deliverables/_archive/2026/07/2026-07-14-prophet-trader-debug-fidelity-check-red-alert.md`
  - `2026-07-14-prophet-trader-deploy-fidelity-baseline-and-hygiene-fixes` → archived to `Deliverables/_archive/2026/07/2026-07-14-prophet-trader-deploy-fidelity-baseline-and-hygiene-fixes.md`
  - `2026-07-11-prophet-trader-deploy-daily-fidelity-check` → archive deferred (still referenced by [[tsk-2026-07-11-001-automate-fidelity-non-clean-surfacing]])
