# GL-007 - Verify Current State Before Acting on a Historical Finding

> **This Guideline is a general rule every agent reads before recommending or documenting an action based on a finding drawn from historical evidence.** Log audits, backup inspections, git-history scans, old session logs, stale registry notes — any of these can prove something was *once* true. None of them prove it is *still* true. SOPs and Workstreams `[[wikilink]]` here rather than restating the rule.

## The rule

**Before opening a task, writing a remediation recommendation, or telling the user to take an action based on a historical finding, check whether the finding is still live.** A finding drawn from logs, backups, git history, or an old note describes the state of the world *at the time that artifact was produced*. The world may have already moved on — especially if the user acted outside the current session.

This is not "don't trust old data." Old data is often exactly right. It's "confirm before asking someone to redo work that's already done."

## How to check, without exposing what you're checking

The check is almost always cheap and almost always safe to do without printing secrets in the clear:

| Situation | Verification method |
|---|---|
| Credential possibly leaked/rotated | Hash both the current live value and the historical value (`sha256sum`) and compare hashes — or compare a short fingerprint (last 4-6 chars). Never echo both raw values side by side. |
| Config/commit possibly stale | Check the live host/repo directly (`git log -1`, `git rev-parse HEAD`, live file read) before trusting a registry note's recorded value. |
| "Is this bug still present" | Re-run the reproduction against current code/state, don't infer from the historical report alone. |
| "Did the user already fix this" | Ask, or check for the most recent evidence (latest commit, latest log line, latest task/journal entry) before assuming silence means "still broken." |

## Why this rule exists

2026-07-08: a Prophet Trader status check led to a genuine finding — a Telegram bot token had leaked into plaintext logs (and into the Backblaze B2 backup) before a logging fix shipped on 2026-07-01. Hawkeye wrote up the audit and opened a priority-1 task telling Jeff to rotate the token via BotFather. Jeff replied: he'd already rotated it. A same-day hash comparison of the current `.env` value against the leaked log value confirmed they didn't match — the exposure was already inert, and the task was closed same-day with zero action needed.

The audit itself was correct. The miss was recommending action without first checking whether the recommended action was already moot. See [[2026-07-08-verify-before-assuming-a-finding-is-unresolved]] (Hawkeye's journal) for the full account.

## When this does NOT apply

- The finding concerns a code path or process, not a point-in-time state (e.g., "this logging statement leaks secrets" is true regardless of whether any particular secret is currently exposed — the code fix recommendation stands on its own).
- You've already confirmed currency in the same investigation (don't re-check something you just verified thirty seconds ago).

## Updates to this Guideline

- 2026-07-08 — created (Hawkeye), graduated from [[2026-07-08-06-30_hawkeye_prophet-trader-status-check-token-leak-found]].
