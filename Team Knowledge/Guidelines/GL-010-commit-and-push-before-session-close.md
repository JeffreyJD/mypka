# GL-010 - Commit and Push at Session Checkpoints, Not Just at Close

> **This Guideline is a general rule every agent reads continuously during a session, not just at the end.** It governs both the mandatory session-close git step and the mid-session checkpoints that should make the close-time step nearly a no-op. SOPs and Workstreams `[[wikilink]]` here rather than restating the rule.

## The rule

**Every git repo a session touches — myPKA itself included — gets committed and pushed at defined checkpoints during the session, not batched up and discovered at the end.** Session close (`/close-session` or any natural-language trigger) remains a mandatory final check per the original version of this Guideline, but it exists as a **backstop**, not the primary mechanism. A session that only commits at close is still exposed for its entire duration — a crash, a dropped connection, or simply forgetting the close trigger loses everything back to the last checkpoint. The fix isn't a better final step; it's more frequent ones.

## Mid-session checkpoint triggers

Fire a checkpoint (git status → commit specific files → push, plus a task-index rebuild per [[SOP-013-rebuild-task-index]] if any task changed) whenever **any one** of these happens — don't wait for all of them, don't wait for a natural pause:

1. **A PR merges or a deploy is confirmed.** The moment a change lands on `main` and is verified, the myPKA-side record of it (registry note, task, session note) gets committed immediately — not carried forward to see what else accumulates.
2. **A Guideline, SOP, or Workstream is created or edited.** Framework changes are exactly the kind of thing that must never be lost to a dropped session — commit right after writing it.
3. **A task transitions to `done` or `cancelled`.** Commit and rebuild the task index at the moment of closure, per [[GL-004-task-resource-linking]] — don't defer the index rebuild to a later batch.
4. **A security or credential finding is resolved.** This class of change should never sit uncommitted longer than necessary.
5. **The session pivots to a materially different sub-topic.** If the conversation moves from "set up tool X" to "audit system Y," that boundary is a checkpoint — whatever was in flight for the first topic gets committed before starting the second, even if it doesn't feel "done."
6. **Quantity fallback.** If none of the above have fired and more than ~15 files have accumulated uncommitted in any one touched repo, checkpoint anyway. This is a safety net under the milestone-based triggers, not a replacement for them — waiting for a number to be hit is worse than reacting to the actual events above.

## Why frequency matters more than the final check

Tonight's session ran 4+ hours and touched ~35 files in myPKA alone before any commit happened — including after this Guideline already existed in an earlier, close-only form. The existence of a mandatory close-time step didn't prevent the accumulation; it just caught it eventually. Multiple checkpoint triggers fired during that window (at least two PR merges, four Guideline creations, three task closures) and every one of them was a missed opportunity to commit immediately instead of later.

## What "every touched repo" means in practice

1. **myPKA itself.** Run `git status` at the vault root (remote `origin` = `github.com/JeffreyJD/mypka`). Commit specific files (never blanket `git add -A`) and push to `origin/main`.
2. **Any code project repo edited this session** (e.g. `prophet-trader`, `obd-scanner`, `mypka-photos`) — check `git status` there too, following that project's own branch discipline (e.g. Pierce's dev→main rule — commit to `dev`, open a PR, don't force-merge to `main` without the owner's sign-off). "Committed and pushed" for a branch-protected project means "pushed to `dev` and a PR exists."
3. **If a push is blocked** (merge conflict, diverged branch, failing CI) — surface the blocker immediately, don't silently skip it and hope the next checkpoint resolves it.

## Session close remains mandatory, as a backstop

The original rule still applies in full: before a session is considered closed, re-run the check across every touched repo. If the checkpoints above have been followed, this should find nothing new — a clean pass at close is the signal the mid-session discipline actually worked, not proof it was unnecessary.

## When this does NOT apply

- Read-only sessions that made no file edits anywhere — nothing to commit, say so explicitly.
- Secrets or credential files that should never be committed — those were never supposed to be tracked (see [[GL-002-frontmatter-conventions]] rule 7); this Guideline does not override that boundary.

## Updates to this Guideline

- 2026-07-08 — created (Hawkeye), at Jeff's explicit request after he named the exact pattern: manually re-typing a commit reminder every session because he suspected (correctly) that drift was happening without it.
- 2026-07-08 (same day, later) — expanded from close-only to mid-session checkpoints, after the same session that created this Guideline went on to accumulate 35 uncommitted files across 4+ hours before the close-time step ever fired. Jeff named the general pattern directly: "I am nervous that the team keeps missing this and we keep having drift and misses."
