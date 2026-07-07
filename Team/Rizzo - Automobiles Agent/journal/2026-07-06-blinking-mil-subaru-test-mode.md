---
agent_id: rizzo
type: journal-entry
created: 2026-07-06T00:00:00Z
updated: 2026-07-06T00:00:00Z
topic: blinking-mil-with-zero-codes-means-check-subaru-test-mode
tags:
  - subaru
  - mil
  - test-mode
  - green-connectors
  - diagnostic-methodology
linked_session_logs: []
linked_tasks: ["tsk-2026-06-30-001"]
related_journal_entries: ["2026-07-06-simultaneous-o2-codes-common-cause", "2026-07-04-subaru-mil-self-clear-and-ltft-adaptation"]
status: durable
---

# A blinking MIL with zero codes on every scanner means the lamp isn't driven by the fault path — on a Subaru, check test mode

## Context

The 2008 Outback's CHECK ENGINE light had blinked constantly for ~1 month (since ~early June 2026, present at the 6/12 Innova scan). Working theory was catalyst-threatening misfire (the OBD-II meaning of a flashing MIL). But four Innova scans, an O'Reilly counter scan, and every obd-scanner read reported MIL commanded OFF — most of that month with zero stored codes.

## What I learned

**1. A lamp that blinks while the MIL status bit reads OFF is not an emissions MIL event.** The ECM drives the physical lamp; Mode 01 PID 01 reports whether the ECM is commanding it for a fault. When they disagree for a month across multiple scan tools, stop asking "which fault?" and start asking "what else drives this lamp?"

**2. On Subarus, the answer is dealer test mode.** Two green single-wire connectors under the driver's-side dash, when mated, put the ECU in test mode: the CEL flashes constantly and the ECU continuously cycles the radiator fan relays, fuel pump, and solenoids. Verified via iWire and multiple SubaruOutback.org threads.

**3. Key-ON/engine-OFF behavior is the free confirmation test.** Normal: fuel pump primes ~2 seconds, then silence. Test mode: continuous relay clicking and fuel pump cycling for as long as the key is on. Jeff confirmed exactly this — the corroborating symptom that closed the loop without touching the car.

**4. Test-mode connectors get mated during DIY fuel-pump diagnosis and forgotten.** Mating the greens makes the pump cycle audibly — it is the standard way to test a suspect pump. This car's blinking started during the early-June stall diagnosis that led to the 6/15 fuel pump replacement. When a mystery symptom starts in the same window as DIY work, ask what diagnostic steps that job involves, not just what parts were changed.

**5. Test mode contaminates everything downstream — re-baseline after exiting.** A month of diagnostics on this car now needs re-reading: "fans always running" (test mode cycles them), EVAP monitor never completing, and possibly the intermittent all-sensor O2/LAF code batches (forced output checks cycle the O2 heater relay). None of those observations can be trusted until re-taken out of test mode.

## When this applies

- Any Subaru with a constantly (not intermittently) blinking CEL and clean code scans — check the green connectors before any other diagnosis.
- Any vehicle where the lamp state and the scanner's MIL-commanded bit disagree persistently — suspect a non-fault lamp driver (test/diag mode, cluster fault, wiring), not a hidden code.
- Any mystery symptom that began in the same window as DIY work — enumerate the diagnostic *procedures* of that job (jumpers, test connectors, disconnected sensors), not just the parts.
- After exiting any diagnostic mode — re-baseline monitors, codes, and behavioral observations before trusting prior data.

## Evidence

- Innova scans 101/102/107/108 (June 2026): no engine codes while lamp blinking
- obd-scanner reads 2026-07-05/06: MIL bit OFF throughout
- Jeff's key-ON observation 2026-07-06: continuous relay clicking + fuel pump cycling
- iWire test-mode reference: https://iwireusa.com/blogs/iwire-university/subaru-test-mode
- Vehicle record: [[2008-subaru-outback]]
- Active task: [[tsk-2026-06-30-001-subaru-ez30d-active-diagnostic]]
