---
agent_id: hawkeye
type: journal-entry
created: 2026-07-08T10:45:00Z
updated: 2026-07-08T10:45:00Z
topic: verify-before-assuming-a-finding-is-unresolved
tags: [security, verification, credentials, prophet-trader]
linked_session_logs: [2026-07-08-06-30_hawkeye_prophet-trader-status-check-token-leak-found]
linked_tasks: [tsk-2026-07-08-001-rotate-telegram-bot-token]
related_journal_entries: []
status: durable
---

# When a security finding recommends "rotate the credential," check whether it already happened before opening a task for it.

## Context
Found a leaked Telegram bot token in old Prophet Trader logs and opened a priority-1 task telling Jeff to rotate it. Jeff replied "we already did this... is this after I changed [the key]?" — he'd rotated it before I ever ran the check. A SHA-256 fingerprint comparison of the live `.env` value against the leaked log value confirmed they differ: already resolved, zero action needed.

## What I learned
A log-forensics audit proves a secret *was* exposed at some point in the past — it says nothing about whether that secret is still live today. Before writing "rotate this" as an action item, check the *current* value against the *leaked* value. This is checkable without ever printing the raw secret: hash both sides (`sha256sum`) or compare a short fingerprint (last 4-6 chars), and compare hashes/fingerprints, not values. If they match, the exposure is still live and rotation is genuinely needed. If they don't match, someone already handled it and the finding is historical, not actionable.

## When this applies
- Any credential-leak finding where the audit only inspected historical artifacts (logs, backups, git history) and not the live config.
- Before creating a task or asking the user to take a remediation action for a "found a leaked secret" finding.
- Whenever a secret rotation might have happened outside the visible session (user did it manually, another tool did it, a scheduled rotation ran).

## When this does NOT apply
- Findings about the *code path* that caused the leak (e.g. "httpx logging needs suppressing") — that's a code fix, not a credential-state question, and doesn't need this check.
- Cases where printing/comparing the value would itself violate secret-handling rules — always compare via hash or fingerprint, never by echoing both raw values side by side.

## Evidence
- [[2026-07-08-06-30_hawkeye_prophet-trader-status-check-token-leak-found]] — session log with the full sequence
- [[tsk-2026-07-08-001-rotate-telegram-bot-token]] — task opened then closed same-day once verification showed it was already resolved
- [[2026-07-08-prophet-trader-telegram-token-leak-security-audit]] — the audit report itself, which correctly separated "fix shipped" from "exposure remediated" but didn't check current-vs-leaked before recommending action
