---
agent_id: hawkeye
session_id: momentum-breakout-phase1-2026-06-22
timestamp: 2026-06-22T23:59:00Z
type: close-session
linked_sops: []
linked_workstreams: []
linked_guidelines:
  - GL-002-frontmatter-conventions
---

# momentum_breakout_stocks — Phase 1 Cleared

## Context

Continuation from the June 19 session (context window compacted). Primary goal: close the PF gap on `momentum_breakout_stocks` and clear Phase 1 gate (avg Sharpe ≥ 1.2, avg PF ≥ 1.5, max DD ≤ 20%, trade count ≥ 100). v6 baseline entering this session: Sharpe 1.438, PF 1.40 — Sharpe passed, PF missed.

## What we did

### Trailing stop implementation (v7, v8) — ruled out as PF lever

Pierce implemented a high-water-mark trailing stop simulator upgrade across `base.py`, `replay.py`, `simulator.py`, and `momentum_breakout_stocks.py`. Three design decisions locked in before implementation:
- Fixed 3.0× ATR target kept as ceiling alongside trailing stop (both can fire)
- Live adapter (`stocks_alpaca.py`) scoped as follow-on task, not this PR
- Initial `trailing_stop_atr_mult: 2.0` (wider, more room to breathe)

v7 (2.0×): Sharpe 0.871, PF 1.27 — both failed. Too tight; trailing stop fired on normal intra-trend pullbacks in choppy folds, converting breakevens into small losses.

v8 (3.0×): Sharpe 1.239, PF 1.345 — Sharpe barely passes, PF still misses. Moving in the right direction but PF gap is structural, not a parameter issue. v6 baseline at PF 1.40 was still better.

**Conclusion:** trailing stop is not the right lever for PF on this strategy. Trailing stop code stays in codebase (disabled via config) for a future follow-on.

### ADX trend filter (v9) — Phase 1 cleared

Added per-ticker ADX (Average Directional Index) filter using Wilder smoothing (14-period, threshold 25.0). Filter culls breakout candidates in non-trending conditions — exactly the choppy-market folds (1, 9, 10) dragging PF down.

v9 results (trailing stop disabled, ADX enabled):

| Metric | Result | Gate |
|---|---|---|
| avg OOS Sharpe | 1.455 | ≥ 1.2 PASS |
| avg OOS PF | 1.519 | ≥ 1.5 PASS |
| max DD | 0.65% | ≤ 20% PASS |
| trade count | 1,272 | ≥ 100 PASS |

Trade count halved (2541 → 1272) because ADX correctly filters out low-trend entries. Averages ~115/fold, well above minimum. Folds 1 and 10 remain weak but do not break the aggregate.

319 tests passing (300 pre-existing + 10 ADX + 9 trailing stop).

### Merge, promotion, and sync

- `phase_state.json` updated: `momentum_breakout_stocks` phase 0 → 2, since 2026-06-22, next review 2026-09-20
- `dev` merged to `main` (commit `20a8b0c`), pushed to origin, GitHub Actions deploy fired
- VPS confirmed clean on `20a8b0c`, working tree clean
- Untracked backtest result JSONs (v1–v9, gap_fade_stocks) committed to `dev` (`4ae37dc`) as archive
- `dev` pushed to origin: one commit ahead of `main` (backtest archive only, expected)
- `PKM/Environment/Services/prophet-trader.md` updated: added `momentum_breakout_stocks` as active phase 2 strategy, added open items for trailing stop live adapter, B2 restore, Tailscale ACL, Alpaca key scoping

### Final sync state

| Branch/Host | HEAD |
|---|---|
| local dev | `4ae37dc` |
| local main | `20a8b0c` |
| origin/main | `20a8b0c` |
| VPS | `20a8b0c` |

## Open threads (carried)

### Prophet Trader
- [ ] **2026-06-23 09:30 ET** — first live fractional order placement (cross_sectional_momentum) AND Phase 2 size bump (0.5% → 1.0% automatic via phase_state.json `since: 2026-05-24`)
- [ ] Trailing stop live adapter (`stocks_alpaca.py` — `TrailingStopOrderRequest`) — follow-on after paper validation
- [ ] Alpaca API key scoping
- [ ] B2 restore test
- [ ] Tailscale ACL review
- [ ] Phase 2c (crypto expansion) gated on 7 clean equity paper days

### Pool Monitor
- [ ] Order Phase 0 parts (~$110)
- [ ] Resolve M800 enclosure (Fibox ARCA-JIC leading option), update build guide
- [ ] Pull M800 Modbus register map from manual, correct placeholders in `pool-monitor.yaml`
- [ ] Flash Phase 0 config, validate at equipment pad

### Network
- [ ] US-24 TFTP recovery (USB-to-Ethernet adapter needed)
- [ ] Switch port VLAN assignment, USG firmware, AP renaming

### Vehicles
- [ ] Subaru: idle relearn, ignition coil, scan 103

### Florida property
- [ ] Florida trip June 17 debrief still missing

### myPKA
- [ ] My Drive bulk import (~900 files) — on hold per Jeff's direction

## Key decisions (durable)

- **Trailing stop as PF lever ruled out** for `momentum_breakout_stocks`. Win rate (33–46%) in choppy periods is the structural constraint; trailing stop addresses exit timing, not entry quality. ADX at entry is the correct fix.
- **ADX threshold 25, period 14** cleared Phase 1 on first attempt. Halved trade count is acceptable; 115/fold average is well above the 100 gate.
- **Trailing stop infrastructure stays in codebase** (disabled). Live adapter task is a clean follow-on once paper confirms trailing stop adds value in live conditions.

## Cross-links

- [[2026-06-19-hawkeye_pool-monitor-intake]] — previous session
- [[prophet-trader]] — service environment file
