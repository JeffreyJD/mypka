---
name: Alpaca
status: active
account_type: exchange
provider_url: https://alpaca.markets
username: ""
plan: Paper trading (free)
monthly_cost: 0
renewal_date: ""
secrets_ref: .env on davisglobe-vps-ash-1 (and dev copy on jeff-laptop)
env_var_names:
  - ALPACA_PAPER_API_KEY
  - ALPACA_PAPER_SECRET_KEY
  - ALPACA_PAPER_BASE_URL
linked_services:
  - prophet-trader
linked_hosts: []
tags:
  - trading
---

# Alpaca

Stock brokerage powering [[prophet-trader]] equities trading. Paper account now; live keys (`ALPACA_LIVE_*`) only after Phase 2 review passes (90 clean paper days).

## Key facts

- No IP allowlisting on standard accounts (enterprise FIX only).
- **Key-scoping plan (pending):** separate keys per role — read-only key for monitoring/data scripts, read+write key exclusively on [[davisglobe-vps-ash-1]] for order execution. Never put the read+write key on [[jeff-laptop]].

## Open questions

- Execute the key-scoping plan (open checklist item in the prophet-trader hardening runbook).
- Record the account email/username.
