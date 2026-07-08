---
agent_id: pierce
type: journal-entry
created: 2026-07-08T20:15:00Z
updated: 2026-07-08T20:15:00Z
topic: b2-versioning-behavior
tags: [backblaze-b2, rclone, backups, security]
linked_session_logs: [2026-07-08-15-30_hawkeye_token-dashboard-setup-and-governance-hardening]
linked_tasks: [tsk-2026-07-08-001-rotate-telegram-bot-token]
related_journal_entries: []
status: durable
---

# `rclone sync` to Backblaze B2 does NOT overwrite in place — it keeps every prior version, hidden, by default.

## Context
Scrubbed 14 leaked-credential lines from the live `cron.log` on `davisglobe-vps-ash-1`, ran an `rclone sync` to push the clean version to the B2 backup, and assumed that closed the loop. It didn't: `rclone lsl --b2-versions` revealed 16 historical daily snapshots of `cron.log` (one per day since 2026-06-12) still sitting in the bucket, each retaining the file's cumulative content as of that day's sync — meaning every one of them still contained the original leaked token. A temp `.bak` file I created during the scrub and then `rclone delete`d also didn't actually go away; the delete just hid it as another retrievable version.

## What I learned
Backblaze B2 buckets have file versioning on by default (unless a lifecycle rule limits retention), and `rclone sync`/`rclone delete` respect that — they never truly remove old content, they just change which version is "current." `rclone lsl` (no flags) only shows the current version and looks exactly like a normal single-copy backup; you have to explicitly pass `--b2-versions` to see that history exists at all. `rclone delete` on a file you don't want anymore does not free you from it — it becomes a hidden version, fully retrievable via `--b2-versions`, until you run `rclone cleanup <remote>` to purge hidden versions permanently.

This means the working assumption "the backup is just a mirror of current state" was wrong for this bucket the whole time — every daily sync of a growing/changing file has been quietly building a version history nobody was tracking or accounting for.

## When this applies
- Any time content needs to be permanently removed from a B2-backed bucket for privacy/security reasons (leaked credential, PII, anything with a "must actually be gone" requirement) — a plain sync or delete is not sufficient. Run `rclone cleanup <remote>[:path]` afterward and verify with `rclone lsl --b2-versions` that the count of versioned entries matches the count of current entries.
- Before trusting "the backup only has current state" as an assumption for any B2 bucket — check whether a lifecycle rule limits version retention, or assume it doesn't and behaves like this one.

## When this does NOT apply
- Buckets with an explicit lifecycle rule capping retention (this bucket now has one — see "Resolved same day" above).
- Providers other than B2 — this is B2's specific versioning model via the S3-like API rclone talks to; other backends (local disk, most other cloud sync targets `rclone` supports) don't necessarily behave this way.

## Resolved same day
Set a bucket-wide lifecycle rule via B2's native API (`b2_update_bucket` — rclone has no backend command for this): `daysFromHidingToDeleting: 30`. Confirmed the bucket had zero lifecycle rules before (default really is keep-forever) and confirmed the new rule persisted via a fresh, independent query after setting it. Durable record: [[backblaze-b2]] account note.

## Evidence
- [[2026-07-08-15-30_hawkeye_token-dashboard-setup-and-governance-hardening]] — session log
- [[tsk-2026-07-08-001-rotate-telegram-bot-token]] — the task this cleanup closed out
- Verification: `rclone lsl b2:Prophet-Trader/data/logs --b2-versions | wc -l` returned 39 before `rclone cleanup`, 23 after — matching the plain (non-versioned) listing count exactly, confirming zero hidden versions remained.
