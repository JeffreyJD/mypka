# GL-011 - Persist `/watch` Output as a Deliverable, Not Just a Session-Log Mention

> **This Guideline is a general rule every agent reads whenever `/watch` (or any other third-party tool that produces substantive, non-persisted output) is used during a session.** It exists to bring tools myPKA doesn't own up to the same persistence standard as the ones it does — see "Why this rule exists" for the STORM/roast comparison that prompted it. SOPs and Workstreams `[[wikilink]]` here rather than restating the rule.

## The rule

**Any `/watch` invocation that produces a substantive answer gets written to a standalone file in `Deliverables/`, not just summarized in a session-log line — before the session ends. Not conditional on the user saying "remember this."** The plugin itself persists nothing: the downloaded video, extracted frames, audio, and transcript all live in a temp directory that gets deleted at session close, per the skill's own documented behavior. What Claude learned from watching is only as durable as the conversation transcript it happened in — and future sessions and specialists don't read old conversation transcripts, they read `Deliverables/`, session logs, journal entries, and PKM notes.

## Why a Deliverable, not just a session-log mention

Compare the three research/analysis-shaped tools in this vault:

- **STORM** (`SOP-018`) writes its full report to `Deliverables/YYYY-MM-DD-{topic}-storm-research.html` as a defined step in its own procedure — self-persisting, independent of the session log.
- **`/roast`** (`SOP-019`, amended 2026-07-09) now does the same: `Deliverables/YYYY-MM-DD-{idea-slug}-roast-verdict.md`, mandatory, mirroring STORM.
- **`/watch`** is a third-party marketplace plugin (`~/.claude/plugins/cache/claude-video/`) — myPKA cannot add a "write to Deliverables" step inside its own code. This Guideline is the necessary workaround: since the skill can't be edited, the *agent using it* carries the obligation instead.

A session-log mention (the pre-2026-07-09 version of this rule) is strictly weaker than a Deliverable: it's harder to find later (buried in prose inside a chronological log, not a standalone dated file), it doesn't get its own wikilink target other documents can point to, and it doesn't survive a close-session pass that summarizes loosely. Bringing `/watch` up to the same standard as STORM and roast means the same discoverability guarantees apply regardless of which tool produced the insight.

## What counts as "substantive"

Apply the same three-month test used for journal entries (per [[SOP-016-write-journal-entry]]): would a future session want to know this without re-watching the video? If yes, capture it. Skip capture for genuinely trivial exchanges (e.g., "what language is this video in" answered in one word) — this Guideline is about not losing real information, not padding every `/watch` call with a mandatory file.

## How to capture it

1. **Write `Deliverables/YYYY-MM-DD-{video-topic-slug}-watch-summary.md`** (plain markdown — no HTML template needed, same reasoning as roast's Phase 3). Contents: the video source (URL or path), duration, transcript source (captions vs. Whisper), and the curated summary of what mattered — key facts, figures, structure, notable claims, timestamps for anything the user would want to jump back to. Not a full transcript dump; a curated summary, same as the Nate Herk precedent's level of detail ([[2026-07-07-21-52_hawkeye_watch-first-use-nate-herk-claude-video]]) — just promoted from a session-log paragraph to its own file.
2. **Cross-link it** from the session log (`## What we did` / `## Cross-links`) — same two-way wiring as any other Deliverable.
3. **If the insight is durable and cross-session-relevant** (a technique, a pattern, something that should change future behavior, not just a fact) — also write a journal entry per [[SOP-016-write-journal-entry]], linking back to the Deliverable as evidence.
4. **Do this proactively, as a mid-session-insight trigger** (per root `AGENTS.md`'s Session-Log Triggers table) — don't wait for the session's natural end if losing it mid-session (crash, dropped connection, forgotten close-session trigger) would actually cost something.

## When this does NOT apply

- Trivial or single-fact `/watch` answers where nothing would be lost by not capturing them.
- The user explicitly says they don't want the content kept (rare, but respect it if stated).

## Why this rule exists

2026-07-09 — Jeff asked whether the team retains anything learned from `/watch`. Investigation confirmed the plugin persists nothing by design, and the one existing precedent (the Nate Herk video, 2026-07-07) was captured only because that session happened to end with a proper session log, not because of any automatic mechanism. The same question asked about STORM and `/roast` surfaced the real fix: STORM already self-persists via its own SOP; `/roast` didn't but could (and now does, per the same-day SOP-019 amendment); `/watch` can't be fixed at the source since it's third-party, so this Guideline raises its capture standard to match the other two as closely as the constraint allows.

## Updates to this Guideline

- 2026-07-09 — created (Hawkeye), at Jeff's explicit request, mirroring [[GL-010-commit-and-push-before-session-close]]'s pattern for a different class of easily-lost information.
- 2026-07-09 (same day) — upgraded from "session-log entry" to "standalone `Deliverables/` file" after Jeff asked for a consistent approach across STORM, `/roast`, and `/watch` built on STORM's own self-persisting pattern.
