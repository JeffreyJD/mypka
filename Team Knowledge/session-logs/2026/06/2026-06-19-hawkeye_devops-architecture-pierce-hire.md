---
agent_id: hawkeye
session_id: devops-architecture-pierce-hire-2026-06-19
timestamp: 2026-06-19T23:59:00Z
type: close-session
linked_sops: []
linked_workstreams: []
linked_guidelines:
  - GL-002-frontmatter-conventions
---

# DevOps architecture + Pierce hire

## Context

Second session of the day (continuation after the bug-fix / passport session closed earlier). Jeff opened by asking about the DevOps architecture for myPKA, the dev folder, and the VPS — specifically whether the setup was correct and how it would scale to multiple future projects. Three action items were identified (#1 myPKA GitHub, #2 prophet-trader dev branch, #3 auto-deploy). All three completed this session. Session closed with the hire of Pierce as Senior Developer.

## What we did

### #2 — dev branch for prophet-trader

- Created `dev` branch locally and pushed to `JeffreyJD/prophet-trader` on GitHub.
- Established permanent branch strategy: `dev` for all active work, `main` = production-only, merge when ready to ship.

### #3 — GitHub Actions auto-deploy for prophet-trader

- Generated SSH key pair `~/.ssh/prophet_trader_deploy` (ed25519, comment: `github-actions-deploy@prophet-trader`) on [[jeff-laptop]].
- Public key added to `/home/trader/.ssh/authorized_keys` on [[davisglobe-vps-ash-1]].
- Created `.github/workflows/deploy.yml` — triggers on push to `main`, SSHs to VPS, runs `git pull origin main`.
- Troubleshooting path: three failed runs before green.
  - Run 1: `gh` CLI not available — pivoted to GitHub web UI for secrets + base64 key encoding.
  - Run 2: `appleboy/ssh-action` Docker container couldn't read key from `/tmp` (host `/tmp` not mounted in container).
  - Run 3: `RUNNER_TEMP` path correct but Docker ran as different user → `chmod 600` denied.
  - Run 4 (green): replaced `appleboy/ssh-action` with direct `ssh` call in a `run:` step — no Docker, no permission boundary.
- GitHub Actions secrets configured on `prophet-trader` repo: `VPS_DEPLOY_KEY` (base64 ed25519 private key), `VPS_HOST`, `VPS_USER`, `VPS_PROJECT_PATH`.
- `dev` branch synced back to `main` after all CI fixes landed.

### #1 — myPKA private GitHub repo

- Jeff confirmed Google Drive backup is sufficient primary backup; GitHub adds version control and change history.
- Updated `.gitignore` to exclude personal data: `PKM/`, `Documents/`, `Deliverables/`, `Team Inbox/`.
- Ran `git rm -r --cached` to untrack 141 previously-committed personal files. Files remain on disk and Google Drive.
- Created private repo `JeffreyJD/mypka` on GitHub.
- Pushed `main` and `dev` branches. Remote confirmed clean.
- Session logs explicitly kept in git (user decision) — all other PKM personal data excluded.

### Environment registry updates

- Created `PKM/Environment/Accounts/github.md` — documents JeffreyJD account, both repos, auto-deploy SSH key, GitHub Actions secrets, branch strategy.
- Updated `PKM/Environment/Services/prophet-trader.md` — added `github_repo`, `deploy_trigger`, `github` linked account, and branch strategy section.
- Note: these files are in `PKM/` (gitignored from GitHub) — they live local + Google Drive only, which is correct.

### Pierce hire — Senior Developer

- Gap identified: Hawkeye was handling all application-layer technical work directly (Python debugging, CI/CD, VPS operations). This is not Hawkeye's role.
- Routed to Potter to draft the contract. B.J. research pass included.
- Slug `trapper` was already taken (Trapper John — Homelab & Drone Engineer from a prior session). Potter assigned slug `pierce`.
- Contract: `Team/Pierce - Senior Developer/AGENTS.md`
- Shim: `.claude/agents/pierce.md`
- AGENTS.md and agent-index.md updated (8 specialists now on roster).

## Decisions made

- **Auto-deploy approach**: direct `ssh` in a `run:` step, not a Docker-based action. Simpler, no permission boundary between runner and container.
- **myPKA GitHub scope**: team infrastructure only (`AGENTS.md`, SOPs, workstreams, guidelines, session-logs, `.claude/`). Personal PKM stays local + Drive.
- **Session logs on GitHub**: explicitly versioned (user preference). Everything else in `PKM/` excluded.
- **Pierce slug**: `pierce` not `trapper` — `trapper` was already assigned to the Homelab & Drone Engineer.
- **Hawkeye scope clarification**: Hawkeye orchestrates; Pierce owns the development and DevOps layer. Future code and CI/CD work routes to Pierce.

## Permanent workflow (both repos)

```
dev  →  (work here)  →  push to dev
main →  (production) →  merge from dev when ready to ship
push to main → GitHub Actions → VPS git pull (prophet-trader only)
```

## Open threads

### Prophet Trader
- [ ] **Monday June 22 09:30 ET** — first live fractional order placement with market open. Pierce to verify fills land correctly in Alpaca paper account and journal.
- [ ] Alpaca API key scoping (carried)
- [ ] B2 restore test (carried)
- [ ] Tailscale ACL review (carried)
- [ ] Phase 2c (crypto expansion) gated on 7 clean equity days

### Network
- [ ] US-24 TFTP recovery — Jeff needs USB-to-Ethernet adapter
- [ ] Switch port VLAN assignment after adoption
- [ ] USG firmware update (4.4.57 → current)
- [ ] AP renaming, DHCP reservations, band steering evaluation

### Vehicles
- [ ] Subaru: idle relearn, ignition coil install, scan 103 (cruise control light)

### Florida property
- [ ] Florida trip June 17 debrief still missing — no listings or notes in vault

### myPKA general
- [ ] My Drive bulk import (~900 files) — still on hold per Jeff's direction

## Cross-links

- [[2026-06-19-hawkeye_prophet-trader-bugs-passport-sync]] — prior session (same day)
- [[prophet-trader]] — service infrastructure note
- [[github]] — new account entry created this session
- [[Team/Pierce - Senior Developer/AGENTS]] — hired this session
