# GL-017 - Specialist Handoff Protocol

- **Type:** Guideline — a cross-cutting convention the whole team references.
- **Applies to:** every point where work moves from one specialist to another inside a Workstream, and every point where in-flight work stops for the session.
- **References:** [[SOP-010-create-task]], [[SOP-011-claim-task]], [[SOP-012-close-task]], [[GL-004-task-resource-linking]], [[GL-001-file-naming-conventions]], [[WS-005-obd-scan-intake-and-fleet-triage]], [[WS-007-infrastructure-change-lifecycle]]

## Why this exists

Handoffs between specialists are where context leaks. When Pierce finishes and work moves to a reviewer, or an architect hands a design to an implementer, the receiving specialist needs to know what was done, what was decided, what's still open, and what to read first — without the user re-briefing them. Today that packet is improvised at each seam, which is slow and drops context. This Guideline standardizes **what travels at a handoff**, so the seam carries its own context and the user stays a dispatcher rather than a relay.

This is a convention, not a procedure. It says *what a handoff must contain*. The *order* of handoffs lives in each Workstream; the *roles* live in contracts. This Guideline is the shared packet shape all of them reuse.

## The one rule

**When work moves across a specialist seam, a handoff packet travels with it. The packet's durable home depends on whether the handoff crosses a session boundary.**

| The handoff… | Packet's durable home | myPKA task? |
|---|---|---|
| Moves between specialists **within one session** | The GitHub PR description + issue thread (+ the repo ADR, if any) | **No** |
| Crosses a **session boundary** (work stops, resumes later) | A myPKA task carrying the `## Handoff` section, **plus** the GitHub artifacts | **Yes** — per [[SOP-010-create-task]] |

The GitHub PR/issue is the primary record in **both** rows for GitHub-tracked software work. The myPKA task is only the *continuity layer* — the bookmark that survives a session close. It is never a mirror of the backlog, and it is never created just because a handoff happened. It is created only when a handoff happens *and* the session is ending mid-flight.

This preserves the standing boundary: **GitHub owns dev work; myPKA owns life and continuity.** A task is a resumption point, not a shadow issue.

For a handoff that isn't GitHub-tracked (a non-software Workstream, e.g. [[WS-005-obd-scan-intake-and-fleet-triage]] or [[WS-007-infrastructure-change-lifecycle]]), the same rule applies with the durable home swapped: a within-session handoff has no separate durable artifact — the routing message and the receiving specialist's own write (a vehicle file update, a registry update) *is* the record. A handoff that crosses a session boundary still gets a myPKA task carrying the `## Handoff` section — that half of the rule is universal, not software-specific.

## What the packet contains

Whether it lands in a PR description or a task's `## Handoff` section, the packet carries four things:

1. **Done** — what the upstream specialist completed. One or two sentences.
2. **Decided vs. open** — what the upstream specialist *settled* (so the downstream one doesn't relitigate it) and what they are *consciously leaving open* for the downstream one to resolve. This is the highest-value line and the one most often dropped.
3. **Gate verdict** — if the upstream step was a gate (design, review, security, test, fidelity), its outcome: PASS / FAIL / PASS-with-notes, with a pointer to the evidence (ADR id, review notes, test run, [[SOP-022-deployment-fidelity-verification]] report). A handoff that skips a required gate verdict is incomplete.
4. **Read-first** — the one or two artifacts the downstream specialist should read before starting, in order. In a task, this is expressed by *ordering* the `## Context one click away` wikilinks, not a new field.

That's the whole packet. It deliberately adds no data that the task's seven `linked_*` arrays already carry — those still hold the full resource bundle. The packet adds only the *judgment* the arrays can't express: what was decided, what's open, and whether the gate passed.

## Where it lives in a task (the `## Handoff` section)

For cross-session handoffs, the packet is a single new **body** section in the task — no new frontmatter fields, so [[GL-004-task-resource-linking]], the schema audit, the SQLite mirror, and [[SOP-013-rebuild-task-index]] are all untouched. It sits after `## What this is`:

```markdown
## Handoff
- **From / to:** <upstream specialist> → <downstream specialist>
- **Done:** <what the upstream specialist completed>
- **Decided:** <what is settled and should not be relitigated>
- **Open:** <what the downstream specialist must resolve>
- **Gate:** <design|review|security|test|fidelity> — PASS | FAIL | PASS-with-notes → <evidence pointer>
- **Read first:** <ordered pointers, mirrored in Context one click away>
```

The section is **optional** — a task that isn't a lifecycle handoff (a one-off fix, a research task) omits it, exactly as tasks do today. It appears only when a task exists *because* work is being handed off mid-lifecycle.

## Where it lives in a within-session handoff

No task, no myPKA artifact. For GitHub-tracked software work, the packet's four elements go in the **PR description** (Done, Decided/Open, Gate verdict) and the **issue thread** (the running record). The ADR, if the change has one, is the durable design record in the repo. The downstream specialist reads the PR and issue to pick up — that *is* the handoff.

For non-software work with no GitHub artifact, the four elements travel in the routing brief itself (Hawkeye's handoff message to the receiving specialist) and the receiving specialist's own durable write (a vehicle record, a registry entry) is what survives — there is no separate packet file to maintain.

## Retrofit

[[WS-005-obd-scan-intake-and-fleet-triage]] and [[WS-007-infrastructure-change-lifecycle]] predate this protocol and had handoffs described ad hoc. Their handoff steps now point at this Guideline rather than each describing its own packet shape. This is the tell that the protocol is a cross-cutting Guideline and not a step inside any one Workstream — three Workstreams share it (these two, plus [[WS-006-software-change-lifecycle]]).

## What this Guideline does NOT do

- **Does not create a task per backlog item.** The backlog is GitHub issues. A task appears only when a handoff crosses a session. Stated twice on purpose: this is the single most likely misreading.
- **Does not add frontmatter.** The `## Handoff` section is body prose. Zero schema change.
- **Does not replace the `linked_*` arrays.** They still carry the resource bundle. The packet carries judgment, not resources.
- **Does not define any lifecycle order.** That's the Workstream's job. This is only the packet shape.
- **Does not make handoffs autonomous.** The user still dispatches. This makes the dispatch *fast* by pre-packaging context; it does not remove the human from the seam.

## Updates to this Guideline

- 2026-07-18 — created (Potter), ratifying WS-004 Tier 1 proposal [[tsk-2026-07-18-016-ratify-handoff-protocol-and-ws-006]] per Jeff's approval. Numbered GL-017 (not the provisionally-reserved GL-016) because a concurrent Tier 1 proposal (`tsk-2026-07-18-014`, the collision-check formalization itself) claimed GL-016 first — re-confirmed free via [[GL-016-numbered-artifact-collision-check]]'s two-check procedure at write time.
