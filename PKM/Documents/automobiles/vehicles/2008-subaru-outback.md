# 2008 Subaru Outback

## Vehicle Details

| Field | Value |
|---|---|
| Year | 2008 |
| Make | Subaru |
| Model | Outback |
| Trim | [NEEDED] |
| Color | [NEEDED] |
| VIN | 4S4BP86C284304726 |
| Engine | 2.5L EJ253 (naturally aspirated boxer) |
| Transmission | [NEEDED] |
| Purchase date | [NEEDED] |
| Purchase mileage | [NEEDED] |
| Purchase price | [NEEDED] |

## Current Status

| Field | Value |
|---|---|
| Odometer | 159,000 mi (as of 2026-06-15) |
| Last service | 2026-06-15 (fuel pump replacement) |
| Next oil change due | ~164,000 mi or ~2026-11-29 (5,000 mi / 6 mo from 2026-05-29 change) |
| Active issues | Cruise control light blinking — scan needed (Scan 103); misfire codes reported on scan (Jeff reports "cylinders 4,5,6" — verify P0XXX codes, EJ253 is 4-cyl only); idle relearn not yet performed; ignition coil set ordered |

## Registration and Insurance

| Field | Value |
|---|---|
| Registration expiry | [NEEDED] |
| State | Pennsylvania |
| Insurance company | [NEEDED] |
| Policy number | [NEEDED] |
| Insurance expiry | [NEEDED] |

## Service Schedule

| Service | Interval | Last Done | Mileage | Next Due |
|---|---|---|---|---|
| Engine oil + filter | 5,000 mi / 6 mo | 2026-05-29 | ~149,830 | ~154,830 mi |
| Spark plugs (copper) | 30,000 mi | 2026-05-29 | ~149,830 | ~179,830 mi |
| Engine air filter | 15,000–30,000 mi | 2026-05-29 | ~149,830 | [NEEDED] |
| Cabin air filter | 15,000–30,000 mi | 2026-05-29 | ~149,830 | [NEEDED] |
| Brake pads + rotors | As worn | 2026-05-29 | ~149,830 | Monitor |
| Brake fluid | 30,000 mi / 2 yr | OPEN — not done at 150k | — | Do now |
| Coolant | 30,000 mi / 2 yr | OPEN — not done at 150k | — | Do now |
| Accessory belt | Inspect at 60k, replace 90k | OPEN — not checked | — | Inspect now |
| Plug wires | 60,000 mi | OPEN — not replaced at 150k | — | Do now |
| Transmission fluid | 30,000 mi | [NEEDED] | — | [NEEDED] |
| Differential fluid | 30,000 mi | [NEEDED] | — | [NEEDED] |
| Front wheel bearing hubs | As worn | 2026-05-29 | ~149,830 | Monitor |
| Front axle (passenger) | As worn | 2026-05-29 | ~149,830 | Monitor |
| Exhaust (from front pipe back) | As worn | 2026-05-29 | ~149,830 | Monitor |

## Service History

| Date | Mileage | Service | DIY/Shop | Notes |
|---|---|---|---|---|
| 2026-06-15 | 159,000 | Fuel pump replacement | DIY | Car now running; cruise control light blinking — scan needed |
| 2026-05-29 | ~149,830 (scanner) / actual odometer unknown | Spark plugs (all 4), brake pads + rotors (all 4), front wheel bearing hubs, passenger front axle, front brake dust shields, full exhaust replacement (front pipe back), engine oil + filter, engine air filter, cabin air filter | DIY | Battery disconnected during plug job — idle relearn NOT performed; scanner mileage was off — actual odometer reads 159,000 as of 2026-06-15 |
| — | — | Prior history | — | [NEEDED — drop receipts in Team Inbox] |

## Known Issues / Watch Items

| Issue | Severity | Status |
|---|---|---|
| Vacuum/intake air leak — rough idle, stalls in gear at low speed | High | OPEN — primary suspect: intake boot or clamp disturbed during 2026-05-29 plug job |
| Idle relearn NOT performed after battery disconnect | High | OPEN — do AFTER leak is fixed |
| Throttle body cleaning | Medium | PLANNED — do during leak investigation |
| Plug wires not replaced at 150k service | Medium | OPEN — should be done soon |
| Brake fluid change | Medium | OPEN — due at 150k, not done |
| Coolant change | Medium | OPEN — due at 150k, not done |
| Accessory belt not inspected | Medium | OPEN — 149k mi, age unknown |
| C0071 Steering angle sensor | Low | OPEN — replace & relearn when convenient (affects VDC accuracy only) |
| TPMS sensors ×4 dead batteries | Low | OPEN — replace at next tire change (18-year-old sensors) |
| SRS history code 26 (passenger airbag indicator) | Low | Monitor — longstanding |
| 8 NHTSA recalls listed | Unknown | OPEN — run VIN at nhtsa.gov/recalls to check completion status |

## Diagnostic Records

| Date | Tool | Key Findings |
|---|---|---|
| 2026-06-12 (scan 101 — before rough running) | Innova RepairSolutions2 all-system | Battery 14.29V running; C0071, SRS-26, TPMS noise; no engine DTCs; all emissions monitors ready (PA) |
| 2026-06-12 (scan 102 — after rough running) | Innova RepairSolutions2 all-system | Battery 14.00V running; transient multi-module codes (C0045, C0052, B2107, B2100, B2110) — attributed to voltage sag during near-stalls, not separate fault |

**Scans on file:** `PKM/Documents/automobiles/2026-06-12-outback-scan-101.pdf` and `-102.pdf`

## Recalls and TSBs

- 8 NHTSA open recalls and 271 TSBs listed against this VIN per 2026-06-12 scan reports
- **Action needed:** check VIN-specific recall completion at [nhtsa.gov/recalls](https://www.nhtsa.gov/recalls)

## Repair Diagnosis Notes

**2026-06-13 working diagnosis — vacuum/air leak:**
Rough running and stall at idle but smooth at ~3,200 rpm is the textbook signature of unmetered air entering past a leak. The leak is a large fraction of total airflow at idle (lean → stalls under gear load) but negligible at higher rpm. The 350 clean miles since the plug job exonerates the plugs and indicates something worked loose over time.

Most likely cause: intake accordion boot or clamp disturbed during rear plug access, reseated imperfectly, worked loose over 350 miles. Combined with missing idle relearn leaving the ECU without adaptive idle compensation.

**Repair order:**
1. Find and fix the air leak (re-check intake boot + all clamps, PCV valve + hose, any vacuum lines disturbed)
2. Clean throttle body (CRC non-chlorinated #05678 — do NOT use chlorinated cleaner on EJ253 bore coating)
3. Idle relearn (key ON 10s, then idle with no load — A/C off — until fully warm, cooling fan cycles 1–2×)
4. Confirm via LTFT live data: should be near 0% at idle after fix
5. Verify front O2 sensor connector seated; check for exhaust leak ahead of front O2

## Notes

- Owner-maintained by Jeff — strong DIY capability
- PA registered
- Source document: `PKM/Documents/automobiles/2008-subaru-outback-repair-record.md`
