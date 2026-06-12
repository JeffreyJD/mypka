---
name: Firecrawl
status: active
account_type: api
provider_url: https://firecrawl.dev
username: ""
plan: Free tier — 500 credits/month
monthly_cost: 0
renewal_date: ""
secrets_ref: .env on davisglobe-vps-ash-1
env_var_names:
  - FIRECRAWL_API_KEY
linked_services:
  - prophet-trader
linked_hosts: []
tags:
  - trading
  - api
---

# Firecrawl

Web-scraping API feeding the macro-news layer of [[prophet-trader]]'s Daily Alpha Brief (Fed, CNBC business, MarketWatch, CoinDesk).

## Key facts

- Usage ~5 credits/run, ~110/month — comfortably inside the 500-credit free tier.
- Graceful degradation: if the key is absent the macro-news layer marks itself UNAVAILABLE; the calendar layer still runs.
- SDK pinned at `firecrawl-py` 2.16 — known gotchas documented in the repo's HANDOFF.md.

## Open questions

- Record the account email.
