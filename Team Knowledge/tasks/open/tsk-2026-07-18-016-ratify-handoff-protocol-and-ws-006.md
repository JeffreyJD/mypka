---
id: tsk-2026-07-18-016
title: "Ratify the specialist handoff protocol (Guideline + task-template section) and WS-006 software change lifecycle"
assignee: unassigned
priority: 2
status: open
blocked_reason: awaiting user approval of the WHAT per WS-004 Tier 1
blocked_by: null
created: 2026-07-18T19:02:33Z
updated: 2026-07-18T19:02:33Z
due: null
created_by: hawkeye
source: external-draft-via-team-inbox
parent: null
linked_sops:
  - SOP-001-how-to-add-a-new-specialist
  - SOP-010-create-task
  - SOP-012-close-task
  - SOP-013-rebuild-task-index
  - SOP-022-deployment-fidelity-verification
linked_workstreams:
  - WS-004-team-retro-and-self-improvement-loop
  - WS-005-obd-scan-intake-and-fleet-triage
  - WS-007-infrastructure-change-lifecycle
linked_guidelines:
  - GL-001-file-naming-conventions
  - GL-004-task-resource-linking
  - GL-005-llm-agnostic-portable-core
linked_my_life: []
linked_session_logs:
  - 2026-07-18-11-27_hawkeye_ws-007-intake-and-tier2-team-retro
linked_journal_entries: []
linked_deliverables:
  - 2026-07-18-gl-xxx-specialist-handoff-protocol-DRAFT
  - 2026-07-18-ws-006-software-change-lifecycle-DRAFT
tags: [workstream, guideline, proposal, handoff, sdlc, ws-004-tier-1, human-gated]
---

# Ratify the specialist handoff protocol and WS-006 software change lifecycle

## What this is

A WS-004 **Tier 1 proposal**. It proposes three coupled framework additions and changes nothing until Jeff approves each:

1. **A new Guideline** — `GL-XXX-specialist-handoff-protocol` (provisional number **superseded already**: reserved as GL-016 at intake time 2026-07-18T19:02:33Z, but `tsk-2026-07-18-014`'s implementation claimed GL-016 for itself before this proposal could be ratified — see [[GL-016-numbered-artifact-collision-check]]. Next free slot as of that landing is **GL-017**, per `Team Knowledge/Guidelines/INDEX.md`. **Re-confirm again at actual write time regardless** — this is now a live, first-hand demonstration of exactly the hazard this proposal itself warns about, and per [[GL-016-numbered-artifact-collision-check]]'s own new rule, the implementer must run its two-check procedure rather than trust any number recorded here): the standard packet that travels when work moves across a specialist seam, with the rule that the packet's durable home is the GitHub PR/issue and a myPKA task is created only when a handoff crosses a session boundary.
2. **A one-section amendment to the task template** (`Team Knowledge/tasks/_template.md`) and [[SOP-010-create-task]] — an **optional** `## Handoff` body section carrying decided-vs-open + gate verdict. **Zero new frontmatter fields**, so the schema audit, SQLite mirror, and [[SOP-013-rebuild-task-index]] are untouched.
3. **A new Workstream** — `WS-006-software-change-lifecycle` (confirmed free at intake — no `WS-006-*.md` exists in `Team Knowledge/Workstreams/` as of this reading): the ordered, GitHub-issue-originated, cost-of-failure-tiered sequence from requirement to deploy, using the handoff protocol at each seam.

The two drafts are attached as deliverables, both marked `DRAFT — NOT RATIFIED`. Nothing moves into `Team Knowledge/Guidelines/` or `Team Knowledge/Workstreams/` until Jeff approves and a named implementer writes the real files.

## Goal in one line

Make the team's handoffs on backlog work **fast, smooth, and context-complete** while keeping **human-in-loop dispatch** — Jeff still dispatches and approves irreversible steps; the protocol removes the friction of re-briefing at each seam, not the human from the seam. An automation layer (n8n) is explicitly **deferred** to a later, separate proposal.

## Why these three are one package

They are the minimum coherent unit: the Guideline is the rule, the template section is where the rule is enacted for cross-session handoffs, and WS-006 is the first Workstream that uses both. WS-006 proves the Guideline is shaped right; the Guideline is what makes WS-006's seams work. Splitting them would ratify a rule with nothing using it, or a lifecycle with an unspecified handoff.

## What is deliberately NOT in this package

- **The three hires** (Architect, Reviewer, Test Engineer) and the Pierce contract amendment. WS-006 *exposes* these as gaps but does not hire them. They are a separate Tier 1 proposal through Potter/SOP-001, held back so this package — the reusable protocol — gets scrutinized on its own before a roster change rides on it. This was Jeff's explicit sequencing call.
- **Any automation/n8n layer.** Deferred by design. The handoff protocol must be proven by hand first; automating an unproven protocol just runs the friction faster.

## Provenance and its limits

