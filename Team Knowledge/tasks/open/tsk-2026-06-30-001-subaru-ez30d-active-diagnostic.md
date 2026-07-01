---
# Identity
id: tsk-2026-06-30-001
title: "Subaru EZ30D active diagnostic — cooling fans, lean LTFT, misfire capture, obd-scanner integration"

# Ownership & priority
assignee: rizzo
priority: 1

# Status (mirrors folder location)
status: open
blocked_reason: null
blocked_by: null

# Time
created: 2026-06-30T00:00:00Z
updated: 2026-06-30T00:00:00Z
due: 2026-07-07

# Provenance
created_by: hawkeye
source: session
parent: null

# Cross-references — REQUIRED, even if empty array. Seven slots. The act of filling these is the whole point.
# See [[GL-004-task-resource-linking]] for the one-way rule (task→resource, never the reverse) and slug formats.
linked_sops: ["SOP-010-create-task", "SOP-012-close-task", "SOP-017-read-own-journal"]
linked_workstreams: ["WS-005-obd-scan-intake-and-fleet-triage"]
linked_guidelines: ["GL-001-file-naming-conventions"]
linked_my_life: ["obd-scanner"]
linked_session_logs: []
linked_journal_entries: []
linked_deliverables: ["2026-06-30-subaru-outback-obd-vlinker-reanalysis", "2026-06-30-subaru-obd-research"]

# Tagging
tags: ["subaru", "obd", "automotive", "diagnostic", "python"]
---

# Subaru EZ30D active diagnostic — cooling fans, lean LTFT, misfire capture, obd-scanner integration

## What this is

Three CRITICAL/HIGH diagnostic threads on the 2008 Subaru Outback EZ30D are open as of the 2026-06-30 Vlinker session. The obd-scanner Python toolkit (`C:\Users\jeff\dev\obd-scanner\`) is the primary instrument. This task connects that project's dev work to the PKM vehicle record and tracks the open diagnostic items through to resolution.

The three threads:
1. **Cooling fans not confirmed operational** — coolant reached 111°C at idle with no fan activation; car must NOT be driven before fans are verified.
2. **Active misfire under load (flashing MIL)** — P030X code not yet captured. P0306 → IC608 ECM cold solder fault (specialist repair); P0300/P0301–P0305 → lean misfire from intake coupler sleeve.
3. **Chronic lean condition — LTFT B1 +15.62%, LTFT B2 +10.16%** — both banks lean, Bank 1 worst. Root cause not yet isolated: intake coupler sleeve (most likely), MAF contamination, PCV hose, or aging LAF sensor.

## Context one click away

- My Life project: [[obd-scanner]]
- Vehicle record: [[2008-subaru-outback]]
- Vlinker session analysis: [[2026-06-30-subaru-outback-obd-vlinker-reanalysis]]
- Prior OBD scan brief: [[2026-06-30-subaru-obd-research]]
- Fleet overview: [[fleet-overview]]
- Procedure for reading journal before starting: [[SOP-017-read-own-journal]]

## Success criteria

- Cooling fans confirmed operational at 95°C (visual check + relay swap test).
- P030X code captured during a drive session with `--log --read-dtc`; cylinder number documented.
- IC608 ECM verdict: if P0306 fires, ECM evaluation initiated. If P0300/P030X (non-6), lean misfire path pursued.
- LTFT B1 trend documented after MAF cleaning + coupler sleeve inspection. Drop below +10% is the target.
- PIDs 0x24 and 0x25 (wideband LAF) added to `obd_scanner/cli.py` (Pierce's task — surface to Pierce).
- [[2008-subaru-outback]] service history and Known Issues section updated with each completed action.
- `obd-scanner` project file updated with next-session prerequisites after each diagnostic run.

## Open action items (priority order)

### CRITICAL — before next drive
- [ ] Cold check: coolant level in overflow reservoir, oil dipstick for milky residue
- [ ] Watch cooling fans at operating temp — Fan 1 should spin before 95°C, both fans by 100°C
- [ ] Fan relay swap test (underhood fuse box — identical relay, free swap)
- [ ] If fans still don't activate after relay swap: do NOT drive — investigate fan motors

### HIGH — this week
- [ ] Pierce: add PIDs 0x24, 0x25, 0x34 to `obd_scanner/cli.py` logger
- [ ] Drive session: `obd-scanner --log --read-dtc` — capture P030X at MIL flash event
- [ ] Document which cylinder fires (P0306 = IC608 path; P0300/P0301–P0305 = lean misfire path)
- [ ] Clean MAF sensor with CRC 05110 (~$10)
- [ ] Inspect intake coupler sleeves — passenger side (Bank 1, cylinders 1/3/5) first

### MEDIUM — this month
- [ ] Replace cracked coupler sleeve(s) if found ($20–50 each)
- [ ] Coolant change (overdue at 150k)
- [ ] Brake fluid change (overdue at 150k)
- [ ] Idle relearn — once cooling fans confirmed working
- [ ] Throttle body cleaning (CRC non-chlorinated #05678)

## Updates

- 2026-06-30 00:00 (hawkeye) — created; born from session health check + Vlinker diagnostic session revealing three active critical threads; obd-scanner project at `C:\Users\jeff\dev\obd-scanner\` confirmed connected to PKM via [[obd-scanner]] My Life project

## Outcome

_(filled when status flips to done — see SOP-012-close-task)_
