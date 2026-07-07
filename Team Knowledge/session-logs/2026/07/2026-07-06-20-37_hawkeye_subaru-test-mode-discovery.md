---
agent_id: hawkeye
session_id: 2026-07-06-subaru-test-mode-discovery
timestamp: 2026-07-07T00:37:00Z
type: end-of-session
linked_sops: ["SOP-020-obd-scan-analysis"]
linked_workstreams: ["WS-005-obd-scan-intake-and-fleet-triage"]
linked_guidelines: []
linked_tasks: ["tsk-2026-06-30-001-subaru-ez30d-active-diagnostic"]
linked_journal_entries: []
---

# Session log — 2026-07-06 — Subaru test-mode discovery and O2 sensor verdict reversal

## Context

Jeff came in with an O'Reilly counter-scan verdict ("both downstream O2 sensors bad") on the 2008 Outback EZ30D. The session ran two obd-scanner code reads and a drive session, and ended with the month-long blinking-MIL mystery likely solved. Rizzo handled all domain work.

## What we did

- **Rizzo** — verified O'Reilly's claim with a 19:12 code read: 6 codes stored+pending (P1152–P1155 both upstream LAFs, P0160 known, **P0140 B1S2 NEW**) — O'Reilly was right, and every O2 sensor on the engine was flagging at once. Flagged shared heater fuse as common-cause suspect; confirmed Denso 234-4447 fits both downstream positions.
- **Rizzo** — 19:21 pre-drive scan: all 6 codes GONE, no Mode 04 performed by anyone (readiness monitors stayed READY — the tell). Fault reclassified as intermittent.
- **Rizzo** — drive session 19:26–19:36 (256 rows, 73.3 mph max): both "dead" downstream sensors switching normally (0.02–0.97 V full swing); closed loop both banks; MIL OFF throughout; cooling fix re-confirmed (max 96 °C, second consecutive drive) — cooling issue marked **Resolved**; lean-at-idle still active (LTFT B1 idle avg +12.6 %, peak +17.19 %) — the 7/5 "normalized" figure was a drive-weighted average.
- **Rizzo** — on Jeff's clarification that the CEL blinks CONSTANTLY (since ~early June, predating the coolant issue): identified **Subaru dealer test mode via mated green connectors** as the likely lamp driver (verified via iWire + SubaruOutback.org). Jeff then corroborated: key ON/engine OFF = constant relay clicking + fuel pump cycling — the test-mode signature. Odds assessed ~90 % connectors, ~10 % wire-short/ECM/aftermarket.
- **Hawkeye** — all sensor orders put on HOLD (234-4447 arriving 7/8 becomes a spare); green-connector check placed at top of task action list; vehicle record, task file, memory, and two Rizzo journal entries written; two commits (`13b496c` GL-002 photo schemas backlog, `40c78f3` today's Subaru work).
- **Pierce (queued, not executed)** — two obd-scanner findings surfaced: `--log --read-dtc` combined silently drops the logger (cli.py returns after report), and B2S1 upstream produces no PID data despite closed-loop B2 (instrumentation gap, not sensor death).

## Decisions made

- **Hold all O2 sensor purchases/installs.** Sensors demonstrated functional in live data; fault is supply-side intermittent. The B2S2 unit arriving 2026-07-08 stays boxed as a spare.
- **Cooling thread closed.** Broken radiator cap + low coolant confirmed as root cause across two drives; thermostat/water-pump watch retired.
- **Diagnostic priority reordered:** green test-mode connectors first, O2 heater fuse/connector inspection second, intake-leak work (MAF clean + B1 coupler sleeves) unchanged and still required.

## Insights

- **Blinking MIL + zero codes on every scanner = the lamp is not driven by the fault path.** On Subarus, check the green test-mode connectors. Key-ON/engine-OFF relay clicking + continuous fuel pump cycling is the free confirmation. (Journal: `2026-07-06-blinking-mil-subaru-test-mode`)
- **Simultaneous multi-sensor code batches point to shared supply, not sensor death; and codes that self-clear without Mode 04 point to intermittent contact.** Re-verify "dead" sensors in live data before ordering parts — the 7/5 B2S2 order was placed for a working sensor. (Journal: `2026-07-06-simultaneous-o2-codes-common-cause`)
- **Mystery symptoms that start during DIY work windows: enumerate the job's diagnostic *procedures* (test connectors, jumpers), not just its parts.** The greens were likely mated during early-June fuel-pump diagnosis.
- **Whole-session trim averages mask idle faults.** LTFT must be evaluated per load regime; the 7/5 "normalization" was an artifact of drive-weighted averaging.
- **Test mode contaminates diagnostics** — "fans always running", chronic EVAP NOT READY, and possibly the phantom O2 code batches all need re-baselining after the connectors are unplugged.

## Realignments

- Jeff, on my lean-misfire-under-load explanation of the blink: "it is constantly blinking and has been for over a month and well before the coolant issue which just started." This reversed the diagnosis from misfire to test mode. Constant-vs-intermittent blink is a load-bearing distinction — capture cadence, not just presence, for any indicator symptom.

## Open threads

- **Green connector check** (tomorrow, 2026-07-07): unplug → key cycle → confirm blink + clicking stop. If greens are NOT mated: trace test-line ground short before suspecting ECM.
- **Post-test-mode re-baseline:** `--read-dtc` snapshot, EVAP readiness over subsequent drives, watch for O2 code batch return on cold starts.
- **Lean-at-idle investigation:** MAF clean (CRC 05110) + Bank 1 coupler sleeve inspection — unchanged, still required.
- **Pierce:** CI task (tsk-2026-07-01-001) untouched; plus the two new obd-scanner findings above; PIDs 0x24/0x25/0x34 still pending.
- **SSM2 K-Line cable** purchase for chassis codes (C0071/SAS) still pending.
- Denso 234-4447 arrives Tue 2026-07-08 — spare unless cold-start scans re-implicate B2S2.
- Coolant reservoir surface check (oil slick/sludge) remains the one unchecked head-gasket item.

## Next steps

1. Jeff: pull the green connectors, report result.
2. Rizzo: interpret the post-unplug `--read-dtc` baseline; branch per result.
3. Hawkeye: route Pierce's obd-scanner fixes when Jeff wants code work.

## Cross-links

- Prior session: [[2026-07-05-10-00_hawkeye_sea-ray-audit-and-subaru-drive-diagnostic]]
- Active task: [[tsk-2026-06-30-001-subaru-ez30d-active-diagnostic]]
- Journals: [[2026-07-06-blinking-mil-subaru-test-mode]], [[2026-07-06-simultaneous-o2-codes-common-cause]]
