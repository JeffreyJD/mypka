#!/usr/bin/env python3
"""
track-b-imap-smtp-connector.py

Track B of the standing inbox-triage system (GL-018 / SOP-023 / ADR-001
Decision 1). Exposes three operations for jeff@davisglobe.com and
admin@davisglobe.com -- the two davisglobe.com addresses that are actively
planned to migrate off Google Workspace to an undecided provider:

    fetch              -- message metadata for a window, via IMAP.
    approve_as_draft   -- IMAP append to the account's Drafts folder.
    approve_and_send   -- SMTP send.

STANDARD LIBRARY ONLY. No third-party IMAP/SMTP package (no imapclient, no
imap-tools, no yagmail). No n8n. This is a deliberate v1 choice per Jeff's
direct ruling in ADR-001 -- see docs/design/ADR-001-unified-alert-notification-
architecture.md, Decision 1, "Track B's execution mechanism."

Why stdlib-only, restated briefly: Track A (jeffreyj2490@gmail.com,
davisglobe@gmail.com) is durably on Google and uses a mature, Vex-reviewed
community MCP server (google_workspace_mcp). Track B's two addresses are
migrating off Google Workspace to an unknown destination, so this script is
built to be protocol-portable: when the domain moves, only the per-inbox
connection config (host/port/auth) changes -- never this script's logic.

This script does NOT:
  - Do any GL-018 classification judgment (category, disposition, tier).
    That's SOP-023/Radar's job, entirely upstream of this script.
  - Read or write `.mypka/inbox-state/<inbox_id>.json` on its own initiative.
    `fetch()` will *read* the state file only to default the fetch window's
    `since` boundary when the caller doesn't supply one explicitly, and to
    skip message-ids already recorded as processed (idempotency). It never
    writes to the state file -- SOP-023 Phase 4 (Radar) owns persisting
    `last_run` / `processed_message_ids`, including the dry-run rule that
    state must not advance on a dry-run.
  - Write anything into PKM/. Klinger establishes the connection and
    delivers raw bytes; Margaret/Radar shape it into myPKA notes.
  - Contain, request, or hardcode any real credential. All secrets are read
    from environment variables (see "Credentials" below).

Usage (CLI, one subcommand per operation):

    python track-b-imap-smtp-connector.py fetch --inbox-id <id> \
        [--since 2026-07-01T00:00:00] [--until 2026-07-22T00:00:00] \
        [--mailbox INBOX] [--config PATH] [--env-file PATH] [--state-dir PATH]

    python track-b-imap-smtp-connector.py approve-as-draft --inbox-id <id> \
        --message-file draft.json [--config PATH] [--env-file PATH]

    python track-b-imap-smtp-connector.py approve-and-send --inbox-id <id> \
        --message-file draft.json [--config PATH] [--env-file PATH]

    python track-b-imap-smtp-connector.py test-connection --inbox-id <id> \
        [--config PATH] [--env-file PATH]

All subcommands print a single JSON object to stdout on success. All
diagnostic/structured logging goes to stderr as JSON lines, so stdout stays
clean for a caller (Radar, via a Bash-tool call) to parse.

`--message-file` points at a small JSON file shaped like:

    {
      "to": ["someone@example.com"],
      "cc": [],
      "subject": "Re: original subject",
      "body": "Plain-text reply body.",
      "in_reply_to": "<original-message-id@mail.example.com>",
      "references": "<original-message-id@mail.example.com>"
    }

`in_reply_to` / `references` are optional (omit for a new, non-reply
message). Only `to`, `subject`, and `body` are required.

Config (non-secret): a small JSON file, `track-b-inboxes.json` by default,
sitting next to this script. Keyed by `inbox_id`. Holds host/port/mailbox
names and the *name* of the environment variable holding that account's
app password -- never the password itself. See that file's own comments.

Credentials: never in this script, never in the non-secret config file
above, never committed to this repo. Each inbox's config names an
environment variable (e.g. TRACK_B_DAVISGLOBE_JEFF_APP_PASSWORD); this
script reads that variable from the real OS environment first, and falls
back to a plain KEY=VALUE env file living OUTSIDE this repo (default
`~/.mypka-track-b/track-b.env`, override via TRACK_B_ENV_FILE) if the
variable isn't already set. This mirrors the existing convention used by
Track A's google_workspace_mcp (client_secret.json / credentials dir living
at C:\\Users\\jeff\\.google-workspace-mcp\\, outside myPKA). Nothing here
creates or requires that file to exist yet -- see the account registration
notes in PKM/Environment/Accounts/ for what Jeff needs to do before this
script can run against real mail.

Retries: transient network/connection failures (DNS, timeout, connection
reset) are retried with exponential backoff. Authentication failures are
NOT retried -- they fail fast and loud, per Klinger's "validate environment
variables/credentials at startup, never silently retry a wrong password."
SMTP send is retried only up to and including the connect/STARTTLS/login
steps; once `smtp.send_message()` has actually been invoked, this script
never retries that call again, to avoid a double-send if the failure
happens after the server accepted the message but before the client saw the
ack. A failure at that exact boundary surfaces as an error for a human
(Jeff, or Radar surfacing to Jeff) to check the account's Sent folder
before manually resending.

Security notes (post Vex review, 2026-07-22):
  - TLS verification is explicit. Every IMAP/SMTP connection this script
    opens passes an `ssl.create_default_context()` (CERT_REQUIRED +
    check_hostname=True) via `_build_tls_context()` -- never the
    imaplib/smtplib default of `ssl_context=None`/`context=None`, which
    silently builds an unauthenticated context (CERT_NONE, no hostname
    check) via the private `ssl._create_stdlib_context()` helper. Fixed
    2026-07-22 (Vex finding 1, HIGH).
  - Header injection (CRLF) is rejected explicitly. `_build_email()` checks
    `to`/`cc`/`subject`/`in_reply_to`/`references` for embedded `\r`/`\n`
    via `_reject_header_injection()` before constructing the EmailMessage,
    raising ConfigError on a hit. This is this script's own control,
    independent of whichever CPython patch level's implicit
    `Policy.verify_generated_headers` guard happens to be in effect. Fixed
    2026-07-22 (Vex finding 2, MEDIUM).
  - Findings 3-6 from that same Vex review (lower priority) were deferred
    by Jeff for this pass and are not addressed here.
"""

