---
agent_id: hawkeye
session_id: environment-registry-created
timestamp: 2026-06-12T01:54:00Z
type: mid-session-insight
linked_sops: ["SOP-002-convert-mypka-to-sqlite"]
linked_workstreams: []
linked_guidelines: ["GL-002-frontmatter-conventions"]
---

# Environment Registry created — four new entity types, two locked decisions

## Context

Jeff's homelab and AI environment outgrew his head. He dropped a Nate Herk transcript into Team Inbox — the signal was Nate's practice of one Claude-readable registry for all VPS/agent infrastructure — and asked for the same. He also pointed at `C:\Users\jeff\dev\prophet-trader`, which carried a live VPS deployment documented only in its HANDOFF.md.

## What we did

- Hawkeye distilled the transcript pattern and clarified two decisions with Jeff.
- Margaret extended [[GL-002-frontmatter-conventions]] with four new entity schemas (Host, Service, Account, Software) and new core rule 7 (secrets are pointers), extended [[SOP-002-convert-mypka-to-sqlite]] with matching tables, and shipped four new templates.
- Margaret built `PKM/Environment/` ([[PKM/Environment/INDEX]]) seeded with 5 Hosts, 1 Service, 8 Accounts, 1 Software note from prophet-trader docs and the PKA-Jeffrey homelab handoff.
- Radar filed [[2026-06-11-environment-registry-kickoff]] in the Journal and removed the processed transcript from Team Inbox.
- Hawkeye updated the entity-folder counts (eight → twelve) in root AGENTS.md, CLAUDE.md, WS-002, and the Margaret/Klinger contracts.
- Evening pass (same session): Jeff confirmed Hetzner details from the live console (CPX31, $24.99 USD/mo, 3 TB traffic, native backups off); [[hetzner]] account note created. Tailscale login recorded (Google SSO jeffreyj2490@gmail.com); Radar processed the admin-console devices CSV from Team Inbox into the [[tailscale]] device table; Jeff disabled key expiry on the VPS the same evening.

## Decisions made

- **Question:** Where does the Environment Registry live?
  **Decision (Jeff, verbatim intent):** "must be located in the myPKA not the old locations." `PKM/Environment/` is the home; PKA-Jeffrey homelab files remain SSOT for build-tracker detail only, wikilinked from the Host notes.
- **Question:** Enable Hetzner native backups (+20%/mo) on the VPS?
  **Decision:** No — Backblaze B2 via rclone is the backup strategy. OS/config recovery path is the documented setup + hardening runbook in the prophet-trader repo.
- **Question:** How are credentials handled in registry files?
  **Decision:** Pointers only ("can we start with the pointer and move to hybrid if needed?"). Now GL-002 rule 7. Hybrid is the documented fallback and requires an explicit user decision recorded in a session log.

## Insights

- prophet-trader's HANDOFF.md was silently accumulating environment state (VPS IP, crontab, 25-var .env, five provider accounts). Per-project deployment footprints should land in `PKM/Environment/Services/` going forward, with the project repo staying SSOT for code and runbooks.
- The PowerShell `Get-Content`/`Set-Content` default-encoding round-trip mojibakes UTF-8 em-dashes on this machine. Use `[IO.File]::ReadAllText/WriteAllText` with explicit UTF-8 for bulk text replacements.

## Realignments

- Jeff considers PKA-Jeffrey "the old locations" — new structured tracking goes into myPKA, not there. Weight this when routing future domain work.

## Open threads

- [x] VPS provider confirmed by Jeff same session: **Hetzner CPX31** (Ashburn), **$24.99 USD/mo** (console displays €20.99 EUR — don't confuse the two), 3 TB traffic, native backups OFF, account jeff@davisglobe.com. [[hetzner]] account note created.
- [ ] Alpaca key scoping (read-only monitoring key vs VPS-only read+write key) still pending.
- [ ] Backblaze B2 restore has never been tested.
- [ ] Tailscale ACL policy unreviewed; phone tailnet key re-auths 2026-07-31.
- [ ] Homelab services get Service notes as they deploy on [[lighthouse]] / [[watchtower]].
- [x] Tailscale key expiry on the VPS — disabled by Jeff 2026-06-11; risk closed.

## Next steps

- First VPS-scheduled prophet-trader run fires 2026-06-12 09:30 ET — worth a check-in.
- As Jeff confirms account usernames/plans, fill the blank frontmatter fields flagged in each note's Open questions.

## Cross-links

- [[2026-06-01-00-00_hawkeye_initialization-and-4077th-migration]]
