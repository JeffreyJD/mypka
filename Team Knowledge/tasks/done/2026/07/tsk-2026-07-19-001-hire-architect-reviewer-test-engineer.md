---
# Identity
id: tsk-2026-07-19-001
title: "Hire Architect, Reviewer, Test Engineer + amend Pierce's contract to complete the WS-006 SDLC"

# Ownership & priority
assignee: potter
priority: 2

# Status (mirrors folder location)
status: done
blocked_reason: null
blocked_by: null

# Time
created: 2026-07-19T01:02:35Z
updated: 2026-07-19T02:05:43Z
due: null

# Provenance
created_by: hawkeye
source: manual
parent: tsk-2026-07-18-016

# Cross-references — REQUIRED, even if empty array. Seven slots. The act of filling these is the whole point.
linked_sops:
  - SOP-001-how-to-add-a-new-specialist
  - SOP-010-create-task
  - SOP-012-close-task
linked_workstreams:
  - WS-004-team-retro-and-self-improvement-loop
  - WS-006-software-change-lifecycle
linked_guidelines:
  - GL-001-file-naming-conventions
  - GL-009-localize-expansion-role-names
  - GL-017-specialist-handoff-protocol
linked_my_life: []
linked_session_logs: []
linked_journal_entries: []
linked_deliverables:
  - 2026-07-19-architect-hire-research
  - 2026-07-19-reviewer-hire-research
  - 2026-07-19-test-engineer-hire-research
tags: [hiring, sop-001, ws-006, sdlc, pierce-amendment, human-gated]
---

# Hire Architect, Reviewer, Test Engineer + amend Pierce's contract to complete the WS-006 SDLC

## What this is

Jeff approved the deferred follow-on proposal that [[WS-006-software-change-lifecycle]] named but deliberately did not act on: hire the three roles WS-006's own choreography exposed as gaps, and amend Pierce's contract so the roster nets clean once they exist. This is the second of the two Tier 1 proposals in the SDLC build — [[tsk-2026-07-18-016-ratify-handoff-protocol-and-ws-006]] (the protocol + lifecycle) is done; this is the roster change WS-006 said should be scrutinized separately, sequenced after the protocol was proven, per Jeff's explicit sequencing call recorded in that task.

**Three hires**, each per full [[SOP-001-how-to-add-a-new-specialist]] (B.J. research brief → name/role → AGENTS.md contract → host shim → agent-index row → Workstream update → post-hire verification checklist → Jeff's approval before anything ships):

1. **Architect** — design authority. Today Pierce makes architecture decisions *and* implements them; author and approver are the same. Carve "software architecture decisions" out of Pierce's contract into this role. Read-only design authority (produces ADRs, never writes implementation code) — same posture Vex already models for security review.
2. **Reviewer** — correctness review in fresh context, independent of the implementer. Today Pierce's contract lists "code review" for himself; Vex covers only security, Vera only visual. Nobody reviews correctness independently. Carve "code review" out of Pierce's contract into this role.
3. **Test Engineer** — adversarial integration/contract/E2E testing, trying to break the code, not confirm it works. Today this is a total vacuum — not in Pierce's contract at all beyond "verify locally," and distinct from Ledger (Ledger checks deployed reality post-merge; this role tests pre-merge). Net-new, not carved from anyone.

**One Pierce contract amendment**, bundled with the hires since it's what makes the roster net clean:
- Remove "software architecture decisions" and "code review" from Pierce's owned responsibilities (now the Architect's and Reviewer's).
- Correct the ADR location convention: Pierce's contract currently states ADRs go in `Deliverables/YYYY-MM-DD-<project>-adr-<slug>.md` (confirmed during Pierce's WS-006 review). [[WS-006-software-change-lifecycle]] already asserts ADRs belong in-repo (`docs/design/ADR-NNN.md`, versioned with the code) and explicitly deferred making that correction real to this proposal. Make it real here.
- Confirm Pierce's active-repos list and any other WS-006-adjacent assertions about his practice still hold once the amendment lands.

