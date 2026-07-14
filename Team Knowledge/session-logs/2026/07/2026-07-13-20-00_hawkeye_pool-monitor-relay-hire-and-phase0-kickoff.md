---
agent_id: hawkeye
session_id: 2026-07-13-pool-monitor-relay-hire-and-phase0-kickoff
timestamp: 2026-07-14T00:00:35Z
type: close-session
linked_sops:
  - SOP-001-how-to-add-a-new-specialist
linked_workstreams: []
linked_guidelines:
  - GL-010-commit-and-push-before-session-close
linked_tasks: []
linked_journal_entries: []
---

# Pool Monitor: Relay hire and Phase 0 kickoff

## Context

Jeff came in ready to start physical work on the Pool Monitor & Automation project (scoped and imported back on 2026-06-19) — specifically flashing the ESP32-S3 for Phase 0. First question: did the team have the right specialist for ESP32/ESPHome/Home Assistant work. It didn't.

## What we did

- Hawkeye reviewed the existing pool monitor project files (`PKM/My Life/Projects/pool-monitor-automation.md`, `PKM/Documents/pool/`) and the team roster (`Team/agent-index.md`), confirmed no current specialist owns ESPHome/ESP32/Home Assistant work — Trapper owns compute-layer/Proxmox/drone firmware, Sparky owns network/VLAN, neither covers the device/application layer.
- Clarified with Jeff: build/flash happens on this laptop; Home Assistant needs to run on a second laptop as a sandbox because Lighthouse (the intended permanent Proxmox host) isn't ready yet.
- **Potter** ran SOP-001 and hired **Relay**, Smart Home & IoT Engineer — self-executed B.J.'s Hire Research Protocol (brief at [[2026-07-13-smart-home-iot-engineer-hire-research]]) since no parallel-dispatch tool was available inside that agent run. Drafted the wiki contract (`Team/Relay - Smart Home & IoT Engineer/AGENTS.md`), the Claude Code shim (`.claude/agents/relay.md`, with `Bash` access for toolchain installs), and the `Team/agent-index.md` row.
- Hawkeye caught and fixed a file-extension error in Relay's contract (source docs listed as `.md` when three are actually `.yaml`) before presenting the draft to Jeff.
- Jeff approved the hire as-is.
- First dispatch attempt to Relay failed — `Agent type 'relay' not found`. Root cause: the Claude Code subagent registry loads at session start, so a shim written mid-session isn't dispatchable until restart. Documented as a durable insight (see below) since this will recur on every future hire.
- Updated `PKM/My Life/Projects/pool-monitor-automation.md` — status section now reflects parts in hand, Relay hired, and the sandbox-then-migrate HA hosting decision; next-steps list rewritten to match current phase.
- Wrote two new memory files: `project_pool_monitor.md` (project status + team ownership) and `feedback_new_shim_requires_restart.md` (the restart requirement), both pointed to from `MEMORY.md`.

## Decisions made

- **Question:** Who owns ESPHome/ESP32 firmware and Home Assistant configuration going forward?
  **Decision:** Hired Relay (Smart Home & IoT Engineer) as a durable specialist, not scoped to the pool project alone. Trapper keeps Proxmox/host provisioning; Sparky keeps network/VLAN; Relay owns the device and application layer sitting on top of both.

- **Question:** Where does Home Assistant run given Lighthouse isn't ready?
  **Decision:** Stand up Home Assistant on a secondary laptop as a sandbox now, built explicitly so it can migrate to Lighthouse later (entity IDs, config structure chosen with migration in mind, migration path documented as soon as the sandbox exists) — not a throwaway setup that gets rebuilt from scratch.

## Insights

- **New subagent shims require a full session restart before they're dispatchable.** Writing `.claude/agents/<slug>.md` mid-session doesn't make it available to the `Agent` tool in that same session — `/clear` doesn't fix it either, only exit-and-reopen does. This should be stated to the user as a standard closing step of every future SOP-001 hire, not discovered fresh each time.

## Realignments

- _(none this session — no pushback on Hawkeye's reasoning, only clarifying questions from Jeff that sharpened scope)_

## Open threads

- [ ] Restart Claude Code session so Relay becomes dispatchable, then resume Phase 0 with Relay: toolchain recon (Python/pip, ESPHome install state, CH343 driver), then wire the DS18B20 and flash `pool-monitor-phase0.yaml`.
- [ ] Stand up sandbox Home Assistant on the secondary laptop once Relay is live; document the Lighthouse migration plan immediately per Relay's contract.
- [ ] Resolve M800 enclosure decision (Hammond panel-mount vs Fibox ARCA-JIC) — carried from prior session, still open.
- [ ] Pull M800 Modbus register map from the manual; correct placeholder addresses in `pool-monitor.yaml` — carried from prior session, still open.
- [ ] Kitchen wall panel (Lenovo Tab M10 Plus) — designed, not purchased — carried from prior session, still open.

## Next steps

- On next session start: confirm Relay dispatches successfully, then have Relay do toolchain reconnaissance on this laptop before any flash attempt.

## Cross-links

- [[2026-06-19-hawkeye_pool-monitor-intake]] — original project intake session
- [[2026-07-13-18-04_hawkeye_watch-jesse-trading-and-coupler-finance-automation]] — prior session earlier the same day
