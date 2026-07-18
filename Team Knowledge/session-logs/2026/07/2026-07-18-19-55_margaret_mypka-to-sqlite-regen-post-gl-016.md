---
agent_id: margaret
session_id: mypka-to-sqlite-regen-post-gl-016
timestamp: 2026-07-18T19:55:00Z
type: end-of-session
linked_sops: ["SOP-002-convert-mypka-to-sqlite"]
linked_workstreams: ["WS-004-team-retro-and-self-improvement-loop"]
linked_guidelines: ["GL-016-numbered-artifact-collision-check", "GL-001-file-naming-conventions"]
---

# mypka.db regeneration after GL-016 + GL-001/SOP-010/WS-004/INDEX amendments

## Context

`tsk-2026-07-18-014-numbered-artifact-collision-rule` closed with a new
Guideline, [[GL-016-numbered-artifact-collision-check]], plus amendments to
[[GL-001-file-naming-conventions]], [[SOP-010-create-task]],
[[WS-004-team-retro-and-self-improvement-loop]], and three `INDEX.md` files
(Guidelines, SOPs, Workstreams) plus `Team Knowledge/INDEX.md`. Per WS-004
Tier 2 Step 6, the SQLite mirror gets regenerated after any approved
framework change lands. Potter flagged this as deferred on the task itself
(no path to dispatch Margaret directly); Hawkeye routed it to me directly
for this regen.

## What I did

- Reused the existing `mypka_to_sqlite.py` at the vault root (generated a
  few hours earlier per
  [[2026-07-18-14-30_margaret_mypka-to-sqlite-regen-post-ws-004-retro]]).
  Read the script in full first per Margaret's rule 3 ("run in a clean
  working directory... don't rewrite from scratch unless broken") - found
  no defects, no rewrite needed.
- Ran `python mypka_to_sqlite.py .` from the vault root. Drop-and-recreate
  strategy (the script's default), read-only on the markdown vault
  throughout.
- Compared row counts, parse-failure count, and unresolved-wikilink count
  against the prior regen's baseline.

## Result: clean run, zero errors

The script completed with no exceptions (aside from two harmless Python
3.12 `sqlite3` date-adapter `DeprecationWarning`s on `journal` inserts -
cosmetic, not a data issue, not new to this run). `mypka.db` and
`_mypka_to_sqlite_last_run.json` were both written to the vault root.

## Delta vs. the prior regen baseline

**No change in any figure.** Every row count, the parse-failure count, and
the unresolved-wikilink count are identical to the baseline recorded a few
hours earlier:

| Metric | Prior regen (14:30) | This regen (19:55) | Delta |
|---|---|---|---|
| Parse failures | 515 | 515 | 0 |
| Unresolved wikilinks | 3 | 3 | 0 |
| Duplicate document stems | 12 | 12 | 0 |
| `people` | 12 | 12 | 0 |
| `organizations` | 3 | 3 | 0 |
| `topics` | 8 | 8 | 0 |
| `projects` | 11 | 11 | 0 |
| `key_elements` | 5 | 5 | 0 |
| `goals` | 2 | 2 | 0 |
| `habits` | 1 | 1 | 0 |
| `documents` | 737 | 737 | 0 |
| `hosts` | 11 | 11 | 0 |
| `services` | 2 | 2 | 0 |
| `accounts` | 11 | 11 | 0 |
| `software` | 3 | 3 | 0 |
| `journal` | 3 | 3 | 0 |
| `journal_media` | 0 | 0 | 0 |
| `content_index` | 15 | 15 | 0 |

This is expected, not a red flag: SOP-002's schema only ever ingests the
twelve `PKM/` entity folders. It has no `guidelines`, `sops`, or
`workstreams` table and no wikilink-scanning pass over `Team Knowledge/`
bodies - a scope boundary already documented in the prior regen's report.
GL-016 and the GL-001/SOP-010/WS-004/INDEX amendments all live under
`Team Knowledge/`, entirely outside what this mirror tracks, so a
zero-delta result confirms the regen ran correctly against current vault
state rather than silently failing to pick up the change.

The 515 parse failures and 3 unresolved wikilinks are the same
pre-existing, already-triaged items from the last report (470 bulk-imported
rentals/woodworking documents predating frontmatter discipline, 9 seeded
My Life/Environment sample notes, 2 build-artifact `.esphome` files
excluded by design, one seeded `dr-schmidt` Person wikilink, and two
correctly-out-of-scope journal links to `GL-002-frontmatter-conventions`
and `INDEX`). No new parse failures, no new unresolved links introduced by
today's framework change.

## Decisions made

None - no schema or mapping questions came up this run. The prior regen's
Documents-recursive-walk / path-relative-slug decision and the
`.esphome`-exclusion decision both still apply unchanged.

## Open threads (carried over, unchanged)

- [ ] Confirm with Jeff/Bastion whether `PKM/Documents/pool/.esphome/`
      should be deleted from the vault (still present, still excluded).
- [ ] Consider a SOP-002 amendment documenting the Documents
      recursive-walk + path-relative-slug behavior as canonical.
- [ ] The 515-file frontmatter gap under `PKM/Documents/` remains a known,
      pre-existing backlog - not blocking.
- [ ] `dr-schmidt` wikilink in the seeded first-day journal entry still has
      no matching Person note - low priority, flag only.
- [ ] If SOPs/Workstreams/Guidelines/specialist contracts should ever be
      covered by the SQLite mirror, that is a SOP-002 schema-change
      proposal requiring explicit approval - not something to improvise.

## Next steps

- No action required for this regen - `mypka.db` is live and current as of
  2026-07-18T19:55Z, reflecting the vault state after GL-016 and its
  companion amendments landed (even though those file types are outside
  SOP-002's tracked-table scope).
- Next regen trigger: another approved WS-004 Tier 2 change landing.
