# Homelab Build — Handoff Knowledge Dump (Export 1 of 3)

**For:** Trapper (new PKA)
**From:** Prior Claude project context
**Compiled:** April 17, 2026
**Project:** Lighthouse (R730) + Watchtower (R740) + OPNsense Router (R340) homelab build
**Owner:** Jeffrey (jeff@davisglobe.com)
**Received into team-inbox:** 2026-04-17 (Radar)

---

## 0. READ THIS FIRST — ORIENTATION

This is a three-server homelab build, not one. The prior conversation heavily focused on Lighthouse (R730) because that is what is actively being purchased and assembled, but there are three distinct systems in flight:

- **Lighthouse** — Dell PowerEdge R730, 2U. Primary Proxmox hypervisor. All services run here. ~60% of parts ordered, nothing yet assembled.
- **Watchtower** — Dell PowerEdge R740, 2U. Dedicated Frigate NVR surveillance server. Architecture only — no Watchtower-specific parts ordered yet in this conversation.
- **OPNsense Router** — Dell PowerEdge R340, 1U. Network gateway. Chassis ordered (affordable_sol, Apr 1) plus an E-2236 CPU from neerecycling and a 120GB SSD + caddy from kl0. Not discussed in depth in the architecture doc — inferred from shipping notifications.

The architecture document (homelab_servers.docx) describes the target end-state for Lighthouse + Watchtower. The build trackers focus on Lighthouse parts acquisition.

Naming convention: Servers are named after lighthouse/watchtower metaphors. Keep it.

Network: Everything connects at 10GbE to a USW-Aggregation core switch. VLAN-segmented. Tailscale provides remote access. AdGuard Home provides split DNS for *.home.lan.

---

## 1. HARDWARE INVENTORY

### 1A. Lighthouse (Dell PowerEdge R730) — Primary Hypervisor

