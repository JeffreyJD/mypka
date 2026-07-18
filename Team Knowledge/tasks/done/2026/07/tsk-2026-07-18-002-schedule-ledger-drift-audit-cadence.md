---
id: tsk-2026-07-18-002
title: "Schedule a recurring cadence for Ledger's Environment Drift Audit"
assignee: ledger
priority: 2
status: done
blocked_reason: null
blocked_by: null
created: 2026-07-18T06:54:42Z
updated: 2026-07-18T10:56:37Z
due: null
created_by: hawkeye
source: ws-004-tier-2-team-retro
parent: null
linked_sops:
  - SOP-022-deployment-fidelity-verification
  - SOP-012-close-task
linked_workstreams:
  - WS-004-team-retro-and-self-improvement-loop
linked_guidelines: []
linked_my_life: []
linked_session_logs: []
linked_journal_entries: []
linked_deliverables:
  - 2026-07-18-team-retro-proposals
tags: [retro-proposal, ledger, drift-audit, approved]
---

# Schedule a recurring cadence for Ledger's Environment Drift Audit

## What this is

Retro Proposal 1 (approved by Jeff 2026-07-18). The Environment Drift Audit exists and works, but its cadence was flagged as unscheduled the day it was created (2026-07-10) and remains unscheduled today, eight days later. Add an explicit recurring-cadence trigger (minimum monthly) to Ledger's contract and/or SOP-022 — worded the way WS-004 already handles its own Tier 2 nudge (close-session MAY nudge on a rough cadence; on-demand remains the default, but the audit itself should fire on a real schedule, not only per-incident).

If WS-007 (Infrastructure Change Lifecycle) ratifies, its draft's Step 7 already names this same cadence — cross-reference rather than duplicate if that lands first (see [[tsk-2026-07-18-001-ratify-ws-007-infrastructure-change-lifecycle]], being handled in parallel by Potter).

## Context one click away

- Procedure: [[SOP-022-deployment-fidelity-verification]]
- Governing Workstream: [[WS-004-team-retro-and-self-improvement-loop]]
- Sibling task (may cross-reference the same cadence language): [[tsk-2026-07-18-001-ratify-ws-007-infrastructure-change-lifecycle]]
- Working artifacts:
  - [[2026-07-18-team-retro-proposals]]

## Success criteria

- Ledger's contract and/or SOP-022 states an explicit recurring cadence (minimum monthly) for the Environment Drift Audit, not just on-demand/per-incident
- If WS-007 ratifies first, this task's change wikilinks to WS-007's Step 7 rather than restating it (SSOT)
- Margaret regenerates the SQLite mirror after this lands, per WS-004 Tier 2 Step 6

## Updates

- 2026-07-18 06:54 (hawkeye) — created from approved retro proposal 1, assigned to Ledger.
- 2026-07-18 (ledger) — picked up alongside tsk-2026-07-18-003 (same target file). Added a "Recurring-cadence trigger (not just per-incident)" note under SOP-022 §3 (Environment Drift Audit): folds the monthly Drift Audit into the close-session routine as a mandatory **trigger**, not an optional nudge (unlike WS-004's own Tier 2 offer) — checks the date of the most recent `Deliverables/YYYY-MM-DD-environment-drift-audit.md` and fires the audit if 30+ days have elapsed or none exists ever. If Ledger can't run it that session (no host/VPS access), the routine records it as overdue/open rather than silently deferring. Also updated SOP-022's top-of-file "Triggered by" line to reference the mechanism. Logged in SOP-022's own Updates footer, wikilinked to this task. WS-007 (tsk-2026-07-18-001) ratified in parallel with the same cadence in its Step 7 — left as two independent statements for now rather than collapsing to one wikilink; worth Hawkeye/Potter revisiting for SSOT once both are settled, not urgent since neither contradicts the other.
- 2026-07-18 (hawkeye) — session hit a usage limit mid-task before Ledger could append this Updates line itself; verified the actual SOP-022 diff directly (not just trusting the agent's self-report, per this same task's own GL-007/retro-proposal-2 lesson) before writing it up. Substantive work confirmed complete and correct. Closing as done.

## Outcome

What shipped: SOP-022 now names an explicit, mandatory recurring cadence (minimum monthly) for the Environment Drift Audit — folded into the close-session routine as a trigger, not an optional nudge, checking the most recent `Deliverables/YYYY-MM-DD-environment-drift-audit.md` date and firing if 30+ days have elapsed or none exists.

Where it lives: `Team Knowledge/SOPs/SOP-022-deployment-fidelity-verification.md` §3; retro corroboration in [[2026-07-18-team-retro-proposals]].

Follow-ups: none. WS-007's own Step 7 independently names the same cadence — left as two separate statements for now (neither contradicts the other); worth a future SSOT pass to wikilink one to the other, not urgent.

Lessons: none new — reinforces the existing pattern that a fail-silent or never-scheduled mechanism can sit unaddressed for a long time even after being flagged (echoes GL-008/GL-007's own founding incidents).

Archived deliverables: `2026-07-18-team-retro-proposals` — archived in the consolidated pass (shared across tasks 001-010, all closing together).