from __future__ import annotations

import argparse
import email
import email.utils
import imaplib
import json
import logging
import os
import re
import smtplib
import socket
import ssl
import sys
import time
from dataclasses import dataclass, field
from datetime import datetime, timedelta, timezone
from email.message import EmailMessage
from pathlib import Path
from typing import Any, Callable, Optional

# --------------------------------------------------------------------------
# Constants / defaults -- every one of these is overridable, none hardcoded
# to a specific mail provider. When davisglobe.com migrates off Google
# Workspace, only track-b-inboxes.json's host/port fields change.
# --------------------------------------------------------------------------

SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent

CONFIG_PATH_ENV = "TRACK_B_CONFIG_PATH"
DEFAULT_CONFIG_PATH = SCRIPT_DIR / "track-b-inboxes.json"

ENV_FILE_ENV = "TRACK_B_ENV_FILE"
DEFAULT_ENV_FILE = Path.home() / ".mypka-track-b" / "track-b.env"

STATE_DIR_ENV = "TRACK_B_STATE_DIR"
DEFAULT_STATE_DIR = REPO_ROOT / ".mypka" / "inbox-state"

DEFAULT_SNIPPET_LEN = 280
DEFAULT_RETRY_TRIES = 3
DEFAULT_RETRY_BASE_DELAY = 1.0
DEFAULT_RETRY_BACKOFF = 2.0

# Header fields that go straight from caller-supplied message payloads into
# EmailMessage headers. Every one of these is checked for embedded CR/LF
# before use -- see _reject_header_injection(). This is an explicit control
# of this script's own, independent of the interpreter version's implicit
# Policy.verify_generated_headers guard (see module security notes).
HEADER_INJECTION_GUARDED_FIELDS = ("to", "cc", "subject", "in_reply_to", "references")


def _build_tls_context() -> ssl.SSLContext:
    """Explicit, verifying TLS context for every IMAP/SMTP connection this
    script makes. Never rely on imaplib/smtplib's default of `context=None`
    -- that path goes through ssl._create_stdlib_context(), which sets
    verify_mode=CERT_NONE and check_hostname=False (encrypted but not
    authenticated -- open to MITM). ssl.create_default_context() gives
    CERT_REQUIRED + check_hostname=True, using the OS trust store."""
    return ssl.create_default_context()


