---
agent_id: hawkeye
session_id: 2026-07-06-photo-catalog-deploy-and-family-crm
timestamp: 2026-07-07T02:20:00Z
type: end-of-session
linked_sops: ["SOP-002-convert-mypka-to-sqlite"]
linked_workstreams: []
linked_guidelines: ["GL-001-file-naming-conventions", "GL-002-frontmatter-conventions"]
linked_tasks: ["tsk-2026-07-06-001-images-gl001-rename-pass"]
linked_journal_entries: []
---

# Session log — 2026-07-06 — GitHub CLI recovery, GL-001 rename pass, photo catalog Phase 1 deploy, family CRM build-out

## Context

The previous session died mid-way through GitHub CLI setup. Jeff came in to recover it; the session then executed the critical-path rename that unblocked the mypka-photos build, deployed the full photo catalog, and built out the family CRM with reference photos for AI face matching.

## What we did

- **Hawkeye** — recovered the dead session: guided `gh auth login` (HTTPS, JeffreyJD, keyring), pushed 7 backlogged commits including the orphaned 2026-07-06 Subaru session log. `gh` v2.96.0 fully operational end-to-end.
- **Margaret** — executed the one-time GL-001 rename pass on `PKM/Images/`: 215 of 226 images normalized to `YYYY-MM-DD-<slug>.<ext>` (102 dates from EXIF via exiftool, 12 from filename patterns, 101 folder-approximated and flagged), 32 files moved to their true `YYYY/MM` folder, stems deduplicated vault-wide for sidecar safety. Old→new mapping + CSV archived as the undo record (`Deliverables/_archive/2026/07/`). 11 live references updated in 4 docs; historical import records and rentals `reference-docs/` pointers deliberately untouched. Import open questions #44 and #52 resolved. Task [[tsk-2026-07-06-001-images-gl001-rename-pass]] created and closed same-session.
- **Margaret/Hawkeye** — pilot sidecar batch (2020/08, 23 images) staged in a scratch vault, validated against the GL-002 `photo_sidecar` schema, moved into the real vault; then full `mypka-photos scan`: **226/226 sidecars generated**, catalog verified.
- **Pierce** — fixed `date_taken` typing in mypka-photos (`datetime.date` → unquoted YAML date so Obsidian types the property as Date; `null` when EXIF absent). 34/34 tests pass incl. two new regression tests. Created private GitHub repo `JeffreyJD/mypka-photos` (main = scaffold, dev = fix), opened **PR #1** (dev→main).
- **Radar/Hawkeye** — family CRM build-out: 11 new/updated People entries (jeff, alex, olivia, alyssa, jack, amelia, ariana, calvin, ila, vaughn + bridget enriched), all wikilink-cross-referenced. Reference photos linked for jeff, ariana (anna), calvin, ila — with EXIF rotation baked upright and filenames normalized.
- **Margaret** — GL-002 People schema extended with `goes_by` (everyday vs legal name) and `maiden_name` (documented existing use); SOP-002 column mapping and person template updated in the same change (committed `c72218f`).
- **Hawkeye** — refreshed stale indexes: `PKM/Images/INDEX.md` (sidecar architecture + current state), `PKM/My Life/Projects/INDEX.md` (4 unlisted projects added), created [[mypka-photos]] project record.

## Decisions made

- **June-import "no-rename" rule reversed for PKM/Images.** Jeff approved; the photo catalog requires GL-001-conforming, stable filenames. The mapping deliverable preserves original names for traceability.
- **Slugs keep unique identifiers, not descriptions.** Descriptive titles live in the sidecar (`title`/`description`), because renaming an image after its sidecar exists orphans the sidecar. Filenames are now frozen.
- **Historical records stay historical.** Session logs and June import manifests keep old filenames; the archived mapping is the crosswalk. Only live documents got reference updates.
- **`full_name` = legal name; `goes_by` = everyday name** (Ariana/Anna, John/Jack, Jeffrey/Jeff). Schema change per GL-002 rule 6, mirrored into SOP-002.
- **`date_taken` emits as a true YAML date**, `null` when unknown — never a quoted string, never an empty string (avoids mixed-type Obsidian property).

## Insights

- **ripgrep silently honors `.gitignore` — and `PKM/` is gitignored.** A Grep-based vault sweep missed 5 live image embeds that a raw ignore-blind sweep caught. Any whole-vault search MUST bypass ignore rules (`grep -r`, `rg --no-ignore`, or Python walk). This nearly shipped a broken-embed rename pass.
- **Same-named files ≠ same files.** Rentals stubs' `digital_location` fields point at `reference-docs/` copies, not the `PKM/Images/` files with identical names. Bare-filename replacement would have corrupted valid pointers; only path-anchored references are safe to rewrite mechanically.
- **Pilot-in-a-scratch-vault pattern works.** `mypka-photos scan` has no batch flag; staging one month's images in a throwaway vault structure, validating, then moving the generated sidecars into the real vault gave a true pilot without new CLI features.
- **Reference photo quality gates AI face-ID.** Front-on + large-in-frame (Jeff, Anna) ≫ wide shot (Calvin) ≫ profile-looking-down (Ila). Also: EXIF orientation flags must be baked upright before matching.
- **PowerShell here-string syntax (`@'...'@`) leaks literal `@` lines when pasted into bash** — cost one amended commit. Pick the quoting idiom for the shell actually running.

## Realignments

- Jeff, verbatim: **"Moving forward do not ask me to do somehting that you can do. It is okay to ask me for approval, but you are my assistance and AI Team you are here to execute items for me. Do not pass the buck when you can execute."** Saved to persistent memory (`feedback_execute_dont_delegate_to_user.md`). Team-wide operating rule: execute with tools; reserve Jeff for approvals, physical-world actions, and judgment calls.

## Open threads

- **Jeff:** eyeball a sidecar in Obsidian (Properties render + image embed) — final pilot gate formality.
- **Jeff:** merge PR #1 (mypka-photos date_taken fix); take reference photos for Bridget, Alex, Olivia, Alyssa, Jack, Amelia + better Ila (front-facing) and Calvin (closer).
- **First AI identification pass** over 226 unconfirmed sidecars — can start with the current 4 anchors.
- **Vaughn Davis parentage** (Alex & Olivia inferred from surname) — one-word confirmation needed.
- Inherited from prior session: Subaru green-connector check + post-test-mode re-baseline; Pierce's obd-scanner CI task (tsk-2026-07-01-001) and logger findings; SSM2 K-Line cable.

## Next steps

1. Jeff: Obsidian visual check + PR #1 merge + reference photos.
2. Hawkeye/Margaret: run first AI face-ID pass when Jeff says go.
3. Rizzo: Subaru green-connector result interpretation (unchanged priority).

## Cross-links

- Prior session: [[2026-07-06-20-37_hawkeye_subaru-test-mode-discovery]]
- Task closed: [[tsk-2026-07-06-001-images-gl001-rename-pass]]
- Project: [[mypka-photos]]
