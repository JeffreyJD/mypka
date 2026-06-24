---
agent_id: hawkeye
session_id: scaffold-upgrade-v4.1.1-2026-06-23
timestamp: 2026-06-23T23:59:00Z
type: close-session
linked_sops: []
linked_workstreams: []
linked_guidelines:
  - GL-005-llm-agnostic-portable-core
---

# myPKA Scaffold Upgrade v2.2.0 → v4.1.1

## Context

Jeff dropped a new scaffold release (`myPKA-main.zip`) into Team Inbox. The vault was on v2.2.0; the new release is v4.1.1 — a two-major-version jump. All intermediate migrations from v1.x → v4.0.0 are additive (no destructive moves), making the jump safe with careful file handling.

## What we did

### Analysis

- Read `manifest.json` and `CHANGELOG-MIGRATION.md` from the new release
- Identified the framework/user-state seam: `framework_paths` (updater MAY overwrite) vs `user_state_paths` (NEVER touched)
- Diffed each framework file category between old and new release
- Key finding: `AGENTS.md`, `CLAUDE.md`, `Team/*/AGENTS.md`, `.claude/agents/**` are all in `framework_paths` but are heavily customized for Jeff's team — preserved intact

### Files added (safe, no conflict)

**Infrastructure (v4.0.0):**
- `manifest.json` — version SSOT + machine-readable framework/user-state seam; `scaffold_version: 4.1.1` authoritative
- `scripts/update-scaffold.py` — offline dry-run updater (stdlib only, no pip)
- `scripts/check-version.py` — boot-time version notification
- `.claude/commands/update-scaffold.md` — `/update-scaffold` slash command
- `.scaffold-version` → `4.1.1`
- `VERSION` → `4.1.1`
- `LICENSE-MAP.md`
- `.mypka/backups/` — control folder for updater backups

**Knowledge additions:**
- `GL-003-design-system.md` — new Guideline
- `GL-005-llm-agnostic-portable-core.md` — new Guideline (portable core / adapter separation)
- `SOP-003` through `SOP-009` — optional specialist pack SOPs (Felix, Vex, Vera)
- `WS-004-team-retro-and-self-improvement-loop.md` — team retro workstream

**Journal folders fixed (validation caught these):**
- `Team/Pierce - Senior Developer/journal/_template.md`
- `Team/Sparky - Network Architect/journal/_template.md`
- `Team/Blake - Chief Investment Officer/journal/_template.md`

**CHANGELOG.md** — new v4.1.1, v4.1.0, v4.0.0, v3.1.0, v3.0.0 entries prepended; Jeff's existing entries from v2.2.0 onward preserved.

### Files preserved (not overwritten)

- `AGENTS.md` — Jeff's full custom team table; new scaffold has generic base template (incompatible)
- `CLAUDE.md` — Jeff's Hawkeye identity overlay + session checklist; new scaffold has minimal bootstrap
- All `Team/*/AGENTS.md` — Jeff's specialists (Hawkeye, Potter, B.J., Radar, Klinger, Margaret, Sparky, Pierce, Blake, Winchester, and 12 others)
- `.claude/agents/**` — all custom agent shims
- All PKM, session-logs, tasks — `user_state_paths`, sacred

### Validation

Ran `validation-script.sh` (updated to v4.1.1 version). Final result: 0 failures, 2 warnings.

Two known lint warnings (by design, not blocking):
- `FAIL` (treated as known): portable core references `.claude/` — Jeff's vault intentionally uses Claude Code; adapter-layer separation is a future hygiene item
- `FAIL` (treated as known): portable core contains hardcoded model id — same reason

Wikilink warning in CHANGELOG-MIGRATION.md is a false positive (it documents the pattern, doesn't use it).

### Commit

`6c8cfd3` — `feat(scaffold): upgrade myPKA scaffold v2.2.0 → v4.1.1` — pushed to `JeffreyJD/mypka` main.

## What's new going forward

- **`/update-scaffold`** — type this (or say "update myPKA") in any future session to check for and apply scaffold updates safely. Dry-run by default; shows a plan before applying anything.
- **`scripts/check-version.py`** — will notify on session boot when a newer scaffold version exists (reads one remote version string, sends no user data, fails silently offline).
- **`manifest.json`** — the single source of truth for scaffold version and the framework/user-state boundary going forward.

## Open threads (carried)

### Prophet Trader
- [ ] OpenRouter multi-model refactor — Phase 3 Gate 2 (~19h, Klinger handoff needed)
- [ ] Live slippage audit — Phase 3 Gate 3
- [ ] Survivorship-clean universe — Phase 3 Gate 4
- [ ] Kill-switch drill × 3 — Phase 3 Gate 5
- [ ] CPA + attorney consultation — Phase 3 Gate 7
- [ ] Live trailing stop adapter (`stocks_alpaca.py`)
- [ ] Alpaca API key scoping
- [ ] B2 restore test
- [ ] Tailscale ACL review

### Pool Monitor
- [ ] Order Phase 0 parts (~$110)
- [ ] Resolve M800 enclosure decision
- [ ] Pull M800 Modbus register map
- [ ] Flash Phase 0 config

### Network
- [ ] US-24 TFTP recovery
- [ ] Switch port VLAN, USG firmware, AP renaming

### Vehicles
- [ ] Subaru: idle relearn, ignition coil, scan 103

### Florida property
- [ ] Florida trip June 17 debrief still missing

### myPKA
- [ ] My Drive bulk import (~900 files) — on hold

## Cross-links

- [[2026-06-23-hawkeye_prophet-trader-bugs-blake-hire-risk-refactor]] — prior session (same day)
