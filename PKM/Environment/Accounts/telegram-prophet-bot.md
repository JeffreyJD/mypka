---
name: Telegram (Prophet Trader bot)
status: active
account_type: bot
provider_url: https://telegram.org
username: ""
plan: Free
monthly_cost: 0
renewal_date: ""
secrets_ref: .env on davisglobe-vps-ash-1
env_var_names:
  - TELEGRAM_BOT_TOKEN
  - TELEGRAM_CHAT_ID
linked_services:
  - prophet-trader
linked_hosts: []
tags:
  - trading
  - notifications
---

# Telegram (Prophet Trader bot)

Telegram bot (created via @BotFather) that delivers [[prophet-trader]] fill alerts, crash notifications, and EOD summaries to Jeff's phone. The shell wrappers also send a curl-based alert through this bot if Python never starts.

## Key facts

- `TELEGRAM_DRY_RUN=1` during local dev logs messages instead of sending.
- Token is rotatable via @BotFather if ever exposed.

## Open questions

- Record the bot's @username.
