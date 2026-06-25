---
agent_id: hawkeye
session_id: 2026-06-24-scaffold-sync-cockpit-install
timestamp: 2026-06-24T00:00:00Z
type: close-session
linked_sops: [SOP-001-how-to-add-a-new-specialist]
linked_workstreams: [WS-003-install-an-expansion]
linked_guidelines: [GL-002-frontmatter-conventions, GL-003-design-system]
---

# Scaffold sync to v4.1.1 + Cockpit install

## Context

Jeff came in asking about the team roster and what came with scaffold v3.0 and v4.0. The folder was at v4.1.1 in version number but was missing the three bundled Expansions (App Developer Pack, Designer Pack, myPKA Cockpit) because the v2.2.0 → v4.1.1 upgrade script only touched framework files. Jeff had downloaded a fresh myPKA-main v4.1.1 copy, which provided the source for the missing packs. The session became a full sync and Cockpit install.

## What we did

- **Hawkeye** audited the team roster — confirmed 22 specialists active at session start; identified Felix, Vex, Vera, Iris, Charta, Pixel as missing (their Expansions never installed).
- **Hawkeye** reviewed `myPKA-main/` download (fresh v4.1.1); confirmed it contained all three missing Expansions and the correct agent folders under different base names (Larry/Nolan/Mack/Silas/Penn/Pax vs Jeff's MASH names).
- **Hawkeye** copied `Expansions/app-developer/`, `Expansions/designer-pack/`, `Expansions/mypka-cockpit/`, and `Expansions/.trusted-sources` from `myPKA-main` into the live `Expansions/` folder.
- **Potter (via WS-003)** merged App Developer Pack v1.0.1: copied Felix, Vex, Vera agent folders to `Team/`; added rows to `Team/agent-index.md` and root `AGENTS.md`.
- **Potter (via WS-003)** merged Designer Expansion Pack v1.1.0: copied Iris, Charta, Pixel agent folders to `Team/`; added rows to both indexes. GL-003 and SOPs 003–009 were already in place from the framework upgrade.
- **Hawkeye** created Claude Code subagent shims for all six new specialists: `.claude/agents/felix.md`, `vex.md`, `vera.md`, `iris.md`, `charta.md`, `pixel.md`.
- **Margaret** ran post-merge integrity check — PASS on all six agent contracts, SOPs 003–009, GL-003.
- **Hawkeye** updated `Expansions/INDEX.md` to record all three Expansions as installed.
- **Hawkeye** ran full v3.0/v4.0/v4.1.1 validation — all structural markers confirmed present. One gap found: `GL-002-frontmatter-conventions.md` was missing the v4.0 `model:` field (specialist contract field for LLM-agnostic tier aliases).
- **Margaret** added the `## Specialist contract fields` section with the `model:` field to `GL-002`, sourced from `myPKA-main` to match the canonical v4.1.1 text.
- **Klinger (Cockpit install via INSTALL.md contract)**:
  - Surfaced DISCLAIMER.md; Jeff consented with git as backup.
  - Installed PyYAML (`pip install --user pyyaml`) — `python3` not available on this Windows system; `python` used throughout.
  - Ran `sqlite-extension/install-extensions.py mypka.db --all` — bootstrapped `mypka.db` (1.6 MB) from scratch with core schema + all 7 cockpit extension tables.
  - Ran `npm run install:all` (502 packages) and `npm run build` (React app → `web/dist/`).
  - Generated Windows launchers: `start-cockpit.ps1` and `start-cockpit.bat` in cockpit root. Added `PYTHONIOENCODING=utf-8` workaround for Windows cp1252 Unicode issue in the regen script.
- **Hawkeye** confirmed folder fully at v4.1.1 — all structural, content, and Expansion markers green.
- **Hawkeye** explained LLM-agnostic portability: portable core (AGENTS.md, Team Knowledge, PKM, session triggers) works with any LLM; Claude Code adapter layer (`.claude/agents/`, `.claude/commands/`, `CLAUDE.md`) is Claude-specific but coexists with other adapters.
- **Hawkeye** explained `PKM/Documents/` structure: domain subfolders, `.md` records with frontmatter, `reference-docs/` for PDFs/scans. Confirmed Sea Ray survey already filed at `lake-erie/`; OBD-II scans belong in `automobiles/`.

## Decisions made

- **Decision:** Use `python` (not `python3`) for all Cockpit scripts on Jeff's Windows machine. `python3` is not mapped; `python` resolves to Python 3.14.5. The generated launcher detects this automatically via the `Test-Python` helper.
- **Decision:** The myPKA-main download folder is the canonical source for missing Expansion packs when the scaffold upgrade script doesn't carry them. Keep it available until confirmed no longer needed.
- **Decision:** Cockpit runs loopback-only (`127.0.0.1:4317`). LAN mode is off by default and requires a separate PIN-gated setup if ever needed.

## Insights

- The v2.2.0 → v4.1.1 scaffold upgrade script correctly handles framework files but intentionally leaves `Expansions/` untouched (user-state). Users upgrading from pre-3.0 need to manually copy the bundled Expansions from a fresh download — the upgrade alone is not sufficient for a full feature sync.
- Windows systems with Python 3 installed as `python` (not `python3`) need `PYTHONIOENCODING=utf-8` set before running any Cockpit Python scripts to avoid cp1252 charmap errors on Unicode output characters (e.g. `→`). This is baked into the generated launcher.
- GL-002 `model:` field was missing from the scaffold upgrade — likely because it was added mid-v4.0.0 cycle ("Silas is adding it in parallel"). Worth checking for similar parallel-added content if future upgrades skip minor content additions.

## Realignments

- _(none this session)_

## Open threads

- [ ] Jeff to launch the Cockpit: double-click `Expansions/mypka-cockpit/start-cockpit.bat`. First run opens `http://127.0.0.1:4317/`.
- [ ] `myPKA-main/` folder still in `My Drive` — can be deleted once Jeff confirms Cockpit is running correctly and no other content needs pulling.
- [ ] OBD-II scan records for vehicles not yet created — Jeff mentioned wanting these; Rizzo can create them when Jeff has scans to file.
- [ ] Team count now 28 specialists (added Felix, Vex, Vera, Iris, Charta, Pixel).

## Next steps

- Launch the Cockpit and confirm it opens correctly.
- Optionally delete `myPKA-main/` from My Drive once satisfied.
- File OBD-II scan records as they come up — route to Rizzo.

## Cross-links

- [[2026-06-23-hawkeye_scaffold-upgrade-v4.1.1]] — prior session that performed the framework-level v2.2.0 → v4.1.1 upgrade; this session completed what that upgrade left unfinished (Expansions + Cockpit).