## Why these are one package

Same logic as the protocol/lifecycle pairing: hiring the Architect and Reviewer without carving the matching authority out of Pierce's contract leaves two people owning the same responsibility on paper. The Test Engineer has no such conflict (net-new) but ships in the same batch since B.J.'s research pass and Potter's drafting pass are more efficient run once across all three than three separate round trips.

## Numbering and naming hazards

- **No numbered artifacts (GL/SOP/WS/tsk) beyond this task itself** — hires create `Team/<Name> - <Role>/` folders and `.claude/agents/<slug>.md` shims, neither of which uses the GL-016 numbering scheme. GL-016 does not apply to name collisions; check [[Team/agent-index]] directly for name collisions instead (SOP-001 step 3).
- **Do check for name collisions** against all current specialists (Hawkeye, Potter, B.J., Radar, Klinger, Margaret, Blake, Charta, Felix, Flagg, Frank, Henry, Iris, Kellye, Bastion, Ledger, Mulcahy, Painless, Pierce, Pixel, Relay, Rizzo, Sparky, Sydney, Trapper, Tuttle, Vera, Vex, Winchester, Zale) before finalizing names for the three new hires.

## Context one click away
- Procedure: [[SOP-001-how-to-add-a-new-specialist]]
- Workstream: [[WS-006-software-change-lifecycle]]
- Guideline: [[GL-009-localize-expansion-role-names]]
- Prior work this extends: [[tsk-2026-07-18-016-ratify-handoff-protocol-and-ws-006]]
- Contract being amended: [[Team/Pierce - Senior Developer/AGENTS]]
- Working artifacts:
  - [[2026-07-19-architect-hire-research]]
  - [[2026-07-19-reviewer-hire-research]]
  - [[2026-07-19-test-engineer-hire-research]]

## Success criteria
- B.J. delivers three research briefs (Architect, Reviewer, Test Engineer), each answering SOP-001 step 2's five required questions, landing in `Deliverables/`
- Potter drafts three AGENTS.md contracts + three Claude Code shims (`.claude/agents/<slug>.md`), passing all four items of SOP-001's post-hire verification checklist (line-count floor, `journal/_template.md` present, UTF-8-no-BOM shim, no generic placeholder names)
- `Team/agent-index.md` gains three new rows
- Pierce's contract amended: architecture-decisions and code-review responsibilities removed, ADR location corrected to in-repo, active-repos list re-verified current
- [[WS-006-software-change-lifecycle]] updated to replace every "*(hire)*"/"*proposed hire*" placeholder for these three roles with real `[[wikilinks]]` to their new contracts
- Jeff has reviewed and approved every draft (contracts, shims, agent-index, Pierce amendment) before anything is treated as live, per SOP-001 step 8
- Hawkeye verifies the actual files directly (not agent self-reports) before closing this task
- Hawkeye logs the three hires in the next session log per SOP-001 step 9

