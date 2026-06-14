---
name: uck-g2-plus
host_type: network-controller
status: active
provider: ubiquiti
os: UniFi OS
location: home — wired to US 24
specs: UCK G2 Plus (Cloud Key Gen2 Plus); embedded UniFi Network controller + UniFi Protect capable
ip_public: ""
ip_lan: 192.168.1.12
ip_tailscale: ""
dns_name: ""
access: https://192.168.1.12 (local) or unifi.ui.com (cloud, UI account jeff@davisglobe.com)
secrets_ref: UI account credentials in password manager
renewal_date: ""
monthly_cost: ""
linked_accounts: []
tags:
  - network
  - unifi
---

# uck-g2-plus

UniFi Cloud Key Gen2 Plus — the controller for all UniFi network hardware at the Davis residence. Adopted and configured 2026-06-13 as part of the homelab network rebuild. Replaced an old controller that had been offline since ~2021.

## What it manages

All four UniFi devices are adopted under this controller:
- [[usg-pro-4]] — router/firewall
- [[us-24]] — 24-port managed switch
- [[ap-firstfloor-livingroom]] — AP AC Pro, first floor
- [[ap-secondfloor-masterbedroom]] — AP AC Pro, second floor

## Network design (as of 2026-06-13)

| Network | VLAN | Subnet | SSID | Bands |
|---|---|---|---|---|
| Default (LAN) | 1 | 192.168.1.0/24 | Downton Abbey | 2.4 + 5 GHz |
| IoT | 20 | 192.168.2.0/24 | Downton Abbey-IOT | 2.4 GHz only |
| Guest | 30 | 192.168.3.0/24 | Downton Abbey-Guest | 2.4 + 5 GHz |

**Fast Roaming (802.11r):** enabled on Downton Abbey SSID.

## Firewall rules (LAN In, Before Predefined)

- Block IoT (192.168.2.0/24) → LAN (192.168.1.0/24) — Drop
- Block Guest (192.168.3.0/24) → LAN (192.168.1.0/24) — Drop
- Block Guest (192.168.3.0/24) → IoT (192.168.2.0/24) — Drop

## Open questions

- US 24 switch adoption still failing — pending hard reset (power-cycle while holding reset). Sparky to complete via SSH when USB-to-Ethernet adapter arrives.
- UCK G2 Plus firmware version not yet recorded.
- UniFi Protect not configured (no cameras yet).
