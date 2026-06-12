---
name: Backblaze B2
status: active
account_type: saas
provider_url: https://www.backblaze.com
username: ""
plan: B2 pay-as-you-go
monthly_cost: ""
renewal_date: ""
secrets_ref: rclone config on davisglobe-vps-ash-1
env_var_names: []
linked_services:
  - prophet-trader
linked_hosts:
  - davisglobe-vps-ash-1
tags:
  - backup
---

# Backblaze B2

Object storage holding the off-site backup of [[prophet-trader]]'s runtime state from [[davisglobe-vps-ash-1]].

## Key facts

- Bucket: `Prophet-Trader`. Daily rclone sync at 00:00 ET; log at `data/logs/backup.log` on the VPS.
- First sync tested 2026-06-11 (9 files). **Restore not yet tested.**
- Plan: add [[lighthouse]] as a second rclone destination once it is online.

## Open questions

- Test a restore before relying on this backup.
- Record account email and current monthly spend.
