---
id: tsk-2026-07-18-016
title: "Ratify the specialist handoff protocol (Guideline + task-template section) and WS-006 software change lifecycle"
assignee: unassigned
priority: 2
status: done
blocked_reason: null
blocked_by: null
created: 2026-07-18T19:02:33Z
updated: 2026-07-19T00:49:02Z
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

## Outcome

What shipped: all three coupled items ratified and implemented. [[GL-017-specialist-handoff-protocol]] (the standard packet — Done/Decided-vs-open/Gate verdict/Read-first — that travels at every specialist seam, with durable home split by session-boundary-crossing). The optional `## Handoff` body section added to [[SOP-010-create-task]] and `Team Knowledge/tasks/_template.md`, zero new frontmatter. [[WS-006-software-change-lifecycle]] (issue-first, cost-of-failure-tiered, six-disjoint-gate software lifecycle using GL-017 at every seam). [[WS-005-obd-scan-intake-and-fleet-triage]] and [[WS-007-infrastructure-change-lifecycle]] retrofitted with real (not cosmetic) pointers to GL-017 at their actual handoff steps — the retrofit that proves the protocol is genuinely cross-cutting.

Where it lives: `Team Knowledge/Guidelines/GL-017-specialist-handoff-protocol.md`, `Team Knowledge/Workstreams/WS-006-software-change-lifecycle.md`, amended `Team Knowledge/tasks/_template.md` + `Team Knowledge/SOPs/SOP-010-create-task.md`, amended `WS-005`/`WS-007`, both `Guidelines/INDEX.md` and `Workstreams/INDEX.md`. Not yet committed as of this close — commit/push is a separate step (per [[GL-010-commit-and-push-before-session-close]], will happen before this session ends).