| Component | Part # / Model | Spec | Status | Source / Order | Notes |
|---|---|---|---|---|---|
| Chassis | Dell PowerEdge R730 | 2U rackmount | Shipped, arriving Apr 14 (UPS, updated from FedEx Apr 10) | TechKabob (Knoxville, TN) — eBay 06-14444-27364 — $399.99 + $56.65 = $456.64 | Includes 128GB RAM — huge value |
| RAM | 8x 16GB DDR4-2400 ECC RDIMM | 128GB total | Shipping with chassis | — | Bundled with chassis purchase |
| CPU (temp for BIOS) | 2x Intel Xeon E5-2620 v3 | 6c/12t each, Haswell-EP, LGA2011-3 | Shipped (USPS, Mar 31) | Cache&Carry (Omaha, NE) — eBay 06-14444-27361 — $9.95 | BIOS-update insurance; resell for $15–25 after use |
| CPU (production) | 2x Intel Xeon E5-2699 v4 | 22c/44t each = 44c/88t total, Broadwell-EP, S-spec SR2JS | NOT YET ORDERED | — | Wait until BIOS confirmed updated to 2.10.0. Target $100–200 matched pair. |
| RAID/HBA | Dell H730P Mini Mono | — | Shipped (USPS, Mar 31) | januarius — eBay 06-14444-27365 — $19.95 | Will be flashed to HBA/IT mode for TrueNAS passthrough |
| Boot SSD #1 | Samsung 480GB SATA (SM863a enterprise) | — | Shipped (UPS, Mar 31) | thepowerhouseofelectronics — eBay 06-14444-27360 — $39.99 + $10.00 = $49.99 | Arch doc says "Samsung 870 EVO" — reality is SM863a enterprise. |
| Boot SSD #2 | Samsung 480GB SATA (SM863a enterprise) | — | Shipped (USPS, Mar 31) | ctrlplusit — eBay 06-14444-27362 — $50.00 | ZFS mirror with SSD #1 |
| iDRAC license | Dell iDRAC 8 Enterprise | Lifetime | Ordered — BLOCKED | motorfixit (Weifang, CN) — eBay 06-14444-27363 — $13.99 | ⚠️ Needs Service Tag + email sent to motorfixit to generate key |
| CPU heatsinks | Dell P/N 0YY2R8 (2x) | 165W rated | Shipped (UPS, Apr 13, arriving Apr 15) | minnesotacompu — eBay 11-14485-06140 | ⚠️ Verify 165W, NOT 95W (0VFWH). Other acceptable PNs: 0TY129, 0PXDG5, 0GDK4 |
| Thermal paste | Arctic MX-4 / Noctua NT-H1 / TG Kryonaut target | — | NOT YET ORDERED | — | $8–12 |
| 10GbE NIC | Dell P/N DDJKY — Intel X710-DA4 | Quad-port 10Gb SFP+ NDC | Shipped (USPS, Apr 13, arriving Apr 14–20) | garlandcompute — eBay 11-14485-06138 | Dell part 068M95 was originally specified; DDJKY equivalent |
| Low profile bracket for X710-DA4 | — | — | Shipped (SpeedPAK, Apr 13, arriving Apr 21–May 4) | zsnow1 — eBay 11-14485-06139 | Slow-boat from overseas |
| Drive caddies (3.5" LFF) | Dell F238F / G302D / 0F238F | Qty 6–8 | NOT YET ORDERED | — | Target $30–60 for 6–8x |
| 2.5"→3.5" adapter trays (x2) | Dell 0XXFVX or 0DFYT4 | — | 1x received (reservertech, Apr 3–7) | reservertech — eBay 19-14428-61020 | Possibly only 1 ordered — verify & order 2nd if needed for both boot SSDs |
| SFP+ DAC cables (x2, 1m) | — | Passive copper | NOT YET ORDERED | — | Target $20–30 for 2x |
| 10GbE switch | TP-Link TL-SX3008F | 8-port SFP+ unmanaged | NOT YET ORDERED | — | ~$100. Alt: MikroTik CRS309-1G-8S+IN (~$150) |
| NVMe carrier | LinkReal PLX8747 (LRNV9547-4I) | 4x M.2 via PCIe 3.0 x8, true PCIe switch | NOT YET ORDERED | — | ⚠️ Must be PLX8747 — R730 lacks BIOS bifurcation. Alt: ASUS Hyper M.2 x16 Gen 4 |
| NVMe drives (x4) | WD Black SN850X 1TB | PCIe Gen4 M.2 | NOT YET ORDERED | — | Target $280–320. Budget alt: Samsung 980 Pro 1TB |
| HDDs (already owned) | 6x Seagate Enterprise ST6000NM0115 (Dell 8D1V4) | 6TB SAS | On-hand | — | Will run SMART check before pool creation. RAIDZ2 → ~24TB usable |
| Rail kit | Dell ReadyRails 053D7M | Sliding | NOT YET ORDERED | — | $50–100. Verify rack depth. |
| Power cables (x2) | C13 → NEMA 5-15P, 10A, 6ft | — | NOT YET ORDERED | — | $10–20 |
| GPU — transcoding | Intel Arc A380 6GB | — | FUTURE (Phase 6, May+) | — | For Jellyfin/Immich. PCIe Slot 4 (Riser 2). Target $100–130 |
| GPU — AI inference | NVIDIA RTX 3060 12GB | — | FUTURE (Phase 6, May+) | — | For Ollama. PCIe Slot 6 (Riser 3). Target $200–250 |
| GPU riser | Dell 800JH Riser 3 | — | FUTURE (Phase 6, May+) | — | Required to populate Slot 6 for RTX 3060 |

**Lighthouse confirmed spend so far:** $600.52+ (still need to add shipping for H730P & SSD #2, plus April orders)

### 1B. Watchtower (Dell PowerEdge R740) — Frigate NVR

| Component | Part # / Model | Spec | Status | Notes |
|---|---|---|---|---|
| Chassis | Dell PowerEdge R740 | 2U | NOT YET ORDERED (in architecture only) | — |
| Boot | Dell BOSS card + mirrored M.2 | — | NOT YET ORDERED | Separate from data |
| VM/working storage | 1x 1TB NVMe SSD | — | NOT YET ORDERED | Frigate working data only; long-term footage goes to Lighthouse via NFS |
| GPU | Dedicated AI inference GPU (TBD) | — | NOT YET ORDERED | Object detection across camera streams |
| 10GbE NIC | (TBD) | — | NOT YET ORDERED | Connects to USW-Aggregation on VLAN 30 |

Watchtower is fully designed on paper but no parts ordered. Architecture is locked in: local NVMe only, footage writes to Lighthouse TrueNAS over 10GbE NFS (Option B architecture — see §2).

### 1C. OPNsense Router (Dell PowerEdge R340) — Network Gateway

**Inferred from shipping notifications — NOT extensively discussed in the architecture conversation.**

| Component | Part # / Model | Spec | Status | Source / Order | Notes |
|---|---|---|---|---|---|
| Chassis | Dell PowerEdge R340 | 1U | Shipping (UPS, arriving ~Apr 9) | affordable_sol — eBay 19-14428-61021 | Includes Xeon E-2174G + 32GB RAM, no HDD |
| CPU (extra) | Intel Xeon E-2236 | 6c, 3.4GHz, LGA1151 | Shipping (USPS, Apr 2–6) | neerecycling — eBay 19-14428-61019 | Unclear purpose — R340 already includes E-2174G. Possibly a CPU upgrade. Confirm with owner. |
| Boot SSD + caddy | Dell 394XT 120GB 6Gbps 2.5" SATA | — | Shipping (USPS, Apr 3–9) | kl0 — eBay 19-14428-61018 | Likely OPNsense boot drive |

⚠️ **Flag for Trapper:** The E-2236 CPU, R340 chassis, 120GB SSD, and extra R720/R730 caddy (reservertech) all shipped Apr 1–4 as a group and were not explained in the Lighthouse-focused trackers. Ask Jeffrey to confirm whether these are (a) the OPNsense R340 build, (b) an R340 CPU upgrade, and (c) whether the reservertech caddy is for R730 or R340.

---

## 2. COMPATIBILITY DECISIONS & CONFIRMED INCOMPATIBILITIES

Critical decisions you must not second-guess without confirming:

1. **BIOS-update strategy with cheap temp CPUs.** Jeffrey bought 2x E5-2620 v3 for $9.95 specifically because older R730 BIOS versions may not recognize the newer E5-2699 v4 production CPUs. Plan: assemble with temp CPUs → update BIOS to 2.10.0 → swap in E5-2699 v4. Temp CPUs will be resold. Do not order the E5-2699 v4 production CPUs until BIOS is confirmed at 2.10.0.

2. **Heatsink wattage — 165W required, NOT 95W.** The E5-2699 v4 is 145W TDP. R730 ships with both 95W (P/N 0VFWH — DO NOT BUY) and 165W-rated heatsinks. Acceptable part numbers: 0YY2R8 (purchased), 0TY129, 0PXDG5, 0GDK4. Height ~65–70mm.

3. **PLX8747 NVMe adapter — bifurcation incompatibility.** The R730 BIOS does NOT support passive PCIe bifurcation. A plain passive 4x M.2 card will only see 1 drive. Must use an adapter with a true PCIe switch chip (PLX8747). Specified: LinkReal LRNV9547-4I. Fallback: ASUS Hyper M.2 x16 Gen 4. Do not buy passive bifurcation cards.

4. **Matched-pair CPUs must share S-spec code (SR2JS).** When buying the E5-2699 v4 pair, verify both CPUs have identical S-spec SR2JS and are listed as "matched" or "tested together."

5. **H730P → HBA/IT mode for TrueNAS.** Plan is to flash the H730P to IT (passthrough) mode so TrueNAS SCALE VM can see the 6x 6TB drives as raw devices for ZFS.

6. **R730 does NOT support passive PCIe bifurcation** — see #3. Repeated because it is the single most common build-breaking mistake on R730.

7. **Samsung SSD naming discrepancy.** Architecture doc says "Samsung 870 EVO" for boot mirror; actual purchased drives are Samsung SM863a enterprise SSDs (480GB). SM863a is enterprise-grade and actually better-suited for ZFS boot mirror than 870 EVO.

8. **Option B storage architecture for Frigate footage.** Watchtower writes to Lighthouse TrueNAS over 10GbE NFS (not local storage on Watchtower). This is a locked decision — avoids duplicating large storage arrays, keeps management centralized. Watchtower gets only 1TB local NVMe for working data.

9. **Intel X710-DA4 is the NDC choice.** Alternatives considered and passed on: 0165T0 (Broadcom), 064PJ8 (Intel X550-T4 copper). Copper was rejected in favor of SFP+/DAC for 10GbE run.

10. **GPU passthrough prerequisite: VT-d + separate IOMMU groups.** Before installing GPUs (Phase 6), verify BIOS has VT-d enabled and that Arc A380 and RTX 3060 land in separate IOMMU groups. Check with `find /sys/kernel/iommu_groups`.

11. **R740 (Watchtower) rejected local-storage-for-long-term design.** Considered giving Watchtower a big HDD array; rejected in favor of NFS-to-Lighthouse (see #8).

---

## 3. CONFIGURATION DECISIONS

### 3A. Network topology

- **VLAN 10 Management** — 10.0.10.0/24 — iDRACs, Cloud Key, switches
  - Lighthouse iDRAC: 10.0.10.6
  - Watchtower iDRAC: 10.0.10.7
  - OPNsense iDRAC: 10.0.10.5
  - Cloud Key Gen 2+: 10.0.10.20
- **VLAN 20 Servers** — 10.0.20.0/24
  - Lighthouse Proxmox: 10.0.20.10
  - TrueNAS VM: 10.0.20.11
  - AdGuard Home VM: 10.0.20.5
  - Tailscale VM: 10.0.20.6
- **VLAN 30 Surveillance** — 10.0.30.0/24 — fully isolated, no outbound inter-VLAN
  - Watchtower: 10.0.30.10
- **VLAN 40 Trusted** — (inferred) accesses Jellyfin/Immich/Nextcloud/HA on specific ports via explicit OPNsense allows
- **VLAN 50 IoT** — 10.0.50.0/24
  - Home Assistant: 10.0.50.10 (intentionally on IoT VLAN, not Servers)
- **Gateway:** OPNsense provides .1 on every VLAN subnet

Note the prior BIOS/milestone doc referenced 192.168.10.10 and 192.168.20.10 — these are superseded by the 10.0.x.x scheme in the architecture doc. **Use 10.0.x.x.**

### 3B. Firewall rules

- VLAN 20 → any VLAN: outbound allowed
- Inbound to VLAN 20: only from VLAN 10 or VLAN 40 on specific service ports
- VLAN 30 → anywhere: denied EXCEPT explicit allow 10.0.30.10 → 10.0.20.11 on NFS port 2049
- VLAN 40 → 10.0.50.10 port 8123 (Home Assistant UI) allowed
- VLAN 40 → Jellyfin (8096/8920), Immich (2283), Nextcloud, Frigate UI (10.0.30.10:5000) on specific ports only
- VLAN 50 IoT devices: blocked from direct internet — all cloud comms go through HA integrations

### 3C. Storage layout (Lighthouse)

- Boot pool: ZFS mirror, 2x Samsung 480GB SM863a
- NVMe pool (vmstore): ZFS mirror, SN850X slots 1–2 → VM disks
- NVMe pool (faststore): ZFS mirror, SN850X slots 3–4 → fast/scratch
- **Discrepancy:** arch doc describes a single "NVMe Pool — 4x SN850X" ZFS pool; milestone doc splits into two mirrors. Reconcile with Jeffrey.
- Data pool (datapool): 6x 6TB SAS in RAIDZ2 → ~24TB usable, managed by TrueNAS VM
- Datasets: media, photos, files (aka nextcloud), surveillance, backups, ai-models
- NFS exports to 10.0.20.0/24 (corrected from 192.168.20.0/24)
- Compression: lz4 on all pools/datasets
- Snapshots: hourly active, daily media, weekly surveillance
- Scrub: monthly

### 3D. VM allocations (Lighthouse Proxmox)

- TrueNAS SCALE VM: 8 vCPU, 32GB RAM (fixed), 50GB disk on vmstore, H730P passthrough, 10GbE dedicated port
- Docker LXC: 12 vCPU, 20GB RAM, 100GB disk on vmstore, privileged, bridged to VLAN 20. Hosts Jellyfin, Immich, Home Assistant, Nextcloud, PostgreSQL, Redis
- AI LXC (Phase 6): 16 vCPU, 32GB RAM, 50GB disk on vmstore, RTX 3060 passthrough, mounts /ai-models

### 3E. Services & hardware acceleration

- Jellyfin → Intel Arc A380 (VAAPI + QuickSync); :8096/:8920
- Immich → Arc A380 for ML face/object detection
- Ollama + Open WebUI → RTX 3060 12GB, models in 7B–13B range at full precision
- Home Assistant → VLAN 50, port 8123
- Frigate (Watchtower) → dedicated GPU for object detection, RTSP from IP cameras + Atlas 4 drone, writes to Lighthouse NFS

### 3F. Remote access

- Tailscale VM on VLAN 20 at 10.0.20.6
- Advertises all six /24 VLAN subnets as subnet routes
- IP forwarding enabled: `net.ipv4.ip_forward=1` and `net.ipv6.conf.all.forwarding=1` in `/etc/sysctl.conf`
- Split DNS: home.lan zone points at AdGuard Home
- Independent of OPNsense — survives router reboots

### 3G. Backups

- Proxmox Backup Server or built-in scheduler → backups dataset on TrueNAS
- Retention: 7 daily / 4 weekly / 3 monthly
- Daily-critical: AdGuard, Tailscale, HA, TrueNAS
- OPNsense config auto-backup → backups/opnsense/ on every change
- Cloud Key config → backups/cloudkey/ daily

---

## 4. CURRENT BUILD STATUS PER SERVER

### Lighthouse (R730) — ~40% of Phase 1 complete, 0% assembled

**Phase progress:**
- Phase 1 (Parts Acquisition, Mar 30 – Apr 5): ~60% done
- Phase 2 (Initial Assembly & BIOS, Apr 6–12): not started — waiting for chassis Apr 14
- Phase 3 (CPU Upgrade & Storage, Apr 13–19): not started — production CPUs not yet ordered
- Phase 4 (Storage & Network, Apr 20–26): not started — NVMe adapter/drives not ordered
- Phase 5 (TrueNAS & Services, Apr 27 – May 3): not started
- Phase 6 (GPU Integration, May 4+): not started

**In-hand or shipped (arriving Apr 14 window):**
- R730 chassis + 128GB RAM (arriving Apr 14)
- 2x E5-2620 v3 temp CPUs
- H730P Mini Mono
- 2x Samsung 480GB SM863a SSDs
- 2x CPU heatsinks 0YY2R8 (arriving Apr 15)
- Intel X710-DA4 NDC (arriving Apr 14–20)
- X710-DA4 low-profile bracket (arriving Apr 21 – May 4)
- 6x 6TB Seagate SAS drives (already owned)
- 1x 2.5"→3.5" adapter tray (reservertech)

**Ordered but blocked/pending:** iDRAC 8 Enterprise license — BLOCKED on service tag reply to motorfixit

**Not yet ordered (critical path):** E5-2699 v4 production CPUs (matched SR2JS), thermal paste, 3.5" drive caddies (6–8x), 2nd 2.5"→3.5" adapter tray (if needed), 2x 10GbE SFP+ DAC cables, 10GbE switch (TP-Link TL-SX3008F), LinkReal PLX8747 NVMe adapter, 4x WD SN850X 1TB, rail kit, power cables

**Not yet ordered (Phase 6, optional):** Intel Arc A380, NVIDIA RTX 3060 12GB, Dell 800JH Riser 3

### Watchtower (R740) — Architecture only, 0% purchased

Full hardware spec designed (see §1B) but no components ordered. Next server to plan purchases for after Lighthouse Phase 2–3.

### OPNsense Router (R340) — Chassis + possible CPU & boot SSD inbound, undocumented

See §1C. Parts shipping (arriving ~Apr 9) but not covered in the Lighthouse trackers. Need scope conversation with Jeffrey.

---

## 5. OPEN ITEMS & NEXT ACTIONS

### Immediate (this week, Apr 17–20)
1. Reply to motorfixit on eBay with R730 Service Tag + email address to unblock iDRAC license delivery.
2. Receive R730 chassis Apr 14. Inspect. Photograph. Verify 128GB RAM, dual PSUs, no bent pins.
3. Record current BIOS version on arrival.
4. Physical assembly (Phase 2): install temp E5-2620 v3 CPUs + 0YY2R8 heatsinks, H730P Mini Mono, 2x SM863a SSDs.
5. Power-on + POST verification.
6. Order thermal paste — $8–12.
7. Resolve OPNsense R340 scope with Jeffrey.

### Short-term (Apr 21–26)
- iDRAC access — install Enterprise license, configure network (VLAN 10, 10.0.10.6), enable remote console.
- Update BIOS to 2.10.0.
- Order production E5-2699 v4 CPUs (matched pair SR2JS) only after BIOS confirmed.
- Swap CPUs, verify 44c/88t, stress test.
- Order NVMe subsystem: LinkReal PLX8747 + 4x SN850X 1TB.
- Order storage ancillaries: caddies, SFP+ DAC cables, 10GbE switch.

### Medium-term (Apr 27 – May 3)
- Install Proxmox on 2x SM863a mirror. Static IP 10.0.20.10 on VLAN 20.
- Create ZFS pools — boot, vmstore, faststore. Reconcile NVMe pool design with Jeffrey.
- Flash H730P to IT/HBA mode.
- Deploy TrueNAS SCALE VM with H730P passthrough.
- Create datapool RAIDZ2, datasets, NFS shares on 10.0.20.0/24.
- Deploy core services: AdGuard, Tailscale, Jellyfin, Immich, Nextcloud, HA.
- Resell E5-2620 v3 temp CPUs.

### Longer-term (May+)
- Order GPU trio: Arc A380, RTX 3060 12GB, Dell 800JH Riser 3.
- GPU passthrough configuration, IOMMU verification.
- Deploy AI LXC + Ollama + Open WebUI.
- Start Watchtower build.
- Post-build optimization: CPU pinning, ZFS ARC, jumbo frames MTU 9000, NFS tuning, monitoring.
- Rack install, cable management, UPS (2x CyberPower CP1500PFCRM2U).

### Known blockers
- iDRAC license — awaiting motorfixit reply
- BIOS version — can't order E5-2699 v4 until verified
- OPNsense R340 scope — needs owner clarification

### Discrepancies to resolve
- IP scheme: use 10.0.x.x (architecture doc is authoritative over milestone doc's 192.168.x.x)
- Boot SSD model: arch doc says "Samsung 870 EVO", actual is SM863a
- NVMe pool design: single 4-drive pool vs. two 2-drive mirrors (vmstore + faststore)
- X710 NDC part number: 068M95 specified vs. DDJKY purchased — confirm equivalent

---

## 6. EVERYTHING ELSE TRAPPER NEEDS TO KNOW

### Jeffrey's build philosophy
- Budget-conscious but not cheap. Spent $10 on temp CPUs to de-risk a $200 CPU purchase.
- eBay-exclusive parts sourcing. Track seller location, store name, order number.
- Values total-cost transparency. Line items with amount + shipping + total.
- Documents meticulously. Three parallel tracking docs — keep in sync.

### Document inventory
- `Lighthouse_Build_Milestones.md` — phased build plan with checkboxes
- `Lighthouse_Purchase_Tracker.md` — orders, shipping, tracking
- `Lighthouse_Shopping_Checklist.md` — what to buy, part numbers, search terms
- `homelab_servers.docx` — architecture reference (end-state design)

### Codename conventions
- Lighthouse = R730 (primary hypervisor, "the light")
- Watchtower = R740 (surveillance)
- OPNsense = R340 (no codename yet — consider one)
- Infra: USW-Aggregation (Unifi 10GbE core switch), US-24 (secondary switch), Cloud Key Gen 2+

### Known future integrations
- Atlas 4 drone — sub-250g drone that will RTSP-stream to Frigate. Not yet acquired.
- Collabora Online (CODE) — Nextcloud app for browser/mobile .docx/.xlsx/.pptx editing.
- Z-Wave / Zigbee hub — HA local on VLAN 50.

### Seller quality notes
- TechKabob — 100% positive, 6.7K sold, reliable
- Cache&Carry — 100% positive, 84 sold, CPUs tested
- motorfixit — China seller, Beijing Time correspondence, requires service-tag reply
- Others — single-item purchases, ratings not captured

### Things deliberately NOT done (don't re-raise)
- No local long-term storage on Watchtower (NFS to Lighthouse is the answer)
- No passive bifurcation NVMe cards (PLX8747 required)
- No copper 10GbE (SFP+/DAC chosen)
- No 95W heatsinks (0VFWH) under any circumstances
- No production CPU order before BIOS 2.10.0 confirmed

### One-line build vision
"Self-hosted compute environment and systems to support my home" — capital-R real homelab, not a toy. Treat it like production.

---

## APPENDIX A — eBay Search Strings
- "E5-2699 v4 matched pair"
- "SR2JS matched pair"
- "Dell R730 heatsink TY129"
- "Dell 068M95 NDC"
- "Dell R730 3.5 caddy F238F"
- "Dell 2.5 to 3.5 adapter tray R730"
- "10GbE SFP+ DAC 1m"
- "TP-Link TL-SX3008F"
- "LinkReal PLX8747"
- "WD Black SN850X 1TB"
- "Dell R730 rail kit 053D7M"
- "Intel Arc A380 6GB"
- "NVIDIA RTX 3060 12GB"
- "Dell 800JH riser 3"

## APPENDIX B — Budget Snapshot (as of Apr 17, 2026)

| Phase | Target | Actual so far |
|---|---|---|
| Phase 1 Foundation | $602–666 | $600.52 confirmed + TBD shipping |
| Phase 2 Critical | $178–332 | Heatsinks + X710 + bracket ordered, amounts TBD |
| Phase 3 Storage/Network | $160–210 | $0 |
| Phase 4 NVMe | $330–400 | $0 |
| Phase 5 Infrastructure | $60–120 | $0 |
| **Core Build Total** | **$1,330–1,728** | **~$600+ spent** |
| Phase 6 GPUs | $350–480 | $0 |
| **Complete Total** | **$1,680–2,208** | **~$600+ spent (~30%)** |
