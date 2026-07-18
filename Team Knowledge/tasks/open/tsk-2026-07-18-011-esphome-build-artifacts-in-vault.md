---
id: tsk-2026-07-18-011
title: "Remove ESPHome/PlatformIO build artifacts that leaked into PKM/Documents/pool"
assignee: relay
priority: 4
status: open
blocked_reason: null
blocked_by: null
created: 2026-07-18T11:23:19Z
updated: 2026-07-18T11:23:19Z
due: null
created_by: hawkeye
source: margaret-mypka-to-sqlite-regen-2026-07-18
parent: null
linked_sops:
  - SOP-002-convert-mypka-to-sqlite
  - SOP-012-close-task
linked_workstreams: []
linked_guidelines:
  - GL-006-vault-search-ignore-rules
linked_my_life: []
linked_journal_entries: []
linked_session_logs:
  - 2026-07-18-14-30_margaret_mypka-to-sqlite-regen-post-ws-004-retro
linked_deliverables: []
tags: [housekeeping, pool-monitor, vault-hygiene]
---

# Remove ESPHome/PlatformIO build artifacts that leaked into PKM/Documents/pool

## What this is

Margaret's 2026-07-18 `mypka.db` regen found a hidden build-artifact tree sitting inside the vault: `PKM/Documents/pool/.esphome/build/...` — ESPHome/PlatformIO compiler output, including vendored `libsodium`/`noise-c` library files, that has no business living inside a markdown PKA. Two stray `.md` files inside that tree were excluded from the SQLite mirror as a side effect.

This looks like build output that leaked in from the pool-monitor-automation project (owned by Relay) rather than something deliberately placed in the vault. Confirm where it came from, remove it from the vault, and make sure the pool-monitor project's own build process writes its artifacts to the project folder (`C:\Users\jeff\dev\pool-monitor` or wherever Relay's toolchain is configured) rather than back into myPKA.

## Context one click away

- Discovered during: [[2026-07-18-14-30_margaret_mypka-to-sqlite-regen-post-ws-004-retro]]
- Guideline (vault-wide search hygiene, relevant since `.gitignore` may be masking this kind of leak from normal searches): [[GL-006-vault-search-ignore-rules]]
- Procedure that surfaced it: [[SOP-002-convert-mypka-to-sqlite]]

## Success criteria

- `PKM/Documents/pool/.esphome/` (or wherever the leaked build tree actually lives once confirmed) is removed from the vault
- Root cause identified: how did a build directory end up inside `PKM/Documents/` — a misconfigured build path, a copy-paste, or something else
- Relay's ESPHome/pool-monitor build configuration confirmed to write artifacts outside the vault going forward
- Margaret's next SQLite regen shows no more stray files under `PKM/Documents/pool/`

## Updates

- 2026-07-18 11:23 (hawkeye) — created from Margaret's regen finding, per Jeff's approval to track it as a task.
