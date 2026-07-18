# SOP-001 - How to Add a New Specialist

- **Default owner:** Potter
- **Reusable by any agent.** This is a skill, not a 1:1 ownership. SOPs are procedures any agent can invoke when they need them. Potter is the default executor for hiring, but any specialist running the procedure (e.g. when bootstrap mode re-engages and Potter isn't available) follows the same steps.
- **Co-owner for research step:** B.J.
- **Triggered by:** user request to hire, or Hawkeye detecting a gap
- **References:** [[GL-001-file-naming-conventions]], [[GL-009-localize-expansion-role-names]], [[Team/agent-index]]

## Pre-hired team

**Hawkeye, Potter, B.J., Radar, Klinger, and Margaret ship pre-hired with the scaffold.** SOP-001 governs hiring everyone beyond these six. Do not re-run SOP-001 to "create" any of the six — they already exist. SOP-001 is for the seventh hire onward.

## Purpose

Add a new specialist to the team in a way that keeps the routing table clean, the AGENTS.md contracts consistent, and the SSOT Golden Rule intact. Every hire gets a world-class research brief from B.J. before Potter drafts the contract - this is how the team avoids generic, AI-flavored specialists and ships ones that mirror what the best humans in that role actually do.

## Steps

### 1. Capture the need (Hawkeye -> Potter)

Hawkeye routes the hiring request to Potter with a one-sentence brief: what the new specialist will do that no current specialist can. If Potter cannot finish that sentence with the user, the role is not ready.

### 2. Brief B.J. for the research pass (Potter -> B.J.)

Potter writes a research brief to B.J.. Required questions:

- What does the best-in-world version of this specialist actually do, day to day?
- What are the core competencies, and what are the anti-patterns (things mediocre versions of this role do that the team should explicitly avoid)?
- What deliverables does this role produce? What does world-class output look like vs adequate output?
- What boundaries should this role hold? What requests should they refuse or hand back?
- Suggested name candidates (short, distinct, single word, no collision with existing team).

B.J. returns a brief sized to the role - usually 400 to 800 words - cited if the research warranted it. The brief lands in `Deliverables/YYYY-MM-DD-<role-slug>-hire-research.md`.

### 3. Pick a name and role (Potter)

Using B.J.'s brief, pick:

- **Name:** short, distinct, single word. From B.J.'s candidates or a variant. Avoid collisions with existing names.
- **Role:** one short phrase. Example: "Frontend Developer" or "Email Marketer."
- **Folder:** `Team/<Name> - <Role>/` (space, hyphen, space). Matches the pattern of the six pre-hired specialists.

### 4. Draft the AGENTS.md (Potter)

Create `Team/<Name> - <Role>/AGENTS.md`. Translate B.J.'s research brief into a contract with these sections:

- **Identity** - name, role, who they report to, operating principle (drawn from B.J.'s "what world-class does day to day").
- **When Hawkeye routes to them** - the cue patterns.
- **Method or protocol** - how they work, in steps (drawn from B.J.'s "deliverables and what world-class looks like").
- **Deliverable structure** - what their output looks like.
- **Where they write** - paths and naming. Reference [[GL-001-file-naming-conventions]] for naming.
- **Cross-references** - Guidelines and Workstreams they touch.
- **Scope boundaries** - what they do not do (drawn from B.J.'s "anti-patterns" and "boundaries").

Keep it short. The shipped four are the template. Do not paste B.J.'s research brief into the AGENTS.md - the brief stays in `Deliverables/`. The contract references it via `[[wikilink]]` if useful.

### 5. Draft the host subagent shim(s) (Potter)

**Mandatory for every hire, in every host the user has activated.** Without the shim, Hawkeye can only role-play the new specialist within the main context — Hawkeye cannot dispatch them as a parallel subagent via the host's agent-tool. The shim is what binds the wiki contract to the host runtime.

The principle is host-agnostic: a thin pointer to the wiki contract, never a copy of it. The exact path and frontmatter convention is host-specific:

| Host | Shim path | Frontmatter convention | Detect host activation by |
|---|---|---|---|
| Claude Code | `.claude/agents/<slug>.md` | YAML: `name`, `description`, `tools` | presence of `CLAUDE.md` at root |
| Codex CLI | `.codex/agents/<slug>.md` (if supported by active version) — otherwise add a one-line specialist roster note in `AGENTS.md.codex` | per Codex spec at hire time | presence of `AGENTS.md.codex` at root |
| Gemini CLI | per Gemini spec (e.g. `.gemini/extensions/<slug>/`) | per Gemini spec | presence of `GEMINI.md` at root |
| Cursor | n/a — Cursor lacks per-specialist parallel dispatch in the standard product. Add a one-line note in `.cursor/rules/main.md` | n/a | presence of `.cursor/rules/main.md` |
| Chat-only LLM | n/a — single context, hat-switching only | n/a | tool-specific pointer file absent |

When hiring:

1. Detect which hosts the user has activated by checking for the tool-specific pointer files listed above.
2. For each activated host that supports parallel subagent dispatch, write the shim at the host's standard path.
3. For activated hosts that don't support parallel dispatch, add a one-line note in that host's tool-specific pointer file: "Specialist `<Name>` runs as a hat-switch within the main context — host does not support parallel subagent dispatch."

Structural template (Claude Code example — translate the frontmatter conventions for other hosts as their specs require):

```markdown
---
name: <slug>
description: <Role>. Use proactively when <trigger patterns>. Owns <relevant SOP/WS>.
tools: <minimal-tool-list>
---

You are **<Name>, <Role> of myPKA**. <One-line operating principle.>

## On every invocation, in order

1. Read `Team/<Name> - <Role>/AGENTS.md` — your full operating contract.
2. Read `AGENTS.md` at the folder root for the identity overlay and hard rules.
3. Read <relevant SOPs / Workstreams / Guidelines> when the task involves them.

## Cold-start briefing rule

Fresh context every invocation. Hawkeye must hand you <list of inputs the role needs>. If the brief is missing critical info, ask Hawkeye one tight clarifying question before acting.

## Operating discipline

- <2-5 hard rules drawn from B.J.'s anti-patterns and the wiki contract>

## Return format to Hawkeye

- <Status line shape>
- <Counts / paths / structured findings>
- <Anomalies and open questions>
```

Rules (host-agnostic):

- **Never paste the wiki contract into the shim.** The shim references the contract via path. Three layers (`Team/<Name>/AGENTS.md` + a per-folder host-pointer file + project-root host shim) violates SSOT. Two layers is the contract: wiki canonical, shim host-specific.
- **The shim's `tools:` (or host equivalent) is minimal.** Radar doesn't need `Bash`. B.J. mostly needs `WebFetch` / `WebSearch`. Trim to what the role actually uses.
- **The shim's `description:` (or host equivalent) reads as routing instruction for Hawkeye.** Lead with the role, then "Use proactively when…", then the owned SOP/Workstream.
- **The shim's body is short.** ~30-50 lines. The contract carries the depth.
- **The shim shape is the same across hosts** — only the file path and frontmatter format change. The body sections (identity, files-to-read-on-invocation, cold-start briefing rule, operating discipline, return format to Hawkeye) are identical regardless of host.

Use any existing shim (`.claude/agents/margaret.md`, `.claude/agents/radar.md`, etc.) as the structural template for the body — adapt the frontmatter to the host's spec.

### 6. Add the row to agent-index (Potter)

Edit [[Team/agent-index]]. Add a row with the specialist's name, role, folder link, and the user input patterns that should route to them.

### 7. Update relevant Workstreams (Potter)

If the new specialist takes part in a recurring orchestration, edit the matching Workstream in `Team Knowledge/Workstreams/` to mention them via `[[wikilinks]]`. Do not duplicate the AGENTS.md content into the Workstream.

### 8. Confirm with the user (Potter -> Hawkeye -> user)

Show the user the draft AGENTS.md, the draft `.claude/agents/<slug>.md` shim, and the updated agent-index, with a one-line summary of what B.J.'s research surfaced. Make changes only after they approve.

### 9. Log the hire (Hawkeye)

Hawkeye writes a line in the next session log: "Hired <Name> as <Role> after research from B.J.. Brief at `[[<research-deliverable-slug>]]`. Contract at `[[Team/<Name> - <Role>/AGENTS]]`. Shim at `.claude/agents/<slug>.md`." This becomes part of the team's persistent memory.

## Post-hire verification checklist (mandatory)

**This is a hard gate, not an optional note.** A hire is not complete until every item below passes. Run this checklist after Step 7 (Workstream updates) and before Step 8 (confirming the draft with the user) — catching a defect here, at hire time, is the entire point; the alternative is a later audit discovering it after the specialist has already been operating with a defective contract or an undispatchable shim.

Three real defect classes have each slipped through undetected in the past, only caught by a later audit: thin contracts missing routing tables and scope boundaries, missing `journal/` template folders, and UTF-8 BOM on shims that silently makes an agent non-dispatchable with no visible error. Run all four checks below, every hire, no exceptions:

1. **Contract line-count floor.** `Team/<Name> - <Role>/AGENTS.md` is at minimum ~80 lines. A contract shorter than this is very likely missing a required section (routing cues, Method/protocol, scope boundaries) — re-read Step 4's section list and fill the gap before proceeding. Line count alone doesn't guarantee quality, but a contract well under the floor is a reliable smell that something required was skipped.
2. **`journal/_template.md` present.** Confirm `Team/<Name> - <Role>/journal/_template.md` exists. Every specialist needs this folder from day one — a hire that ships without it silently breaks the first journal entry the specialist tries to write.
3. **Shim encoding: UTF-8, no BOM.** Confirm `.claude/agents/<slug>.md` (and any other activated host's shim) is UTF-8 without a byte-order mark. A BOM at the start of a shim file silently breaks frontmatter parsing on some hosts — the agent becomes non-dispatchable with no error message, which is exactly the failure mode this checklist exists to catch before it ships. Write shim files with a tool that does not add a BOM; verify if there's any doubt.
4. **No generic placeholder names left in either file.** Scan both `Team/<Name> - <Role>/AGENTS.md` and the shim(s) for any leftover upstream/generic role name (an Expansion pack's authoring placeholder, a draft name that didn't get replaced, a stray reference to a role that isn't on this team). Ties directly to [[GL-009-localize-expansion-role-names]] — the same localization discipline that Expansion merges require applies to a fresh SOP-001 hire whenever the draft was seeded from external research or a template that named roles generically.

If any item fails, fix it before Step 8. Do not show the user a draft that fails this checklist "to save a round trip" — a failed item found later costs more than the round trip does now.

## Common mistakes to avoid

- Skipping the B.J. research step. Even for "obvious" roles, the research surfaces anti-patterns that prevent generic specs.
- Pasting B.J.'s research brief into the AGENTS.md. The brief is reference material in `Deliverables/`. The AGENTS.md is the contract.
- **Shipping the wiki contract without the matching host subagent shim(s).** The two artifacts go together for every activated host (Claude Code, Codex CLI, Gemini CLI). Without the shim, Hawkeye can only role-play the new specialist — not dispatch them as a parallel subagent in that host.
- **Treating this as a Claude-only setup.** The principle is host-agnostic. Only the shim path and frontmatter convention is host-specific.
- **Pasting the wiki contract into the host shim.** The shim references the contract via path. Don't duplicate.
- **Creating a per-host pointer file (`CLAUDE.md`, `GEMINI.md`, `AGENTS.md.codex`) inside `Team/<Name>/`.** Three layers violates SSOT. Two layers is the rule: wiki contract (host-agnostic) + shim (host-specific, project-root location).
- Duplicating naming rules inside the new AGENTS.md. Link to [[GL-001-file-naming-conventions]] instead.
- Naming the folder with a different separator than other specialists. Always: space, hyphen, space.
- Forgetting to add the row to [[Team/agent-index]]. Hawkeye's routing will skip an unlisted specialist.
- Writing the AGENTS.md in the user's voice instead of as a contract. The file is for the LLM, not the reader.
