# WS-007 - Infrastructure Change Lifecycle

- **Type:** Workstream — a multi-agent composition.
- **Owners:** Trapper (homelab servers, end to end), Bastion (personal client devices), Sparky (network layer), Relay (device/IoT workloads), Ledger (verification), Hawkeye (routing). **Jeff (the approval gate on every irreversible change).**
- **References:** [[GL-001-file-naming-conventions]], [[GL-002-frontmatter-conventions]], [[GL-005-llm-agnostic-portable-core]], [[GL-007-verify-before-acting-on-a-finding]], [[GL-008-read-registry-before-creating-new-state]], [[GL-017-specialist-handoff-protocol]], [[SOP-010-create-task]], [[SOP-012-close-task]], [[SOP-017-read-own-journal]], [[SOP-022-deployment-fidelity-verification]], [[Team/Trapper - Homelab & Drone Engineer/AGENTS]], [[Team/Bastion - Endpoint & Systems Administrator/AGENTS]], [[Team/Sparky - Network Architect/AGENTS]], [[Team/Relay - Smart Home & IoT Engineer/AGENTS]], [[Team/Ledger - Deployment Verification Engineer/AGENTS]], [[Team/Vex - Security Engineer/AGENTS]]
- **Trigger:** Jeff requests a change to any host, endpoint, or device — or a specialist identifies one while working. Natural-language cues: a part number, a firmware version, a driver, a patch, a VM, a dataset, a new machine, "should I buy", "can I upgrade", "it's running slow", "set up X on Y".

## Purpose

Infrastructure changes are not code changes. There is no branch to abandon, no PR to close unmerged, no revert commit. A flashed BIOS, a migrated ZFS pool, and a purchased heatsink are all one-way doors. This Workstream composes the existing specialist contracts into one lifecycle so the choreography is inspectable in one place, and so the gate lands where the door is one-way.

This Workstream **documents an existing practice**. Every step below is already in a contract. Nothing here is new behavior.

## Domain ownership (the routing spine)

Read this table before routing anything. It restates no rule; each row points at the contract that owns it.

| Layer | Owner | Boundary source |
|---|---|---|
| Homelab servers — hardware through software stack | Trapper | [[Team/Trapper - Homelab & Drone Engineer/AGENTS]] |
| Personal client devices — OS, drivers, toolchain, patch, backup | Bastion | [[Team/Bastion - Endpoint & Systems Administrator/AGENTS]] |
| Network — VLANs, firewall, switching, wireless, IP schema | Sparky | [[Team/Sparky - Network Architect/AGENTS]] |
| Device/IoT workloads — firmware, HA config, Modbus | Relay | [[Team/Relay - Smart Home & IoT Engineer/AGENTS]] |
| Security policy and audit | Vex | [[Team/Vex - Security Engineer/AGENTS]] |
| Verification of deployed reality vs intent | Ledger | [[Team/Ledger - Deployment Verification Engineer/AGENTS]] |

Relay's toolchain installs (ESPHome CLI, USB-serial drivers) are the device/app layer and sit in the reversible tier below. The underlying machine-level plumbing those installs run on top of (Python venv bootstrap, PATH, the driver package itself) stays Bastion's per the existing Bastion/Relay boundary already stated in both contracts — this Workstream doesn't add a new rule here, just names where the existing one already draws the line.

### The form-factor rule

**Machine administration follows physical form factor, not current workload.**

A personal laptop running a project workload is still Bastion's to administer — OS, drivers, container engine, housekeeping — regardless of what runs on it. The specialist who owns the project owns *what runs* on the machine and the migration plan. Trapper has zero involvement until the workload migrates onto homelab hardware; at that point provisioning and architecture become his call, not before.

*Locked 2026-07-14 alongside Bastion's hire. On ratification (2026-07-18) this became the single source — [[Team/Trapper - Homelab & Drone Engineer/AGENTS]], [[Team/Bastion - Endpoint & Systems Administrator/AGENTS]], and [[Team/Relay - Smart Home & IoT Engineer/AGENTS]] all point here via `[[wikilink]]` instead of restating it, per the SSOT Golden Rule.*

