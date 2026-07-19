# Tasks Index

_Auto-generated. Do not edit by hand. Run `SOP-013-rebuild-task-index` to regenerate._

_Last rebuilt: 2026-07-19T02:06:28Z_

## Summary
- Open: 24
- In progress: 0
- Done (this month): 26
- Cancelled (this month): 1

## Open (24)

### Priority 1 — urgent
- [[tsk-2026-06-30-001-subaru-ez30d-active-diagnostic]] — Subaru EZ30D active diagnostic — cooling fans, lean LTFT, misfire capture, obd-scanner integration — assignee: rizzo — created 2026-06-30

### Priority 2 — high
- [[tsk-2026-07-06-002-sea-ray-windlass-upgrade]] — Sea Ray 340 windlass upgrade — spec, select, and plan install — assignee: henry — created 2026-07-06
- [[tsk-2026-07-09-003-instrument-council-divergence-vs-bare-rule]] — Instrument agent-council decision divergence vs. a bare rule — assignee: pierce — created 2026-07-09 — GH #41 — priority bumped 2026-07-18 (retro flag: live decision data accumulating, unstarted a week+)
- [[tsk-2026-07-16-001-confirm-weekly-strategy-report-first-live-fire]] — Confirm Weekly Strategy Report's first live Sunday cron fire runs clean — assignee: pierce — created 2026-07-16 — due 2026-07-20

