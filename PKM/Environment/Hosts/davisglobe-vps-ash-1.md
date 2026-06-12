---
name: davisglobe-vps-ash-1
host_type: vps
status: active
provider: hetzner
os: Ubuntu 26.04 LTS
location: Ashburn, VA
specs: Hetzner CPX31 — 4 vCPU AMD / 8 GB RAM / 160 GB disk
ip_public: 178.156.163.139
ip_public_v6: "2a01:4ff:f4:67e5::1"
ip_lan: ""
ip_tailscale: 100.91.84.117
dns_name: davisglobe-vps-ash-1.tailfe9a46.ts.net
access: ssh trader@178.156.163.139
secrets_ref: SSH key on jeff-laptop; password auth and root login disabled
renewal_date: ""
monthly_cost: 24.99
linked_accounts:
  - hetzner
  - tailscale
  - backblaze-b2
tags:
  - trading
  - cloud
---

# davisglobe-vps-ash-1

Cloud VPS running the Prophet Trader paper-trading stack. Originally planned as a Proxmox VM on [[lighthouse]]; switched to cloud for simpler setup and always-on uptime. Tagged `tag:trading` in the tailnet.

## What runs here

- [[prophet-trader]] — daily trading routine (Mon–Fri 09:30 ET) and weekly autopsy (Sun 10:00 ET) via the `trader` user's crontab, `TZ=America/New_York`.
- rclone backup job — daily 00:00 ET sync to Backblaze B2 bucket `Prophet-Trader` ([[backblaze-b2]]). Log at `data/logs/backup.log`.

## Security posture

Hardening runbook completed 2026-06-11 (full checklist in `C:\Users\jeff\dev\prophet-trader\docs\DEPLOYMENT.md` — that file is the SSOT for the runbook):

- `PermitRootLogin no`, `PasswordAuthentication no` — SSH key auth only, as user `trader`.
- UFW active: port 22/tcp allowed, everything else blocked.
- fail2ban active (defaults); unattended security upgrades active; chrony time sync.
- Tailscale v1.98.4, key expiry **disabled** (2026-06-11) — tailnet peers: jeff-laptop (100.120.6.80), phone (100.116.242.25).
- `.env` is `chmod 600`, 25 variables. Per [[GL-002-frontmatter-conventions]] rule 7, variable names are documented on [[prophet-trader]]; values live only in that file.

## Backups

rclone → Backblaze B2 `Prophet-Trader`, daily 00:00 ET. Tested 2026-06-11 (9 files uploaded). **Restore has NOT been tested** — do once before relying on it. When [[lighthouse]] comes online, add it as a second rclone destination.

## Open questions

- Alpaca key scoping pending: generate a read-only key for monitoring and keep the read+write key on this VPS only (never on the laptop). See [[alpaca]].
- Optional systemd watchdog not configured — healthchecks.io is the failure detector for now.
