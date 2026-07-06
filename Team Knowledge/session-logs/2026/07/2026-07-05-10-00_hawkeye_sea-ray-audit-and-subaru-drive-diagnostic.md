---
agent_id: hawkeye
session_id: 2026-07-05-sea-ray-audit-and-subaru-drive-diagnostic
timestamp: 2026-07-05T22:00:00Z
type: close-session
linked_sops: ["SOP-020-obd-scan-analysis"]
linked_workstreams: ["WS-005-obd-scan-intake-and-fleet-triage"]
linked_guidelines: ["GL-001-file-naming-conventions", "GL-004-task-resource-linking"]
linked_tasks: ["tsk-2026-06-30-001-subaru-ez30d-active-diagnostic"]
linked_journal_entries: []
---

# Sea Ray equipment audit + Subaru EZ30D drive diagnostic + O2 sensor identification

## Context

Jeff opened a fresh session (post `/clear`) on July 5, 2026. Two workstreams ran in parallel: the Sea Ray 340 Amberjack vessel record needed updating from equipment photos in Team Inbox, and the 2008 Subaru Outback EZ30D needed a live OBD diagnostic session covering cold checks, a drive log run, and analysis of a month-long flashing CHECK ENGINE light that prior sessions had tracked but not resolved.

## What we did

### Sea Ray 340 (Happy Ours)
- **Hawkeye** read 6 equipment photos from Team Inbox and updated `sea-ray-340.md` with confirmed electronics (Garmin GPSMAP XSV chartplotter ×2, Garmin XHD2 radar, Raymarine autopilot, Fish Hawk Electronics Bluetooth depth/temp display, Standard Horizon VHF), Bennett trim tab system, and WinGear controls (status: DNF)
- **Hawkeye** moved all 6 images from Team Inbox to `PKM/Images/2026/06/` with GL-001 slugs
- **Hawkeye** updated Known Issues: WinGear marked DNF; holding tank/hoses marked ✅ Resolved 2021; rudder packing marked ✅ Resolved 2022; maintenance log entries added for both
- **Henry** added NOAA Marine Forecast Zone table (LEZ148/LEZ149) to `lake-erie-intel.md`

### Subaru EZ30D diagnostic
- **Hawkeye + Rizzo** walked Jeff through pre-drive cold checks: oil normal (no HG contamination), coolant LOW
- **Jeff** topped off coolant and replaced radiator cap — found **broken in the middle** (pressure valve failed)
- **Hawkeye** directed a 40-minute highway drive session (19:31–20:11, 874 rows, 70.8 mph max) via `obd-scanner --log`
- **Rizzo** analyzed the drive CSV: max coolant 96°C (zero rows above 100°C vs. prior 114°C), LTFT normalized to near-zero at highway (B1 -0.68%, B2 -1.37%), MIL did not fire — overheating root cause confirmed resolved
- **Hawkeye** directed pre-drive DTC scan finding 5 stored codes: P1152/P1153/P1154/P1155 (LAF sensor faults both banks), P0160 (downstream B2S2 dead)
- **Hawkeye** read and synthesized all 4 historical Innova scan PDFs (101, 102, 107, 108 — June 2026): all show ENGINE = NO CODES, confirming neither the Innova nor the ELM327 has ever captured the P-code behind the flashing MIL; P115x codes post-date June 23
- **Hawkeye** wrote the flashing MIL memory to persistent memory so future sessions do not lose this context
- **Rizzo** confirmed Bank 2 = driver's side (left) on the EZ30D via SubaruOutback.org forum research; corrected prior vehicle file label error (Bank 1 was mislabeled as driver's side — fixed)
- **Rizzo** identified replacement sensors: Denso 234-9047 (upstream B2S1 LAF) and Denso 234-4447 (downstream B2S2)
- **B.J.** independently verified Denso 234-9047 against DensoProducts.com, Advance Auto Parts, FinditParts, and PartsHawk — **corrected wire count to 4-wire** (Rizzo had stated 5-wire); confirmed correct fitment for EZ30D H6 3.0L 2003–2009
- **Hawkeye** updated vehicle file, deliverable, and task file with corrected part numbers and wire count; committed 14 files to git

## Decisions made