## Updates
- 2026-07-19 01:02 (hawkeye) — created. Jeff approved the deferred hire proposal WS-006 named as its explicit next step. Routing to Potter to run SOP-001 for all three roles, starting with B.J.'s research pass.
- 2026-07-19 (potter) — priors loaded: none (`linked_journal_entries` empty, per SOP-017). Ran SOP-001 steps 3-7 for all three hires using B.J.'s three research briefs: named Keystone (Architect), Lens (Reviewer), Breaker (Test Engineer); no collisions against `Team/agent-index.md`. Drafted three `AGENTS.md` contracts and three `.claude/agents/<slug>.md` shims; added three rows to `Team/agent-index.md`; replaced all `*(hire)*`/`*proposed hire*` placeholders in [[WS-006-software-change-lifecycle]] with `[[wikilinks]]`, leaving the interim-state caveat and gate-firing language untouched as instructed. Amended [[Team/Pierce - Senior Developer/AGENTS]]: removed "code review" and "software architecture decisions" from his routed scope, corrected the ADR deliverable path to `docs/design/ADR-NNN.md` in-repo; active-repos list untouched (already current from prior session). Ran the mandatory post-hire verification checklist (line-count floor, `journal/_template.md`, UTF-8-no-BOM shim, no leftover generic placeholders) — all four items pass for all three hires, detailed results reported to Hawkeye. Everything here is a draft per SOP-001 step 8 — nothing is live until Jeff approves; task stays open for Hawkeye to verify files directly and close.
- 2026-07-19 (potter) — Hawkeye's direct file review found two remaining inconsistencies from the prior pass; fixed both. (1) [[Team/Pierce - Senior Developer/AGENTS]] Method step 2 still had Pierce self-authoring a "one-line design note" for shape-affecting changes — the exact trigger now owned by Keystone. Rewrote it to route to Keystone's ADR gate (Full tier always, Standard tier when shape-affecting, per [[WS-006-software-change-lifecycle]] Step 2), with Light-tier/non-shape-affecting Standard work going straight to implementation. No other Method steps renumbered or touched. (2) [[WS-006-software-change-lifecycle]] still carried its pre-hire "interim state" caveat in three places, now stale since Keystone/Lens/Breaker exist: the Full-tier table row ("held open pending hires... do not currently block merge") now states plainly that all steps fire, same as the other tiers; the "Interim state — hires not yet made" paragraph is replaced with a "Hire status" note linking all three new contracts and stating Design/Correctness/Test now block merge like every other gate, with a one-sentence past-tense historical note that the Workstream shipped before these roles existed; and the "Gaps this Workstream exposes" pointer sentence now states the gaps are closed and points at the three contracts instead of describing an absent gate. Also caught and fixed a fourth stale instance in Step 6 (Merge and deploy) carrying the same "not firing gates in practice... unchanged by this Workstream" language, which the requested re-grep would otherwise have surfaced as a leftover — updated it to point at the Rigor-tiers table and Hire-status note instead. Re-grepped WS-006 for "pending hires", "not yet made", "aren't hired", "don't currently block", "absent, not blocking", "do not currently block" — zero matches remain except the one deliberate past-tense historical sentence in the new "Hire status" note. Tier-table repo examples, choreography step order, GL-017 references, and the "Resolved at ratification" section were left untouched as instructed. Task stays open for Hawkeye to re-verify directly and route to Jeff for approval.

- 2026-07-19 (potter) — Jeff approved the full hire package: three contracts (Keystone, Lens, Breaker), three shims, the Pierce amendment, and all WS-006 updates. Final cosmetic cleanup done: removed the stale "This is the gate that today's roster is missing entirely" clause from WS-006 Step 4's Lens bullet (it described the pre-hire gap, now inaccurate). Task left open for Hawkeye to close per SOP-012.
- 2026-07-19 02:05 (hawkeye) — verified the Step 4 cleanup directly (zero grep matches for "missing entirely"). Added the three B.J. research briefs to `linked_deliverables`/`Working artifacts` — Potter's drafting pass never recorded them per GL-004. Ran SOP-012 pre-flight (no sub-tasks, no other task shares the three deliverables) and closed done: three hires live, Pierce amended, WS-006 fully de-placeholdered and internally consistent, three deliverables archived.

## Outcome

