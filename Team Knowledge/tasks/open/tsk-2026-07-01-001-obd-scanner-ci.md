---
# Identity
id: tsk-2026-07-01-001
title: "Add GitHub Actions CI to obd-scanner"

# Ownership & priority
assignee: pierce
priority: 3

# Status (mirrors folder location)
status: open
blocked_reason: null
blocked_by: null

# Time
created: 2026-07-01T00:00:00Z
updated: 2026-07-01T00:00:00Z
due: null

# Provenance
created_by: hawkeye
source: session
parent: null

linked_sops: []
linked_workstreams: []
linked_guidelines: []
linked_my_life: ["obd-scanner"]
linked_session_logs: []
linked_journal_entries: []
linked_deliverables: []

tags: ["python", "ci", "github-actions", "obd"]
---

# Add GitHub Actions CI to obd-scanner

## What this is

Wire up GitHub Actions to the obd-scanner repo so that `pytest` runs automatically on every push to `dev` and on every PR to `main`. Prophet Trader already has this pattern — follow the same structure.

## Context one click away

- My Life project: [[obd-scanner]]

## Success criteria

- `.github/workflows/ci.yml` exists in the repo
- `pytest tests/` runs clean on push to `dev` and PRs targeting `main`
- Follows the same CI pattern as Prophet Trader's workflow

## Updates

- 2026-07-01 00:00 (hawkeye) — created; surfaced by Pierce after VIN auto-detection implementation (28 tests exist, no runner yet)

## Outcome

_(filled when status flips to done — see SOP-012-close-task)_
