---
agent_id: hawkeye
session_id: 2026-07-22-email-assistant-architecture-and-track-a-build
timestamp: 2026-07-23T00:59:52Z
type: end-of-session
linked_sops:
  - SOP-023-triage-inbox
  - SOP-010-create-task
linked_workstreams: []
linked_guidelines:
  - GL-018-inbox-triage-and-classification
  - GL-002-frontmatter-conventions
  - GL-001-file-naming-conventions
  - GL-010-commit-and-push-before-session-close
linked_tasks:
  - tsk-2026-07-21-001-millville-insurance-claim-followup
  - tsk-2026-07-21-002-portugal-spain-wedding-trip-followup
linked_journal_entries: []
---

# Email/alert assistant: architecture designed, GL-018 hardened, Track A built end-to-end

## Context

Session picked up mid-stream from a prior inbox-triage install (GL-018/SOP-023 already shipped). Jeff wanted to move from "one-time dry-run cleanup" to "a true standing AI assistant with a 360-degree view" across all his inboxes — and, once that vision was clear, to actually build the first real piece of it (Google-native email/Contacts access for the two Gmail-hosted accounts).

## What we did

- **Radar** ran the first live (non-dry-run) `gmail-personal` backlog pass: filed ~12 PKM entries (new vehicle files for the Silverado and Grand Highlander, a new finance statements log, a new CRM entry for Ali Kochno/Florida realtor), left ~300 junk messages untouched pending a Gmail-modify tool grant.
- **Radar** wrote four hard rules into [[GL-018-inbox-triage-and-classification]] / [[SOP-023-triage-inbox]] this session: a three-tier priority-override system (Contact match / Direct human correspondence / category fallthrough), compound dispositions for Tier 1/2 messages (FILE + reply-draft + task-draft can all fire from one message, bundled together), a shipment/part-to-task cross-check, and an invoice-to-repair/upgrade-tracking cross-check.
- **Henry** built a structured Parts & Invoice Ledger inside the boat's `maintenance-log.md`, correcting two mislabeled items and a wrong autopilot model along the way (it's a Raymarine EV200, not an AutoHelm ST6002).
- **B.J.** produced two research briefs: a cross-domain alert-architecture comparison, then an independently-commissioned Gmail/Contacts-automation architecture review that challenged and corrected Klinger's original OAuth-client plan (right mechanism, wrong scope name; ruled out domain-wide delegation given davisglobe.com's planned migration off Google Workspace).
- **Klinger** scoped, then built, Track A end-to-end: Google Cloud project, OAuth consent screen, `taylorwilsdon/google_workspace_mcp` pinned to v1.22.0, `.mcp.json` registered with two named instances (`jeffreyj2490@gmail.com`, `davisglobe@gmail.com`), both independently verified to have zero send-capable tools exposed. Diagnosed and root-caused four consecutive OAuth consent failures (simple 10-minute state-token expiry from relay/back-and-forth delay, not a bug).
- **Vex** ran a two-pass security review of `google_workspace_mcp` (initial CONDITIONAL, then a scope-expansion re-review after discovering the `drafts` permission tier is cumulative) — final verdict **APPROVE with binding conditions**, chiefly that the shim's permission tier must never exceed `gmail:drafts`.
- **Keystone** authored and revised `docs/design/ADR-001-unified-alert-notification-architecture.md` through five rounds of correction as decisions landed live in conversation — most significantly reversing the execution model from Cloud Routines to Desktop Scheduled Tasks after Klinger proved Cloud Routines can't get live vault access.
- **Bastion** confirmed the Claude Desktop app was already installed on jeff-laptop (no install needed) and split the previously-conflated `claude-code`/`claude-desktop` Software entries.
- **Hawkeye** drove the actual OAuth consent click-throughs via browser automation for both accounts (explicitly authorized by Jeff per-instance), after a first-attempt collision from two simultaneous drivers (Hawkeye + Jeff) on the same tab.

## Decisions made

- **Question:** Should the standing assistant's v1 execution model be a VPS script + n8n, or something else?
  **Decision:** Runs "within the team" — Claude Code Desktop Scheduled Tasks, not externalized infrastructure. Jeff's explicit framing: "for initial launch let's run through the team... down the road we have to change." VPS/n8n is a named, deliberate v2+ migration path, not abandoned.

- **Question:** Which of the four email addresses need which kind of automation?
  **Decision:** Two tracks. Track A (`jeffreyj2490@gmail.com`, `davisglobe@gmail.com` — durably Google) uses the Google-native MCP server. Track B (`jeff@`, `admin@davisglobe.com` — migrating off Google Workspace, destination undecided) will use a short, auditable stdlib IMAP/SMTP script, not a third-party package or n8n. See [[user_email_infrastructure]].