### Priority 3 — normal
- [[tsk-2026-07-01-001-obd-scanner-ci]] — Add GitHub Actions CI to obd-scanner — assignee: pierce — created 2026-07-01
- [[tsk-2026-07-09-004-deflated-sharpe-retrospective-mbs]] — Deflated Sharpe Ratio retrospective on momentum_breakout_stocks — assignee: blake — created 2026-07-09
- [[tsk-2026-07-10-001-fix-live-vix-bar-fetch-mbs]] — Source true VIX index data (non-Alpaca) for momentum_breakout_stocks — VIXY proxy rejected by Blake — assignee: pierce — created 2026-07-10 — due 2026-08-07 — GH #44
- [[tsk-2026-07-10-002-vix-csv-provenance-investigation]] — Trace provenance of data/bars/VIX.csv used in the wf_v9 backtest — source can't be reproduced from live Alpaca — assignee: pierce — created 2026-07-10 — due 2026-09-01
- [[tsk-2026-07-11-001-automate-fidelity-non-clean-surfacing]] — Formalize surfacing of non-CLEAN Daily Fidelity Check days into myPKA — currently manual, unenforced (Ledger LOW finding, PR #13) — assignee: pierce — created 2026-07-11 — GH #42
- [[tsk-2026-07-17-002-reconcile-qty-tolerance-boundary-risk]] — Widen scripts/reconcile.py QTY_TOLERANCE boundary (strict > at exactly 1e-6 can silently mask a genuine drift) — assignee: pierce — created 2026-07-17 — GH #43
- [[tsk-2026-07-17-004-server-py-zero-test-coverage]] — src/api/server.py (Observatory dashboard) has zero test coverage — assignee: pierce — created 2026-07-17 — GH #46
- [[tsk-2026-07-17-005-event-driven-regime-csm-formal-evaluation]] — Formal Blake evaluation: should cross_sectional_momentum trade through event-driven regime windows — assignee: blake — created 2026-07-17
- [[tsk-2026-07-17-006-demotion-trigger-4-portfolio-wide-design-question]] — Demotion Trigger 4 (reconciliation drift) is portfolio-wide, not per-strategy — assignee: blake — created 2026-07-17 — GH #47
- [[tsk-2026-07-17-010-risk-journal-open-positions-schema-mismatch]] — risk_journal.py open-positions summary + deployed_pct use the same fictional trade schema as the P&L bug — assignee: pierce — created 2026-07-17
- [[tsk-2026-07-17-013-confirm-bac-reconciliation-clean-on-monday-run]] — Confirm BAC reconciles clean on the next automated Daily Fidelity Check run (2026-07-17 FAIL 5/6, settlement-timing theory) — assignee: pierce — created 2026-07-17 — due 2026-07-20 — no GH issue (watch item, not yet a bug)
- [[tsk-2026-07-18-013-west-9th-tenant-identity-ambiguities]] — Resolve or explicitly park two West 9th Street tenant-identity ambiguities from the June import — assignee: frank — created 2026-07-18 — flagged by outside audit as the one dropped thread from the retro cycle

### Priority 4 — low
- [[tsk-2026-07-09-005-research-universe-breadth-for-momentum-strategies]] — Research brief: optimal stock universe breadth — assignee: bj — created 2026-07-09 — prep for future bundled Phase 1 cycle, not immediate action
- [[tsk-2026-07-17-007-preferred-regimes-fidelity-check-coverage-gap]] — Fidelity check hash doesn't cover phase_state.json preferred_regimes — can silently drift again undetected — assignee: pierce — created 2026-07-17 — GH #48
- [[tsk-2026-07-17-008-walk-forward-cost-estimate-placeholder]] — walk_forward.py _stress_test() cost-estimate placeholder needs a proper version — assignee: pierce — created 2026-07-17 — GH #49
- [[tsk-2026-07-17-009-bj-base-rate-research-trending-bull-event-blackout]] — B.J. base-rate research: trending-bull and event-blackout frequency from Phase 1 backtest period — assignee: bj — created 2026-07-17
- [[tsk-2026-07-17-011-council-intent-standdown-warning-first-live-trigger]] — Verify council_intent.py's week_pnl_pct stand-down warning displays correctly the first time a real closed loss triggers it (-3%/-5%) — assignee: pierce — created 2026-07-17 — no GH issue (watch item, not yet a bug/enhancement)
- [[tsk-2026-07-18-011-esphome-build-artifacts-in-vault]] — Remove ESPHome/PlatformIO build artifacts that leaked into PKM/Documents/pool — assignee: relay — created 2026-07-18 — found during mypka.db regen
- [[tsk-2026-07-18-012-sop-002-schema-scope-team-knowledge]] — Decide whether SOP-002's SQLite mirror should cover Team Knowledge/ and Team/ contracts — assignee: margaret — created 2026-07-18 — BLOCKED: awaiting Jeff's scope decision
- [[tsk-2026-07-18-015-ws-007-cadence-ssot-phrasing]] — WS-007 Step 7: point the Drift Audit cadence at SOP-022 §3 instead of restating it — assignee: potter — created 2026-07-18 — trivial, batchable, no urgency

## In progress (0)
_none_

## By assignee
- rizzo: 1 open, 0 in-progress
- henry: 1 open, 0 in-progress
- pierce: 11 open, 0 in-progress
- blake: 3 open, 0 in-progress
- bj: 2 open, 0 in-progress
- relay: 1 open, 0 in-progress
- margaret: 1 open, 0 in-progress
- potter: 1 open, 0 in-progress
- frank: 1 open, 0 in-progress

## Recently closed (last 7 days)
- 2026-07-19 [[tsk-2026-07-19-001-hire-architect-reviewer-test-engineer]] — done — hawkeye (WS-004 Tier 1 follow-on proposal: three new specialists hired per SOP-001 — [[Team/Keystone - Architect/AGENTS|Keystone]] (Architect, Design gate), [[Team/Lens - Reviewer/AGENTS|Lens]] (Reviewer, Correctness gate), [[Team/Breaker - Test Engineer/AGENTS|Breaker]] (Test Engineer, Test gate) — each with contract, shim, journal folder, agent-index row; Pierce's contract amended (architecture/code-review scope removed, ADR path corrected to in-repo, Method step 2 routed to Keystone); WS-006 fully de-placeholdered and its stale pre-hire "gates don't block merge" caveat corrected in all four places it appeared; three B.J. research briefs archived)
- 2026-07-19 [[tsk-2026-07-18-016-ratify-handoff-protocol-and-ws-006]] — done — hawkeye (WS-004 Tier 1 proposal ratified: new [[GL-017-specialist-handoff-protocol]] — the packet, Done/Decided-vs-open/Gate verdict/Read-first, that travels at every specialist seam — plus optional `## Handoff` task-template section, plus [[WS-006-software-change-lifecycle]] software lifecycle; WS-005/WS-007 retrofitted with real GL-017 pointers; Margaret's schema/SQLite check PASS zero-delta; Pierce's required domain review caught a blocking-grade gate-firing ambiguity and wrong tier-table examples, both fixed and re-verified; Pierce also fixed his own contract's stale repo list; a Potter contract-scope inconsistency surfaced and is noted as an open thread, not resolved)
- 2026-07-18 [[tsk-2026-07-18-014-numbered-artifact-collision-rule]] — done — potter (WS-004 Tier 1 proposal formalized: new [[GL-016-numbered-artifact-collision-check]] — re-confirm number immediately before write, plus required batch-wide check before any commit — wired into GL-001, SOP-010, the Guidelines/SOPs/Workstreams indexes, and WS-004 Tier 2 Step 5; Margaret's mirror regen deferred/flagged to Hawkeye)
- 2026-07-18 [[tsk-2026-07-18-001-ratify-ws-007-infrastructure-change-lifecycle]] — done — potter (WS-004 Tier 1 proposal ratified: WS-007 Infrastructure Change Lifecycle written to Team Knowledge/Workstreams/, form-factor rule single-sourced there, Trapper/Bastion/Relay contracts repointed; Finding A resolved PASS-with-caveat via Ledger; Finding B routed to future software-lifecycle proposal)
- 2026-07-18 [[tsk-2026-07-18-002-schedule-ledger-drift-audit-cadence]] — done — ledger (WS-004 Tier 2 retro proposal 1: SOP-022 §3 gained a mandatory monthly Drift Audit cadence trigger, folded into close-session)
- 2026-07-18 [[tsk-2026-07-18-003-sop-022-pre-implementation-review-mode]] — done — ledger (retro proposal 2: SOP-022 §1 gained a conditional pre-implementation plan-review step for financial-risk/gate-adjacent changes)
- 2026-07-18 [[tsk-2026-07-18-004-hawkeye-execute-vs-route-boundary]] — done — potter (retro proposal 3: Hawkeye's contract gained an explicit execute-vs-route test)
- 2026-07-18 [[tsk-2026-07-18-005-windows-shell-interop-guideline]] — done — bastion (retro proposal 4: new GL-014-windows-shell-interop-gotchas consolidating five recurring gotchas)
- 2026-07-18 [[tsk-2026-07-18-006-sop-001-post-hire-checklist]] — done — potter (retro proposal 5: SOP-001 gained a mandatory post-hire verification checklist)
- 2026-07-18 [[tsk-2026-07-18-007-ws-002-onenote-lockfile-import-rules]] — done — margaret (retro proposal 6: WS-002 documents OneNote/lock-file/slug-collision import rules)
- 2026-07-18 [[tsk-2026-07-18-008-root-agents-md-stale-table-fix]] — done — potter (retro proposal 7: root AGENTS.md's stale specialist table replaced with a Team/agent-index pointer)
- 2026-07-18 [[tsk-2026-07-18-009-credential-hash-guideline]] — done — vex (retro proposal 8: GL-007 gained a named Hash/Fingerprint Compare method; new GL-015-credential-expansion-over-new-grants — renumbered from a GL-014 collision with tsk-2026-07-18-005, both agents ran in parallel)
- 2026-07-18 [[tsk-2026-07-18-010-dedupe-healthchecks-weekly-report-check]] — done — pierce (retro operational flag: independently re-verified live that the 2026-07-12 duplicate had already been resolved 2026-07-16; no fix needed, registry updated with confirmed evidence)
- 2026-07-18 [[tsk-2026-07-17-014-reconcile-settlement-grace-window]] — done — pierce (Ledger SOP-022 PASS on PR #57; merged dev→main via release PR #59 at `c670b3d`; deploy confirmed via GitHub Actions + VPS HEAD match; GH #56 closed with fix confirmation, links #58 as deferred follow-up)
- 2026-07-17 [[tsk-2026-07-14-001-risk-journal-pnl-schema-mismatch]] — done — pierce (Ledger SOP-022 PASS on PR #52; merged dev→main via release PR #53 at `ea5c677`; deploy confirmed via GitHub Actions + VPS HEAD match; GH #29 closed with fix confirmation; dead-code duplicate finding remediated same-session as [[tsk-2026-07-17-012-remove-dead-realized-edge]]; informational finding tracked as [[tsk-2026-07-17-011-council-intent-standdown-warning-first-live-trigger]])
- 2026-07-17 [[tsk-2026-07-17-012-remove-dead-realized-edge]] — done — pierce (removed dead `realized_edge()` duplicate of the risk_journal P&L schema bug from `strategies/base.py`; PR #54 merged to dev; GH #55 opened and closed same-session with commit/PR evidence)
- 2026-07-17 [[tsk-2026-07-17-003-weekly-autopsy-cadence-broken]] — done — blake/pierce (root-caused as the same cloud-routine egress/git-write failure fixed under [[tsk-2026-07-13-001-weekly-strategy-report-cloud-routine-network-and-gitignore-blockers]]; 2026-07-12 narrative autopsy backfilled at [[2026-07-12-strategy-autopsy]]; GH #45 closed with full diagnosis)
- 2026-07-17 [[tsk-2026-07-17-001-reconciliation-fractional-share-format-bug]] — done — pierce (PR #38 fix merged/deployed, Ledger SOP-022 PASS on re-check, cosmetic type-hint fix PR #39 also shipped, follow-up [[tsk-2026-07-17-002-reconcile-qty-tolerance-boundary-risk]] opened for the tolerance-boundary finding)
- 2026-07-16 [[tsk-2026-07-09-002-check-weekly-strategy-report-first-fire]] — cancelled — pierce (superseded by the VPS-native rebuild; first-live-fire verification now tracked by [[tsk-2026-07-16-001-confirm-weekly-strategy-report-first-live-fire]])
- 2026-07-16 [[tsk-2026-07-13-001-weekly-strategy-report-cloud-routine-network-and-gitignore-blockers]] — done — pierce (merged dev→main, deployed to VPS, cron wired, quarter-open-equity backfill executed, Environment docs updated; follow-up [[tsk-2026-07-16-001-confirm-weekly-strategy-report-first-live-fire]] carries first-live-fire verification)
- 2026-07-15 [[tsk-2026-07-12-001-post-deploy-baseline-recheck-fidelity-check]] — done — pierce (PR #22 merged/deployed, Ledger PASS, healthchecks.io red alert cleared, two LOW findings also shipped)
