---
# Identity
id: tsk-2026-07-13-001
title: "Move Weekly Strategy Report from broken cloud routine to a VPS script — 2 blocking data-integrity bugs found along the way"

# Ownership & priority
assignee: pierce
priority: 1

# Status (mirrors folder location)
status: open
blocked_reason: null
blocked_by: null

# Time
created: 2026-07-13T11:10:33Z
updated: 2026-07-14T10:00:00Z
due: 2026-07-19

# Provenance
created_by: hawkeye
source: session
parent: null

# Cross-references — REQUIRED, even if empty array. Seven slots. The act of filling these is the whole point.
linked_sops: ["SOP-010-create-task", "SOP-012-close-task"]
linked_workstreams: []
linked_guidelines: []
linked_my_life: []
linked_session_logs: []
linked_journal_entries: []
linked_deliverables: ["2026-07-13-weekly-strategy-report-vps-script-spec", "2026-07-13-prophet-trader-deploy-cross-strategy-sweep", "2026-07-13-weekly-strategy-report-data-prerequisites-decision", "2026-07-13-prophet-trader-debug-healthchecks-slug-lookup"]

# Tagging
tags: ["prophet-trader", "weekly-strategy-report", "remotetrigger", "cloud-routine", "network-egress", "architecture"]
---

# Weekly Strategy Report cloud routine cannot run at all — no egress to B2/healthchecks, no git write access, and PKM/ isn't in the bare clone

## What this is

The Weekly Strategy Report's first live fire (2026-07-12) never pinged healthchecks.io — confirmed via direct API query (zero pings ever, on the correctly-identified check, ruling out the duplicate-check red herring from a prior session). A manual re-run (2026-07-13, ~21:26 ET / 01:26 UTC) reproduced the same failure. Jeff pulled the actual session transcript himself (the only way to see it — neither the `RemoteTrigger` API nor VPS access exposes cloud-routine run logs) and it revealed the real root cause, which is **not** the single gitignore/commit-chaining issue originally hypothesized. It's three separate, more fundamental blockers:

1. **No network egress to `api.backblazeb2.com`** — the session's outbound HTTPS agent proxy returned 403 on the `CONNECT` itself. The routine cannot fetch the autopsy data from B2 at all, regardless of whether the read-only scoped key is still valid.
2. **No network egress to `hc-ping.com`** — same proxy, same 403, on *both* the success ping and the `/fail` fallback ping. This is why the check has never received a single ping since creation, even on a hard failure — the routine's own designed "at least report failure" mechanism is blocked by the same wall as everything else.
3. **No git write access back to `JeffreyJD/mypka`** — both a direct `git push` and a GitHub API-based push attempt returned 403. The session apparently has read-only access to the repo it was given as a source, not read-write, despite the routine's design assuming it can commit and push its own report.

**Separately, and independent of the network issue:** even if egress and write access were both fixed, the routine still could not do its job as designed, because `PKM/`, `Documents/`, and `Deliverables/` are gitignored in the mypka repo and have never been committed to git history at all — a bare clone (which is what a `RemoteTrigger` session gets) genuinely cannot contain them. The routine's own instructions require reading the IPS (`PKM/Documents/prophet-trader/...`) and writing its report to `Deliverables/` — both paths are structurally absent from any git clone, cloud or otherwise.

## Why this matters more than the original hypothesis

This isn't a bug in Blake's prompt or a small chaining mistake — it's a mismatch between how this routine was designed (assumes free internet egress + git write + access to gitignored vault content) and what a `RemoteTrigger` cloud-routine session's environment actually permits.

## Decision (2026-07-13): retire the cloud routine, move to the VPS

Jeff and Hawkeye decided not to chase whether the cloud sandbox's egress/write restrictions are even configurable. Instead: **retire the `RemoteTrigger` routine entirely** (disabled via API, `enabled: false`, confirmed) and **move this report onto the VPS**, reusing what's already proven reliable there (Daily Routine, Weekly Autopsy both have full network egress and git write access). The judgment/reasoning layer becomes a direct Anthropic API call from a VPS Python script, not an interactive cloud agent session.

Blake reviewed and approved this architecture with conditions — see [[2026-07-13-weekly-strategy-report-vps-script-spec]] for the full spec. Key points:

