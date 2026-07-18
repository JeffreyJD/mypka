---
id: tsk-2026-07-18-006
title: "Add a mandatory post-hire verification checklist to SOP-001"
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
  - SOP-001-how-to-add-a-new-specialist
  - SOP-012-close-task
linked_workstreams: []
linked_guidelines:
  - GL-009-localize-expansion-role-names
linked_my_life: []
linked_session_logs: []
linked_journal_entries: []
linked_deliverables:
  - 2026-07-18-team-retro-proposals
tags: [retro-proposal, potter, sop-001, approved]
---

# Add a mandatory post-hire verification checklist to SOP-001

## What this is

Retro Proposal 5 (approved by Jeff 2026-07-18). Three distinct hire-time defect classes were each caught only by a later audit, never at hire time: thin contracts (13 hires clustered around 2026-06-24, 26-54 lines, missing routing tables and scope boundaries), missing `journal/_template.md` folders (at least two separate hire batches), and UTF-8 BOM on shims silently making agents non-dispatchable with no visible error (13 shims, found 2026-07-01).

Add a closing checklist to SOP-001, run at hire time rather than discovered later: contract line-count floor (~80 lines), `journal/_template.md` present, shim file is UTF-8 no-BOM, no generic upstream/placeholder names left in either file (ties to GL-009).

## Context one click away

- Procedure being amended: [[SOP-001-how-to-add-a-new-specialist]]
- Related Guideline: [[GL-009-localize-expansion-role-names]]
- Working artifacts:
  - [[2026-07-18-team-retro-proposals]]

## Success criteria

- SOP-001 ends with an explicit hire-time checklist covering all four defect classes above
- The checklist is a hard gate on the hire being considered complete, not an optional note
- Margaret regenerates the SQLite mirror after this lands, per WS-004 Tier 2 Step 6

## Updates

- 2026-07-18 06:54 (hawkeye) — created from approved retro proposal 5, assigned to Potter.
- 2026-07-18 07:30 (potter) — picked up; loaded priors by reading GL-009 and the full current SOP-001. Added a new "## Post-hire verification checklist (mandatory)" section to `Team Knowledge/SOPs/SOP-001-how-to-add-a-new-specialist.md`, placed between Step 7 and "Common mistakes to avoid," explicitly framed as a hard gate run before Step 8 (showing the user the draft), not an optional note. Covers all four defect classes named in this task: contract line-count floor (~80 lines), `journal/_template.md` present, shim UTF-8-no-BOM, and no generic upstream/placeholder names left in either file (tied to [[GL-009-localize-expansion-role-names]] via wikilink, not restated). Also added GL-009 to SOP-001's top-of-file References line since the checklist now depends on it.
- 2026-07-18 (hawkeye) — verified the actual SOP-001 diff directly before closing — correctly placed as a hard gate, all four defect classes covered. Closing as done.

## Outcome

What shipped: SOP-001 gained a mandatory "Post-hire verification checklist" run before Step 8, covering contract line-count floor, `journal/_template.md` presence, shim UTF-8-no-BOM, and no leftover generic placeholder names.

Where it lives: `Team Knowledge/SOPs/SOP-001-how-to-add-a-new-specialist.md`; retro corroboration in [[2026-07-18-team-retro-proposals]].

Follow-ups: none.

Lessons: three independent hire-time defect classes were each caught only by a later audit in the past — this closes the loop so the next hire catches them at creation instead.

Archived deliverables: `2026-07-18-team-retro-proposals` — archived in the consolidated pass (shared across tasks 001-010, all closing together).
