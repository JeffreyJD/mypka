---
title: 2008 Subaru Outback — Repair Record
doc_type: other
physical_location: ""
digital_location: Documents/automobiles/ (scan PDFs 2026-06-12-outback-scan-101.pdf and -102.pdf)
issued_on: 2026-06-12
expiry_date: ""
renewal_trigger: ""
linked_people: []
linked_organizations: []
tags:
  - automobiles
  - subaru-outback
---

# 2008 Subaru Outback — Repair Record

Living service and diagnostic record. Newest entries first.

## Vehicle

- **VIN:** 4S4BP86C284304726 · **Engine:** 2.5L EJ253 · **Odometer:** 149,830 mi (2026-06-12)
- Owner-maintained by Jeff.

## 2026-06-12 — Rough running investigation (OPEN)

**Symptom:** engine began running "really rough" between two all-system scans taken ~1 hour apart. **Zero engine DTCs in either scan**; emissions monitors all ready (PA).

**Scans:** `Documents/automobiles/2026-06-12-outback-scan-101.pdf` (before) and `2026-06-12-outback-scan-102.pdf` (after). Innova RepairSolutions2 all-system scans.

**Key scan deltas (101 → 102):**
- Cleared/vanished between scans: C0045 (TCM malfunction), C0052 (ABS motor relay OFF failure), B2107 (IGN fuse blown / IGN circuit abnormal), B2100, B2110 (keyless module). Multi-module transient electrical gibberish.
- Battery voltage 14.29 V → 14.00 V (running).
- Persistent in both: C0071 steering angle sensor (chassis/VDC — separate item), SRS history code 26 (passenger airbag indicator, longstanding).
- All TPMS codes = dead in-wheel sensor batteries (18 years old) — noise, ignore for this issue.

**Working diagnosis (SUPERSEDED 2026-06-13 — see update below):** originally read as an intermittent power/ground fault browning out modules. Revised once the idle-specific symptoms came in.

### Update 2026-06-13 — symptom refinement → vacuum/air leak now primary

**New symptoms from Jeff:**
- Engine wants to **stall at idle and at low speed when put into gear**.
- In Park, brought up to ~3,200 rpm it **runs fine**.
- ~350 trouble-free miles since the plug change before this started 2026-06-12.
- **Battery WAS disconnected** during the plug job (needed to reach rear plugs on the EJ253). **Idle relearn was NOT performed afterward.**

**Revised diagnosis:** rough/stall at idle but smooth at ~3,200 rpm is the textbook signature of **unmetered air (vacuum / intake-boot leak)** — a leak is a large fraction of airflow at idle (lean, stalls under gear load) but negligible at higher rpm. The 350 clean miles exonerates the plugs and says something *worked loose over time*. The earlier multi-module electrical codes are now read as a **symptom** (voltage sag during near-stalls browning out modules), not a separate ground fault — one problem, not two.

**Most likely cause:** reaching the rear plugs requires disturbing the intake ducting + vacuum lines. A boot/clamp/line reseated imperfectly worked loose over 350 miles → air leak; AND the missing idle relearn left the ECU with no adaptive idle compensation to mask it. Two byproducts of the same plug job, stacking.

**Revised plan (do in this order):**
1. **Find/fix the air leak first.** Re-check the intake (accordion) boot and every clamp touched during the plug job; inspect PCV valve + hose and any disturbed vacuum lines. (Do NOT relearn idle with a leak present — it teaches the ECU bad values.)
2. **Idle relearn:** key ON ~10 s without starting (throttle init), then idle with no load (A/C off, no steering/brake input) until fully warm and cooling fan cycles 1–2×.
3. **Confirm via live data:** LTFT at idle vs ~2,800 rpm. High positive LTFT at idle dropping toward 0 at rpm = leak confirmed; near-zero at idle = resolved.
4. Verify front O2 connector seated + no exhaust leak ahead of front O2 (new exhaust).
5. **Safety:** if CEL ever flashes while rough, stop driving (active misfire → catalyst damage).

Demoted suspects: plug wires (350 clean miles), battery terminals/grounds (don't fit the idle/rpm pattern — kept as a quick free check only).

**Separate items (not rough-running related):**
- C0071 steering angle sensor — replace & relearn when convenient (VDC accuracy).
- TPMS sensors ×4 dead batteries — replace at next tire change.

## ~2026-05-29 — Owner work completed (two weeks prior to scans)

- Spark plugs — all replaced (wires NOT replaced)
- Brake pads + rotors — all 4 wheels
- Front wheel bearing hubs installed
- Passenger-side front axle replaced
- Front brake dust shields replaced
- Exhaust system replaced from after the front pipe to the rear, including mufflers
- Engine oil + oil filter changed
- Engine air filter + cabin air filter replaced

**150k service checklist still open after this work:** brake fluid change, coolant change, plug WIRES / accessory belt inspection-replacement, transmission & differential fluid inspection.

## History / notes

- 8 NHTSA recalls + 271 TSBs listed against the vehicle per the scan reports — not yet reviewed against VIN-specific completion status. Worth a one-time recall check at [nhtsa.gov/recalls](https://www.nhtsa.gov/recalls) with the VIN.
