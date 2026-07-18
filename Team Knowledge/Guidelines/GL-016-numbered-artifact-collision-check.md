# GL-016 - Numbered-Artifact Collision Check

> **Read this whenever you are about to mint a new numbered artifact** — a Guideline (`GL-NNN`), an SOP (`SOP-NNN`), a Workstream (`WS-NNN`), or a task id (`tsk-YYYY-MM-DD-NNN`) — and whenever more than one agent may be creating artifacts of the same type in the same working window.

This Guideline is the single shared home for the collision-check rule. [[GL-001-file-naming-conventions]] states the numbering *pattern* (zero-padded, no gaps, no reuse without a logged retirement); this Guideline states the *procedure* that keeps two independent agents from claiming the same number before either commits. [[SOP-010-create-task]], the "How to add a new SOP/Workstream/Guideline" sections of the three `Team Knowledge/*/INDEX.md` files, and [[WS-004-team-retro-and-self-improvement-loop]] all `[[wikilink]]` here rather than restating it.

## Why this exists

"List the directory, find the next free number" is a lookup, not a lock. Two agents working in the same window — dispatched in parallel, or simply two sessions open on the same repo — can each list the same directory, each correctly see the same number as free, and each write a different file to that number before either commits. Neither agent did anything wrong; the check they ran was correct at the moment they ran it. The race lives in the gap between *checking* the number is free and *committing* the file that claims it — a gap that a single confirm-at-the-start-of-work check cannot close, because nothing stops another agent from claiming the same number in that gap.

This was not a hypothetical: on 2026-07-18, two agents dispatched in parallel each independently confirmed `GL-014` as the next free Guideline number and each wrote a different Guideline to `GL-014-*.md` before either committed. It was caught only because the coordinating agent happened to review each agent's actual file diff before the final commit — a review step that was good practice, not a required gate. This Guideline formalizes that catch into a required gate so it stops depending on someone happening to look.

## The rule

Two checks, not one. Both are required; neither substitutes for the other.

### Check 1 — Re-confirm immediately before writing, not just at the start of work

When you first pick up a task that will mint a numbered artifact, listing the directory to find the candidate number is normal and correct — but that number is only a *candidate* until the moment you actually write the file. If any time passes between that first check and the write (research, drafting, waiting on another step), re-run the same "next free number" check **immediately before you write the file**, not just once at the start.

If the number you originally saw as free is no longer free — someone else's file now occupies it — treat it as claimed. Pick the next free number and write there instead. Do not treat your earlier check as still valid; it wasn't a reservation, it was a snapshot.

For tasks specifically, [[SOP-010-create-task]] §2 already implements this half of the rule mechanically: it generates the id from a live count, and if the write fails because the file already exists (another agent claimed it in the gap), it increments and retries up to five times. That retry loop *is* Check 1 for `tsk-NNN`. GL/SOP/WS numbering has no equivalent automated retry today — the discipline has to be applied by hand: re-list the directory right before you write, don't trust a check made earlier in the same session.

### Check 2 — A required batch check before any commit that includes new numbered artifacts

Before any commit lands that includes one or more newly-created `GL-NNN`, `SOP-NNN`, or `WS-NNN` files (or, for a batch of tasks created close together, multiple new `tsk-YYYY-MM-DD-NNN` ids), run one check across the **whole batch**, not just your own file:

1. List every new file of that artifact type staged for this commit.
2. Extract the number from each filename.
3. Confirm every number is unique within the batch, **and** confirm none of them collides with a number already listed in that artifact type's index (`Guidelines/INDEX.md`, `SOPs/INDEX.md`, `Workstreams/INDEX.md`, or the live `tasks/` tree).
4. If a collision is found, renumber every colliding file but one to the next free number, update every cross-reference to the renumbered file (its own index row, any `linked_*` frontmatter, any inbound `[[wikilink]]`), and log the renumbering in that file's own "Updates" section and in the relevant index.

