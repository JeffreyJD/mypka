# WS-005 - OBD Scan Intake and Fleet Triage

- **Type:** Workstream — a multi-agent composition.
- **Owners:** Pierce (obd-scanner tooling + fleet detection), Rizzo (triage and vehicle record updates), Hawkeye (routing)
- **References:** [[Team/Pierce - Senior Developer/AGENTS]], [[Team/Rizzo - Automobiles Agent/AGENTS]], [[SOP-010-create-task]], [[SOP-012-close-task]], [[SOP-017-read-own-journal]], [[GL-001-file-naming-conventions]]
- **Trigger:** Jeff drops any scan output into `Team Inbox/`, or signals that a scan session is complete.

## Purpose

Every scan run on a fleet vehicle feeds directly back into that vehicle's PKM record. Rizzo triages every session — even a clean scan is a data point. Issues that reach the Schedule or Stop-driving threshold automatically open a task. No scan disappears into a folder without a verdict.

Scans on non-fleet vehicles are stored for reference only; no PKM update is triggered.

## Supported scanners

This Workstream handles output from two tools. The intake path differs by tool; everything from Step 3 onward is identical.

| Scanner | Output format | Fleet detection method |
|---|---|---|
| Innova RepairSolutions2 (hardware) | PDF report | Hawkeye reads VIN from PDF content; looks up fleet registry |
| obd-scanner Python CLI (Vlinker FS USB) | CSV log + DTC markdown report | VIN auto-read at scan time; slug embedded in filename |

## Fleet registry

The authoritative fleet manifest lives in the obd-scanner project at `obd_scanner/fleet.yaml`. It maps VINs to myPKA vehicle slugs. Pierce maintains this file. When a vehicle is added to or removed from `PKM/Documents/automobiles/vehicles/`, Pierce also updates `fleet.yaml`.

## Inputs

- **Innova PDF** — dropped by Jeff into `Team Inbox/` as-is (filename from the app is fine).
- **obd-scanner output** — CSV log and/or DTC markdown report dropped into `Team Inbox/`, or Jeff signals completion verbally; filename is pre-tagged with vehicle slug by the CLI.
- **Verbal signal** — Jeff says "I ran a scan on [vehicle]" with or without a file path.

## Choreography

### Step 1a — Innova PDF intake (Hawkeye)

Jeff drops the Innova PDF into `Team Inbox/`. Hawkeye detects it as an OBD scan report and:

1. Reads the PDF to extract the VIN (present in the report header on every Innova all-system scan).
2. Looks up the VIN in `obd_scanner/fleet.yaml`.
3. **Fleet match** → rename the file to the standard convention and move to `PKM/Documents/automobiles/scans/YYYY/YYYY-MM-DD-<vehicle-slug>-innova-scan-<NNN>.pdf`, then route to Rizzo (Step 3) with: vehicle slug + PDF path.
4. **No fleet match** → move to `PKM/Documents/automobiles/scans/YYYY/<vin>-innova-scan.pdf`; no further action unless Jeff requests triage.

### Step 1b — obd-scanner CLI intake (Pierce's tooling)

The obd-scanner CLI reads the vehicle VIN via OBD-II Service 09 at session start and looks it up in `obd_scanner/fleet.yaml`.

- **Fleet match:** output files are named `YYYY-MM-DD-HH-MM-<vehicle-slug>-log.csv` and `YYYY-MM-DD-HH-MM-<vehicle-slug>-dtc.md`. CLI prints the matched vehicle name.
- **No match:** output files use the raw VIN as identifier. CLI prints "not in fleet registry."
- **VIN read fails:** Jeff passes `--vehicle <slug>` as an override.

Jeff drops the tagged output into `Team Inbox/` or signals completion. Hawkeye reads the slug from the filename and routes to Rizzo (Step 3).

### Step 2 — Hawkeye confirms routing

Before handing to Rizzo, Hawkeye confirms:
- Which vehicle (slug + display name).
- Which scan files are in scope (paths).
- Whether this is a new scan or a supplement to an existing open task.

If an open task already exists for this vehicle (check `Team Knowledge/tasks/open/` and `in-progress/`), Hawkeye hands Rizzo both the new scan and the existing task ID so Rizzo can update rather than create a duplicate.

### Step 3 — Rizzo triage

Rizzo receives: vehicle slug + path(s) to scan output file(s) + open task ID if one exists.

1. Read [[SOP-017-read-own-journal]] — check for prior sessions on this vehicle.
2. Read the vehicle file at `PKM/Documents/automobiles/vehicles/<vehicle-slug>.md` — understand current status, active issues, and prior scan context before interpreting anything.
3. Parse the scan output (PDF content or CSV/DTC markdown):
   - Code-by-code verdict: **Monitor**, **Schedule**, or **Stop driving**.
   - PID trend analysis if CSV log is present: fuel trims, coolant temp, MAF, O2 sensors.
   - Innova PDFs: interpret all active and history codes across all modules (ENGINE, ABS, SRS, TPMS, KEYLESS, etc.).
4. Update the vehicle file:
   - Add a row to **Diagnostic Records** (date, tool, key findings).
   - Update **Known Issues / Watch Items** — close resolved items, open new ones with severity.
   - Update **Current Status** odometer if a new reading is in the scan.
5. Task handling:
   - If an open task exists: add findings as an update entry; escalate priority if warranted.
   - If no open task and any code or PID reaches **Schedule** or **Stop driving**: create a task via [[SOP-010-create-task]]; link this WS and the deliverable.
   - Clean (all Monitor or no codes): no new task, but note the clean scan in the vehicle file.
6. Produce a deliverable: `Deliverables/YYYY-MM-DD-<vehicle-slug>-obd-scan-<slug>.md`.

### Step 4 — Hawkeye closes the loop

Hawkeye reports to Jeff:
- Vehicle confirmed (slug + display name).
- Scanner used (Innova / obd-scanner CLI).
- Verdict summary: N codes — X Monitor / Y Schedule / Z Stop driving.
- Task created or updated (ID + title), if applicable.
- Deliverable path.

## File naming and storage

| Artifact | Pattern |
|---|---|
| Innova PDF (archived) | `PKM/Documents/automobiles/scans/YYYY/YYYY-MM-DD-<vehicle-slug>-innova-scan-<NNN>.pdf` |
| obd-scanner CSV log | `YYYY-MM-DD-HH-MM-<vehicle-slug>-log.csv` (written by CLI) |
| obd-scanner DTC report | `YYYY-MM-DD-HH-MM-<vehicle-slug>-dtc.md` (written by CLI) |
| Rizzo triage deliverable | `Deliverables/YYYY-MM-DD-<vehicle-slug>-obd-scan-<slug>.md` |
| Non-fleet scan archive | `PKM/Documents/automobiles/scans/YYYY/<vin>-<scanner>-scan.pdf` |

The `<NNN>` in Innova filenames is the scan sequence number shown in the Innova app report (e.g., scan-101, scan-107). Preserve it — it matches the physical device log.

## What this Workstream does not do

- Does not process non-fleet vehicle scans beyond archiving them.
- Does not auto-clear OBD codes — Rizzo issues a verdict; Jeff decides whether to clear.
- Does not replace shop-level diagnostic — Rizzo escalates to a shop recommendation when the scope warrants it.
- Does not maintain the fleet manifest (`fleet.yaml`) — that is Pierce's responsibility.
- Does not parse Innova PDFs for vehicles not in the fleet — those go to archive only.
