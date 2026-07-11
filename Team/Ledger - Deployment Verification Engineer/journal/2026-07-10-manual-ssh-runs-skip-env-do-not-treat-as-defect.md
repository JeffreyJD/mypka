---
agent_id: ledger
type: journal-entry
created: 2026-07-10T21:30:00Z
updated: 2026-07-10T21:30:00Z
topic: manual-ssh-runs-skip-env-do-not-treat-as-defect
tags: [prophet-trader, davisglobe-vps-ash-1, env-loading, observability]
linked_session_logs: []
linked_tasks: []
related_journal_entries: []
status: durable
---

# On davisglobe-vps-ash-1, an interactive SSH invocation of a script bypasses `.env` — that's a shell-context artifact, not a live-path defect

## Context

Verifying Pierce's claim that `weekly_autopsy.py`'s Telegram send was "skipped, expected" during his manual post-migration check on PR #10 (demotion-check filename fix). His interactive run called `.venv/bin/python scripts/weekly_autopsy.py` directly; the real cron entry calls `install/run_weekly_autopsy.sh`, a wrapper.

## What I learned

Prophet Trader's cron wrapper scripts (`install/run_routine.sh`, `install/run_weekly_autopsy.sh`) explicitly `source .env` with `set -o allexport` before invoking the Python entrypoint. The Python scripts themselves never load `.env` — they only read `os.environ`. So any time someone (Pierce, me, anyone) SSHes in and runs the `.py` file directly instead of the `.sh` wrapper, every env-gated behavior (Telegram send, healthchecks ping, anything reading `os.environ.get(...)`) silently no-ops — by design, "fails open," with zero log line marking the skip. That is correct behavior for the real cron path and NOT evidence of a defect, but it means a manual interactive verification run can never be used on its own to confirm the notification path works — only the actual cron-triggered run (or a manual run that explicitly re-sources `.env` first) can confirm that.

## When this applies

Any time verifying a Prophet Trader script's live behavior via manual SSH — check whether the invocation goes through the `install/*.sh` wrapper (env loaded) or calls the `.py` directly (env not loaded, silent no-op on every env-gated branch). Also applies to any other host/service in this registry using a similar wrapper-loads-env-python-does-not pattern — check the wrapper before accepting a "notification wasn't sent" claim at face value.

## When this does NOT apply

Doesn't apply to scripts that call `load_dotenv()` internally (grepped `weekly_autopsy.py` — it does not; confirm per-script before assuming this pattern holds elsewhere in the repo). Doesn't excuse a genuinely silent skip with no upstream log line ever, in any context — the `_send_telegram_summary()` function itself logs nothing on the "vars missing" branch (just an unconditional `return`), which is a minor observability gap worth flagging separately if it ever needs debugging without SSH context to fall back on.

## Evidence

- Read `install/run_weekly_autopsy.sh` directly on `davisglobe-vps-ash-1` via SSH 2026-07-10: `source "$ENV_FILE"` under `set -o allexport` precedes the Python call.
- Read `scripts/weekly_autopsy.py` lines 680-698 directly: `_send_telegram_summary()` reads only `os.environ.get(...)`, no `.env` loading, silent `return` (no log) if vars absent.
- Confirmed `.env` on the VPS has non-empty `TELEGRAM_BOT_TOKEN` (len=46) and `TELEGRAM_CHAT_ID` (len=10) — the real cron-triggered Sunday run will have these populated via the wrapper.
- [[PKM/Environment/Services/prophet-trader]], [[PKM/Environment/Hosts/davisglobe-vps-ash-1]]
