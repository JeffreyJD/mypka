# GL-013 - Credential Backup Hygiene on Operational Hosts

> **This Guideline is a general rule for any agent (chiefly Pierce, but any agent doing ops work on any host) making a pre-change backup of a file that holds live credentials.** `.gitignore` stops a file from entering git history. It does nothing about disk-level exposure, backup-tool scope creep, or someone browsing the directory. Those need a separate discipline, which is what this Guideline sets.

## The rule

**Never create a literal copy of a credential-bearing file (`.env` or equivalent) inside a git working directory — not even a gitignored one.** If a rollback copy is genuinely needed during a change:

- Store it **outside the repo directory entirely** (e.g. `~/.env-backups/`, not `/home/trader/<project>/`).
- Match the original's permissions exactly — `chmod 600`, same owner, same group.
- **Delete it the moment the change is verified working — not on a calendar TTL.** "Verified working" already has a concrete definition for most changes on this system: a same-day smoke test plus the next real scheduled run succeeding. That's the deletion trigger, not a separate clock someone has to remember to check.

This applies to any credential-bearing file touched during ops work on any host, not just Prophet Trader's `.env`.

## Why this rule exists

2026-07-14/15: a pre-change backup of Prophet Trader's `.env` (`.env.bak-2026-07-11`, made ahead of a routine env-var append) was found still sitting, unencrypted, inside the git working directory on `davisglobe-vps-ash-1` — days after the change it protected had already been verified working twice over (a same-day smoke test, then a real successful scheduled cron run). It held a full copy of every production credential, including the same Telegram bot token class that had already leaked once this month and required rotation ([[tsk-2026-07-08-001-rotate-telegram-bot-token]]). It had also, until this finding, gone unnoticed by `.gitignore` — meaning it could have been silently swept into a future commit at any point.

Vex's assessment: the underlying intent (keep one rollback copy during a risky change) is legitimate. The failure was in the implementation — an unencrypted copy, inside the repo directory, with no deletion trigger tied to "the rollback window is actually closed." This Guideline codifies the corrected version of that same intent rather than banning backups outright.

This is the same failure shape as [[GL-007-verify-before-acting-on-a-finding]]'s founding incident — a stale artifact holding a secret value that nobody has a standing reason to remember exists, months from now, at the next rotation. GL-007 is about verifying a finding is still current before acting on it; this Guideline is about not creating that kind of stale, easy-to-forget artifact in the first place.

## When this does NOT apply

- Encrypted, access-controlled secret storage designed for long-term retention (a proper secrets manager, an encrypted vault) — this Guideline is about ad-hoc plaintext backups made during a one-off change, not a deliberate credential-storage system.
- A backup of a file that never held live credentials — normal pre-change backups of config, code, or non-secret data don't need this treatment; `.gitignore` alone is sufficient there.

## Updates to this Guideline

- 2026-07-15 — created (Hawkeye), authoring Vex's proposed rule verbatim from his conditional credential-retention audit on `.env.bak-2026-07-11`, at Jeff's explicit request to route the finding to Vex and act on his judgment.
