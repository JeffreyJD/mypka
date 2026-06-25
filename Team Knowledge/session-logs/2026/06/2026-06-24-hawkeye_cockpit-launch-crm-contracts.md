---
agent_id: hawkeye
session_id: 2026-06-24-cockpit-launch-crm-contracts
timestamp: 2026-06-24T00:00:00Z
type: close-session
linked_sops: []
linked_workstreams: []
linked_guidelines: [GL-001-file-naming-conventions, GL-002-frontmatter-conventions]
linked_my_life: []
linked_deliverables: []
---

# Cockpit launch, CRM cleanup, and full team contract strengthening

## Context

Continuation of the Subaru triage session (see [[2026-06-24-hawkeye_subaru-outback-triage]]). After the Subaru work was logged, Jeff continued with housekeeping: launching the Cockpit for the first time, understanding the SQLite/markdown relationship, cleaning up the CRM, clarifying team member roles, and — most substantially — strengthening 13 thin specialist contracts that were missing routing tables, method sections, and scope boundaries.

## What we did

- **Hawkeye** explained the myPKA DB architecture: markdown is always the source of truth; `mypka.db` is a read-only mirror refreshed at every Cockpit launch. The team never reads or writes SQLite directly.
- **Hawkeye** launched the Cockpit via `Start-Process` (separate window so the Node server doesn't block the session). Cockpit confirmed working at `http://127.0.0.1:4317/`.
- **Hawkeye** listed CRM contacts — found 2 people (Danielle Adamowicz, Dr. Schmidt) and 2 organizations (Erie Yacht Club, Dr. Schmidt Clinic). Dr. Schmidt and Dr. Schmidt Clinic were example/placeholder entries.
- **Hawkeye** deleted `PKM/CRM/People/dr-schmidt.md` and `PKM/CRM/Organizations/dr-schmidt-clinic.md`. INDEX files were already clean — no further edits needed. CRM now: 1 person (Danielle Adamowicz), 1 organization (Erie Yacht Club).
- **Hawkeye** clarified Sparky vs. Vex: not duplicates — Sparky owns network infrastructure security (VLANs, firewall rules, UniFi, wireless); Vex owns application/software security (API audits, RLS, credentials, GDPR, pre-ship gates). Different layers, both needed.
- **Hawkeye** audited all team member AGENTS.md contracts by line count. Identified 13 thin contracts (26–54 lines) vs. well-specified contracts (70–220 lines). All 13 were custom personal-domain hires missing routing tables, method sections, deliverable structures, and scope boundaries.
- **Potter** strengthened 7 contracts that could be filled from existing context (no Jeff input needed): Rizzo, Winchester, Henry, Trapper, Mulcahy, Painless, Zale. All went from 27–54 lines to 120–140+ lines.
- **Potter** strengthened 6 contracts using available context + `[TO FILL: ...]` placeholders for Jeff's personal details (properties, firearms, equipment, loyalty programs, platforms, genealogy data): Frank, Kellye, Flagg, Igor, Sydney, Tuttle. All went from 26–39 lines to 128–207 lines.
- **Hawkeye** updated root `.gitignore` to exclude `mypka.db`, `mypka.db-shm`, `mypka.db-wal` (runtime-generated, not source).
- **Hawkeye** committed and pushed all session changes to GitHub.

## Decisions made

- **Decision:** `mypka.db` is excluded from git. It's a binary file regenerated from markdown on every Cockpit launch — committing it would add noise and no value. The markdown files are the backup.
- **Decision:** Sparky and Vex are confirmed as complementary, not redundant. No consolidation needed.
- **Decision:** The 6 contracts with `[TO FILL: ...]` placeholders ship as-is. Jeff will provide personal details (rental properties, firearms, equipment, etc.) in a future session to complete them. Routing tables and method sections are fully functional without the personal context.

## Insights

- Personal-domain specialists (Frank, Kellye, Flagg, Igor, Sydney, Tuttle, Rizzo, etc.) were all hired with minimal contracts — good enough to name the role but not enough to route reliably or produce consistent outputs. The pattern to watch: when hiring a personal-domain specialist, use the same contract template as core team members, not a shorthand version.
- The two-tier contract split (core team vs. personal domain) is a common scaffold debt pattern. Easy to detect via line count audit; easy to fix with Potter dispatch. Worth running this audit again after any batch of new hires.
- The Cockpit `Start-Process` launch pattern (separate window, non-blocking) is the correct approach for a long-running Node server within a Claude Code session. Direct PowerShell execution would block all further tool calls.
- `mypka.db` must be added to root `.gitignore` when the Cockpit is first installed — the Cockpit's own nested `.gitignore` only protects files within its own folder, not the scaffold-root DB.

## Realignments

- _(none this session)_

## Open threads

- [ ] **6 contract placeholders to fill:** Frank (rental properties), Kellye (loyalty programs/carriers), Flagg (firearms/builds), Igor (equipment: smoker/grill/flattop), Sydney (active platforms + brand goal), Tuttle (DNA platforms + family surnames + brick walls)
- [ ] **Task #1:** Replace SAS on 2008 Subaru Outback (C0071) — part not yet ordered
- [ ] **150k service items still open:** plug wires, brake fluid, coolant, accessory belt, trans/diff fluid
- [ ] **NHTSA recall check:** VIN 4S4BP86C284304726 at nhtsa.gov/recalls
- [ ] **myPKA-main folder:** still in My Drive — delete once confident nothing else is needed

## Next steps

- Order the SAS for the Subaru; return when part arrives.
- Fill in the 6 contract placeholders when ready — just mention the details and Hawkeye will update the contracts.
- Optionally delete myPKA-main from My Drive.

## Cross-links

- [[2026-06-24-hawkeye_subaru-outback-triage]] — immediately prior session: Subaru triage, scan 107/108 analysis, SAS diagnosis, Task #1 created
- [[2026-06-24-hawkeye_scaffold-sync-cockpit-install]] — earlier today: scaffold sync to v4.1.1, Cockpit install, 6 new specialists
