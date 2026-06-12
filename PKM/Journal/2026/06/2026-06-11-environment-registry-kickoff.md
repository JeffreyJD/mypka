---
date: 2026-06-11
tags: [journal, environment, homelab, ai, prophet-trader]
---

# Environment Registry Kickoff

Jeff dropped a Nate Herk video transcript into the Team Inbox — mostly about the Hermes agent, but the part that mattered was Nate's practice of keeping one Claude Code project as a registry for all his VPS agents: per-server folders with IPs, deployment shape (root vs. Docker), env-var inventory, and security notes, so the assistant always has the full infrastructure picture. Jeff's environment (homelab, AI work, VPS, containers, accounts) has outgrown his head, and he wants the same discipline here.

Two decisions locked today:

1. **The Environment Registry lives in myPKA** — `PKM/Environment/` with Hosts, Services, Accounts, and Software as four new entity types — not in the old PKA-Jeffrey locations.
2. **Secrets are pointers, never values** (now [[GL-002-frontmatter-conventions]] rule 7). Start pointers-only; move to hybrid later only if needed, by explicit decision.

Seeded from two sources: the prophet-trader project at `C:\Users\jeff\dev\prophet-trader` (live VPS [[davisglobe-vps-ash-1]], the [[prophet-trader]] service, and seven provider accounts) and the homelab handoff docs ([[lighthouse]], [[watchtower]], [[opnsense-r340]]). Registry hub: [[PKM/Environment/INDEX]].

The transcript was processed and removed from Team Inbox per the inbox convention.

## Evening additions — Hetzner and Tailscale details

Jeff filled in the registry gaps live: the VPS is a **Hetzner CPX31** ($24.99 USD/mo — console displays €20.99 EUR), account jeff@davisglobe.com, native backups off by decision ([[backblaze-b2]] is the strategy). Tailscale login confirmed as Google SSO **jeffreyj2490@gmail.com**, and a devices CSV export from the admin console filled the device table on [[tailscale]] — three devices, key expiry enabled on all. The key-expiry flag on [[davisglobe-vps-ash-1]] was acted on the same evening — Jeff disabled it in the admin console, so the VPS stays on the tailnet indefinitely. The phone still re-auths 2026-07-31 (low stakes, it just prompts).
