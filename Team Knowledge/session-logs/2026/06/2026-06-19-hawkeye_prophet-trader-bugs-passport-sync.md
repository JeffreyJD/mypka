---
agent_id: hawkeye
session_id: prophet-trader-bugs-passport-sync-2026-06-19
timestamp: 2026-06-19T23:59:00Z
type: close-session
linked_sops: []
linked_workstreams: []
linked_guidelines:
  - GL-002-frontmatter-conventions
---

# Prophet Trader bug fixes + passport filing + repo sync

## Context

Evening session focused on Prophet Trader operations. Jeff opened with a status request on Prophet Trader, which surfaced three bugs from today's first rebalance run. All three were diagnosed, fixed, tested, and production-validated in the same session. Secondary work: passport filing from Team Inbox, Subaru update commit, and full repo sync across dev/GitHub/VPS.

## What we did

### Prophet Trader — status check and bug diagnosis

- Pulled live VPS logs for June 15–19. Confirmed timezone fix holding: all runs firing at exactly 09:30 ET.
- June 15–18: clean runs, no proposals (off-rebalance cadence + regime gated).
- June 19: first rebalance day — 6 proposals generated. Three bugs surfaced:

**Bug 1 — "Position would round to zero shares" (AMAT, AMD, CAT, MU)**
Root cause: Phase 2 first-30-days budget = 0.5% × $100k = $500. Current prices — AMAT $592, AMD $512, CAT $956, MU $1,043 — all above $500/share. `int(500 // 593) = 0`. Fix: switched `suggested_qty` from `int` to `float`, minimum threshold 0.001 (Alpaca paper supports fractional shares).

**Bug 2 — "limit price must be > 0" (CSCO, GOOGL)**
Root cause: June 19 is Juneteenth — NYSE closed. MARKETABLE_LIMIT orders fetch a live quote at placement; closed market → ask = 0 → `0 * 1.0005 = 0` → Alpaca rejects. Fix: (1) market-open check in routine before executing any orders, skips gracefully if closed; (2) defensive fallback in adapter — if live quote returns zero, falls back to `order.limit_price` (last close from bars).

**Bug 3 — "Journaled 2 fill records" when both were rejections**
Root cause: `fills` list mixed successful submissions (`event_type: fill`) and rejections (`event_type: rejected`); log and Telegram counted the whole list as "fills." Fix: separate submitted/rejected counts in logs, Telegram summary, and journal write confirmation.

### Files changed
- `src/risk/gates.py` — fractional qty support
- `src/adapters/stocks_alpaca.py` — defensive zero-quote guard
- `scripts/daily_routine.py` — market-open check + cleaner reporting
- `tests/test_risk_gates.py` — updated min_qty test for fractional threshold

### Testing and validation
- 253/253 tests passing locally
- Committed `a42a3ef`, pushed to GitHub, pulled to VPS
- Production validation run on VPS (LIVE PAPER mode, --force-rebalance):
  - 6/6 proposals approved, 0 vetoed
  - Market-closed guard fired: "market is CLOSED — skipping 6 approved order(s)"
  - Healthchecks.io pinged 200 OK
  - `Routine complete: 6 approved, 0 vetoed, 0 submitted, 0 rejected`

### Weekly autopsy review
- June 14 autopsy reviewed: 1 trading day in window, 0 proposals, $0 P&L — expected (VPS had only been running 2 days).
- Next autopsy Sunday June 21 10:00 ET will be the first with real content.

### Passport — Team Inbox processing (Radar)
- `Team Inbox/20260615_074203.jpg` — Jeff's new US passport (issued 2026-06-04, expires 2036-06-03)
- Image archived: `PKM/Images/2026/06/2026-06-15-passport.jpg`
- `PKM/Documents/passport.md` updated with real data; passport number kept in password manager per GL-002 rule 7
- Renewal trigger set: 2035-09-03 (9 months before expiry)
- Team Inbox cleared

### Subaru Outback update
- Committed pending changes to `PKM/Documents/automobiles/vehicles/2008-subaru-outback.md`
- Fuel pump replaced 2026-06-15, odometer confirmed 159,000 mi (scanner discrepancy resolved)
- Active issues remain open: cruise control light blinking, misfire codes pending scan 103, idle relearn not done, ignition coil ordered

### Repo sync — prophet-trader
- Added `data/briefs/` to `.gitignore` (was missing; briefs are runtime-generated)
- Committed executable permission fix for `install/run_routine.sh` and `install/run_weekly_autopsy.sh`
- All three environments (dev, GitHub, VPS) confirmed on commit `16e74d0`, clean working trees

## Decisions made

- **Fractional shares are the right fix for Bug 1** — not raising the position size cap. Phase 2 limits stay at 0.5%/1.0%; the execution layer now handles high-priced stocks via Alpaca's fractional share support.
- **Market-closed guard lives in the routine, not the adapter** — primary check is `is_market_open()` before execution; adapter fallback is secondary defense only.
- **Passport number not stored in vault** — password manager only, per GL-002 rule 7.
- **VPS deploy key is read-only** — can pull, cannot push. All pushes flow dev → GitHub → VPS pull. This is the permanent workflow.

## Insights

- Today being Juneteenth exposed the market-closed gap; the cron fires on all weekdays and doesn't know about market holidays. The `is_market_open()` check now handles this cleanly for any future holiday.
- AMAT, AMD, CAT, MU prices in June 2026 ($512–$1,043) far exceed the Phase 2 first-30-days $500 budget per position — fractional shares are not a workaround, they're the correct approach for a $100k paper account with a tight phase cap.
- The `data/briefs/` gitignore omission had been accumulating untracked files silently since May 26 — 24 files. Clean now.

## Open threads

### Prophet Trader
- [ ] **Monday June 22 09:30 ET** — first live fractional order placement with market open. Verify fills land correctly in Alpaca paper account and journal.
- [ ] Alpaca API key scoping (carried from prior weeks)
- [ ] B2 restore test (carried)
- [ ] Tailscale ACL review (carried)
- [ ] Phase 2c (crypto expansion) gated on 7 clean equity days — clock starts when first real fills land

### Network
- [ ] US-24 TFTP recovery — Jeff needs USB-to-Ethernet adapter
- [ ] Switch port VLAN assignment after adoption
- [ ] USG firmware update (4.4.57 → current)
- [ ] AP renaming, DHCP reservations, band steering evaluation

### Vehicles
- [ ] Subaru: idle relearn, ignition coil install, scan 103 (cruise control light)
- [ ] Plug wires, brake fluid, coolant — all deferred from 150k service

### Florida property
- [ ] Florida trip June 17 debrief still missing — no listings or notes in vault

### myPKA general
- [ ] My Drive bulk import (~900 files) — still on hold per Jeff's direction

## Cross-links

- [[2026-06-14-hawkeye_pka-migration-network-docs]] — prior session
- [[prophet-trader]] — service infrastructure note
- [[2008-subaru-outback]] — vehicle file updated this session
- [[passport]] — filed and updated this session
