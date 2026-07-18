---
id: tsk-2026-07-18-001
title: "Ratify WS-007 Infrastructure Change Lifecycle and act on two adjacent findings"
assignee: potter
priority: 3
status: done
blocked_reason: null
blocked_by: null
created: 2026-07-18T06:32:02Z
updated: 2026-07-18T10:56:37Z
due: null
created_by: hawkeye
source: external-draft-via-team-inbox
parent: null
linked_sops:
  - SOP-001-how-to-add-a-new-specialist
  - SOP-010-create-task
  - SOP-012-close-task
  - SOP-022-deployment-fidelity-verification
linked_workstreams:
  - WS-004-team-retro-and-self-improvement-loop
  - WS-005-obd-scan-intake-and-fleet-triage
linked_guidelines:
  - GL-001-file-naming-conventions
  - GL-004-task-resource-linking
  - GL-005-llm-agnostic-portable-core
  - GL-007-verify-before-acting-on-a-finding
  - GL-008-read-registry-before-creating-new-state
linked_my_life: []
linked_session_logs: []
linked_journal_entries: []
linked_deliverables:
  - 2026-07-18-ws-007-infrastructure-change-lifecycle-DRAFT
  - 2026-07-18-team-retro-proposals
tags: [workstream, proposal, infrastructure, ws-004-tier-1, human-gated]
---

# Ratify WS-007 Infrastructure Change Lifecycle and act on two adjacent findings

## What this is

A WS-004 **Tier 1 proposal**. It proposes three things and changes nothing:

1. **Ratify a new Workstream, WS-007**, documenting the infrastructure change lifecycle that already operates implicitly across Trapper's, Bastion's, Sparky's, Relay's, and Ledger's contracts.
2. **Finding A** — Ledger's Environment Drift Audit may not walk `PKM/Environment/Software/`.
3. **Finding B** — ADRs are currently written to `Deliverables/`, which the scaffold defines as ephemeral.

The draft Workstream is attached as a deliverable. It is marked `DRAFT — NOT RATIFIED` and must not be moved into `Team Knowledge/Workstreams/` until Jeff approves the WHAT and a named implementer writes the real file. Per WS-004's hard invariant, there is no path from this task to a framework change that does not pass through Jeff.

## Provenance and its limits

This draft was produced by an assistant in a chat session outside the folder, reading the scaffold through a Drive connector. It read: `agent-index`, and the full contracts for Pierce, Relay, Trapper, Bastion, Ledger, Vera. It read: SOP-001, SOP-010, GL-004, GL-005, WS-004, WS-005.

**It did not read** any `Team/*/journal/` entry, any `session-logs/` entry, any file under `PKM/Environment/`, Sparky's contract, Vex's contract, Klinger's contract, Margaret's contract, or Hawkeye's contract.

This matters for how much weight the proposal should carry. WS-004 Tier 2 mines the actual run record; Ledger exists because six real incidents were clustered from it. This proposal is reasoned from contracts alone. **It is a hypothesis about where the gaps are, not evidence of where they are.**

**Recommendation: run a Tier 2 Team Retro before or alongside acting on this.** If the retro independently surfaces the same patterns from the journals and session-logs, that is corroboration from better evidence. If it surfaces different ones, prefer the retro's findings over this document's.

## The pattern and its evidence

**Infrastructure work has a lifecycle. It is real, it is followed, and it is written down nowhere.**

Evidence, by contract:

| Step | Where it currently lives |
|---|---|
| Read the registry before creating state | GL-008; restated in Trapper §Method, Bastion §Method, Relay §toolchain |
| Plan before irreversible change | Trapper §Method — firmware flashes, destructive Proxmox changes, hardware purchases |
| Jeff approves before execution | Trapper §Method steps 3/5, §Hard rules; Bastion §Scope boundaries |
| Execute and confirm | Trapper §Method, Bastion §Method |
| Update the registry, same session | Trapper §Method 5, Bastion §Method 4, Relay §toolchain 3 |
| Verify reality against intent | Ledger §Method 3 — Environment Drift Audit |
| Domain handoffs | Trapper↔Sparky, Trapper↔Bastion, Relay↔Bastion, Relay↔Trapper, Bastion↔Vex |

Seven steps, five specialists, zero Workstreams. The choreography is inferable only by reading five contracts side by side.

Compare WS-005: it added no capability. Pierce's tooling and Rizzo's triage already existed. What WS-005 added was the *composition* — one artifact showing the handoff, the file conventions, and an explicit boundary section. WS-007 is the same move for infrastructure.

