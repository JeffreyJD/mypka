---
agent_id: pierce
type: journal-entry
created: 2026-07-14T08:30:00Z
updated: 2026-07-14T08:30:00Z
topic: healthchecks-fail-ping-vs-schedule-staleness
tags: [healthchecks, monitoring, cron, debugging]
linked_session_logs: []
linked_tasks: []
related_journal_entries: []
status: durable
---

# A red healthchecks.io check can mean "explicit /fail ping received," not just "no ping arrived within schedule+grace" — check the last actual event before assuming it's a timing artifact

## Context

Jeff flagged a red "Daily Fidelity Check" on healthchecks.io while today's cron window hadn't even opened yet. First instinct was to check whether this was a display quirk of cron-based checks near their expected window. It wasn't — the check's own script hit healthchecks.io's `/fail` suffix URL after a real FAIL verdict the prior weekday, and that state persists until the next ping of any kind arrives.

## What I learned

healthchecks.io has two independent ways a check goes "down": (1) no ping arrives within schedule + grace (the timing-based path everyone assumes), and (2) an explicit ping to the `/fail` suffix, which flips the check red **immediately**, regardless of where you are in the schedule window. A check can show "last ping N hours ago" and be red for either reason — the timestamp alone doesn't tell you which. Any script instrumented with success/fail dual-endpoint pinging (a good pattern — SOP-022-style self-monitoring) will produce this second kind of red state, and it looks identical in the dashboard to a stale-schedule red state at a glance.

## When this applies

Any time a healthchecks.io check shows red/alerting and the instinct is "maybe this is just before the window closes" — don't stop at the schedule math. Pull the actual last run's log/output first. If the monitored script has fail-endpoint logic (`grep -n "'/fail'" <script>` or similar), a real FAIL verdict from the *previous* scheduled run is a far more likely explanation than a display artifact, especially if the last-ping timestamp lines up with the prior occurrence rather than "just now."

## When this does NOT apply

Simple period-type checks (not cron) with no fail-endpoint logic in the pinging script — those really can only go down via the schedule+grace staleness path, so the "is this just early" question is the right first question for those.

## Evidence

- [[2026-07-14-prophet-trader-debug-fidelity-check-red-alert]]
- `scripts/daily_fidelity_check.py` `_ping_healthcheck()` — `url = f"{base}/fail" if event == "fail" else base`
