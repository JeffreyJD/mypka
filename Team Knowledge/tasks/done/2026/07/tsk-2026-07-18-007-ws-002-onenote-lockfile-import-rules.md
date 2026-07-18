---
id: tsk-2026-07-18-007
title: "Fold Margaret's recurring OneNote/lock-file import rules into WS-002"
assignee: margaret
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
linked_workstreams:
  - WS-002-import-external-knowledge-base
linked_guidelines: []
linked_my_life: []
linked_journal_entries:
  - Team/Margaret - Database Architect/journal/2026-06-01-import-source-patterns
linked_session_logs: []
linked_deliverables:
  - 2026-07-18-team-retro-proposals
tags: [retro-proposal, margaret, ws-002, approved]
---

# Fold Margaret's recurring OneNote/lock-file import rules into WS-002

## What this is

Retro Proposal 6 (approved by Jeff 2026-07-18). The same two rules were independently re-derived and documented across at least six separate bulk-import sessions (Master Notes, Guns, Auto, 3D Printing, Woodworking, ServErie, Construction/Landscaping, Rentals — 2026-06-27 through 2026-06-29): `.one`/`.onetoc2` files are binary/stub-only (no content extraction possible), and `~$`-prefixed Office lock files are always safe to discard without import. A slug-prefix collision-avoidance convention was also explicitly named reusable during that stretch.

Fold these three rules into WS-002 itself as documented sub-procedures, so the next import doesn't re-derive them from scratch.

## Context one click away

- Workstream being amended: [[WS-002-import-external-knowledge-base]]
- Prior evidence: [[Team/Margaret - Database Architect/journal/2026-06-01-import-source-patterns]]
- Working artifacts:
  - [[2026-07-18-team-retro-proposals]]

## Success criteria

- WS-002 documents: `.one`/`.onetoc2` handling (binary, stub-only), `~$` lock-file discard rule, slug-prefix collision-avoidance convention
- Margaret regenerates the SQLite mirror after this lands, per WS-004 Tier 2 Step 6

## Updates

- 2026-07-18 06:54 (hawkeye) — created from approved retro proposal 6, assigned to Margaret.
- 2026-07-18 07:40 (margaret) — picked up; loaded priors from [[2026-06-01-import-source-patterns]] (OneNote `.one`/`.onetoc2` binary/stub-only rule).
- 2026-07-18 07:40 (margaret) — added three rules to `WS-002-import-external-knowledge-base.md` § "Edge cases / known gotchas" (new bullets, immediately after the existing "Per-tool format drift" bullet, before "## Definition of done"): (1) OneNote `.one`/`.onetoc2` files are binary/stub-only — create a stub Document note pointing at the source file, flag for PDF/DOCX/HTML re-export; (2) Office `~$`-prefixed lock files are always safe to discard — excluded from inventory entirely, rollup count only; (3) slug-prefix collision-avoidance convention — prefix generated slugs with the source subfolder's slug (`<source-folder-slug>-<original-slug>.md`) proactively when one import spans multiple source subfolders landing in one destination folder, rather than relying on the Step 2 `-from-<source>` conflict-rename fallback. Did not touch the SQLite mirror regen (Hawkeye is running one consolidated regen after all retro tasks land) and did not run SOP-013 index rebuild or move this task to done/ (Hawkeye's consolidated close+reindex pass). Leaving task in `in-progress/` for Hawkeye.
- 2026-07-18 (hawkeye) — verified the WS-002 diff directly before closing — all three rules present, correctly placed. Closing as done.

## Outcome

What shipped: WS-002 documents three previously-tribal import rules: `.one`/`.onetoc2` binary/stub-only handling, `~$` lock-file discard, and the slug-prefix collision-avoidance convention.

Where it lives: `Team Knowledge/Workstreams/WS-002-import-external-knowledge-base.md` § Edge cases / known gotchas; retro corroboration in [[2026-07-18-team-retro-proposals]].

Follow-ups: none.

Lessons: the same two rules were independently re-derived across six separate import sessions before this — worth watching for the same shape (a rule re-derived more than twice) as a graduate-to-Workstream signal going forward.

Archived deliverables: `2026-07-18-team-retro-proposals` — archived in the consolidated pass (shared across tasks 001-010, all closing together).
