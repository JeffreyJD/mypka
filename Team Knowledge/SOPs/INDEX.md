# SOPs - Index

**SOPs are agent skills.** Each SOP is a canonical procedure — a step-by-step recipe for one job. They are LLM-agnostic and reusable across agents: an SOP has a **default owner** (the specialist who runs it most often), but any agent can invoke an SOP when they need its procedure. Think of SOPs the way Claude skills work — discrete, named, callable.

Filename pattern: `SOP-NNN-<title>.md`. See [[GL-001-file-naming-conventions]] for slug rules. Numbering follows authorship order, not topic — gaps are intentional and reserve slots for future agents.

## Active SOPs

| SOP | Title | Default owner | Description |
|---|---|---|---|
| SOP-001 | [[SOP-001-how-to-add-a-new-specialist]] | Potter | Step-by-step procedure to draft and onboard a new team specialist. References [[GL-001-file-naming-conventions]]. |
| SOP-002 | [[SOP-002-convert-mypka-to-sqlite]] | Margaret (run by the user via paste-into-LLM prompt) | Generate a SQLite mirror of your myPKA on demand. Markdown stays canonical; SQLite is a derived performance layer. Body is a paste-into-LLM prompt. |
| SOP-003 | [[SOP-003-felix-build-a-component]] | Felix | Build a UI component end-to-end on the team's design system. (App Developer Pack — installed v4.1.1) |
| SOP-004 | [[SOP-004-vex-security-audit]] | Vex | Run an application-layer security audit / "safe to ship" review. (App Developer Pack — installed v4.1.1) |
| SOP-005 | [[SOP-005-vera-quality-gate]] | Vera | Visual/UI QA quality gate — design-system + WCAG 2.2 AA + responsive sign-off. (App Developer Pack — installed v4.1.1) |
| SOP-006 | [[SOP-006-author-a-design-system]] | Iris | Author or extend [[GL-003-design-system]], the brand/visual SSOT. (Designer Pack — installed v4.1.1) |
| SOP-007 | [[SOP-007-audit-content-for-design-system-compliance]] | Iris | Audit a deliverable against GL-003 and report violations. (Designer Pack — installed v4.1.1) |
| SOP-008 | [[SOP-008-build-an-infographic]] | Charta | Build an infographic / structured visual deliverable (HTML/CSS layout). (Designer Pack — installed v4.1.1) |
| SOP-009 | [[SOP-009-generate-a-styled-image]] | Pixel | Generate or stylize an image to the design system; Klinger wires the connection half if needed. (Designer Pack — installed v4.1.1) |
| SOP-010 | [[SOP-010-create-task]] | Hawkeye | Create a task: duplicate check, ID generation (retry-on-exists loop satisfies [[GL-016-numbered-artifact-collision-check]] Check 1), seven-slot cross-reference walk, file write to `tasks/open/`, index rebuild. References [[GL-004-task-resource-linking]], [[GL-001-file-naming-conventions]], [[GL-016-numbered-artifact-collision-check]]. |
| SOP-011 | [[SOP-011-claim-task]] | Assignee | Claim a task (§A), record a block (§B), or record an unblock (§C): pre-flight cross-reference read, move from `tasks/open/` to `tasks/in-progress/`, frontmatter update, index rebuild. References [[GL-004-task-resource-linking]], [[SOP-017-read-own-journal]]. |
| SOP-012 | [[SOP-012-close-task]] | Hawkeye / Assignee | Close a task done (§A) or cancelled (§B): verify success criteria, fill Outcome, sharing-check `linked_deliverables`, archive un-shared deliverables, move task file. References [[GL-004-task-resource-linking]], [[SOP-016-write-journal-entry]]. |
| SOP-013 | [[SOP-013-rebuild-task-index]] | Hawkeye | Regenerate `tasks/INDEX.md` from the live state of `open/`, `in-progress/`, `done/`, `cancelled/`. awk-based frontmatter parser, atomic write, status-vs-folder drift correction. Called by every task-touching SOP. |
| SOP-014 | [[SOP-014-list-open-tasks]] | Hawkeye | List open and in-progress tasks: §A fast path (read INDEX.md), §B authoritative path (grep the folders directly). Includes Hawkeye and specialist session-boot routines and blocked-task surfacing. References [[SOP-013-rebuild-task-index]]. |
| SOP-015 | [[SOP-015-write-session-log]] | Hawkeye | Write a session log entry in `session-logs/YYYY/MM/`. Filename convention, frontmatter schema, recommended body sections (What I shipped, Tasks touched, Root cause, Voice notes), cross-reference wiring. References [[SOP-016-write-journal-entry]], [[SOP-010-create-task]]. |
| SOP-016 | [[SOP-016-write-journal-entry]] | Any specialist | Write a durable specialist journal entry in `Team/<Name>/journal/`. Trigger test, topic slug, body sections (Context, What I learned, When applies, When NOT, Evidence), cross-link back to session log and task. References [[SOP-017-read-own-journal]]. |
| SOP-017 | [[SOP-017-read-own-journal]] | Any specialist | Read your own journal before starting task work: four steps (task `linked_journal_entries`, 10 most-recent entries, tag match, topic match). Carry priors visibly into the task's Updates log. References [[SOP-016-write-journal-entry]]. |
| SOP-018 | [[SOP-018-storm-research]] | B.J. | Turn one topic into a verified multi-perspective HTML briefing. Five expert lenses, contradiction mapping, adversarial peer review, citation verification. Output: `Deliverables/YYYY-MM-DD-{topic-slug}-storm-research.html`. Template: [[storm-report-template.html]]. |
| SOP-019 | [[SOP-019-roast-an-idea]] | Hawkeye | Pressure-test an idea before building it. Convenes a 5-persona adversarial council (Contrarian, Expansionist, Logician, Researcher, Buyer) in parallel, then Hawkeye-as-Judge delivers one GO / RESHAPE / KILL verdict plus the cheapest 48-hour de-risk test. Triggered by `/roast`. |
| SOP-020 | [[SOP-020-obd-scan-analysis]] | Rizzo | Analyze an OBD scan session CSV from the obd_scanner Python logger. Five phases: locate and identify the scan file (Phase 0, includes km/h speed unit guardrail), read baseline conditions (Phase 1), identify events — MIL transitions, LTFT load pattern, STFT spikes, coolant trend (Phase 2), compare against prior sessions (Phase 3), write back to vehicle file + task + journal (Phase 4). Guardrails: speed is km/h; DTCs require separate mode $03 read; chassis codes require multi-module scanner; LTFT is load-cell specific. |
| SOP-021 | [[SOP-021-photo-intake-and-sidecar-cataloging]] | Margaret | Take any new image from arrival to fully cataloged: GL-001 naming (EXIF date priority), `mypka-photos rename` dry-run gate, `scan` sidecar generation, metadata fill (people wikilinks, photo_type vocab), ai_pending/confirmed state machine. Guardrails: never rename after sidecar exists; stems unique across extensions; GL-006 sweep safety; bake EXIF orientation. Tool-agnostic note: CLI optional, GL-002 schema is the contract. |
| SOP-022 | [[SOP-022-deployment-fidelity-verification]] | Ledger | Verify deployed/scheduled/configured reality matches validated intent. Four procedures: pre-deploy Fidelity Check (baseline diff, declared-dependency-to-live-path check, scheduling collision, observability signal), Decommission Verification (old system checked directly, not assumed off), recurring Environment Drift Audit (registry vs live state, minimum monthly), Data Provenance Check (dataset reproducibility before it feeds a gate decision). References [[GL-007-verify-before-acting-on-a-finding]], [[GL-008-read-registry-before-creating-new-state]]. |

