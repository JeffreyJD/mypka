---
id: tsk-2026-07-19-002
title: "Add a git-workflow section to Felix's contract, mirroring Pierce's"

assignee: potter
priority: 3

status: open
blocked_reason: null
blocked_by: null

created: 2026-07-19T23:21:17Z
updated: 2026-07-19T23:21:17Z
due: null

created_by: hawkeye
source: team-inbox-handoff
parent: null

linked_sops:
  - SOP-010-create-task
linked_workstreams:
  - WS-006-software-change-lifecycle
linked_guidelines: []
linked_my_life: []
linked_session_logs:
  - 2026-07-19-21-23_hawkeye_crash-recovery-verification
linked_journal_entries: []
linked_deliverables:
  - 2026-07-19-ws-006-post-implementation-audit
tags: [contract-hygiene, felix, ws-006, documentation-only]
---

# Add a git-workflow section to Felix's contract, mirroring Pierce's

## What this is

[[WS-006-software-change-lifecycle]] assumes Felix follows the same `dev`→`main`/PR/CI discipline as Pierce, and Jeff confirmed this directly at WS-006's ratification (`tsk-2026-07-18-016`). But `Team/Felix - Frontend Developer/AGENTS.md` doesn't document it — the assumption lives only in WS-006 and the ratification session log, not in the file Felix himself reads. Confirmed absent by direct grep (`git-workflow`, `dev.*main`, `force-push`, `branch` — zero matches in Felix's contract) as of this task's creation.

This gap was flagged twice in prior work (the 2026-07-18 and 2026-07-19 session logs' open threads) and surfaced a third time by an external post-implementation audit dropped into Team Inbox — see [[2026-07-19-ws-006-post-implementation-audit]], Item 2.

## Why it matters

If Felix is ever dispatched cold on a frontend PR, his own contract doesn't tell him the branch/PR discipline WS-006 expects of him. Low risk (the discipline is already confirmed, not disputed) but a real documentation gap — an assumption a Workstream depends on should live where the specialist it governs would see it.

## Suggested action (per the audit)

Add a git-workflow section to `Team/Felix - Frontend Developer/AGENTS.md`, mirroring Pierce's (`dev`→`main`, PR-with-why, no direct `main` commits, no force-push). Use Felix's existing contract as the base. Small, self-contained — this is *documenting* an already-confirmed behavior, not deciding new scope, so it's closer to hygiene than a Tier 1 framework decision. Jeff should confirm on review that it's transcription only.

## Context one click away

- Workstream this closes a gap in: [[WS-006-software-change-lifecycle]]
- Contract being amended: [[Team/Felix - Frontend Developer/AGENTS]]
- Reference contract (the pattern to mirror): [[Team/Pierce - Senior Developer/AGENTS]]
- Source of this task: [[2026-07-19-ws-006-post-implementation-audit]]
- Prior context: [[2026-07-19-02-05_hawkeye_ws-006-ratification-and-three-hires]]

## Success criteria

- `Team/Felix - Frontend Developer/AGENTS.md` gains a git-workflow section documenting `dev`→`main`, PR-with-why, no direct `main` commits, no force-push
- Jeff confirms the addition transcribes already-confirmed behavior and doesn't introduce new scope
- No other section of Felix's contract is touched beyond what's needed for the addition to read cleanly

## Updates
- 2026-07-19 23:21 (hawkeye) — created, routed to Potter. Surfaced by [[2026-07-19-ws-006-post-implementation-audit]] Item 2, itself a restatement of an open thread already flagged twice. Not yet dispatched.
