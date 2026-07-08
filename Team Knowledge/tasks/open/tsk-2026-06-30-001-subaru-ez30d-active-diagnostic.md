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
updated: 2026-07-06T00:00:00Z
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
linked_journal_entries: ["2026-07-01-subaru-obd-drive-analysis"]
linked_deliverables: ["2026-06-30-subaru-outback-obd-vlinker-reanalysis", "2026-06-30-subaru-obd-research", "2026-07-01-2008-subaru-outback-obd-scan-idle-driveway", "2026-07-05-subaru-obd-drive-analysis", "2026-07-07-subaru-ez30d-diagnostic-summary-and-triage"]

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

### CRITICAL — before next drive (cooling system capacity fault)

2026-07-01 UPDATE: Jeff confirmed both fans running throughout the session. 114°C WITH fans running = cooling flow or heat-transfer problem, not fan relay. Fan relay test items below are retired.

- [x] Watch cooling fans at operating temp — CONFIRMED RUNNING by Jeff during 2026-07-01 session
- [x] Cold check: coolant level in overflow reservoir — **LOW** (2026-07-05; likely contributing to 114°C readings)
- [x] Oil dipstick: normal black color — no milky/gray appearance; head gasket NOT flagged (2026-07-05)
- [ ] Coolant reservoir: check for oil slick or brown sludge on surface (head gasket check) — surface appearance not yet confirmed
- [x] Replace radiator cap — **DONE 2026-07-05. OLD CAP WAS BROKEN IN THE MIDDLE — pressure valve failed. System was running at near-atmospheric pressure, dropping coolant boiling point ~50°F. THIS IS LIKELY THE PRIMARY CAUSE OF THE 114°C READINGS.**
- [ ] Replace thermostat (~$25 DIY, combine with coolant change) — eliminate partial-open stuck thermostat
- [ ] Inspect accessory belt: glazing, cracking, fraying, tension — belt drives the water pump (belt uninspected per service record)
- [ ] Assess water pump: pulley wobble, shaft seal weep, suspect impeller slip if all else passes
- [ ] Perform coolant flush and refill (overdue 10k miles, use Subaru OAT blue) — degraded coolant reduces heat transfer and scales radiator passages

### HIGH — this week
- [x] **GREEN TEST-MODE CONNECTORS: CONFIRMED AND CLEARED (2026-07-07).** Jeff found the green connectors mated, removed the jumpers — relay clicking and fuel pump cycling stopped immediately. Test mode confirmed as the cause of the constant cycling. CEL blink status on next key cycle: pending confirmation.
- [ ] **Re-baseline EVERYTHING post-test-mode** — re-scan DTCs (`--read-dtc`), re-check EVAP readiness over next drives, re-evaluate O2 code batches and fan observations (all may have been test-mode artifacts)
- [ ] **Inspect O2 heater fuse + connectors for intermittent contact** (underhood fuse box): reseat the fuse, look for corrosion/heat discoloration on fuse legs and box terminals; wiggle-test O2 sensor harness connectors. Fault is INTERMITTENT (codes self-cleared 2026-07-06, sensors demonstrated working on drive) — looking for a flaky connection, not a blown fuse
- [ ] Post-drive `--read-dtc` after next 2–3 cold starts — heaters matter most cold; a code re-batch on a cold morning localizes the fault window
- [ ] **HOLD all sensor installs/orders**: B2S2 Denso 234-4447 arriving 7/8 — keep as spare, do not install; do NOT order B1S2 or upstream LAFs (all demonstrated functional 2026-07-06)
- [ ] Pierce: add PIDs 0x24, 0x25, 0x34 to `obd_scanner/cli.py` logger
- [ ] Drive session: `obd-scanner --log --read-dtc` — capture P030X at MIL flash event
- [ ] Document which cylinder fires (P0306 = IC608 path; P0300/P0301–P0305 = lean misfire path)
- [x] Clean MAF sensor with CRC 05110 — **DONE 2026-07-07** (pre-clean idle LTFT B1 baseline: +9.01% avg / +17.19 peak from same-day drive; next drive log gives the after)
- [x] Reseat fuel cap for pending P0457 — **DONE 2026-07-07**; watch whether pending ages out over next drives
- [ ] Inspect intake coupler sleeves — passenger side (Bank 1, cylinders 1/3/5) first

