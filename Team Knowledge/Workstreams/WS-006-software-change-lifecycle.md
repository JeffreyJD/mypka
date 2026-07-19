# WS-006 - Software Change Lifecycle

- **Type:** Workstream — a multi-agent composition.
- **Owners:** Hawkeye (routing), [[Team/Keystone - Architect/AGENTS]] (design), Pierce (implementation, Python/DevOps), Felix (implementation, frontend), [[Team/Lens - Reviewer/AGENTS]] (correctness), Vex (security review), Vera (visual/WCAG review), [[Team/Breaker - Test Engineer/AGENTS]] (adversarial testing), Ledger (deployment fidelity), Blake (phase gate, Prophet Trader only). **Jeff (approves design, and every irreversible/capital step).**
- **References:** [[GL-017-specialist-handoff-protocol]], [[GL-001-file-naming-conventions]], [[GL-005-llm-agnostic-portable-core]], [[GL-008-read-registry-before-creating-new-state]], [[SOP-010-create-task]], [[SOP-022-deployment-fidelity-verification]], [[WS-004-team-retro-and-self-improvement-loop]], [[WS-005-obd-scan-intake-and-fleet-triage]], [[WS-007-infrastructure-change-lifecycle]], and the contracts of every owner above.
- **Trigger:** **A GitHub issue is opened** in a project repo under `JeffreyJD`, or Jeff signals a software change. Natural-language cues: a feature request, a bug, a refactor, "add", "fix", "build", a traceback, a PR.

## Where a requirement starts

**For software work, a requirement always starts as a GitHub issue.** The issue is the requirement — the unit of work, the ID, the backlog entry, the thing a PR closes. myPKA does not get a mirror task per issue.

A myPKA task appears in this lifecycle **only** when a handoff crosses a session boundary (work stops mid-flight and resumes later), per [[GL-017-specialist-handoff-protocol]]. The task is the continuity layer, never the origin. This keeps one backlog (GitHub), one source of truth, and no drift between a GitHub issue and a myPKA shadow of it.

This origin rule is specific to *software*. Infrastructure work originates against the Environment registry ([[WS-007-infrastructure-change-lifecycle]]); pure life items originate as journal entries or tasks. WS-006 begins at an issue.

## Rigor tiers

Software tiers on **cost of failure** (infrastructure tiers on reversibility — a different axis, see WS-007). The tier is a property of the *repo*, and it decides which steps fire.

**Scope:** WS-006 covers Pierce/Felix-owned software repos only — the repos listed in Pierce's contract (`prophet-trader`, `mypka`, `mypka-photos`, and future additions there). IoT/firmware "software" changes (e.g. ESPHome configs, device flashing) are not this Workstream's domain even when they live in a `JeffreyJD` repo with a `.git` — that work stays under [[WS-007-infrastructure-change-lifecycle]], which already owns device/IoT work via Relay. This resolves an ambiguity the original examples below created; see the note on `pool-monitor` in the Light-tier row.

