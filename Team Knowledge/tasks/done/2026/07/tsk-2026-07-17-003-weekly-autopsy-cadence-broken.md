---
# Identity
id: tsk-2026-07-17-003
title: "Weekly Autopsy cadence broken — IPS-committed weekly cadence not being honored"

# Ownership & priority
assignee: blake
priority: 2

# Status (mirrors folder location)
status: done
blocked_reason: null
blocked_by: null

# Time
created: 2026-07-17T09:50:00Z
updated: 2026-07-17T15:00:00Z
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
linked_deliverables: ["2026-07-08-strategy-autopsy", "2026-07-12-strategy-autopsy"]

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

- [x] Confirm the actual cadence gap: which Sundays since 2026-07-08 have and have not had a narrative autopsy produced. — Only 2026-07-12 was gapped (2026-07-08 was the catch-up autopsy itself; 2026-07-19 hasn't happened yet). Confirmed via VPS log + healthchecks.io cross-check that the *underlying automated data run* fired clean on 07-12 (`autopsy-2026-07-12.log`, exit 0, healthchecks `last_ping` matching to the second) — the miss was specifically in the human-facing narrative Deliverable, not the trading system or its lower-level automation.
- [x] Produce the missed/overdue autopsy(ies) now, current as of this task's close. — [[2026-07-12-strategy-autopsy]] written, backfilled from the verified VPS log + healthchecks.io evidence. Both strategies: Watch (regime-driven quiet per IPS §5.3/§5.4, not model failure — zero proposals both strategies, consistent with documented `trending-bull` scarcity and `event-driven` gating).
- [x] Decide and implement an enforcement mechanism so this doesn't depend on human memory. — Already decided and implemented by Pierce under a separate, earlier task ([[tsk-2026-07-13-001-weekly-strategy-report-cloud-routine-network-and-gitignore-blockers]], closed 2026-07-16): the original mechanism (an Anthropic cloud `RemoteTrigger` routine, first fire 2026-07-12) is the thing that failed — it had no network egress to B2/healthchecks.io and no git write access, and `PKM/`/`Deliverables/` were never in its bare clone to begin with. Replaced with a VPS-resident script (`scripts/weekly_strategy_report.py`) chained after the weekly autopsy in the same cron line (`0 10 * * 0 run_weekly_autopsy.sh && run_weekly_strategy_report.sh`, deployed 2026-07-16), with its own dedicated healthchecks.io dead-man's switch (`HEALTHCHECKS_WEEKLY_REPORT_URL`). This task's root-cause work independently confirms that mechanism is the right fix — no additional design work needed here.
- [x] Document the chosen mechanism somewhere durable. — Already documented at [[PKM/Environment/Services/prophet-trader-weekly-strategy-report]] and the build ADR referenced there. This task's backfilled autopsy ([[2026-07-12-strategy-autopsy]]) adds the narrative-facing explanation and cross-links back.

## Diagnosis (Blake, 2026-07-17)

**Root cause: code/infrastructure bug (architecture-choice failure), not a process gap in the sense of "nobody remembered."** The team *did* build automation specifically to close this exact gap (right after the 2026-07-08 catch-up autopsy flagged it) — a cloud `RemoteTrigger` routine, first scheduled to fire 2026-07-12 18:00 ET. That routine could never have worked: no network egress to Backblaze B2 (where the data lives) or healthchecks.io (so it couldn't even report its own failure), no git write access to push a report, and `PKM/`/`Documents/`/`Deliverables/` are gitignored and were never present in its bare clone regardless. This was discovered 2026-07-13 by pulling the routine's own session transcript (the only way to see cloud-routine run logs).

**07-12 was a real failure, not a benign skip.** The lower-level automated artifact (`scripts/weekly_autopsy.py`, writing `data/autopsies/2026-07-12.*`) ran perfectly on schedule — confirmed independently via VPS log (`2026-07-12T14:00:01Z` start, exit 0) and healthchecks.io (`last_ping` matching to the second). Only the narrative Deliverable — the human-facing document this task is about — failed to materialize, because the mechanism assigned to produce it was structurally broken from the day it was built.

**Chaining timing, per the task's specific question:** the `run_weekly_autopsy.sh && run_weekly_strategy_report.sh` cron chain landed 2026-07-16 — four days *after* the 2026-07-12 gap and three days after the 07-13 root-cause discovery. It is the fix that resulted from diagnosing this gap, not something that predates or caused it. First live fire of the new chained pipeline is 2026-07-19, tracked separately at [[tsk-2026-07-16-001-confirm-weekly-strategy-report-first-live-fire]] — not yet confirmed clean as of this diagnosis.

**Process-layer finding, worth carrying forward even though the infra fix already shipped:** the cloud routine was never dry-run before its first live scheduled dependency. A manual on-demand trigger before 07-12 would have surfaced all three blockers days earlier, for free. Recommend this becomes a standing rule for any future automation intended to replace a human-memory-dependent cadence: one confirmed manual dry run producing real output, before the first scheduled fire is trusted. Not proposing an IPS amendment for this — it's an engineering/deployment discipline item, not an investment-policy one; routing the recommendation to Pierce/Hawkeye rather than adjudicating it here.

**Recommend this task close** once GitHub issue #45 is updated with this diagnosis (I do not have GitHub write access from this seat — routing that step to Hawkeye/Pierce).

## Updates

- 2026-07-17 09:50 (pierce) — created while building the consolidated GitHub Issues backlog per Jeff's directive; this was an untracked gap identified from Blake's own 2026-07-08 autopsy finding.
- 2026-07-17 (pierce) — filed as GitHub issue [#45](https://github.com/JeffreyJD/prophet-trader/issues/45); this is a real defect (a committed automation cadence not running), not a verification activity, so it qualifies as backlog-worthy under the bugs/enhancements-only backlog scope Jeff clarified.
- 2026-07-17 (blake) — root-caused as a code/infra architecture bug (cloud routine had no egress/git-write/gitignored-file access), not a memory-dependence process gap in the narrow sense — though the enforcement mechanism already shipped (2026-07-16, separate task) is exactly the right structural fix. Backfilled the missing 2026-07-12 narrative autopsy at [[2026-07-12-strategy-autopsy]] (Watch/Watch, regime-driven quiet, no strategy action). All four success criteria satisfied. GitHub issue #45 still needs updating with this diagnosis — routed to Hawkeye/Pierce, no GitHub write access from this seat.
- 2026-07-17 15:00 (pierce) — reviewed Blake's diagnosis, confirmed sound (all four success criteria met, root cause independently traceable to the same cloud-routine egress/git-write failure already fixed under [[tsk-2026-07-13-001-weekly-strategy-report-cloud-routine-network-and-gitignore-blockers]]). Closed as done. Updated + closed GitHub issue #45 with the full diagnosis.

## Outcome

What shipped: root-cause diagnosis of the 2026-07-12 Weekly Autopsy narrative gap (Blake), confirming it was a code/infrastructure failure — the cloud `RemoteTrigger` routine had no network egress to B2/healthchecks.io and no git write access, and `PKM/`/`Deliverables/` were never present in its bare clone. The underlying automated data run (`scripts/weekly_autopsy.py`) fired clean on 2026-07-12 (VPS log + healthchecks.io `last_ping` both confirm) — only the human-facing narrative Deliverable was missing. The fix is already deployed: the VPS-resident cron chain (`run_weekly_autopsy.sh && run_weekly_strategy_report.sh`, live 2026-07-16) shipped under a separate, earlier task and independently addresses this exact failure mode. The missing 2026-07-12 narrative autopsy was backfilled at `Deliverables/2026-07-12-strategy-autopsy.md`.

Where it lives: [[2026-07-12-strategy-autopsy]] (Deliverable, on disk — see archive note below re: git tracking). GitHub issue [#45](https://github.com/JeffreyJD/prophet-trader/issues/45), closed with the full diagnosis as a comment. This task file.

Follow-ups: [[tsk-2026-07-16-001-confirm-weekly-strategy-report-first-live-fire]] carries the still-open first-live-fire verification of the chained cron (2026-07-19) — not duplicated here. Blake's process-layer recommendation (dry-run any automation before its first scheduled dependency) was noted but not spun into a new task; it's a general engineering-discipline point, not a scoped action item.

Lessons: none new beyond what's already captured under [[tsk-2026-07-13-001-weekly-strategy-report-cloud-routine-network-and-gitignore-blockers]]'s closing journal entry — this task's diagnosis independently confirms that fix was the right one, it doesn't surface a new insight.

Archived deliverables:
  - `2026-07-08-strategy-autopsy` — archive deferred, still referenced by [[tsk-2026-07-17-005-event-driven-regime-csm-formal-evaluation]] and [[tsk-2026-07-17-009-bj-base-rate-research-trending-bull-event-blackout]] (both open).
  - `2026-07-12-strategy-autopsy` — not archived to `Deliverables/_archive/`; `Deliverables/` is intentionally excluded from this repo's git tracking (`.gitignore` line 13: "Personal knowledge — stays local + Google Drive only"), so the file lives on disk / syncs via Google Drive only. No other open task references it, so if a future close needs to physically move it into `_archive/`, a plain filesystem move (not `git mv`) applies.
