---
agent: klinger
date: 2026-06-24
type: tier-0-learning
---

# Cockpit install patterns

## What I learned

Two things to do every time the Cockpit is installed, beyond the install steps themselves:

1. **Root `.gitignore` entry for `mypka.db`.** The Cockpit's own nested `.gitignore` only covers files within its subfolder. The scaffold-root `mypka.db` (and `-shm`, `-wal` WAL files) will be accidentally committed if this step is missed. Add all three to the root `.gitignore` at install time.

2. **Non-blocking launch.** The Cockpit is a long-running Node server. Launching it with a blocking shell call locks all further tool calls for the duration of the process. Use a non-blocking invocation (e.g. `Start-Process` on Windows, `&` background operator on Unix). The user starts it themselves from the generated launcher — Hawkeye does not auto-start it.

## When this applies

Every Cockpit install or reinstall. Check the root `.gitignore` before closing the install session.

## When this does NOT apply

Does not apply to one-shot scripts or CLI tools that exit on their own.