Drafted by an assistant outside the folder via a read-only Drive connector. It read directly: agent-index; the full contracts for Pierce, Blake, Vex, Ledger, Vera, Relay, Trapper, Bastion; SOP-001, SOP-010, GL-004, GL-005, GL-007, GL-014, GL-015, WS-004, WS-005, WS-007, and both ratified SOP-022 sections.

It did **not** read: Felix's contract (flagged as WS-006 open question 3), Hawkeye's, Potter's, Margaret's, or Klinger's contracts; the raw `_template.md` file (worked from SOP-010's authoritative schema instead — the search tool could not surface the template file by title); any journal or session-log beyond the retro cycle.

Per WS-004, this is reasoned largely from **contract text plus one design conversation**, not from a mined run record. Treat it as a well-formed hypothesis. **A Tier 2 retro pass would strengthen or correct it** — in particular, whether the handoff friction this solves is the friction the team actually hits.

## The numbering hazard applies to this drop directly

This package creates **two numbered artifacts** (`GL-XXX`, `WS-006`) plus possibly renumbering if `WS-006` is already taken. This is the exact condition that produced the GL-014/GL-015 collision in the last cycle. **Before writing the real files, the implementer must reserve both numbers and confirm they're free** — and if the team is dispatching the Guideline and the Workstream to two different agents in parallel, serialize the number reservation. This proposal should not be the second live test of that unresolved hazard.

**Live status as of intake:** `tsk-2026-07-18-014` (WS-004 Tier 1 proposal to formalize a mandatory pre-commit collision check, Jeff already chose option (b)) is being implemented concurrently by Potter right now. If that work creates a new Guideline, the GL number this proposal provisionally reserved (GL-016) may already be taken by the time this proposal is implemented. Whoever implements this proposal must re-check `Team Knowledge/Guidelines/` immediately before writing — do not trust the number recorded above.

## Context one click away

- Governing procedure: [[WS-004-team-retro-and-self-improvement-loop]]
- Structural templates: [[WS-005-obd-scan-intake-and-fleet-triage]], [[WS-007-infrastructure-change-lifecycle]]
- Task procedure being amended: [[SOP-010-create-task]]
- Index rebuild (unaffected, but confirm): [[SOP-013-rebuild-task-index]]
- Linking rule the amendment respects: [[GL-004-task-resource-linking]]
- Portability constraint: [[GL-005-llm-agnostic-portable-core]]
- Hiring path for the deferred roles: [[SOP-001-how-to-add-a-new-specialist]]
- Related concurrent work: [[tsk-2026-07-18-014-numbered-artifact-collision-rule]]
- Working artifacts:
  - [[2026-07-18-gl-xxx-specialist-handoff-protocol-DRAFT]]
  - [[2026-07-18-ws-006-software-change-lifecycle-DRAFT]]

## Routing note

Hawkeye routes; Jeff approves the WHAT before anything is written. Implementer candidates:

- **Potter** — framework hygiene, no domain stake; natural owner for a cross-cutting Guideline + a Workstream that will spawn hires he'll later run.
- **Pierce** — owns the software domain WS-006 describes; best placed to catch where the lifecycle misreads current dev practice. But he's also the contract being carved by the *deferred* proposal, so there's a mild conflict-of-interest in having him author the Workstream that justifies carving him.

Leaning Potter for neutrality, with Pierce as required reviewer before ratification.

## Success criteria

- Jeff has approved / amended / rejected **each of the three items separately** — they're coupled but not a forced bundle
- If approved: numbers reserved and collision-checked *immediately before writing* (not just at intake); real files land in `Guidelines/` and `Workstreams/`; the task-template amendment lands in `_template.md` and SOP-010; DRAFT banners removed
- The `## Handoff` section is confirmed **optional** and **frontmatter-free** — Margaret verifies the schema audit and SQLite mirror still pass unchanged
- On ratification, [[WS-005-obd-scan-intake-and-fleet-triage]] and [[WS-007-infrastructure-change-lifecycle]] are updated to point at the new Guideline at their handoff steps (the retrofit that proves it's cross-cutting)
- WS-006 open questions 1–4 resolved (esp. Felix's contract read, and ADR-in-repo confirmed as belonging to the deferred Pierce amendment)
- The deferred hire proposal is noted as the explicit next step
- Hawkeye session-logs the outcome; Margaret regenerates the mirror after any landed change

## Updates

- 2026-07-18 19:02 (hawkeye) — created as external draft, placed in Team Inbox for Hawkeye intake. Duplicate check clean. GL-005 re-checked directly (grepped all three source files for harness names) — confirmed clean. Numbers reserved sequentially per the drop's own warning: GL-016 provisional (Guidelines dir listed directly), WS-006 confirmed free (Workstreams dir listed directly) — both done as one sequential check, not split across parallel agents. Flagged the live concurrency risk with `tsk-2026-07-18-014` (Potter's collision-check implementation, running right now) explicitly in the body above. Drafts moved to `Deliverables/` with date prefixes.
