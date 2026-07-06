---
sop_id: SOP-020
title: OBD Scan Analysis
default_owner: rizzo
status: active
version: 1.0
created: 2026-07-01
updated: 2026-07-01
tags:
  - obd
  - subaru
  - diagnostic
  - automobiles
---

# SOP-020 — OBD Scan Analysis

**Default owner:** Rizzo
**Reusable by any agent** — this SOP is a skill, not exclusive to Rizzo.

Covers how to analyze an OBD scan session CSV produced by the `obd_scanner` Python CLI tool (`C:\Users\jeff\dev\obd-scanner\`). Applies to any vehicle in the fleet that has been logged with this tool. Vehicle-specific context (known codes, prior LTFT baselines, active issues) comes from the relevant vehicle file under `PKM/Documents/automobiles/vehicles/`.

---

## Guardrails (read before every analysis)

These are the failure modes that have caused misreads on real sessions. Check each before interpreting numbers.

1. **Speed unit — fixed in current builds; check the log date.** The `speed_mph` column in obd_scanner builds from 2026-07-04 onward is correct (mph). Logs captured **before 2026-07-04** output vehicle speed in km/h regardless of locale, with the column labeled "MPH" or left unlabeled. To confirm for a historical log: take a known highway event and verify the value makes sense in mph — a peak of 107 on a neighborhood drive is not 107 mph; it is 107 km/h = 66.5 mph. For any pre-fix log, treat the speed column as km/h throughout the analysis.

2. **obd_scanner does NOT capture actual DTC codes.** Mode $03 (stored fault codes) is not implemented in the current logger. What IS captured: PID 01 bit 7 (MIL on/off) and PID 01 byte 3 (DTC count). You will know the MIL state and how many codes are stored, but not what codes they are. A separate scan with the Innova RepairSolutions2 (or any reader that runs mode $03) is required to identify actual P-codes.

3. **Chassis codes (C/B/U) are on K-Line, not CAN — Mode $03 cannot reach them.** Mode $03 only retrieves emissions-related codes stored in the engine ECM (CAN bus, Pins 6/14). Codes like C0071 (SAS), C0045, B2107, and similar live in separate control modules. On the 2008 Subaru Outback, the ABS/VDC module speaks Subaru SSM2 at 9600 baud on K-Line (Pin 7) — the Vlinker FS USB ELM327 runs K-Line at 10400 baud with KWP2000 framing and cannot reach this bus. The `--chassis-dtcs` flag in obd-scanner probes both K-Line (SSM2) and CAN, but the K-Line side returns NO DATA without an SSM2 K-Line USB cable (~$30–50). To read chassis codes, use: (a) obd-scanner `--chassis-dtcs` with SSM2 K-Line USB cable, (b) Innova RepairSolutions2 all-system scanner, or (c) a shop with Subaru SSM. Never conclude chassis codes are absent based on obd_scanner CSV output alone.

4. **LTFT is load-cell specific — do not compare idle LTFT to highway LTFT directly.** The ECU stores separate fuel trim values indexed by load and RPM. A LTFT of +15% at idle and +1% at highway cruise does NOT mean the trim changed — they index different map cells. Compare idle LTFT sessions to other idle sessions; compare highway LTFT to other highway sessions. The difference BETWEEN cells in a single session is diagnostic (see Phase 2).

5. **O2 sensor B1 S1 (upstream, Bank 1) is a wideband LAF sensor on the EZ30D.** PID 0x14 returns garbage for this sensor. The correct PIDs are 0x24 (wideband current mA) and 0x25 (wideband voltage). If B1 S1 shows no data or a flat line, this is a logger limitation, not a sensor failure. Pierce is tracking the fix. B1 S2 (downstream narrowband) reads correctly via PID 0x15.

---

## Phase 0 — Locate and identify the scan file(s)

1. Confirm the vehicle and session date from context (Hawkeye dispatch or Jeff's description).
2. Find the CSV in `C:\Users\jeff\dev\obd-scanner\logs\`. Filename convention: `YYYY-MM-DD-HH-MM-<vehicle-slug>-log.csv`.
3. Note the session type from context or from the data:
   - **Idle session:** vehicle speed column is 0 throughout, RPM typically 650–800.
   - **Drive session:** vehicle speed column rises above 0; RPM ranges widely.
   - **Mixed:** includes both idle and driving segments.
4. Apply the **speed unit guardrail** immediately — verify km/h vs mph before reading any speed-related finding (see Guardrails item 1).
5. Read the relevant vehicle file (`PKM/Documents/automobiles/vehicles/<vehicle>.md`) before interpreting any numbers. Know the prior LTFT baseline, known active codes, and current MIL state.

**In Claude Code:** Read the CSV file using the Read tool; read the vehicle file using the Read tool.
**In any other LLM:** Open the CSV in a text editor or spreadsheet; read the vehicle file manually.

---

## Phase 1 — Read the baseline (session start conditions)

From the first 10–20 rows of the CSV, establish:

| Metric | Where to find it | What to record |
|---|---|---|
| MIL state | PID 01 bit 7 (column "MIL" or derived) | ON / OFF at row 1 |
| DTC count | PID 01 byte 3 (column "DTC_COUNT" or similar) | Number at row 1 |
| Coolant temperature | PID 05 (column "COOLANT_TEMP") | Starting value in °C |
| LTFT B1 | PID 07 | Starting %, note if locked or trending |
| LTFT B2 | PID 09 | Starting %, note if locked or trending |
| RPM | PID 0C | Starting RPM |
| MAF | PID 10 | Starting g/s |

**Interpretation triggers:**
- DTC count > 0 at session start with MIL OFF: a pending code exists but has not yet confirmed. Watch for MIL transition during this session.
- DTC count > 0 at session start with MIL ON: stored confirmed code(s). Cannot identify them from this CSV — note as "P-code(s) unknown, count = N, dedicated code read required."
- LTFT B1 or B2 above +10% at session start: lean condition active at baseline. Note the specific values for later Phase 2 comparison.

---

## Phase 1.5 — Chassis code scope check

Standard CSV logs contain **no chassis (C/B/U) codes**. OBD2 Mode $03 only surfaces engine ECM codes (P-codes). Before proceeding to Phase 2, determine whether chassis codes are a concern for this session.

**If chassis codes are not a concern** (no ABS warning, no VDC off indicator, no SAS symptom): proceed to Phase 2.

**If chassis codes are a concern** (e.g., C0071 SAS, ABS warning lamp, VDC off light):
- Run `obd-scanner --chassis-dtcs` separately — this is not in the standard CSV log workflow
- For Subaru ABS/VDC module: the `--chassis-dtcs` K-Line side requires an SSM2 K-Line USB cable (~$30–50); without it, K-Line returns NO DATA
- The CAN side of `--chassis-dtcs` (engine P-codes) works today with the Vlinker FS USB
- Alternative for immediate chassis read: Innova RepairSolutions2 all-system scan (no additional hardware needed)
- Document chassis code results in the vehicle file's Diagnostic Records table separately from the CSV session entry

---

## Phase 2 — Identify events

Scan the full session for these event types. Each event gets a timestamp and a note.

### 2A. MIL transitions

Any row where MIL state changes from the baseline value.

- MIL OFF → MIL ON: a pending code confirmed. Note the timestamp, RPM, speed, and LTFT values at the transition row. This is the moment a new stored fault was confirmed — not necessarily the moment the root cause started.
- MIL ON → MIL OFF: code cleared externally (rare during logging, but possible if the Innova was used between sessions).

### 2B. LTFT behavior across load

For drive sessions, extract LTFT values at three operating regimes:
- Idle (speed = 0, RPM < 900): record LTFT B1 and B2
- City/low-speed (speed > 0 km/h but < 60 km/h): record LTFT B1 and B2
- Highway (speed > 80 km/h): record LTFT B1 and B2
- Post-highway idle (first 10–20 rows after speed returns to 0): record LTFT B1 and B2

**Interpretation:**
- LTFT collapses at highway load and returns high at idle = intake air leak (unmetered air, load-dependent). The snap-back at post-highway idle is the confirmatory sign.
- LTFT elevated at ALL load points equally = MAF contamination or fuel pressure deficiency.
- LTFT elevated only at one bank (B1 much worse than B2, or vice versa) = bank-specific source (intake coupler on that bank's side, PCV hose for that bank).

### 2C. STFT spikes

Flag any STFT value beyond ±15% (either bank). Note:
- Timestamp and duration (how many rows is the spike)
- Speed and RPM at the spike
- Whether it is symmetric across banks (both banks) or asymmetric (one bank only)
- Direction: negative STFT spike (rich correction) at speed can indicate unburned oxygen from a misfire reaching the downstream O2 sensor.

### 2D. Coolant temperature trend

- Record starting temp, peak temp, and temp at session end.
- Note whether the fan came on (Jeff must confirm visually — obd_scanner does not log the fan relay state).
- Flag any sustained temp above 105°C as an attention item.
- Separate idle from highway running: coolant typically runs hotter at prolonged idle than at steady highway cruise (airflow through the radiator is higher at speed).

### 2E. RPM and MAF anomalies

- Unusual RPM spikes or drops at idle (below 600 or above 900 without driver input) may indicate throttle body fouling or vacuum leak severity.
- MAF step-changes correlated with temp transitions may indicate an adaptive strategy shift (EZ30D known to step-down MAF at ~112–113°C — logged in the 2026-07-01 idle session).

---

## Phase 3 — Compare against prior sessions

Before writing any finding, check the Diagnostic Records table and the Diagnostic Sessions section in the vehicle file for prior session data.

Questions to answer:
- Is LTFT B1 better, worse, or the same as the prior idle session? A worsening trend is more urgent than a stable elevated value.
- Did the MIL state change between sessions? (MIL was OFF in prior session, ON in this session = code confirmed in this session's drive.)
- Is the coolant peak temp rising over successive sessions? Rising peaks indicate degrading cooling capacity.
- Does any new STFT or RPM anomaly appear that was absent in prior sessions?

If prior sessions are absent (first session for this vehicle), note that no baseline exists and treat current session values as the initial baseline.

---

## Phase 4 — Write back

Every session analysis requires ALL of the following write-backs. Do not close an analysis without completing all four.

### 4A. Update vehicle file — Diagnostic Records table

Add a row to the `## Diagnostic Records` table in the vehicle file with:
- Date and session type
- Tool (obd_scanner Python CLI + Vlinker FS USB)
- Key findings in condensed form
- Reference to the CSV file path

### 4B. Update vehicle file — Diagnostic Sessions section

Add an entry under `## Diagnostic Sessions` with:
- Session date, type, and time range
- CSV file path(s)
- All key findings (8 bullets maximum — be specific, include values)
- Status at session end (MIL state, code status, next step)

If the `## Diagnostic Sessions` section does not yet exist in the vehicle file, create it after the `## Diagnostic Records` section.

### 4C. Update the active task

Find the relevant open task in `Team Knowledge/tasks/open/` (typically `tsk-YYYY-MM-DD-NNN`). Add an Updates entry covering:
- Session date and type
- MIL state and DTC count at start and end
- Key findings summary (3–5 bullets)
- Next steps

Update the task's `updated` frontmatter timestamp. If a new journal entry was written, add it to `linked_journal_entries`.

### 4D. Write a journal entry (if durable insight was gained)

Trigger: any session that reveals a new diagnostic pattern, confirms or refutes a hypothesis, or establishes a new baseline.

Write to `Team/Rizzo - Automobiles Agent/journal/YYYY-MM-DD-<topic-slug>.md` following the `_template.md` schema (Context, What I learned, When applies, When NOT, Evidence). Reference [[SOP-016-write-journal-entry]] for the full protocol.

**In Claude Code:** Use the Write tool to create the journal file; use the Edit tool for vehicle file and task file updates.
**In any other LLM:** Write each file update manually; confirm file paths match the naming conventions in [[GL-001-file-naming-conventions]].

---

## Cross-references

- [[GL-001-file-naming-conventions]] — slug and date rules for all file writes
- [[SOP-016-write-journal-entry]] — durable insight journal protocol
- [[SOP-017-read-own-journal]] — read prior entries before starting analysis
- [[WS-005-obd-scan-intake-and-fleet-triage]] — the workstream that owns intake and routing of new scan files
- [[2008-subaru-outback]] — vehicle file (primary write destination for Subaru sessions)
