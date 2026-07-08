---
# Identity
id: tsk-2026-07-08-001
title: "Rotate Prophet Trader Telegram bot token (leaked to logs pre-2026-07-01)"

# Ownership & priority
assignee: jeff
priority: 1

# Status (mirrors folder location)
status: done
blocked_reason: null
blocked_by: null

# Time
created: 2026-07-08T00:00:00Z
updated: 2026-07-08T00:00:00Z
due: null

# Provenance
created_by: hawkeye
source: session
parent: null

linked_sops: []
linked_workstreams: []
linked_guidelines: []
linked_my_life: []
linked_session_logs: ["2026-07-08-06-30_hawkeye_prophet-trader-status-check-token-leak-found"]
linked_journal_entries: ["2026-07-08-verify-before-assuming-a-finding-is-unresolved"]
linked_deliverables: ["2026-07-08-prophet-trader-telegram-token-leak-security-audit"]

tags: ["security", "prophet-trader", "credentials"]
---

# Rotate Prophet Trader Telegram bot token

## What this is

Vex's audit found the live `TELEGRAM_BOT_TOKEN` logged in plaintext 14 times in `/home/trader/prophet-trader/data/logs/cron.log` between 2026-06-12 and 2026-07-01 (httpx INFO-level request logging, fixed in commit `ab8dadd`). The log file — leaked token included — is also synced to the Backblaze B2 backup nightly. The logging bug is already fixed; the *exposed value itself* is not, since old log/backup copies still hold it.

## Context one click away

- Audit report: [[2026-07-08-prophet-trader-telegram-token-leak-security-audit]]
- Account: [[telegram-prophet-bot]]
- Service: [[prophet-trader]]

## Success criteria

- New bot token generated via @BotFather (`/mybots` → bot → API Token → Revoke current token)
- `TELEGRAM_BOT_TOKEN` updated in `/home/trader/prophet-trader/.env` on `davisglobe-vps-ash-1`
- Verified: next routine run or `scripts/test_healthchecks.py` sends successfully with the new token
- Old token confirmed dead (a request using it returns 401)

## Updates

- 2026-07-08 (hawkeye) — created from Vex's audit finding during a routine "status of prophet-trader runs" check.
- 2026-07-08 (hawkeye) — Jeff confirmed he'd already rotated the token before this task was opened. Verified via SHA-256 fingerprint comparison (never exposing raw values): current `.env` token hash `0326452b...` does not match the leaked-log token hash `71fa7e59...`. Confirmed already resolved — closing without further action.

## Outcome

What shipped: nothing new — verification only. Jeff had already rotated `TELEGRAM_BOT_TOKEN` via @BotFather prior to this task being opened; the token that leaked into `cron.log` (2026-06-12 through 2026-07-01) is no longer live. Confirmed by comparing SHA-256 hashes of the current `.env` value against the leaked log value — they differ.

Where it lives: verification done live over SSH on `davisglobe-vps-ash-1`; no commit, no file change.

Follow-ups: none. Optional/low-priority housekeeping only — scrubbing the 14 dead-token lines from `cron.log` for tidiness, not urgent since the exposed value is already inert.

Lessons: [[2026-07-08-verify-before-assuming-a-finding-is-unresolved]] (journal).

Archived deliverables: `2026-07-08-prophet-trader-telegram-token-leak-security-audit` → archived to `Deliverables/_archive/2026/07/2026-07-08-prophet-trader-telegram-token-leak-security-audit.md`.

## Final update

- 2026-07-08 10:45 (hawkeye) — done: token already rotated by Jeff before task was opened; verified via hash comparison, no action taken, closed same-day.
