---
name: healthchecks.io
status: active
account_type: saas
provider_url: https://healthchecks.io
username: ""
plan: Free
monthly_cost: 0
renewal_date: ""
secrets_ref: ping URLs in .env on davisglobe-vps-ash-1
env_var_names:
  - HEALTHCHECKS_URL
  - HEALTHCHECKS_AUTOPSY_URL
linked_services:
  - prophet-trader
linked_hosts: []
tags:
  - trading
  - monitoring
---

# healthchecks.io

Dead-man's switch for [[prophet-trader]]. The only monitoring layer that catches "the machine never ran at all" — Telegram alerts only fire if Python starts.

## Key facts

- Two checks, both verified HTTP 200 on 2026-06-11:
  - **Prophet Trader - Daily Routine** — expected Mon–Fri 09:30 ET, 30 min grace.
  - **Prophet Trader - Weekly Autopsy** — expected Sun 10:00 ET, 60 min grace.
- Pinged at start, success, and fail by the routine and autopsy scripts.

## Open questions

- Record the account email and where alert notifications are delivered.
