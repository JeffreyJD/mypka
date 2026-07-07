---
# Identity
id: tsk-2026-07-06-001
title: "PKM/Images GL-001 rename pass — prerequisite for mypka-photos sidecar generation"

# Ownership & priority
assignee: margaret
priority: 1

# Status (mirrors folder location)
status: done
blocked_reason: null
blocked_by: null

# Time
created: 2026-07-06T00:00:00Z
updated: 2026-07-06T00:00:00Z
due: null

# Provenance
created_by: hawkeye
source: session
parent: null

# Cross-references — REQUIRED, even if empty array. Seven slots. The act of filling these is the whole point.
# See [[GL-004-task-resource-linking]] for the one-way rule (task→resource, never the reverse) and slug formats.
linked_sops: []
linked_workstreams: []
linked_guidelines: ["GL-001-file-naming-conventions", "GL-002-frontmatter-conventions"]
linked_my_life: []
linked_session_logs: []
linked_journal_entries: []
linked_deliverables: ["2026-07-06-images-gl001-rename-pass", "2026-07-06-images-gl001-rename-map", "2026-07-06-photo-catalog-architecture", "2026-07-06-photo-library-research"]

# Tagging
tags: ["photos", "gl-001", "mypka-photos", "migration"]
---

# PKM/Images GL-001 rename pass

## What this is

One-time slug normalization of every image in `PKM/Images/` to `YYYY-MM-DD-<slug>.<ext>`,
required by the mypka-photos photo catalog (architecture brief recommendation #4) because
sidecar files are named after their image — renames after sidecar generation orphan sidecars.

## Success criteria

- `mypka-photos rename` reports 0 non-conforming files
- Old→new mapping preserved as an undo record (PKM/ is gitignored — the mapping is the only history)
- All live vault references to renamed images updated; no broken embeds

## Updates

- 2026-07-06 (hawkeye/margaret) — created and executed in one session; Jeff approved full execution and reversal of the June-import "no-rename" rule.

## Outcome

215 of 226 images renamed (102 dates from EXIF, 12 parsed from filenames, 101 approximated
to folder month, flagged `APPROX-folder`). 32 files moved to their true `YYYY/MM` folder;
emptied folders removed. Stems unique vault-wide for sidecar safety. 11 live references
updated across 4 documents; historical import records intentionally untouched; rental stubs
point at `reference-docs/` copies and were correctly left alone. Import open questions #44
and #52 resolved. Post-check: `mypka-photos rename` → 0 non-conforming, safe to run `scan`.
Mapping record: [[2026-07-06-images-gl001-rename-pass]] (+ CSV), archived per GL-004.