## The reversibility tiers

Infrastructure tiers on **whether the door swings back**, not on cost of failure.

| Tier | Examples | Gate |
|---|---|---|
| **Reversible** | Patch pass, driver install, package update, non-destructive config change, entity rename | Registry read → change → registry update. No plan document, no approval. |
| **Irreversible / expensive** | Firmware flash, BIOS update, hardware purchase, ZFS pool migration, dataset or VM deletion, host migration, ESPHome first flash on new hardware | Written plan to `Deliverables/` → **Jeff approves** → execute → registry update → verification |
| **Cross-domain** | Anything needing another layer: a VLAN for a new host, a hardening item, a hosting requirement | Written requirement handed to the owning specialist **before** proceeding, per [[GL-017-specialist-handoff-protocol]]'s packet shape (done / decided-vs-open / gate verdict / read-first). The requesting specialist does not reach across the boundary. |

A change can be both irreversible and cross-domain. Both gates apply.

Drone builds (Trapper's domain) fit this tiering exactly — a maiden flight after a firmware or parameter change is an irreversible-tier event, gated the same as a BIOS flash. "Infrastructure" in this Workstream's name is used broadly, covering the physical-asset lifecycle Trapper, Bastion, Relay, and Sparky share, not homelab servers exclusively. Drone work stays in scope.

## Choreography

### Step 1 — Hawkeye routes

Hawkeye identifies the layer from the domain table above and routes to the owning specialist. Where a change spans layers, Hawkeye routes to the specialist who owns the *primary* change and names the downstream handoff explicitly in the brief — this cross-domain handoff follows [[GL-017-specialist-handoff-protocol]]'s packet shape even though it has no GitHub artifact to carry it: the brief itself states what's done, what's decided/open, and what the downstream specialist should read first.

If the machine is a personal laptop, the form-factor rule decides — not what the machine is currently being used for.

### Step 2 — The specialist reads before acting

Per [[GL-008-read-registry-before-creating-new-state]]:

1. Read [[SOP-017-read-own-journal]] — prior learning on this host or device class.
2. Read the host's entry in `PKM/Environment/Hosts/` (and `Services/` or `Software/` as applicable).
3. Read the relevant living document — e.g. the build log, the parts-compatibility ledger, the project record.

The registry describes intent. It is not evidence of current reality — that distinction is Ledger's whole mandate.

### Step 3 — Classify the tier

The specialist states which tier the change falls in, out loud, before proceeding. Reversible changes continue to Step 5. Irreversible changes go to Step 4. Cross-domain requirements are written and handed off before either.

**When in doubt, classify up.** A change misfiled as reversible is discovered by its consequences.

### Step 4 — Plan and approval gate (irreversible changes only)

1. Document the current state before proposing the new one — current firmware version, current parameter set, current pool layout, current part in the slot.
2. Write the plan to `Deliverables/` per the owning specialist's contract.
3. The plan states: what changes, what the impact is (downtime? running VMs? physical risk?), what the rollback path is — **or explicitly that there is none**.
4. **Jeff approves before execution.** Not after. Not in parallel.

A plan with no stated rollback path is not disqualified — many infrastructure changes genuinely have none. It is disqualified if it does not *say so*.

### Step 5 — Execute and confirm

Execute. Confirm with direct evidence, not inference: pool status, VM health, `systemctl status`, log output, the device reporting in. "It should be working" is not confirmation.

### Step 6 — Update the registry, same session

Update `PKM/Environment/Hosts/`, `Services/`, or `Software/` and the relevant living document in the same session. Per every contract in this Workstream: undocumented state does not survive a session close.

The specialist who made the change updates the registry. Ledger does not — Ledger reports discrepancies; the owning specialist closes them.

### Step 7 — Verification (conditional)

| Condition | Verification |
|---|---|
| Execution migrated between hosts | **Ledger Decommission Verification** — direct inspection of the *old* system, per [[SOP-022-deployment-fidelity-verification]]. "Should be off" is a claim, not a fact. |
| The change touched config values, scheduled jobs, or a data dependency | **Ledger Pre-deploy Fidelity Check** — note this fires *before* the change ships, not here |
| Recurring cadence, minimum monthly | **Ledger Environment Drift Audit** — independent of any single change |
| Routine reversible change | None. The registry update is the record. |

**Watch item (as of ratification, 2026-07-18):** Ledger's Environment Drift Audit method names only `PKM/Environment/Hosts/` and `Services/`; it does not currently walk `PKM/Environment/Software/`, even though Bastion registers state there. Verified directly by Ledger against the live registry (per [[GL-007-verify-before-acting-on-a-finding]]) — verdict **PASS-with-caveat**: `Software/` exists, is populated (3 entries), and none of the current entries are gate-relevant (dev-toolchain bookkeeping, not scheduled jobs or deployed config), so the gap is real as documentation but moot in practice today. Revisit if `Software/`'s scope changes to include gate-relevant state — that would make this a live gap, not a documentation one.

### Step 8 — Hawkeye closes the loop

Hawkeye reports: what changed, on which host, which tier it was, whether Jeff approved (if irreversible), what the confirmation evidence was, what the registry now says, and any verification verdict.

## Task handling

A change that will not finish in one session becomes a task per [[SOP-010-create-task]] — with the seven-array walk, including `linked_deliverables` pointing at any plan document. This is a session-crossing handoff, so the task carries the `## Handoff` section per [[GL-017-specialist-handoff-protocol]] when the change is being handed from one specialist to another mid-lifecycle (e.g. a cross-domain requirement waiting on Sparky, or a plan awaiting Jeff's approval that will be picked up in a later session). Closed per [[SOP-012-close-task]].

A durable insight — a compatibility gotcha, a driver quirk, a migration lesson — becomes a journal entry. Per WS-004 Tier 0, that is autonomous and needs no gate.

If the insight would help the whole team, it is a **Tier 1 proposal** per [[WS-004-team-retro-and-self-improvement-loop]], never a direct edit to a shared artifact.

## What this Workstream does not do

- **Does not add a design gate over any specialist.** Trapper's hardware and architecture decisions are his, gated by Jeff at the irreversible step. Bastion's baseline decisions are his. This Workstream introduces no reviewer, no architect, no approver other than Jeff.
- **Does not gate reversible work.** A driver install does not get a plan document. Adding ceremony to routine administration is how a lifecycle becomes theater and stops being followed.
- **Does not cover application code, CI/CD, or repo-shaped work.** That is the software lifecycle. Different artifacts, different gates, different tiering axis.
- **Does not cover line-voltage electrical work.** Licensed electrician territory, per Relay's contract. No specialist owns it and none should.
- **Does not restate any boundary rule.** Every boundary points at the contract that owns it. The form-factor rule is the one exception, and it is now the single source here (see above).
- **Does not replace Ledger's judgment.** Step 7 names when verification fires; the verdict rules stay in [[SOP-022-deployment-fidelity-verification]].
- **Does not purchase anything.** Every contract in scope already refuses hardware purchase without Jeff's explicit approval.

## Ratification note

This Workstream documents practice that predates it — three specialists (Trapper, Bastion, Relay) had already independently converged on the same choreography before this file existed. It was drafted outside the folder from contracts alone (no journal entries, no session-logs, no `PKM/Environment/` inspection), then corroborated where possible: a targeted Finding A check by Ledger (PASS-with-caveat, see Step 7 watch item above) and a full WS-004 Tier 2 Team Retro mining the actual run record. The retro found the corpus too thin to strongly corroborate or refute the core claim — most infrastructure hires are 1-2 weeks old and Trapper has zero real journal entries yet — but Jeff ratified anyway on 2026-07-18, judging the downside low since this Workstream adds no new capability or gate over what the contracts already do. If future infrastructure run-history contradicts a step here, amend this file rather than treating the thin-evidence history as disqualifying.

A second finding surfaced during the same reading (ADRs living in the ephemeral `Deliverables/` folder rather than a project repo) was deliberately **not** folded into this Workstream — it belongs to the software lifecycle (a separate proposal) and is recorded in the originating task, not here.
