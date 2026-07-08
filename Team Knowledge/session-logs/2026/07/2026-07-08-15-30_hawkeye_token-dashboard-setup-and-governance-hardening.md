---
agent_id: hawkeye
session_id: 2026-07-08-token-dashboard-setup-and-governance-hardening
timestamp: 2026-07-08T19:30:00Z
type: end-of-session
linked_sops: ["SOP-004-vex-security-audit", "SOP-012-close-task", "SOP-013-rebuild-task-index"]
linked_workstreams: ["WS-003-install-an-expansion"]
linked_guidelines: ["GL-007-verify-before-acting-on-a-finding", "GL-008-read-registry-before-creating-new-state", "GL-009-localize-expansion-role-names"]
linked_tasks: ["tsk-2026-07-08-001-rotate-telegram-bot-token"]
linked_journal_entries: ["2026-07-08-verify-before-assuming-a-finding-is-unresolved"]
---

# Session log — 2026-07-08 — Token Dashboard setup, Prophet Trader status check, and a governance-hardening pass

## Context

Jeff opened by asking to set up `nateherkai/token-dashboard`. What started as a routine tool install turned into a full-vault governance audit after two separate near-misses (a wrong local-folder choice, then a stale-finding false alarm) prompted the question "how does this team keep missing stuff?"

## What we did

- **Pierce (voice)** — set up Token Dashboard: cloned, ran `scan`/`dashboard`, confirmed it reads Claude Code's own JSONL transcripts locally (no telemetry). Found and documented a real environment bug: port 8080 fails on this machine (`WinError 10013`); pinned to 8765. Built and verified `launch-dashboard.bat`. Registered the tool in `PKM/Environment/Software/token-dashboard.md`.
- **Hawkeye** — initially cloned into a newly-created `~/projects/` instead of the pre-existing `~/dev/` (which already held `prophet-trader`, documented in `jeff-laptop.md`). Jeff caught it; moved the project via `robocopy` (worked around a Windows file-handle lock that blocked a plain move), made `~/dev` the documented standing convention.
- **Hawkeye** — explained Groq's existing role as the `/watch` plugin's Whisper fallback (already configured, no action needed).
- **Pierce (voice)** — live status check of Prophet Trader on `davisglobe-vps-ash-1`: July 7 routine clean, July 3 holiday auto-skip correct, backups current through B2, disk healthy. Caught the service registry's stale commit reference (`84e1780` vs. actual `4f2021c`).
- **Vex (voice)** — investigated the commit gap, proved a real finding: `TELEGRAM_BOT_TOKEN` leaked into `cron.log` in plaintext 14 times (2026-06-12–2026-07-01, pre-dating a logging fix) and into the B2 backup. Wrote an audit report, opened a priority-1 remediation task.
- **Hawkeye** — Jeff said he'd already rotated the token; verified via SHA-256 hash comparison (current `.env` value vs. leaked log value — no raw secrets ever printed) that they differ. Closed the task same-day, archived the deliverable, corrected the registry note.
- **Jeff** raised the systemic question: "how does this team keep missing stuff... disconnect between memory, sessions, task updates and documentation."
- **Hawkeye** — diagnosed three concrete failure modes from the session itself and wrote two Guidelines: [[GL-007-verify-before-acting-on-a-finding]] (a historical finding proves past, not current, state) and [[GL-008-read-registry-before-creating-new-state]] (read the Host/Service/Account note before creating anything new). Wired both into `SOP-004`, and — on Jeff's approval — into Pierce's and Vex's `AGENTS.md` contracts.
- **Jeff** noticed Vex's contract still named a generic orchestrator "Larry" instead of Hawkeye — asked to fix it and scan everywhere for the same issue.
- **Hawkeye** — full-vault scan found the same un-localized generic roster (`Larry/Mack/Silas/Pax/Nolan/Penn/Lex`) in **six** specialist contracts (Charta, Felix, Iris, Pixel, Vera, Vex — both hired via 2026-06-24 Expansion installs), their **seven** SOPs (003–009), one core Workstream (`WS-004`), two core Guidelines (`GL-002`, `GL-005`), and two `.claude/` files (`vex.md` shim, `update-scaffold.md` command). Fixed all of them: `Larry→Hawkeye`, `Mack→Klinger`, `Silas→Margaret`, `Pax→B.J.`, `Nolan→Potter`, `Penn→Radar`. `Lex` (legal specialist — no host-team equivalent) rewritten everywhere as a named gap routed to Hawkeye/Potter, not left as a phantom name.
- **Hawkeye** — fixed the root cause, not just the instances: `WS-003-install-an-expansion` never had a localization step. Added one to Potter's merge procedure (§3.1, §3.2) and a validation check to Margaret's post-merge integrity gate (§4). Wrote [[GL-009-localize-expansion-role-names]] to make it permanent, cross-linked from WS-003.
- **Hawkeye (Librarian pass, this close)** — rebuilt `Team Knowledge/tasks/INDEX.md`, which had **never been generated** (still showed placeholder zeros from scaffold init) — found during this pass, not before. Verified every wikilink created or touched this session resolves; confirmed no orphans; no SSOT violations found.

