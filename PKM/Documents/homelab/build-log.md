# Homelab Build Log

Last updated: 2026-05-05
Maintained by: Trapper

> **2026-04-17 reconciliation:** Build log rewritten from authoritative
> Export 1 handoff (see `team-inbox/reference-intake/2026-04-17_export1_homelab_servers_handoff.md`).
> Prior log incorrectly showed several Lighthouse components as "Installed" —
> nothing is physically assembled yet.
>
> **2026-04-17 chassis inspection update:** Chassis arrived and on inspection
> was found to be an **R730XD** (not R730), with **4x 32GB DDR4-2666** (not
> 8x 16GB DDR4-2400), and **YY2R8 heatsinks already installed**. See
> `reference-docs/Lighthouse_R730XD_PKA_Update_April_2026.md` and
> `leader-inbox/2026-04-17-lighthouse-r730xd-chassis-upgrade.md` for the full
> deviation list. All downstream compatibility holds; shopping list adjusted.

---

## R730XD "Lighthouse" — Primary Hypervisor

**Codename:** Lighthouse ("the light")
**Role:** Primary Proxmox hypervisor, TrueNAS SCALE VM, services, AI inference (Phase 6)
**Current state:** Phase 3 complete as of 2026-05-05. E5-2699 v4 CPUs installed. BIOS at 2.19.0. H730P Mini Mono installed. iDRAC Enterprise licensed and web UI live at 192.168.1.200 (temporary — will move to 10.0.10.6 when OPNsense is configured). Boot drives blocked pending SAS cables + rear flex bay cable arriving 2026-05-07 to 2026-05-14.

**Build session log:**
- 2026-05-02/03: BIOS updated to 2.19.0 via UEFI Shell EFI method. Temp E5-2620 v3 CPUs installed. H730P Mini Mono installed. Boot drive install blocked — missing backplane SAS cables and rear flex bay cable.
- 2026-05-05: Production E5-2699 v4 CPUs installed (swapped from temp v3s). ePSA full diagnostic run — passed with fan warning (SEL cleared) and error 2000-0251 (iDRAC not initialized — resolved). iDRAC factory reset, firmware confirmed 2.63.60 (Build 6), IP corrected to 192.168.1.200, Enterprise license applied, default password changed. SAS cables + rear flex bay cable ordered.

**iDRAC firmware (confirmed 2026-05-05):**
- iDRAC Settings Version: 2.40.40.05
- iDRAC Firmware Version: 2.63.60 (Build 6)

**Chassis specifics (as-received):**
- Dell PowerEdge R730XD, 13th Gen, 2U, **31.5"** deep
- 12x 3.5" LFF hot-swap bays (front) + 2x 2.5" SFF hot-swap bays (rear) = **14 total bays**
- 2x 750W EPP PSUs, N+1 redundant, 1500W combined
- 4x 32GB DDR4-2666 ECC RDIMM 2Rx4 (Samsung M393A4K40BB2-CTD) = 128GB, downclocks to 2400 MHz (no perf penalty — 2400 is max on this platform)
- 2x Dell YY2R8 165W heatsinks already installed
- NDC slot: empty (ready for X710-DA4)
- PCIe: Riser 1 slots 1–3 full-height (GPUs), Riser 2 slots 4–7 mixed (NVMe carrier in slot 5)
- Memory upgrade ceiling: 24x 32GB = 768GB max

### Shipped / In-hand (Phase 1 Foundation)

| Date arriving | Item | Part/Model | Status | Source |
|---|---|---|---|---|
| Received | R730XD chassis + 128GB RAM (4x 32GB DDR4-2666 ECC RDIMM) + 2x YY2R8 heatsinks + 2x 750W EPP PSUs | Dell PowerEdge R730XD | Received & inspected | TechKabob — $456.64 |
| Delivered | Temp CPUs (BIOS update insurance) | 2x Intel Xeon E5-2620 v3 (6c/12t each) | Shipped (USPS) | Cache&Carry — $9.95 |
| Delivered | RAID/HBA controller | Dell H730P Mini Mono | Shipped (USPS) | januarius — $19.95 |
| Delivered | Boot SSD #1 | Samsung 480GB SATA SM863a enterprise | Shipped (UPS) | thepowerhouseofelectronics — $49.99 |
| Delivered | Boot SSD #2 | Samsung 480GB SATA SM863a enterprise | Shipped (USPS) | ctrlplusit — $50.00 |
| Apr 15 | CPU heatsinks (165W) — **RECONCILE** | 2x Dell 0YY2R8 | Shipped (UPS) | minnesotacompu — ⚠️ duplicate? chassis already has YY2R8 installed |
| Apr 14–20 | 10GbE NIC (NDC) | Dell DDJKY — Intel X710-DA4 quad-port SFP+ | Shipped (USPS) | garlandcompute |
| Apr 21 – May 4 | X710-DA4 low-profile bracket | — | Shipped (SpeedPAK, slow) | zsnow1 |
| Delivered | 2.5"→3.5" adapter tray (1x) — **NOW SURPLUS** | Dell 0XXFVX / 0DFYT4 | Received | reservertech — rear 2.5" bays eliminate need |
| Received | Thermal paste | Arctic MX-4 (or equivalent) | On-hand | Amazon — Jeffrey self-ordered 2026-04-17 |
| On-hand | 6x 6TB SAS HDDs | Seagate Enterprise ST6000NM0115 (Dell 8D1V4) | On-hand | — |