def _reject_header_injection(field_name: str, value: str) -> None:
    """Explicit CRLF/header-injection guard, independent of whatever the
    running interpreter's email.policy implicitly catches. Modern CPython
    (3.7.16+/3.8.16+/3.9.16+/3.10.9+/3.11.1+, default from 3.12) rejects
    embedded \\r/\\n in header values via Policy.verify_generated_headers,
    but this script does not rely on that version-gated stdlib behavior --
    SOP-023 passes external-sender content (subject/sender) into drafted
    replies, so a hostile sender's CRLF-plus-fake-header in a Subject/From
    is a real path into this function's inputs."""
    if "\r" in value or "\n" in value:
        raise ConfigError(
            f"Rejected message field '{field_name}': contains a carriage "
            f"return or newline character, which could be used for header "
            f"injection (e.g. smuggling a fake Bcc/header). Value not logged."
        )

# Errors worth retrying: transient network conditions only. Never retry
# authentication failures (imaplib.IMAP4.error / smtplib.SMTPAuthenticationError
# are deliberately excluded).
TRANSIENT_EXCEPTIONS = (
    socket.timeout,
    ConnectionError,
    imaplib.IMAP4.abort,
    TimeoutError,
)


# --------------------------------------------------------------------------
# Structured logging (JSON lines to stderr; stdout is reserved for the
# final result payload). Never log a credential value -- only env var
# *names*, never contents.
# --------------------------------------------------------------------------

logger = logging.getLogger("track_b_connector")
logger.setLevel(logging.INFO)


class _JsonLineFormatter(logging.Formatter):
    def format(self, record: logging.LogRecord) -> str:
        payload = {
            "ts": datetime.now(timezone.utc).isoformat(),
            "level": record.levelname,
            "message": record.getMessage(),
        }
        extra = getattr(record, "fields", None)
        if extra:
            payload.update(extra)
        return json.dumps(payload)


_handler = logging.StreamHandler(stream=sys.stderr)
_handler.setFormatter(_JsonLineFormatter())
logger.addHandler(_handler)
logger.propagate = False


def log_event(level: str, message: str, **fields: Any) -> None:
    """Structured log helper. `fields` must never contain a credential
    value -- pass env var *names*, message-ids, hosts, counts, etc. only."""
    logger.log(getattr(logging, level.upper(), logging.INFO), message, extra={"fields": fields})


# --------------------------------------------------------------------------
# Errors
# --------------------------------------------------------------------------

class ConfigError(RuntimeError):
    """Raised for missing/malformed configuration. Fails fast and loud --
    never silently falls back to a default that could point at the wrong
    mailbox."""


class CredentialsError(RuntimeError):
    """Raised when a required credential env var is not set anywhere this
    script is allowed to look. Never includes the credential's value."""


# --------------------------------------------------------------------------
# Retry decorator
# --------------------------------------------------------------------------

def with_retry(
    exceptions: tuple = TRANSIENT_EXCEPTIONS,
    tries: int = DEFAULT_RETRY_TRIES,
    base_delay: float = DEFAULT_RETRY_BASE_DELAY,
    backoff: float = DEFAULT_RETRY_BACKOFF,
) -> Callable:
    """Exponential backoff retry for transient network failures only.
    Authentication/config errors are never caught here -- they propagate
    immediately."""

    def decorator(fn: Callable) -> Callable:
        def wrapper(*args, **kwargs):
            delay = base_delay
            last_exc: Optional[Exception] = None
            for attempt in range(1, tries + 1):
                try:
                    return fn(*args, **kwargs)
                except exceptions as exc:  # noqa: PERF203 - clarity over micro-perf
                    last_exc = exc
                    if attempt == tries:
                        log_event(
                            "error",
                            "retry exhausted",
                            fn=fn.__name__,
                            attempts=attempt,
                            error=str(exc),
                        )
                        raise
                    log_event(
                        "warning",
                        "transient error, retrying",
                        fn=fn.__name__,
                        attempt=attempt,
                        next_delay_s=delay,
                        error=str(exc),
                    )
                    time.sleep(delay)
                    delay *= backoff
            # Unreachable, but keeps type-checkers happy.
            if last_exc:
                raise last_exc

        return wrapper

    return decorator


# --------------------------------------------------------------------------
# Config + credentials loading
# --------------------------------------------------------------------------

