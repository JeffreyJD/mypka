# Homelab Network Build — OPNsense on R340

**Owner:** Trapper
**Status:** Between Phase 0 (Planning & Procurement) and Phase 1 (R340 Hardware Staging)
**Source:** EXPORT 2 handoff, ingested 2026-04-17
**Authoritative references:** `network_architecture.md`, `Homelab Network Redesign - Phased Project Plan.docx`, `Purchase Tracker.md`
**Cross-reference:** `homelab/build-log.md` (R730 Lighthouse/R740 Watchtower server builds — separate project), `homelab/network-schema.md`, `homelab/parts-compatibility.md`

---

## 0. TL;DR

**Goal:** Replace incumbent Ubiquiti USG Pro with OPNsense running bare-metal on a Dell PowerEdge R340. Add full VLAN segmentation (6 VLANs), inline IPS (Suricata), community blocklist (CrowdSec), layered DNS (AdGuard → Unbound → DoT), Tailscale remote access, and dual-WAN failover (fiber + LTE).

**Current gating item:** R340 chassis + Intel X710-DA4 NIC arrival. Cutover has NOT happened. Phases 1–5 are explicitly non-disruptive. Phase 6 is the only outage window.

### Non-negotiable design rules (do not re-litigate)

- Tailscale runs on a dedicated Lighthouse VM, NOT on OPNsense. Keeps failure domains independent — router can reboot without killing remote access.
- All DNS must traverse AdGuard → Unbound → DoT. Enforced via firewall rule blocking outbound port 53 to anything except AdGuard. Devices with hardcoded DNS get transparently redirected.
- Unifi controller (Cloud Key Gen 2 Plus) is independent of the Proxmox stack. Do not virtualize it. Backs up to Lighthouse NFS, but runs on its own hardware.
- IP scheme is `10.0.X.0/24`, where X = VLAN ID (10, 20, 30, 40, 50, 60). Any doc that says 192.168.x.x is stale — use 10.0.x.x.

---

## 1. Network Topology

### Physical flow

```
V-net Fiber ONT ─► R340 X710-DA4 Port 1 (WAN1, 10GbE SFP+)
                      │
                 ┌────┴────[OPNsense]────┬────────────────────────┐
                 │                       │                        │
      X710-DA4 Port 2 (Server Trunk)   X710-DA4 Port 3           X710-DA4 Port 4
      │                                (Client Trunk)            (WAN2 / LTE)
      ▼                                ▼                         ▼
   USW-Aggregation                  US-24                      GL-X3000
   (8x SFP+ 10GbE)                  (24x 1GbE + 2x SFP)        (5G/4G LTE)
      │                                │
      ├─► Lighthouse (R730)            ├─► Workstations/laptops (VLAN 40)
      ├─► Watchtower (R740)            ├─► Unifi APs (VLAN 40/50/60 via SSID)
      └─► Cloud Key Gen 2 Plus         ├─► IoT devices (VLAN 50)
                                       └─► Guest WiFi (VLAN 60)
OOB: R340 onboard i350 em0 ──► Management VLAN (dedicated)
```

### Switch roles

- **USW-Aggregation** (Ubiquiti, 8x SFP+ 10GbE, L2, fanless, 1U) — core switch, carries Server VLANs 10/20/30. Replaces incumbent MikroTik CRS305. Managed by Cloud Key.
- **US-24** (Ubiquiti, 24x 1GbE + 2x SFP, managed) — distribution switch, carries Client VLANs 10/40/50/60. Existing hardware. Managed by Cloud Key.
- **Cloud Key Gen 2 Plus** — runs Unifi Network + Protect. 1TB internal HDD. Independent of Proxmox. Daily auto-backup to Lighthouse NFS. Losing it unbacked = full rebuild of every switch + AP config.

### R340 port assignment (authoritative)

X710-DA4 fills the R340's single PCIe x8 low-profile slot. All four 10GbE SFP+ ports come from it. Onboard i350 dual-port 1GbE NIC is freed for management.

