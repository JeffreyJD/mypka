---
agent_id: rizzo
type: journal-entry
created: 2026-07-06T00:00:00Z
updated: 2026-07-06T00:00:00Z
topic: simultaneous-o2-sensor-codes-point-to-common-cause
tags:
  - subaru
  - obd
  - o2-sensors
  - heater-circuit
  - diagnostic-methodology
linked_session_logs: []
linked_tasks: ["tsk-2026-06-30-001"]
related_journal_entries: ["2026-07-04-subaru-mil-self-clear-and-ltft-adaptation"]
status: durable
---

# When every O2 sensor flags at once, suspect the shared supply — not the sensors

## Context

2026-07-06 code read on the 2008 Outback EZ30D found all six O2-system codes stored AND pending: P1152/P1154 (B1S1 upstream LAF), P1153/P1155 (B2S1 upstream LAF), P0140 (B1S2 downstream — new), P0160 (B2S2 downstream). Every oxygen sensor on the engine flagging simultaneously. An O'Reilly counter scan the same day independently reported "both downstream O2 sensors bad."

## What I learned

**1. Batch onset is the tell.** The 2026-07-01 scans showed zero stored/pending DTCs. The full six-code batch first appeared 2026-07-05 and grew (P0140 added) by 2026-07-06. Four sensors do not independently die in the same four-day window. Simultaneous multi-sensor O2 codes across both banks and both positions point to a shared dependency: the O2 heater supply (fuse/relay), a common ground, or the ECM heater drivers. Check the cheap shared item before condemning any sensor.

**2. "Works when hot, flags when cold" is the heater-failure fingerprint.** B1S1 produced valid wideband data during the 2026-07-05 highway drive (2.878V / +0.049mA) and fuel trims responded normally — yet B1S1 carries range/perf + malfunction codes. A sensor with a dead heater still functions once exhaust heat brings the element to temperature; it fails the ECU's warm-up-time checks (range/perf codes) and downstream sensors far from the engine may never get hot enough at idle ("no activity" codes). A dead element, by contrast, never produces data. Distinguish these before buying parts.

**3. Counter scans (parts-store code pulls) report symptoms, not diagnosis.** O'Reilly's "both downstream sensors bad" was code-accurate (P0140 + P0160 are real) but the implied fix (two sensors) may be wrong if a $2 fuse killed the heaters. Treat retail scan verdicts as code inventories to verify with our own scan, never as repair orders.

## Addendum — same day, drive session 19:26

Confirmed within hours. All 6 codes self-cleared between 19:12 and 19:21 with no Mode 04 performed (readiness monitors stayed READY — the tell that no clear happened). On the 19:26 drive, both "no activity" downstream sensors switched normally (0.02–0.97V full swing, stdev 0.32) and both banks ran closed loop. Dead elements don't resurrect. The common cause is not just shared — it is INTERMITTENT: a flaky fuse seat, corroded terminal, or chafed harness making and breaking contact. Corollary lesson: **a sensor "confirmed dead" by codes on one day must be re-verified in live data before parts are ordered** — the B2S2 order placed 7/5 on P0160 evidence turned out to be for a working sensor.

## When this applies

- Any vehicle presenting 3+ O2/LAF codes across multiple banks/positions in one scan — run the common-cause check (heater fuse, relay, ground) before ordering sensors.
- Any O2 code where live data shows the sensor producing plausible values when fully warm — suspect heater circuit, not element.
- Any parts-store scan result — re-verify with obd-scanner before acting.

## Evidence

- Code read report: `C:\Users\jeff\dev\obd-scanner\logs\2026-07-06-19-12-unknown-dtc.md`
- Prior clean scans: 2026-07-01 idle + drive sessions (0 DTCs)
- 2026-07-05 drive log (B1S1 wideband functioning): [[2026-07-05-subaru-obd-drive-analysis]]
- Vehicle record: [[2008-subaru-outback]]
- Active task: [[tsk-2026-06-30-001-subaru-ez30d-active-diagnostic]]