def load_connection_config(config_path: Optional[Path] = None) -> dict:
    path = config_path or Path(os.environ.get(CONFIG_PATH_ENV, DEFAULT_CONFIG_PATH))
    if not path.is_file():
        raise ConfigError(f"Track B connection config not found at {path}")
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        raise ConfigError(f"Track B connection config at {path} is not valid JSON: {exc}") from exc
    if "inboxes" not in data or not isinstance(data["inboxes"], dict):
        raise ConfigError(f"Track B connection config at {path} is missing a top-level 'inboxes' object")
    return data["inboxes"]


def get_inbox_config(inbox_id: str, config_path: Optional[Path] = None) -> dict:
    inboxes = load_connection_config(config_path)
    if inbox_id not in inboxes:
        known = ", ".join(sorted(inboxes)) or "(none configured)"
        raise ConfigError(f"inbox_id '{inbox_id}' not found in Track B config. Known ids: {known}")
    cfg = inboxes[inbox_id]
    required_top = ("email_address", "imap_host", "imap_port", "smtp_host", "smtp_port", "drafts_folder", "auth")
    for key in required_top:
        if key not in cfg:
            raise ConfigError(f"inbox_id '{inbox_id}' config missing required field '{key}'")
    if "username" not in cfg["auth"] or "password_env_var" not in cfg["auth"]:
        raise ConfigError(f"inbox_id '{inbox_id}' auth block missing 'username' or 'password_env_var'")
    return cfg


def _parse_env_file(path: Path) -> dict:
    """Tiny stdlib KEY=VALUE parser -- deliberately not python-dotenv
    (stdlib-only constraint). Ignores blank lines and lines starting with
    '#'. Does not support quoting/escaping beyond simple strip()."""
    result: dict[str, str] = {}
    if not path.is_file():
        return result
    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, _, value = line.partition("=")
        result[key.strip()] = value.strip()
    return result


def resolve_password(password_env_var: str, env_file_path: Optional[Path] = None) -> str:
    """Never logs or returns anything but the resolved value to the caller
    for immediate use -- never persisted, never echoed. Checks the real OS
    environment first (e.g. set by a Desktop Scheduled Task's action or the
    operator's shell), then falls back to the external env file."""
    value = os.environ.get(password_env_var)
    if value:
        return value
    path = env_file_path or Path(os.environ.get(ENV_FILE_ENV, DEFAULT_ENV_FILE))
    file_vars = _parse_env_file(path)
    value = file_vars.get(password_env_var)
    if value:
        return value
    raise CredentialsError(
        f"Credential env var '{password_env_var}' is not set in the OS environment "
        f"and not present in the env file at {path}. Set it before running this "
        f"script -- never hardcode it here or in track-b-inboxes.json."
    )


# --------------------------------------------------------------------------
# State file (read-only from this script's point of view -- see module
# docstring). Shape matches .mypka/inbox-state/gmail-personal.json's
# existing schema so Radar/SOP-023 can treat every inbox_id uniformly
# regardless of track.
# --------------------------------------------------------------------------

def state_file_path(inbox_id: str, state_dir: Optional[Path] = None) -> Path:
    directory = state_dir or Path(os.environ.get(STATE_DIR_ENV, DEFAULT_STATE_DIR))
    return directory / f"{inbox_id}.json"


def read_state(inbox_id: str, state_dir: Optional[Path] = None) -> dict:
    path = state_file_path(inbox_id, state_dir)
    if not path.is_file():
        return {"inbox_id": inbox_id, "last_run": None, "processed_message_ids": []}
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        raise ConfigError(f"State file at {path} is not valid JSON: {exc}") from exc


# --------------------------------------------------------------------------
# Message parsing helpers
# --------------------------------------------------------------------------

def _decode_header_value(raw: Optional[str]) -> str:
    if not raw:
        return ""
    try:
        return str(email.header.make_header(email.header.decode_header(raw)))
    except Exception:  # noqa: BLE001 - best-effort decode, never fatal
        return raw