| Port | Iface | Speed | Role | Connects To | Notes |
|---|---|---|---|---|---|
| X710-DA4 Port 1 | ix0 | 10GbE | WAN1 | V-net ISP modem/ONT | Primary WAN. Suricata IPS inline. |
| X710-DA4 Port 2 | ix1 | 10GbE | SERVER_TRUNK | USW-Aggregation Port 1 | Tagged 10/20/30. DAC cable. |
| X710-DA4 Port 3 | ix2 | 10GbE | CLIENT_TRUNK | US-24 SFP Port 1 | Tagged 10/40/50/60. 1GbE SFP DAC. |
| X710-DA4 Port 4 | ix3 | 10GbE | WAN2 | GL-X3000 LTE (Ethernet WAN-out) | LTE failover. Gateway group Tier 2. |
| Onboard i350 Port 1 | em0 | 1GbE | OOB MGMT | Management VLAN port | Dedicated, independent of WAN. |
| Onboard i350 Port 2 | em1 | 1GbE | Spare | — | Disabled for now. |

---

## 2. VLAN Design

| ID | Name | Subnet | Gateway | Trunk | Devices | Firewall Intent |
|---|---|---|---|---|---|---|
| 10 | Management | 10.0.10.0/24 | 10.0.10.1 | Both | iDRAC, switch mgmt, Cloud Key, OPNsense OOB | Admin only. No internet. Inbound locked to trusted source IPs. |
| 20 | Servers | 10.0.20.0/24 | 10.0.20.1 | USW-Agg | Lighthouse (Proxmox), Watchtower NFS target | Outbound anywhere. Inbound only from VLAN 10 and VLAN 40 on specific ports. |
| 30 | Surveillance | 10.0.30.0/24 | 10.0.30.1 | USW-Agg | Watchtower, IP cameras, drones | Outbound only to NTP + firmware-update domains. Zero lateral movement. |
| 40 | Trusted | 10.0.40.0/24 | 10.0.40.1 | US-24 | Workstations, laptops, phones | Full internet. Reach VLAN 20 on Jellyfin/Nextcloud/Immich/SSH only. No reach to VLAN 30. |
| 50 | IoT | 10.0.50.0/24 | 10.0.50.1 | US-24 | Smart-home devices, Home Assistant | No direct internet for devices. HA reachable from VLAN 40 only. |
| 60 | Guest | 10.0.60.0/24 | 10.0.60.1 | US-24 | Guest WiFi clients | Internet only. Hard-block to all RFC1918. |

### IP reservation conventions

- `.1` = OPNsense gateway on every VLAN.
- VLAN 10: `.5–.20` = infrastructure (iDRAC R340/R730/R740, switches, Cloud Key).
- VLAN 20: `.10` = Lighthouse primary; `.53` = AdGuard Home VM; `.100` = Tailscale VM.
- VLAN 30: `.10` = Watchtower.
- VLAN 40/50/60: DHCP pool `.100–.200`. VLAN 50 has `.10` statically reserved for Home Assistant.

### Key firewall rules (authoritative)

- Block outbound port 53 (TCP+UDP) from every VLAN except to AdGuard Home IP (`10.0.20.53`). Forces all devices through the filter chain regardless of hardcoded DNS.
- Block VLAN 30 (Surveillance) from initiating any connection to any internal VLAN — cameras are fully lateral-isolated.
- Block VLAN 50 (IoT) from direct internet — devices talk through Home Assistant only.
- Block VLAN 60 (Guest) to all RFC1918 ranges — internet only.
- VLAN 10 (Management) inbound restricted to a small set of trusted source IPs.
- Default-deny inter-VLAN with explicit allows for specific ports.

---

## 3. Hardware Inventory

### 3a. Core network hardware