### Ordered — Blocked

| Item | Part/Model | Blocker |
|---|---|---|
| ~~iDRAC 8 Enterprise license~~ | Lifetime | ✅ **iDRAC8 Enterprise license applied 2026-05-05. Web UI at 192.168.1.200. Password secured.** |

### NOT YET ORDERED — Critical Path

| Item | Target spec | Price target | Notes |
|---|---|---|---|
| ~~Production CPUs~~ | ~~2x Intel Xeon E5-2699 v4 matched SR2JS (44c/88t)~~ | — | ✅ **Installed 2026-05-05** |
| ~~Thermal paste~~ | Arctic MX-4 | — | ✅ **Received** — Jeffrey self-ordered on Amazon |
| ~~2nd 2.5"→3.5" adapter tray~~ | — | — | **Cancelled** — rear 2.5" bays eliminate need |
| Front 3.5" drive caddies | Dell F238F / G302D / 0F238F | $30–60 | Qty 6 (6x 6TB SAS data) |
| **Rear 2.5" drive caddies** | Dell G176J / 0G176J / X7K8W | $10–20 | Qty 2 (both boot SSDs in rear bays) |
| ~~SAS cables (2x CBL0009 A0+B0)~~ | Dell 0PKCG4 / 0RCPKG | — | ✅ Ordered 2026-05-05 — arriving 2026-05-07 to 2026-05-14 |
| ~~Rear flex bay cable~~ | Dell 0G7GV2 | — | ✅ Ordered 2026-05-05 — arriving 2026-05-07 to 2026-05-14 |
| 10GbE SFP+ DAC cables | 1m passive copper | $20–30 | Qty 2 |
| 10GbE switch | TP-Link TL-SX3008F (8-port SFP+ unmanaged) | ~$100 | Alt: MikroTik CRS309-1G-8S+IN (~$150) |
| NVMe PCIe carrier | LinkReal PLX8747 (LRNV9547-4I) — PCIe switch chip required | — | R730 lacks bifurcation. Alt: ASUS Hyper M.2 x16 Gen 4 |
| NVMe drives | 4x WD Black SN850X 1TB | $280–320 total | Budget alt: Samsung 980 Pro 1TB |
| Rail kit | Dell ReadyRails H4X6X (same for R730 / R730XD) | $50–100 | ⚠️ Verify **rack internal depth ≥32"** before ordering — R730XD is 31.5" deep, ~34" with rails extended |
| Power cables | 2x C13 → NEMA 5-15P, 10A, 6ft | $10–20 | — |

### NOT YET ORDERED — Phase 6 (GPU, May+)

| Item | Part/Model | Price target | Slot |
|---|---|---|---|
| Transcoding GPU | Intel Arc A380 6GB | $100–130 | PCIe Slot 4 (Riser 2) — Jellyfin / Immich |
| AI inference GPU | NVIDIA RTX 3060 12GB | $200–250 | PCIe Slot 6 (Riser 3) — Ollama |
| GPU riser | Dell 800JH Riser 3 | — | Required to populate Slot 6 |

### Lighthouse confirmed spend (as of 2026-04-17)

~$600.52+ on Phase 1 parts (does not include heatsinks, X710, bracket shipping totals — still TBD).

---

## R740 "Watchtower" — Frigate NVR

**Codename:** Watchtower
**Role:** Dedicated Frigate NVR / surveillance server with AI object detection
**Current state:** Architecture locked, 0% purchased.
**Storage decision (locked):** Option B — local 1TB NVMe for working data only; long-term footage over 10GbE NFS to Lighthouse TrueNAS (`datapool/surveillance`). No large local HDD array.

| Component | Spec | Status |
|---|---|---|
| Chassis | Dell PowerEdge R740 2U | NOT YET ORDERED |
| Boot | Dell BOSS card + mirrored M.2 | NOT YET ORDERED |
| Working storage | 1x 1TB NVMe SSD | NOT YET ORDERED |
| GPU | Dedicated AI inference GPU (TBD) | NOT YET ORDERED |
| 10GbE NIC | TBD — VLAN 30 to USW-Aggregation | NOT YET ORDERED |

