---
agent_id: pierce
type: journal-entry
created: 2026-07-10T08:15:00Z
updated: 2026-07-10T08:15:00Z
topic: alpaca-vix-data-limits
tags: [prophet-trader, alpaca, vix, data-pipeline, market-data]
linked_session_logs: []
linked_tasks: [tsk-2026-07-10-001-fix-live-vix-bar-fetch-mbs]
related_journal_entries: [2026-07-08-verify-deployed-config-field-by-field-against-the-backtest-that-passed]
status: durable
---

# Alpaca's stock data API does not serve true CBOE VIX index data — VIXY is the only fetchable VIX-adjacent series, on any feed tier.

## Context
Task asked me to feed real VIX daily bars into `momentum_breakout_stocks`'s internal filter, preferring true VIX over a VIXY proxy. I tested directly against the live Alpaca paper account before writing any code.

## What I learned
`StockHistoricalDataClient` (the same class `scripts/fetch_historical_bars.py` and `src/briefs/fetchers/equity_alpaca.py` both use) returns **empty, not an error**, for symbol `VIX` on `StockBarsRequest`, `StockLatestQuoteRequest`, and `StockLatestTradeRequest` — tried on both `DataFeed.IEX` and `DataFeed.SIP`. Alias attempts (`^VIX`, `I:VIX`) hard-error as invalid symbols instead. There is also no `IndexHistoricalDataClient` in the installed `alpaca-py` version — only `StockHistoricalDataClient`, `CryptoHistoricalDataClient`, `OptionHistoricalDataClient`. `VIXY` works immediately on the same account/credentials with real trade data. Conclusion: this isn't a credentials or entitlement problem, it's that Alpaca's stock data API structurally does not carry the VIX index — full stop, on this integration.

This explains why `src/briefs/fetchers/equity_alpaca.py` already defaults to `vix_symbol: str = "VIXY"` — that fetcher was written around this exact limitation, not as an arbitrary choice. Future work touching VIX in this codebase should treat "true VIX isn't fetchable via Alpaca" as an established fact, not something to re-discover by testing again.

Open thread I did NOT chase: `data/bars/VIX.csv` (used in the Phase 1 wf_v9 backtest) contains real-VIX-shaped data (volume always 0, levels in the teens/twenties) that could not be reproduced today by `fetch_historical_bars.py` against this account — meaning that file's true provenance is unclear (hand-sourced from elsewhere? different entitlement at build time?). Worth a look before anyone trusts `data/bars/VIX.csv` as "regenerable from Alpaca" per the `.gitignore` comment — it currently isn't, at least not with this integration.

## When this applies
- Any future prophet-trader work that wants true VIX index levels (not a proxy) via Alpaca — stop, don't re-test, this is settled. A proxy (VIXY, or a different provider entirely — CBOE, FRED `VIXCLS`, a paid feed) is required.
- Evaluating whether a "VIX-based" threshold in any strategy config is actually validated against real VIX levels or against a proxy's price scale — check which one before trusting the number.

## When this does NOT apply
- Regime classification (`equity_alpaca.py`) — already correctly built around the VIXY proxy from the start; no fix needed there.
- If prophet-trader ever adds a different market-data provider (Polygon, IEX Cloud direct, a paid CBOE feed) — that provider may well carry true VIX and this limitation is Alpaca-specific.

## Evidence
- [[tsk-2026-07-10-001-fix-live-vix-bar-fetch-mbs]] — task that prompted the test
- [[2026-07-10-prophet-trader-debug-vix-bars-alpaca-unavailable]] — full test output and options writeup
- `C:\Users\jeff\dev\prophet-trader\src\briefs\fetchers\equity_alpaca.py` line 103 — the pre-existing `vix_symbol: str = "VIXY"` default this confirms the reason for
