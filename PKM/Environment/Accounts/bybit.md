---
name: Bybit
status: active
account_type: exchange
provider_url: https://www.bybit.com
username: ""
plan: Testnet (free)
monthly_cost: 0
renewal_date: ""
secrets_ref: .env on davisglobe-vps-ash-1
env_var_names:
  - BYBIT_TESTNET_API_KEY
  - BYBIT_TESTNET_API_SECRET
  - BYBIT_TESTNET_BASE_URL
linked_services:
  - prophet-trader
linked_hosts: []
tags:
  - trading
  - crypto
---

# Bybit

Crypto exchange for [[prophet-trader]] — testnet only until Phase 2 gates pass. Live keys (`BYBIT_LIVE_*`) stay empty until then. Crypto strategy work itself is gated behind Phase 2c.

## Key facts

- No IP-restriction option on API keys (same gap as Alpaca).

## Open questions

- Record the account email/username.