| Role | Device | Key Specs / Part # | Status |
|---|---|---|---|
| Router / Firewall | Dell PowerEdge R340 | Xeon E-2136 or E-2236 (6c/12t), 32GB DDR4 ECC, 8-bay SFF, dual PSU, iDRAC9 Enterprise. Bare-metal OPNsense. | Inbound (tracked in server-build project). Chassis + E-2236 + 120GB SSD + extra caddy were shipping Apr 1–4 per prior handoff notes. **Verify arrival before Phase 1.** |
| NIC (R340) | Intel X710-DA4 | Quad-port 10GbE SFP+, PCIe x8 low profile. Dell OEM P/N: DDJKY or PGRFV. | Inbound per prior handoff notes — **confirm receipt**. Low-profile bracket required for R340 1U. |
| Boot Drive (R340) | Dell 394XT 120GB SSD | Intel S3520 enterprise SATA + hot-swap caddy. | 1 boot + 1 cold spare on shelf (per plan). **Verify both on hand.** |
| Core switch | Ubiquiti USW-Aggregation | 8x SFP+ 10GbE, L2, fanless, 1U. | **Need to confirm in hand** — replaces MikroTik CRS305. |
| Client switch | Ubiquiti US-24 | 24x 1GbE + 2x SFP, managed. | On hand (existing hardware). |
| Unifi controller | Cloud Key Gen 2 Plus | Unifi Network + Protect, 1TB HDD. | On hand (existing). |
| LTE Failover | GL.iNet GL-X3000 | 5G NR / 4G LTE, dual SIM, Ethernet WAN-out. | **Needs two SIM cards installed before Phase 7.** |
| UPS | APC BE600M1 | 600VA sine wave, USB. | On hand (existing). OPNsense will monitor via os-nut plugin. |

### 3b. Servers the network must serve

| Role | Device | Notes |
|---|---|---|
| Primary server | Dell PowerEdge R730 "Lighthouse" | Dual E5-2699 v4, 128GB DDR4. Proxmox host. Runs TrueNAS SCALE, Jellyfin, Immich, Home Assistant, Nextcloud, Ollama/Open WebUI, AdGuard Home VM, Tailscale VM. Separate build project — arrived Tue Apr 14 @ 5:45 PM (UPS tracking 1Z14V49E0332003370) after wrong-unit/reship saga with seller techkabob. |
| AI / Surveillance | Dell PowerEdge R740 "Watchtower" | Dedicated Frigate NVR. Writes footage over 10GbE NFS to Lighthouse TrueNAS. BOSS-card boot, 1TB NVMe for VM storage. |

### 3c. Cabling (inventory before Phase 1)

- SFP+ DAC, R340 Port 2 ↔ USW-Aggregation Port 1 — 10GbE server trunk.
- SFP+ DAC, R340 Port 3 ↔ US-24 SFP Port 1 — **this is a 1GbE SFP DAC** (US-24 uplink is 1GbE, not 10GbE). Do not assume 10G DAC — US-24 SFP is 1G only.
- SFP+ transceiver or DAC, R340 Port 1 ↔ V-net ISP modem/ONT — gated on whether V-net ONT has an SFP+ cage. Fallback: copper-to-SFP+ adapter, or temporarily use onboard i350 for WAN1 until adapter arrives.
- Ethernet patch, GL-X3000 → R340 Port 4 — for WAN2 LTE failover (Phase 7).
- Ethernet patch, R340 i350 em0 → Management VLAN access port — OOB management.

### 3d. Lighthouse parts purchased 2026-03-30/31 on eBay

All shipped to 1323 East 32nd Street, Erie PA 16504. Total charged: **$166.90** (after $491.18 in coupons/discounts against $530.37 subtotal) to card ending -0817. All seven orders delivered as of Tue Apr 14, 2026.

| Item | Order # | Price | Seller | Delivered |
|---|---|---|---|---|
| Samsung SM863a 480GB SSD (MZ7KM480HMHQ-00005) | 06-14444-27360 | $39.99 | thepowerhouseofelectronics | Thu Apr 02 16:38 (UPS) |
| Intel Xeon E5-2620 V3 x2 (LGA2011-3) | 06-14444-27361 | $6.45 | cachencarry | Fri Apr 03 17:23 (USPS) |
| Samsung SM863a 480GB SSD (2nd, MZ7KM480HMHQ) | 06-14444-27362 | $50.00 | ctrlplusit | Thu Apr 02 14:51 (USPS) |
| Dell iDRAC 7-10 Enterprise License (iDRAC 8) | 06-14444-27363 | $13.99 | motorfixit | Immediate digital — pickup code 885219 |
| Dell R730XD w/ 128GB RAM (no drive/OS/CPU/RAID) | 06-14444-27364 | $399.99 | techkabob | Tue Apr 14 17:45 (UPS 1Z14V49E0332003370) — reship; see note |
| Dell PERC H730P Mini RAID Controller (07H4CN) | 06-14444-27365 | $19.95 | januarius | Thu Apr 02 14:51 (USPS) |
| Dell 3.5" HDD Caddies (2.5"→3.5" adapters) | 19-14428-61020 unknown | — | reservertech | Mon Apr 06 17:25 (USPS) |

