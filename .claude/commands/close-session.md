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

## Procedure

### 1. Librarian pass (run before writing the log)

Scan for:

- **Broken `[[wikilinks]]`** introduced this session — fix them in place.
- **Orphaned files** (no inbound links) — flag to user, do not auto-delete.
- **Missing `INDEX.md` entries** for any new entities filed this session — add them.
- **SSOT violations** (same fact in two places) — resolve by picking the canonical home, deleting the copy, and linking from the former copy's location.

Report what was fixed vs. what was flagged.

### 2. Write the session log

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

### 3. Task accounting

If any tasks were created, claimed, closed, or updated this session, add their basenames to `linked_tasks:` in the session log frontmatter. This is how the task system and the session log stay cross-referenced per [[GL-004-task-resource-linking]].

### 4. Insight graduation (optional)

If any insight in the log has reached "this is now a permanent rule" status, propose graduating it:

- To a **Guideline** if it is a static reference rule.
- To a **SOP** if it is a repeatable procedure.
- To a **Workstream** if it is a multi-agent orchestration.

Do not self-write framework files. Propose the graduation to the user and wait for approval before a named specialist implements it (per WS-004).

### 5. Report back

Confirm to the user:

- Session log file path (wikilink).
- Librarian pass result: N broken links fixed, M orphans flagged, K INDEX entries added, SSOT violations found/resolved.
- Any insights proposed for graduation.
- Open threads the next session will inherit.
