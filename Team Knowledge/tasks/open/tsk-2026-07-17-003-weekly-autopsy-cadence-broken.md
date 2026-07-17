---
# Identity
id: tsk-2026-07-17-003
title: "Weekly Autopsy cadence broken — IPS-committed weekly cadence not being honored"

# Ownership & priority
assignee: blake
priority: 2

# Status (mirrors folder location)
status: open
blocked_reason: null
blocked_by: null

# Time
created: 2026-07-17T09:50:00Z
updated: 2026-07-17T09:50:00Z
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
linked_deliverables: ["2026-07-08-strategy-autopsy"]

# Tagging
tags: ["prophet-trader", "weekly-autopsy", "process-gap", "ips-compliance"]
---

# Weekly Autopsy cadence broken — IPS-committed weekly cadence not being honored

**GitHub issue:** [#45](https://github.com/JeffreyJD/prophet-trader/issues/45)

## What this is

Blake's own first autopsy ([[2026-07-08-strategy-autopsy]]) opened with: "This is the first autopsy on record. The IPS commits to a weekly cadence; none had been produced before today." That gap was itself flagged as a process finding, with the stated expectation that "going forward, expect this cadence to actually run." As of this task's creation (2026-07-17), no second narrative Weekly Strategy Autopsy Deliverable has been produced — the next Sunday after 2026-07-08 (2026-07-12) came and went with no follow-up autopsy filed in `Deliverables/`. This is distinct from `scripts/weekly_autopsy.py`'s automated per-strategy JSON/MD output in `data/autopsies/` (a different, lower-level artifact) — this task tracks the human-facing, Blake-authored narrative autopsy the IPS actually commits to.

This is a durability problem, not a one-off miss: the IPS makes a standing commitment, and the mechanism enforcing it is "someone remembers to run it," which already failed once before this task existed and has now failed again.

## Context one click away

- Working artifacts: [[2026-07-08-strategy-autopsy]] — the one autopsy on record, and the finding that named this exact gap
- Service: [[prophet-trader]]
- CIO owner: Blake
- GitHub issue: [#45](https://github.com/JeffreyJD/prophet-trader/issues/45)

## Success criteria

- [ ] Confirm the actual cadence gap: which Sundays since 2026-07-08 have and have not had a narrative autopsy produced.
- [ ] Produce the missed/overdue autopsy(ies) now, current as of this task's close.
- [ ] Decide and implement an enforcement mechanism so this doesn't depend on human memory — e.g., a standing calendar reminder Hawkeye checks, a healthchecks.io ping tied to the autopsy's own commit, or folding it into the existing weekly cron chain (Weekly Autopsy script → Weekly Strategy Report) as an explicit "narrative autopsy also due" checkpoint.
- [ ] Document the chosen mechanism somewhere durable (SOP, IPS amendment, or Environment Service note) so it's not just a one-time fix.

## Updates

- 2026-07-17 09:50 (pierce) — created while building the consolidated GitHub Issues backlog per Jeff's directive; this was an untracked gap identified from Blake's own 2026-07-08 autopsy finding.
- 2026-07-17 (pierce) — filed as GitHub issue [#45](https://github.com/JeffreyJD/prophet-trader/issues/45); this is a real defect (a committed automation cadence not running), not a verification activity, so it qualifies as backlog-worthy under the bugs/enhancements-only backlog scope Jeff clarified.

## Outcome

_(filled when status flips to done — see SOP-012-close-task)_
