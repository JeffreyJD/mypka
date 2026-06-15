# Parts Compatibility Reference

Last updated: 2026-04-17
Maintained by: Trapper

## R730 / R730XD Heatsinks — E5-2699 v4 (145W TDP)

Heatsinks must be rated for 165W to have adequate margin for the 145W CPU.
Height ~65–70mm.

### CONFIRMED COMPATIBLE ✅
| Part Number | Rating | Notes |
|---|---|---|
| 0YY2R8      | 165W | **2x installed in R730XD chassis as received** (2026-04-17 inspection); additional 2x inbound from minnesotacompu — treat as duplicates pending verification |
| 0TY129      | 165W | Confirmed acceptable |
| 0PXDG5      | 165W | Confirmed acceptable |
| 0GDK4       | 165W | Confirmed acceptable |
| NGC09       | 165W | Confirmed acceptable |

### EXPLICITLY INCOMPATIBLE ❌ — NEVER RECOMMEND
| Part Number | Reason |
|---|---|
| 0VFWH | 95W only — insufficient for 145W E5-2699 v4 |
| 8K3F3 | Wrong socket configuration |

**Rule:** If Jeffrey asks about 0VFWH or 8K3F3 in ANY context —
flag as incompatible immediately. These will damage the build.

---

## Rail Kits

| Part Number | Fits | Notes |
|---|---|---|
| H4X6X  | R730 / R730XD | Authoritative 2U rail kit — same for both chassis variants |
| 053D7M | R730 / R730XD | Dell ReadyRails sliding (Export 1 SKU); interchangeable with H4X6X |
| 8N0JT  | R340 only | 1U rails — NOT interchangeable with R730 / R730XD |

**⚠️ Open item (R730XD-specific):** Verify rack internal depth **≥32"** (front-rail-hole to rear-rail-hole) before ordering. R730XD is 31.5" deep; rails extend to ~34". Standard 36–42" racks are fine; 30" shallow racks are not.

**Rule:** R730/R730XD rails and R340 rails are NEVER interchangeable.

---

## RAID / HBA Controllers

| Model | Compatible With | Status | Notes |
|---|---|---|---|
| PERC H730P Mini Mono | R730 | Shipped (not yet installed) | **Will be flashed to IT/HBA mode** for TrueNAS SCALE passthrough — ZFS on raw devices, no RAID |

---

## CPUs — R730 (LGA2011-3, Haswell-EP/Broadwell-EP)

| Model | TDP | Cores | S-spec | Status | Notes |
|---|---|---|---|---|---|
| E5-2620 v3 (x2) | 85W | 6c/12t | — | Shipped (temp) | $9.95 total — BIOS update insurance only. Resell $15–25 after use. |
| E5-2699 v4 (x2) | 145W | 22c/44t | SR2JS | **Installed 2026-05-05** | BIOS 2.19.0 confirmed before swap. |

**Rules:**
- E5-2699 v4 pair MUST be matched pair with identical S-spec code SR2JS.
- Do NOT order production CPUs until BIOS is updated to 2.10.0 — older R730 BIOS versions may not recognize E5-2699 v4.
- 145W TDP is within 165W heatsink rating — safe margin.

---

## CPUs — R340 (LGA1151)

| Model | TDP | Cores | Status | Notes |
|---|---|---|---|---|
| Xeon E-2174G | 71W | 4c/8t | Included with chassis | affordable_sol — OPNsense-adequate |
| Xeon E-2236 | 80W | 6c/12t | Shipping (Apr 2–6, neerecycling) | Possible upgrade — scope unconfirmed |

**⚠️ Open item:** Confirm whether E-2236 is an upgrade over E-2174G, or spare.

---

## NVMe PCIe Carriers — R730

### ⚠️ R730 has NO BIOS support for passive PCIe bifurcation.
A plain passive 4x M.2 adapter will only show ONE drive. **Do not buy.**

### COMPATIBLE ✅
| Model | Chip | Notes |
|---|---|---|
| LinkReal LRNV9547-4I | **PLX8747 PCIe switch** | Primary choice — 4x M.2 via PCIe 3.0 x8 |
| ASUS Hyper M.2 x16 Gen 4 | onboard switch | Acceptable fallback |

### INCOMPATIBLE ❌
| Card type | Reason |
|---|---|
| Any passive 4x M.2 bifurcation card | R730 BIOS cannot split the PCIe lanes |

**Rule:** NVMe carrier must have a **true PCIe switch chip** (PLX8747 or equivalent).

