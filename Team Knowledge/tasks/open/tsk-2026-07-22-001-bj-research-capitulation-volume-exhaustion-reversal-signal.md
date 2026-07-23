---
# Identity
id: tsk-2026-07-22-001
title: "B.J. research brief: capitulation/volume-exhaustion equity reversal signal for Prophet Trader"

# Ownership & priority
assignee: bj
priority: 4

# Status (mirrors folder location)
status: open
blocked_reason: null
blocked_by: null

# Time
created: 2026-07-23T01:53:45Z
updated: 2026-07-23T01:53:45Z
due: null

# Provenance
created_by: hawkeye
source: session
parent: null

# Cross-references — REQUIRED, even if empty array. Seven slots. The act of filling these is the whole point.
linked_sops: ["SOP-010-create-task", "SOP-012-close-task"]
linked_workstreams: []
linked_guidelines: []
linked_my_life: ["investing"]
linked_session_logs: []
linked_journal_entries: []
linked_deliverables: ["2026-07-08-strategy-autopsy"]

# Tagging
tags: ["prophet-trader", "research", "capitulation", "mean-reversion", "regime-gap"]
---

# B.J. research brief: capitulation/volume-exhaustion equity reversal signal for Prophet Trader

## What this is

Jeff watched a YouTube video (Lance / TheOneLance, ex-Trillium intraday trader, swing trading strategy breakdown) and asked Hawkeye whether anything in it applies to Prophet Trader. Hawkeye routed the screening to Blake, who confirmed a genuine gap: the IPS's `capitulation` regime class (§5.1) currently has only one strategy mapped to it — `funding_skew_crypto`, still Phase 0, crypto-only. There is no equity strategy targeting capitulation.

The video's mean-reversion approach is distinct from Prophet Trader's already-shelved `mean_reversion_zscore_stocks` (failed Phase 1: PF 0.93, Sharpe -0.25, statistical z-score based). The video's mechanism instead:
- Waits for a stock to become so overextended (up or down) that it shows exhaustion characteristics — massive volume on an accelerated, unsustainable move.
- Interprets that as marginal sellers (or buyers) being exhausted.
- Enters on trend break ("right side of the V"), stop initially at the low of the move, trailing via prior daily bar lows.

Blake's explicit instruction: this is a screening pointer, not a validated idea. An anecdote (one large trade) is not evidence. B.J.'s job is to determine whether a real, falsifiable, out-of-sample case exists before this goes anywhere near Blake for formal evaluation — per IPS §3.1/§3.2 evidentiary standards.

## Context one click away

- IPS: `PKM/Documents/prophet-trader/investment-policy-statement.md` — §5.1 (regime taxonomy, capitulation class), §3.1/§3.2 (evidence standards for new strategy candidates)
- Working artifacts: [[2026-07-08-strategy-autopsy]] — background on regime-to-strategy mapping and prior mean-reversion failure
- Service: [[prophet-trader]]
- Prior failed strategy for contrast: `mean_reversion_zscore_stocks` (shelved, Phase 1 failure — statistical z-score mechanism, NOT the same as volume-exhaustion)

## Success criteria

Research brief (to `Deliverables/`) answering:

1. Is there a distinct, testable hypothesis here — volume-climax exhaustion as a reversal signal — separate from the already-failed z-score mean reversion approach?
2. Does historical equity data show an out-of-sample edge for this specific signal (not just the anecdotal single-trade case)?
3. If evidence supports it: a scoped proposal for a new strategy candidate with an explicit `preferred_regimes: [capitulation]` hypothesis, ready for Blake's Phase 0/1 intake — not a recommendation to build outright.
4. If evidence does not support it: say so plainly and close the loop — this is allowed to come back "no."

Brief is handed to Blake, not actioned directly by B.J.

## Updates

- 2026-07-23 01:53 (hawkeye) — created, following Jeff's confirmation to open this task after Blake's screening of a YouTube-sourced swing trading video.

## Outcome

_(filled when status flips to done — see SOP-012-close-task)_