| Tier | Repo | Steps that fire |
|---|---|---|
| **Full** | `prophet-trader` (trades, real consequences) | All: issue → design → build → review → security → test → fidelity → deploy → phase gate. Every step fires, same as the other tiers' rows. |
| **Standard** | Most Pierce/Felix repos (general apps, tooling). Live example: `mypka-photos` (`JeffreyJD/mypka-photos`) — already running this exact `dev` → `main` / PR / CI workflow (merged PR #1, 34/34 tests, CI green). | issue → build → review → test → deploy. Design only if it affects system shape; security only if it touches auth/data/secrets. |
| **Light** | Low-stakes, fast-feedback Pierce/Felix repos. *No live example exists yet as of 2026-07-18* — `pool-monitor` (`C:\Users\jeff\dev\pool-monitor\`) was considered but is out of scope: it has no `.git`/GitHub remote and is Relay's domain (ESPHome/Home Assistant), not Pierce's or Felix's. Treat this row as forward-looking until a real Pierce/Felix Light-tier repo exists. | issue → build → deploy. The implementer ships; hooks format and test. No design/review/gate ceremony. |

A step that doesn't fire for a tier is *skipped cleanly*, not performed as theater. Adding a design gate to a one-line low-stakes config change is exactly the "lifecycle theater" the scaffold warns against.

**Note on `obd-scanner`:** also considered as a Standard-tier example and also rejected — it has a local `.git` but no GitHub remote configured, so it can't satisfy this Workstream's own trigger (an issue opened under `JeffreyJD`). Same treatment as `pool-monitor` above: not a live example until it's GitHub-tracked.

**Hire status:** the Architect, Reviewer, and Test Engineer are now hired — [[Team/Keystone - Architect/AGENTS]], [[Team/Lens - Reviewer/AGENTS]], and [[Team/Breaker - Test Engineer/AGENTS]], as of this proposal's ratification. Step 6's "all firing gates are PASS" now means what it says: Design, Correctness, and Test block merge exactly like every other gate in the stack. *Historical note: this Workstream shipped before these three roles existed, so task and session-log history from before ratification may reference an interim state where these gates were absent, not blocking — that state is superseded, not retroactively rewritten.*

**The Light tier gets zero special-casing on task handling.** Skipping ceremony steps (design/review/gate) is the only thing "Light" changes. The cross-session-boundary task rule in [[GL-017-specialist-handoff-protocol]] applies to a Light-tier change exactly as it does to Full or Standard — if a Light-tier change stalls mid-session, it gets a task with the `## Handoff` section like any other tier. See "Task handling" below.

## The gate stack (all disjoint)

Six independent verification perspectives, no two overlapping — verified against the contracts:

| Gate | Owner | Question | Not to be confused with |
|---|---|---|---|
| Strategy | Blake | Should we trade this? Capital risk? | Design — Blake owns *what to trade*, not *how it's built* |
| Design | [[Team/Keystone - Architect/AGENTS]] | Is this the right technical shape? | Strategy (Blake) and implementation (Pierce) |
| Correctness | [[Team/Lens - Reviewer/AGENTS]] | Does the code do what it should? | Security (Vex) and visual (Vera) |
| Security | Vex | Is it safe to ship? | Correctness and visual |
| Visual | Vera | Does the UI meet WCAG/visual bar? | Security and correctness |
| Test | [[Team/Breaker - Test Engineer/AGENTS]] | Is it adversarially tested? | Fidelity (Ledger checks *deployed* reality) |
| Fidelity | Ledger | Does deployed reality match intent? | Test (tests run pre-merge; fidelity checks post-deploy) |

Each gate feeds the one above it the way Blake already consumes Ledger's fidelity reports as phase-gate evidence — the pattern exists; this composes the rest onto it.

## Choreography

Every arrow below is a handoff governed by [[GL-017-specialist-handoff-protocol]] — the packet (Done / Decided-vs-open / Gate verdict / Read-first) travels at each seam. Within a session it lands in the PR + issue; across a session it lands in a task's `## Handoff` section.

### Step 1 — Hawkeye routes from the issue

Hawkeye reads the issue, determines the repo's tier, and routes to the first firing step. For a Prophet Trader strategy change, Blake precedes design. For a standard app feature, routing goes straight to design-or-build.

### Step 2 — Design (Full tier; Standard only if it affects system shape)

[[Team/Keystone - Architect/AGENTS]] reads the issue, produces an **ADR in the repo** (`docs/design/ADR-NNN.md`, *not* `Deliverables/` — ADRs are durable and version with the code), proposing options with tradeoffs. **Jeff approves the ADR. This is a human gate.** The Architect never writes implementation code — read-only design authority, the same posture Vex models for security.

Handoff to implementer carries: the approved ADR, what's decided (the chosen option), what's open (implementation choices left to the implementer).

### Step 3 — Build

Pierce (Python/DevOps) or Felix (frontend) implements *within* the approved design, on a `dev` branch, writing unit tests for their own code as they go. **Felix follows the same `dev` → `main` / PR discipline as Pierce** — confirmed by Jeff directly at ratification: never commit to `main`, open a PR that says *why*, merge only after CI passes and all firing gates are PASS. The implementer owns the "how" inside the Architect's "what," regardless of which of the two implements it.

Handoff to review carries: the PR, what's done, what's open (anything the implementer flags as uncertain).

### Step 4 — Review (correctness + security + visual, in parallel)

- **[[Team/Lens - Reviewer/AGENTS]]** — correctness, logic, maintainability. Fresh context; must not be the implementer.
- **Vex** — security review, *if* the change touches auth, data, secrets, or an endpoint. Vex's existing "review this PR for security" gate.
- **Vera** — visual/WCAG review, *if* the change touches UI.

Each posts its verdict to the PR per the handoff protocol. A FAIL routes back to Step 3.

### Step 5 — Test

[[Team/Breaker - Test Engineer/AGENTS]] writes and runs integration/contract/E2E tests — adversarial, trying to break it, not confirm it works. This is *before* merge and distinct from Ledger: tests prove the code does what it should; Ledger later proves what's *deployed* matches what was tested. Per Pierce's existing method step 6, any change touching config/schedule/data already must clear Ledger's Fidelity Check before merge — the Test Engineer's tests slot *before* that, not on top of it.

### Step 6 — Merge and deploy

Pierce or Felix merges to `main` only after CI passes and all firing gates are PASS. Deploy runs via GitHub Actions per Pierce's contract. No `--no-verify`, no skip flags. **"All firing gates" means all gates that fire for the repo's tier** — see the "Rigor tiers" table and the "Hire status" note above. Design, Correctness, and Test now have owners (Keystone, Lens, Breaker respectively) and block merge exactly like every other gate.

### Step 7 — Fidelity (conditional)

Per [[SOP-022-deployment-fidelity-verification]]: config/schedule/data changes and host migrations get Ledger's post-deploy check. "Should be working" is not confirmation.

### Step 8 — Phase gate (Prophet Trader only)

Blake assesses against pre-committed phase criteria, consuming Ledger's fidelity report as evidence. Pass/fail, no "mostly." Per Blake's existing contract — unchanged by this Workstream.

### Step 9 — Hawkeye closes the loop

Hawkeye reports: what shipped, which issue it closed, which gates fired and their verdicts, and any task created for continuity.

## Task handling

A change that won't finish in one session becomes a task per [[SOP-010-create-task]], carrying the `## Handoff` section from [[GL-017-specialist-handoff-protocol]]. Closed per [[SOP-012-close-task]]. This applies **regardless of tier** — Light-tier changes are not exempt from the cross-session task rule; only the ceremony steps (design/review/gate) are tier-gated, never the continuity mechanism. A durable engineering insight becomes a journal entry (Tier 0, autonomous). A lesson worth teaming becomes a Tier 1 proposal per [[WS-004-team-retro-and-self-improvement-loop]].

## What this Workstream does NOT do

- **Does not create a task per issue.** The backlog is GitHub. Tasks are cross-session continuity only.
- **Does not make handoffs autonomous.** Jeff dispatches; the protocol makes dispatch fast, not absent. (An automation layer — n8n — is explicitly deferred to a later, separate proposal.)
- **Does not cover infrastructure.** Racking, provisioning, drivers, firmware → [[WS-007-infrastructure-change-lifecycle]]. Different axis, different gates.
- **Does not give the Architect infrastructure design authority.** Software only. Trapper keeps homelab design; Blake keeps strategy design.
- **Does not put ADRs in `Deliverables/`.** They live in the repo, versioned with the code. (Corrects the current Pierce-contract convention — this correction is actioned in the deferred hire/amendment proposal below, not asserted unilaterally in this Workstream.)
- **Does not hire anyone.** The three proposed roles (Architect, Reviewer, Test Engineer) appear here as *exposed gaps*. They are a separate Tier 1 proposal routed through Potter/SOP-001, held back deliberately.

## Gaps this Workstream exposes (for the separate hire proposal)

Writing the choreography surfaced exactly three roles no current specialist owned. **These gaps are now closed** — [[Team/Keystone - Architect/AGENTS]], [[Team/Lens - Reviewer/AGENTS]], and [[Team/Breaker - Test Engineer/AGENTS]] own the Design, Correctness, and Test steps respectively; see the "Hire status" note under "Rigor tiers" above.

1. **Architect** — design authority. Today Pierce makes architecture decisions *and* implements them; author and approver are the same. (Carve "software architecture decisions" from Pierce.)
2. **Reviewer** — correctness review in fresh context. Today Pierce's contract lists "code review" for himself; Vex covers only security, Vera only visual. Nobody reviews correctness independently. (Carve "code review" from Pierce.)
3. **Test Engineer** — adversarial integration/contract/E2E testing. Today this is a vacuum — testing is not in Pierce's contract at all beyond "verify locally." (Net-new; bound against Ledger, not carved from Pierce.)

These three, plus a small amendment to Pierce's contract so the roster nets clean, are the content of the follow-on proposal.

## Resolved at ratification (2026-07-18)

Jeff ruled on the draft's four open questions when he approved this Workstream. These rulings are now settled, not open:

1. **Reviewer + Test Engineer: two hires or one?** — **Two separate hires**, confirmed, for maximum independence. Reflected above: the gate stack and the gaps list both treat Reviewer and Test Engineer as distinct roles, never a combined one.
2. **Does the Light tier need any myPKA footprint?** — **No special-casing (option A).** The Light tier skips ceremony (design/review/gate), full stop — but the universal cross-session-boundary task rule from [[GL-017-specialist-handoff-protocol]] applies to it exactly as it does to every other tier, with no tier-specific exception. Chosen over a full exemption (risks losing continuity on a stalled Light change) and a lightweight session-log-mention mechanism (would add a new pattern not used anywhere else). See "Rigor tiers" and "Task handling" above, both updated to state this explicitly.
3. **Felix's frontend implementation — same `dev`→`main`/PR discipline as Pierce?** — **Confirmed by Jeff directly.** Felix follows the identical branch/PR/CI discipline Pierce's contract already states. Reflected in Step 3 (Build) and Step 6 (Merge and deploy) above.
4. **ADR-in-repo vs. `Deliverables/`** — **Confirmed**: this correction to Pierce's current contract convention belongs to the deferred Pierce-amendment proposal (the same follow-on that hires the Architect, Reviewer, Test Engineer), not asserted unilaterally in this Workstream. No change needed here beyond restating it — see "What this Workstream does NOT do" above.