---

## Storage

| Model | Interface | Capacity | Status | Use |
|---|---|---|---|---|
| Samsung SM863a enterprise (x2) | SATA | 480GB | Shipped | ZFS boot mirror — Lighthouse |
| WD Black SN850X (x4) | PCIe Gen4 M.2 | 1TB each | NOT YET ORDERED | NVMe pools — vmstore + faststore (or unified pool — TBD with Jeffrey) |
| Samsung 980 Pro 1TB | PCIe Gen4 M.2 | 1TB | (alternate budget) | — |
| Seagate Enterprise ST6000NM0115 (Dell 8D1V4) | SAS | 6TB | On-hand (6x) | TrueNAS RAIDZ2 datapool — ~24TB usable |
| Dell 394XT | SATA 2.5" | 120GB | Shipping | OPNsense boot drive (inferred) |

**Documentation drift:** Architecture doc says "Samsung 870 EVO" for boot mirror — actual is SM863a enterprise, which is a better ZFS boot drive. No change needed; update arch doc text.

---

## Drive Caddies

| Part Number | Form | Fits | Status |
|---|---|---|---|
| Dell F238F / G302D / 0F238F / KG1CH / 9W8C4 | 3.5" LFF front | R730 / R730XD | NOT YET ORDERED — need 6 (for 6x 6TB SAS data) |
| Dell G176J / 0G176J / X7K8W | 2.5" SFF rear | **R730XD only** | NOT YET ORDERED — need 2 (for boot SSDs in rear bays) |
| Dell 0XXFVX / 0DFYT4 | 2.5"→3.5" adapter tray | R730 / R730XD | 1x received (reservertech); **now surplus** — R730XD rear bays eliminate need. Hold as spare or resell. |

---

## Network — NICs and Optics

| Device / Model | Role | Status | Notes |
|---|---|---|---|
| Dell DDJKY — Intel X710-DA4 | Quad-port 10GbE SFP+ NDC (Lighthouse) | Shipping | Dell 068M95 was originally specified — **DDJKY is equivalent** per Export 1 |
| 10GbE SFP+ DAC, 1m passive copper | Host ↔ switch | NOT YET ORDERED | Qty 2 |

**Rejected alternatives (do not re-raise):**
- Dell 0165T0 (Broadcom) — rejected
- Dell 064PJ8 — X550-T4 copper — rejected (copper rejected in favor of SFP+/DAC)

---

## Network — Switches

| Device | Role | Status |
|---|---|---|
| Ubiquiti USW-Aggregation | 10GbE core switch | Planned |
| Ubiquiti US-24 | 1GbE client distribution | Existing |
| TP-Link TL-SX3008F | 8-port SFP+ unmanaged | NOT YET ORDERED (~$100) — primary |
| MikroTik CRS309-1G-8S+IN | 8-port SFP+ | Alternate ~$150 |
| Ubiquiti Cloud Key Gen 2+ | Unifi controller | Planned — 10.0.10.20 |

---

## GPUs — Phase 6 (Lighthouse)

| GPU | Role | Slot | Price target | Status |
|---|---|---|---|---|
| Intel Arc A380 6GB | Transcoding — Jellyfin VAAPI/QuickSync, Immich ML | PCIe Slot 4 (Riser 2) | $100–130 | NOT YET ORDERED |
| NVIDIA RTX 3060 12GB | AI inference — Ollama 7B–13B full precision | PCIe Slot 6 (Riser 3) | $200–250 | NOT YET ORDERED |
| Dell 800JH Riser 3 | Enables Slot 6 | — | — | NOT YET ORDERED — required for RTX 3060 |

**Prerequisites before installing GPUs:**
- BIOS VT-d enabled
- Arc A380 and RTX 3060 in **separate IOMMU groups** — verify with `find /sys/kernel/iommu_groups`

---

## Things Deliberately NOT Done (don't re-raise)

- No local long-term storage on Watchtower (NFS to Lighthouse is the answer)
- No passive bifurcation NVMe cards (PLX8747 required on R730)
- No copper 10GbE (SFP+/DAC chosen)
- No 95W heatsinks (0VFWH) under any circumstances
- ~~No production E5-2699 v4 order before BIOS 2.10.0 confirmed~~ ✅ Done — BIOS 2.19.0, CPUs installed 2026-05-05
- Watchtower does NOT get a large HDD array — centralizes on Lighthouse TrueNAS
