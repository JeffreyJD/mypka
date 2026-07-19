---
# Identity
id: tsk-YYYY-MM-DD-NNN
title: "Replace this with the task title"

# Ownership & priority
assignee: unassigned
priority: 3

# Status (mirrors folder location)
status: open
blocked_reason: null
blocked_by: null

# Time
created: YYYY-MM-DDTHH:MM:SSZ
updated: YYYY-MM-DDTHH:MM:SSZ
due: null

# Provenance
created_by: unassigned
source: manual
parent: null

# Cross-references — REQUIRED, even if empty array. Seven slots. The act of filling these is the whole point.
# See [[GL-004-task-resource-linking]] for the one-way rule (task→resource, never the reverse) and slug formats.
linked_sops: []
linked_workstreams: []
linked_guidelines: []
linked_my_life: []
linked_session_logs: []
linked_journal_entries: []
linked_deliverables: []

# Tagging
tags: []
---

# Replace this with the task title

## What this is
One paragraph: what's the work, what's the user-visible outcome, repro steps if it's a bug. Keep it tight — anyone resuming this should be able to read this section and know what they're picking up.

## Handoff
_(Optional — only when this task exists because work is being handed off mid-lifecycle across a session boundary. Delete this whole section if it doesn't apply. See [[GL-017-specialist-handoff-protocol]].)_
- **From / to:** <upstream specialist> → <downstream specialist>
- **Done:** <what the upstream specialist completed>
- **Decided:** <what is settled and should not be relitigated>
- **Open:** <what the downstream specialist must resolve>
- **Gate:** <design|review|security|test|fidelity> — PASS | FAIL | PASS-with-notes → <evidence pointer>
- **Read first:** <ordered pointers, mirrored in Context one click away>

## Context one click away
- Procedure: [[<SOP-name>]]
- Workstream: [[<workstream-name>]]
- Guideline: [[<guideline-name>]]
- My Life context: [[<my-life-entry-name>]]
- Birthed in: [[<session-log-name>]]
- Prior learning: [[<journal-entry-name>]]
- Working artifacts:
  - [[<deliverable-file-or-folder-name>]]

(Delete the bullets that don't apply. Keep what matters for resumption. The frontmatter `linked_*` arrays must be in sync with these. `Working artifacts:` is the body mirror of `linked_deliverables` — see [[GL-004-task-resource-linking]] for the slug format.)

## Success criteria
- A specific, observable outcome
- Another specific outcome

## Updates
- YYYY-MM-DD HH:MM (creator-name) — created

## Outcome
_(filled when status flips to done — see SOP-012-close-task)_
