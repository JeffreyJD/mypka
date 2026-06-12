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
schedule: ""
env_file: /home/trader/prophet-trader/.env
env_var_names:
  - EXAMPLE_API_KEY
monitoring: ""
depends_on: []
linked_accounts:
  - example-account
tags:
  - trading
---

# Prophet Trader

## What it does

One paragraph. What this service is for and why it exists.

## How it is deployed

Runtime detail: container image, cron block, systemd unit, venv path. Enough that a rebuild from scratch is possible. `env_var_names` in frontmatter lists what the `.env` must contain — values stay on the host per [[GL-002-frontmatter-conventions]] rule 7.

## Runbook

How to check it is alive, read its logs, restart it, and what to do when it breaks.

## Open questions

Anything unconfirmed or pending.
