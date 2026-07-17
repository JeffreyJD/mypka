# Tasks Index

_Auto-generated. Do not edit by hand. Run `SOP-013-rebuild-task-index` to regenerate._

_Last rebuilt: 2026-07-17T09:10:00Z_

## Summary
- Open: 11
- In progress: 1 (1 blocked)
- Done (this month): 8
- Cancelled (this month): 1

## Open (11)

### Priority 1 — urgent
- [[tsk-2026-06-30-001-subaru-ez30d-active-diagnostic]] — Subaru EZ30D active diagnostic — cooling fans, lean LTFT, misfire capture, obd-scanner integration — assignee: rizzo — created 2026-06-30

### Priority 2 — high
- [[tsk-2026-07-06-002-sea-ray-windlass-upgrade]] — Sea Ray 340 windlass upgrade — spec, select, and plan install — assignee: henry — created 2026-07-06
- [[tsk-2026-07-16-001-confirm-weekly-strategy-report-first-live-fire]] — Confirm Weekly Strategy Report's first live Sunday cron fire runs clean — assignee: pierce — created 2026-07-16 — due 2026-07-20

### Priority 3 — normal
- [[tsk-2026-07-01-001-obd-scanner-ci]] — Add GitHub Actions CI to obd-scanner — assignee: pierce — created 2026-07-01
- [[tsk-2026-07-09-003-instrument-council-divergence-vs-bare-rule]] — Instrument agent-council decision divergence vs. a bare rule — assignee: pierce — created 2026-07-09
- [[tsk-2026-07-09-004-deflated-sharpe-retrospective-mbs]] — Deflated Sharpe Ratio retrospective on momentum_breakout_stocks — assignee: blake — created 2026-07-09
- [[tsk-2026-07-10-001-fix-live-vix-bar-fetch-mbs]] — Source true VIX index data (non-Alpaca) for momentum_breakout_stocks — VIXY proxy rejected by Blake — assignee: pierce — created 2026-07-10 — due 2026-08-07
- [[tsk-2026-07-10-002-vix-csv-provenance-investigation]] — Trace provenance of data/bars/VIX.csv used in the wf_v9 backtest — source can't be reproduced from live Alpaca — assignee: pierce — created 2026-07-10 — due 2026-09-01
- [[tsk-2026-07-11-001-automate-fidelity-non-clean-surfacing]] — Formalize surfacing of non-CLEAN Daily Fidelity Check days into myPKA — currently manual, unenforced (Ledger LOW finding, PR #13) — assignee: pierce — created 2026-07-11
- [[tsk-2026-07-14-001-risk-journal-pnl-schema-mismatch]] — Daily Alpha Brief's P&L calculation may always read $0.00 — trade schema mismatch in risk_journal.py — assignee: pierce — created 2026-07-14 — due 2026-07-21

### Priority 4 — low
- [[tsk-2026-07-09-005-research-universe-breadth-for-momentum-strategies]] — Research brief: optimal stock universe breadth — assignee: bj — created 2026-07-09 — prep for future bundled Phase 1 cycle, not immediate action

## In progress (1)
- [[tsk-2026-07-17-001-reconciliation-fractional-share-format-bug]] — assignee: pierce — claimed 2026-07-17 — BLOCKED: awaiting Ledger's independent SOP-022 Pre-deploy Fidelity Check on PR #38 (merged to dev at caeaca4) before merge to main

## By assignee
- rizzo: 1 open, 0 in-progress
- henry: 1 open, 0 in-progress
- pierce: 7 open, 1 in-progress
- blake: 1 open, 0 in-progress
- bj: 1 open, 0 in-progress

## Recently closed (last 7 days)
- 2026-07-16 [[tsk-2026-07-09-002-check-weekly-strategy-report-first-fire]] — cancelled — pierce (superseded by the VPS-native rebuild; first-live-fire verification now tracked by [[tsk-2026-07-16-001-confirm-weekly-strategy-report-first-live-fire]])
- 2026-07-16 [[tsk-2026-07-13-001-weekly-strategy-report-cloud-routine-network-and-gitignore-blockers]] — done — pierce (merged dev→main, deployed to VPS, cron wired, quarter-open-equity backfill executed, Environment docs updated; follow-up [[tsk-2026-07-16-001-confirm-weekly-strategy-report-first-live-fire]] carries first-live-fire verification)
- 2026-07-15 [[tsk-2026-07-12-001-post-deploy-baseline-recheck-fidelity-check]] — done — pierce (PR #22 merged/deployed, Ledger PASS, healthchecks.io red alert cleared, two LOW findings also shipped)
- 2026-07-09 [[tsk-2026-07-09-001-merge-b2-autopsy-timing-fix]] — done — jeff/hawkeye (approved, merged, deployed, verified)
- 2026-07-09 [[tsk-2026-07-08-004-merge-weekly-autopsy-multi-strategy-fix]] — done — jeff/hawkeye (approved, merged, deployed, verified)
- 2026-07-09 [[tsk-2026-07-08-003-create-weekly-strategy-report-healthcheck]] — done — hawkeye (created via API, wired into routine)
- 2026-07-08 [[tsk-2026-07-08-002-merge-mbs-regime-config-fix]] — done — jeff/hawkeye (approved, merged, deployed, verified)
- 2026-07-08 [[tsk-2026-07-08-001-rotate-telegram-bot-token]] — done — jeff (verified already resolved same-day)
- 2026-07-06 [[tsk-2026-07-06-001-images-gl001-rename-pass]] — done — margaret
