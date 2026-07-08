---
agent_id: hawkeye
session_id: 2026-07-07-watch-first-use-nate-herk-claude-video
timestamp: 2026-07-08T01:52:00Z
type: end-of-session
linked_sops: []
linked_workstreams: []
linked_guidelines: []
linked_tasks: []
linked_journal_entries: []
---

# Session: first real use of /watch — Nate Herk "Claude Millionaires" video

## Context

Jeff asked to watch a YouTube video (https://www.youtube.com/watch?v=pbrln2TVeh4) using the `/watch` plugin configured last session. First production run of the plugin end-to-end.

## What we did

- **Hawkeye** ran the `/watch` pipeline on Nate Herk's "How Claude is Creating a New Generation of Millionaires" (9:36): yt-dlp download, 80 frames at 512px, transcript pulled from native captions (no Whisper spend needed).
- Fixed the `~/.config/watch/.env` permissions warning flagged at session start (`chmod 600`).
- Delivered a full timestamped summary: the Vulcan government-software startup story, Anthropic's $65B raise / $47B run rate, the four Claude Code differentiators, the YC adoption shift, and Herk's four-step starter playbook.

## Decisions made

- None — informational session, no directional changes.

## Insights

- The `/watch` pipeline works end-to-end on first real use: captions path avoided any Whisper API cost, and the full run (download → frames → transcript → analysis) completed with no manual intervention. The Groq key remains untested until a video without captions comes along.
- The video's advocated workflow (roast council with Go/Reshape/Kill verdicts, persistent memory, verification discipline, an "AI operating system") is functionally what myPKA already implements — external validation of the scaffold's design, and a possible content angle for Sydney (Jeff is living what this creator sells to 800k+ subscribers).

## Realignments

- None.

## Open threads

- Groq Whisper fallback still unexercised — first captionless video will be the real test (carried from [[2026-07-07-21-41_hawkeye_watch-plugin-setup-groq-whisper]]).
- Optional: Sydney content angle on "I already run the AI operating system YouTubers are selling" — only if Jeff wants it.

## Next steps

- None required. Watch working directory in scratchpad was cleaned up at close.

## Cross-links

- [[2026-07-07-21-41_hawkeye_watch-plugin-setup-groq-whisper]] — the setup session this run validated.