What shipped: three new specialists fully hired per [[SOP-001-how-to-add-a-new-specialist]] — **Keystone** (Architect, owns WS-006's Design gate), **Lens** (Reviewer, owns the Correctness gate), **Breaker** (Test Engineer, owns the Test gate). Each has a wiki contract, a Claude Code shim, a `journal/` folder, and a row in `Team/agent-index.md`. [[Team/Pierce - Senior Developer/AGENTS]] amended to remove "software architecture decisions" and "code review" from his scope, correct the ADR path to in-repo (`docs/design/ADR-NNN.md`), and route shape-affecting changes to Keystone instead of self-authoring a design note. [[WS-006-software-change-lifecycle]] fully de-placeholdered: every `*(hire)*` reference now points at a real contract, and the "interim state, gates don't block merge yet" caveat — accurate when WS-006 first shipped, stale the moment these three existed — is corrected across all four places it appeared (Rigor-tiers table, the caveat paragraph itself, the Gaps section, and a fourth instance in Step 6 that only surfaced on the mandated re-grep). The SDLC WS-006 describes is now fully staffed, not just designed.

Where it lives: `Team/Keystone - Architect/AGENTS.md`, `Team/Lens - Reviewer/AGENTS.md`, `Team/Breaker - Test Engineer/AGENTS.md`, `.claude/agents/keystone.md`, `.claude/agents/lens.md`, `.claude/agents/breaker.md`, amended `Team/Pierce - Senior Developer/AGENTS.md`, amended `Team Knowledge/Workstreams/WS-006-software-change-lifecycle.md`, amended `Team/agent-index.md`. B.J.'s three research briefs archived to `Deliverables/_archive/2026/07/`. Not yet committed as of this close — commit/push is a separate step per [[GL-010-commit-and-push-before-session-close]].

Process notes:
- **Two rounds of Hawkeye-caught staleness, both real, neither cosmetic-only.** First pass: Pierce's Method step 2 still self-assigned design work now owned by Keystone, and WS-006's "gates don't block merge, hires pending" caveat was left exactly backwards once the hires existed — read literally, it would have told every future reader to skip gates that had just been staffed. Second pass (Jeff's requested cleanup): one genuinely cosmetic leftover in Step 4's Lens bullet ("the gate today's roster is missing entirely"), no behavioral effect, fixed on request. Direct file verification (not trusting agent self-reports) caught both real issues before either reached Jeff.
- **B.J.'s research grounded all three contracts in named real-world practice**, not generic AI-agent tropes: Keystone models staff/principal-engineer ADR discipline (adr.github.io, Fowler), Lens models Google's documented "approve once it improves code health" review standard, Breaker models the SDET (Software Development Engineer in Test) discipline. All three contracts encode the *refusal* behaviors (scope-creep anti-patterns) as explicitly as the duties — B.J.'s research flagged "helpful scope creep" (the Architect who starts implementing, the Reviewer who never approves, the Tester who pads with redundant unit tests) as the dominant real-world failure mode across all three roles, more common than outright laziness.

Follow-ups: none tracked as separate tasks.
1. This Workstream is now live guidance — the next Full or Standard-tier PR on `prophet-trader` or `mypka-photos` is the first real exercise of the full WS-006 choreography with all gates staffed. Worth watching for friction on the first real run.
2. Felix's contract still has no git-workflow section documenting the dev→main/PR discipline WS-006 assumes he follows (flagged in the prior task, still open, still non-urgent).
3. The Potter contract-scope inconsistency flagged in the prior task (a fresh Potter instance initially declining document-editing work it later accepted when reframed) recurred in spirit but not in practice this round — every dispatch in this task was accepted without pushback, likely because each was framed explicitly as "continuing your own already-approved task." Still worth a retro look at whether Potter's contract should state framework-hygiene document editing explicitly rather than relying on reframing.

Lessons: captured inline above and in WS-006's own "Hire status" note rather than as a separate journal entry — directly tied to this task's artifacts.

Archived deliverables:
  - `2026-07-19-architect-hire-research.md` → archived to `Deliverables/_archive/2026/07/2026-07-19-architect-hire-research.md`
  - `2026-07-19-reviewer-hire-research.md` → archived to `Deliverables/_archive/2026/07/2026-07-19-reviewer-hire-research.md`
  - `2026-07-19-test-engineer-hire-research.md` → archived to `Deliverables/_archive/2026/07/2026-07-19-test-engineer-hire-research.md`
