# GL-009 - Localize Generic Role Names When Merging Expansion Content

> **This Guideline is a general rule for whoever executes an Expansion merge (default: Potter, per [[WS-003-install-an-expansion]]).** Any Expansion-authored `AGENTS.md`, SOP, Guideline, or Workstream that references *other* team roles by name ships with the pack author's own generic placeholder roster, not the installing user's actual team. SOPs and Workstreams `[[wikilink]]` here rather than restating the rule.

## The rule

**Before a merged Expansion file is considered installed, every cross-reference to another specialist role must be rewritten to the host vault's actual roster.** Expansion authors write their `AGENTS.md`/SOP content assuming a generic team shape (a Journal Writer, an Automation Specialist, a Database Architect, a Researcher, an HR/hiring role, an Orchestrator) and name them with placeholder names. Those placeholder names are **structurally correct** (the role mapping is right) but **literally wrong** (the name doesn't exist in this vault) until localized.

This is not optional polish — an agent reading an un-localized contract will route work to a name that isn't on the team, or worse, silently accept the wrong name as gospel and propagate it into new files it writes.

## How to localize, mechanically

1. **Build the role-to-name map first**, from `Team/agent-index.md`'s actual roles (Orchestrator → Hawkeye, Automation/connections → Klinger, Database/import → Margaret, Researcher → B.J., Journal capture → Radar, Hiring/HR → Potter, etc. — read the index, don't assume this list is exhaustive or permanent).
2. **Substitute every occurrence** of the pack's placeholder names with the mapped real name, in the copied `AGENTS.md` file(s) AND in any SOPs/Guidelines/Workstreams the pack ships alongside them — a pack's SOPs cross-reference the same placeholder roster and are just as likely to carry it.
3. **If a referenced role has no equivalent on the host team** (e.g. a legal/compliance specialist that hasn't been hired), do not invent a name. Rewrite the reference to name the gap functionally ("no legal specialist currently on the team; flag to Hawkeye, who hires via Potter") rather than leaving a dangling placeholder name that reads as real.
4. **Check wikilinks, not just prose.** A placeholder name often appears inside a path-shaped wikilink (`[[Team/Mack - Automation Specialist/AGENTS]]`) — these need the same substitution or they'll dangle.
5. **This is part of the merge, not a follow-up.** Do it in the same pass as the file copy in [[WS-003-install-an-expansion]] §3, before the post-merge integrity check.

## What stays untouched

The Expansion's own source folder under `Expansions/<slug>/` is a **portable, reusable template** — it is meant to work for any host vault's roster, including a future re-install on a different myPKA with different specialist names. Leave the placeholder names in `Expansions/<slug>/` exactly as shipped. Localization applies only to the **copies** that land in `Team/`, `Team Knowledge/SOPs/`, `Team Knowledge/Guidelines/`, and `Team Knowledge/Workstreams/`.

## Why this rule exists

Two Expansion installs on 2026-06-24 (App Developer Pack → Felix/Vex/Vera; Designer Pack → Iris/Charta/Pixel) merged six `AGENTS.md` contracts and seven SOPs that all still referenced the packs' generic authoring roster (`Larry`, `Mack`, `Silas`, `Pax`, `Nolan`, `Penn`, `Lex`) instead of Jeff's actual team (`Hawkeye`, `Klinger`, `Margaret`, `B.J.`, `Potter`, `Radar`, and — for `Lex` — no equivalent hire exists at all). This surfaced two weeks later when Jeff asked why Vex's contract named an orchestrator called "Larry." A full vault scan found the same drift in a core Workstream (`WS-004`) and two core Guidelines (`GL-002`, `GL-005`) as well — the localization gap wasn't unique to Expansion merges, but Expansion merges are the highest-risk surface for it since every install introduces new cross-references wholesale.

## Updates to this Guideline

- 2026-07-08 — created (Hawkeye), graduated from the six-contract localization fix. See [[2026-07-08-verify-before-assuming-a-finding-is-unresolved]] session thread for the adjacent finding that prompted the full-vault scan.