def _extract_snippet(msg: email.message.Message, max_len: int = DEFAULT_SNIPPET_LEN) -> str:
    """Best-effort plain-text snippet. Prefers text/plain; falls back to a
    naive tag-strip of text/html (stdlib re, not a real HTML parser --
    flagged here as non-authoritative on purpose, since BeautifulSoup would
    be a third-party dependency this script deliberately avoids)."""
    plain_text = None
    html_text = None
    if msg.is_multipart():
        for part in msg.walk():
            content_type = part.get_content_type()
            disposition = str(part.get("Content-Disposition", ""))
            if "attachment" in disposition:
                continue
            if content_type == "text/plain" and plain_text is None:
                plain_text = _decode_payload(part)
            elif content_type == "text/html" and html_text is None:
                html_text = _decode_payload(part)
    else:
        if msg.get_content_type() == "text/plain":
            plain_text = _decode_payload(msg)
        elif msg.get_content_type() == "text/html":
            html_text = _decode_payload(msg)

    if plain_text:
        text = plain_text
    elif html_text:
        text = re.sub(r"<[^<]+?>", " ", html_text)
    else:
        text = ""
    text = re.sub(r"\s+", " ", text).strip()
    return text[:max_len]


def _decode_payload(part: email.message.Message) -> str:
    try:
        payload = part.get_payload(decode=True)
        if payload is None:
            return ""
        charset = part.get_content_charset() or "utf-8"
        return payload.decode(charset, errors="replace")
    except Exception:  # noqa: BLE001 - best-effort decode, never fatal
        return ""


def _extract_attachments(msg: email.message.Message) -> list[str]:
    names = []
    if not msg.is_multipart():
        return names
    for part in msg.walk():
        disposition = str(part.get("Content-Disposition", ""))
        filename = part.get_filename()
        if filename and ("attachment" in disposition or part.get_content_maintype() not in ("text", "multipart")):
            names.append(_decode_header_value(filename))
    return names


def _parse_message_record(inbox_id: str, raw_bytes: bytes) -> dict:
    msg = email.message_from_bytes(raw_bytes)
    message_id = (msg.get("Message-ID") or "").strip()
    sender_name, sender_addr = email.utils.parseaddr(msg.get("From", ""))
    subject = _decode_header_value(msg.get("Subject"))
    date_header = msg.get("Date")
    date_iso: Optional[str] = None
    if date_header:
        try:
            dt = email.utils.parsedate_to_datetime(date_header)
            date_iso = dt.isoformat()
        except (TypeError, ValueError):
            date_iso = None
    return {
        "inbox_id": inbox_id,
        "message_id": message_id,
        "sender_name": _decode_header_value(sender_name),
        "sender_address": sender_addr,
        "subject": subject,
        "date": date_iso,
        "snippet": _extract_snippet(msg),
        "attachments": _extract_attachments(msg),
    }


# --------------------------------------------------------------------------
# IMAP operations
# --------------------------------------------------------------------------

@with_retry()
def _imap_connect(host: str, port: int, username: str, password: str) -> imaplib.IMAP4_SSL:
    conn = imaplib.IMAP4_SSL(host, port, ssl_context=_build_tls_context())
    try:
        conn.login(username, password)
    except imaplib.IMAP4.error as exc:
        # Auth failures are never retried -- fail fast and loud.
        conn.logout()
        raise CredentialsError(
            f"IMAP login failed for {username}@{host}:{port}. Check the app "
            f"password is current and has not been revoked. ({exc})"
        ) from exc
    return conn


