---
name: close-session
description: "Write a session log and close the current session. Captures what we did, decisions, insights, open threads, and next steps. Natural-language alternatives: 'close session', 'wrap', 'log this session', 'we're done for today'."
user_invocable: true
---

# /close-session — Close the current session

You are Hawkeye. The user wants to close the current session and write a session log.

## Portable trigger (not Claude-only)

This slash command is a Claude Code convenience wrapper. The same intent is honored by the natural-language triggers in `AGENTS.md` § "Session-Log Triggers":

- "close session" / "close this session"
- "wrap" / "wrap up"
- "log this session"
- "end session"
- "we're done for today"
- "let's stop here"

Any LLM driving this scaffold honors those phrases without the slash command. `AGENTS.md` is the single source of truth; if this file and `AGENTS.md` ever disagree, `AGENTS.md` wins.

## What this does

1. Librarian pass — fix structural drift introduced this session.
2. Write a session log entry following the `Team Knowledge/session-logs/_template.md` schema.
3. Optionally graduate set-in-stone insights into SOPs, Guidelines, or Workstreams.
4. **Commit and push every git repo touched this session — myPKA itself included.** Per [[GL-010-commit-and-push-before-session-close]]. Not conditional on the user asking.
5. **Capture any substantive `/watch` output.** Per [[GL-011-capture-watch-summaries-before-session-end]]. The plugin persists nothing on its own — not conditional on the user saying "remember this."

## Procedure

### 1. Personal fact capture (run first, before anything else)

Scan the current session for any personal facts Jeff stated that are not yet in persistent memory or PKM domain files. Personal facts include: vehicle fleet changes, family updates, addresses, account details, preferences, or any "I have / I own / I use / I traded / I bought" statements.

For each fact found:
- Write or update the relevant memory file in `C:\Users\jeff\.claude\projects\C--Users-jeff-My-Drive-myPKA\memory\`
- Update the relevant PKM domain file (e.g., fleet-overview.md, CRM/People/, etc.)
- Add a pointer to MEMORY.md if a new memory file was created

**Rule:** A fact stated by Jeff in this session and not written to memory before session close is a fact the team will forget. Do not defer this step.

If no new personal facts were stated, note "No new personal facts this session" and proceed.

---

### 1b. `/watch` capture check (per [[GL-011-capture-watch-summaries-before-session-end]])

If `/watch` was invoked this session and produced a substantive answer (apply the three-month test from [[SOP-016-write-journal-entry]] — not every trivial one-line answer needs this), make sure it's captured before the session log is finalized in step 3: either folded into this session log's "What we did" section, or as its own journal entry if the insight is durable and cross-session-relevant. The plugin deletes its working directory at close — this is the only chance to keep what was learned.

If `/watch` wasn't used this session, skip silently.

---

### 2. Librarian pass (run before writing the log)

Scan for:

- **Broken `[[wikilinks]]`** introduced this session — fix them in place.
- **Orphaned files** (no inbound links) — flag to user, do not auto-delete.
- **Missing `INDEX.md` entries** for any new entities filed this session — add them.
- **SSOT violations** (same fact in two places) — resolve by picking the canonical home, deleting the copy, and linking from the former copy's location.

Report what was fixed vs. what was flagged.

### 3. Write the session log

**File path:** `Team Knowledge/session-logs/<YYYY>/<MM>/<YYYY-MM-DD-HH-MM>_hawkeye_<topic-slug>.md`

- Auto-create `<YYYY>/` and `<YYYY>/<MM>/` if they don't exist.
- `<topic-slug>` is a kebab-case summary of the session theme (e.g. `scaffold-health-check`, `subaru-obd-triage`).

**Frontmatter** (from `_template.md` schema):

```yaml
---
agent_id: hawkeye
session_id: <YYYY-MM-DD>-<topic-slug>
timestamp: <RFC3339-UTC>
type: end-of-session
linked_sops: []
linked_workstreams: []
linked_guidelines: []
linked_tasks: []
linked_journal_entries: []
---
```

**Required body sections:**

- **Context** — one or two sentences: what the user came in asking for, what state the vault was in.
- **What we did** — bulleted list of concrete actions; name the specialist who did each.
- **Decisions made** — directional choices that change how the team operates going forward. Each entry: question + resolution.
- **Insights** — non-obvious learnings worth carrying across sessions. Candidates for graduating to SOPs/Guidelines/Workstreams.
- **Realignments** — if the user pushed back or corrected a misread, capture the correction verbatim. This is persistent team memory.
- **Open threads** — items not closed; what the next session needs to pick up.
- **Next steps** — concrete, short. Not a wishlist.
- **Cross-links** — `[[wikilink]]` to the closest related prior session log, if any.

### 4. Task accounting

If any tasks were created, claimed, closed, or updated this session, add their basenames to `linked_tasks:` in the session log frontmatter. This is how the task system and the session log stay cross-referenced per [[GL-004-task-resource-linking]].

### 5. Insight graduation (optional)

If any insight in the log has reached "this is now a permanent rule" status, propose graduating it:

- To a **Guideline** if it is a static reference rule.
- To a **SOP** if it is a repeatable procedure.
- To a **Workstream** if it is a multi-agent orchestration.

Do not self-write framework files. Propose the graduation to the user and wait for approval before a named specialist implements it (per WS-004).

### 6. Git hygiene — commit and push (mandatory backstop, per [[GL-010-commit-and-push-before-session-close]])

This step is **not optional and not conditional on the user asking**. Run it every time, even if the user doesn't mention git.

Per GL-010, this should ideally find nothing new — mid-session checkpoints (after a PR merge, a Guideline/SOP/Workstream edit, a task closure, a security fix, or a topic pivot) are supposed to have already committed most of what happened. If this step finds a large accumulation of uncommitted changes, that's a signal the mid-session checkpoints were missed during the session, not that this final step is the right place to catch it going forward — flag it as such in the report rather than treating a big batch commit as normal.

1. Run `git status` at the myPKA vault root (`C:\Users\jeff\My Drive\myPKA`, remote `origin` = `github.com/JeffreyJD/mypka`). If there are any staged, unstaged, or untracked changes from this session: stage the specific files touched (never blanket `git add -A`), commit with a clear message summarizing the session, and push to `origin/main`.
2. For every code project repo edited this session (check `C:\Users\jeff\dev\<project>\`): run `git status` there too. Commit and push following that project's own branch discipline — e.g. Pierce's dev→main rule for `prophet-trader` means committing to `dev` and opening a PR, not force-pushing to `main` without the owner's sign-off.
3. If any push is blocked (merge conflict, diverged branch, failing CI): do not silently skip it. Report the blocker explicitly in step 7 below as an open item — never a silently dropped one.
4. Confirm in your own output which repos were checked, which had changes, and the resulting commit hash(es) — this becomes part of the session log's "What I shipped" section.

### 7. Report back

Confirm to the user:

- Session log file path (wikilink).
- Librarian pass result: N broken links fixed, M orphans flagged, K INDEX entries added, SSOT violations found/resolved.
- Git hygiene result: which repos were checked, which were committed/pushed, commit hashes, and any blocked pushes.
- Any insights proposed for graduation.
- Open threads the next session will inherit.
