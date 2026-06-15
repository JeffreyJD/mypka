# Environment - Index

The registry of Jeff's technical environment: every machine, deployed service, provider account, and tracked software in one queryable place. Built 2026-06-11 so that "which agent is on which server, what's the IP, where does the key live, when does it renew" never has to live in Jeff's head.

Inspired by the Nate Herk pattern: one Claude-readable project that holds the full infrastructure picture, so the assistant always has context when something breaks or needs changing.

## Subsections

- **Hosts/** - one file per machine you own, rent, or administer (physical server, VPS, laptop). Template: [[Templates/host]].
- **Services/** - one file per deployed thing that runs on a Host (app, container, VM, cron job). Template: [[Templates/service]].
- **Accounts/** - one file per external provider relationship (hosting, API, SaaS, exchange). Template: [[Templates/account]].
- **Software/** - software whose license, renewal, or loss you need to track. Template: [[Templates/software]].

Schemas live in [[GL-002-frontmatter-conventions]] (Hosts, Services, Accounts, Software sections).

## Secrets policy (rule 7 — locked 2026-06-11)

**No credential value is ever written into this folder.** It syncs to cloud storage. Files carry `secrets_ref` (where the credential lives), `env_var_names` (variable names only), and `license_ref`. Usernames, IPs, ports, and URLs are fine — the door, not the key. Agreed fallback if pointers prove too slow: hybrid, low-risk LAN-only credentials inline after an explicit user decision. See [[GL-002-frontmatter-conventions]] §Core rules 7.

## Active files

### Hosts
- [[davisglobe-vps-ash-1]] — cloud VPS, prophet-trader production (active)
- [[jeff-laptop]] — primary dev machine (active)
- [[lighthouse]] — Dell R730 Proxmox hypervisor (building)
- [[watchtower]] — Dell R740 Frigate NVR (planned)
- [[opnsense-r340]] — Dell R340 network gateway (building)
- [[uck-g2-plus]] — UniFi Cloud Key Gen2 Plus, home network controller (active)
- [[usg-pro-4]] — UniFi Security Gateway Pro 4, home router/firewall (active)
- [[us-24]] — UniFi Switch 24, core switch (adoption pending — hard reset required)
- [[ap-firstfloor-livingroom]] — UniFi AP AC Pro, 1F living room, ch. 36 5GHz (active)
- [[ap-secondfloor-masterbedroom]] — UniFi AP AC Pro, 2F master bedroom, ch. 149 5GHz (active)

### Services
- [[prophet-trader]] — AI trading system on davisglobe-vps-ash-1 (active, Phase 2 paper)

### Accounts
- [[hetzner]] — cloud hosting (the VPS provider) · [[alpaca]] — stock brokerage (paper) · [[bybit]] — crypto exchange (testnet) · [[firecrawl]] — scraping API · [[healthchecks-io]] — dead-man's switch · [[telegram-prophet-bot]] — alert bot · [[backblaze-b2]] — off-site backup · [[tailscale]] — mesh VPN · [[anthropic]] — Claude access

### Software
- [[claude-code]] — Anthropic CLI agent

## Open questions (registry-wide)

- Alpaca key scoping (read-only monitoring key vs VPS-only read+write key) still pending — see [[alpaca]].
- Backblaze B2 restore never tested — see [[backblaze-b2]].
- Tailscale ACL policy unreviewed; phone key re-auths 2026-07-31 — see [[tailscale]].
- Homelab service notes (TrueNAS, AdGuard, Jellyfin, Frigate, etc.) get created as each service actually deploys — planned services live in the body of their Host note until then.

## Network design

Full network design document: [[network-design]] — IP schema, VLAN register, RF plan, firewall ruleset, device registry, and expansion roadmap.

## Resolved this session (2026-06-11)

- VPS provider confirmed: Hetzner CPX31, Ashburn, $24.99 USD/mo (console shows €20.99 EUR) — [[hetzner]].
- Hetzner native backups: OFF by decision; [[backblaze-b2]] is the backup strategy.
- Tailscale login identity recorded (Google SSO, jeffreyj2490@gmail.com) and device table filled from CSV export.
- Tailscale key expiry disabled on [[davisglobe-vps-ash-1]] — the silent-drop-off risk is closed.

## How this section stays in sync

- New machine, VPS, account, or subscription → copy the matching template, fill what you know, link it here.
- When a homelab VM/container goes live on [[lighthouse]] or [[watchtower]], it gets a Service note that moment.
- Hawkeye's Librarian pass checks this INDEX against the folder at session close.
- Build-tracker detail for the homelab stays in `PKM/Documents/homelab/` (SSOT); these notes are the registry view and link out.