- **The verdict itself must be computed by deterministic Python** (extending `weekly_autopsy.py`'s existing `_compute_verdict()`), not decided by the API call — the model is scoped narrowly to the one genuinely interpretive judgment IPS assigns to a human (regime-vs-model-failure attribution) plus narrative writing. This directly prevents the "judgment call without running the structured criteria" anti-pattern IPS 7.3 forbids.
- **Two blocking data-integrity bugs found while tracing the actual code, independent of this redesign:**
  1. Trade fill records (`data/trades.jsonl`) carry no strategy attribution — the `"strategy"` field on every proposal is never copied onto the resulting fill. Per-strategy P&L has been effectively portfolio-wide all along, masked only because `momentum_breakout_stocks` has had zero lifetime fills so far.
  2. The daily classified market regime is never persisted to `data/decisions/*.json` — without it, nothing can later distinguish a regime-gated quiet week from a model-failure quiet week.
- Report lands at `prophet-trader/reports/YYYY-MM-DD-weekly-strategy-report.md`, git-committed on the VPS — not myPKA's `Deliverables/`. myPKA gets a pointer note in `PKM/Environment/Services/prophet-trader.md`, same pattern as other Environment/Accounts entries.
- New `config/ips_criteria.yaml` in prophet-trader, owned by Blake, kept in sync as a mandatory sub-step of any future IPS amendment.
- Benchmark data: Alpaca's own SPY bars (already-integrated adapter), explicitly labeled a proxy, gated behind 50%-of-quarter-elapsed before any beat/miss commentary.

## Context one click away

- Session transcript Jeff pulled directly (the only source of truth for this diagnosis; not independently re-verifiable by Pierce or Hawkeye through any tool currently available): `https://claude.ai/code/session_016pgK8Ne41XXKA6phBipqZ8`
- Routine config: `trig_01DSKrdhex2fBMkK8bA3q6a3` ("Prophet Trader - Weekly Strategy Report")
- Prior diagnostic thread (superseded by this finding, kept for the false starts it correctly ruled out): the gitignore/commit-chaining hypothesis, the duplicate-healthchecks-check investigation, the B2-data-availability check (confirmed data exists and is reachable **from the VPS**, which is a different network context entirely from the cloud routine's sandbox — that finding stands, it just wasn't the actual blocker)

## Success criteria

- [x] Determine root cause — done. Cloud sandbox egress/write restrictions confirmed real and reproducible (original fire + manual re-run both failed identically).
- [x] Architectural decision made — retire `RemoteTrigger` for this job, move to VPS. Routine disabled (`enabled: false`, confirmed via API).
- [x] Blake's spec for the VPS-scripted version — complete, [[2026-07-13-weekly-strategy-report-vps-script-spec]].
- [x] **Blocking prerequisite bugs fixed and deployed:** trade-fill strategy attribution (PR #15) and regime persistence (PR #16) both merged, deployed to `main`, confirmed live on the VPS (`d85e10c`).
- [x] **Unplanned but completed:** full cross-strategy-mixing sweep (Jeff's "identify and fix all bugs" directive) found 3 more real instances beyond the two Blake originally scoped — most severe: `check_demotion_triggers.py` Triggers 1-3 had zero strategy filtering and were **live and unmasked in production today**, meaning `momentum_breakout_stocks` demotion evidence could have been computed from `cross_sectional_momentum`'s real numbers. Also fixed: `_summarize_open_positions()` cross-strategy leakage, 3 dashboard endpoint key-mismatch bugs. All fixed, tested, merged, deployed (PR #17 → PR #18 `dev`→`main`, VPS confirmed at `d85e10c`). Full detail: [[2026-07-13-prophet-trader-deploy-cross-strategy-sweep]]. Blake's gut-check confirmed **no strategy was ever actually demoted incorrectly** (verified directly against `phase_state.json`) — only the evidence text was mislabeled.
- [x] Quarter-open-equity source and per-strategy drawdown tracking — **decided**, not yet implemented. Blake's decisions: persisted first-party snapshot (one-time Alpaca bootstrap + automatic quarterly snapshots going forward) for equity; drawdown computed from the existing demotion-trigger logic, unbounded to since-Phase-2-inception. One open condition: Pierce must confirm a 2026-07-09–07-13 data gap before trusting the `cross_sectional_momentum` drawdown backfill. Full detail: [[2026-07-13-weekly-strategy-report-data-prerequisites-decision]]. **Not yet coded.**
- [ ] Implement the quarter-open-equity snapshot mechanism and drawdown computation per Blake's decisions above.
- [ ] Build `config/ips_criteria.yaml` per Blake's spec §1.2 — this file's content is Blake's sign-off, not Pierce's to draft freely.
- [ ] Build the VPS report-generation script per Blake's spec §7 order-of-operations, chained after `weekly_autopsy.py` same pattern as `daily_fidelity_check.py` is chained after `daily_routine.py`. **Not yet started** — Pierce has been diverted twice (the sweep, then the healthchecks bug below) since the spec landed.
- [ ] Jeff provisions a new `HEALTHCHECKS_WEEKLY_REPORT_URL` dead-man's switch (same pattern as the existing autopsy/fidelity checks) before first live fire. **Still outstanding.**
- [ ] Report written to `prophet-trader/reports/YYYY-MM-DD-weekly-strategy-report.md`; myPKA pointer note added to `PKM/Environment/Services/prophet-trader.md`.
- [ ] Ledger's Pre-deploy Fidelity Check (SOP-022 §1) on the report script itself — new cron entry, new credential, new config file. Do not merge without PASS.
- [ ] First live fire confirmed clean before closing this task — do not close on "should work now."

### Side quest, found and mostly resolved along the way: the fidelity check itself had a false-positive bug

While chasing the "fix all bugs" directive, a genuinely unrelated bug surfaced: `daily_fidelity_check.py` (the tool from `tsk-2026-07-11`/`-12`, unrelated to this task's actual scope) has been reporting a false "Routine: FAIL" every weekday since it deployed, including today — a hardcoded hyphen in a name lookup didn't match the real check's em-dash name. Root cause and fix confirmed independently by Ledger (PASS), but Ledger found the PR's own reasoning for rejecting a more stable identifier (`unique_key`) was factually wrong per vendor docs, and pointed to live proof in this same account (two checks with an empty `slug` field) that the chosen fix doesn't fully close the bug class either. **Fix works and is safe to build on (merged to `dev`), but the PR's documentation/comments need correcting before promotion to `main`** — routed back to Pierce, not yet confirmed landed. Full detail: [[2026-07-13-prophet-trader-debug-healthchecks-slug-lookup]]. Tracked here only for visibility; not a literal blocker on this task's own success criteria.

## Updates

- 2026-07-13 11:10 (hawkeye) — recreated. The original version of this task was created by the routine's own final diagnostic session as `tsk-2026-07-13-001` but only existed inside that session's local (uncommitted) state — the same git-write-access problem this task describes prevented it from ever being pushed, so it was lost when the session ended. Jeff relayed the routine's own summary verbatim; this task reconstructs it faithfully rather than only noting "something failed."
- 2026-07-13 12:05 (hawkeye) — Jeff confirmed the architecture decision: retire the cloud routine, move to the VPS. Disabled `trig_01DSKrdhex2fBMkK8bA3q6a3` via API (`enabled: false`, confirmed). Dispatched Blake to spec the VPS-scripted judgment logic before Pierce builds anything — he approved the architecture with conditions and, while tracing the actual codebase to write the spec, found two real, previously-undiscovered data-integrity bugs (trade-fill strategy attribution, regime persistence) that need fixing as their own prerequisite work, independent of this redesign. Full spec at [[2026-07-13-weekly-strategy-report-vps-script-spec]]. Routing to Pierce next.
- 2026-07-14 10:00 (hawkeye) — bringing this current after a full day of activity that wasn't being logged against this task as it happened. Since the last update: (1) PR #15/#16 merged and deployed, confirming the two prerequisite bugs are actually fixed in production, not just committed. (2) Jeff's "we must have all bugs identified and fixed asap" directive triggered a full cross-strategy-mixing sweep — found and fixed 3 more real instances, most seriously a live, unmasked bug in the demotion-trigger logic itself (fixed, deployed, Blake confirmed no strategy was ever actually demoted incorrectly as a result). (3) Blake resolved both remaining data prerequisites (quarter-open equity, drawdown tracking) with concrete mechanisms — decided, not yet coded. (4) An unrelated but real bug surfaced in the Daily Fidelity Check tool itself (false "Routine: FAIL" every weekday) — fixed and Ledger-verified, but Ledger found the fix's own documented reasoning was factually wrong per vendor docs and flagged a live gap in the same account (empty `slug` fields) proving the fix doesn't fully close the bug class; correction routed to Pierce, not yet confirmed landed. **Net effect: the actual report-generation script Pierce needs to build per Blake's spec has not been started yet** — he's been correctly diverted twice to fix real bugs found along the way rather than building on an unverified foundation.

## Outcome

_(filled when status flips to done — see SOP-012-close-task)_
