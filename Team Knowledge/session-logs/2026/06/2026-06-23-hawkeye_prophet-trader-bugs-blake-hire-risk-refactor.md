---
agent_id: hawkeye
session_id: prophet-trader-bugs-blake-hire-risk-refactor-2026-06-23
timestamp: 2026-06-23T23:59:00Z
type: close-session
linked_sops:
  - SOP-001-how-to-add-a-new-specialist
linked_workstreams: []
linked_guidelines:
  - GL-002-frontmatter-conventions
---

# Prophet Trader — Bug Fixes, Blake CIO Hire, Risk Limits Refactor

## Context

Continuation from 2026-06-22 session. Entered this session with Prophet Trader Phase 2 running but three bugs active: regime classifier returning `unknown`, CSCO/GOOGL limit price zero error, and `momentum_breakout_stocks` never being called by the daily routine despite Phase 2 promotion. Also: no CIO role on team, no formal risk doctrine, no single source of truth for phase limits.

## What we did

### Pre-run readiness check and manual run verification

Ran a full VPS readiness check before the 9:30 ET routine. All systems green. The 9:30 run fired on time (exit 0) but returned 0 proposals due to regime = `unknown`. Verified via manual run that the fix was needed. Later confirmed markets were open and ran additional manual tests confirming the dispatcher fix.

### Bug 1 — Regime classifier `unknown` (FIXED)

Root cause: VIX between 20–22 fell through a gap in all five classification branches, returning the `unknown` fallback. Fix: widened range-bound boundary to `< 22`, added a catch-all for indeterminate-but-data-present states. Confirmed via manual run: `volatile-uncertain` and `range-bound` now correctly returned under various VIX conditions.

### Bug 2 — CSCO/GOOGL `limit price must be > 0` (FIXED)

Root cause: June 19 was Juneteenth (market closed). Those tickers had `entry_price = 0` (no session data) and the order reached the Alpaca adapter with `limit_price = 0`. Fix: pre-placement guard in `_execute_approved` — zero/None/negative entry price logs `SKIP` and journals a rejected record before the adapter is touched.

### Bug 3 — `momentum_breakout_stocks` never called (FIXED)

Root cause: MBS was promoted to Phase 2 but never registered in the routine's strategy dispatcher. Every run since promotion silently skipped it. Fix: converted dispatch to a multi-strategy loop iterating all Phase 2+ entries from `phase_state.json`. Both strategies now confirmed running in every log: `Running all Phase 2+ strategies: ['momentum_breakout_stocks', 'cross_sectional_momentum']`.

### Blake hired — Chief Investment Officer

Routed to Potter via SOP-001. B.J. researched world-class CIO function for AI-native systematic trading. Potter drafted the contract and shim. Character: Colonel Henry Blake (CO of the 4077th — holds the line on pre-committed criteria). Slug: `blake`. No overlap with Winchester (personal portfolio) — Blake owns Prophet Trader system only.

Key behavioral commitments locked in the contract:
- Pre-committed criteria do not move mid-phase. Not for a good month. Not for impatience. Not for Jeff asking.
- Distinguish regime-driven drawdown from model failure.
- Blake specifies. Pierce implements. Never crosses the line.

### Investment Policy Statement drafted (Blake, first invocation)

Blake drafted `PKM/Documents/prophet-trader/investment-policy-statement.md` — SSOT for all strategy evaluation, gate assessment, and risk parameter decisions.

**Phase 2 → Phase 3 gate criteria (locked, non-negotiable):**
1. 90-day clean paper record per strategy (CSM: 2026-08-22, MBS: 2026-09-20)
2. OpenRouter multi-model refactor complete
3. Live slippage audit (30 days paper fills vs backtest)
4. Survivorship-clean universe (paid Polygon or equivalent)
5. Kill-switch drill × 3 from cold, documented
6. `config/risk_limits.yaml` Phase 3 $5K cap enforced by Risk Officer
7. CPA + securities attorney consultation on record

