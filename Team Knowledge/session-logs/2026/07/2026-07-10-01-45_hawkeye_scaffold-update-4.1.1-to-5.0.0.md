---
agent_id: hawkeye
session_id: 2026-07-09-scaffold-update-4.1.1-to-5.0.0
timestamp: 2026-07-10T01:45:50Z
type: end-of-session
linked_sops: []
linked_workstreams: []
linked_guidelines: []
linked_tasks: []
linked_journal_entries: []
---

# Session log — 2026-07-09 — myPKA scaffold updated 4.1.1 → 5.0.0, with manual personalization re-merge

## Context

Jeff asked how the scaffold update process works, then said "update mypka." The boot-time version check (`scripts/check-version.py`) had never once fired — traced this to a dead URL in `manifest.json` (`update_check.remote_version_url` pointed at `myICOR/mypka-scaffold`, a repo that returns 404), found the real canonical repo (`myICOR/myPKA`) in `CHANGELOG.md`'s own history, and discovered a real pending update: 5.0.0, marked `breaking: true`.

## What we did

- **Hawkeye** — downloaded the official 5.0.0 release bundle from GitHub, ran the real dry-run via `scripts/update-scaffold.py` against Jeff's actual vault (not just eyeballing the changelog). Plan: 10 changed files, 0 new, 0 of Jeff's own content touched.
- **Hawkeye** — before applying, diffed each of the 10 flagged files individually rather than trusting the tool's "0 of your files touched" framing at face value. Found that framing was true only for `PKM/`/`Expansions/`/etc. (genuinely untouched) but misleading for `AGENTS.md`/`CLAUDE.md`/`README.md`/`ADAPTER-PROMPT.md` — a raw overwrite of those would have reverted Jeff's personalized team names (Hawkeye/Potter/B.J./Radar/Klinger/Margaret → the generic upstream Larry/Nolan/Pax/Penn/Mack/Silas) and silently deleted this session's own GL-010 (git-hygiene) and GL-011 (`/watch` persistence) paragraphs plus the `PKM/Environment/` registry references from `AGENTS.md`.
- **Hawkeye** — presented the tradeoff to Jeff via AskUserQuestion rather than deciding unilaterally (apply-safe-subset-only vs. apply-everything-then-manually-remerge vs. skip). Jeff chose apply-everything-then-remerge.
- **Hawkeye** — ran the full `--apply` (all 10 files backed up to `.mypka/backups/2026-07-09-212314/` before overwrite, per the updater's own safety design). Then manually rebuilt `AGENTS.md` and `CLAUDE.md` from the new upstream structure with Jeff's names and session-authored content restored. For `README.md` and `ADAPTER-PROMPT.md` — both saturated with generic mascot marketing copy (image refs to `larry.png` etc. that don't even exist as files) and carrying no functional changes for Jeff beyond naming/unbundling narrative — restored Jeff's already-correct pre-update versions from the backup rather than attempting a risky merge of copy that doesn't apply to his setup.
- **Hawkeye** — added `.mypka/` to `.gitignore` (it's declared `user_state_paths` in `manifest.json`, same treatment as `PKM/`/`Deliverables/`, but wasn't actually ignored yet).
- **Hawkeye** — regenerated `mypka.db` via `Expansions/mypka-cockpit/scripts/regen-mypka-db.py` (28 agents, clean run).
- **Hawkeye (Librarian pass)** — verified every `[[wikilink]]` in the rewritten `AGENTS.md` resolves to a real file; grepped all 4 touched files for stray generic-name references (zero found).
- **Hawkeye** — committed and pushed (`23ca3c9`) with a commit message documenting the full provenance: what came from upstream as-is, what was manually re-merged and why, what was deliberately left as Jeff's pre-update version and why.

## Decisions made

- **Scaffold updates that touch `AGENTS.md`/`CLAUDE.md` require a manual diff review before apply, not a blind trust of the updater's "0 of your files touched" summary.** That summary is accurate about `user_state_paths` (genuinely never touched) but says nothing about whether a `framework_paths` file the updater *will* overwrite has been personalized. The updater has no concept of "this framework file is also partially yours now" — that judgment has to happen outside the tool.
- **For files that are pure marketing/bootstrap copy with no operational bearing on live sessions** (`README.md`, `ADAPTER-PROMPT.md` once `PKM/.user.yaml` exists) **and where upstream's content doesn't fit the personalization at all** (mismatched mascot theming, broken image refs), the safer default is restoring the proven-correct pre-update version rather than forcing a merge of content that doesn't apply.

## Insights

- **The dead `remote_version_url` bug meant Jeff's boot-time update check had silently never worked, for an unknown number of sessions.** It failed silently by design (fail-silent-offline is a deliberate privacy feature) — which means a real bug and "no updates available" were indistinguishable from the user's side. Worth remembering this failure mode generalizes: any fail-silent check can mask a real bug for a long time, and periodically verifying the *mechanism* itself (not just trusting its silence) is worth doing when something has "just always been quiet."
- **This is a strong candidate for graduating into a Guideline** — something like "before applying a scaffold update, diff any framework-path file that is also a personalization surface (AGENTS.md, CLAUDE.md, root docs) individually; do not rely on the updater's file-count summary alone." Proposed to Jeff below; not yet written as a formal Guideline.

## Realignments

- None — Jeff's one explicit steering decision (apply everything, then manually re-merge, over the safer cherry-pick option) was a direct choice at a presented fork, not a correction of a wrong direction.

## Open threads

- **Proposed Guideline graduation** (see Insights above) — not yet written. Jeff has not been asked to confirm this specific graduation; flagging for next session or on request.
- Unchanged, carried forward: Subaru diagnostic (`tsk-2026-06-30-001`), Sea Ray windlass (`tsk-2026-07-06-002`), obd-scanner CI (`tsk-2026-07-01-001`), Weekly Strategy Report first-fire check due 2026-07-12 (`tsk-2026-07-09-002`), council-divergence instrumentation (`tsk-2026-07-09-003`), deflated-Sharpe retrospective (`tsk-2026-07-09-004`), universe-breadth research brief (`tsk-2026-07-09-005`).
- Google Drive MCP connector still needs reauthorization (carried from prior session, untouched).

## Next steps

1. If Jeff wants the "diff personalization-surface files before scaffold apply" rule formalized, write it as a new Guideline (next free `GL-0NN` slot) and wikilink it from the scaffold-update procedure.
2. Nothing blocking before the Weekly Strategy Report's first live fire, 2026-07-12.

## Cross-links

- [[2026-07-10-00-56_hawkeye_resume-folder-lookup-and-drive-auth-gap]]
