# GL-007 - Verify Current State Before Acting on a Historical Finding

> **This Guideline is a general rule every agent reads before recommending or documenting an action based on a finding drawn from historical evidence.** Log audits, backup inspections, git-history scans, old session logs, stale registry notes — any of these can prove something was *once* true. None of them prove it is *still* true. SOPs and Workstreams `[[wikilink]]` here rather than restating the rule.

## The rule

**Before opening a task, writing a remediation recommendation, or telling the user to take an action based on a historical finding, check whether the finding is still live.** A finding drawn from logs, backups, git history, or an old note describes the state of the world *at the time that artifact was produced*. The world may have already moved on — especially if the user acted outside the current session.

This is not "don't trust old data." Old data is often exactly right. It's "confirm before asking someone to redo work that's already done."

## How to check, without exposing what you're checking

The check is almost always cheap and almost always safe to do without printing secrets in the clear:

| Situation | Verification method |
|---|---|
| Credential possibly leaked/rotated | Run a **Hash / Fingerprint Compare** (named method below) — never echo both raw values side by side. |
| Config/commit possibly stale | Check the live host/repo directly (`git log -1`, `git rev-parse HEAD`, live file read) before trusting a registry note's recorded value. |
| "Is this bug still present" | Re-run the reproduction against current code/state, don't infer from the historical report alone. |
| "Did the user already fix this" | Ask, or check for the most recent evidence (latest commit, latest log line, latest task/journal entry) before assuming silence means "still broken." |

## Named method: Hash / Fingerprint Compare

Use this specific, named check whenever a finding is "is a leaked or historical credential still live" — a case that comes up often enough that it deserves a citable procedure rather than being re-derived from memory each time.

1. Take the **historical value** (the one found in the log, backup, or git-history artifact) and the **current live value** (from the running config, `.env`, or secret manager).
2. Hash both independently with the same algorithm (SHA-256 is sufficient) — or, if hashing isn't convenient in the moment, reduce both to a short fingerprint (the last 4-6 characters of each).
3. Compare the **hashes or fingerprints**, never the raw values. **Never print or compare both raw values side by side, even in a private terminal** — the whole point of the method is confirming liveness without creating a second exposure of the secret.
4. **Match** → the historical value is still the live one: the exposure is real and current, rotation is genuinely needed. **No match** → someone already rotated it: the finding is historical, no remediation action needed beyond noting it as resolved.

Cite this by name ("running a hash/fingerprint compare") rather than re-explaining the steps inline — this section is the canonical description.

## Why this rule exists

2026-07-08: a Prophet Trader status check led to a genuine finding — a Telegram bot token had leaked into plaintext logs (and into the Backblaze B2 backup) before a logging fix shipped on 2026-07-01. Hawkeye wrote up the audit and opened a priority-1 task telling Jeff to rotate the token via BotFather. Jeff replied: he'd already rotated it. A same-day hash comparison of the current `.env` value against the leaked log value confirmed they didn't match — the exposure was already inert, and the task was closed same-day with zero action needed.

The audit itself was correct. The miss was recommending action without first checking whether the recommended action was already moot. See [[2026-07-08-verify-before-assuming-a-finding-is-unresolved]] (Hawkeye's journal) for the full account.

## When this does NOT apply

- The finding concerns a code path or process, not a point-in-time state (e.g., "this logging statement leaks secrets" is true regardless of whether any particular secret is currently exposed — the code fix recommendation stands on its own).
- You've already confirmed currency in the same investigation (don't re-check something you just verified thirty seconds ago).

## Updates to this Guideline

- 2026-07-08 — created (Hawkeye), graduated from [[2026-07-08-06-30_hawkeye_prophet-trader-status-check-token-leak-found]].
- 2026-07-18 — added the named "Hash / Fingerprint Compare" method (Vex), per WS-004 Tier 2 Team Retro proposal 8 — the technique already lived in the table above but had been invoked from memory 3+ times without a citable name; now named and spelled out as its own section. Source: [[Team/Hawkeye - Orchestrator/journal/2026-07-08-verify-before-assuming-a-finding-is-unresolved]].
