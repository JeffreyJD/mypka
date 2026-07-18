---
id: tsk-2026-07-18-003
title: "Add a pre-implementation design-review mode to SOP-022 for financial-risk changes"
assignee: ledger
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
  - SOP-022-deployment-fidelity-verification
  - SOP-012-close-task
linked_workstreams:
  - WS-004-team-retro-and-self-improvement-loop
linked_guidelines: []
linked_my_life: []
linked_session_logs:
  - 2026-07-18-04-00_hawkeye_prophet-trader-daily-ops-backlog-consolidation-and-reconciliation-fix
linked_journal_entries: []
linked_deliverables:
  - 2026-07-18-team-retro-proposals
tags: [retro-proposal, ledger, sop-022, approved]
---

# Add a pre-implementation design-review mode to SOP-022 for financial-risk changes

## What this is

Retro Proposal 2 (approved by Jeff 2026-07-18). On 2026-07-18, Ledger and Blake independently reviewed Pierce's reconciliation-timing fix plan *before* any code was written and caught a dead condition and an uncovered second bucket — issues a post-hoc check would likely have missed. That session log calls this out directly as "a stronger pattern than the session's earlier norm (build first, verify after)."

Add a conditional step to SOP-022: for changes touching position sizing, reconciliation, or Phase-gate inputs, Ledger (and Blake where strategy logic is touched) review the written plan before implementation begins, not only the shipped result.

## Context one click away

- Procedure being amended: [[SOP-022-deployment-fidelity-verification]]
- Governing Workstream: [[WS-004-team-retro-and-self-improvement-loop]]
- Evidence session: [[2026-07-18-04-00_hawkeye_prophet-trader-daily-ops-backlog-consolidation-and-reconciliation-fix]]
- Working artifacts:
  - [[2026-07-18-team-retro-proposals]]

## Success criteria

- SOP-022 states a conditional pre-implementation review step for financial-risk / gate-adjacent changes, naming when it fires and who's involved (Ledger always, Blake when strategy logic is touched)
- Existing post-hoc verification steps in SOP-022 are unchanged for everything else — this doesn't become a universal gate
- Margaret regenerates the SQLite mirror after this lands, per WS-004 Tier 2 Step 6

## Updates

- 2026-07-18 06:54 (hawkeye) — created from approved retro proposal 2, assigned to Ledger.
- 2026-07-18 (ledger) — picked up alongside tsk-2026-07-18-002 (same target file). Added a "Conditional: pre-implementation plan review (financial-risk / gate-adjacent changes only)" subsection to SOP-022 §1: for changes touching position sizing, reconciliation logic, or any Phase-gate input, Ledger reads the written plan before implementation (not the shipped diff), traces each claimed condition against the actual live codebase, and Blake reviews the same plan independently in parallel if strategy logic is touched — findings go to the implementer before code is written, in addition to (not instead of) the existing post-hoc steps. Added a checklist line and a coverage-map row citing the 2026-07-18 reconciliation-timing review as the originating evidence. Logged in SOP-022's own Updates footer, wikilinked to this task.
- 2026-07-18 (hawkeye) — session hit a usage limit mid-task before Ledger could append this Updates line itself; verified the actual SOP-022 diff directly (not just trusting the agent's self-report, per this same task's own lesson) before writing it up. Substantive work confirmed complete and correct — both this task's and tsk-2026-07-18-002's changes landed in the same SOP-022 edit. Closing as done.

## Outcome

What shipped: SOP-022 §1 gained a conditional pre-implementation plan-review step for changes touching position sizing, reconciliation logic, or Phase-gate inputs — Ledger (and Blake, in parallel, when strategy logic is touched) reviews the written plan before code is written, in addition to the existing post-hoc steps. Everything outside this narrow class keeps the prior post-hoc-only norm.

Where it lives: `Team Knowledge/SOPs/SOP-022-deployment-fidelity-verification.md` §1; evidence session [[2026-07-18-04-00_hawkeye_prophet-trader-daily-ops-backlog-consolidation-and-reconciliation-fix]]; retro corroboration in [[2026-07-18-team-retro-proposals]].

Follow-ups: none.

Lessons: none new beyond what's already in SOP-022's own Updates footer — this graduates a one-off practice (build-then-verify norm broken deliberately once) into a named, repeatable step.

Archived deliverables: `2026-07-18-team-retro-proposals` — archived in the consolidated pass (shared across tasks 001-010, all closing together).
