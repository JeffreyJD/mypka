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
| SOP-010 | [[SOP-010-create-task]] | Hawkeye | Create a task: duplicate check, ID generation, seven-slot cross-reference walk, file write to `tasks/open/`, index rebuild. References [[GL-004-task-resource-linking]], [[GL-001-file-naming-conventions]]. |
| SOP-011 | [[SOP-011-claim-task]] | Assignee | Claim a task (§A), record a block (§B), or record an unblock (§C): pre-flight cross-reference read, move from `tasks/open/` to `tasks/in-progress/`, frontmatter update, index rebuild. References [[GL-004-task-resource-linking]], [[SOP-017-read-own-journal]]. |
| SOP-012 | [[SOP-012-close-task]] | Hawkeye / Assignee | Close a task done (§A) or cancelled (§B): verify success criteria, fill Outcome, sharing-check `linked_deliverables`, archive un-shared deliverables, move task file. References [[GL-004-task-resource-linking]], [[SOP-016-write-journal-entry]]. |
| SOP-013 | [[SOP-013-rebuild-task-index]] | Hawkeye | Regenerate `tasks/INDEX.md` from the live state of `open/`, `in-progress/`, `done/`, `cancelled/`. awk-based frontmatter parser, atomic write, status-vs-folder drift correction. Called by every task-touching SOP. |
| SOP-014 | [[SOP-014-list-open-tasks]] | Hawkeye | List open and in-progress tasks: §A fast path (read INDEX.md), §B authoritative path (grep the folders directly). Includes Hawkeye and specialist session-boot routines and blocked-task surfacing. References [[SOP-013-rebuild-task-index]]. |
| SOP-015 | [[SOP-015-write-session-log]] | Hawkeye | Write a session log entry in `session-logs/YYYY/MM/`. Filename convention, frontmatter schema, recommended body sections (What I shipped, Tasks touched, Root cause, Voice notes), cross-reference wiring. References [[SOP-016-write-journal-entry]], [[SOP-010-create-task]]. |
| SOP-016 | [[SOP-016-write-journal-entry]] | Any specialist | Write a durable specialist journal entry in `Team/<Name>/journal/`. Trigger test, topic slug, body sections (Context, What I learned, When applies, When NOT, Evidence), cross-link back to session log and task. References [[SOP-017-read-own-journal]]. |
| SOP-017 | [[SOP-017-read-own-journal]] | Any specialist | Read your own journal before starting task work: four steps (task `linked_journal_entries`, 10 most-recent entries, tag match, topic match). Carry priors visibly into the task's Updates log. References [[SOP-016-write-journal-entry]]. |
| SOP-018 | [[SOP-018-storm-research]] | B.J. | Turn one topic into a verified multi-perspective HTML briefing. Five expert lenses, contradiction mapping, adversarial peer review, citation verification. Output: `Deliverables/YYYY-MM-DD-{topic-slug}-storm-research.html`. Template: [[storm-report-template.html]]. |

*Reserved (genuinely open for future agents):* SOP-019 onward. Do not back-fill below SOP-019 without coordinating across the team.

## How to add a new SOP

1. Pick the next unused number (`SOP-NNN`) — by authorship order, not topic. Don't reuse reserved numbers.
2. Filename: `SOP-NNN-<kebab-case-title>.md`.
3. Header includes the default owner, status, triggers, references, and an explicit "Reusable by any agent" note — the SOP is a skill, not 1:1 ownership.
4. Reference [[GL-001-file-naming-conventions]] and any other Guideline instead of duplicating its content.
5. Add a row to this index.
