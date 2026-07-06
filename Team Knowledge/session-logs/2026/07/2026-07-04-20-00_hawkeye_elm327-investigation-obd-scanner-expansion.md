---
agent_id: hawkeye
session_id: 2026-07-04-elm327-investigation-obd-scanner-expansion
timestamp: 2026-07-04T20:00:00Z
type: end-of-session
linked_sops:
  - SOP-020-obd-scan-analysis
linked_workstreams: []
linked_guidelines: []
linked_tasks:
  - tsk-2026-06-30-001-subaru-ez30d-active-diagnostic
linked_journal_entries:
  - 2026-07-04-subaru-mil-self-clear-and-ltft-adaptation
---

## Context

Continued from the 2026-07-01 Subaru OBD triage session. Jeff challenged the assumption that a generic ELM327 cannot see everything on the OBD2 port, leading to a full investigation of the Subaru K-Line bus and whether the existing Vlinker FS USB could be used to read ABS/VDC chassis codes in software. Secondary work: expanded the obd-scanner PID set, completed Team Inbox cleanup, and analyzed the 17:34 driveway idle CSV that had been sitting unprocessed.

---

## What we did

- **Hawkeye** — explained the split-bus architecture (CAN for engine ECM, K-Line for ABS/VDC/SAS/TCM) and why standard OBD2 Mode $03 cannot reach chassis codes
- **Pierce** — investigated ELM327 feasibility for Subaru ABS K-Line access; confirmed Vlinker FS USB is genuine ELM327 with CP210x bridge; found K-Line protocol mismatch (ELM327 runs 10400 baud/KWP2000, SSM2 requires 9600 baud/proprietary framing); built `subaru_chassis.py` with correct SSM2 frame format (ABS DTC request `80 15 F0 01 B8 3E`) and `--chassis-dtcs` CLI flag; 100 tests passing
- **Pierce** — merged `dev` to `main` (97be3dc), rewrote README to document all 26 logged columns, hardware requirements, and known limitations; 100 → 128 tests
- **Rizzo** — updated 4 myPKA files with K-Line investigation findings: Subaru vehicle file (new OBD Scanner Hardware Notes section + bus topology table), SOP-020 (Phase 1.5 chassis scope check added, guardrails expanded), Subaru diagnostic task (hardware investigation logged), fleet-overview (Diagnostic Tools table added)
- **Pierce** — added 10 new diagnostic PIDs to live logger: timing advance, throttle position, fuel system status, MAP, barometric pressure, commanded lambda, O2 B2 S1/S2, catalyst temps B1/B2, ambient air temp; 128 → 133 tests
- **Pierce** — added FUEL_STATUS tuple normalizer; merged `dev` to `main` (23f8c6f); 133/133 passing
- **Hawkeye** — cleaned Team Inbox: deleted 9 files + `.pytest_cache/` folder; retained `README.md` and the 17:34 Subaru CSV pending Rizzo analysis
- **Rizzo** — moved `2026-07-01-17-34-2008-subaru-outback-log.csv` to `obd-scanner/logs/`; ran SOP-020 five-phase analysis; discovered MIL self-cleared load-dependently; confirmed cooling fault at 114°C with both fans running; updated vehicle file, diagnostic task, and wrote journal entry

---

## Decisions made

**Software can partially solve the K-Line problem, but not with ELM327 hardware.** Pierce built the correct SSM2 frame format and `--chassis-dtcs` flag — the software layer is complete. The blocking factor is hardware protocol incompatibility (baud rate + frame format), not a software gap. Minimum purchase to close it: SSM2 K-Line USB cable (~$30–50, eBay/AliExpress).

**All diagnostic PID additions are gated behind `connection.supports()`.** The scanner will never crash on vehicles that don't advertise a PID — they log empty. This is the permanent pattern for adding PIDs.

**Timing advance was not in the logger — it is now.** Pierce confirmed it was missing from the PIDS manifest despite earlier column guesses. The README now reflects what the code actually logs.

**Team Inbox is a drop zone, not storage.** Files processed or available in their canonical location get deleted promptly at session close. Only the scaffold `README.md` is permanent in Team Inbox.

---

## Insights

**ELM327 K-Line limitation is architectural, not a bug.** The ELM327 chip's K-Line mode is hardcoded to ISO 9141-2 (10400 baud, KWP2000 framing). Subaru SSM2 runs at 9600 baud with a proprietary 0x80 header byte. There is no AT command override. This is permanent — no firmware or software change on the ELM327 side can bridge this. Only a raw K-Line transceiver (SSM2 cable or Tactrix) can reach the ABS module.

**MIL can self-clear between drive and idle sessions.** The 15:26 drive session ended with MIL ON (pending DTC confirmed). By 17:35 (103 minutes later) MIL was OFF, dtc_count was 0, and remained cleared for 25 minutes of idle. The P-code is load-dependent — triggers under highway acceleration, does not re-confirm at idle, ECU clears after sufficient consecutive non-failure cycles. An idle-only scan showing MIL OFF does not mean the fault is resolved.

**Total Bank 1 correction at hot idle: ~18.5%.** LTFT B1 at full hot idle is +14.06%, STFT B1 peaks at +5.47% above 113°C coolant. Combined correction of ~18.5% confirms an active lean condition at full operating temperature.

**Fan engagement has a distinct OBD signature.** At 113°C both fans kick: engine load steps down ~6%, MAF steps down ~0.7 g/s, RPM drops ~20. Cooling system capability is the separate question — the car reached 114°C stationary WITH both fans running.

---

## Realignments

None this session. No corrections from Jeff.

---

## Open threads

- **Cooling fault — stop-driving item.** Car reached 114°C stationary with both fans running. Physical checks needed before next drive: coolant level, oil milkiness (head gasket), thermostat, water pump impeller, belt condition.
- **P-code identity still unknown.** Innova RepairSolutions2 all-system scan needed during a highway drive while MIL is ON. Do not do that drive until cooling fault is addressed.
- **SSM2 K-Line USB cable pending purchase.** ~$30–50 on eBay/AliExpress. Jeff to order. Once in hand, Pierce connects it and the `--chassis-dtcs` K-Line path is live — C0071 readable natively from obd-scanner CLI.
- **SAS still not replaced.** Denso 88021AG02A, calibration relearn required after install.
- **Three vehicle files not yet created** — 2013 Dodge Grand Caravan, 2022 Chevy Silverado 2500 HD Custom, 2024 Toyota Grand Highlander Limited. Easy-ask info still needed from Jeff (colors of Caravan and Silverado, mileage approximations, purchase dates).
- **Timing advance was missing from logger — now added.** First scan with the full 26-column set should be the Innova all-system + obd-scanner run during a highway drive once cooling is confirmed safe.
- **Subaru diagnostic task `tsk-2026-06-30-001` remains open.**

---

## Next steps

1. Physical cooling checks on the Subaru — coolant level, oil cap (milkiness), thermostat, water pump — before any further driving
2. Order SSM2 K-Line USB cable (~$30–50, eBay/AliExpress)
3. Once cooling confirmed safe: highway drive with obd-scanner running + Innova ready to capture P-code while MIL is ON
4. Fill in `[NEEDED]` fields in fleet-overview for Caravan, Silverado, Grand Highlander — tell Hawkeye the colors and approximate mileage

---

## Cross-links

[[2026-07-01-18-10_hawkeye_subaru-obd-idle-triage]]