- **Question:** How should send-vs-draft approval work?
  **Decision:** Both "approve as draft" and "approve and send" are supported per-message, chosen at approval time — not one global mode.

- **Question:** What's the alert-channel structure for the broader (non-email) relay?
  **Decision:** Four channels — Trading (Prophet Trader only), Infrastructure (VPS + homelab + network + backups combined), Home Automation, Email — not five-by-domain as first drafted.

- **Question:** Is the `taylorwilsdon/google_workspace_mcp` package safe to adopt given it requires four Gmail scopes (not just compose) to reach the drafts tier?
  **Decision:** Yes, APPROVE with binding conditions (Vex) — `send` stays fully excluded regardless, and the shim's exposed tool list was independently verified to have zero send-capable tools.

- **Question (mid-session correction):** Perficient was listed as a planned third inbox alongside gmail-personal/davisglobe.
  **Resolution:** Struck entirely — Jeff confirmed it has nothing to do with this effort; carried over incorrectly from a stray prior session-log note. Fixed in [[GL-018-inbox-triage-and-classification]] and in the ADR.

## Insights

- **OAuth state-token TTLs are a real, easy-to-miss failure mode in any multi-agent relay.** Four consecutive `davisglobe@gmail.com` consent failures all traced to simple elapsed time past a hardcoded 10-minute window — every theory tested first (duplicate-hit race, missing parameters, Google flagging automation) was disproven with direct evidence before the real cause (accumulated relay delay) was found. Worth remembering for any future OAuth-driven build: generate and complete the consent click-through back-to-back, don't let it sit in a conversation queue.
- **A subagent correctly refusing to trust a relayed "the user approved this" claim is a feature, not friction** — Klinger flagged this twice during the OAuth build and was right to; the fix was Hawkeye confirming the direct quote was real, not overriding the caution. See [[feedback_oauth_consent_execution]].
- **Package permission tiers can be cumulative in ways that widen scope beyond what a name suggests** — `gmail:drafts` sounds narrow but actually requests four scopes together (`readonly`+`labels`+`modify`+`compose`) in this package's version. Always read the actual tier-resolution code, not just the tier name, before scoping an OAuth request.
- **Cross-referencing into existing structures (tasks, tracking logs) rather than filing new content in isolation is the throughline Jeff cares about most** for this whole system — validated explicitly mid-session. See [[feedback_email_cross_reference_depth]].

## Realignments

- Jeff corrected the "5 channels by domain" framing to "4 channels by group" (Trading separate from Infrastructure, which combines VPS/homelab/network/backups) — captured directly in the ADR.
- Jeff corrected an assumption that OAuth consent should be user-only; explicitly authorized Hawkeye to drive it, twice, per-instance — see [[feedback_oauth_consent_execution]].
- A misclick during the Radar shim tool grant was clarified as accidental ("I clicked on wrong button") — reran successfully.

## Open threads

- [ ] **Track B build — Jeff's explicit next-session priority ("ASAP").** Stdlib IMAP/SMTP script for `jeff@`/`admin@davisglobe.com`, reading Track A's Contacts cache, its own Desktop Scheduled Task. Not started.
- [ ] Grant the new Gmail/Contacts MCP tools to Radar's shim (`.claude/agents/radar.md`) — Track A is built and verified but not yet wired to Radar; needs Hawkeye's explicit go-ahead next session (session ended before this was actioned).
- [ ] Clear the ~300 junk messages still sitting in `gmail-personal` — blocked on the same Radar shim tool grant above.
- [ ] Confirm whether Healthchecks.io's trading-cadence checks belong in the Trading or Infrastructure alert channel (Keystone defaulted to Trading, unconfirmed by Jeff).
- [ ] `inbox_id`-to-four-address mapping still not formally finalized in GL-018.
- [ ] The alert relay itself (Decision 2 of ADR-001) — four channels designed, nothing built.
- [ ] Home automation (YoLink/Ring/Nanit) still has zero Environment registry footprint.
- [ ] `davisglobe.com`'s eventual hosting destination is still undecided — Track B was deliberately built without pre-committing to a portable-contacts layer for this reason (Microsoft 365 has no CardDAV).

## Next steps

- Next session: build Track B first, per Jeff's explicit instruction.
- Then: grant Radar's shim the Track A tools and run a live `gmail-personal` pass to clear the junk backlog.
- ADR-001 is stable and fully reflects this session's decisions but has not received Jeff's final, formal whole-document sign-off — worth a quick confirmation pass before more is built on top of it.

## Cross-links

- [[2026-07-21-01-35_hawkeye_inbox-triage-install-gl018-sop023]] — the prior session that shipped GL-018/SOP-023 for the first time.
