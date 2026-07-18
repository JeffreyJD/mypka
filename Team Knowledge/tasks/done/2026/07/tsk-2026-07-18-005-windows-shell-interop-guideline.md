---
id: tsk-2026-07-18-005
title: "Consolidate Windows/shell-interop gotchas into a new shared Guideline (GL-014)"
assignee: bastion
priority: 3
status: done
blocked_reason: null
blocked_by: null
created: 2026-07-18T06:54:42Z
updated: 2026-07-18T10:56:37Z
due: null
created_by: hawkeye
source: ws-004-tier-2-team-retro
parent: null
linked_sops:
  - SOP-012-close-task
linked_workstreams:
  - WS-004-team-retro-and-self-improvement-loop
linked_guidelines:
  - GL-014-windows-shell-interop-gotchas
linked_my_life: []
linked_journal_entries:
  - Team/Pierce - Senior Developer/journal/2026-06-13-vps-and-git-patterns
  - Team/Relay - Smart Home & IoT Engineer/journal/2026-07-13-esphome-windows-msys-and-longpath-gotchas
linked_session_logs: []
linked_deliverables:
  - 2026-07-18-team-retro-proposals
tags: [retro-proposal, bastion, new-guideline, approved]
---

# Consolidate Windows/shell-interop gotchas into a new shared Guideline (GL-014)

## What this is

Retro Proposal 4 (approved by Jeff 2026-07-18). At least five distinct Windows/PowerShell/Git-Bash tooling gotchas were independently discovered and separately journaled by different specialists: PowerShell breaks heredoc/quoted `git commit -m` (hit twice), `Get-Content`/`Set-Content` encoding mojibakes UTF-8 em-dashes, `chmod 600` silently no-ops on NTFS via Git Bash (needs `icacls`), `MSYSTEM=MINGW64` inherited from Git Bash breaks ESP-IDF/PlatformIO builds even via child PowerShell/cmd processes, PowerShell here-string syntax (`@'...'@`) leaks literal `@` lines when pasted into bash.

Write a new Guideline, `GL-014-windows-shell-interop-gotchas` (next available number as of 2026-07-18 — reconfirm at write time in case another GL landed first), consolidating all known gotchas in one place so future specialists `[[wikilink]]` to it instead of rediscovering each one independently.

## Context one click away

- Governing Workstream: [[WS-004-team-retro-and-self-improvement-loop]]
- Naming convention: [[GL-001-file-naming-conventions]]
- Prior evidence: [[Team/Pierce - Senior Developer/journal/2026-06-13-vps-and-git-patterns]], [[Team/Relay - Smart Home & IoT Engineer/journal/2026-07-13-esphome-windows-msys-and-longpath-gotchas]]
- Working artifacts:
  - [[2026-07-18-team-retro-proposals]]

## Success criteria

- New `GL-014-windows-shell-interop-gotchas` exists, covering at minimum: PowerShell heredoc/quoting in git commits, encoding mojibake in Get-Content/Set-Content, chmod-on-NTFS no-op, MSYSTEM leakage into child shells, PowerShell here-string paste-into-bash leak
- Added to `Team Knowledge/Guidelines/INDEX.md`
- Relevant specialist contracts (Pierce, Relay, Bastion) get a `[[wikilink]]` to it where they currently restate a gotcha inline, rather than duplicating (SSOT)
- Margaret regenerates the SQLite mirror after this lands, per WS-004 Tier 2 Step 6

## Updates

- 2026-07-18 06:54 (hawkeye) — created from approved retro proposal 4, assigned to Bastion (owns endpoint toolchain troubleshooting).
- 2026-07-18 14:10 (bastion) — claimed; loaded priors from [[Team/Pierce - Senior Developer/journal/2026-06-13-vps-and-git-patterns]] and [[Team/Relay - Smart Home & IoT Engineer/journal/2026-07-13-esphome-windows-msys-and-longpath-gotchas]]. Confirmed GL-014 was still the next free slot (checked `Team Knowledge/Guidelines/` directory listing directly, per the task's own caveat) before writing. Wrote [[GL-014-windows-shell-interop-gotchas]] covering all five gotchas (heredoc/quoted `git commit -m`, `Get-Content`/`Set-Content` mojibake, `chmod`-on-NTFS no-op via `icacls`, `MSYSTEM` leakage into child PowerShell/cmd from Git Bash, PowerShell here-string paste-into-bash leak), kept harness-agnostic per GL-005 (no harness brand names — shell names like PowerShell/Git Bash/cmd.exe are OS-level facts, not agent-harness brands, so they're fine per GL-005's own wording). Added the GL-014 row to `Team Knowledge/Guidelines/INDEX.md` and bumped "next free slot" to GL-015. Checked Pierce's, Relay's, and my own (Bastion's) `AGENTS.md` contract bodies for inline gotcha restatements to replace with a `[[wikilink]]` per the success criteria — found none: Pierce's contract mentions "PowerShell primary, Git Bash available" only as a dev-machine environment fact, not a restated gotcha, and neither Relay's nor Bastion's contract mentions any of the five gotchas at all. No contract edits made; nothing to de-duplicate. Not closing this task or running SOP-013 — Hawkeye is doing a consolidated close+reindex pass across all parallel retro tasks to avoid INDEX.md races. Margaret's SQLite-mirror regen (WS-004 Tier 2 Step 6) is still open, left for Hawkeye's consolidated pass.
- 2026-07-18 (hawkeye) — caught a numbering collision: Vex's parallel task (tsk-2026-07-18-009) independently claimed GL-014 for a different Guideline at the same time. Renumbered Vex's file to GL-015, not this one — Bastion's GL-014 stands as originally written, confirmed correct by direct read. Closing as done.

## Outcome

What shipped: new Guideline `Team Knowledge/Guidelines/GL-014-windows-shell-interop-gotchas.md`, covering five independently-discovered Windows/PowerShell/Git-Bash gotchas with concrete fixes for each, indexed in `Team Knowledge/Guidelines/INDEX.md`.

Where it lives: [[GL-014-windows-shell-interop-gotchas]]; retro corroboration in [[2026-07-18-team-retro-proposals]].

Follow-ups: none — contract SSOT check found nothing worth replacing with a wikilink.

Lessons: none new beyond the GL-014/GL-015 numbering-collision note itself, captured on tsk-2026-07-18-009 and in the Guidelines INDEX.

Archived deliverables: `2026-07-18-team-retro-proposals` — archived in the consolidated pass (shared across tasks 001-010, all closing together).
