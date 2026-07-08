---
agent_id: hawkeye
session_id: 2026-07-07-watch-plugin-setup-groq-whisper
timestamp: 2026-07-08T01:41:29Z
type: end-of-session
linked_sops: []
linked_workstreams: []
linked_guidelines:
  - GL-002-frontmatter-conventions
linked_tasks: []
linked_journal_entries: []
---

# Session: /watch plugin setup — Groq Whisper key + dependencies

## Context

Jeff asked where the `/watch` video plugin (claude-video 0.1.2) expects its Groq API key, then had the full dependency setup executed and verified with a live video run. Vault was clean at session start; no vault content work was planned.

## What we did

- **Hawkeye** located the key location by reading the plugin source: `~/.config/watch/.env`, read via the plugin's `setup.py`/`whisper.py`.
- **Hawkeye** scaffolded `C:\Users\jeff\.config\watch\.env` with the plugin's own template; Jeff pasted his Groq key into it directly.
- **Hawkeye** installed ffmpeg 8.1.2 and yt-dlp 2026.07.04 via winget (the plugin's setup script only prints install commands on Windows — it doesn't auto-install). yt-dlp pulled Deno 2.9.1 and its own ffmpeg build as winget dependencies.
- **Hawkeye** verified end-to-end with a live `/watch` run on a YouTube URL (Jeff's test video was, naturally, a rickroll): download, 80 frames extracted, native captions pulled — Whisper/Groq not needed for captioned videos.
- **Hawkeye** verified the `.env` NTFS ACLs with `icacls` (jeff/SYSTEM/Administrators only) — the setup script's "readable by other users" warning is a POSIX-bits false positive on Windows.
- **Hawkeye** registered the new Groq account in the Environment registry ([[groq]]) and updated [[PKM/Environment/INDEX]] and persistent memory.

## Decisions made

- **Groq over OpenAI for Whisper fallback** — cheaper and faster for `whisper-large-v3`; the OpenAI key slot in the `.env` stays empty.
- **Key storage location** — `C:\Users\jeff\.config\watch\.env`, outside the synced vault, consistent with GL-002 rule 7 (registry entry holds the pointer, never the value).

## Insights

- **yt-dlp on Windows needs a JS runtime (Deno) on PATH for YouTube.** Without it, signature solving fails and downloads die with "Requested format is not available / only images available." Deno ships as a winget dependency of yt-dlp but must be reachable on PATH.
- **winget PATH changes don't reach running processes.** They land in the registry; an already-running Claude Code session keeps its stale PATH. Fix: restart Claude Code, or prepend `%LOCALAPPDATA%\Microsoft\WinGet\Packages\<pkg>` dirs manually within the session.
- **The plugin's chmod/permissions warning is noise on Windows** — POSIX mode bits don't reflect NTFS ACLs; verify with `icacls` instead.

## Realignments

None — no corrections or pushback this session.

## Open threads

- **Claude Code restart pending** — Jeff is restarting after this log so the new PATH takes effect; `/watch` then works with no workarounds. Nothing else carries over.
- Groq account email not yet recorded in [[groq]] (flagged in that file's Open questions).

## Next steps

- Next `/watch` run after restart should just work; no action needed.
- Optionally test the Whisper path someday with a captionless video to confirm the Groq key round-trips.

## Cross-links

- Prior session: [[2026-07-07-19-15_hawkeye_windlass-storm-and-subaru-test-mode-resolution]]
