# GL-010 - Commit and Push Every Touched Repo Before Session Close

> **This Guideline is a general rule every agent reads before closing a session** — whether triggered by `/close-session` or any natural-language close-session phrase in `AGENTS.md`. SOPs and Workstreams `[[wikilink]]` here rather than restating the rule.

## The rule

**A session is not closed until every git repo it touched — myPKA itself included — is committed and pushed, with a clean working tree.** This is not optional, not conditional on the user asking, and not deferred to "next time." If the session edited files in `C:\Users\jeff\My Drive\myPKA` (which is itself a git repo, remote `origin` = `github.com/JeffreyJD/mypka`) or in any code project under `C:\Users\jeff\dev\`, the close-session procedure checks `git status` on each, and commits + pushes before the session log is finalized.

## Why this can't be left to the user to request

Jeff had been manually typing "please commit, and update all files and documentation" before every close-session, specifically because he didn't trust the process to do it on its own. He was right not to trust it: neither `Team Knowledge/SOPs/SOP-015-write-session-log.md` nor the close-session command ever mentioned git at all. A user compensating by memory for a gap in the process is the exact failure pattern this whole Guideline series (GL-007, GL-008, GL-009) exists to close — the difference here is that this one was never even attempted automatically; it depended entirely on Jeff remembering to ask, every single time, forever.

## What "every touched repo" means in practice

1. **myPKA itself.** Run `git status` at the vault root. If there are staged, unstaged, or untracked changes from this session, commit them (specific files, not blanket `git add -A`, per the standing git safety protocol) and push to `origin/main`.
2. **Any code project repo edited this session** (e.g. `prophet-trader`, `obd-scanner`, `mypka-photos`) — check `git status` there too. Follow that project's own branch discipline (e.g. Pierce's dev→main rule for prophet-trader — commit to `dev`, open a PR, do not push straight to `main` without the owner's sign-off). "Committed and pushed" for a project with branch protection means "pushed to `dev` and a PR exists," not "force-merged to `main` unattended."
3. **If a push is blocked** (merge conflict, diverged branch, failing CI) — do not silently skip it. Surface the blocker to the user explicitly in the close-session report. A blocked push is a known open item, not a silently dropped one.

## When this does NOT apply

- Read-only sessions that made no file edits anywhere — nothing to commit, say so explicitly rather than running the check pointlessly.
- Secrets or credential files that should never be committed — those were never supposed to be tracked in the first place (see [[GL-002-frontmatter-conventions]] rule 7); this Guideline does not override that boundary.

## Updates to this Guideline

- 2026-07-08 — created (Hawkeye), at Jeff's explicit request after he named the exact pattern: manually re-typing a commit reminder every session because he suspected (correctly) that drift was happening without it.
