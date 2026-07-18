---
id: tsk-2026-07-18-012
title: "Decide whether SOP-002's SQLite mirror should cover Team Knowledge/ and Team/ contracts"
assignee: margaret
priority: 4
status: open
blocked_reason: awaiting Jeff's scope decision before any schema work starts
blocked_by: null
created: 2026-07-18T11:23:19Z
updated: 2026-07-18T11:23:19Z
due: null
created_by: hawkeye
source: margaret-mypka-to-sqlite-regen-2026-07-18
parent: null
linked_sops:
  - SOP-002-convert-mypka-to-sqlite
  - SOP-012-close-task
linked_workstreams:
  - WS-004-team-retro-and-self-improvement-loop
linked_guidelines:
  - GL-004-task-resource-linking
linked_my_life: []
linked_journal_entries: []
linked_session_logs:
  - 2026-07-18-14-30_margaret_mypka-to-sqlite-regen-post-ws-004-retro
linked_deliverables: []
tags: [margaret, sop-002, schema, scope-decision]
---

# Decide whether SOP-002's SQLite mirror should cover Team Knowledge/ and Team/ contracts

## What this is

Margaret's 2026-07-18 `mypka.db` regen (after the WS-007 ratification + WS-004 Tier 2 retro landed) surfaced a scope boundary, not a bug: SOP-002's schema has only ever covered the twelve `PKM/` entity folders plus a `content_index` of journal/document bodies. It has never had tables for `Team Knowledge/` (SOPs, Workstreams, Guidelines) or `Team/*/AGENTS.md` contracts. That means today's new files — `WS-007-infrastructure-change-lifecycle.md`, `GL-014-windows-shell-interop-gotchas.md`, `GL-015-credential-expansion-over-new-grants.md` — can't have their wikilinks resolved by the mirror, and never will unless the schema is deliberately extended. This is by design, not a parse failure.

This is a genuine scope decision for Jeff, not something to default into either direction: extending the schema adds real value (deterministic backlink queries across the whole framework, not just `PKM/`) but also real maintenance surface (a bigger schema, more to keep in sync on every regen).

## Context one click away

- Procedure: [[SOP-002-convert-mypka-to-sqlite]]
- Discovered during: [[2026-07-18-14-30_margaret_mypka-to-sqlite-regen-post-ws-004-retro]]
- Related governance: [[WS-004-team-retro-and-self-improvement-loop]] (this is the kind of framework-shape question that goes through Jeff, not an autonomous schema change)

## Success criteria

- Jeff decides: extend SOP-002's schema to cover `Team Knowledge/` and `Team/` contracts, or explicitly leave the mirror scoped to `PKM/` only
- If extending: Margaret amends SOP-002 and `mypka_to_sqlite.py` accordingly, then regenerates the mirror
- If not extending: this task closes noting the scope is intentional, so the question doesn't resurface as a "bug" in a future regen

## Updates

- 2026-07-18 11:23 (hawkeye) — created from Margaret's regen finding, per Jeff's approval to track it as a task. Blocked pending Jeff's scope call — this shouldn't proceed to schema work without that decision first.
