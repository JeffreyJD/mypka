# Document Intake Summary — Lighthouse R730XD PKA Update

**To:** Jeffrey
**From:** Trapper
**Date:** 2026-04-17
**Source file:** `Lighthouse_R730XD_PKA_Update_April_2026.md` (uploaded 2026-04-17)
**Disposition:** Filed to `homelab/reference-docs/`; `build-log.md` and `parts-compatibility.md` updated.

---

## What changed

The chassis arrived and inspection revealed seven material deviations from the planned R730 build. Most are favorable. Two need your attention before the next power-on.

### Deltas from planned build

| # | Area | Planned | Actual | Impact |
|---|---|---|---|---|
| 1 | Model | R730 | **R730XD** | +6 drive bays, +3" depth, +$200–300 market value |
| 2 | Memory | 8x 16GB DDR4-2400 | **4x 32GB DDR4-2666** (Samsung M393A4K40BB2-CTD) | Same 128GB total, better upgrade path (up to 768GB), better airflow |
| 3 | Heatsinks | Order 2x YY2R8 separately | **Already installed in chassis** | See ⚠️ flag below |
| 4 | Storage layout | 8 front bays (2 boot + 6 data) | **12 front + 2 rear bays** | Boot SSDs move to rear 2.5" bays; all 12 front bays free |
| 5 | 2.5"→3.5" adapters | Need 2 for boot SSDs in front | **Not needed** (native rear 2.5" bays) | 1 already received from reservertech is now surplus |
| 6 | Depth | 28.5" | **31.5"** | Rack must be ≥32–34" internal depth |
| 7 | PSU | Assumed 750W x2 | **Confirmed 750W x2 EPP** | No change, just confirmed |

## ⚠️ Discrepancy worth flagging

The new document states the YY2R8 heatsinks were **included with the chassis** and recommends removing them from the shopping list. But `build-log.md` already shows **2x 0YY2R8 shipped separately from minnesotacompu, arriving Apr 15**. Three possibilities:

1. The minnesotacompu order was placed before discovering the chassis had them → you now have **4 heatsinks** (2 spare). Fine — spares are cheap insurance.
2. The minnesotacompu order was cancelled or refunded and this was never updated in the log.
3. The new document is mistaken about the chassis-included heatsinks.

**Recommended action:** when the minnesotacompu shipment arrives, open it and verify. If duplicates, resell the spare pair on eBay ($30–40 recoverable) or hold as spares. Either way, this isn't blocking.

## Action items requiring your decision

- [ ] **Measure your rack's internal depth** — front-rail-hole to rear-rail-hole. R730XD needs **≥32" available, ~34" preferred** for rails extended. If your rack is <32", installation stops until this is resolved.
- [ ] Confirm disposition of the minnesotacompu heatsink order (see discrepancy above).
- [ ] Approve the updated shopping list below before any orders are placed.

## Updated shopping list — removals and additions

**Remove:**
- ~~2x CPU heatsinks (YY2R8)~~ — already installed
- ~~2nd 2.5"→3.5" adapter tray~~ — rear bays replace front-bay adapter strategy

**Add:**
- 2x Dell **G176J** rear 2.5" caddies ($10–20) — for boot SSDs in rear bays

**Unchanged:**
- Arctic MX-4 thermal paste ($8–12) — still needed for temp + production CPU installs
- 6x Dell F238F front 3.5" caddies ($30–60)
- Everything else in the Phase 2+ plan stands

**Net budget impact:** -$40 to -$60 (savings)

## Storage strategy update

New layout takes advantage of the XD's rear bays and frees the entire front:

```
REAR (2x 2.5" hot-swap)
├─ Rear 1: Samsung 480GB SM863a (boot A)
└─ Rear 2: Samsung 480GB SM863a (boot B)
   → ZFS mirror, Proxmox boot pool

FRONT (12x 3.5" hot-swap)
├─ Bays 1–6: 6x 6TB SAS (Seagate ST6000NM0115) → RAIDZ2 datapool, ~24TB usable
└─ Bays 7–12: EMPTY → expansion (grow pool to 10x / add second pool / hot spares)
```

This is strictly better than the original plan. Cleaner cable management, no adapter trays, six empty bays for growth.

## Power / thermal

- 2x 750W EPP PSUs confirmed. Typical load 450–565W, peak 600–700W including future GPUs. 50–60% utilization is the efficiency sweet spot. N+1 redundant.
- YY2R8 heatsinks (165W) vs E5-2699 v4 CPUs (145W TDP) = 20W margin. Adequate.
- R730XD pulls ~30W more idle than R730 would have (~$32/year at $0.12/kWh). Offset many times over by the +$200–300 value received.

## Compatibility confirmation

Every component already ordered or planned remains compatible with R730XD:
- E5-2620 v3 temp CPUs, E5-2699 v4 production CPUs, H730P Mini Mono, Samsung SM863a SSDs, iDRAC 8 Enterprise license, X710-DA4 NDC, PLX8747 carrier, NVMe drives, Arc A380 / RTX 3060, rail kit (H4X6X is same for R730 and R730XD).

No re-orders required. No architectural changes to VLAN plan, Proxmox/TrueNAS/service layout, or network schema.

## KB updates performed (Karpathy Principle)

1. `build-log.md` — Lighthouse section rewritten for R730XD: chassis, memory spec, rear bay boot strategy, updated drift list, adjusted blockers and next actions.
2. `parts-compatibility.md` — added rear 2.5" caddy G176J, annotated YY2R8 heatsink "chassis-included" status, noted 2.5"→3.5" adapter now surplus.
3. Original file moved to `homelab/reference-docs/Lighthouse_R730XD_PKA_Update_April_2026.md` as the inspection-of-record for this chassis.
4. Database records to add to `jeffrey.db`:
   - `documents`: filename, project=homelab, type=inspection-report, date_ingested=2026-04-17, summary="R730XD chassis inspection — seven deviations from R730 plan, all favorable or neutral"
   - `homelab_parts`: update chassis record R730 → R730XD, RAM record → 4x32GB DDR4-2666, add G176J rear caddies as new line, flag YY2R8 separate order for reconciliation

## What I need from Jeffrey

- [ ] **Rack depth measurement** — hard blocker before rails mount
- [ ] **Minnesotacompu heatsink reconciliation** — verify on arrival, decide spare disposition
- [ ] **Approve updated shopping list** — drop heatsinks + 2nd adapter, add 2x G176J rear caddies
- [ ] Optional: approve resale plan for any duplicate heatsinks after verification

Nothing gets ordered until you sign off.

---
*Filed to: homelab/leader-inbox/ per the Leader Inbox Rule.*
