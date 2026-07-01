---
agent_id: hawkeye
session_id: 2026-07-01-agent-fix-obd-scanner-workstream
timestamp: 2026-07-01T10:17:00Z
type: end-of-session
linked_sops: ["SOP-010-create-task", "SOP-012-close-task", "SOP-015-write-session-log"]
linked_workstreams: ["WS-005-obd-scan-intake-and-fleet-triage"]
linked_guidelines: ["GL-001-file-naming-conventions"]
linked_tasks: ["tsk-2026-06-30-001-subaru-ez30d-active-diagnostic", "tsk-2026-07-01-001-obd-scanner-ci"]
linked_journal_entries: []
---

# Session Log — 2026-07-01 | Agent Fix + OBD Scanner Workstream

## Context

Session continued from 2026-06-30 with three approved writes pending (Rizzo engine fix, Subaru diagnostic task, vehicle service history). The session then pivoted to investigate why 13 custom-hired team specialists were not appearing as dispatchable subagent_types in Claude Code, and expanded into designing the OBD scanner intake workflow to connect Jeff's two scanning tools to the PKM vehicle records.

## What we did

- **Hawkeye** — completed the three carried-forward writes: fixed Rizzo AGENTS.md engine reference (EJ253 → EZ30D H6 + EJ quirks → EZ30D quirks); created tsk-2026-06-30-001 linking obd-scanner project to PKM Subaru record; confirmed vehicle file already had all four scan sessions populated.
- **Hawkeye** — diagnosed the 13-agent dispatch gap: read SOP-001 (onboarding process is correct and was followed), checked all 27 shims (structurally identical), ran byte-level inspection — found UTF-8 BOM (`EF BB BF`) on exactly 13 files created outside Claude Code. Claude Code's YAML parser requires `---` at byte offset 0; BOM silently blocks frontmatter parse.
- **Hawkeye** — stripped BOM from all 13 affected shims (flagg, frank, henry, igor, kellye, mulcahy, painless, rizzo, sydney, trapper, tuttle, winchester, zale) using PowerShell `System.IO.File::WriteAllText` with `new UTF8Encoding(false)`. All 27 agents confirmed dispatching on next session load.
- **Hawkeye** — authored WS-005 (OBD Scan Intake and Fleet Triage), updated Workstreams/INDEX.md, linked WS-005 to tsk-2026-06-30-001.
- **Pierce (subagent)** — implemented VIN auto-detection (OBD Service 09, `force=True` for ELM327 compatibility), `FleetRegistry` class, `fleet.yaml` manifest (Subaru registered), dynamic vehicle-slug output filenames, `--vehicle` override flag, 28 passing tests; merged to main on obd-scanner repo.
- **Hawkeye** — extended WS-005 to cover Innova RepairSolutions2 PDF path (Team Inbox drop → Hawkeye reads VIN from PDF → fleet lookup → route to Rizzo), making the workstream scanner-agnostic from Step 3 onward.
- **Hawkeye** — created tsk-2026-07-01-001 (obd-scanner CI, Pierce, priority 3).
- **Hawkeye** — committed 74 files to myPKA main and pushed to JeffreyJD/mypka.

## Decisions made

- **VIN auto-read over `--vehicle` flag as primary** — Jeff confirmed auto-read is the right long-term approach; `--vehicle` ships as fallback for when VIN read fails (some vehicles don't advertise Mode 09).
- **WS-005 covers both scanners** — Innova PDF and obd-scanner CLI are equal first-class intake paths; they converge at Rizzo triage (Step 3). Scanner-agnostic from that point.
- **fleet.yaml lives in obd-scanner repo, not myPKA** — Pierce owns and maintains it; new vehicle additions require Pierce to update the manifest alongside the myPKA vehicle file.
- **BOM rule is permanent** — all agent shims must be written by Claude Code's Write tool (clean UTF-8). Manual edits in Windows Notepad are prohibited for shim files.
- **obd-scanner CI deferred** — filed as priority-3 task for Pierce; not blocking anything today.

## Insights

- **UTF-8 BOM silently kills Claude Code agent registration.** No error is surfaced — the agent simply doesn't appear in available subagent_types. Diagnosis requires byte-level inspection (`xxd` or PowerShell byte array read). The BOM (`EF BB BF`) precedes the `---` delimiter, making the entire YAML frontmatter invisible to the parser. Root fix: always write shim files via Claude Code's Write tool.
- **Agent dispatch failures are not always a capacity limit.** Initial hypothesis (14-agent cap) was incorrect — Tom Solid runs 40+ agents. The real cause was encoding, not quantity. Validate at the encoding layer first before assuming system limits.
- **WS-005 intake design principle: detect at the earliest possible moment.** VIN auto-read at scan time (obd-scanner) is better than requiring Jeff to remember a `--vehicle` flag. For Innova PDFs, VIN is in the PDF content — Hawkeye extracts it, no naming convention required from Jeff.

## Realignments

- Initial analysis attributed the 13-agent gap to a Claude Code slot limit (~14 custom agents). Jeff corrected this: Tom Solid's vault runs 40+ agents with no limit. Investigation redirected to shim content → encoding → BOM confirmed as root cause.

## Open threads

- **tsk-2026-06-30-001** (Rizzo, priority 1): Subaru EZ30D active diagnostic — cooling fans (no-drive gate), P030X capture, LTFT B1 +15.62% lean investigation. Must not drive until cooling fans confirmed.
- **tsk-2026-07-01-001** (Pierce, priority 3): obd-scanner GitHub Actions CI.
- **obd-scanner dev branch** has one commit (`.gitignore`) ahead of main — merge when ready.
- **PIDs 0x24/0x25/0x34** (wideband LAF) still not added to obd_scanner logger — still in tsk-2026-06-30-001 checklist under Pierce action item.
- **6 specialist contracts with [TO FILL] placeholders** remain: Frank, Kellye, Flagg, Igor, Sydney, Tuttle. Their shims are clean and dispatching; contracts need content.
- **Rizzo subagent dispatch** — now confirmed working after BOM fix. No further investigation needed.

## Next steps

- Jeff: cooling fan check on Subaru before next drive (relay swap test, visual confirm at 95°C).
- Pierce: merge obd-scanner dev → main (`.gitignore`); add PIDs 0x24/0x25/0x34 to logger.
- Jeff: run a scan with the new CLI and drop output in Team Inbox to test WS-005 end-to-end.
- Potter: fill [TO FILL] placeholders in 6 specialist contracts when Jeff is ready.

## Cross-links

- Prior session: [[2026-06-30]] (scaffold health check, Rizzo hire, scan PDF intake)
