---
id: tsk-2026-07-18-014
title: "WS-004 Tier 1 proposal: prevent numbered-artifact collisions in parallel dispatch"
assignee: potter
priority: 2
status: open
blocked_reason: awaiting Jeff's choice between option (a) serialize vs (b) mandatory pre-commit collision check, per WS-004 Tier 1 step 3
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
  - WS-004-team-retro-and-self-improvement-loop
linked_guidelines:
  - GL-001-file-naming-conventions
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

- Jeff chooses (a), (b), a hybrid, or declines to formalize a rule at all
- If approved: Potter drafts the actual mechanism into the relevant SOP(s) (likely SOP-010/011/013 for tasks, plus wherever GL/SOP/WS numbering is documented) and the cross-session-learning note in `Team Knowledge/INDEX.md` is updated to point at the new rule instead of standing alone
- Margaret regenerates the SQLite mirror after any landed change, per WS-004 Tier 2 step 6

## Updates

- 2026-07-18 12:29 (hawkeye) — created from an outside audit's handoff. Awaiting Jeff's choice between (a) and (b) before Potter drafts anything.
