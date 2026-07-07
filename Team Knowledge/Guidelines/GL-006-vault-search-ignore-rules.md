# GL-006 - Vault-Wide Searches Must Bypass Ignore Rules

> **This Guideline is a general rule every agent reads before any vault-wide search.** Any operation that claims to sweep "the whole vault" — reference audits, rename-impact analysis, SSOT checks, wikilink verification, orphan detection — reads this file first. SOPs and Workstreams `[[wikilink]]` here rather than restating the rule.

## The rule

**Any search that must cover the entire myPKA folder MUST use a tool that ignores `.gitignore`.** Ripgrep-based tools (including the Claude Code `Grep` tool) silently respect `.gitignore` — and this vault gitignores its largest content trees:

```
PKM/            <- all personal knowledge: Journal, CRM, My Life, Documents, Images, Environment
Documents/
Deliverables/
Team Inbox/
```

A default ripgrep sweep therefore searches **only** `Team Knowledge/`, `Team/`, `Expansions/`, and root files — while reporting no error and no warning. The result looks complete. It is not.

## Approved search methods for vault-wide sweeps

| Method | Notes |
|---|---|
| `grep -r <pattern> .` (Bash) | Ignores `.gitignore`; skips nothing except what you exclude |
| `rg --no-ignore <pattern>` | Ripgrep with ignore rules disabled |
| Python `Path.rglob()` walk | Full control; used for scripted audits |

The Claude Code `Grep` tool remains fine for searches **scoped to tracked trees** (`Team Knowledge/`, `Team/`) — that is what it sees anyway.

## Positive-control check

Before trusting any "no matches found" result on a vault-wide sweep, run a **positive control**: search for a string you know exists inside `PKM/` (e.g. a filename from `PKM/Images/INDEX.md`). If the control returns nothing, your tool is honoring ignore rules and the sweep is invalid.

## Why this rule exists

2026-07-06, GL-001 image rename pass: a `Grep`-based sweep for image references reported ~5 matches vault-wide. An ignore-blind re-sweep found **109 files** with references, including 5 live embeds in `PKM/Documents/3d-printing/` that would have been left pointing at renamed (nonexistent) files. The broken-embed rename pass was caught only because the miss looked suspicious. This Guideline makes the re-check mandatory instead of lucky.

## Updates to this Guideline

- 2026-07-06 — created (Margaret), graduated from the [[2026-07-06-22-20_hawkeye_photo-catalog-deploy-and-family-crm]] session insight.