**R730 reship note (resolved):** techkabob originally shipped the wrong server on Apr 3 via FedEx (380193490108) — an SFF/2.5" unit instead of the R730XD LFF. After Jeff reported it, they reshipped the correct LFF unit on Apr 10 via UPS, delivered Apr 14. Return label for the wrong unit was in the original box.

**Not in this tracker:** later-order eBay shipments (X710-DA4 NIC, R730 heatsink, etc.) belong to a separate purchase cycle. Confirm with the server-build project tracker for those.

---

## 4. Configuration Decisions

### 4a. OPNsense

- Install method: iDRAC9 virtual media (mount ISO remotely) onto Dell 394XT 120GB SSD.
- Latest stable release, FreeBSD-based.
- Interface naming (renamed from ix0–ix3 / em0–em1 at install): `WAN1`, `SERVER_TRUNK`, `CLIENT_TRUNK`, `WAN2`, `MGMT`, `SPARE`.
- 30 local versioned config revisions kept on boot SSD; auto-backup to Lighthouse NFS on every config change (Phase 8).

### 4b. Suricata (os-suricata)

- IPS mode, inline on WAN1 and on the IoT VLAN interface (east-west inspection).
- Rulesets: ET Open, abuse.ch SSL Blacklist, Feodo Tracker C2.
- Pattern matcher: Hyperscan (required for R340 performance).
- HOME_NET = all 10.0.x.0/24 ranges.
- Install only after Phase 2 passes; validate against a test network or the ISP modem before cutover to avoid breaking legitimate traffic on day one.

### 4c. CrowdSec (os-crowdsec)

- Plugin + firewall bouncer enabled — blocks known-bad IPs at the firewall layer before Suricata inspects.
- Instance enrolled with CrowdSec console account.
- HTTP and SSH scenario parsers enabled.
- Verify console shows the instance reporting before moving on.

### 4d. Unbound (OPNsense built-in)

- Bind to all VLAN interfaces.
- Internal zone: `home.lan`, DNSSEC validation on.
- Upstream forwarders over DoT: Quad9 (`9.9.9.9:853`) + Cloudflare (`1.1.1.1:853`).
- HaGeZi Multi PRO blocklist enabled as baseline filter until AdGuard Home is live.

**Host overrides (configure during Phase 2):**

- `lighthouse.home.lan` → 10.0.20.10
- `watchtower.home.lan` → 10.0.30.10
- `jellyfin.home.lan` → 10.0.20.10
- `immich.home.lan` → 10.0.20.10
- `nextcloud.home.lan` → 10.0.20.10
- `homeassistant.home.lan` → 10.0.50.10 (port 8123)
- `idrac-r340.home.lan` → 10.0.10.5
- `idrac-r730.home.lan` → 10.0.10.6
- `idrac-r740.home.lan` → 10.0.10.7

### 4e. AdGuard Home

- Runs as Debian 12 VM on Lighthouse Proxmox. 2 vCPUs, 2GB RAM, 20GB disk. Static IP `10.0.20.53` on VLAN 20.
- Upstream → OPNsense Unbound (`10.0.20.1`).
- Blocklists: AdGuard Base, EasyList, EasyPrivacy, OISD Big, HaGeZi Multi PRO.
- Per-device analytics enabled (uses OPNsense DHCP hostnames).
- DNSSEC forwarding validation on.
- All VLAN DHCP scopes point to `10.0.20.53` for DNS (set at cutover, not before).

### 4f. Tailscale

- Runs as dedicated lightweight Debian 12 VM on Lighthouse Proxmox — 2 vCPUs, 1GB RAM, 10GB disk. Suggested IP `10.0.20.100` on VLAN 20.
- **Do NOT install Tailscale on OPNsense.** Keeps failure domains independent; router reboots don't kill remote access.
- Advertises all six VLAN subnets as Tailscale routes: `10.0.10.0/24,10.0.20.0/24,10.0.30.0/24,10.0.40.0/24,10.0.50.0/24,10.0.60.0/24`. Routes approved in Tailscale admin console. Key expiry disabled on this node.
- Split DNS: `home.lan` → AdGuard Home Tailscale IP — internal names resolve when remote.