**The form-factor rule is the proof this is worth doing.** The Trapper/Bastion boundary — *machine administration follows physical form factor, not current workload* — is stated in three contracts (Trapper, Bastion, Relay), with a lock date of 2026-07-14, with no drift between the three statements. That rule was expensive to get right. It currently survives only because three contracts happen to agree. A Workstream is where a rule like that should live once, with the contracts pointing at it.

## What WS-007 deliberately does NOT do

Stated here because it is the most likely way this proposal goes wrong:

- **It does not add a design-review gate over Trapper.** Trapper's decisions are already human-gated at the irreversible step: hardware purchases, firmware flashes, and destructive Proxmox changes all require a Deliverable and Jeff's approval *before execution*. That is a real gate. Adding an architect over it would be exactly the "lifecycle theater" the scaffold warns against, and would dilute a parts-compatibility ledger built from hard-won hardware knowledge.
- **It does not gate Bastion's routine work.** Read registry → change → update registry is correct for installing a driver. A patch pass does not need a plan document.
- **It does not touch the software lifecycle.** That is a separate proposal (WS-006), deliberately not bundled here.
- **It does not move any hires.** No specialist is added, removed, or rescoped by this proposal.

## The tiering axis (the one novel claim)

The software side tiers on *cost of failure*. Infrastructure tiers on a different axis: **reversibility**.

| Tier | Trigger | Gate |
|---|---|---|
| Reversible | Patch pass, driver install, package update, non-destructive config | Registry read → change → registry update. No plan document. |
| Irreversible / expensive | Firmware flash, hardware purchase, ZFS pool migration, VM/dataset deletion, host migration | Written plan to `Deliverables/` → **Jeff approves** → execute → registry update |
| Cross-domain | Any change requiring another specialist's layer (network, security policy, hosting) | Written requirement handed to the owning specialist before proceeding |

This is not invented. It is what Trapper's and Bastion's contracts already do. WS-007 names the axis so future specialists inherit it instead of re-deriving it.

## Finding A — Ledger's Drift Audit may not cover `PKM/Environment/Software/`

Ledger §Method 3 step 1 walks `PKM/Environment/Hosts/` and `PKM/Environment/Services/`.

Bastion §Where Bastion writes names `PKM/Environment/Hosts/` **and `PKM/Environment/Software/`**.

`Software/` appears in no step of the Drift Audit. If Bastion registers software state there, that state may sit outside the audit's walk.

**Status: unverified.** Per GL-007, this is a finding to check, not a fact to act on. Nobody has inspected `PKM/Environment/` to confirm `Software/` exists, is populated, or contains anything gate-relevant. It may be empty, or the omission may be deliberate.

**Proposed action:** Ledger checks directly and reports. If the gap is real, the fix is a one-line amendment to Ledger's contract — a separate Tier 1 proposal, not folded into this one.

## Finding B — ADRs live in an ephemeral folder

Pierce §Deliverable structure writes architecture decision records to `Deliverables/YYYY-MM-DD-<project>-adr-<slug>.md`.

The scaffold defines `Deliverables/` as *"work-in-progress and finished artifacts… Time-stamped, ephemeral, the team's working surface."* GL-004's archive-on-close rule then moves every deliverable in `linked_deliverables` to `Deliverables/_archive/YYYY/MM/` when its owning task closes.

An architecture decision is not ephemeral. It is the durable record of *why the system is shaped this way*, and its natural readers are people reading the code six months later. Archiving it on task close puts it in the wrong place for its actual lifetime.

**Proposed action:** ADRs move into the project repo (e.g. `docs/design/`), versioned and branched with the code they govern. This is an amendment to Pierce's contract and belongs to the software lifecycle (WS-006), **not to WS-007.** It is recorded here only because it surfaced during this reading and should not be lost.

**This finding is independent of every hire and every Workstream.** It can be actioned on its own.

## Context one click away

