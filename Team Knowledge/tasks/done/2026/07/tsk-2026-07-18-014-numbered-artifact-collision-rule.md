---
id: tsk-2026-07-18-014
title: "WS-004 Tier 1 proposal: prevent numbered-artifact collisions in parallel dispatch"
assignee: potter
priority: 2
status: done
blocked_reason: null
blocked_by: null
created: 2026-07-18T12:29:33Z
updated: 2026-07-18T19:45:52Z
due: null
created_by: hawkeye
source: outside-audit-handoff-2026-07-18
parent: null
linked_sops:
  - SOP-010-create-task
  - SOP-012-close-task
linked_workstreams:
  - WS-004-team-retro-and-self-improvement-loop
linked_guidelines:
  - GL-001-file-naming-conventions
  - GL-016-numbered-artifact-collision-check
linked_my_life: []
linked_journal_entries: []
linked_session_logs:
  - 2026-07-18-11-27_hawkeye_ws-007-intake-and-tier2-team-retro
linked_deliverables:
  - 2026-07-18-ws-007-post-ratification-audit
tags: [workstream, proposal, ws-004-tier-1, human-gated, framework-hygiene]
---

# WS-004 Tier 1 proposal: prevent numbered-artifact collisions in parallel dispatch

## What this is

A WS-004 **Tier 1 proposal**. During the 2026-07-18 retro's parallel dispatch, Bastion and Vex were each independently assigned a new Guideline to write. Both correctly listed `Team Knowledge/Guidelines/` and both correctly saw GL-014 as the next free number — and both wrote a different Guideline to `GL-014-*.md` before either agent's session closed. Hawkeye caught it only by reviewing each agent's actual file diff before the final close pass, and renumbered the second file to GL-015. Recorded as a cross-session learning in `Team Knowledge/INDEX.md`, but not yet promoted to a hard rule.

An outside audit ([[2026-07-18-ws-007-post-ratification-audit]], Item 2) flagged this as the one live, systemic finding from the whole retro cycle: any future parallel dispatch that creates sequentially-numbered artifacts (`GL-NNN`, `SOP-NNN`, `WS-NNN`, `tsk-NNN`) hits the same race, and next time it may not be caught before commit.

## The choice for Jeff

Two candidate fixes, genuine tradeoff between throughput and safety — this proposal does not recommend one over the other:

