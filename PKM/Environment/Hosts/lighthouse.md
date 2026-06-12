---
name: lighthouse
host_type: physical
status: building
provider: eBay parts build (chassis from TechKabob)
os: Proxmox (planned)
location: home rack
specs: Dell PowerEdge R730 2U / 128 GB DDR4 ECC / target 2x Xeon E5-2699 v4 (44c/88t) / 2x SM863a 480GB boot mirror / 4x SN850X 1TB NVMe (planned) / 6x 6TB SAS RAIDZ2 (~24TB usable)
ip_public: ""
ip_lan: 10.0.20.10
ip_tailscale: ""
dns_name: ""
access: iDRAC at 10.0.10.6; Proxmox web UI at 10.0.20.10 (planned)
secrets_ref: iDRAC license pending; credentials TBD at assembly
renewal_date: ""
monthly_cost: ""
linked_accounts: []
tags:
  - homelab
---

# lighthouse

Dell PowerEdge R730 — primary Proxmox hypervisor for the homelab. "The light." Mid-build: ~60% of Phase 1 parts acquired, nothing assembled yet as of the April 2026 handoff.

**SSOT note:** detailed build state (parts, orders, compatibility decisions, phased milestones) lives in `C:\Users\jeff\My Drive\PKA-Jeffrey\homelab\` (`build-log.md`, `parts-compatibility.md`, `network-build.md`, `network-schema.md`). This note is the registry view; do not duplicate the build tracker here.

## Network identity (from homelab network-schema)

- Proxmox host: 10.0.20.10 (VLAN 20 — Servers)
- iDRAC: 10.0.10.6 (VLAN 10 — Management)
- 10GbE via Intel X710-DA4 NDC to USW-Aggregation core switch

## What runs here (planned)

VM/LXC allocations once built — each becomes a Service note when actually deployed:

- TrueNAS SCALE VM (10.0.20.11) — H730P passthrough, datapool RAIDZ2, NFS exports
- Docker LXC — Jellyfin (8096/8920), Immich (2283), Nextcloud, PostgreSQL, Redis
- AdGuard Home VM (10.0.20.53), Tailscale subnet-router VM (10.0.20.100)
- AI LXC (Phase 6) — Ollama + Open WebUI on RTX 3060 12GB
- Prophet Trader Stage 3+ — live trading is planned to move here from [[davisglobe-vps-ash-1]] ("a misbehaving bot on Lighthouse you can walk into your office and unplug")

## Security posture

Not yet applicable — not assembled. iDRAC 8 Enterprise license ordered but BLOCKED on service-tag reply to seller (motorfixit).

## Backups

Planned: Proxmox backups to TrueNAS datapool/backups, 7 daily / 4 weekly / 3 monthly. Will also become the second rclone destination for the VPS.

## Open questions

- BIOS must reach 2.10.0 before ordering production E5-2699 v4 CPUs (matched SR2JS pair).
- NVMe pool design: single 4-drive striped-mirror vs. two 2-drive mirrors — Jeff's call, still open.
- iDRAC license blocked on motorfixit service-tag reply.
