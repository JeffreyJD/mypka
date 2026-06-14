# Home Network Design — Davis Residence

**Architect:** Sparky (Network Architect, myPKA team)  
**Last updated:** 2026-06-13  
**Status:** Operational — US 24 adoption pending

---

## Physical topology

```
ISP Modem/ONT
      |
  USG-Pro-4  (192.168.1.1)   ← router/firewall
      |
   US 24     (192.168.1.137) ← 24-port core switch [adoption pending]
   /    \
AP-1    AP-2                 ← dual AP AC Pro coverage
(1F LR) (2F MBR)
      |
  UCK G2+   (192.168.1.12)  ← UniFi controller
```

**Controller:** [[uck-g2-plus]] at 192.168.1.12  
Access: https://192.168.1.12 (local) · unifi.ui.com (cloud)

---

## IP address schema

| Network | VLAN | Subnet | Gateway | DHCP Range | Purpose |
|---|---|---|---|---|---|
| Default (LAN) | 1 | 192.168.1.0/24 | 192.168.1.1 | .100–.254 | Main devices |
| IoT | 20 | 192.168.2.0/24 | 192.168.2.1 | .100–.254 | Smart home, cameras, printers |
| Guest | 30 | 192.168.3.0/24 | 192.168.3.1 | .100–.254 | Visitor Wi-Fi |

### Static/reserved IPs (LAN)

| Device | IP | MAC |
|---|---|---|
| USG-Pro-4 (LAN) | 192.168.1.1 | 18:E8:29:4F:30:71 |
| UCK G2 Plus | 192.168.1.12 | — |
| US 24 | 192.168.1.137 | B4:FB:E4:20:AE:9A |
| AP First Floor | 192.168.1.114 | 78:8A:20:89:D3:ED |
| AP Second Floor | 192.168.1.110 | 78:8A:20:2C:68:75 |

---

## Device registry

| Device | Model | Role | IP | Firmware | Status |
|---|---|---|---|---|---|
| [[usg-pro-4]] | USG-Pro-4 | Router/Firewall | 192.168.1.1 | 4.4.57 | Active |
| [[us-24]] | US-24 | Core Switch | 192.168.1.137 | Unknown | Adoption failed — pending hard reset |
| [[ap-firstfloor-livingroom]] | UAP-AC-PRO | AP, 1F Living Room | 192.168.1.114 | 6.8.2 | Active |
| [[ap-secondfloor-masterbedroom]] | UAP-AC-PRO | AP, 2F Master Bed | 192.168.1.110 | 6.8.2 | Active |
| [[uck-g2-plus]] | UCK G2 Plus | UniFi Controller | 192.168.1.12 | — | Active |

---

## Wireless RF plan

| AP | Location | 2.4 GHz Ch. | 2.4 GHz Width | 5 GHz Ch. | 5 GHz Width |
|---|---|---|---|---|---|
| [[ap-firstfloor-livingroom]] | 1F Living Room | 1 | 20 MHz | **36** | 40 MHz |
| [[ap-secondfloor-masterbedroom]] | 2F Master Bedroom | 11 | 20 MHz | **149** | 40 MHz |

**Design principle:** Non-overlapping channels on both bands across all APs. 2.4 GHz uses channels 1 and 11 (both non-overlapping with each other and with channel 6). 5 GHz uses channels 36 and 149 — maximum separation to eliminate co-channel interference.

**Why this matters:** The MediaTek MT7921 Wi-Fi 6 adapter in [[jeff-laptop]] cannot handle co-channel same-SSID roaming — it stalls the data path for 1–2 minutes. Separating channels (36 vs 149) resolves this permanently. (Diagnosed and fixed 2026-06-13.)

---

## SSID register

| SSID | Network | VLAN | Bands | Fast Roaming | Purpose |
|---|---|---|---|---|---|
| Downton Abbey | Default | 1 | 2.4 + 5 GHz | Enabled (802.11r) | Main devices — laptops, phones, tablets |
| Downton Abbey-IOT | IoT | 20 | 2.4 GHz only | — | Smart home, cameras, printers |
| Downton Abbey-Guest | Guest | 30 | 2.4 + 5 GHz | — | Visitor access |

**Password storage:** All SSID passwords stored in password manager only — never written in myPKA files (GL-002 Rule 7).

---

## Firewall ruleset

All rules: **LAN In**, **Drop**, **Before Predefined**.

| Rule name | Source | Destination | Action | Purpose |
|---|---|---|---|---|
| Block IOT to LAN | 192.168.2.0/24 | 192.168.1.0/24 | Drop | IoT cannot reach main devices |
| Block Guest to LAN | 192.168.3.0/24 | 192.168.1.0/24 | Drop | Guests cannot reach main devices |
| Block Guest to IOT | 192.168.3.0/24 | 192.168.2.0/24 | Drop | Guests cannot reach IoT devices |

**Implicit allows:** LAN → IoT (allows control of smart devices from main network). IoT → internet (allowed for cloud-dependent devices).

**Note:** Switch-level VLAN isolation (per-port) is NOT yet configured — [[us-24]] adoption pending. Current isolation is enforced only at the USG firewall. Wired IoT ports are not yet isolated.

---

## Future network expansion plan

Jeff's target architecture (when expansion AP hardware arrives):

```
Per room: 2 APs
  AP-A: broadcasts IoT SSID only (2.4 GHz)
  AP-B: broadcasts Main SSID only (5 GHz+)
```

Rooms planned: Living Room (1F), Master Bedroom (2F) — already covered. Additional rooms TBD.

When 4-AP setup is in place, update RF plan to assign channels across 4 APs maintaining non-overlapping coverage.

---

## Pending items (Sparky)

1. **US 24 hard reset + adoption** — power-cycle while holding reset, SSH `set-inform`, adopt. Requires USB-to-Ethernet adapter on [[jeff-laptop]] (no native RJ45). Jeff purchasing adapter.
2. **Switch port VLAN assignment** — after adoption, assign IoT VLAN 20 to ports serving IoT devices; Guest VLAN 30 to any guest-facing ports.
3. **USG firmware update** — controller will prompt; schedule a maintenance window.
4. **Rename APs in controller** — change generic "AC Pro" names to "AP-FirstFloor-LivingRoom" and "AP-SecondFloor-MasterBedroom".
5. **DHCP reservations** — assign static IPs by MAC for all infrastructure devices.
6. **Band Steering** — evaluate after co-channel fix confirmed stable for 1 week.
7. **ACL / firewall review** — Sparky to audit complete ruleset after US 24 adoption completes.

---

## Change log

| Date | Change | Author |
|---|---|---|
| 2026-06-13 | Full network rebuild: UCK G2+ installed, all devices factory reset, adopted. Three networks + three SSIDs configured. Channels separated. Firewall rules added. | Sparky / Hawkeye |
