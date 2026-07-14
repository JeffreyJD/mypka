---
# Identity
id: tsk-2026-07-12-001
title: "Update fidelity baseline after first live Monday run, then dispatch Ledger's required SOP-022 follow-up recheck"

# Ownership & priority
assignee: pierce
priority: 2

# Status (mirrors folder location)
status: open
blocked_reason: "Waiting on today's (2026-07-14) 09:30 ET chained cron run to confirm the Routine sub-check now passes clean post-slug-fix before updating the baseline, per Jeff's explicit choice to get one more clean data point rather than race a deadline that's already unreachable."
blocked_by: null

# Time
created: 2026-07-12T10:05:31Z
updated: 2026-07-14T12:20:00Z
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
linked_deliverables: ["2026-07-11-prophet-trader-deploy-daily-fidelity-check", "2026-07-14-prophet-trader-debug-fidelity-check-red-alert"]

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
- [ ] Today's (2026-07-14) 09:30 ET run confirmed — Routine sub-check expected to pass clean (fix deployed), crontab/config-hash sub-checks expected to fail again for the same still-unresolved baseline-staleness reason.
- [ ] Pierce updates `config/fidelity_baseline.json` to the new correct state, as its own commit — **deliberately after** today's run, not before, per Jeff's explicit choice to get one more clean confirmation data point rather than race an already-unreachable deadline.
- [ ] Hawkeye dispatches Ledger for the required SOP-022 follow-up recheck on the baseline update — not accepted on Pierce's say-so.
- [ ] Ledger's verdict recorded (PASS/FAIL/UNVERIFIED) before this task closes.

## Updates

- 2026-07-12 10:05 (hawkeye) — created immediately after PR #13's deploy, converting Pierce's informal "I'll flag back to Hawkeye" commitment into a tracked task so it survives past this session even if nobody happens to think to ask.
- 2026-07-14 12:20 (hawkeye) — Jeff shared a healthchecks.io dashboard screenshot showing a live red-alert bell on this exact check. Dispatched Pierce to investigate rather than assume; confirmed the alert is real and explained (Monday's genuine FAIL 3/6, never cleared since no ping has landed since), not a false alarm. Jeff chose to wait for today's 09:30 ET run before updating the baseline, to get one more clean confirmation data point rather than race a deadline that's already unreachable. Due date pushed to 2026-07-15 accordingly.

## Outcome

_(filled when status flips to done — see SOP-012-close-task)_