- **Question:** Which O2 sensors need replacing and in what order?
  **Decision:** Replace both Bank 2 (driver's side) sensors together — B2S1 upstream LAF (234-9047, produced zero data in drive log) and B2S2 downstream (234-4447, P0160 confirmed dead). Bank 1 upstream (B1S1) is still producing data; monitor 3 more drive cycles before deciding on replacement.

- **Question:** Was the chronic lean condition (LTFT B1 +14%, B2 +8%) caused by an intake air leak?
  **Decision:** No — it was caused by the overheating. With correct coolant temps (90–96°C), LTFT collapsed to near-zero at highway. Intake coupler sleeve inspection deprioritized unless LTFT residual at idle does not continue dropping over next 2–3 drive cycles.

- **Question:** Is the flashing MIL a misfire (P030X)?
  **Decision:** Unknown, but tentatively not — no misfire code fired in the July 5 drive session at correct temps. The most likely current cause is the P115x LAF sensor codes (dual-bank A/F sensor failure). The pre-June-23 flashing MIL cause remains unidentified (possibly ABS C0045/C0071 cascade).

## Insights

- **Broken radiator cap as overheating root cause:** A failed pressure valve cap drops coolant boiling point by ~50°F (~28°C), making a 114°C plateau look like a thermostat or water pump fault when it's a $15 cap. Always check cap integrity before condemning cooling components.
- **EZ30D upstream LAF sensors are 4-wire wideband, NOT 5- or 6-wire.** Denso 234-9047 confirmed 4-wire, 7.87" harness. The upstream position uses a wideband lambda element; substituting a narrowband will trigger immediate malfunction codes regardless of wire count.
- **EZ30D Bank orientation:** Bank 1 = passenger side (right, cylinders 1/3/5). Bank 2 = driver's side (left, cylinders 2/4/6). This is fixed, verified, and now permanent in the vehicle file.
- **Innova RepairSolutions2 all-system scan consistently shows no engine codes on this Subaru** across 4 scans spanning June 2026 — including at least one scan taken during the active flashing MIL period. The instrument is not reliably capturing whatever sets the flash. The obd-scanner also misreads MIL state via PID 01. The P-code behind the flashing MIL has never been successfully read by any tool owned by Jeff.
- **P115x codes post-date June 23** — they are not the original cause of the month-long flashing MIL (which predates them). There are at least two separate fault events: the original unknown flash trigger (~June 5), and the new LAF sensor codes that developed after the June 23 coil pack replacement / battery disconnect.

## Realignments

- **Wire count correction:** Rizzo stated the upstream Denso sensor was "5-wire." Jeff questioned this immediately. B.J. verified against manufacturer and retailer specs — it is **4-wire**. All documentation was corrected before close. Rizzo's sensor research should be independently spot-checked against B.J. when ordering parts.

## Open threads

- [ ] **Flashing MIL P-code still unknown** — primary unresolved safety issue. Try: `obd-scanner --read-dtc` with engine running (all prior reads were KOEO); if inconclusive, AutoZone/O'Reilly free scan. The original trigger (pre-June 23) has never been captured by any tool.
- [ ] **Order and install Bank 2 sensors** — Denso 234-9047 (upstream B2S1, ~$100–150) + Denso 234-4447 (downstream B2S2, ~$50–80). Both driver's side. Verify VIN fitment at RockAuto before ordering.
- [ ] **Monitor B1S1 upstream LAF (P1152/P1154)** — still reading data; run 3 clean drive cycles; rescan before deciding on replacement.
- [ ] **Monitor idle LTFT residual** (B1 +3.75%, B2 +2.22% at end of July 5 drive) — expect continued drop as ECU re-adapts at correct temps.
- [ ] **Coolant level cold check before next start** — confirm no slow leak from the cap swap.
- [ ] **Pierce: Fix MIL PID reading bug** — obd-scanner `mil` column reads false OFF on this Subaru ECM throughout all drive sessions.
- [ ] **Pierce: Add GitHub Actions CI to obd-scanner** — tsk-2026-07-01-001, P3, open.
- [ ] **150k overdue services** — coolant flush, brake fluid change, accessory belt inspection.
- [ ] **Idle relearn** — not yet performed since battery disconnect in May.
- [ ] **2 Team Inbox images** (20260705_105325.jpg, 20260705_105244.jpg) — not yet processed.
- [ ] **Sea Ray 340 — autopilot model** — Raymarine unit confirmed present but model number unconfirmed; verify from unit or manual.
- [ ] **NHTSA recalls** — 8 open against this VIN; check completion status at nhtsa.gov/recalls.

## Next steps

1. Order sensors before next Subaru session: Denso 234-9047 + 234-4447 from RockAuto (verify fitment against VIN first)
2. Run `obd-scanner --read-dtc` with engine running to attempt MIL P-code capture
3. Check coolant cold before next start
4. After 3 drive cycles, re-scan to see if P115x is clearing naturally

## Cross-links

- `[[2026-07-01-18-10_hawkeye_subaru-obd-idle-triage]]` — prior session covering the 2026-07-01 idle driveway session and LTFT analysis
- `[[2026-07-04-20-00_hawkeye_elm327-investigation-obd-scanner-expansion]]` — ELM327 bus topology investigation and SSM2 K-Line protocol work
