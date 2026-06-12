---
agent_id: hawkeye
session_id: close-session-environment-registry
timestamp: 2026-06-12T02:35:00Z
type: close-session
linked_sops: ["SOP-002-convert-mypka-to-sqlite"]
linked_workstreams: ["WS-002-import-external-knowledge-base"]
linked_guidelines: ["GL-002-frontmatter-conventions"]
---

# Close session — Environment Registry built, seeded, and committed

## Context

Jeff's homelab/AI environment had outgrown his head. A Nate Herk transcript in Team Inbox supplied the pattern (one Claude-readable infrastructure registry); the prophet-trader project supplied the urgent seed data (a live Hetzner VPS whose details existed only in a HANDOFF file). One session took the idea to a committed, fully-seeded registry.

## What we did

Full build narrative is in [[2026-06-11-21-54_hawkeye_environment-registry-created]] — summary:

- Margaret added four entity types (Host, Service, Account, Software) via the GL-002 extension path: schemas, SQLite contract in SOP-002, four templates, entity count eight → twelve everywhere it is stated.
- Margaret built and seeded `PKM/Environment/` — 17 files: INDEX + 5 hosts + 1 service + 9 accounts + 1 software.
- Radar processed two Team Inbox drops (Nate Herk transcript, Tailscale devices CSV) into the Journal and registry, clearing the inbox per convention.
- Jeff confirmed live facts from consoles as we went: Hetzner CPX31 / $24.99 USD/mo / jeff@davisglobe.com; Tailscale Google SSO jeffreyj2490@gmail.com; and **disabled Tailscale key expiry on the VPS in-session**, closing the silent-drop-off risk dated 2026-12-08.
- Hawkeye committed the work: `f8b0181` — 31 files, +1,275 lines.

## Decisions made

(Recorded in detail in the mid-session log; restated for the record.)

- **Registry location:** myPKA (`PKM/Environment/`), not PKA-Jeffrey — Jeff: "must be located in the myPKA not the old locations."
- **Secrets policy:** pointers only (GL-002 rule 7); hybrid is the explicit-decision fallback.
- **Hetzner native backups:** OFF by decision; Backblaze B2 rclone is the backup strategy.

## Insights

- Per-project deployment footprints (like prophet-trader's HANDOFF.md) silently accumulate environment state; the registry is now their home, with project repos remaining SSOT for code and runbooks.
- Console pastes beat web research for account facts: the web said $24.99, the console showed €20.99, and only Jeff knew both were right (currency display). Record what the user confirms; mark inferences as inferences.
- Windows PowerShell 5.1 gotchas captured for the team: default-encoding round-trips mojibake UTF-8 (use `[IO.File]` with explicit UTF-8), and embedded double quotes break `git commit -m` (use `-F <file>`).

## Realignments

- PKA-Jeffrey is "the old locations" — new structured tracking belongs in myPKA. Carried in team memory.

## Open threads

- [ ] Alpaca key scoping: read-only monitoring key vs VPS-only read+write key (prophet-trader hardening item).
- [ ] Backblaze B2 restore test — backup is unverified until restored once.
- [ ] Tailscale ACL policy review; phone tailnet key re-auths 2026-07-31.
- [ ] Homelab Service notes created as services actually deploy on [[lighthouse]] / [[watchtower]].
- [ ] The large pre-existing uncommitted migration changes (~180 files: specialist renames, README/SOP edits) remain in the working tree — separate piece of work, untouched tonight.
- [ ] Pending bulk document import (~900 files) still awaiting Jeff's review — unchanged from prior sessions.

## Next steps

- First VPS-scheduled prophet-trader run fires **2026-06-12 09:30 ET**; healthchecks.io is the dead-man's switch. Worth a check-in next session.
- As Jeff confirms remaining account usernames/plans, fill blank frontmatter fields flagged per-note.

## Cross-links

- [[2026-06-11-21-54_hawkeye_environment-registry-created]] — same-session build log.
- [[2026-06-01-00-00_hawkeye_initialization-and-4077th-migration]] — prior session.