### `config/risk_limits.yaml` created (Blake policy spec)

Blake issued locked risk limits covering Phase 2, Phase 3, Phase 4, and regime overrides. Single source of truth for all phase limit values. Phase 3 hard cap: $5,000 deployed capital. Breach response: 4-tier protocol (warning → soft breach → hard breach → kill switch).

### kelly.py + gates.py unified to risk_limits.yaml (Blake approved, Pierce implemented)

Blake approved the refactor with conditions (Approve-with-conditions verdict). Pierce implemented:
- New `src/risk/config_loader.py` — hard-fail YAML loader, raises `FileNotFoundError` if file absent
- `kelly.py` — `PHASE_LIMITS` dict and small-sample constants now loaded from YAML
- `gates.py` — `PHASE_LIMITS` dict now loaded from YAML; 30-day ramp boundary is YAML field (`position_ramp_days: 30`)
- `config/risk_limits.yaml` — added Phase 4 block (Jeff confirmed values)

Key corrections made by the refactor:
- Phase 2 `max_per_position_pct`: 0.05 → 0.020 (was inert cap, now matches IPS)
- Phase 3 `max_per_position_pct`: 0.01 → 0.020 (YAML authoritative per IPS)

### Sync state confirmed

All four refs on `04396d8`:
- local `dev` — `04396d8` (synced forward from main, 6-commit drift resolved)
- local `main` — `04396d8`
- `origin/main` (GitHub) — `04396d8`
- VPS — `04396d8`, working tree clean

**343 tests passing.**

## Regime behavior (informational, not a bug)

Today's 9:30 ET run: regime = `volatile-uncertain`. Both strategies gated (correct). MBS requires `trending-bull`; CSM is also on-rebalance cadence (21-day, last rebalance 2026-06-19, next ~2026-07-10). Zero proposals is correct behavior in current market conditions.

## Open threads (carried)

### Prophet Trader
- [ ] OpenRouter multi-model refactor — Phase 3 Gate 2, ~19h, Klinger handoff needed before Pierce implements (`docs/OPENROUTER_REFACTOR.md` scoped)
- [ ] Phase 3 Gate 3: live slippage audit (30 days paper fills vs backtest assumptions)
- [ ] Phase 3 Gate 4: survivorship-clean universe (paid Polygon or equivalent)
- [ ] Phase 3 Gate 5: kill-switch drill × 3 from cold, documented
- [ ] Phase 3 Gate 7: CPA + securities attorney consultation on record
- [ ] Live adapter for trailing stop (`stocks_alpaca.py`) — follow-on task
- [ ] Alpaca API key scoping
- [ ] B2 restore test
- [ ] Tailscale ACL review
- [ ] Phase 2c (crypto expansion) gated on 7 clean equity paper days

### Pool Monitor
- [ ] Order Phase 0 parts (~$110)
- [ ] Resolve M800 enclosure (Fibox ARCA-JIC leading), update build guide
- [ ] Pull M800 Modbus register map, correct placeholders in `pool-monitor.yaml`
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

- **Blake is the CIO.** All strategy promotion/demotion, Phase gate assessments, and risk parameter changes route through Blake. Hawkeye does not make investment decisions.
- **Phase 2→3 gate criteria are locked.** Not negotiable. Not movable mid-phase. Next assessment: 2026-09-20.
- **`config/risk_limits.yaml` is the single source of truth** for all phase limits. kelly.py and gates.py load from it. Any change to limits requires a Blake memo.
- **Trailing stop approach ruled out as PF lever for MBS.** ADX filter was the correct fix.
- **Regime `volatile-uncertain` and `unknown` gate all proposals.** Correct policy per IPS. Not a bug.

## Cross-links

- [[2026-06-22-hawkeye_momentum-breakout-phase1]] — prior session
- [[prophet-trader]] — service environment file
- [[investment-policy-statement]] — Blake's IPS (SSOT for Prophet Trader decisions)