## Decisions made

- **`~/dev` is the standing convention for all local project checkouts on jeff-laptop**, documented in the Host note and in [[GL-008-read-registry-before-creating-new-state]].
- **Expansion source folders (`Expansions/<slug>/`) stay generic/un-localized by design** — they're portable install templates for future myPKA installs, potentially with a different roster. Localization applies only to the copies that land in `Team/` and `Team Knowledge/`.
- **No placeholder hire for "Lex."** Legal-interpretation gaps route functionally to Hawkeye → Potter (hire via [[SOP-001-how-to-add-a-new-specialist]]) rather than pointing at a name that was never actually hired.

## Insights

- **A finding sourced from historical evidence (logs, backups, git history) proves past exposure, not current exposure.** Verify via hash/fingerprint comparison before recommending action — this is [[GL-007-verify-before-acting-on-a-finding]], born from opening a remediation task for a credential Jeff had already rotated.
- **A registry note documenting a convention is only useful if it gets read before the decision, not after.** `jeff-laptop.md` already said `~/dev` was the convention; the miss was not reading it, not a missing fact — this is [[GL-008-read-registry-before-creating-new-state]].
- **Expansion-authored content ships with the pack author's own generic team roster baked in as literal text, not `{{}}` placeholders** — so it silently survives a merge that only copies files without a substitution pass. This drifted undetected for two weeks across six contracts before Jeff spotted it by name-recognition ("who's Larry?"). This is [[GL-009-localize-expansion-role-names]].
- **Meta-insight on Jeff's original question:** "the team keeps missing stuff" wasn't one problem — it was three distinct, previously-undocumented failure modes (staleness with no invalidation mechanism, out-of-band changes that leave no trace unless verified, and a narrow rule — Pierce's VPS-registry-read habit — that never generalized to every agent/situation). Naming them separately is what made each one fixable with a concrete, cross-linked Guideline instead of a vague "be more careful."

## Realignments

- Jeff: "why did you choose jeff/projects folder and not the dev folder" — corrected a live placement error; the folder was moved and the convention documented rather than left as a one-off fix.
- Jeff: "but we already did this i changed api key is this after I changed" — corrected an unnecessary task before it consumed Jeff's time; directly produced GL-007.
- Jeff: "how does this team keep missing stuff? ... disconnect between memory, sessions, task updates and documentation" — reframed the second half of the session from feature work into governance hardening. This is the session's load-bearing realignment.
- Jeff: "fix and scan everywhere for this same issue" — turned a single-file fix (Vex's contract) into a full-vault audit that surfaced four additional un-localized files nobody had flagged.

## Open threads

- Three pre-existing open tasks untouched this session: [[tsk-2026-06-30-001-subaru-ez30d-active-diagnostic]] (priority 1), [[tsk-2026-07-06-002-sea-ray-windlass-upgrade]] (priority 2), [[tsk-2026-07-01-001-obd-scanner-ci]] (priority 3).
- Optional, low-priority: scrub the 14 dead-token lines from Prophet Trader's `cron.log` for hygiene (inert since the token's already rotated — not urgent).
- The new WS-003 localization step (§3.1, §3.2) and Margaret's integrity-check addition (§4) are unexercised — the next Expansion install is the first live test of the hardened procedure.

## Next steps

1. Next Expansion install: confirm the new GL-009 localization step actually fires and Margaret's check actually catches a miss if one occurs.
2. No forced action on the three open tasks — pick up next session per priority if Jeff wants to.
3. Optional `cron.log` cleanup whenever convenient.

## Cross-links

- Prior session: [[2026-07-07-21-52_hawkeye_watch-first-use-nate-herk-claude-video]]
- Same-session earlier log: [[2026-07-08-06-30_hawkeye_prophet-trader-status-check-token-leak-found]]
- Journal: [[2026-07-08-verify-before-assuming-a-finding-is-unresolved]]
