---
agent_id: klinger
type: journal-entry
created: 2026-07-22T19:18:00Z
updated: 2026-07-22T19:45:00Z
topic: stdlib-connector-credential-split-pattern
tags: [credentials, imap, smtp, stdlib, connector-design]
linked_session_logs:
  - 2026-07-22-19-18_klinger_track-b-imap-smtp-connector-build
  - 2026-07-22-19-45_klinger_track-b-connector-security-fixes
linked_tasks: []
related_journal_entries: []
status: durable
---

# Split a stdlib connector into three layers: committed non-secret config, external env-var-named-only config, and the actual secret — and check config errors before credential errors

## Context

Building the Track B IMAP/SMTP connector (`scripts/track-b-imap-smtp-connector.py`) for jeff@/admin@davisglobe.com, deliberately outside OAuth/MCP because the domain is migrating providers. No mature MCP/third-party option was appropriate — first from-scratch stdlib-only mail connector I've built for this vault.

## What I learned

For any stdlib (no third-party package) connector that needs a live credential:

1. **Three layers, not two.** (a) A non-secret connection-config file (host, port, folder names, which env var holds the password) — safe to commit. (b) An external env file, *outside the repo*, holding the actual secret values, read by a tiny stdlib `KEY=VALUE` parser (never `python-dotenv` — that's a third-party dependency, defeats the stdlib-only constraint). (c) The OS environment itself, checked *before* the env file, so a Scheduled Task's own environment can override without touching disk. This mirrors the OAuth-era convention (`client_secret.json` + a credentials dir, both outside the repo) but for basic-auth creds instead of tokens — same "secrets are pointers, never values, in the vault" rule, just a different credential shape.
2. **Order error checks by cost, not by convenience.** If a function needs both a resolved parameter (like a fetch window) and a credential, resolve the parameter *first*. A missing window on a brand-new `inbox_id` is a config problem the operator can fix without touching secrets at all — don't make them wire up a password just to discover the window is the actual blocker. I initially wrote credential resolution first in `fetch()` and had to reorder it after testing surfaced the wrong error message first.
3. **Test the failure paths against the real remote endpoint, with a fake credential.** Attempting a real connection to `imap.gmail.com`/`smtp.gmail.com` with a placeholder password and confirming it fails with an *auth* error (not a network error) is a strictly better verification step than mocking the transport — it proves DNS, TLS/STARTTLS, and protocol framing all work, without ever touching a real mailbox or needing the real secret.
4. **Auth failures are structurally different from transient failures — never share a retry path.** A wrong/revoked password retried three times with backoff just wastes time and can trip provider-side brute-force throttling. Exclude auth-error exception types from the retry decorator's caught-exception tuple explicitly; let them raise on the first attempt.

## When this applies

Any future from-scratch stdlib connector (IMAP/SMTP, a plain REST API with an API key, anything not going through an existing MCP server or OAuth library) that needs a credential and has to run unattended (a Scheduled Task, a cron job).

## When this does NOT apply

- OAuth-flow connectors (token refresh already handles most of this differently — see the `google_workspace_mcp` pattern instead).
- One-shot interactive scripts a human runs and pastes a credential into on the spot — the external-env-file layer is overkill there.

## Evidence

- [[2026-07-22-19-18_klinger_track-b-imap-smtp-connector-build]]
- `scripts/track-b-imap-smtp-connector.py`
