---
name: opnsense-r340
host_type: physical
status: building
provider: eBay parts build (chassis from affordable_sol)
os: OPNsense (planned)
location: home rack (planned)
specs: Dell PowerEdge R340 1U / Xeon E-2174G / 32 GB RAM / 120 GB SATA boot SSD (Xeon E-2236 also purchased — possible CPU upgrade, unconfirmed)
ip_public: ""
ip_lan: ""
ip_tailscale: ""
dns_name: ""
access: iDRAC at 10.0.10.5 (planned)
secrets_ref: TBD at build
renewal_date: ""
monthly_cost: ""
linked_accounts: []
tags:
  - homelab
  - network
---

# opnsense-r340

Dell PowerEdge R340 — network gateway for the homelab. Chassis, CPU, and boot SSD acquired April 2026; not yet assembled. No codename assigned yet (Lighthouse/Watchtower convention — consider one).

**SSOT note:** build detail lives in `PKM/Documents/homelab/` — this is the registry view.

## What runs here (planned)

- OPNsense — gateway providing `.1` on every VLAN subnet (VLAN 10 Management, 20 Servers, 30 Surveillance, 40 Trusted, 50 IoT). Firewall rules per the homelab `network-build.md`.
- Config auto-backup to TrueNAS `backups/opnsense/` on every change (once [[lighthouse]] is live).

## Open questions

- Purpose of the extra Xeon E-2236 unconfirmed (R340 shipped with E-2174G) — upgrade or spare?
- Assembly and OPNsense install not yet scheduled.