def fetch(
    inbox_id: str,
    since: Optional[datetime] = None,
    until: Optional[datetime] = None,
    mailbox: str = "INBOX",
    config_path: Optional[Path] = None,
    env_file_path: Optional[Path] = None,
    state_dir: Optional[Path] = None,
    include_processed: bool = False,
) -> dict:
    """Fetch message metadata for a window via IMAP. Read-only: uses
    BODY.PEEK[] so \\Seen is never set. Does not write the state file.

    Window resolution: if `since` is not given, falls back to the state
    file's `last_run`. If neither exists, raises ConfigError -- mirrors
    SOP-023 Phase 0's rule that the very first run for a new inbox_id
    requires Jeff's explicit window, never a silent guess.
    """
    cfg = get_inbox_config(inbox_id, config_path)

    # Resolve the fetch window before touching credentials -- a missing
    # window on a first run is a config error, not a credentials error, and
    # should surface without requiring the app password to be wired up yet
    # (useful when a caller is still setting up a brand-new inbox_id).
    state = read_state(inbox_id, state_dir)
    if since is None:
        last_run = state.get("last_run")
        if not last_run:
            raise ConfigError(
                f"No 'since' provided and no last_run recorded for inbox_id "
                f"'{inbox_id}'. First run for a new inbox requires an explicit "
                f"--since window (per SOP-023 Phase 0) -- never guessed."
            )
        since = datetime.fromisoformat(last_run.replace("Z", "+00:00"))

    processed_ids = set(state.get("processed_message_ids", [])) if not include_processed else set()

    password = resolve_password(cfg["auth"]["password_env_var"], env_file_path)

    log_event(
        "info",
        "imap fetch starting",
        inbox_id=inbox_id,
        mailbox=mailbox,
        since=since.isoformat(),
        until=until.isoformat() if until else None,
    )

    conn = _imap_connect(cfg["imap_host"], int(cfg["imap_port"]), cfg["auth"]["username"], password)
    try:
        status, _ = conn.select(mailbox, readonly=True)
        if status != "OK":
            raise ConfigError(f"Could not select mailbox '{mailbox}' for inbox_id '{inbox_id}'")

        # IMAP SINCE/BEFORE are date-granular only (no time-of-day). This
        # query is therefore a coarse superset; precise since/until
        # filtering happens below against each message's parsed Date header.
        criteria = f'(SINCE "{since.strftime("%d-%b-%Y")}"'
        if until:
            until_plus = until + timedelta(days=1)
            criteria += f' BEFORE "{until_plus.strftime("%d-%b-%Y")}"'
        criteria += ")"

        status, data = conn.uid("search", None, criteria)
        if status != "OK":
            raise ConfigError(f"IMAP SEARCH failed for inbox_id '{inbox_id}': {data}")
        uids = data[0].split() if data and data[0] else []

        records = []
        for uid in uids:
            status, msg_data = conn.uid("fetch", uid, "(BODY.PEEK[])")
            if status != "OK" or not msg_data or msg_data[0] is None:
                log_event("warning", "failed to fetch message", inbox_id=inbox_id, uid=uid.decode())
                continue
            raw_bytes = msg_data[0][1]
            record = _parse_message_record(inbox_id, raw_bytes)

            if record["message_id"] in processed_ids:
                continue

            if record["date"]:
                msg_dt = datetime.fromisoformat(record["date"])
                if msg_dt.tzinfo is None:
                    msg_dt = msg_dt.replace(tzinfo=timezone.utc)
                since_cmp = since if since.tzinfo else since.replace(tzinfo=timezone.utc)
                if msg_dt < since_cmp:
                    continue
                if until:
                    until_cmp = until if until.tzinfo else until.replace(tzinfo=timezone.utc)
                    if msg_dt > until_cmp:
                        continue

            records.append(record)

        records.sort(key=lambda r: r["date"] or "")
        log_event("info", "imap fetch complete", inbox_id=inbox_id, message_count=len(records))
        return {
            "inbox_id": inbox_id,
            "mailbox": mailbox,
            "window": {"since": since.isoformat(), "until": until.isoformat() if until else None},
            "message_count": len(records),
            "messages": records,
        }
    finally:
        try:
            conn.close()
        except Exception:  # noqa: BLE001 - best-effort cleanup
            pass
        conn.logout()


@with_retry()
def _imap_append_draft(cfg: dict, password: str, message: EmailMessage) -> None:
    conn = _imap_connect(cfg["imap_host"], int(cfg["imap_port"]), cfg["auth"]["username"], password)
    try:
        typ, _ = conn.append(
            cfg["drafts_folder"],
            r"(\Draft)",
            imaplib.Time2Internaldate(time.time()),
            message.as_bytes(),
        )
        if typ != "OK":
            raise ConfigError(f"IMAP APPEND to '{cfg['drafts_folder']}' did not return OK")
    finally:
        conn.logout()


