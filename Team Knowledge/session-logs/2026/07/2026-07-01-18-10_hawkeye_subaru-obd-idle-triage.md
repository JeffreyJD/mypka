---
agent_id: hawkeye
session_id: 2026-07-01-subaru-obd-idle-triage
timestamp: 2026-07-01T23:10:00Z
type: end-of-session
linked_sops: ["SOP-015-write-session-log", "SOP-017-read-own-journal"]
linked_workstreams: ["WS-005-obd-scan-intake-and-fleet-triage"]
linked_guidelines: ["GL-001-file-naming-conventions", "GL-004-task-resource-linking"]
linked_tasks: ["tsk-2026-06-30-001-subaru-ez30d-active-diagnostic"]
linked_journal_entries: []
linked_deliverables: ["2026-07-01-2008-subaru-outback-obd-scan-idle-driveway"]
---

# Subaru OBD idle driveway triage — 2026-07-01

## Context

Jeff came in wanting to run a DTC read on the 2008 Subaru Outback but immediately hit a "VSS session locked" error on the obd-scanner CLI. After recovering the session lock, he ran a 25-minute idle log in the driveway. The session produced a drive log (not a DTC file). Rizzo triaged the data under WS-005 and issued a STOP DRIVING verdict.

## What we did

- **Pierce** diagnosed the "VSS session locked" error: a stale Python process was holding the COM port exclusively. Recovery: `taskkill /F /IM python.exe`, unplug Vlinker from OBD-II and USB, 60-second ignition-off wait, reconnect in order.
- **Rizzo** (first pass) received an incorrect framing — cooling fans assumed failed — and began triage with that assumption.
- **Hawkeye** intercepted Rizzo mid-triage via SendMessage after Jeff confirmed both fans were running. Correction delivered before the deliverable was written.
- **Rizzo** (corrected pass) completed WS-005 Step 3: loaded priors, read vehicle file, analyzed 949-row CSV log, produced deliverable, updated vehicle file and task.
- **Hawkeye** ran Librarian pass: added SOP-018 to `Team Knowledge/SOPs/INDEX.md` (was missing); no broken wikilinks; no SSOT violations found.
- **Hawkeye** committed all Team Knowledge changes and closed session.

## Decisions made

- **Cooling fans are working.** The prior session log (2026-06-30) noted "fans not observed activating" — now corrected. Both fans confirmed running by Jeff during the full 25-minute session. All fan relay action items in tsk-2026-06-30-001 are retired.
- **Verdict: STOP DRIVING** until the cooling system capacity fault is identified. 114°C at idle with fans running + dash gauge at 3/4 toward red = genuine overheating, not a sensor or relay issue.
- **Diagnosis sequence established** (cheapest first): cold coolant level check → oil/coolant contamination check (head gasket screen) → radiator cap (~$15) → thermostat + coolant flush (~$25 DIY, combine) → accessory belt + water pump assessment → radiator flow test.
- **Lean investigation deferred** until cooling is resolved. Data at 114°C is contaminated for LTFT trend analysis.

## Insights

- The EZ30D water pump is accessory belt-driven. An uninspected belt at 160k miles is a plausible low-flow cause that could explain 114°C at idle with fans running — a non-obvious culprit to check before the thermostat.
- The coolant temperature is worsening between sessions: 111°C (2026-06-30) → 114°C (2026-07-01). This is a directional trend, not a one-off reading.
- STFT B1 is escalating at heat soak (+6.25% at 113°C this session vs. +4.69% prior). Total effective lean on Bank 1 (~18.75%) is approaching the DTC set threshold (~25%) — load conditions during driving are likely crossing it, explaining the flashing MIL.
- The MAF signal step-down at 17:45:56 (4.24 → 3.52 g/s in one scan cycle at 113°C) is a repeatable pattern to watch across future sessions.

## Realignments

- **Cooling fan assumption corrected mid-session.** Hawkeye and Rizzo (first pass) both assumed the 114°C reading meant fans were not running, based on the uncertain 2026-06-30 observation. Jeff confirmed physically that both fans ran throughout. The diagnosis pivots entirely: the problem is cooling capacity/flow, not fan activation. Future sessions should not assume fan failure without visual confirmation.

## Open threads

- [ ] Jeff to run cold coolant level check and oil dipstick inspection before next start
- [ ] Jeff to inspect for milky oil or oily coolant (head gasket screen — if positive, stop all DIY and go to shop)
- [ ] Radiator cap replacement (~$15)
- [ ] Thermostat + coolant flush (combine as one service event)
- [ ] Accessory belt inspection (belt drives water pump — uninspected at 160k)
- [ ] Pierce: add PIDs 0x24, 0x25, 0x34 (wideband LAF) to `obd_scanner/cli.py`
- [ ] Drive session with `--log --read-dtc` to capture P030X — only after cooling confirmed healthy
- [ ] MAF cleaning (CRC 05110, ~$10) + Bank 1 intake coupler sleeve inspection

## Next steps

1. Cold checks first (coolant level, oil dipstick) — Jeff can do these now, no tools required.
2. Once head gasket is screened out, start with radiator cap swap and coolant flush.
3. Accessory belt inspection before committing to thermostat replacement.
4. Drop the next drive log into `Team Inbox/` — WS-005 handles intake automatically.

## Cross-links

- [[2026-07-01-10-17_hawkeye_agent-fix-obd-scanner-workstream]] — earlier today's session that wired up WS-005 and fixed the obd-scanner shims