### 4g. Zenarmor (optional, free tier)

- Enabled on IoT and Guest interfaces for application-visibility dashboard. MongoDB backend. Free tier is sufficient for homelab needs.

### 4h. Dual WAN failover

- WAN1 = V-net fiber on `ix0` (DHCP or PPPoE per V-net requirements; confirm MTU 1500 vs. tagged VLAN from ONT).
- WAN2 = GL-X3000 LTE on `ix3`.
- Gateway group with WAN1 Tier 1 / WAN2 Tier 2. Monitor IPs: WAN1 watches 8.8.8.8, WAN2 watches 1.1.1.1. Gateway group applied to default outbound firewall rule. Tune latency/packet-loss thresholds for realistic failover.

### 4i. UPS / NUT

- Install os-nut plugin. APC BE600M1 connected via USB to R340. Shutdown threshold 20% battery. Test by simulating power loss.

### 4j. Backup strategy

- **OPNsense:** auto-backup to Lighthouse NFS on every config change; 30 local versioned revisions on boot SSD; cold spare 394XT SSD on shelf labeled "OPNsense Cold Spare — [date]" → recovery target 30 minutes.
- **Unifi (Cloud Key):** daily auto-backup to Lighthouse NFS share. Contains VLAN profiles, port assignments, AP configs, switch configs. Losing this unbacked = full rebuild.
- **Switch configs:** live inside Cloud Key controller DB — covered by Unifi backup.

---

## 5. Current Status by Component

| Component | Status |
|---|---|
| Architecture document | ✅ Finalized (`network_architecture.md`) |
| Phased project plan (10 phases) | ✅ Finalized (`Homelab Network Redesign - Phased Project Plan.docx`) |
| Lighthouse (R730) chassis + RAM | ✅ Delivered Apr 14 — populating with SM863a SSDs, E5-2620 v3 CPUs, H730P RAID, HDD caddies, iDRAC 8 Enterprise license (pickup code 885219) |
| R340 (OPNsense host) | 🟡 Procurement reportedly underway (tracked in server-build project). Gating item for Phase 1. Verify chassis + E-2236 CPU + 120GB 394XT SSD x2 + caddy are on hand. |
| Intel X710-DA4 NIC (DDJKY/PGRFV) | 🟡 Inbound per prior notes. Gating item for Phase 1. Confirm low-profile bracket. |
| USW-Aggregation | 🟡 Confirm in hand before Phase 4. |
| US-24 | ✅ On hand (existing). |
| Cloud Key Gen 2 Plus | ✅ On hand (existing). |
| GL-X3000 LTE router | 🟡 Verify on hand + two SIMs active before Phase 7. |
| APC BE600M1 UPS | ✅ On hand. |
| SFP+ cabling | 🟡 Inventory before Phase 1: DAC for server trunk (10G), DAC/transceiver for client trunk (1G), WAN1 SFP+ option depends on V-net ONT. |
| V-net ONT SFP+ support | ❓ Unknown — must confirm. If no SFP+ cage, need copper-to-SFP+ adapter or plan to use i350 em0/em1 temporarily for WAN1. |
| OPNsense install | ⏳ Not started — Phase 1. |
| VLANs / Unbound / firewall rules | ⏳ Not started — Phase 2. |
| Suricata / CrowdSec / Zenarmor | ⏳ Not started — Phase 3. |
| Unifi switch VLAN provisioning | ⏳ Not started — Phase 4. |
| AdGuard Home VM on Lighthouse | ⏳ Not started — Phase 5 (depends on Lighthouse being up). |
| Cutover from USG Pro | ⏳ Not started — Phase 6. USG Pro still routing. |
| Tailscale VM + WAN2 failover | ⏳ Not started — Phase 7. |
| Backup automation | ⏳ Not started — Phase 8. |
| Hardening / validation | ⏳ Not started — Phase 9. |

