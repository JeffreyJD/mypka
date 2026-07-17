---
# Identity
id: tsk-2026-07-17-005
title: "Formal Blake evaluation: should cross_sectional_momentum trade through event-driven regime windows"

# Ownership & priority
assignee: blake
priority: 3

# Status (mirrors folder location)
status: open
blocked_reason: null
blocked_by: null

# Time
created: 2026-07-17T09:54:00Z
updated: 2026-07-17T09:54:00Z
due: null

# Provenance
created_by: pierce
source: session
parent: null

# Cross-references — REQUIRED, even if empty array. Seven slots. The act of filling these is the whole point.
linked_sops: ["SOP-010-create-task", "SOP-012-close-task"]
linked_workstreams: []
linked_guidelines: []
linked_my_life: []
linked_session_logs: []
linked_journal_entries: []
linked_deliverables: ["2026-07-08-strategy-autopsy"]

# Tagging
tags: ["prophet-trader", "cross-sectional-momentum", "regime-gating", "phase-gate", "clock-reset"]
---

# Formal Blake evaluation: should cross_sectional_momentum trade through event-driven regime windows

## What this is

Flagged as recommendation 4 in Blake's 2026-07-08 autopsy ([[2026-07-08-strategy-autopsy]]): `event-driven` regime gates both active strategies unconditionally (any FOMC/CPI/NFP/PPI/GDP/CB event within 48 hours), which the autopsy estimates removes roughly 20-30% of trading days. This is intentional, code-implemented design, but was never documented in the IPS's regime taxonomy (Section 5.1 lists only `trending-bull`/`range-bound`/`volatile-uncertain`/`capitulation`) and its trade-frequency cost was never quantified before being accepted.

The open question: should `cross_sectional_momentum` — which already tolerates the broader `range-bound` regime — also be permitted to trade through `event-driven` windows? This is explicitly a strategy-design decision requiring Blake's own written evaluation, separate from the autopsy that surfaced it, because changing the permitted-regime list is a parameter change under IPS 6.3/7.7 and would reset `cross_sectional_momentum`'s 90-day Phase 2 clock (currently `next_review: 2026-08-22`). The tradeoff must be made explicit to Jeff before any change, per the autopsy's own recommendation.

## Context one click away

- Working artifacts: [[2026-07-08-strategy-autopsy]] — recommendation 4, source of this task
- Related research (base-rate frequency input for this decision): [[tsk-2026-07-17-009-bj-base-rate-research-trending-bull-event-blackout]]
- IPS: [[PKM/Documents/prophet-trader/investment-policy-statement]] Sections 5.1 (regime taxonomy), 6.3 and 7.7 (parameter-change clock reset)
- Service: [[prophet-trader]]

## Success criteria

- [ ] Written evaluation brief from Blake, in the standard Deliverable structure, weighing: expected trade-frequency gain vs. the 90-day clock-reset cost, and whether `event-driven` should also be formally documented in the IPS's Section 5.1 regime taxonomy regardless of the outcome (it exists and gates trades today either way).
- [ ] Explicit go/no-go recommendation to Jeff, not a passive "here are the tradeoffs."
- [ ] If B.J.'s base-rate research ([[tsk-2026-07-17-009-bj-base-rate-research-trending-bull-event-blackout]]) is available, incorporate its evidence-based frequency numbers rather than the autopsy's anecdotal 20-30% estimate.
- [ ] Does not change any config until Jeff explicitly approves — this task produces the recommendation, not the change itself.

## Updates

- 2026-07-17 09:54 (pierce) — created while building the consolidated GitHub Issues backlog per Jeff's directive, formalizing Blake's autopsy recommendation 4 into a tracked task.
- 2026-07-17 (pierce) — Jeff clarified the GitHub Issues backlog is for bugs/enhancements only, not open decision questions. This is a decision/evaluation for Blake, so it stays myPKA-task-only — no GitHub issue filed. Once Blake decides and it becomes concrete config/code work, that becomes its own new issue at that time.

## Outcome

_(filled when status flips to done — see SOP-012-close-task)_
