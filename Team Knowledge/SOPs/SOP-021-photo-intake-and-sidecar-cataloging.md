---
sop_id: SOP-021
title: Photo Intake and Sidecar Cataloging
default_owner: margaret
status: active
version: 1.0
created: 2026-07-06
updated: 2026-07-06
tags:
  - photos
  - images
  - sidecar
  - gl-001
  - gl-002
---

# SOP-021 — Photo Intake and Sidecar Cataloging

**Default owner:** Margaret
**Reusable by any agent** — this SOP is a skill, not exclusive to Margaret. Radar runs it for Journal/Team Inbox images.

Covers taking any new image from arrival (Team Inbox, direct drop, or import) to a fully cataloged state: GL-001-conforming filename, correct `YYYY/MM` placement, and a schema-compliant `photo_sidecar`. The architecture is sidecar-primary: the sidecar `.md` is the SSOT for all per-image metadata. Schema: [[GL-002-frontmatter-conventions]] § photo_sidecar. Project: [[mypka-photos]].

---

## Guardrails (read before every run)

1. **Never rename an image that already has a sidecar** — the sidecar becomes an orphan. If a rename is unavoidable, rename image and sidecar together in one operation and update any embeds.
2. **Stems must be unique vault-wide across extensions.** `photo.jpg` and `photo.heic` would fight over one sidecar (`photo.md`); suffix the format (`photo-heic.heic`) or a counter.
3. **Reference-impact sweeps follow [[GL-006-vault-search-ignore-rules]]** — `PKM/` is gitignored; default ripgrep sweeps miss it silently.
4. **Bake EXIF orientation upright** before any AI face-matching use (`PIL ImageOps.exif_transpose` or exiftool). Sideways pixels degrade detection.
5. **Descriptive naming lives in the sidecar, not the filename.** Filenames keep a stable unique identifier; `description`/`event` fields carry the meaning. Filenames are frozen after sidecar creation (guardrail 1).

## Procedure

### 1. Name and place the image

- Target: `PKM/Images/YYYY/MM/YYYY-MM-DD-<slug>.<ext>` per [[GL-001-file-naming-conventions]] — lowercase kebab-case, lowercase extension.
- Date priority: **EXIF capture date** > date parsed from the original filename > context (journal entry date, Jeff's statement) > folder month with day `01` (note the approximation in the sidecar body).
- `YYYY/MM` folder matches the date prefix. Create folders as needed.
- Multiple same-day, same-source images: append `-1`, `-2`, ….

**Reference photos are different:** identity anchors go to `PKM/Images/_references/<person-slug>-reference-YYYY.jpg` (no date folder, no sidecar) per `_references/README.md`, and get embedded in the person's CRM file under `## Reference photo`.

### 2. Verify naming (dry-run gate)

Run the checker — it never modifies anything:

```
mypka-photos rename "C:\Users\jeff\My Drive\myPKA"
```

Expected: `Non-conforming (action needed): 0`. Fix any flagged names before proceeding.

### 3. Generate the sidecar

```
mypka-photos scan "C:\Users\jeff\My Drive\myPKA"
```

`scan` skips images that already have sidecars, so it is safe to run vault-wide after adding any number of images. Verify with:

```
mypka-photos catalog "C:\Users\jeff\My Drive\myPKA"
```

### 4. Fill metadata (what makes the catalog useful)

Edit the new sidecar's frontmatter per the GL-002 schema:

- `people` — wikilinks (`"[[calvin-wolfe]]"`), the documented rule-4 exception. This is what powers "all photos of this person" via backlinks.
- `photo_type` — controlled vocabulary: `family | property | equipment | document | landscape | event`.
- `event`, `location`, `description` — free text.
- `date_taken` — unquoted YAML date; correct it here if step 1 approximated.

### 5. Respect the confirmation state machine

- Agent-suggested people tags: set `ai_pending: true` + `ai_confidence: high|medium|low`, leave `confirmed: false`.
- Only Jeff's review flips `confirmed: true` (and resets `ai_pending: false`, `ai_confidence: null`).
- Never set `ai_pending: true` and `confirmed: true` together.

## Tool-agnostic execution note

The `mypka-photos` CLI (steps 2–3) requires shell access (Claude Code: `Bash` tool). An LLM without shell access performs the equivalent manually: verify the filename against the GL-001 pattern by inspection, and create the sidecar by copying the `photo_sidecar` schema block from [[GL-002-frontmatter-conventions]] — same stem as the image, same folder, body containing only the `![[Images/YYYY/MM/<filename>]]` embed. The CLI is a convenience, not the contract; the schema is the contract.

## Cross-links

- [[GL-001-file-naming-conventions]] — filename pattern
- [[GL-002-frontmatter-conventions]] — photo_sidecar schema + state machine
- [[GL-006-vault-search-ignore-rules]] — sweep safety
- [[mypka-photos]] — project record, phase roadmap