---

## 6. Open Items & Next Actions

### Immediate (Phase 0 completion)

1. Audit the existing network before any physical changes: export USG Pro config, export full Unifi controller backup, record all current DHCP leases / static IPs / port forwards, photograph all switch cabling and port assignments.
2. Verify R340 + X710-DA4 are actually in hand and that the NIC has a low-profile bracket (required by the R340 1U chassis).
3. Confirm V-net ONT SFP+ support — determines whether WAN1 is SFP+ direct, SFP+ via copper adapter, or temporary fallback on i350.
4. Confirm USW-Aggregation on hand. If not, order before Phase 4 or cutover slips.
5. Confirm GL-X3000 has two active SIMs before Phase 7.
6. Verify iDRAC9 Enterprise license is live on the R340 and virtual media is accessible (required for OPNsense install method).
7. Download OPNsense amd64 ISO and verify SHA256.
8. Schedule 2–4 hour maintenance window for the Phase 6 cutover.

### Longer-lead / watch items

- Lighthouse TrueNAS NFS share must exist before Phase 5 (AdGuard) — backup target for both OPNsense and Cloud Key. Dependency on the server-build project.
- Management VLAN trusted source-IP list — firewall rule restricting VLAN 10 inbound needs concrete list of trusted IPs before Phase 9.

### Known documentation inconsistencies to watch

- The phased plan's Phase 2 step mentions a temporary LAN IP of `192.168.1.1` during OPNsense install-time web-UI access. That is a **one-time bootstrap IP** for a laptop-to-R340 web-UI connection during install, not the production scheme. Production is `10.0.x.0/24`.
- Phase 2 lists VLAN 10 on both SERVER_TRUNK and CLIENT_TRUNK with a note "same VLAN, different trunk — or bridge to above." Decide at implementation time: simplest is to put VLAN 10 on both trunks as tagged and let the switches handle it. **Document the choice when made.**

---

## 7. Design Principles & Recovery

### Design principles (do not violate)

- **Live-network safety:** Phases 0–5 must not break the existing network. USG Pro is the rollback target through Phase 5 and stays powered-but-disconnected for 48 hours after cutover as a hot rollback.
- **Independent failure domains:** Tailscale off-box from OPNsense; Cloud Key off-box from Proxmox; backups land on separate NFS share.
- **Staged validation:** Every phase has defined success criteria. Do not advance past failing criteria — this is how the whole thing stays recoverable.

### Recovery expectations

- **R340 boot-drive failure:** swap 394XT SSD from cold spare on shelf, reinstall OPNsense via iDRAC9 virtual media, restore config from Lighthouse NFS. Target 30 minutes.
- **Cloud Key failure:** restore latest daily backup from NFS share to replacement Cloud Key.
- **Network fully hosed:** reconnect USG Pro (kept as emergency spare post-Phase 9) → network comes back; then diagnose.

### Naming conventions

- Servers: `<name>.home.lan` (e.g. `lighthouse.home.lan`).
- Services: `<service>.home.lan` (e.g. `jellyfin.home.lan`) — often CNAMEs/A records to host IP.
- Management: `<device-type>-<model>.home.lan` (e.g. `idrac-r340.home.lan`, `switch-agg.home.lan`).

### Cross-project boundary

- **This project owns:** OPNsense R340, switches, Cloud Key, LTE router, UPS, cabling, DNS chain config, Tailscale VM config, firewall rules, backup wiring for network gear.
- **This project depends on, but does not own:** Lighthouse (R730) and Watchtower (R740) builds. Those are the subject of a separate server-build handoff. If that doc is missing, the Lighthouse parts inventory in §3d is the fallback.

### Referenced source files (prior session's workspace — not in mypka)

- `/sessions/awesome-dreamy-bohr/mnt/Homelab Network Build/network_architecture.docx`
- `/sessions/awesome-dreamy-bohr/mnt/Homelab Network Build/Homelab Network Redesign - Phased Project Plan.docx`
- `/sessions/awesome-dreamy-bohr/mnt/Homelab Network Build/Purchase Tracker.md`

**Rule of precedence:** If any detail in this file conflicts with the phased project plan docx, **the docx wins** — it is the one being executed against.
