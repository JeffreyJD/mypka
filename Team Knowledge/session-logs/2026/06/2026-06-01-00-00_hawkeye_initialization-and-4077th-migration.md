---
agent_id: hawkeye
session_id: 2026-06-01-initialization-and-4077th-migration
timestamp: 2026-06-01T00:00:00Z
type: close-session
linked_sops:
  - SOP-001-how-to-add-a-new-specialist
linked_workstreams:
  - WS-002-import-external-knowledge-base
linked_guidelines:
  - GL-001-file-naming-conventions
  - GL-002-frontmatter-conventions
  - GL-004-task-resource-linking
---

# First session — full scaffold initialization, 4077th team build, PKA-Jeffrey migration, Documents structure

## Context

Jeff's first session in a fresh myPKA scaffold. Came in with "initialize yourself in this folder." Had a prior PKA at `../PKA-Jeffrey/` using the MASH 4077th theme with a richer team roster. Goal: get the new scaffold initialized, adopt the 4077th naming, migrate prior PKA content, and build a proper Documents structure for ~900 existing files in Google Drive.

## What we did

**Initialization:**
- Hawkeye created `CLAUDE.md` from `ADAPTER-PROMPT.md` template — identity overlay, session start checklist, architecture reference, tool-specific notes for Claude Code.
- Hawkeye ran personalization: wrote `PKM/.user.yaml` (`first_name: Jeff`), replaced 3 `{{USER_NAME}}` tokens across scaffold.

**Team renames — base 6 (MASH 4077th theme):**
- Hawkeye renamed all 6 base specialists across 40+ files + folder renames + shim renames: Larry → Hawkeye, Nolan → Potter, Pax → B.J., Penn → Radar, Mack → Klinger, Silas → Margaret.
- Fixed "Tom" references in existing agent shims → "Jeff."

**13 project agents hired from PKA-Jeffrey:**
- Hawkeye created `.claude/agents/<slug>.md` shims and `Team/<Name> - <Role>/AGENTS.md` contracts for all 13: Trapper (Homelab+Drones), Sydney (Branding), Mulcahy (Personal), Henry (Lake Erie), Tuttle (Genealogy), Igor (Food), Zale (Home Improvement), Frank (Rentals), Flagg (Gunsmithing), Rizzo (Automobiles), Painless (Car Detailing), Kellye (Travel), Winchester (Investing).
- All agents read `../PKA-Jeffrey/` knowledge files directly — no duplication.
- Updated `Team/agent-index.md` with all 13 new entries.

**PKM content seeded from PKA-Jeffrey:**
- Hawkeye created 4 Key Elements: `work.md`, `homelab.md`, `lake-erie.md`, `personal.md`.
- Hawkeye created 5 Topics: `oracle-erp-delivery.md`, `homelab-infrastructure.md`, `drone-builds.md`, `investing.md`, `personal-branding.md`.
- Radar created 1 Project: `sea-ray-spring-commissioning-2026.md`.
- Radar created 2 CRM entries: `danielle-adamowicz.md` (PKM/CRM/People/), `erie-yacht-club.md` (PKM/CRM/Organizations/).

**Documents structure built:**
- Hawkeye created `Documents/` + `PKM/Documents/` with 14 matching domain subfolders (lake-erie, homelab, branding, investing, gunsmithing, automobiles, drones, home-improvement, rentals, travel, personal, genealogy, food, car-detailing).
- 7 binary files copied from PKA-Jeffrey → `Documents/`: sea-ray survey PDF, homelab reference doc, 5 branding files (bios, resumes, template).
- 10 PKM stubs created in `PKM/Documents/` across lake-erie/, homelab/, branding/, travel/.
- `PKM/Documents/INDEX.md` updated with full domain structure and add-a-document workflow.

**PKA-Jeffrey leader-inbox items → Deliverables:**
- 7 pending items moved to `Deliverables/`: put-in scheduling, survey summary, Resolute GPS decision, Farragut motor selection, Lighthouse chassis upgrade, Perficient resume draft, Best-of-Class resume draft.

**Google Drive import scanned, paused:**
- Hawkeye inventoried ~900 files across 30 folders in `../` (My Drive root).
- Full mapping table built and saved to memory. Import paused pending Jeff's folder-by-folder review.

