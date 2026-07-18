---
id: tsk-2026-07-18-008
title: "Fix root AGENTS.md's stale, duplicate specialist table"
assignee: potter
priority: 3
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
  - SOP-012-close-task
linked_workstreams: []
linked_guidelines: []
linked_my_life: []
linked_session_logs:
  - 2026-07-14-23-30_hawkeye_pool-monitor-phase0-flash-ha-sandbox-bastion-hire
linked_journal_entries: []
linked_deliverables:
  - 2026-07-18-team-retro-proposals
tags: [retro-proposal, potter, agents-md, approved, protected-file]
---

# Fix root AGENTS.md's stale, duplicate specialist table

## What this is

Retro Proposal 7 (approved by Jeff 2026-07-18). Root `AGENTS.md` carries its own specialist table that duplicates `Team/agent-index.md` and has drifted — missing Ledger, Relay, and Trapper as of the last Librarian pass that found it (2026-07-14). It was flagged but explicitly not fixed at the time because `AGENTS.md` is a protected file requiring approval. Jeff has now approved the fix via this retro review.

Replace the restated table in root `AGENTS.md` with a pointer to `[[Team/agent-index]]` as the single source, per the SSOT Golden Rule the file itself states.

## Context one click away

- File being amended: root `AGENTS.md` (protected)
- Single source of truth: [[Team/agent-index]]
- Evidence session: [[2026-07-14-23-30_hawkeye_pool-monitor-phase0-flash-ha-sandbox-bastion-hire]]
- Working artifacts:
  - [[2026-07-18-team-retro-proposals]]

## Success criteria

- Root `AGENTS.md`'s specialist table section is replaced with a `[[Team/agent-index]]` pointer, or explicitly deleted in favor of the link — no restated roster
- No other content in `AGENTS.md` is touched beyond this section (protected-file discipline)
- Margaret regenerates the SQLite mirror after this lands, per WS-004 Tier 2 Step 6

## Updates

- 2026-07-18 06:54 (hawkeye) — created from approved retro proposal 7, assigned to Potter. Jeff has explicitly approved editing this protected file for this specific change.
- 2026-07-18 07:30 (potter) — replaced the restated 14-row specialist table in root `AGENTS.md` with a single-paragraph pointer to `[[Team/agent-index]]`, framed explicitly as the SSOT reason ("a duplicated table in this file has drifted out of sync with reality before... exactly the kind of SSOT violation the Golden Rule below exists to prevent"). Confirmed nothing else in the file was touched — scoped to the one section per the protected-file discipline.
- 2026-07-18 (hawkeye) — session hit a usage limit right as Potter was completing this, the last of four parallel tasks (see tsk-2026-07-18-001, -004, -006 for the other three, all of which got their own Updates lines before the cutoff). Verified the actual `AGENTS.md` diff directly before writing this line — confirmed done and correctly scoped. Closing as done.

## Outcome

What shipped: root `AGENTS.md`'s stale, drifted 14-row specialist table replaced with a single-paragraph pointer to `[[Team/agent-index]]` as the SSOT, explicitly naming the drift-then-discovered pattern as the reason.

Where it lives: root `AGENTS.md`; retro corroboration in [[2026-07-18-team-retro-proposals]].

Follow-ups: none.

Lessons: this SSOT violation sat known-but-unfixed for four days because the file is normally protected — worth remembering that "protected" and "cannot be fixed once explicitly approved" are different things.

Archived deliverables: `2026-07-18-team-retro-proposals` — archived in the consolidated pass (shared across tasks 001-010, all closing together).
