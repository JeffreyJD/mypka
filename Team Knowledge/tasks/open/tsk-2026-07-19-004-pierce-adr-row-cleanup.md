---
id: tsk-2026-07-19-004
title: "Remove/reword the stale ADR row in Pierce's deliverable-structure table"

assignee: potter
priority: 4

status: open
blocked_reason: null
blocked_by: null

created: 2026-07-19T23:21:17Z
updated: 2026-07-19T23:21:17Z
due: null

created_by: hawkeye
source: team-inbox-handoff
parent: null

linked_sops:
  - SOP-010-create-task
linked_workstreams:
  - WS-006-software-change-lifecycle
linked_guidelines: []
linked_my_life: []
linked_session_logs:
  - 2026-07-19-21-23_hawkeye_crash-recovery-verification
linked_journal_entries: []
linked_deliverables:
  - 2026-07-19-ws-006-post-implementation-audit
tags: [contract-hygiene, pierce, cosmetic, batch-whenever, low-priority]
---

# Remove/reword the stale ADR row in Pierce's deliverable-structure table

## What this is

The `tsk-2026-07-19-001` amendment to `Team/Pierce - Senior Developer/AGENTS.md` correctly removed architecture-decision ownership from Pierce's routing and fixed Method step 2 to wait for Keystone's ADR instead of self-authoring one. But Pierce's `## Deliverable structure` table (line 95, confirmed by direct read) still lists a row:

> `| Architecture decision record | docs/design/ADR-NNN.md | Before any structural code or deploy change |`

— as a deliverable *Pierce* produces. Architecture is now Keystone's; Pierce shouldn't produce ADRs at all. Surfaced by an external post-implementation audit — see [[2026-07-19-ws-006-post-implementation-audit]], Item 1.

## Why it matters

Cosmetic, not behavioral — Method step 2 already routes correctly, so Pierce won't actually self-author an ADR in practice. But on a literal read, the deliverable table contradicts the carve-out. A future reader (or a schema/consistency pass) could take the table at face value.

## Suggested action

Remove the ADR row from Pierce's deliverable table, or reword it to "reads Keystone's ADR (produced per WS-006 Step 2)." One line. **No urgency** — batch this with any other Pierce-contract touch rather than running it standalone.

## Context one click away

- Contract to amend: [[Team/Pierce - Senior Developer/AGENTS]]
- Workstream context: [[WS-006-software-change-lifecycle]]
- Origin: [[tsk-2026-07-19-001-hire-architect-reviewer-test-engineer]] (the amendment that created this inconsistency as a side effect)
- Source of this task: [[2026-07-19-ws-006-post-implementation-audit]]

## Success criteria

- Pierce's `## Deliverable structure` table no longer lists an ADR row he produces
- Either the row is removed, or reworded to reflect that Pierce reads (not produces) the ADR

## Updates
- 2026-07-19 23:21 (hawkeye) — created, low priority, deliberately not dispatched standalone. Surfaced by [[2026-07-19-ws-006-post-implementation-audit]] Item 1. Bundle whenever Pierce's contract is next touched for another reason.
