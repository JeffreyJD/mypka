---
name: Prophet Trader
status: active
service_type: app
runtime: cron
host: davisglobe-vps-ash-1
install_path: /home/trader/prophet-trader
repo_path: C:\Users\jeff\dev\prophet-trader
url: ""
ports: []
schedule: "30 9 * * 1-5 daily routine; 0 10 * * 0 weekly autopsy — TZ America/New_York"
env_file: /home/trader/prophet-trader/.env (chmod 600, 25 variables)
env_var_names:
  - ANTHROPIC_API_KEY
  - ALPACA_PAPER_API_KEY
  - ALPACA_PAPER_SECRET_KEY
  - ALPACA_PAPER_BASE_URL
  - BYBIT_TESTNET_API_KEY
  - BYBIT_TESTNET_API_SECRET
  - BYBIT_TESTNET_BASE_URL
  - TELEGRAM_BOT_TOKEN
  - TELEGRAM_CHAT_ID
  - FIRECRAWL_API_KEY
  - HEALTHCHECKS_URL
  - HEALTHCHECKS_AUTOPSY_URL
  - ACCOUNT_EQUITY_USD
monitoring: healthchecks.io dead-man's switches (daily 30 min grace, autopsy 60 min grace) + Telegram crash alerts + shell-level curl fallback
depends_on: []
linked_accounts:
  - alpaca
  - bybit
  - telegram-prophet-bot
  - firecrawl
  - healthchecks-io
  - anthropic
  - backblaze-b2
tags:
  - trading
  - ai
---

# Prophet Trader

AI-driven paper-trading system (agent council architecture). Phase 2 paper trading live since 2026-05-25; cron jobs deployed to [[davisglobe-vps-ash-1]] on 2026-06-11, first VPS-scheduled run 2026-06-12 09:30 ET. Active strategy: `cross_sectional_momentum` (next review 2026-08-22).

**SSOT note:** the project itself — code, ROADMAP, DEPLOYMENT runbook, HANDOFF state — lives at `C:\Users\jeff\dev\prophet-trader\`. This note is the infrastructure footprint only.

## How it is deployed

- Runs as the `trader` user from a Python venv at `/home/trader/prophet-trader/.venv`, scheduled by crontab (not systemd):
  ```
  TZ=America/New_York
  30 9 * * 1-5 /home/trader/prophet-trader/install/run_routine.sh >> /home/trader/prophet-trader/data/logs/cron.log 2>&1
  0 10 * * 0  /home/trader/prophet-trader/install/run_weekly_autopsy.sh >> /home/trader/prophet-trader/data/logs/cron.log 2>&1
  ```
- `env_var_names` above lists the load-bearing `.env` variables (names only, per [[GL-002-frontmatter-conventions]] rule 7); the full template is `.env.example` in the repo. Live-trading variables (`ALPACA_LIVE_*`, `BYBIT_LIVE_*`) exist in the template but stay empty until Phase 3.
- Runtime state (trades.jsonl, decisions, autopsies, phase_state.json, kill_switch.json) is gitignored — lives only on the host + B2 backup.

## Runbook

- Watch a run: `ssh trader@178.156.163.139` then `tail -f /home/trader/prophet-trader/data/logs/routine-YYYY-MM-DD.log`
- "Did it run at all?" — healthchecks.io is the only layer that catches a machine that never started ([[healthchecks-io]]).
- Test alerting: `python scripts/test_healthchecks.py`
- Backups: rclone → [[backblaze-b2]] daily 00:00 ET.

## Open questions

- Phase 2c (crypto expansion) gated on 7 clean days of equity-only paper.
- Phase 3 (live capital) gated on 90 clean paper days + seven prerequisite items in ROADMAP.md; deployment then moves toward [[lighthouse]].
