---
# Identity
id: tsk-2026-07-17-004
title: "src/api/server.py (Observatory dashboard) has zero test coverage"

# Ownership & priority
assignee: pierce
priority: 3

# Status (mirrors folder location)
status: open
blocked_reason: null
blocked_by: null

# Time
created: 2026-07-17T09:52:00Z
updated: 2026-07-17T09:52:00Z
due: null

# Provenance
created_by: pierce
source: session
parent: null

# Cross-references — REQUIRED, even if empty array. Seven slots. The act of filling these is the whole point.
linked_sops: ["SOP-010-create-task", "SOP-012-close-task"]
linked_workstreams: []
linked_guidelines: []
linked_my_life: []
linked_session_logs: []
linked_journal_entries: []
linked_deliverables: []

# Tagging
tags: ["prophet-trader", "tech-debt", "test-coverage", "observatory-dashboard"]
---

# src/api/server.py (Observatory dashboard) has zero test coverage

**GitHub issue:** [#46](https://github.com/JeffreyJD/prophet-trader/issues/46)

## What this is

`src/api/server.py` is the Observatory dashboard — a single-file FastAPI server (port 8000/8080) exposing five tiles: phase state, today's decisions, reconciliation, demotion triggers, and recent activity, all read directly from the same files the daily routine writes. It has been flagged twice in prior review passes as having no test coverage, but never actually tracked as a standing item — confirmed via repo search: no file under `tests/` imports or exercises `src.api.server` or `src.api`.

Because it only reads existing data files (no writes, no trading-path risk), this is tech-debt rather than a live-risk bug, but a dashboard silently serving stale or malformed data with no test to catch a regression is exactly the kind of "should be off/should be right" claim CLAUDE.md's operating discipline says not to trust without verification.

## Context one click away
- Code: `src/api/server.py` (FastAPI app, five endpoint handlers plus embedded HTML dashboard)
- Working artifacts: none yet
- GitHub issue: [#46](https://github.com/JeffreyJD/prophet-trader/issues/46)

## Success criteria

- [ ] Add `tests/test_server.py` (or equivalent) using FastAPI's `TestClient`/`httpx` covering each of the five tile endpoints: happy path (valid data files present) and missing/malformed-file fallback path (each helper already has defensive `try/except` — confirm the fallback behavior is actually correct, not just present).
- [ ] Cover `_read_json()` and `_latest_file()` helpers directly for edge cases (missing directory, corrupt JSON, empty directory).
- [ ] CI green with the new tests included in the standard suite run.
- [ ] No behavior change to `server.py` itself unless a test uncovers a real bug — this task is coverage-first, fix-if-found second.

## Updates

- 2026-07-17 09:52 (pierce) — created while building the consolidated GitHub Issues backlog per Jeff's directive; confirmed via grep that no test file references `src.api.server` before filing.
- 2026-07-17 (pierce) — filed as GitHub issue [#46](https://github.com/JeffreyJD/prophet-trader/issues/46); build work (add tests), qualifies as backlog-worthy enhancement under the bugs/enhancements-only backlog scope.

## Outcome

_(filled when status flips to done — see SOP-012-close-task)_
