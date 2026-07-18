---
id: tsk-2026-07-18-004
title: "Write the Hawkeye execute-vs-route boundary explicitly into his contract"
assignee: potter
priority: 2
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
  - SOP-001-how-to-add-a-new-specialist
  - SOP-012-close-task
linked_workstreams:
  - WS-004-team-retro-and-self-improvement-loop
linked_guidelines: []
linked_my_life: []
linked_session_logs: []
linked_journal_entries: []
linked_deliverables:
  - 2026-07-18-team-retro-proposals
tags: [retro-proposal, potter, hawkeye-contract, approved, framework-edit]
---

# Write the Hawkeye execute-vs-route boundary explicitly into his contract

## What this is

Retro Proposal 3 (approved by Jeff 2026-07-18). Two independently-evidenced rules collided in the same week without a written boundary between them: Jeff's "execute for me, don't pass the buck" (2026-07-06), and the iron rule that Hawkeye routes domain work to specialists rather than doing it himself (Hawkeye was corrected twice on 2026-07-14 for doing ESPHome toolchain work directly instead of routing to Relay — "this has been established already"). Both rules are real and independently well-evidenced; neither document states where the line falls between them.

Add a short explicit clause to Hawkeye's contract: Hawkeye executes orchestration, librarian, and administrative work himself (session logs, task hygiene, wikilink repair, filing, research synthesis, retro mining); Hawkeye routes anything that requires a domain specialist's registered knowledge or tools (toolchain install, firmware, financial judgment, security review, etc.). The test is "does this require a specialist's domain knowledge," not "can the underlying tools technically do this."

This is a contract edit — human-gated per WS-004's hard invariant. Jeff has approved the WHAT; Potter drafts the actual wording.

## Context one click away

- Contract being amended: [[Team/Hawkeye - Orchestrator/AGENTS]]
- Governing Workstream: [[WS-004-team-retro-and-self-improvement-loop]]
- Working artifacts:
  - [[2026-07-18-team-retro-proposals]]

## Success criteria

- Hawkeye's contract states the execute-vs-route test explicitly, in Hawkeye's own words/voice
- The clause doesn't contradict or soften the existing iron rule ("Hawkeye never executes domain work himself") — it clarifies the boundary, not loosens it
- Margaret regenerates the SQLite mirror after this lands, per WS-004 Tier 2 Step 6

## Updates

- 2026-07-18 06:54 (hawkeye) — created from approved retro proposal 3, assigned to Potter (framework hygiene owner). Jeff has already approved the WHAT via the retro review.
- 2026-07-18 07:30 (potter) — picked up; loaded priors by reading Hawkeye's full contract and root `AGENTS.md`'s existing iron-rule statement to make sure the new clause didn't restate or contradict either. Added a new "## The execute-vs-route boundary" section to `Team/Hawkeye - Orchestrator/AGENTS.md`, placed between Identity and Scaffold-scope-vs-team-scope. States the test explicitly ("does this require a specialist's registered domain knowledge or tools," not "can the tools technically do this"), lists concrete examples on both sides matching the task's own list (session logs, task hygiene, wikilink repair, filing, research synthesis, retro mining on the execute side; toolchain install, firmware, financial judgment, security review on the route side), and closes with an explicit non-softening statement plus a one-question test for ambiguous cases. Kept the wording harness-agnostic per GL-005 — no product names, no tool names.
- 2026-07-18 (hawkeye) — verified the actual contract diff directly before closing — correctly placed, doesn't soften the iron rule, harness-agnostic. Closing as done.

## Outcome

What shipped: `Team/Hawkeye - Orchestrator/AGENTS.md` gained an explicit "The execute-vs-route boundary" section stating the test (domain knowledge required, not tool capability) with concrete examples on both sides.

Where it lives: [[Team/Hawkeye - Orchestrator/AGENTS]]; retro corroboration in [[2026-07-18-team-retro-proposals]].

Follow-ups: none.

Lessons: the boundary was implied by two independently-correct rules colliding twice without ever being written down — worth remembering that "both rules are individually well-evidenced" doesn't mean their interaction is self-evident.

Archived deliverables: `2026-07-18-team-retro-proposals` — archived in the consolidated pass (shared across tasks 001-010, all closing together).
