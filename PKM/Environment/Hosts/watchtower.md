---
name: watchtower
host_type: physical
status: planned
provider: ""
os: TBD (Frigate host)
location: home rack (planned)
specs: Dell PowerEdge R740 2U / BOSS mirrored M.2 boot / 1TB NVMe working storage / AI-inference GPU TBD
ip_public: ""
ip_lan: 10.0.30.10
ip_tailscale: ""
dns_name: ""
access: iDRAC at 10.0.10.7 (planned)
secrets_ref: TBD at build
renewal_date: ""
monthly_cost: ""
linked_accounts: []
tags:
  - homelab
  - surveillance
---

# watchtower

Dell PowerEdge R740 — dedicated Frigate NVR surveillance server. Fully designed on paper, zero parts ordered. Next build after [[lighthouse]] reaches Phase 2–3.

**SSOT note:** architecture detail lives in `PKM/Documents/homelab/` — this is the registry view.

## What runs here (planned)

- Frigate NVR — object detection on camera streams (+ future Atlas 4 drone RTSP feed), UI on port 5000.

## Network identity (planned)

- VLAN 30 — Surveillance (10.0.30.0/24), fully isolated. Single firewall exception: 10.0.30.10 → 10.0.20.11 on NFS 2049.
- Long-term footage writes to [[lighthouse]] TrueNAS over 10GbE NFS — **locked decision** (Option B): no local long-term storage on Watchtower, only 1TB NVMe working data.

## Open questions

- All hardware still to order: chassis, BOSS card, NVMe, GPU, 10GbE NIC.
