---
id: tsk-2026-07-18-015
title: "WS-007 Step 7: point the Drift Audit cadence at SOP-022 §3 instead of restating it"
assignee: potter
priority: 4
status: open
blocked_reason: awaiting Jeff's approval (WS-007 is a ratified Workstream) — trivial, batchable into next retro, no urgency
blocked_by: null
created: 2026-07-18T12:29:33Z
updated: 2026-07-18T12:29:33Z
due: null
created_by: hawkeye
source: outside-audit-handoff-2026-07-18
parent: null
linked_sops:
  - SOP-010-create-task
  - SOP-012-close-task
linked_workstreams:
  - WS-007-infrastructure-change-lifecycle
linked_guidelines:
  - GL-001-file-naming-conventions
linked_my_life: []
linked_journal_entries: []
linked_session_logs: []
linked_deliverables:
  - 2026-07-18-ws-007-post-ratification-audit
tags: [ws-007, ssot, framework-hygiene, low-priority, ws-004-tier-1]
---

# WS-007 Step 7: point the Drift Audit cadence at SOP-022 §3 instead of restating it

## What this is

An outside audit ([[2026-07-18-ws-007-post-ratification-audit]], Item 3) flagged a minor SSOT seam: the Drift Audit cadence ("minimum monthly") is stated as a value in two ratified files — `SOP-022` §3 (which owns the mechanism) and `WS-007-infrastructure-change-lifecycle` Step 7's conditional table (which restates the value rather than pointing at §3 as source). `tsk-2026-07-18-002`'s own outcome already flagged this and correctly deferred it as non-urgent — this task exists so the deferred item doesn't disappear entirely.

## Context one click away

- File to amend: [[WS-007-infrastructure-change-lifecycle]] Step 7
- Source of truth: `Team Knowledge/SOPs/SOP-022-deployment-fidelity-verification.md` §3
- Flagged by: [[2026-07-18-ws-007-post-ratification-audit]] (Item 3); originally noted in [[tsk-2026-07-18-002-schedule-ledger-drift-audit-cadence]]'s outcome

## Success criteria

- WS-007 Step 7's "minimum monthly" table cell changed to reference SOP-022 §3 as the cadence source (e.g. "per SOP-022 §3's cadence trigger") rather than restating the value

## Updates

- 2026-07-18 12:29 (hawkeye) — created from an outside audit's handoff. Low priority, batchable — no need to action ahead of other work.
