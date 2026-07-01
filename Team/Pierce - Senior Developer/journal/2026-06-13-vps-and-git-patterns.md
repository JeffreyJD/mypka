---
agent: pierce
date: 2026-06-13
type: tier-0-learning
---

# VPS cron and git commit patterns

## What I learned

**Ubuntu cron ignores `TZ=` header for scheduling.** Writing `TZ=America/New_York` at the top of a crontab does not change when cron fires — it only sets the environment variable inside the job. All crontab times must be expressed in UTC. Convert ET times to UTC before writing the crontab. Deadline note: UTC offsets change at DST boundaries (America/New_York is UTC-5 in winter, UTC-4 in summer) — review crontab before each DST change (March and November).

**PowerShell breaks `git commit -m` with quoted multiline strings.** Quoted `-m` strings and heredoc syntax both fail in PowerShell for multiline commit messages. Use `git commit -F <tempfile>` instead: write the message to a temp file, commit with `-F`, delete the temp file. This pattern is reliable across sessions. (Hit twice before this was documented.)

## When this applies

- Every crontab edit on the davisglobe-vps-ash-1 Ubuntu host.
- Every multiline `git commit` issued from a PowerShell session.

## When this does NOT apply

- Bash sessions (heredocs work fine in bash).
- Single-line commit messages (quoted `-m` works for those).
