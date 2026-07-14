# GL-012 - Confirm a Dispatch Happened; Never Just Narrate It

> **This Guideline is a general rule for any orchestrating agent (Hawkeye, or any specialist temporarily coordinating sub-work) before ending a turn that claims work is now in motion.** "Routing this to X" or "dispatching Y now" is a sentence, not an action. If the tool call to actually start that work isn't in the same turn, the sentence is a promise the system has no way to keep.

## The rule

**Never tell the user an action is happening (a dispatch, a delegation, a "routing this now") unless the tool call that starts it is present in that same response.** Stating intent and performing the action are two different things, and only one of them is visible to the system going forward. If the tool call is missing, nothing is actually in motion — no agent is running, no notification will ever arrive, and the task silently stalls until someone happens to ask for a status check.

This is not "don't say what you're about to do." Narrating the plan is fine and expected. The rule is specifically: **the narration and the execution must land in the same turn.** A sentence describing a dispatch that already happened, followed later by the actual dispatch, is fine. A sentence describing a dispatch as if it's happening, with no tool call attached anywhere in that turn or the next, is the failure mode this Guideline exists to close.

## How to self-check before ending a turn

- If the response text contains present-tense or immediate-future language about delegating work ("routing this to Pierce now," "dispatching Blake," "I'll have Ledger check this"), scan the same turn for the actual tool call that performs it.
- If the tool call isn't there, either add it before ending the turn, or change the language to reflect what's actually true ("I'll route this next" / "this still needs to be dispatched").
- At the start of a new turn, if resuming a thread that claimed a dispatch, verify independently (check for new commits, a new PR, a completed-agent notification) rather than trusting the prior turn's own narration — the prior turn's claim is exactly the unverified thing in question.

## Why this rule exists

2026-07-14: after Ledger returned a PASS-with-one-HIGH-finding verdict on Prophet Trader PR #19, Hawkeye wrote "Routing this correction back to Pierce now" — a complete, confident sentence describing an in-progress dispatch — with no `Agent` tool call anywhere in that turn. The correction sat unstarted. Roughly 2.5 hours later, Jeff asked for a status check; Hawkeye checked GitHub directly (rather than trusting its own prior claim) and found zero commits since PR #19's merge, meaning nothing had actually been dispatched. The miss wasn't lack of diligence at the check-in — it was the earlier turn treating a stated intention as equivalent to an executed one.

This is a close cousin of [[GL-007-verify-before-acting-on-a-finding]] (verify a *historical finding* is still current before acting on it) but distinct: GL-007 is about not trusting stale external evidence; this Guideline is about not trusting your own prior narration as if it were a log of what actually executed. Both are solved the same way — check the live state, not the story about the live state.

## When this does NOT apply

- Describing a plan for future turns ("I'll route this to Pierce once Blake's spec lands") — this is explicitly not claiming the action is happening now.
- A dispatch that already has its tool call in the same turn — the narration text around it is fine and expected; this Guideline doesn't ask for less communication, only that the words match an action actually taken.

## Updates to this Guideline

- 2026-07-14 — created (Hawkeye), graduated from the same-day Prophet Trader Weekly Strategy Report PR #19 correction near-miss, at Jeff's explicit request to capture the lesson durably.
