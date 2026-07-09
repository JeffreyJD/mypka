---
agent_id: pierce
type: journal-entry
created: 2026-07-09T01:15:00Z
updated: 2026-07-09T01:15:00Z
topic: credential-scoping-decisions
tags: [security, api-keys, b2, architecture]
linked_session_logs: []
linked_tasks: [tsk-2026-07-09-001-merge-b2-autopsy-timing-fix]
related_journal_entries: []
status: durable
---

# When a new component needs data from an existing system, check whether an already-scoped credential can be extended before minting a new, broader one.

## Context
The Weekly Strategy Report cloud routine needed a way to read Prophet Trader's weekly data. The first design used git: have the VPS push data into the private `mypka` vault repo, which the routine could then read from its own clone. That required giving `davisglobe-vps-ash-1` a brand-new credential — write access to the entire personal vault repo — to solve what was actually a much narrower problem (read one folder's worth of JSON files). Jeff rejected it on sight, correctly: a compromised VPS with that credential could read/write the whole vault, not just trading data.

The actual fix reused a trust relationship that already existed: the VPS already writes Prophet Trader's data to a Backblaze B2 bucket nightly. Instead of a new git credential, a second B2 Application Key was created — read-only, restricted to one bucket, restricted to one file-name prefix (`data/autopsies/`) — and the cloud routine reads directly from B2. Zero new trust granted to the VPS; the new credential's own blast radius, even if leaked, is "read old summary numbers."

## What I learned
Also learned a mechanical fact worth remembering: an operational B2 key (the kind rclone uses for day-to-day read/write on a bucket) does NOT have `writeKeys` capability by default — it can't create other keys. Calling `b2_create_key` with it returns a bare `401 unauthorized`. Creating a new scoped key requires the account's master key or a key explicitly granted key-management capability, which most services don't hand out for routine automation. In practice this means: **the human has to create narrowly-scoped keys through the provider's own console** — it's not something the agent holding only an operational credential can bootstrap for itself, and that's a feature of the security model, not a bug to route around.

## When this applies
- Any time a new component (a script, a scheduled job, a new service) needs access to data or systems another component already touches.
- Before reaching for "give the new thing its own broad credential," check: does something in the existing architecture already have a relationship to this data that could be narrowed and reused instead?
- When an API call to create/manage credentials returns an unexpected `401`/`403` from a key you know is valid for other operations — check whether the capability you need (key management) is simply a different, higher tier than the capability the key actually has (file read/write).

## When this does NOT apply
- When no existing credential's scope is anywhere close to what's needed — forcing a fit onto an unrelated existing key is worse than a clean, purpose-built one.
- When the existing credential is itself overprivileged — extending access via an already-too-broad key just compounds the problem; narrow the existing one first if that's the case.

## Evidence
- [[tsk-2026-07-09-001-merge-b2-autopsy-timing-fix]] — the task this decision shipped under
- [[prophet-trader-weekly-strategy-report]] — service note documenting both the rejected design and the one that shipped
- [[backblaze-b2]] — account note with the new key's exact capability restrictions and verification results
