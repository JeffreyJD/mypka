---
# Identity
id: tsk-2026-07-08-003
title: "Create healthchecks.io check for Weekly Strategy Report and send Hawkeye the ping URL"

# Ownership & priority
assignee: jeff
priority: 2

# Status (mirrors folder location)
status: open
blocked_reason: "no healthchecks.io API key on file — must be created via web dashboard"
blocked_by: null

# Time
created: 2026-07-08T00:00:00Z
updated: 2026-07-08T00:00:00Z
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

## Outcome

_(filled when status flips to done — see SOP-012-close-task)_