- **(a) Serialize numbered-artifact creation.** When a parallel dispatch will mint numbered artifacts, one agent reserves the numbers up front, or numbering happens in a single pass at the end rather than during parallel work. Removes the race entirely; costs some dispatch parallelism whenever numbered artifacts are in scope.
- **(b) Mandatory pre-commit collision check.** Each agent re-confirms its number is still free immediately before writing, and a required final check runs across the whole batch before any commit — formalizing what actually caught this collision (which happened by Hawkeye's review discipline, not by a required step). Keeps full parallelism; relies on the check always running.

## Context one click away

- Governing procedure: [[WS-004-team-retro-and-self-improvement-loop]] — Tier 1 proposal, human-gated
- Naming convention: [[GL-001-file-naming-conventions]]
- Cross-session learning already recorded: `Team Knowledge/INDEX.md` § Cross-session learnings, 2026-07-18 entry
- Origin session: [[2026-07-18-11-27_hawkeye_ws-007-intake-and-tier2-team-retro]]
- Flagged by: [[2026-07-18-ws-007-post-ratification-audit]] (Item 2)

## Success criteria

- Jeff chooses (a), (b), a hybrid, or declines to formalize a rule at all — MET: chose (b)
- If approved: Potter drafts the actual mechanism into the relevant SOP(s) (likely SOP-010/011/013 for tasks, plus wherever GL/SOP/WS numbering is documented) and the cross-session-learning note in `Team Knowledge/INDEX.md` is updated to point at the new rule instead of standing alone — MET: see Outcome
- Margaret regenerates the SQLite mirror after any landed change, per WS-004 Tier 2 step 6 — DEFERRED: Potter has no path to dispatch Margaret from this task; flagged to Hawkeye to route before session close

## Updates

- 2026-07-18 12:29 (hawkeye) — created from an outside audit's handoff. Awaiting Jeff's choice between (a) and (b) before Potter drafts anything.
- 2026-07-18 (jeff) — chose **(b) mandatory pre-commit collision check** over serializing numbered-artifact creation. WHAT approved per WS-004 Tier 1 step 3 — Potter clear to draft.
- 2026-07-18 19:42 (potter) — picked up, drafting the mechanism. Read [[GL-001-file-naming-conventions]] rule 6, [[SOP-010-create-task]] §2, and the Guidelines/SOPs/Workstreams INDEX.md "how to add" sections to find the current homes for numbering discipline before deciding shape (one shared Guideline vs per-location amendments).
- 2026-07-18 19:45 (potter) — done: wrote [[GL-016-numbered-artifact-collision-check]] as the single shared home for the two-check rule (re-confirm immediately before write; required batch check across the whole set before any commit), wikilinked from [[GL-001-file-naming-conventions]] §6, [[SOP-010-create-task]] §2, the "how to add" sections of the Guidelines/SOPs/Workstreams `INDEX.md` files, and [[WS-004-team-retro-and-self-improvement-loop]] Tier 2 Step 5. Updated the 2026-07-18 "Parallel dispatch" cross-session-learning entry in `Team Knowledge/INDEX.md` to point at the resolution instead of standing alone as an open question.

## Outcome

What shipped: a new Guideline, [[GL-016-numbered-artifact-collision-check]], formalizing Jeff's approved option (b) — mandatory pre-commit collision check over serializing numbered-artifact creation. The Guideline states two required checks: (1) re-confirm the candidate number is still free immediately before writing the file, not just once at the start of work — already mechanized for tasks via [[SOP-010-create-task]] §2's retry-on-exists loop, now applied by hand for GL/SOP/WS numbering too; (2) a required batch-wide check across every new numbered artifact in a commit, run by whoever performs that commit, before it lands — this is the piece that was missing on 2026-07-18 and that formalizes what Hawkeye's manual diff review happened to catch. One shared Guideline was chosen over four separate amendments (per SSOT) because the same two-check procedure applies identically to `GL-NNN`, `SOP-NNN`, `WS-NNN`, and `tsk-NNN` — only the "where do I look for the current index" detail differs per artifact type, and that's covered inside the Guideline's own text rather than duplicated.

Where it lives:
- New Guideline: [[GL-016-numbered-artifact-collision-check]]
- Amended: [[GL-001-file-naming-conventions]] §6 (numbering rule now points to the check)
- Amended: `Team Knowledge/Guidelines/INDEX.md` (new GL-016 row; "Reserved" note updated to point at the Guideline instead of standing as an unresolved observation)
- Amended: `Team Knowledge/SOPs/INDEX.md` ("How to add a new SOP" step 1; SOP-010's own row)
- Amended: `Team Knowledge/Workstreams/INDEX.md` ("When to write a new Workstream" section)
- Amended: [[SOP-010-create-task]] §2 and its header References line
- Amended: [[WS-004-team-retro-and-self-improvement-loop]] Tier 2 Step 5 and its header References line — this is where parallel implementers land approved changes, the exact situation that produced the 2026-07-18 collision
- Amended: `Team Knowledge/INDEX.md` — the 2026-07-18 "Parallel dispatch" cross-session-learning entry now points at [[GL-016-numbered-artifact-collision-check]] as the resolution instead of standing alone as an open question

Follow-ups: Margaret's SQLite mirror regen (per WS-004 Tier 2 Step 6) has not been run — Potter has no path to dispatch Margaret directly from this task. Flagged to Hawkeye to route before session close.

Lessons: none written as a separate journal entry — the durable lesson is the Guideline itself (per [[SOP-016-write-journal-entry]]'s own guidance: a rule that applies team-wide and permanently is a Guideline, not a journal note).

Archived deliverables: `2026-07-18-ws-007-post-ratification-audit` — archive deferred. Still referenced by two open tasks, [[tsk-2026-07-18-013-west-9th-tenant-identity-ambiguities]] and [[tsk-2026-07-18-015-ws-007-cadence-ssot-phrasing]]. Stays in `Deliverables/` until the last referencing task closes.