### MEDIUM — this month
- [ ] Replace cracked coupler sleeve(s) if found ($20–50 each)
- [ ] Coolant change (overdue at 150k)
- [ ] Brake fluid change (overdue at 150k)
- [ ] Idle relearn — once cooling fans confirmed working
- [ ] Throttle body cleaning (CRC non-chlorinated #05678)

## Updates

- 2026-07-07 18:30 (rizzo) — **SPRAY TEST: NEGATIVE ACROSS THE BOARD.** Jeff sprayed starter fluid on all accessible seams/joints both sides — intake duct bellows (flexed), duct clamps, manifold runner seams, brake booster hose both ends, EVAP/purge spring-clamp joints — zero RPM change anywhere. Combined with the MAF clean producing no LTFT improvement, the evidence shifts away from a simple visible vacuum leak. Re-ranked suspects: (1) **PCV valve stuck open / crankcase path** — spray-invisible, free rattle-check; (2) **exhaust leak upstream of B1S1** (pre-cat air ingestion reads falsely lean → ECU over-fuels; B1-dominant fits; spray can't detect) — listen for cold-start tick passenger side, look for soot at manifold joints; (3) **downward-facing intake/manifold gasket leak** — only a SMOKE TEST finds it; (4) **B1S1 wideband LAF drift reading lean-biased** — the earlier P1152/P1154 range/perf codes gain new relevance if smoke test comes up clean. Engine bay photos filed: `2026-07-07-subaru-ez30d-engine-bay-{driver,passenger}-side.jpg` + sidecars.
- 2026-07-07 16:32 (rizzo) — **POST-MAF-CLEAN DRIVE ANALYZED** (16:17–16:33, 431 rows, max 36 mph, warm start 94°C, no highway). **Hot-idle LTFT B1 essentially unchanged after the MAF clean: idle avg +15.38%, peak +17.97 (vs +17.19 peak pre-clean).** All 197 idle rows fully warm, so this is the purest hot-idle sample yet — and it says the MAF was not (or not the main) cause of the lean condition. Caveats: (1) ECU LTFT relearn takes 2–3 drive cycles post-clean, STFT responds first (STFT B1 mid-drive peak +22.66% is high); (2) short low-speed drive, no cruise cells. Everything else clean: MIL 0 / dtc 0 all rows, both downstream O2s full-swing again, WB B1S1 3.027 V, coolant 94–100°C. VERDICT PATH: give it 2–3 more normal drives for relearn; if hot-idle LTFT B1 stays ~+15–18%, the unmetered-air source is downstream of the MAF — **Bank 1 coupler sleeve inspection + PCV hose check, then smoke test** ($20–35 at shop, or DIY). Note B1 peak +17.97% is creeping toward P0171 threshold territory (~+25%). CSV: `logs/2026-07-07-16-16-2008-subaru-outback-log.csv`.
- 2026-07-07 14:47 (rizzo) — **POST-DRIVE SCAN: EVAP monitor RAN for the first time post-test-mode and flagged P0457 PENDING** (EVAP leak — fuel cap loose/off class). MIL OFF, 0 stored; all monitors READY except EVAP (still completing its multi-trip sequence). Interpretation: the chronically-blocked EVAP monitor is now actually executing — the pending code is the monitor doing its job, and the most common cause is a loose/aged fuel cap. ACTION: retighten fuel cap (multiple clicks), drive normally; pending should age out without maturing. If P0457 matures to stored after cap retightening → inspect cap seal, filler neck, EVAP hoses. Do NOT clear codes — let the monitor finish naturally. Report: `logs/2026-07-07-14-47-2008-subaru-outback-dtc.md`.
- 2026-07-07 14:34 (rizzo) — **FIRST POST-TEST-MODE DRIVE ANALYZED** (13:47–14:34, 1,324 rows, max 77 mph, CSV `logs/2026-07-07-13-46-2008-subaru-outback-log.csv`). (1) **MIL off / dtc_count 0 all 1,324 rows** — first fully clean drive of the summer. (2) **Both downstream O2 sensors full-swing switching (0.00–0.97 V) the entire session** — second consecutive drive confirming sensors healthy; WB B1S1 avg 3.009 V normal. (3) **Cooling: cruise rock-steady 91–95°C for 36+ min.** Brief spikes to 106–112°C only at 14:24–14:31, immediately following hard pulls (90% load @ 4,383 RPM) and end-of-drive low-speed heat soak — recovered 112→105 in ~16 s, ended 99°C. NOT the old always-114 pattern; reads as reduced cooling margin under abuse on a hot July afternoon → the overdue coolant flush is the indicated fix, no watch-status change. (4) **Lean-at-idle persists, slightly improved: LTFT B1 idle avg +9.01% (peak +17.19, includes warmup rows), B2 idle +3.70%; cruise B1 +0.86%** — unmetered-air signature unchanged; MAF clean + B1 coupler sleeves remain the action. (5) B2S1 PID gap persists (instrumentation, Pierce's item). Pending: post-drive `--read-dtc` (EVAP readiness check) + cold-start scans.
- 2026-07-07 (rizzo) — **BLINKING MIL: RESOLVED — CONFIRMED BY DRIVE.** CEL off and stayed off through a full drive after the green connectors were unplugged. The month-long "flashing MIL" issue is closed: cause was dealer test mode (greens mated during early-June fuel-pump diagnosis), fix was $0. Vehicle record row moved to Resolved. Remaining watches: EVAP readiness completion over next drives, O2 code batch on next 2–3 cold starts, post-drive `--read-dtc` + drive CSV pending analysis.
- 2026-07-07 13:38 (rizzo) — **POST-TEST-MODE BASELINE: CLEAN.** First `--read-dtc` after the green connectors were unplugged: MIL OFF, **0 stored, 0 pending**, readiness monitors ALL READY except chronic EVAP. Notably: no O2/LAF codes present (P115x/P0140/P0160 batch absent) and both O2 monitors (sensor + heater) READY — consistent with the code batches having been test-mode artifacts or a make/break contact that is currently good. Cold-start watch over next 2–3 mornings remains the discriminator. EVAP NOT READY expected — it needs normal drive cycles now that test mode is no longer potentially blocking it; watch over the next week. VIN auto-read failed again (known); `--vehicle` override worked. Report: `logs/2026-07-07-13-38-2008-subaru-outback-dtc.md`. Incidental: ignition key jammed after the under-dash work — steering-lock pin under tension; freed by rocking the wheel while turning the key. No damage.
- 2026-07-07 (rizzo) — **TEST MODE CONFIRMED AND CLEARED.** Jeff located the green connectors under the driver's-side dash, found them MATED, and removed the jumpers. Relay clicking and continuous fuel pump cycling stopped immediately — the test-mode signature is gone. This closes the month-long blinking-MIL mystery at the predicted ~90% branch: the connectors were left mated during the early-June fuel-pump diagnosis. Remaining confirmations: (1) CEL blink gone on next key-on/engine-run, (2) post-test-mode re-baseline — `--read-dtc` snapshot, EVAP readiness over next drives, fan behavior re-observation, cold-start O2 code watch. Wear-mode on the new fuel pump/relays/battery from weeks of cycling: ended.
- 2026-07-06 (rizzo) — TEST MODE CORROBORATED by Jeff: with key ON / engine OFF, constant clicking from the engine bay (relays/solenoids) and continuous fuel pump noise — the exact test-mode output-cycling signature (normal behavior is a single ~2 s pump prime, then silence). Three independent symptoms now align: constant CEL blink, zero codes on every scanner while blinking, continuous relay/pump cycling at key-on. Physical check of green connectors is the only remaining confirmation step. Note: continuous cycling is active wear on the new fuel pump, relays, and battery — unplug promptly.
- 2026-07-06 (rizzo) — BLINKING MIL LIKELY SOLVED: Jeff clarified the CEL blinks CONSTANTLY, for over a month, predating the coolant issue. Constant blink + every scanner reporting MIL-commanded OFF + 0 codes = lamp is NOT driven by the OBD fault path. Classic Subaru cause verified via iwireusa.com + SubaruOutback.org: green test-mode connectors under driver's dash left mated → dealer test mode → CEL flashes constantly, radiator fans/fuel pump/solenoids cycle continuously. Timeline: blinking already present at 6/12 Innova scan → greens likely mated during the early-June fuel-pump DIAGNOSIS (mating them cycles the pump audibly — standard test), pump then replaced 6/15. Cascading implications if confirmed: (a) "fans running constantly" observation was possibly test-mode cycling, (b) chronic EVAP NOT READY possibly blocked by test mode, (c) intermittent O2/LAF code batches possibly forced-output-check artifacts, (d) the month of "flashing MIL = catalyst-killing misfire" worry dissolves. Action item added at top of HIGH: unplug greens, key cycle, re-baseline all diagnostics. Vehicle record Known Issues row rewritten.
- 2026-07-06 (rizzo) — Drive session complete (19:26–19:36, 256 rows, max 73.3 mph, RPM to 3994). VERDICT-CHANGING RESULTS: (1) **Both downstream O2 sensors ALIVE — B1S2 0.02–0.97V, B2S2 0.01–0.96V, full narrowband switching all session.** The P0140/P0160 "no activity" sensors work when running. Dead elements don't resurrect → intermittent heater-supply/connector fault confirmed as leading theory. ALL sensor orders now on HOLD; 234-4447 arriving 7/8 becomes a spare. (2) MIL OFF, dtc_count 0 all 256 rows — nothing re-confirmed during a proper load pull. Pending codes not visible in CSV; post-drive `--read-dtc` still needed (esp. after cold starts). (3) Cooling fix re-confirmed second consecutive drive: max 96°C, highway 91–93°C. Thermostat/water pump watch retired; cooling issue marked Resolved in vehicle file. (4) **Lean-at-idle NOT resolved: LTFT B1 idle avg +12.6%, peak +17.19% (matches pre-cap-fix values); B2 idle +5.85%. Highway B1 +0.81%/B2 -1.46% with instant snap-back at stop — the unmetered-air-at-idle signature is unchanged. The 7/5 "LTFT normalized" reading was a drive-weighted average, not a fix.** MAF clean + coupler sleeve inspection remain fully warranted. (5) B2S1 upstream produced no PID data BUT fuel_status shows closed loop both banks and STFT B2 active — ECU is getting B2S1 signal; log gap is instrumentation (surface to Pierce with the --log/--read-dtc flag conflict). Vehicle record updated: Diagnostic Records row, Active issues, Known Issues (O2 intermittent + cooling Resolved), Parts Order Status (DO NOT ORDER lines), Service History row.
- 2026-07-06 (rizzo) — ANOMALY: 19:21 pre-drive scan showed 0 stored / 0 pending — all 6 codes from the 19:12 scan gone 9 minutes later. Jeff confirmed NO code clear was performed (not by him, not by O'Reilly). Readiness monitors stayed READY (except chronic EVAP), which independently rules out a Mode 04 clear — a clear resets monitors. So the ECU dropped the codes on its own across a key cycle, or one of the two reads is unreliable. Consistent with an INTERMITTENT fault (flaky shared heater supply — loose fuse/corroded connector making and breaking contact) rather than dead sensor elements. Drive test in progress with zero-code baseline: any code that re-sets as pending during this cycle is a live, active fault. Also: `--log --read-dtc` combined does NOT work — `--read-dtc` exits before the poll loop starts (cli.py returns after report save). Surface to Pierce: either chain the flags or warn on the combination. `--log` alone captures a start-of-session DTC snapshot, so use `--log --vehicle <slug>` for drive sessions.
- 2026-07-06 (rizzo) — Stationary code read 19:12 (`--read-dtc`, report `logs/2026-07-06-19-12-unknown-dtc.md` — VIN auto-read failed, filed as "unknown"). MIL OFF. 6 codes, ALL both stored and pending: P1152/P1153/P1154/P1155 (upstream LAF, both banks — drive-cycle watch point 2 of 3, still present) + P0160 (B2S2, known) + **P0140 (B1S2 downstream — NEW since 7/5)**. This confirms the O'Reilly counter scan from earlier today: both downstream O2 sensors bad. KEY INSIGHT: every O2/LAF sensor on the engine is now flagging, and the whole batch first appeared 2026-07-05 after a clean 7/1 scan — common-cause suspect is the shared O2 heater fuse/supply, not four independent sensor deaths. B1S1 producing valid wideband data when hot (7/5 drive) supports heater-failure-not-element-death. ACTION ORDER: (1) check heater fuse ($0), (2) if blown: replace, clear codes, re-scan after one warm drive before installing anything; (3) if good: order second Denso 234-4447 for B1S2 (same part both banks, fitment confirmed) and proceed with Tuesday's B2 install. Vehicle record updated (Active codes table, Parts Order Status, Known Issues, Diagnostic Records). Readiness monitors all READY except EVAP.
- 2026-07-05 (hawkeye) — Parts ordered: Denso 234-4447 (B2S2 downstream narrowband O2, P0160) ordered from RockAuto. ETA: Tuesday 2026-07-08 afternoon. Upstream LAF 234-9047 (B2S1) not yet ordered — monitoring P115x over next drive cycles first.
- 2026-07-05 (hawkeye) — O2 sensor identification complete. Bank 2 = driver's side (left), confirmed via SubaruOutback.org forum. Two sensors on driver's side need replacement: (1) B2S1 upstream LAF — Denso 234-9047 / OEM 22641AA25A — 4-wire wideband, ~$100–150; produced zero data in drive log, P1153/P1155 stored. (2) B2S2 downstream — Denso 234-4447 / OEM 22690AA840 — 4-wire narrowband, ~$50–80; P0160, physically dead. Both are same side — replace together. B1S1 upstream still reading data; monitor 3 drive cycles before deciding on replacement. Corrected prior documentation error: upstream sensors are 4-wire (not 5-wire). OEM NA catalog number is 22641AA25A; 22641AA160 is equivalent EU/JDM revision.
- 2026-07-05 (hawkeye) — Drive session complete (19:31–20:11, 874 rows, 70.8mph max). ROOT CAUSE OF OVERHEATING CONFIRMED: broken radiator cap + low coolant. Max coolant temp this session: 96°C (zero rows above 100°C vs. 114°C in prior sessions). LTFT normalized dramatically: B1 avg +1.76% (was +14.06%), B2 avg +0.10% (was +7.81%). Highway LTFT B1 -0.68%, B2 -1.37% — essentially stoichiometric. MIL did NOT fire; P030X not triggered. Wideband LAF B1 reading (avg 2.878V / +0.049mA at highway). Pre-drive DTC scan found 5 stored/pending codes: P1152/P1153/P1154/P1155 (LAF sensor faults, both banks) and P0160 (rear O2 Bank 2 dead). These were pre-existing. No new codes set during drive. Deliverable: [[2026-07-05-subaru-obd-drive-analysis]].
- 2026-07-05 (hawkeye) — Pre-drive DTC scan (19:25). MIL OFF. P030X misfire NOT present — self-cleared again (consistent with load-dependent pattern). NEW: 5 codes found, all O2/LAF sensor system. Stored AND pending: P1152 (LAF sensor range/perf B1), P1153 (LAF sensor range/perf B2), P1154 (LAF sensor malfunction B1), P1155 (LAF sensor malfunction B2), P0160 (rear O2 no activity B2 sensor 2). Both upstream wideband LAF sensors faulting on both banks — likely a major contributor to the chronic lean condition. Downstream rear O2 sensor Bank 2 completely dead. Freeze frame: RPM=0, coolant=26°C, speed=0, throttle=17.3% (cold/KOEO snapshot). Cold checks complete: oil normal black (HG not flagged); coolant LOW (topped off); radiator cap BROKEN (replaced). Proceeding to drive session.


- 2026-07-04 (rizzo) — Full SOP-020 five-phase analysis of 2026-07-01 17:34 driveway idle session (950 data rows, 25 min stationary, 17:35:02–18:00:23). File confirmed at `C:\Users\jeff\dev\obd-scanner\logs\2026-07-01-17-34-2008-subaru-outback-log.csv` (Team Inbox copy still present — needs manual delete). KEY FINDINGS: (1) MIL was OFF, dtc_count = 0 throughout entire session — the P-code that set the MIL during the 15:26 drive self-cleared between 15:52 and 17:35. Fault is load-dependent/intermittent: triggers under highway acceleration, absent at idle. This rules out static faults. (2) LTFT adapted downward: B1 15.62%→14.06%, B2 10.16%→7.81% in the first 90 seconds of the session. ECU post-drive recalibration, NOT a physical fix. Lean condition is active. (3) Fan kick-on at 17:45:56 (113°C) confirmed by data: engine load 26%→20%, MAF 4.24→3.56 g/s, RPM 715→696. Temperature still reached 114°C WITH fans running — cooling capacity fault confirmed. (4) STFT B1 at hot idle (113–114°C): sustained 3.91–5.47%, peak 5.47% at 17:48. Total B1 fuel correction at full hot idle: LTFT 14.06% + STFT ~4.5% avg = ~18.5%. (5) Diagnostic Records entry STFT value of "+6.25%" appears to be from the June 30 idle session, not this CSV; this session's actual peak is 5.47%. Vehicle file Diagnostic Sessions section updated with full SOP-020 breakdown. Rizzo journal entry written for durable insight on load-dependent MIL self-clearing.
- 2026-07-04 (rizzo) — Hardware investigation complete (Pierce's OBD bus topology work). ELM327 (Vlinker FS USB) cannot reach the ABS/VDC K-Line bus — this is a protocol mismatch, not a software fix: ELM327 runs K-Line at 10400 baud with KWP2000 framing; Subaru SSM2 requires 9600 baud with proprietary `0x80` header; no AT command override exists. C0071 and all other ABS/VDC chassis codes remain unreadable with current hardware. MINIMUM PURCHASE TO CLOSE: SSM2 K-Line USB cable (~$30–50, eBay/AliExpress). obd-scanner `--chassis-dtcs` flag is built, SSM2Protocol class implemented (ABS DTC request frame `80 15 F0 01 B8 3E`), merged to main — awaiting hardware. FreeSSM (free, Windows) is the alternative once cable acquired. Vehicle file (## OBD Scanner Hardware Notes section) and SOP-020 (Guardrails + Phase 1.5) updated with bus topology and acquisition path. NEXT STEP: Jeff to purchase SSM2 K-Line USB cable; connect with Vlinker FS USB; run `obd-scanner --chassis-dtcs` to confirm C0071 active/inactive status.
- 2026-07-01 (rizzo) — Drive session analysis complete. CSV: `C:\Users\jeff\dev\obd-scanner\logs\2026-07-01-15-26-2008-subaru-outback-log.csv` (992 rows, 15:27–15:52). KEY FINDINGS: (1) MIL confirmed ON at 15:32:15 during acceleration at 53 km/h — pending code reached confirmation threshold during this drive cycle; MIL stayed ON through session end. Actual DTC unknown — obd_scanner does not capture service $03 codes; Pierce fix pending. (2) CC disengagement confirmed same drive. Two simultaneous active CC cascade triggers: engine MIL + C0071 SAS/VDC (cannot isolate which or both without code read + chassis scan). (3) LTFT load-dependent pattern confirmed — textbook intake air leak: LTFT near-zero at highway load, snaps back to +15.62%/+10.16% within seconds of stopping (CSV lines 932–935). (4) Speed unit in obd_scanner is km/h not mph (bug). Vehicle file updated: Known Issues, Diagnostic Records, and new Diagnostic Sessions section added. Journal entry written: [[2026-07-01-subaru-obd-drive-analysis]]. SOP-020 created. NEXT STEPS: (1) dedicated code read scan for engine P-code identity (Innova or any OBD reader with mode $03), (2) chassis module scan to confirm C0071 active status in ABS/VDC module (Innova RepairSolutions2 all-system scan), (3) SAS replacement still pending.
- 2026-07-01 (rizzo) — WS-005 Step 3 complete; 25-min driveway idle log analyzed (CSV: Team Inbox/2026-07-01-17-34-2008-subaru-outback-log.csv); KEY CORRECTION: Jeff visually confirmed both cooling fans running throughout session — cooling fault is a capacity/flow problem, not fan relay. Coolant plateau at 114°C WITH fans running; dash at 3/4 toward red. STFT B1 escalating to +6.25% at hot idle (worse than prior session). Diagnostic action items updated. Deliverable: [[2026-07-01-2008-subaru-outback-obd-scan-idle-driveway]]. Vehicle file updated with corrected Known Issues, new Diagnostic Record, and new Service History entry.
- 2026-06-30 00:00 (hawkeye) — created; born from session health check + Vlinker diagnostic session revealing three active critical threads; obd-scanner project at `C:\Users\jeff\dev\obd-scanner\` confirmed connected to PKM via [[obd-scanner]] My Life project

## Outcome

_(filled when status flips to done — see SOP-012-close-task)_
