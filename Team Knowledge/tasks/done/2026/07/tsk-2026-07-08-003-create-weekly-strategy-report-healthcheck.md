---
# Identity
id: tsk-2026-07-08-003
title: "Create healthchecks.io check for Weekly Strategy Report and send Hawkeye the ping URL"

# Ownership & priority
assignee: jeff
priority: 2

# Status (mirrors folder location)
status: done
blocked_reason: null
blocked_by: null

# Time
created: 2026-07-08T00:00:00Z
updated: 2026-07-09T00:30:00Z
due: "2026-07-12"

# Provenance
created_by: hawkeye
source: session
parent: null

linked_sops: []
linked_workstreams: []
linked_guidelines: []
linked_my_life: []
linked_session_logs: []
linked_journal_entries: []
linked_deliverables: []

tags: ["prophet-trader", "monitoring", "healthchecks"]
---

# Create healthchecks.io check for Weekly Strategy Report

## What this is

The Daily Routine and Weekly Autopsy each have a dead-man's-switch check on healthchecks.io. The new [[prophet-trader-weekly-strategy-report]] cloud routine needs the third, matching check before it's fully monitored like the other two.

## Context one click away

- Service note: [[prophet-trader-weekly-strategy-report]]
- Account: [[healthchecks-io]]

## Success criteria

1. Check created on healthchecks.io: name `Prophet Trader - Weekly Strategy Report`, tag `trading`, schedule type **Cron**, expression `0 22 * * 0` (UTC), grace 180 minutes.
2. Ping URL sent to Hawkeye.
3. Hawkeye adds a final ping step to the routine's prompt (success on report/SKIPPED-note written, `/fail` if the routine crashes before writing anything) and updates the [[healthchecks-io]] account note with the new `env_var_names` entry / check record.

## Updates

- 2026-07-08 (hawkeye) — created. Due before the routine's first fire (2026-07-12) so monitoring is live from day one, though the routine will run either way.
- 2026-07-09 00:30 (hawkeye) — Jeff provided a healthchecks.io Project API key in-chat; created the check programmatically via the API instead of the originally-planned manual dashboard flow. Used `America/New_York` local-time Cron (`0 18 * * 0`) rather than UTC-converted, matching the other two checks' architecture exactly (also DST-safe, same reasoning as the VPS's own permanent timezone fix). Wired the ping into the routine's prompt as its final step on both branches (report written or SKIPPED note written), plus a `/fail` ping on unrecoverable error.

## Outcome

What shipped: third healthchecks.io check created (`Prophet Trader - Weekly Strategy Report`, Cron `0 18 * * 0` America/New_York, 180 min grace), routine updated to ping it, registry notes updated ([[healthchecks-io]], [[prophet-trader-weekly-strategy-report]]).

Where it lives: check UUID `1b204e49-283b-4d76-884e-abed551496e4` (ping URL embedded in the routine's own prompt config, not stored in any myPKA file). Routine `trig_01DSKrdhex2fBMkK8bA3q6a3` updated at 2026-07-09T00:27Z.

Follow-ups: none for this task specifically. The broader VPS→mypka data pipeline remains unbuilt (tracked in [[prophet-trader-weekly-strategy-report]]'s Open questions, no task opened yet — it depends on a git-credential-scope decision Jeff hasn't made).

Archived deliverables: none (linked_deliverables was empty).
