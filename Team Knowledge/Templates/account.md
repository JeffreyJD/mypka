---
name: Alpaca
status: active
account_type: api
provider_url: https://alpaca.markets
username: jeff@example.com
plan: Paper trading (free tier)
monthly_cost: 0
renewal_date: ""
secrets_ref: .env on davisglobe-vps-ash-1
env_var_names:
  - ALPACA_PAPER_API_KEY
  - ALPACA_PAPER_SECRET_KEY
linked_services:
  - prophet-trader
linked_hosts: []
tags:
  - trading
---

# Alpaca

## What it is for

One paragraph. What this account does in your environment and which services depend on it.

## Key facts

Plan limits, quotas, key scoping decisions, billing notes. Bullet form is fine. Per [[GL-002-frontmatter-conventions]] rule 7: where the key lives, never the key.

-

## Open questions

Renewals to confirm, scopes to tighten, anything pending.