## Decisions made

- **Question:** Should files physically move into mypka or stay in place with stub pointers?
  **Decision:** Move files into mypka (`Documents/<domain>/`). Stubs point to `Documents/<domain>/filename`.

- **Question:** How to organize PKM/Documents/ at 100+ document scale?
  **Decision:** Domain subfolders (`PKM/Documents/lake-erie/`, `PKM/Documents/homelab/`, etc.) rather than flat folder with tags.

- **Question:** Should CHANGELOG.md, README.md, and other scaffold documentation files be updated when renaming team members?
  **Decision:** Yes — full replacement across all 40 files. Jeff's personal PKA, not a public scaffold.

- **Question:** Team naming convention going forward?
  **Decision:** MASH 4077th theme. Base 6 = Hawkeye, Potter, B.J., Radar, Klinger, Margaret. Project agents retain their old PKA-Jeffrey MASH names.

## Insights

- Old PKA-Jeffrey is a goldmine of knowledge files that agents should read directly rather than copy. Keeping it in place at `../PKA-Jeffrey/` and pointing agents there is cleaner than duplicating 60+ knowledge articles.
- `myPKA/` and `My PKA/` folders in Google Drive are older scaffold instances — not document sources. Do not import from them.
- `Master Notes/` folder contains 27 OneNote `.one` files spanning every domain (auto, boating, detailing, guns, crypto, home IT). Cannot be read as text — stubs only, with note to Jeff about OneNote export if he wants the content migrated.
- `Trading Bot/` in Google Drive is an active git repo — leave in place, do not import.

## Realignments

- Jeff accidentally rejected a tool call ("pressed 1") mid-session and immediately said "try again." Not a content realignment — execution continued as planned.

## Open threads

- [ ] **Resolute GPS decision** — Trapper's memo at `Deliverables/2026-04-17-resolute-gps-decision.md`. Jeff to approve Option A (GPS), Option B (no GPS), or Option C (defer).
- [ ] **Farragut motor/config decision** — Trapper's memo at `Deliverables/2026-04-17-farragut-motor-selection.md`. Jeff to approve quad vs. hex + motor selection.
- [ ] **Lighthouse rack depth + shopping list** — Trapper's memo at `Deliverables/2026-04-17-lighthouse-r730xd-chassis-upgrade.md`. Hard blocker: rack depth must be measured before rails can mount.
- [ ] **Perficient resume** — Sydney's draft at `Deliverables/2026-04-13-perficient-resume-draft.md`. 6 open questions from Sydney need Jeff's answers.
- [ ] **Best-of-Class resume** — Sydney's draft at `Deliverables/2026-04-13-best-of-class-resume-draft.md`. Post-2019 client work and Celonis cert status needed.
- [ ] **Sea Ray put-in scheduling** — `Deliverables/2026-04-13-put-in-scheduling.md`. Contact Danielle Adamowicz at EYC (dadamowicz@erieyachtclub.org / 814-453-4931 ext. 219) to schedule mid-May 2026 launch.
- [ ] **Google Drive bulk import** — ~900 files across 30 folders mapped and ready. Jeff to review folder mapping and give go-ahead per folder. Plan saved at `.claude/projects/.../memory/project_pending_import.md`.
- [ ] **Passport + travel credentials** — `PKM/Documents/travel/travel-documents.md` stub has placeholder values. Jeff to fill in actual passport expiry, TSA PreCheck, and Global Entry numbers.
- [ ] **Investing allocation targets** — Winchester's `master-strategy.md` has TBD for equity/crypto/cash split. Jeff to confirm total portfolio target allocations.
- [ ] **OPNsense R340 scope clarification** — Trapper flagged this as unresolved in the homelab handoff. What is the E-2236 CPU for?

## Next steps

- Jeff reviews `Deliverables/` folder — 7 items awaiting decisions/answers.
- Jeff reviews Google Drive import mapping and tells Hawkeye which folders to proceed with first.
- Once import folders are confirmed, Hawkeye + Margaret execute bulk copy + stub creation per domain.

## Cross-links

_(First session — no prior log.)_