- Governing procedure: [[WS-004-team-retro-and-self-improvement-loop]] — this is a Tier 1 proposal under its hard invariant
- Structural template: [[WS-005-obd-scan-intake-and-fleet-triage]]
- Task procedure: [[SOP-010-create-task]], [[SOP-012-close-task]]
- Hiring procedure (if a gap is later approved): [[SOP-001-how-to-add-a-new-specialist]]
- Constraint (portable core): [[GL-005-llm-agnostic-portable-core]]
- Constraint (one-way linking): [[GL-004-task-resource-linking]]
- Constraint (verify findings): [[GL-007-verify-before-acting-on-a-finding]]
- Constraint (registry first): [[GL-008-read-registry-before-creating-new-state]]
- Verification gate referenced by the draft: [[SOP-022-deployment-fidelity-verification]]
- Working artifacts:
  - [[2026-07-18-ws-007-infrastructure-change-lifecycle-DRAFT]]
  - [[2026-07-18-team-retro-proposals]]

## Routing note

Per WS-004 Tier 1 step 3, Hawkeye routes and Jeff approves the WHAT before anything is written.

Implementer candidates for the ratified WS-007, for Jeff to choose between:

- **Trapper** — owns the largest share of the lifecycle; closest to the material
- **Bastion** — owns the other half; newest contract, so most likely to spot where the draft misreads current practice
- **Potter** — owns framework hygiene via SOP-001 and has no domain stake, so least likely to write the Workstream around his own preferences

No recommendation offered. The choice affects whose blind spots end up in the file.

## Success criteria

- Jeff has approved, rejected, or amended **each of the three items separately** — they are independent and should not be ratified as a bundle
- If WS-007 is approved: a named implementer writes the real file to `Team Knowledge/Workstreams/`, the draft's DRAFT banner is removed, and the contracts of participating specialists gain a `[[wikilink]]` to it rather than a restatement of it
- If WS-007 is approved: the form-factor rule lives in WS-007, and Trapper's / Bastion's / Relay's contracts point at it instead of each restating it
- Finding A: Ledger has directly inspected `PKM/Environment/` and reported PASS / FAIL / UNVERIFIED
- Finding B: routed to the software lifecycle proposal, or actioned standalone against Pierce's contract
- Margaret regenerates the SQLite mirror after any landed change, per WS-004 Tier 2 step 6
- Hawkeye session-logs the outcome

## Updates

