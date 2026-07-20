---
id: tsk-2026-07-19-003
title: "Resolve Potter's contract scope: hiring-only, or general framework-hygiene authoring too"

assignee: unassigned
priority: 2

status: open
blocked_reason: "awaiting Jeff's ruling on option (a) vs (b) below, per WS-004 Tier 1"
blocked_by: null

created: 2026-07-19T23:21:17Z
updated: 2026-07-19T23:21:17Z
due: null

created_by: hawkeye
source: team-inbox-handoff
parent: null

linked_sops:
  - SOP-001-how-to-add-a-new-specialist
  - SOP-010-create-task
linked_workstreams:
  - WS-004-team-retro-and-self-improvement-loop
linked_guidelines: []
linked_my_life: []
linked_session_logs:
  - 2026-07-19-21-23_hawkeye_crash-recovery-verification
linked_journal_entries: []
linked_deliverables:
  - 2026-07-19-ws-006-post-implementation-audit
tags: [contract-hygiene, potter, ws-004-tier-1, human-gated, scope-decision]
---

# Resolve Potter's contract scope: hiring-only, or general framework-hygiene authoring too

## What this is

During the WS-006 cycle, `Team/Potter - HR/AGENTS.md` was treated as covering general framework-hygiene document authoring — Potter drafted `[[GL-017-specialist-handoff-protocol]]`, `[[WS-006-software-change-lifecycle]]`, and the `[[GL-016-numbered-artifact-collision-check]]` implementation — all arguably outside a strict "hiring/SOP-001" reading of his contract (confirmed by direct read: Potter's contract opens "You handle hiring for the team... You own the process for adding new specialists," with no explicit mention of Guidelines/Workstreams authoring).

It worked in practice, but the boundary was never settled — a fresh Potter instance dispatched mid-cycle to apply a fix initially declined the work citing contract scope, and was routed around by reframing the dispatch rather than resolving the underlying question. This is a carried-over open thread from `tsk-2026-07-18-016`'s own close, restated by an external post-implementation audit — see [[2026-07-19-ws-006-post-implementation-audit]], Item 3.

## Why it matters

Left undefined, this recurs: the next new Guideline or Workstream raises the same "does this go to Potter?" routing question with no contract text to answer it. Better to settle it once than re-work-around it every time.

## Decision needed (Jeff rules — WS-004 Tier 1)

- **(a)** Explicitly widen Potter's contract to own framework-hygiene document authoring (Guidelines/Workstreams/SOPs), in addition to hiring.
- **(b)** Keep Potter strictly hiring-only, and name a different owner (or Hawkeye directly) for general framework authoring.

This is a real scope decision, not a wording fix — draft nothing further until Jeff picks (a) or (b).

## Context one click away

- Governing procedure for the decision: [[WS-004-team-retro-and-self-improvement-loop]]
- Contract under discussion: [[Team/Potter - HR/AGENTS]]
- Origin of this open thread: [[tsk-2026-07-18-016-ratify-handoff-protocol-and-ws-006]]
- Source of this task: [[2026-07-19-ws-006-post-implementation-audit]]
- Prior context: [[2026-07-19-02-05_hawkeye_ws-006-ratification-and-three-hires]]

## Success criteria

- Jeff rules (a) vs (b)
- If (a): `Team/Potter - HR/AGENTS.md` amended to explicitly scope in framework-hygiene document authoring
- If (b): a named owner (specialist or Hawkeye) is documented for framework-hygiene authoring, and Potter's contract is left as strictly hiring-scoped
- Either way, the ambiguity is closed with contract text, not a routing convention held only in session-log memory

## Updates
- 2026-07-19 23:21 (hawkeye) — created, blocked on Jeff's ruling. Surfaced by [[2026-07-19-ws-006-post-implementation-audit]] Item 3, restating an open thread from `tsk-2026-07-18-016`'s close. Not yet drafted as a formal proposal pending Jeff's directional pick between (a)/(b) — drafting the actual contract language is premature until the WHAT is chosen.
