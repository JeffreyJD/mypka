---
name: usg-pro-4
host_type: router
status: active
provider: ubiquiti
os: UniFi OS (EdgeOS-based)
location: home — wired to US 24
specs: UniFi Security Gateway Pro 4 (USG-Pro-4); 4-port GbE; hardware offload capable
ip_public: 38.148.154.29
ip_lan: 192.168.1.1
ip_tailscale: ""
dns_name: ""
access: managed via [[uck-g2-plus]] controller
secrets_ref: managed by UniFi controller; no direct credential needed
renewal_date: ""
monthly_cost: ""
mac_address: "18:E8:29:4F:30:71"
firmware: "4.4.57"
linked_accounts: []
tags:
  - network
  - unifi
  - router
---

# usg-pro-4

UniFi Security Gateway Pro 4 — the router and firewall for the Davis home network. Factory reset and adopted into [[uck-g2-plus]] on 2026-06-13. ISP connection is plain DHCP (no PPPoE credentials needed).

## Ports

- Port 1: LAN (GbE, connected to [[us-24]])
- Port 3: WAN (GbE, internet uplink — globe LED)
- Ports 2, 4: disconnected

## WAN

- Type: DHCP (ISP assigns public IP automatically)
- Current WAN IP: 38.148.154.29 (dynamic — will change on lease renewal)
- LAN gateway: 192.168.1.1

## Networks enforced

Enforces VLAN segmentation and firewall rules for three networks — see [[uck-g2-plus]] for full design.

Firewall rules (LAN In, Before Predefined) block IoT and Guest traffic from reaching the main LAN.

## Security posture

- Adopted and managed by [[uck-g2-plus]]; no direct SSH access in normal operations.
- Factory reset history: reset 2026-06-13 (old controller offline since 2021; no config backup available).
- Firmware 4.4.57 — may need update via UniFi controller.

## Open questions

- USG firmware update pending (controller will prompt when available).
- Port forwarding rules not yet configured (none needed currently).