This check is required **regardless of who authored which file**. It does not matter whether each individual agent already ran Check 1 correctly — Check 1 only protects against a race with an agent that had *already written* by the time you re-checked. It cannot protect against an agent writing concurrently and committing before you do. Check 2 is what actually catches that: someone (a human, or whichever agent is about to run the commit) looks at the whole set of new artifacts together, not each one in isolation.

### Who runs Check 2

Whoever is about to execute the commit for the batch. In a session where one agent works alone through a queue, that's the same agent — the check is nearly free there (nothing else likely changed the index since Check 1 ran seconds earlier), but it still costs nothing to run and still catches a stale local checkout or a second session open on the same repo. In a session where a coordinating agent is folding together the output of several agents that worked in parallel, the coordinating agent runs Check 2 across the full set before the shared commit — this is exactly the situation that produced the 2026-07-18 collision, and exactly the situation Check 2 is written for.

## Two-path note

- **Where the agent runtime supports dispatching multiple agents to work in parallel:** each dispatched agent runs Check 1 for its own artifact immediately before writing. The agent that performs the final commit for the batch runs Check 2 across every artifact the parallel batch produced, before that commit — this is the gate that would have caught the 2026-07-18 collision at the moment it happened instead of after the fact.
- **Where agents work through a queue one at a time (no parallel dispatch):** Check 1 and Check 2 collapse into the same near-simultaneous moment for a single artifact, but still run both — re-confirm the number is free right before writing (Check 1), and re-scan the batch of anything not yet committed right before committing (Check 2). This also protects against the case where a second session or a human edit touched the same repo between your check and your commit.

## Applies to

- `GL-NNN` (Guidelines)
- `SOP-NNN` (SOPs)
- `WS-NNN` (Workstreams)
- `tsk-YYYY-MM-DD-NNN` (tasks) — Check 1 is already mechanized by [[SOP-010-create-task]] §2's retry loop; Check 2 (the batch-wide pre-commit pass) is the piece that SOP adds by reference to this Guideline rather than by duplicating the text.

## Common mistakes

- Treating a check made at the start of a multi-step task as still valid by the time you write the file. It is a snapshot, not a lock — re-check immediately before the write.
- Running Check 1 correctly and assuming that's sufficient. Check 1 protects against writing on top of a number someone already claimed. It does nothing against a concurrent write that lands after your check but before your commit — that's what Check 2 is for.
- Skipping Check 2 because "I already checked when I started." The whole point of Check 2 is that it runs across a batch that may include artifacts you didn't personally check.
- Running Check 2 against only the files you personally wrote, instead of the entire batch about to be committed. A parallel-dispatch collision is invisible if you only look at your own diff.
- Discovering a collision and picking a number "close enough" without updating every cross-reference to the renumbered file. A renumbered `GL-NNN` with a stale `[[wikilink]]` pointing at the old number is worse than the original collision — it's now a silent broken link instead of a loud commit-time catch.

## Updates to this Guideline

- 2026-07-18 — created (Potter), formalizing WS-004 Tier 1 proposal [[tsk-2026-07-18-014-numbered-artifact-collision-rule]] per Jeff's approval of option (b) — mandatory pre-commit collision check, over serializing numbered-artifact creation. Born from the 2026-07-18 GL-014 collision between two parallel retro-implementer agents (Bastion and Vex), caught by the coordinating agent's manual review rather than a required step.

## References

- [[GL-001-file-naming-conventions]] — the numbering pattern this Guideline's procedure protects.
- [[GL-005-llm-agnostic-portable-core]] — this Guideline names no harness; "dispatching multiple agents to work in parallel" and "agents work through a queue one at a time" are runtime-shape descriptions, not product names.
- [[SOP-010-create-task]] — implements Check 1 mechanically for `tsk-NNN` via its retry-on-exists loop.
- [[WS-004-team-retro-and-self-improvement-loop]] — Tier 2 Step 5 is where multiple named implementers land approved changes in the same window; this is where Check 2 most often applies.
