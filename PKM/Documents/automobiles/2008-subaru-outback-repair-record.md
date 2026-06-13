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

**Working diagnosis:** intermittent power/ground fault (battery terminals, engine-to-chassis ground strap, or IGN circuit connection) browning out modules and disturbing engine running — pattern: simultaneous multi-module codes that clear themselves + voltage drift + rough running with a clean ECM. Plugs ruled DOWN as primary suspect (new 2 weeks ago, see below) — but **old plug wires on new plugs**, or a wire not fully seated from the plug job, is suspect #2.

**Plan:**
1. Clean battery terminals/clamps to bright metal; inspect & clean engine-to-chassis ground strap and body grounds; check underhood fuse box IGN connections (B2107 named that circuit).
2. Re-seat all plug wires at both ends; inspect wires for arcing (mist test in the dark) — wires were NOT replaced with the plugs.
3. If still rough: live-data scan WHILE rough — per-cylinder misfire counts, STFT/LTFT, MAF g/s — to split ignition vs vacuum/fueling.
4. Exhaust was just replaced (see below) — verify O2 sensor connectors fully seated and no exhaust leak ahead of the front O2.
5. **Safety:** if CEL ever flashes while rough, stop driving (active misfire → catalyst damage).

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
