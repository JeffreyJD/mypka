# Tasks Index

_Auto-generated. Do not edit by hand. Run `SOP-013-rebuild-task-index` to regenerate._

_Last rebuilt: 2026-07-17T16:25:00Z_

## Summary
- Open: 19
- In progress: 0
- Done (this month): 12
- Cancelled (this month): 1

## Open (19)

### Priority 1 — urgent
- [[tsk-2026-06-30-001-subaru-ez30d-active-diagnostic]] — Subaru EZ30D active diagnostic — cooling fans, lean LTFT, misfire capture, obd-scanner integration — assignee: rizzo — created 2026-06-30

### Priority 2 — high
- [[tsk-2026-07-06-002-sea-ray-windlass-upgrade]] — Sea Ray 340 windlass upgrade — spec, select, and plan install — assignee: henry — created 2026-07-06
- [[tsk-2026-07-16-001-confirm-weekly-strategy-report-first-live-fire]] — Confirm Weekly Strategy Report's first live Sunday cron fire runs clean — assignee: pierce — created 2026-07-16 — due 2026-07-20

### Priority 3 — normal
- [[tsk-2026-07-01-001-obd-scanner-ci]] — Add GitHub Actions CI to obd-scanner — assignee: pierce — created 2026-07-01
- [[tsk-2026-07-09-003-instrument-council-divergence-vs-bare-rule]] — Instrument agent-council decision divergence vs. a bare rule — assignee: pierce — created 2026-07-09 — GH #41
- [[tsk-2026-07-09-004-deflated-sharpe-retrospective-mbs]] — Deflated Sharpe Ratio retrospective on momentum_breakout_stocks — assignee: blake — created 2026-07-09
- [[tsk-2026-07-10-001-fix-live-vix-bar-fetch-mbs]] — Source true VIX index data (non-Alpaca) for momentum_breakout_stocks — VIXY proxy rejected by Blake — assignee: pierce — created 2026-07-10 — due 2026-08-07 — GH #44
- [[tsk-2026-07-10-002-vix-csv-provenance-investigation]] — Trace provenance of data/bars/VIX.csv used in the wf_v9 backtest — source can't be reproduced from live Alpaca — assignee: pierce — created 2026-07-10 — due 2026-09-01
- [[tsk-2026-07-11-001-automate-fidelity-non-clean-surfacing]] — Formalize surfacing of non-CLEAN Daily Fidelity Check days into myPKA — currently manual, unenforced (Ledger LOW finding, PR #13) — assignee: pierce — created 2026-07-11 — GH #42
- [[tsk-2026-07-17-002-reconcile-qty-tolerance-boundary-risk]] — Widen scripts/reconcile.py QTY_TOLERANCE boundary (strict > at exactly 1e-6 can silently mask a genuine drift) — assignee: pierce — created 2026-07-17 — GH #43
- [[tsk-2026-07-17-004-server-py-zero-test-coverage]] — src/api/server.py (Observatory dashboard) has zero test coverage — assignee: pierce — created 2026-07-17 — GH #46
- [[tsk-2026-07-17-005-event-driven-regime-csm-formal-evaluation]] — Formal Blake evaluation: should cross_sectional_momentum trade through event-driven regime windows — assignee: blake — created 2026-07-17
- [[tsk-2026-07-17-006-demotion-trigger-4-portfolio-wide-design-question]] — Demotion Trigger 4 (reconciliation drift) is portfolio-wide, not per-strategy — assignee: blake — created 2026-07-17 — GH #47
- [[tsk-2026-07-17-010-risk-journal-open-positions-schema-mismatch]] — risk_journal.py open-positions summary + deployed_pct use the same fictional trade schema as the P&L bug — assignee: pierce — created 2026-07-17

### Priority 4 — low
- [[tsk-2026-07-09-005-research-universe-breadth-for-momentum-strategies]] — Research brief: optimal stock universe breadth — assignee: bj — created 2026-07-09 — prep for future bundled Phase 1 cycle, not immediate action
- [[tsk-2026-07-17-007-preferred-regimes-fidelity-check-coverage-gap]] — Fidelity check hash doesn't cover phase_state.json preferred_regimes — can silently drift again undetected — assignee: pierce — created 2026-07-17 — GH #48
- [[tsk-2026-07-17-008-walk-forward-cost-estimate-placeholder]] — walk_forward.py _stress_test() cost-estimate placeholder needs a proper version — assignee: pierce — created 2026-07-17 — GH #49
- [[tsk-2026-07-17-009-bj-base-rate-research-trending-bull-event-blackout]] — B.J. base-rate research: trending-bull and event-blackout frequency from Phase 1 backtest period — assignee: bj — created 2026-07-17
- [[tsk-2026-07-17-011-council-intent-standdown-warning-first-live-trigger]] — Verify council_intent.py's week_pnl_pct stand-down warning displays correctly the first time a real closed loss triggers it (-3%/-5%) — assignee: pierce — created 2026-07-17 — no GH issue (watch item, not yet a bug/enhancement)

## In progress (0)
_None._

## By assignee
- rizzo: 1 open, 0 in-progress
- henry: 1 open, 0 in-progress
- pierce: 11 open, 0 in-progress
- blake: 3 open, 0 in-progress
- bj: 2 open, 0 in-progress

## Recently closed (last 7 days)
- 2026-07-17 [[tsk-2026-07-14-001-risk-journal-pnl-schema-mismatch]] — done — pierce (Ledger SOP-022 PASS on PR #52; merged dev→main via release PR #53 at `ea5c677`; deploy confirmed via GitHub Actions + VPS HEAD match; GH #29 closed with fix confirmation; dead-code duplicate finding remediated same-session as [[tsk-2026-07-17-012-remove-dead-realized-edge]]; informational finding tracked as [[tsk-2026-07-17-011-council-intent-standdown-warning-first-live-trigger]])
- 2026-07-17 [[tsk-2026-07-17-012-remove-dead-realized-edge]] — done — pierce (removed dead `realized_edge()` duplicate of the risk_journal P&L schema bug from `strategies/base.py`; PR #54 merged to dev; GH #55 opened and closed same-session with commit/PR evidence)
- 2026-07-17 [[tsk-2026-07-17-003-weekly-autopsy-cadence-broken]] — done — blake/pierce (root-caused as the same cloud-routine egress/git-write failure fixed under [[tsk-2026-07-13-001-weekly-strategy-report-cloud-routine-network-and-gitignore-blockers]]; 2026-07-12 narrative autopsy backfilled at [[2026-07-12-strategy-autopsy]]; GH #45 closed with full diagnosis)
- 2026-07-17 [[tsk-2026-07-17-001-reconciliation-fractional-share-format-bug]] — done — pierce (PR #38 fix merged/deployed, Ledger SOP-022 PASS on re-check, cosmetic type-hint fix PR #39 also shipped, follow-up [[tsk-2026-07-17-002-reconcile-qty-tolerance-boundary-risk]] opened for the tolerance-boundary finding)
- 2026-07-16 [[tsk-2026-07-09-002-check-weekly-strategy-report-first-fire]] — cancelled — pierce (superseded by the VPS-native rebuild; first-live-fire verification now tracked by [[tsk-2026-07-16-001-confirm-weekly-strategy-report-first-live-fire]])
- 2026-07-16 [[tsk-2026-07-13-001-weekly-strategy-report-cloud-routine-network-and-gitignore-blockers]] — done — pierce (merged dev→main, deployed to VPS, cron wired, quarter-open-equity backfill executed, Environment docs updated; follow-up [[tsk-2026-07-16-001-confirm-weekly-strategy-report-first-live-fire]] carries first-live-fire verification)
- 2026-07-15 [[tsk-2026-07-12-001-post-deploy-baseline-recheck-fidelity-check]] — done — pierce (PR #22 merged/deployed, Ledger PASS, healthchecks.io red alert cleared, two LOW findings also shipped)
- 2026-07-09 [[tsk-2026-07-09-001-merge-b2-autopsy-timing-fix]] — done — jeff/hawkeye (approved, merged, deployed, verified)
- 2026-07-09 [[tsk-2026-07-08-004-merge-weekly-autopsy-multi-strategy-fix]] — done — jeff/hawkeye (approved, merged, deployed, verified)
- 2026-07-09 [[tsk-2026-07-08-003-create-weekly-strategy-report-healthcheck]] — done — hawkeye (created via API, wired into routine)
- 2026-07-08 [[tsk-2026-07-08-002-merge-mbs-regime-config-fix]] — done — jeff/hawkeye (approved, merged, deployed, verified)
- 2026-07-08 [[tsk-2026-07-08-001-rotate-telegram-bot-token]] — done — jeff (verified already resolved same-day)
