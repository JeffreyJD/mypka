---
agent_id: margaret
session_id: guns-folder-import-2026-06-28
timestamp: 2026-06-28T09:00:00Z
type: end-of-session
linked_sops: []
linked_workstreams: []
linked_guidelines:
  - GL-001-file-naming-conventions
  - GL-002-frontmatter-conventions
---

# Session Log — Guns/ Folder Import

## What I did

Imported `C:\Users\jeff\My Drive\Guns\` into `PKM/Documents/gunsmithing/`.

Source contained 4 files across 2 subfolders — all OneNote binary artifacts (2 `.one` section files, 2 `.onetoc2` notebook index files). No images, PDFs, or readable text.

Created `reference-docs/` under `gunsmithing/`. Moved all 4 source files to `reference-docs/` preserving original filenames. Created 4 markdown stubs with GL-002 Document frontmatter. Appended 2 open questions to the running import questions log.

## What I learned

**Filename collision from OneNote renames.** OneNote creates `.onetoc2` notebook index files with a hardcoded name ("Open Notebook.onetoc2"). When a user renames a notebook folder in Windows, OneNote can leave behind the stale folder with the same index filename. Both folders then contain identically-named `.onetoc2` files. Resolution without renaming: use a parent subfolder to preserve both at their original names.

**Typo-folder pattern.** The `Gun Informatiaon/` folder (typo) had the actual content; the `Gun Information/` folder (correct spelling) had only the orphaned index. The typo folder came first chronologically. This is a common artifact of Windows folder renaming while a OneNote notebook is open — the renamed folder gets a fresh `.onetoc2` but the old sections stay in the original folder.

## When this applies

Any import where the source is a Windows filesystem with OneNote notebooks. Check for `.onetoc2` filename collisions before moving. When two folders share a notebook-index filename, the older-dated folder is typically the one that still has the `.one` section files.

## When this does NOT apply

Sources that are not Windows OneNote exports. Sources where filenames were already normalized before handoff.

## Anomalies for Hawkeye

- Two open questions added: items #7 and #8 in `Deliverables/2026-06-27-import-open-questions.md`
- `Guns/` folder and its two empty subfolders remain on disk (not deleted per rules)
- Both `.one` files carry generic OneNote default names — content unknown until opened in OneNote
