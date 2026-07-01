---
# Identity
id: tsk-2026-05-10-001
title: "Welcome — read this and then close me"

# Ownership & priority
assignee: hawkeye
priority: 4

# Status
status: done
blocked_reason: null
blocked_by: null

# Time
created: 2026-05-10T12:00:00Z
updated: 2026-06-30T00:00:00Z
due: null

# Provenance
created_by: scaffold
source: scaffold-seed
parent: null

# Cross-references — three populated to show the pattern
linked_sops: [SOP-010-create-task, SOP-011-claim-task, SOP-012-close-task, SOP-013-rebuild-task-index]
linked_workstreams: []
linked_guidelines: [GL-001-file-naming-conventions, GL-004-task-resource-linking]
linked_my_life: []
linked_session_logs: []
linked_journal_entries: []
linked_deliverables: []

# Tagging
tags: [scaffold, onboarding]
---

# Welcome — read this and then close me

## What this is
This is a seed task included with the scaffold so you can see what a real task file looks like in this folder. It's intentionally trivial — you read it, you close it. The point is to show the shape: frontmatter with required cross-reference arrays, body with "Context one click away," updates, outcome.

## Context one click away
- Procedure for creating tasks: [[SOP-010-create-task]]
- Procedure for claiming this: [[SOP-011-claim-task]]
- Procedure for closing this: [[SOP-012-close-task]]
- Procedure for keeping the index fresh: [[SOP-013-rebuild-task-index]]
- Naming standards: [[GL-001-file-naming-conventions]]
- Linking rule: [[GL-004-task-resource-linking]]

## Success criteria
- You read this file and understand the resumption-point principle: a task is a place to pick up from, with all relevant context one wikilink away.
- You read [[SOP-010-create-task]] and [[SOP-012-close-task]] to see the lifecycle.
- You close this task via [[SOP-012-close-task]] (which moves it to `done/2026/05/` and writes an outcome).

## Notes for newcomers
- Task ids follow `tsk-YYYY-MM-DD-NNN`. NNN is a per-day counter.
- Filename is `<id>-<kebab-slug>.md`. The id is canonical; the slug is human-helpful.
- Cross-reference any task with a basename wikilink: `[[tsk-2026-05-09-001-mux-webhook-401]]`. Never include the path — folders change as tasks move.
- The seven `linked_*` arrays in frontmatter are required. Empty arrays are valid. The discipline of confronting "is there a relevant SOP / workstream / guideline / my-life-entry / session-log / journal-entry / deliverable?" at creation is the whole design. See [[GL-004-task-resource-linking]] for the one-way Task → Resource rule.
- The `INDEX.md` in this folder is auto-generated. Don't edit it by hand.

## Updates
- 2026-05-10 12:00 (scaffold) — created as scaffold seed task
- 2026-06-30 00:00 (hawkeye) — closed during June 2026 system health check. Linked SOP slugs updated from unnumbered to SOP-010–013.

## Outcome
Scaffold seed task reviewed and closed as part of the June 2026 system health check. No deliverables. Task lifecycle SOPs (SOP-010, SOP-011, SOP-012) authored in the same session; rebuild-task-index (SOP-013) remains to be authored.
