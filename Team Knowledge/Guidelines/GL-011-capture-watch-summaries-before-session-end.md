# GL-011 - Capture `/watch` Summaries Before Session End

> **This Guideline is a general rule every agent reads whenever `/watch` (or any other tool that produces substantive, non-persisted output) is used during a session.** SOPs and Workstreams `[[wikilink]]` here rather than restating the rule.

## The rule

**Any `/watch` invocation that produces a substantive answer gets captured into myPKA — a session-log entry or a journal entry — before the session ends. Not conditional on the user saying "remember this."** The plugin itself persists nothing: the downloaded video, extracted frames, audio, and transcript all live in a temp directory that gets deleted at session close, per the skill's own documented behavior. What Claude learned from watching is only as durable as the conversation transcript it happened in — and future sessions and specialists don't read old conversation transcripts, they read session logs, journal entries, and PKM notes. If nothing gets written down, the video might as well never have been watched, from the team's perspective.

## What counts as "substantive"

Apply the same three-month test used for journal entries (per [[SOP-016-write-journal-entry]]): would a future session want to know this without re-watching the video? If yes, capture it. Skip capture for genuinely trivial exchanges (e.g., "what language is this video in" answered in one word) — this Guideline is about not losing real information, not padding every `/watch` call with a mandatory note.

## How to capture it

1. **Default: a session-log entry**, following the shape already established (see the Nate Herk video precedent, [[2026-07-07-21-52_hawkeye_watch-first-use-nate-herk-claude-video]]) — a curated summary of what mattered (key facts, figures, structure, notable claims), not a full transcript dump.
2. **If the insight is durable and cross-session-relevant** (a technique, a pattern, something that should change future behavior) — also write a journal entry per [[SOP-016-write-journal-entry]], not just a session-log line.
3. **Do this proactively, as a mid-session-insight trigger** (per root `AGENTS.md`'s Session-Log Triggers table) — don't wait for the session's natural end if the video's content is substantial enough that losing it mid-session (crash, dropped connection, forgotten close-session trigger) would actually cost something.

## When this does NOT apply

- Trivial or single-fact `/watch` answers where nothing would be lost by not capturing them.
- The user explicitly says they don't want the content kept (rare, but respect it if stated).

## Why this rule exists

2026-07-09 — Jeff asked whether the team retains anything learned from `/watch`. Investigation confirmed: the plugin persists nothing by design, and the one existing precedent (the Nate Herk video, 2026-07-07) was captured only because that session happened to end with a proper session log, not because of any automatic mechanism. Jeff asked for this to be formalized the same way git hygiene was (see [[GL-010-commit-and-push-before-session-close]]) rather than left to depend on whether a given session's close happened to include it.

## Updates to this Guideline

- 2026-07-09 — created (Hawkeye), at Jeff's explicit request, mirroring [[GL-010-commit-and-push-before-session-close]]'s pattern for a different class of easily-lost information.
