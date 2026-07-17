---
# Identity
id: tsk-2026-07-11-001
title: "Formalize surfacing of non-CLEAN Daily Fidelity Check days into myPKA (currently manual, unenforced)"

# Ownership & priority
assignee: pierce
priority: 3

# Status (mirrors folder location)
status: open
blocked_reason: null
blocked_by: null

# Time
created: 2026-07-11T23:40:00Z
updated: 2026-07-11T23:40:00Z
due: null

# Provenance
created_by: pierce
source: session
parent: null

# Cross-references — REQUIRED, even if empty array. Seven slots. The act of filling these is the whole point.
linked_sops: ["SOP-022-deployment-fidelity-verification", "SOP-010-create-task", "SOP-012-close-task"]
linked_workstreams: []
linked_guidelines: []
linked_my_life: []
linked_session_logs: []
linked_journal_entries: []
linked_deliverables: ["2026-07-11-prophet-trader-deploy-daily-fidelity-check"]
tags: ["prophet-trader", "sop-022", "observability", "automation-followup"]
---

# Formalize surfacing of non-CLEAN Daily Fidelity Check days into myPKA (currently manual, unenforced)

**GitHub issue:** [#42](https://github.com/JeffreyJD/prophet-trader/issues/42)

## What this is

Ledger's PR #13 review flagged (LOW severity) that PR #13's own documentation says non-CLEAN Daily Fidelity Check days will be "surfaced into myPKA's `Deliverables/` by hand" (Pierce, manually) — but there is no enforcement mechanism. If Pierce misses a day, a real FAIL or NEEDS REVIEW verdict could sit in `data/fidelity_checks/YYYY-MM-DD.{json,md}` on the VPS indefinitely without ever reaching myPKA, silently defeating the point of the check. This is the same class of gap SOP-022 exists to catch (an observability gap with no verifiable success signal), just one level up — applied to the fidelity checker's own output.

The [[prophet-trader-weekly-strategy-report]] cloud routine already has a working precedent for pushing its own output into durable storage as part of its own run (not a human remembering to do it after the fact) — that pattern is the likely template, but this needs its own design pass, not a rushed copy.

## Context one click away

- Procedure: [[SOP-022-deployment-fidelity-verification]]
- Working artifacts:
  - [[2026-07-11-prophet-trader-deploy-daily-fidelity-check]]
- GitHub issue: [#42](https://github.com/JeffreyJD/prophet-trader/issues/42)

## Success criteria

- [ ] Decide the mechanism: either (a) automate the push — e.g. `run_fidelity_check.sh` or `daily_fidelity_check.py` itself writes/pushes a `Deliverables/YYYY-MM-DD-daily-fidelity-check.md`-equivalent artifact into myPKA (or a queue/inbox Radar or Hawkeye can pick up) whenever the verdict is not CLEAN, mirroring the Weekly Strategy Report's own-output-push pattern; or (b) keep it manual but add an explicit enforcement backstop (e.g. Ledger's recurring Environment Drift Audit, or a standing weekly Hawkeye check, specifically verifies no un-surfaced non-CLEAN day exists).
- [ ] If (a): build it, test it (including a deliberately non-CLEAN synthetic run), deploy, verify live.
- [ ] If (b): write the enforcement step into the relevant SOP/Workstream so it's not just a bare mention, and confirm it's actually being run (not aspirational).
- [ ] Either way, closed out with Ledger's SOP-022 sign-off given this touches the fidelity check's own output path.

## Updates

- 2026-07-11 23:40 (pierce) — created per Ledger's LOW finding on PR #13; not automated tonight to avoid rushing a design decision alongside tonight's merge/deploy/credential work. VPS has no path to the Google Drive myPKA folder (confirmed via `rclone listremotes` — only `b2:` configured), so option (a) will need a real transport decision (webhook, email, B2 + Klinger-side pull, or similar), not just "write a file."
- 2026-07-17 (pierce) — filed as GitHub issue [#42](https://github.com/JeffreyJD/prophet-trader/issues/42) per Jeff's consolidated-backlog directive; this is build work (automation gap needing a fix), qualifies as backlog-worthy under the bugs/enhancements-only backlog scope.

## Outcome

_(filled when status flips to done — see SOP-012-close-task)_