Next action: do not begin until Lighthouse Phase 2–3 proves out.

---

## R340 — OPNsense Router (Codename: TBD)

**Role:** Network gateway, firewall, VLAN router, Unbound, Suricata IPS, CrowdSec
**Current state:** Chassis + boot drive + extra CPU inbound. Gating item for network Phase 1.

> **The OPNsense build is its own project.** This file tracks the **hardware** only.
> For network architecture, VLAN/firewall/DNS design, install plan, and phased
> execution, see **`network-build.md`** (authoritative).

| Component | Part/Model | Arriving | Source |
|---|---|---|---|
| Chassis (w/ E-2174G + 32GB RAM, no HDD) | Dell PowerEdge R340 1U | ~Apr 9 (UPS) | affordable_sol — eBay 19-14428-61021 |
| CPU upgrade | Intel Xeon E-2236 (6c, 3.4GHz, LGA1151) | Apr 2–6 | neerecycling — eBay 19-14428-61019 |
| Boot SSD + caddy | Dell 394XT 120GB 6Gbps SATA 2.5" | Apr 3–9 | kl0 — eBay 19-14428-61018 |

**Rail kit:** 8N0JT (R340 specific — NOT interchangeable with R730 053D7M / H4X6X)

**Scope confirmed (per EXPORT 2 / phased project plan):**
- The R340 chassis + E-2236 CPU + 394XT SSD + caddy are all part of the OPNsense build.
- E-2236 is a CPU upgrade over the included E-2174G (EXPORT 2 spec: "E-2136 or E-2236").
- 2.5"→3.5" adapter tray attribution (R730 vs R340) — still open; see `parts-compatibility.md`.

---

## Services Planned — Lighthouse

- Proxmox VE (hypervisor)
- TrueNAS SCALE (storage VM, H730P passthrough)
- Jellyfin — Arc A380 VAAPI/QuickSync — :8096/:8920
- Immich — Arc A380 ML
- Nextcloud + Collabora Online (CODE) for browser/mobile Office edits
- Home Assistant (lives on VLAN 50, 10.0.50.10:8123)
- Vaultwarden (passwords)
- AdGuard Home (10.0.20.53 — split DNS for home.lan)
- Tailscale (10.0.20.100 — advertises all VLAN subnet routes)
- Ollama + Open WebUI (Phase 6, RTX 3060 12GB)
- Frigate → runs on Watchtower, writes footage to Lighthouse NFS

---

## Supporting Equipment

| Device | Model | Role | Notes |
|---|---|---|---|
| Laptop | ASUS Vivobook | Primary build workstation — iDRAC console, SSH, eBay research | WiFi only — no Ethernet port. USB-C/USB-A to Ethernet adapter needed for direct iDRAC access on non-routed subnets. |

---

## Known Future Integrations

- **Atlas 4 drone** — sub-250g drone will RTSP-stream to Frigate for aerial surveillance. Not yet acquired.
- **Z-Wave / Zigbee hub** — local HA integration on VLAN 50.

---

## Active Blockers

| Blocker | Impact | Next action |
|---|---|---|
| **SAS cables + rear flex bay cable** | H730P → front backplane + boot SSDs cannot connect | ✅ Ordered 2026-05-05 — arriving 2026-05-07 to 2026-05-14 |
| **Fan error — monitor** | One fan flagged during ePSA 2026-05-05 | ⚠️ SEL cleared for fresh start. Monitor iDRAC dashboard Health → Fans on next session for recurrence |
| **ePSA Error 2000-0251 — re-run needed** | System Management failed during ePSA — was iDRAC not initialized | ⚠️ Re-run ePSA after cables installed and iDRAC fully configured to confirm clears |
| **iDRAC IP temporary** | 192.168.1.200 only works on home network — not final | Move to 10.0.10.6 on VLAN 10 after OPNsense is configured |
| **Front 3.5" caddies** | Cannot mount 6x SAS HDDs in front bays | Order 6x Dell F238F / G302D — ~$30–60 |
| **Rear 2.5" caddies** | Cannot mount boot SSDs in rear bays | Order 2x Dell G176J / X7K8W — ~$10–20 |
| **Rack depth unverified** | Blocks rail install | Jeffrey to measure rack internal depth — must be ≥32" |
| ~~**iDRAC license**~~ | ✅ Resolved 2026-05-05 — iDRAC8 Enterprise applied | — |
| ~~**Heatsink duplicate**~~ | ✅ Resolved — duplicate YY2R8 pair received, listed for resale | — |

