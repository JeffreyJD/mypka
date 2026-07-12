---
# Identity
id: tsk-2026-07-12-001
title: "Update fidelity baseline after first live Monday run, then dispatch Ledger's required SOP-022 follow-up recheck"

# Ownership & priority
assignee: pierce
priority: 2

# Status (mirrors folder location)
status: open
blocked_reason: "Waiting on Monday 2026-07-13's first live chained cron run (daily routine + fidelity check) — deliberately not done over the weekend since the cron doesn't fire until then."
blocked_by: null

# Time
created: 2026-07-12T10:05:31Z
updated: 2026-07-12T10:05:31Z
due: 2026-07-14

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
linked_deliverables: ["2026-07-11-prophet-trader-deploy-daily-fidelity-check"]

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

- [ ] Monday 2026-07-13's chained daily routine + fidelity check run confirmed to have actually fired (check VPS logs / the Telegram `[Fidelity Check]` message).
- [ ] Confirm the run's findings match the *expected* one-time drift (new cron line, `HEALTHCHECKS_API_KEY`/`HEALTHCHECKS_FIDELITY_URL` added) and nothing else unexpected.
- [ ] Pierce updates `config/fidelity_baseline.json` to the new correct state, as its own commit.
- [ ] Hawkeye dispatches Ledger for the required SOP-022 follow-up recheck on the baseline update — not accepted on Pierce's say-so.
- [ ] Ledger's verdict recorded (PASS/FAIL/UNVERIFIED) before this task closes.

## Updates

- 2026-07-12 10:05 (hawkeye) — created immediately after PR #13's deploy, converting Pierce's informal "I'll flag back to Hawkeye" commitment into a tracked task so it survives past this session even if nobody happens to think to ask.

## Outcome

_(filled when status flips to done — see SOP-012-close-task)_
