---
agent_id: rizzo
type: journal-entry
created: 2026-07-01T00:00:00Z
updated: 2026-07-01T00:00:00Z
topic: subaru-obd-drive-analysis
tags:
  - subaru
  - obd
  - ltft
  - intake-air-leak
  - diagnostic-methodology
  - obd-scanner
linked_session_logs: []
linked_tasks: ["tsk-2026-06-30-001"]
related_journal_entries: []
status: durable
---

# Load-dependent LTFT is the definitive intake air leak fingerprint on the EZ30D

## Context

The 2026-07-01 highway drive session (992-row CSV, 15:27–15:52) produced the first live-driving OBD data on this vehicle. Comparing idle LTFT values against highway-load LTFT in the same session resolved the longstanding question of whether the lean condition was engine-wide or load-specific.

## What I learned

**1. Load-dependent LTFT = unmetered air, not sensor drift, not fuel injector wear.**

When LTFT is severely positive at idle (+15% range) and collapses to near-zero at steady highway speed, the root cause is almost always unmetered air entering after the MAF. Here is why: a fixed-size leak (crack in a coupler sleeve, loose boot clamp, unseated PCV hose) admits a roughly constant volume of air. At idle, the MAF is metering only a small total airflow (this EZ30D logs 3.5–4.6 g/s at idle). A small leak is a large percentage of that total — the ECU sees a huge discrepancy and runs LTFT way positive to compensate. At highway cruise the MAF commands ten or more times as much airflow. The same leak is now a tiny fraction of total airflow — the LTFT discrepancy washes out and LTFT approaches zero. When the car returns to idle after the highway run, LTFT snaps back to the high positive value within seconds (confirmed at CSV lines 932–935). No sensor drift or injector issue behaves this way. This is the textbook signature.

**2. The MIL activating during a drive cycle means a pending code crossed the confirmation threshold — not a new code appearing from nothing.**

OBD-II distinguishes pending (one drive cycle failure) from confirmed (two consecutive drive cycle failures). A DTC count of 1 at session start, plus MIL turning on ~5 minutes into the drive, means the code was already pending from a prior drive. This drive triggered the second failure event. The MIL comes on; the code is now stored and confirmed. This matters for diagnostic sequencing: if you see DTC count = 1 at session start with MIL OFF, there is a code waiting to confirm. Do not clear it — let it confirm and then read it.

**3. The obd_scanner Python logger outputs speed in km/h, not mph — with no label.**

The CSV column is labeled something like "Speed (MPH)" or similar but the values are km/h. Peak logged value of 107 matches 66.5 mph — a normal highway speed. If you read 107 as mph you would think the car was doing 107 mph on a surface street, which is obviously wrong. Detection method: cross-reference a known highway speed event. If the logged value is ~1.609× what you expect in mph, the unit is km/h. This is a known obd_scanner bug tracked with Pierce.

**4. Brief rich STFT spikes at high speed (-24% to -29% across both banks) are a possible misfire indicator, not a fuel delivery problem.**

When a cylinder misfires, the unburned oxygen-rich exhaust gases hit the downstream O2 sensor. The ECU sees a lean signal and adds fuel to compensate — but then the next cycle fires normally. This shows up as a negative STFT spike (ECU overcorrected rich). Simultaneous B1 and B2 spikes at -24% to -29% near 97 km/h could indicate a random misfire (P0300) or a load-sensitive misfire. It could also be a momentary MAF transient. Not conclusive from one drive, but worth noting the specific speed/load region where it occurred.

**5. Chassis codes (C0071 SAS) are invisible to the standard OBD-II port and to obd_scanner.**

The ABS/VDC module is a separate controller that requires manufacturer-specific communication (ISO 14229 UDS on a proprietary address, or Subaru SSM protocol). OBD mode $03 only retrieves emissions-related fault codes stored in the engine control module. C0071 was confirmed in earlier Innova all-system scans because the Innova RepairSolutions2 speaks multi-module. Do not conclude chassis codes are absent just because obd_scanner shows DTC count = 0.

**6. Do not compare idle LTFT to highway LTFT as if they represent the same correction map cell.**

The ECU uses separate LTFT map cells indexed by engine load and RPM. The idle cell and the highway cell are different entries in the fueling table. The dramatic difference between them in this session is diagnostic gold, but in normal operation you would not expect them to be identical — they index different operating conditions. What matters is the direction: idle cell is high positive, highway cell is near zero. That directionality is the leak signature.

## When this applies

- Next OBD drive session analysis on the 2008 Subaru Outback EZ30D
- Any future vehicle where idle LTFT is elevated and the cause is uncertain — run a highway drive session before concluding sensor failure or injector wear
- Any session where the obd_scanner speed column seems implausibly high — always check km/h vs mph before diagnosing speeding tickets
- Any session where MIL turns on mid-drive with DTC count already at 1 — that is a pending-to-confirmed code transition, not a new failure
- Any inquiry about whether C0071 or other ABS/VDC codes are active — confirm with Innova all-system scan, not obd_scanner

## When this does NOT apply

- Idle-only sessions (no highway load to compare against) — can confirm elevated LTFT but cannot yet isolate to the load-dependent pattern without a drive
- Vehicles with multi-port fuel injection where injector flow variation can produce bank-specific LTFT (the EZ30D is sequential MFI but bank differential of 6.25 pp still most consistent with a Bank 1 air leak, not injector wear)
- Cases where LTFT is elevated at ALL load points equally — that pattern points at MAF contamination or fuel pressure loss, not an air leak

## Evidence

- Drive session CSV: `C:\Users\jeff\dev\obd-scanner\logs\2026-07-01-15-26-2008-subaru-outback-log.csv` (992 rows, 15:27–15:52)
- Idle session CSV (same day): `C:\Users\jeff\dev\obd-scanner\logs\2026-07-01-17-34-2008-subaru-outback-log.csv`
- Vehicle record: [[2008-subaru-outback]]
- Active task: [[tsk-2026-06-30-001-subaru-ez30d-active-diagnostic]]
- Prior idle analysis deliverable: [[2026-07-01-2008-subaru-outback-obd-scan-idle-driveway]]