def _build_email(cfg: dict, message: dict) -> EmailMessage:
    required = ("to", "subject", "body")
    for key in required:
        if key not in message:
            raise ConfigError(f"message payload missing required field '{key}'")

    # Explicit CRLF/header-injection guard -- checked before any value
    # touches an EmailMessage header. Independent of whatever the running
    # interpreter's email.policy implicitly does or doesn't catch; see
    # _reject_header_injection()'s docstring for why this can't be left to
    # the stdlib alone (SOP-023 pipes external-sender content in here).
    for field_name in HEADER_INJECTION_GUARDED_FIELDS:
        raw_value = message.get(field_name)
        if raw_value is None:
            continue
        values = raw_value if isinstance(raw_value, list) else [raw_value]
        for v in values:
            _reject_header_injection(field_name, str(v))

    email_msg = EmailMessage()
    email_msg["From"] = cfg["email_address"]
    to = message["to"] if isinstance(message["to"], list) else [message["to"]]
    email_msg["To"] = ", ".join(to)
    if message.get("cc"):
        cc = message["cc"] if isinstance(message["cc"], list) else [message["cc"]]
        email_msg["Cc"] = ", ".join(cc)
    email_msg["Subject"] = message["subject"]
    email_msg["Date"] = email.utils.formatdate(localtime=True)
    email_msg["Message-ID"] = email.utils.make_msgid()
    if message.get("in_reply_to"):
        email_msg["In-Reply-To"] = message["in_reply_to"]
    if message.get("references"):
        email_msg["References"] = message["references"]
    email_msg.set_content(message["body"])
    return email_msg


def approve_as_draft(
    inbox_id: str,
    message: dict,
    config_path: Optional[Path] = None,
    env_file_path: Optional[Path] = None,
) -> dict:
    """IMAP append to the account's Drafts folder. Called only after Jeff
    has already approved this specific outcome for this specific message
    (propose-then-confirm already happened upstream in SOP-023) -- this
    function does not itself gate anything."""
    cfg = get_inbox_config(inbox_id, config_path)
    password = resolve_password(cfg["auth"]["password_env_var"], env_file_path)
    email_msg = _build_email(cfg, message)
    log_event("info", "drafting message", inbox_id=inbox_id, drafts_folder=cfg["drafts_folder"])
    _imap_append_draft(cfg, password, email_msg)
    return {
        "status": "drafted",
        "inbox_id": inbox_id,
        "drafts_folder": cfg["drafts_folder"],
        "new_message_id": email_msg["Message-ID"],
        "drafted_at": datetime.now(timezone.utc).isoformat(),
    }


@with_retry()
def _smtp_connect_and_login(cfg: dict, password: str) -> smtplib.SMTP:
    tls_context = _build_tls_context()
    if cfg.get("smtp_use_ssl"):
        smtp = smtplib.SMTP_SSL(cfg["smtp_host"], int(cfg["smtp_port"]), timeout=30, context=tls_context)
    else:
        smtp = smtplib.SMTP(cfg["smtp_host"], int(cfg["smtp_port"]), timeout=30)
        if cfg.get("smtp_use_starttls", True):
            smtp.starttls(context=tls_context)
    try:
        smtp.login(cfg["auth"]["username"], password)
    except smtplib.SMTPAuthenticationError as exc:
        smtp.quit()
        raise CredentialsError(
            f"SMTP login failed for {cfg['auth']['username']}@{cfg['smtp_host']}:"
            f"{cfg['smtp_port']}. Check the app password is current. ({exc})"
        ) from exc
    return smtp


def approve_and_send(
    inbox_id: str,
    message: dict,
    config_path: Optional[Path] = None,
    env_file_path: Optional[Path] = None,
) -> dict:
    """SMTP send. Called only after Jeff has already approved 'send now'
    for this specific message. Retries are scoped to connect/STARTTLS/login
    only -- once send_message() is called, this function never retries, to
    avoid a double-send on an ambiguous post-send failure."""
    cfg = get_inbox_config(inbox_id, config_path)
    password = resolve_password(cfg["auth"]["password_env_var"], env_file_path)
    email_msg = _build_email(cfg, message)
    log_event("info", "sending message", inbox_id=inbox_id, to=email_msg["To"])
    smtp = _smtp_connect_and_login(cfg, password)
    try:
        smtp.send_message(email_msg)
    except Exception as exc:
        log_event(
            "error",
            "send_message failed after successful login -- check Sent folder "
            "before resending, this call is not retried",
            inbox_id=inbox_id,
            error=str(exc),
        )
        raise
    finally:
        try:
            smtp.quit()
        except Exception:  # noqa: BLE001 - best-effort cleanup
            pass
    return {
        "status": "sent",
        "inbox_id": inbox_id,
        "to": email_msg["To"],
        "new_message_id": email_msg["Message-ID"],
        "sent_at": datetime.now(timezone.utc).isoformat(),
    }