- 2026-07-18 06:32 (hawkeye) — created as external draft, placed in Team Inbox for Hawkeye intake. Duplicate check clean (no existing task references WS-007 or "infrastructure change lifecycle"). GL-005 re-checked directly (grepped both source files for harness names) — confirmed clean, no harness named. Draft renamed with date prefix and moved to `Deliverables/2026-07-18-ws-007-infrastructure-change-lifecycle-DRAFT.md`. `linked_session_logs` left empty pending this session's session-log write at close.
- 2026-07-18 (jeff) — approved moving forward "appropriately" on the three items. Jeff's two explicit calls: (1) run the Tier 2 Team Retro before ratifying WS-007, per the proposal's own recommendation; (2) if WS-007 is approved, **Potter** writes the real file (chosen over Trapper/Bastion — no domain stake, least likely to write the Workstream around his own preferences).
- 2026-07-18 (hawkeye) — routed Finding A to Ledger for direct verification per GL-007. **Verdict: PASS.** Ledger confirmed the Drift Audit method (contract + SOP-022) names only `Hosts/` and `Services/`, confirmed `PKM/Environment/Software/` exists and is populated (3 files — `claude-code.md`, `esphome-cli.md`, `token-dashboard.md`), and confirmed Bastion's contract does write there. Verdict is PASS-with-caveat: the gap is real as documentation but moot today because none of the three current `Software/` entries are gate-relevant (dev-toolchain bookkeeping, not scheduled jobs or deployed config). Flagged as "moot now, revisit if `Software/`'s scope changes" rather than a closed non-issue. No files edited.
- 2026-07-18 (hawkeye) — ran the WS-004 Tier 2 Team Retro per Jeff's approval. Mined all 17 non-template journal entries and all 64 session logs. Ranked proposal doc: [[2026-07-18-team-retro-proposals]]. Headline verdict on WS-007 itself: the corpus does not contain enough infrastructure-choreography run-history to strongly corroborate or refute WS-007's core claim (Trapper — the specialist who'd own the largest share of the lifecycle — has zero real journal entries yet; most infra hires are 1-2 weeks old). The one piece of direct, dated corroboration: Ledger's Drift Audit cadence was flagged as unscheduled on 2026-07-10 and remains unscheduled today — exactly the gap WS-007's own draft Step 7 already proposes to close. Finding B (ADRs in ephemeral `Deliverables/`) has no corroborating evidence anywhere in the corpus — it remains a hypothesis from contract-reading only, not a run-record finding. Awaiting Jeff's review of the ranked list (WS-004 Step 4) before anything in it or in WS-007 gets written.
- 2026-07-18 (jeff) — reviewed the retro's ranked list and ruled on WS-007 directly: **ratify now anyway**, despite the thin infra run-history, since the draft documents existing practice and adds no new capability or gate — accepted the low-downside argument over waiting for more evidence. Assignee updated to **potter** (chosen earlier over Trapper/Bastion). All 8 retro proposals also approved in the same review — see their own tasks (tsk-2026-07-18-002 through 010) and [[2026-07-18-team-retro-proposals]] for the full record. `blocked_reason` cleared — the human gate (WS-004 Tier 1 step 3 / Tier 2 step 4) is satisfied; Potter is now clear to write the real file.
- 2026-07-18 07:30 (potter) — picked up; loaded priors by reading the draft in full (`Deliverables/2026-07-18-ws-007-infrastructure-change-lifecycle-DRAFT.md`), Hawkeye's contract (not touched by this task), and Trapper's/Bastion's/Relay's contracts for the current form-factor-rule restatements. Wrote the real file to `Team Knowledge/Workstreams/WS-007-infrastructure-change-lifecycle.md` (DRAFT banner removed, provenance-limits note kept as an internal Ratification note rather than deleted, since it's useful context for future readers). Resolved all four "Open questions for ratification" as implementer rather than carrying them forward as blockers: (1) Software walk gap — resolved, cited Ledger's 2026-07-18 PASS-with-caveat verdict already on this task, flagged as a revisit-if-Software's-scope-changes watch item inside the Workstream's Step 7 table rather than an open question; (2) form-factor rule migration — resolved yes, per this task's own instruction; WS-007 is now the single source, Trapper/Bastion/Relay all repointed to a `[[WS-007-infrastructure-change-lifecycle]]` wikilink; (3) Relay's toolchain boundary — resolved by adding one clarifying sentence under Domain ownership (Relay's device/app-layer work is the reversible tier; the underlying laptop toolchain plumbing stays Bastion's per the existing Bastion/Relay boundary — no new rule needed, just stated once here); (4) drone-work naming — resolved to keep drone builds in scope (they fit the reversibility tiering exactly per Trapper's contract) and added a one-line scope note rather than renaming the Workstream. Updated `Team Knowledge/Workstreams/INDEX.md` with the new WS-007 row. Edited Trapper's, Bastion's, and Relay's contracts to replace their inline form-factor-rule restatements with a `[[WS-007-infrastructure-change-lifecycle]]` wikilink — verified no other content in those three contracts was touched.
- 2026-07-18 (hawkeye) — Potter's session hit a usage limit right after this line was written; verified the actual `WS-007-infrastructure-change-lifecycle.md` file, the Workstreams INDEX row, and all three contract diffs directly before closing — all four correct and cleanly scoped, nothing else disturbed in any contract. Closing as done.

## Outcome

What shipped: WS-007 (Infrastructure Change Lifecycle) ratified and written to `Team Knowledge/Workstreams/WS-007-infrastructure-change-lifecycle.md`, replacing the Team Inbox draft. The form-factor rule (machine administration follows physical form factor, not workload) is now single-sourced there; Trapper's, Bastion's, and Relay's contracts point at it via `[[wikilink]]` instead of each restating it. Finding A resolved PASS-with-caveat (Ledger verified `PKM/Environment/Software/` exists, is populated, isn't currently gate-relevant — recorded as a watch item in WS-007's Step 7). Finding B (ADRs in ephemeral `Deliverables/`) deliberately left unfolded into WS-007 — it belongs to a future software-lifecycle proposal (WS-006) and isn't lost, just not actioned here.

Where it lives: [[WS-007-infrastructure-change-lifecycle]]; index row in [[Team Knowledge/Workstreams/INDEX]]; retro corroboration in [[2026-07-18-team-retro-proposals]].

Follow-ups: none spun out as separate tasks — Finding B stays recorded in this task's body for whenever the software-lifecycle proposal is drafted.

Lessons: the retro's honest verdict — thin infra run-history doesn't disqualify a low-downside ratification — is worth remembering next time a proposal's evidence base looks thinner than its stakes.

Archived deliverables: see this task's Updates for the shared-deliverable note; both `2026-07-18-ws-007-infrastructure-change-lifecycle-DRAFT` and `2026-07-18-team-retro-proposals` archive in the consolidated pass covering tasks 001-010 together (the retro doc is referenced by all ten).
