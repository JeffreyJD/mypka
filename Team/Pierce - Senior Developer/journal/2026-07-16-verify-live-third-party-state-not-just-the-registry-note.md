---
agent_id: pierce
type: journal-entry
created: 2026-07-16T22:00:00Z
updated: 2026-07-16T22:00:00Z
topic: verify-live-third-party-state-not-just-the-registry-note
tags: ["healthchecks-io", "deploy-verification", "vps"]
linked_session_logs: []
linked_tasks: ["tsk-2026-07-13-001-weekly-strategy-report-cloud-routine-network-and-gitignore-blockers"]
related_journal_entries: ["2026-07-14-healthchecks-fail-ping-is-independent-of-schedule-timing"]
status: durable
---

# A myPKA Environment note documents state at write time, not now — re-query live before trusting it mid-deploy

## Context
Deploying the Weekly Strategy Report, the registry (`healthchecks-io.md`) said the check's grace was still 180 min and its slug still empty, both blocked on a read-only API key. A direct Management API query at deploy time showed both had actually been fixed (grace 5400s/90min, slug populated) — someone (Jeff, via the UI) had closed the gap since the registry was last written, and the file just hadn't caught up.

## What I learned
Environment registry files are a snapshot from whenever they were last edited, not a live view. For anything gated on a third-party UI/API where a human (not code) makes the change, always re-query the live API before writing a doc update or making a decision that depends on that state — never propagate a stale "still broken" note forward without checking. This cuts both ways: don't assume a documented blocker is still blocking, and don't assume a documented fix is still true either.

## When this applies
Any deploy or verification step that touches a third-party service (healthchecks.io, DNS, a SaaS dashboard) where the registry describes a state that a human could have changed out-of-band since the note was written — especially when the task instructions themselves assume a state ("correct the grace to 90 min") that may already be true.

## When this does NOT apply
State that only changes through code you control and just deployed (e.g., your own VPS crontab, your own git HEAD) — there the registry drift is your own to fix, not a live-query question, though verifying post-change is still correct practice.

## Evidence
- [[tsk-2026-07-13-001-weekly-strategy-report-cloud-routine-network-and-gitignore-blockers]]
- [[healthchecks-io]]
