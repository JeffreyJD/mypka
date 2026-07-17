---
# Identity
id: tsk-2026-07-10-002
title: "Trace provenance of data/bars/VIX.csv used in the wf_v9 backtest — source can't be reproduced from live Alpaca"

# Ownership & priority
assignee: pierce
priority: 3

# Status (mirrors folder location)
status: open
blocked_reason: null
blocked_by: null

# Time
created: 2026-07-10T08:35:00Z
updated: 2026-07-10T08:35:00Z
due: 2026-09-01

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
linked_deliverables: ["2026-07-10-mbs-vix-proxy-decision", "2026-07-10-prophet-trader-debug-vix-bars-alpaca-unavailable"]

# Tagging
tags: ["prophet-trader", "momentum-breakout-stocks", "vix", "data-provenance", "phase-3-prep"]
---

# Trace provenance of data/bars/VIX.csv used in the wf_v9 backtest — source can't be reproduced from live Alpaca

## What this is

While investigating the live VIX-bar-fetch gap ([[tsk-2026-07-10-001-fix-live-vix-bar-fetch-mbs]]), Pierce found that `data/bars/VIX.csv` — the file used in the Phase 1 gate-passing `momentum_breakout_stocks_wf_v9` backtest (Sharpe 1.455, PF 1.519, `vix_filter: true`) — contains real-VIX-shaped data (volume always 0, consistent with true index data rather than an ETF proxy) that could not be reproduced today via `fetch_historical_bars.py` against the current live Alpaca account. Full findings in [[2026-07-10-prophet-trader-debug-vix-bars-alpaca-unavailable]].

Blake's assessment ([[2026-07-10-mbs-vix-proxy-decision]]): this is **material but not automatically fail-triggering** under IPS Section 2.2 — the data is real, not synthetic. But it independently confirms the original filter was validated against a data source that is currently unidentified and unreproducible, which has two implications: (1) any VIXY-proxy substitution today would be mapping onto an unverified target, reinforcing Blake's rejection of the proxy path; (2) it's worth knowing before the strategy's Phase 3 backtest-fidelity audit whether the original wf_v9 walk-forward can even be independently reproduced.

There's also a `.gitignore` comment currently claiming VIX data is "regenerable from Alpaca" — factually wrong per this investigation, worth correcting once the actual source is known (or confirmed unknowable).

## Context one click away

- [[2026-07-10-mbs-vix-proxy-decision]] — Blake's ruling, includes the provenance assessment
- [[2026-07-10-prophet-trader-debug-vix-bars-alpaca-unavailable]] — Pierce's original investigation where this was found
- [[tsk-2026-07-10-001-fix-live-vix-bar-fetch-mbs]] — sibling task, the live-fetch fix this provenance question was found alongside

## Success criteria

- [ ] Trace `data/bars/VIX.csv`'s actual origin — git file history, commit messages, any README/data-sourcing notes, whoever/whatever originally generated it.
- [ ] Determine whether the original wf_v9 walk-forward can be independently reproduced with a currently-available data source, or whether that specific backtest run is effectively unrepeatable.
- [ ] Correct the `.gitignore` comment that incorrectly claims VIX data is "regenerable from Alpaca."
- [ ] If this surfaces a genuine data-architecture question (e.g., "where should historical index data for backtesting live going forward"), loop in Margaret rather than resolving it solely as a one-off file trace.
- [ ] Report findings back — feeds into (does not block) the strategy's Phase 3 slippage/backtest-fidelity audit.

## Updates

- 2026-07-10 08:35 (hawkeye) — created per Blake's explicit handoff in [[2026-07-10-mbs-vix-proxy-decision]]; tracked separately from `tsk-2026-07-10-001` since it's a provenance question, not blocking the live-fetch fix. No urgency — due date set well ahead of the strategy's 2026-09-20 Phase 3 eligibility, giving room for this to feed the eventual audit.
- 2026-07-17 (pierce) — Jeff clarified the GitHub Issues backlog is for bugs/enhancements only, not investigation activities. This is a provenance trace, so it stays myPKA-task-only — no GitHub issue filed. If the trace surfaces an actual fix (e.g. a `.gitignore` correction or a data-architecture change), that becomes its own new issue at that time.

## Outcome

_(filled when status flips to done — see SOP-012-close-task)_
