---
name: Hetzner
status: active
account_type: hosting
provider_url: https://www.hetzner.com/cloud
username: jeff@davisglobe.com
plan: Cloud — pay-as-you-go (hourly billing, monthly cap)
monthly_cost: 24.99
renewal_date: ""
secrets_ref: Hetzner Cloud console login; SSH key for the VPS lives on jeff-laptop
env_var_names: []
linked_services: []
linked_hosts:
  - davisglobe-vps-ash-1
tags:
  - hosting
  - cloud
---

# Hetzner

Cloud hosting provider for [[davisglobe-vps-ash-1]], the prophet-trader production VPS.

## Key facts

- Server type: **CPX31** (4 vCPU AMD / 8 GB RAM / 160 GB local disk) in Ashburn, VA — confirmed from console 2026-06-11.
- Price: **$24.99 USD/month** (console displays €20.99 EUR — Hetzner is a German company; registry tracks USD). Up from $17.99 in Hetzner's 2026-04-01 lineup-wide increase. Billing is hourly with a monthly cap — no annual renewal; cost scales if the server is resized.
- Traffic allowance: **3 TB outbound/month** included (usage 0 as of 2026-06-11).
- Server created ~2026-06-06; root password reset ~2026-06-07 during setup.
- **Hetzner native backups: OFF — by decision (Jeff, 2026-06-11).** Backblaze B2 via rclone is the backup strategy ([[backblaze-b2]]). Note the coverage gap: the B2 job syncs the prophet-trader data directory, not the OS/cron/hardening config — a full VPS loss means re-running `setup_vps.sh` + the hardening runbook in `docs/DEPLOYMENT.md`, which is documented and repeatable.

## Open questions

- _(none — see [[backblaze-b2]] for the open restore-test item)_
