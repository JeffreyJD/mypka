---
id: tsk-2026-07-18-009
title: "Write the hash-compare and narrow-credential-expansion patterns into a Guideline"
assignee: vex
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
linked_workstreams: []
linked_guidelines:
  - GL-007-verify-before-acting-on-a-finding
  - GL-015-credential-expansion-over-new-grants
linked_my_life: []
linked_journal_entries:
  - Team/Hawkeye - Orchestrator/journal/2026-07-08-verify-before-assuming-a-finding-is-unresolved
  - Team/Pierce - Senior Developer/journal/2026-07-09-prefer-expanding-a-narrow-credential-over-minting-a-broad-one
linked_session_logs: []
linked_deliverables:
  - 2026-07-18-team-retro-proposals
tags: [retro-proposal, vex, gl-007, approved]
---

# Write the hash-compare and narrow-credential-expansion patterns into a Guideline

## What this is

Retro Proposal 8 (approved by Jeff 2026-07-18). Two techniques were each invoked from memory 3+ times rather than from written procedure: comparing a hash/fingerprint instead of raw secrets when checking whether a leaked credential is still live (used to resolve the Telegram-token question without ever printing either value), and expanding an existing narrow-scoped credential instead of minting a new broad one (used at least three times: a second B2 Application Key instead of broad VPS git access; refusing to hand over a raw production Telegram token for a cloud routine; a new write-scoped GitHub deploy key instead of reusing/broadening an existing one).

Add the hash-compare method as a named technique in [[GL-007-verify-before-acting-on-a-finding]]; add the narrow-credential-expansion default as a named technique in Vex's own contract (or a small new Guideline if Vex judges it needs its own home), so both are citable rather than re-derived from memory each time.

## Context one click away

- Guideline being amended: [[GL-007-verify-before-acting-on-a-finding]]
- Prior evidence: [[Team/Hawkeye - Orchestrator/journal/2026-07-08-verify-before-assuming-a-finding-is-unresolved]], [[Team/Pierce - Senior Developer/journal/2026-07-09-prefer-expanding-a-narrow-credential-over-minting-a-broad-one]]
- Working artifacts:
  - [[2026-07-18-team-retro-proposals]]

## Success criteria

- GL-007 names the hash/fingerprint-compare technique explicitly as a method for "is this secret still live" checks
- The narrow-credential-expansion default is written down somewhere citable (Vex's contract or a new small Guideline — Vex's call)
- Margaret regenerates the SQLite mirror after this lands, per WS-004 Tier 2 Step 6

## Updates

- 2026-07-18 06:54 (hawkeye) — created from approved retro proposal 8, assigned to Vex.
- 2026-07-18 09:45 (vex) — picked up; loaded priors from [[Team/Hawkeye - Orchestrator/journal/2026-07-08-verify-before-assuming-a-finding-is-unresolved]] and [[Team/Pierce - Senior Developer/journal/2026-07-09-prefer-expanding-a-narrow-credential-over-minting-a-broad-one]]. Note on claim mechanics: this session has no shell/file-delete tool available, so the physical `git mv` from `tasks/open/` to `tasks/in-progress/` could not be executed here — frontmatter below is updated to `status: in-progress` in place, at this path, pending the physical folder move. Flagging to Hawkeye to complete the move (or delegate it) ahead of the consolidated close+reindex pass so folder and frontmatter agree before SOP-013 runs.
- 2026-07-18 10:20 (vex) — completed both amendments. Added a new named "Hash / Fingerprint Compare" method section to `Team Knowledge/Guidelines/GL-007-verify-before-acting-on-a-finding.md` (inserted between the existing verification table and "Why this rule exists"; the table's "Credential possibly leaked/rotated" row now points to the named section instead of restating the steps), and logged the change in GL-007's own Updates section. Created a new standalone Guideline, originally written as `GL-014-credential-expansion-over-new-grants.md`, for the narrow-credential-expansion default rather than folding it into Vex's own contract — chose a Guideline because the pattern has already been invoked by more than one agent (Pierce on the B2/Telegram/GitHub-deploy-key decisions, Hawkeye on the rejected VPS git-access design) making credential-provisioning calls outside a security-audit context, so it reads as a team-wide default rather than a Vex-specific audit technique. Added cross-references from `Team/Vex - Security Engineer/AGENTS.md` (Core philosophy #2, a new Critical rule #11, and the References list) so the new Guideline is discoverable from Vex's own contract without duplicating its content there, per the SSOT rule. Both files kept harness-agnostic per GL-005 — no harness/product names, no host-specific tool names. Not closing this task or running SOP-013 per Hawkeye's instruction; handed back for the consolidated close+reindex pass.
- 2026-07-18 (hawkeye) — **numbering collision caught and fixed.** Bastion's parallel task (tsk-2026-07-18-005) independently claimed GL-014 for the Windows/shell-interop Guideline at the same time Vex claimed it for this one — both agents ran concurrently and neither could see the other's write before confirming the number was free. Renamed Vex's file to `GL-015-credential-expansion-over-new-grants.md`, updated all three references in `Team/Vex - Security Engineer/AGENTS.md`, updated `linked_guidelines` above, and added GL-015's row to `Team Knowledge/Guidelines/INDEX.md` (Bastion's GL-014 row stands as originally written). Also completed the physical `open/` → `in-progress/` move Vex's session couldn't do (no shell/file-delete tool available to that agent). Verified both GL-007's amendment and GL-015's content directly. Closing as done.

## Outcome

What shipped: GL-007 gained a named "Hash / Fingerprint Compare" method section for verifying a leaked credential is still live. A new Guideline, `GL-015-credential-expansion-over-new-grants.md`, documents the narrow-credential-expansion default, with cross-references added from Vex's own contract.

Where it lives: [[GL-007-verify-before-acting-on-a-finding]]; [[GL-015-credential-expansion-over-new-grants]]; retro corroboration in [[2026-07-18-team-retro-proposals]].

Follow-ups: none.

Lessons: the GL-014/GL-015 numbering collision itself is worth remembering — when two parallel agents each independently confirm a "next free number" by listing a directory, a race is still possible between the confirm and the write. No process change proposed here; noting it as a live example for a future retro if it recurs.

Archived deliverables: `2026-07-18-team-retro-proposals` — archived in the consolidated pass (shared across tasks 001-010, all closing together).
