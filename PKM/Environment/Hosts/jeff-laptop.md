---
name: jeff-laptop
host_type: laptop
status: active
provider: ""
os: Windows 11 Home + WSL
location: with Jeff
specs: ""
ip_public: ""
ip_lan: ""
ip_tailscale: 100.120.6.80
dns_name: laptop-k2i9ps34.tailfe9a46.ts.net
access: local
secrets_ref: local .env files per project; Claude Code standard login
renewal_date: ""
monthly_cost: ""
linked_accounts:
  - tailscale
  - anthropic
tags:
  - dev
---

# jeff-laptop

Primary development machine. Personal — **not** corporate: Claude Code uses direct Anthropic auth, no Portkey, no Bedrock, no corporate gateway.

## What runs here

- Claude Code ([[claude-code]]) — daily driver for dev and for the myPKA team.
- prophet-trader dev checkout at `C:\Users\jeff\dev\prophet-trader` (Python venv, 251 tests passing on Windows). Deployed copy runs on [[davisglobe-vps-ash-1]] — see [[prophet-trader]].
- **No scheduled jobs** — Windows Task Scheduler and WSL crontab confirmed empty 2026-06-11. All crons moved to the VPS.

## Security posture

- On the tailnet at 100.120.6.80 as `laptop-k2i9ps34` (Tailscale 1.98.4, joined 2026-06-11, key expiry 2026-12-08 — see [[tailscale]]).
- Local prophet-trader `.env` holds dev keys. Never put the Alpaca read+write key here — that key lives only on the VPS (see [[alpaca]]).

## Backups

Not documented yet — see Open questions.

## Open questions

- Document laptop make/model/specs.
- Define a backup story for the laptop (My Drive covers the PKA folders; what about `C:\Users\jeff\dev\`?).
