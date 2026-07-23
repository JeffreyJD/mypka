---
agent_id: klinger
session_id: 2026-07-22-track-b-connector-security-fixes
timestamp: 2026-07-23T01:45:00Z
type: end-of-session
linked_sops:
  - SOP-023-triage-inbox
linked_workstreams: []
linked_guidelines:
  - GL-018-inbox-triage-and-classification
  - GL-013-credential-backup-hygiene-on-operational-hosts
linked_tasks: []
linked_journal_entries:
  - 2026-07-22-stdlib-connector-credential-split-pattern
---

# Track B connector: applied Vex's two blocking security findings

## Context

Vex reviewed [[2026-07-22-19-18_klinger_track-b-imap-smtp-connector-build|the Track B build from earlier today]] (`scripts/track-b-imap-smtp-connector.py`) and returned four findings: two HIGH/MEDIUM blocking, two low-priority nice-to-haves. Jeff approved applying the two blocking findings this pass and explicitly declined 3/4 for now. No real credentials exist yet for this connector, so nothing needed re-verifying against a live mailbox — Vex's PoCs used placeholder/test data only, same standard as the original build pass.

## Finding 1 (HIGH) — TLS certificate verification missing

`imaplib.IMAP4_SSL(host, port)` and `smtp.starttls()` were both called with no explicit `ssl_context`/`context`, so CPython's private `ssl._create_stdlib_context()` fallback silently builds a context with `verify_mode=CERT_NONE` and `check_hostname=False` — encrypted but not authenticated, open to MITM.

**Before-fix PoC (ran against the real endpoints, confirmed the gap):**
```
IMAP context verify_mode/check_hostname: 0 False
SMTP context verify_mode/check_hostname: 0 False
```
(`0` = `ssl.CERT_NONE`.)

**Fix:** added a `_build_tls_context()` helper returning `ssl.create_default_context()`, passed explicitly at all three call sites:
- `imaplib.IMAP4_SSL(host, port, ssl_context=ctx)` in `_imap_connect`
- `smtp.starttls(context=ctx)` in `_smtp_connect_and_login`'s STARTTLS branch
- `smtplib.SMTP_SSL(..., context=ctx)` in the same function's `smtp_use_ssl: true` branch (unused today but present in the code — fixed for consistency, per Vex's ask)

**After-fix PoC (ran against the real endpoints, using the fixed code's own `_build_tls_context()` + the same call pattern as the fixed connect functions):**
```
IMAP (fixed) verify_mode/check_hostname: 2 True
SMTP (fixed) verify_mode/check_hostname: 2 True
SMTP_SSL (smtp_use_ssl branch, fixed) verify_mode/check_hostname: 2 True
```
(`2` = `ssl.CERT_REQUIRED`.) Also confirmed `python -m py_compile` clean after the edit.

New import needed: `ssl` (stdlib, no new dependency).

## Finding 2 (MEDIUM) — no explicit CRLF/header-injection guard

`_build_email` assigned caller-supplied strings straight into `EmailMessage` headers (`to`, `cc`, `subject`, `in_reply_to`, `references`) with no validation for embedded `\r`/`\n`. Modern CPython (3.7.16+/3.8.16+/3.9.16+/3.10.9+/3.11.1+, default from 3.12) has an implicit mitigation via `Policy.verify_generated_headers`, but the script wasn't asserting that guarantee as its own control — SOP-023 pipes external-sender content (subject/sender) into drafted replies, so a hostile sender's CRLF-plus-fake-header in a Subject/From is a real path into this function.

**Before-fix PoC** (on this machine's actual interpreter, Python 3.14.5): the interpreter's own implicit guard already rejects the injection (`ValueError: Header values may not contain linefeed or carriage return characters`) — confirming the script was relying on that version-gated stdlib behavior rather than an explicit control of its own, exactly as Vex flagged.

**Fix:** added `_reject_header_injection(field_name, value)` and a `HEADER_INJECTION_GUARDED_FIELDS` tuple (`to`, `cc`, `subject`, `in_reply_to`, `references`). `_build_email` now checks every guarded field (list-valued fields like `to`/`cc` checked element-by-element) for embedded `\r`/`\n` before constructing anything, raising `ConfigError` — matching the script's existing error-handling convention — independent of whatever the running interpreter's `email.policy` does.

**After-fix PoC:**
```
Rejected by our explicit guard: ConfigError: Rejected message field 'subject': contains a carriage return or newline character, which could be used for header injection (e.g. smuggling a fake Bcc/header). Value not logged.
_build_email rejected: ConfigError: Rejected message field 'subject': ...
Legit message built OK, Subject header: Re: original subject
```
Confirmed the explicit guard fires (not relying on the stdlib), and that a legitimate message payload still builds normally (no false positive).

## Scope discipline

Only findings 1 and 2 touched. Findings 3 and 4 (Vex's low-priority nice-to-haves) were explicitly declined by Jeff for this pass and untouched. No credential handling, retry logic, state-file logic, or CLI surface changed.

## What else changed in the file

- New stdlib import: `ssl`.
- New module docstring section, "Security notes (post Vex review, 2026-07-22)", documenting both fixes and noting findings 3-6 were deferred.
- Updated the "Ready for Vex" build session log ([[2026-07-22-19-18_klinger_track-b-imap-smtp-connector-build]]) with a pointer to this entry, since it referenced the pre-fix state.

## Handoff

- **Vex** — findings 1 and 2 closed; 3/4 remain open/deferred if Jeff wants them revisited later.
- **Jeff** — still owns generating the two app passwords per the original build session log's "what Jeff needs to do next" section; nothing in this pass changes that.
- No new task opened — this was a direct fix-and-verify pass against Vex's existing review, not new scope.

## References

- [[2026-07-22-19-18_klinger_track-b-imap-smtp-connector-build]]
- [[2026-07-22-stdlib-connector-credential-split-pattern]]
- [[ADR-001-unified-alert-notification-architecture]]
- [[SOP-023-triage-inbox]]
- `scripts/track-b-imap-smtp-connector.py`