---

## Documentation Drift (carried from Export 1 — to resolve)

1. ~~**IP scheme:** Old milestone doc used 192.168.x.x.~~ ✅ Resolved — `10.0.x.x` is authoritative across all network/server docs (see `network-build.md` §2).
2. **Boot SSD model:** Arch doc says "Samsung 870 EVO"; actual is **SM863a enterprise**. SM863a is a better fit for ZFS boot mirror — update arch doc, not the parts.
3. **NVMe pool design:** Arch doc = single 4-drive pool. Milestone doc = two mirrors (vmstore + faststore). Real perf/redundancy tradeoff — **needs Jeffrey's call**.
4. **X710 NDC part number:** 068M95 was specified in the shopping list; **DDJKY** was purchased. Confirm equivalence before install.
5. ~~**R730 rail kit SKU:** 053D7M (export) vs H4X6X (prior log).~~ ✅ Reconciled — H4X6X is the rail kit for both R730 and R730XD per chassis inspection. Rack depth (≥32" internal) is now the live blocker, not the SKU.
6. **AdGuard/Tailscale VM IPs:** Older docs used 10.0.20.5 (AdGuard) and 10.0.20.6 (Tailscale). **EXPORT 2 authoritative values: 10.0.20.53 (AdGuard), 10.0.20.100 (Tailscale).** All references in this file reconciled 2026-04-17.
7. **Chassis model:** All prior docs reference R730. Actual chassis is **R730XD** (14 bays, 31.5" deep, 4x 32GB DDR4-2666). Downstream compatibility unaffected; storage layout improved (rear boot bays).
8. **Heatsink redundancy:** Chassis arrived with YY2R8 already installed; minnesotacompu shipment is duplicate. Verify on arrival, resell spares.

---

## Next Actions (refreshed 2026-05-05)

### When cables arrive (2026-05-07 to 2026-05-14)
1. Install 2x SAS cables (Dell 0PKCG4 / 0RCPKG) — H730P Mini Mono → front backplane
2. Install rear flex bay cable (Dell 0G7GV2) — connects rear 2.5" bays
3. Install 2x Samsung 480GB SM863a boot SSDs into rear 2.5" bays (need 2x G176J rear caddies first)
4. Verify iDRAC sees all drives
5. Re-run ePSA to confirm error 2000-0251 clears
6. Monitor fan health in iDRAC dashboard

### Still to order (before cable install session)
- 2x Dell G176J rear 2.5" caddies (~$10–20) — boot SSDs
- 6x Dell F238F front 3.5" caddies (~$30–60) — SAS HDDs
- Resell temp E5-2620 v3 CPUs ($15–25 target on eBay)

### After boot drives connected
- Install Proxmox VE on 2x SM863a ZFS mirror — static IP 10.0.20.10 on VLAN 20
- Create ZFS pools: boot mirror, vmstore, faststore
- Flash H730P → IT/HBA mode
- Deploy TrueNAS SCALE VM with H730P passthrough
- datapool RAIDZ2 across 6x 6TB SAS → ~24TB usable
- Create datasets + NFS exports on 10.0.20.0/24
- Deploy core services: AdGuard, Tailscale, Jellyfin, Immich, Nextcloud, HA
- Reconcile NVMe pool design (1-pool vs 2-mirror) with Jeffrey

### Medium-term (Jun+)
- Order NVMe subsystem: LinkReal PLX8747 + 4x WD SN850X 1TB
- Order networking: 2x SFP+ DAC cables + TP-Link TL-SX3008F switch
- Order GPU trio (Arc A380, RTX 3060 12GB, Dell 800JH Riser 3)
- Configure OPNsense R340 → then move iDRAC IP to 10.0.10.6 (VLAN 10)
- Post-build: CPU pinning, ZFS ARC tuning, MTU 9000, SMART alerts, scheduled scrubs
- Rack + rails (verify depth first) + UPS (2x CyberPower CP1500PFCRM2U)
- Begin Watchtower R740 build

---

## Budget Snapshot (as of 2026-04-29)

| Phase | Target | Actual |
|---|---|---|
| Phase 1 — Foundation | $602–666 | $600.52+ |
| Phase 2 — Critical | $178–332 | Heatsinks + X710 + bracket ordered, TBD |
| Phase 3 — Storage/Network | $160–210 | $0 |
| Phase 4 — NVMe | $330–400 | $0 |
| Phase 5 — Infrastructure | $60–120 | $0 |
| **Core build total** | **$1,330–1,728** | **~$600+** |
| Phase 6 — GPUs | $350–480 | $0 |
| **Complete total** | **$1,680–2,208** | **~$600+ (~30%)** |
