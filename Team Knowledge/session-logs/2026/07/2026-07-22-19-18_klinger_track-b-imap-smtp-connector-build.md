---
agent_id: klinger
session_id: 2026-07-22-track-b-imap-smtp-connector-build
timestamp: 2026-07-23T01:18:06Z
type: end-of-session
linked_sops:
  - SOP-023-triage-inbox
linked_workstreams: []
linked_guidelines:
  - GL-018-inbox-triage-and-classification
  - GL-013-credential-backup-hygiene-on-operational-hosts
  - GL-002-frontmatter-conventions
linked_tasks: []
linked_journal_entries: []
---

# Track B built: stdlib IMAP/SMTP connector for jeff@/admin@davisglobe.com

## Context

Per [[ADR-001-unified-alert-notification-architecture|ADR-001]] Decision 1, sequencing item 5: Track B of the standing inbox-triage system needs its own execution mechanism, deliberately not OAuth/MCP (unlike Track A's `google_workspace_mcp`), because `davisglobe.com` email hosting is actively planned to migrate off Google Workspace to an undecided destination. Jeff ruled directly: a short, auditable, stdlib-only Python script (`imaplib`/`smtplib`), no third-party IMAP/SMTP package, no n8n.

## What I built

- `scripts/track-b-imap-smtp-connector.py` — stdlib-only Python script exposing `fetch`, `approve_as_draft`, `approve_and_send`, plus a `test-connection` health-check subcommand, both as an importable module and a CLI (`argparse`, subcommands, JSON in/out on stdout, structured JSON logs to stderr). Retries transient network errors with exponential backoff; never retries auth failures; never retries past the point `smtp.send_message()` is actually invoked (avoids a double-send on an ambiguous post-send failure). `fetch` uses `BODY.PEEK[]` (never marks a message read) and skips message-ids already in a state file's `processed_message_ids` set, but does not itself advance state — that stays SOP-023 Phase 4 / Radar's job, including the dry-run rule that state must not advance on a dry-run.
- `scripts/track-b-inboxes.json` — non-secret connection config (host/port/mailbox names per `inbox_id`; only the *name* of each account's password env var, never the value). Two provisional entries seeded: `davisglobe-jeff` and `davisglobe-admin`, both pointed at today's actual host (`imap.gmail.com` / `smtp.gmail.com`, since davisglobe.com hasn't migrated yet) — when it does migrate, only this file's host/port fields change, never the script.
- `PKM/Environment/Accounts/davisglobe-jeff-mailbox.md` and `davisglobe-admin-mailbox.md` — account registrations, `secrets_ref` pointing at an env var name and an external `.env` path (`C:\Users\jeff\.mypka-track-b\track-b.env`, outside this repo), never a value. Added to `PKM/Environment/INDEX.md`.
- Credential loading: reads the password from the real OS environment first, falls back to a tiny stdlib `KEY=VALUE` parser reading the external env file (no `python-dotenv` — third-party). No real credential was requested or created this pass, per scope.

## What I verified (no real credentials involved)

- `python -m py_compile` clean; `track-b-inboxes.json` valid JSON.
- CLI error paths tested end-to-end: missing credential env var, missing fetch window on a first run (config error, not a credentials error — reordered the code so window resolution is checked before the password lookup), unknown `inbox_id`, missing `--message-file`/`--message-json`.
- **Real network test against Google's actual endpoints** with a placeholder password: `imap.gmail.com:993` and `smtp.gmail.com:587` both reached successfully and correctly rejected the fake credential (`AUTHENTICATIONFAILED` / `535 5.7.8 BadCredentials`), proving reachability, TLS/STARTTLS negotiation, and the auth-failure-is-not-retried path all work — without ever touching a real mailbox.
- A deliberately-invalid host confirmed DNS failures surface immediately (not retried — `socket.gaierror` isn't in the transient-error set), so a misconfigured `track-b-inboxes.json` entry fails fast rather than retrying for ~7 seconds against a dead host.
- Draft/send message-payload parsing (`to`/`subject`/`body`/`in_reply_to`) confirmed structurally correct before hitting the credentials boundary.

## Two open design questions I flagged rather than silently resolving

1. **Contacts-cache hand-off** (Track B has no Google Contacts access, so GL-018 Tier-1 priority tiering needs a local snapshot instead). **My recommendation:** Radar's existing Track A SOP-023 runs write a read-only JSON snapshot (`.mypka/cache/contacts-snapshot.json`, shape `{generated_at, source, contacts: [{name, email}]}`) as a side effect, since that session already holds the `contacts:readonly` grant — Track B/Radar then just does a plain JSON read, no new credential surface. I did **not** build a separate standalone fetcher for this, because that would mean minting a second Google-credentialed process for data Track A's session already has live access to — worse, not better, separation of concerns. This needs a small SOP-023 amendment (Radar/Hawkeye's territory, not mine) to actually wire the write-side; I only documented the recommendation and the target path/schema.
2. **`inbox_id` mapping** — left exactly as ADR-001 instructs: not resolved by me. The script and config take `inbox_id` as a required parameter throughout; `davisglobe-jeff`/`davisglobe-admin` in `track-b-inboxes.json` are explicitly commented as provisional placeholders for whoever (Hawkeye/Klinger, per ADR-001 item 10) resolves the four-address/two-track mapping.

## What Jeff needs to do next (physical-world, can't be done by me)

For each address (`jeff@davisglobe.com`, `admin@davisglobe.com`), in the Google Workspace admin console / that account's own security settings:
1. Confirm 2-Step Verification is enabled.
2. Confirm app-password generation is allowed for that account (Workspace Admin console: Security > Authentication > 2-step verification).
3. Generate the app password at https://myaccount.google.com/apppasswords while signed in as that address.
4. Create `C:\Users\jeff\.mypka-track-b\track-b.env` (outside this repo) with `TRACK_B_DAVISGLOBE_JEFF_APP_PASSWORD=<value>` and `TRACK_B_DAVISGLOBE_ADMIN_APP_PASSWORD=<value>`, then set owner-only permissions (`icacls` — mirrors the outside-repo, owner-only convention already used for Track A's `client_secret.json`).

## Ready for Vex

Per ADR-001 item 5, this script needs Vex's lighter read-through (correctness/security skim, not a full package-trust audit — it's stdlib-only) before any real credential is wired in. Not yet requested this session — flagging it as the next gate, not something I can self-clear.

## Handoff

- **Radar/Hawkeye** should pick up the SOP-023 amendment for the contacts-cache side-effect write, and the `inbox_id` mapping decision (ADR-001 item 10).
- **Vex** should read through `scripts/track-b-imap-smtp-connector.py` next.
- **Jeff** generates the two app passwords per the steps above — nothing else in this build is blocked on anything but that.

## References

- [[ADR-001-unified-alert-notification-architecture]]
- [[GL-018-inbox-triage-and-classification]]
- [[SOP-023-triage-inbox]]
- [[davisglobe-jeff-mailbox]]
- [[davisglobe-admin-mailbox]]
- [[google-workspace-mcp-davisglobe]] (Track A's sibling, contrast in mechanism)
- [[2026-07-22-23-00_hawkeye_email-assistant-architecture-and-track-a-build|prior session: Track A built, GL-018 hardened]]

## Update — 2026-07-22, later same day: Vex's blocking findings applied

Vex reviewed this script (the "Ready for Vex" ask above) and returned two blocking findings plus two deferred nice-to-haves. Jeff approved fixing the two blocking ones this pass; deferred 3/4. Both are now fixed in `scripts/track-b-imap-smtp-connector.py` — see [[2026-07-22-19-45_klinger_track-b-connector-security-fixes|the fix session log]] for the full before/after PoC record. Short version: TLS verification was implicit-off by default (`ssl._create_stdlib_context()` gives `CERT_NONE`/no hostname check when `imaplib`/`smtplib` aren't handed an explicit context) — now explicit via `ssl.create_default_context()` at all three connect sites. CRLF/header-injection guard was previously relying on the interpreter's own version-gated `Policy.verify_generated_headers` — now an explicit check in `_build_email()` independent of interpreter version. The "Ready for Vex" line above and "what I verified" section reflect the *pre-fix* state of the script; treat this update section as the current state.