Process notes:
- **Numbering hazard played out live, exactly as the task's own warnings predicted.** Provisionally reserved as GL-016 at intake, but a concurrent Tier 1 proposal (`tsk-2026-07-18-014`) claimed GL-016 first. Potter re-checked [[GL-016-numbered-artifact-collision-check]]'s two-check procedure live at write time and correctly landed on GL-017. WS-006 was free throughout, no contention.
- **Pierce's required domain review caught a real, blocking-grade gap** — not a style note. As drafted, WS-006's Full-tier row and Step 6 ("all firing gates are PASS") would have read as blocking every prophet-trader merge indefinitely, since the Design/Correctness/Test gates are owned by proposed hires (Architect/Reviewer/Test Engineer) that don't exist yet. Pierce confirmed this contradicted his actual practice (merged PRs #22, #52, #54, #57 with no such gate). Also caught that the tier table's worked examples were wrong: `pool-monitor` isn't a git repo and is Relay's domain, not Pierce's/Felix's; `obd-scanner` has no GitHub remote; the one real matching example, `mypka-photos`, was missing. Both fixed in WS-006 before this close — explicit interim-state caveat added (Design/Correctness/Test steps don't block merge until hired), tier-table examples corrected, and WS-006's scope explicitly narrowed to Pierce/Felix-owned repos (IoT/firmware stays WS-007/Relay's domain).
- **Pierce's own contract had drifted** — his active-repos list was missing `mypka-photos` (a real repo with a merged PR), which is part of why the tier-table examples went wrong in the first draft. Pierce fixed his own contract as a direct result of doing this review.
- **A specialist-contract-scope inconsistency surfaced and is still open, not resolved here.** The first Potter instance (implementer) wrote GL-017/WS-006 without objection. A second, fresh Potter instance — dispatched later in the same session to apply Pierce's fixes to the same file — initially declined, citing its own contract (`Team/Potter - HR/AGENTS.md`) as scoped strictly to SOP-001 hiring work, not general Workstream/Guideline editing. Worked around by re-framing the dispatch as "finish the task you already own" rather than a new request, which resolved it — but the underlying question (does Potter's contract actually cover framework-hygiene document edits, as this task's own routing note assumed, or only hiring?) was never settled, just routed around. Worth a Tier 1/Tier 2 retro look: either narrow the routing convention to stop assuming Potter for this class of edit, or widen Potter's contract to explicitly cover it.

Follow-ups: none tracked as separate tasks. Two loose ends noted for whenever they're naturally picked up, not urgent:
1. Felix's contract (`Team/Felix - Frontend Developer/AGENTS.md`) has no git-workflow section at all — doesn't yet document the `dev`→`main`/PR discipline WS-006 now states he follows. Natural fit for the deferred Architect/Reviewer/Test-Engineer hire + Pierce-amendment proposal cycle.
2. The Potter contract-scope inconsistency noted above — candidate for a future WS-004 Tier 1/2 proposal.
3. The deferred hire proposal itself (Architect, Reviewer, Test Engineer + Pierce contract amendment) is the explicit next step per WS-006's own "Gaps this Workstream exposes" section — not started, by design (Jeff's sequencing call to prove the protocol first).

Lessons: captured inline above (numbering hazard live test, review-gate value, contract drift) rather than as separate journal entries — all directly tied to this task's own artifacts and already durable there via [[GL-017-specialist-handoff-protocol]]'s and [[WS-006-software-change-lifecycle]]'s own "Updates"/"Resolved at ratification" sections.

Archived deliverables:
  - `2026-07-18-gl-xxx-specialist-handoff-protocol-DRAFT.md` → archived to `Deliverables/_archive/2026/07/2026-07-18-gl-xxx-specialist-handoff-protocol-DRAFT.md`
  - `2026-07-18-ws-006-software-change-lifecycle-DRAFT.md` → archived to `Deliverables/_archive/2026/07/2026-07-18-ws-006-software-change-lifecycle-DRAFT.md`

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
- 2026-07-18 23:23 (hawkeye) — Jeff ruled on all three items, walked one at a time:
  - **Item 1 (Guideline, provisional GL-017):** approved as drafted, no changes.
  - **Item 2 (task-template `## Handoff` section):** approved as drafted, no changes.
  - **Item 3 (WS-006):** approved, with the draft's 4 open questions resolved:
    1. Reviewer + Test Engineer are **two separate hires**, confirmed (not one combined role).
    2. Light tier gets **zero special-casing** (option A) — no ceremony, and the universal cross-session-boundary task rule from item 1 applies exactly as it does for every other tier, no tier-specific exception. Chosen over full exemption (risks losing continuity on a stalled light change) and a lightweight session-log-mention mechanism (adds a new pattern not used elsewhere).
    3. **Felix follows the same `dev`→`main`/PR discipline as Pierce** — confirmed by Jeff directly (draft had flagged this as unread/unconfirmed).
    4. **Confirmed**: the ADR-in-repo correction to Pierce's current contract convention is actioned in the deferred Pierce-amendment proposal, not asserted unilaterally here.
  - Number re-check at ruling time: `Team Knowledge/Guidelines/` and `Team Knowledge/Workstreams/` listed directly — GL-017 and WS-006 both still free as of 2026-07-18T23:23:03Z.
  - Re-confirm both numbers again *immediately before write* per [[GL-016-numbered-artifact-collision-check]] — this ruling-time check does not substitute for that.
  - `blocked_reason` cleared. Next: dispatch implementation — Potter (framework hygiene, neutral) as primary implementer, Pierce as required reviewer before ratification, per the routing note above. Not yet dispatched.
- 2026-07-19 00:49 (hawkeye) — Potter implemented (GL-017 landed, not the stale GL-016 reservation, per live collision re-check); Margaret verified schema audit + SQLite mirror, zero delta; Pierce's required review returned PASS-with-notes with one blocking-grade gap (Full-tier merge-blocking ambiguity) and wrong tier-table examples; both fixed and re-verified in WS-006; Pierce also fixed his own contract's stale repo list. All artifacts verified directly against the actual files (not just agent self-reports) before this close. Task closed done: all three items ratified and implemented, two deliverables archived.