def test_connection(
    inbox_id: str,
    config_path: Optional[Path] = None,
    env_file_path: Optional[Path] = None,
) -> dict:
    """Health check: verifies IMAP login + mailbox select, and SMTP
    connect + login, without touching any message. Safe to run before
    credentials are trusted for real fetch/draft/send."""
    cfg = get_inbox_config(inbox_id, config_path)
    password = resolve_password(cfg["auth"]["password_env_var"], env_file_path)

    result: dict[str, Any] = {"inbox_id": inbox_id}

    try:
        conn = _imap_connect(cfg["imap_host"], int(cfg["imap_port"]), cfg["auth"]["username"], password)
        conn.select("INBOX", readonly=True)
        conn.close()
        conn.logout()
        result["imap"] = "ok"
    except Exception as exc:  # noqa: BLE001 - health check reports, doesn't raise
        result["imap"] = f"failed: {exc}"

    try:
        smtp = _smtp_connect_and_login(cfg, password)
        smtp.quit()
        result["smtp"] = "ok"
    except Exception as exc:  # noqa: BLE001 - health check reports, doesn't raise
        result["smtp"] = f"failed: {exc}"

    return result


# --------------------------------------------------------------------------
# CLI
# --------------------------------------------------------------------------

def _parse_iso(value: Optional[str]) -> Optional[datetime]:
    if value is None:
        return None
    return datetime.fromisoformat(value)


def _load_message_payload(args: argparse.Namespace) -> dict:
    if args.message_file:
        return json.loads(Path(args.message_file).read_text(encoding="utf-8"))
    if args.message_json:
        return json.loads(args.message_json)
    raise ConfigError("Provide --message-file or --message-json for this operation")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--config", type=Path, default=None, help="Path to track-b-inboxes.json (non-secret config)")
    parser.add_argument("--env-file", type=Path, default=None, help="Path to external env file holding app passwords")

    sub = parser.add_subparsers(dest="command", required=True)

    p_fetch = sub.add_parser("fetch", help="Fetch message metadata for a window via IMAP")
    p_fetch.add_argument("--inbox-id", required=True)
    p_fetch.add_argument("--since", type=str, default=None, help="ISO8601 datetime, e.g. 2026-07-01T00:00:00")
    p_fetch.add_argument("--until", type=str, default=None, help="ISO8601 datetime")
    p_fetch.add_argument("--mailbox", type=str, default="INBOX")
    p_fetch.add_argument("--state-dir", type=Path, default=None)
    p_fetch.add_argument("--include-processed", action="store_true", help="Debug only: skip idempotency dedup")

    p_draft = sub.add_parser("approve-as-draft", help="IMAP append to the account's Drafts folder")
    p_draft.add_argument("--inbox-id", required=True)
    p_draft.add_argument("--message-file", type=Path, default=None)
    p_draft.add_argument("--message-json", type=str, default=None)

    p_send = sub.add_parser("approve-and-send", help="SMTP send")
    p_send.add_argument("--inbox-id", required=True)
    p_send.add_argument("--message-file", type=Path, default=None)
    p_send.add_argument("--message-json", type=str, default=None)

    p_test = sub.add_parser("test-connection", help="IMAP + SMTP login health check, no message operations")
    p_test.add_argument("--inbox-id", required=True)

    return parser


def main(argv: Optional[list] = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    try:
        if args.command == "fetch":
            result = fetch(
                inbox_id=args.inbox_id,
                since=_parse_iso(args.since),
                until=_parse_iso(args.until),
                mailbox=args.mailbox,
                config_path=args.config,
                env_file_path=args.env_file,
                state_dir=args.state_dir,
                include_processed=args.include_processed,
            )
        elif args.command == "approve-as-draft":
            message = _load_message_payload(args)
            result = approve_as_draft(args.inbox_id, message, args.config, args.env_file)
        elif args.command == "approve-and-send":
            message = _load_message_payload(args)
            result = approve_and_send(args.inbox_id, message, args.config, args.env_file)
        elif args.command == "test-connection":
            result = test_connection(args.inbox_id, args.config, args.env_file)
        else:  # pragma: no cover - argparse enforces valid choices
            raise ConfigError(f"Unknown command {args.command}")
    except (ConfigError, CredentialsError) as exc:
        log_event("error", str(exc), inbox_id=getattr(args, "inbox_id", None))
        print(json.dumps({"status": "error", "error": str(exc)}, indent=2))
        return 1

    print(json.dumps(result, indent=2, default=str))
    return 0


if __name__ == "__main__":
    sys.exit(main())