*Reserved (genuinely open for future agents):* SOP-022 onward. Do not back-fill below SOP-022 without coordinating across the team.

## How to add a new SOP

1. Pick the next unused number (`SOP-NNN`) — by authorship order, not topic. Don't reuse reserved numbers. Run the collision check in [[GL-016-numbered-artifact-collision-check]] immediately before writing, and again as part of the batch check before committing — especially if another agent may be minting an SOP in the same window.
2. Filename: `SOP-NNN-<kebab-case-title>.md`.
3. Header includes the default owner, status, triggers, references, and an explicit "Reusable by any agent" note — the SOP is a skill, not 1:1 ownership.
4. Reference [[GL-001-file-naming-conventions]] and any other Guideline instead of duplicating its content.
5. Add a row to this index.

## LLM-agnostic standard (applies to all SOPs)

**Every SOP must be LLM-agnostic by default.** The procedure — steps, prompts, output format — must be written in plain language any capable LLM can follow. Where Claude Code-specific tools are used (`Agent`, `Write`, `Read`, `Bash`, etc.), add a **two-path execution note** at the point of use:

- **In Claude Code:** [tool-specific path — parallel agents, file writes, etc.]
- **In any other LLM (Cursor, Gemini CLI, plain chat):** [equivalent sequential or manual path]

The slash command (`.claude/commands/`) is the Claude Code entry point. The SOP is the canonical procedure. Other LLMs invoke the SOP via natural language; they never see the command file.

## Skill-to-SOP conversion pattern

When converting an existing skill or command file to a proper SOP:
1. Write the SOP first — canonical procedure, LLM-agnostic, two-path note where needed.
2. Slim the command file down to a thin entry point that references the SOP by wikilink.
3. The command file holds only: frontmatter, portable trigger phrases, a one-paragraph "what this does," and a single "Execute [[SOP-NNN]] now" instruction.
4. The SOP is the source of truth. The command file is the doorbell.
