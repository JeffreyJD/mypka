---
agent_id: hawkeye
session_id: 2026-06-24-subaru-outback-triage
timestamp: 2026-06-24T00:00:00Z
type: close-session
linked_sops: []
linked_workstreams: []
linked_guidelines: []
linked_my_life: []
linked_deliverables: []
---

# 2008 Subaru Outback triage — scans 107 & 108, SAS diagnosis

## Context

Continuation of the prior session (scaffold sync + Cockpit install). Jeff came back to focus entirely on the 2008 Subaru Outback. Two OBD-II scan PDFs (Reports 107 and 108, both Jun 23 2026) were waiting in Team Inbox. Jeff had also confirmed the idle relearn was done and the car was running well post-coil-pack replacement. The session became a full triage: scan analysis, record filing, and root-cause diagnosis for the cruise control fault.

## What we did

- **Hawkeye** analyzed Report 107 (159,906 mi, pre-drive): Emissions NOT READY (CAT/EVA/EGR incomplete), no engine/ABS/SRS codes, 14 TPMS noise codes, battery 14.13V.
- **Hawkeye** analyzed Report 108 (159,962 mi, post-56-mile drive): Emissions READY for PA — all monitors complete, no engine/ABS codes, SRS-26 history only, same TPMS noise. Car confirmed clean.
- **Hawkeye** delivered full triage work order: idle relearn (Jeff confirmed done), plug wires, brake/coolant flush, accessory belt, trans/diff fluid, TPMS at next tire change, SRS-26 monitoring, NHTSA recall check.
- **Hawkeye** copied Report 107 and 108 PDFs from `Team Inbox/` to `PKM/Documents/automobiles/` as `2026-06-23-outback-scan-107.pdf` and `2026-06-23-outback-scan-108.pdf`. Cleared Team Inbox.
- **Hawkeye** updated `PKM/Documents/automobiles/vehicles/2008-subaru-outback.md`:
  - Odometer updated to 159,962 mi
  - Active issues simplified (idle relearn done, vacuum leak likely resolved, 150k items and SAS remain)
  - Service history: added scan 107 and 108 entries; corrected coil pack entry with confirmed outcome
  - Known issues: vacuum/air leak downgraded to "likely resolved"; C0071 bumped Medium with confirmed cascade cause
  - Diagnostic records: added scans 107 and 108 to table; updated scans-on-file list
  - Repair diagnosis notes: closed the 2026-06-13 vacuum leak hypothesis as resolved; documented remaining preventive items
- **Hawkeye** diagnosed the cruise control cascade:
  - Jeff described: after ~20 min highway cruise, CC auto-disengaged; CEL steady on; CC light blinking; S light blinking; VDC OFF light on. Car reset after 5-min key-off; CEL briefly blinking on restart, then scan 108 came back clean.
  - Root cause confirmed: C0071 Steering Angle Sensor — already flagged in scan 101 (Jun 12). SAS lost zero-point calibration during battery disconnect (May 2026 plug job). Extended cruise exposes SAS drift → VDC fault threshold hit → cascade (VDC off → CC disengages → AT protection mode → S blinks → CEL sets). Resets at key-on because SAS re-initializes.
  - Post-restart blinking CEL: likely transient misfire stumble as systems recovered; cleared before scan 108 was taken. CAT monitor completing in scan 108 confirms no sustained misfire.
- **Jeff** decided to replace the SAS (not just calibrate).
- **Hawkeye** created Task #1: Replace Steering Angle Sensor — 2008 Subaru Outback (C0071). Steps: order OEM/Dorman part by VIN → install → calibrate (zero-point relearn via Innova RS2 or Subaru-capable shop) → highway test → clear codes → update PKM record.

## Decisions made

- **Decision:** Replace the SAS outright rather than attempting calibration-only. Calibration may be temporary if the sensor is internally degrading; replacement eliminates the root cause cleanly.
- **Decision:** Source OEM or Dorman (not generic). SAS is a VDC input — calibration drift from a low-quality sensor creates new fault loops.
- **Decision:** Zero-point calibration is mandatory post-install. New sensor ships uncalibrated. Innova RS2 VDC/SAS reset function is the first option; Subaru-capable shop is the fallback.

## Insights

- On 2008 Subaru Outback, battery disconnect (even brief, for plug/ignition work) loses the SAS zero-point calibration. The SAS should always be recalibrated as part of any job that disconnects the battery. This was the missed step in the May 2026 plug job that led to two subsequent OBD events (C0071 in scan 101, cruise cascade in June).
- The CC/VDC/S-light cascade is not multiple faults — it is one fault (SAS/VDC) propagating through integrated systems. Seeing all four lights at once on this generation Outback is diagnostic shorthand for VDC module fault.
- A blinking CEL after a VDC cascade restart is likely a transient misfire stumble (systems re-initializing), not a separate engine fault. Confirm by checking: does it clear in a few seconds? Does scan come back clean? If yes, it's not a primary engine fault.
- Scan 107 → 108 delta (56 miles, same day) shows the EJ253 can complete all PA emission monitors quickly once running cleanly. Fast monitor completion = healthy engine. Slow or incomplete monitors = investigate combustion or sensor issues.

## Realignments

- _(none this session)_

## Open threads

- [ ] Task #1: Order SAS part (OEM or Dorman, VIN `4S4BP86C284304726`) — not yet ordered
- [ ] 150k service items still open: plug wires, brake fluid, coolant, accessory belt inspection, transmission fluid, differential fluid
- [ ] TPMS sensors ×4 — replace at next tire change
- [ ] SRS code 26 (history) — monitor; diagnose before long road trip
- [ ] NHTSA recall check — run VIN at nhtsa.gov/recalls (8 NHTSA + 9 dealer recalls listed)
- [ ] Cockpit launch still pending — Jeff to double-click `Expansions/mypka-cockpit/start-cockpit.bat`
- [ ] myPKA-main folder still in My Drive — delete once satisfied with Cockpit

## Next steps

- Order the SAS; come back when part arrives for install walk-through if needed.
- Run idle quality check on next cold start to confirm relearn held.
- Work through 150k service items (plug wires are the most time-sensitive).

## Cross-links

- [[2026-06-24-hawkeye_scaffold-sync-cockpit-install]] — same day, prior session: scaffold sync to v4.1.1 + Cockpit install; also introduced Subaru triage context at close
- [[2026-06-13-08-13_hawkeye_close-session-laptop-vps-outback]] — first session with Subaru scan data (scans 101 + 102, pre-fuel-pump)
