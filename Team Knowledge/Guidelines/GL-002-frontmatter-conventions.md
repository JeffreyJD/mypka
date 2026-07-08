# GL-002 - Frontmatter Conventions

> **This Guideline is a general rule every agent reads on every relevant action.** Every entity note Radar captures, every entity Margaret writes during an import, every audit Iris runs — they all read this file. SOPs and Workstreams `[[wikilink]]` here rather than restating the schema.

This is the source of truth for the YAML frontmatter that sits at the top of every entity note in your myPKA. Every other file that needs to talk about field names `[[wikilinks]]` here.

Aligns with [[SOP-002-convert-mypka-to-sqlite]] (the SQLite migration contract). Field names in this Guideline match the column names that SOP-002 reads. Do not rename one without the other.

## Why this exists

Read this once, never again.

A note in your myPKA has two layers:

1. **Structured data** lives in YAML frontmatter at the top of the file. Names, dates, links, statuses, contact details. Anything that has a clear shape and the team will want to query.
2. **Narrative** lives in the body. How you met the person. Why the project matters. What you noticed. Anything that reads like prose.

The split is load-bearing for three reasons:

- The right-sidebar **Properties tab** in mypka-interface parses frontmatter and renders it as a typed key-value UI. No frontmatter, no Properties tab.
- The **SQLite migration** ([[SOP-002-convert-mypka-to-sqlite]]) reads frontmatter into typed columns. Inline body text like `**Email:** jane@example.com` migrates as zero structured data.
- New users (and new agents) need a predictable shape. If every note invents its own field names, search and automation collapse.

When in doubt, the rule is: structured fact goes in frontmatter, story goes in the body.

## Core rules

### 1. Frontmatter sits at the very top of the file

Open and close the block with three dashes on their own line:

```yaml
---
name: Jane Doe
role: Product Designer
---
```

Body content starts on the line after the closing `---`.

### 2. Field names are kebab-case-or-snake_case, never both

myPKA uses `snake_case` for frontmatter keys to match the SQLite column names in [[SOP-002-convert-mypka-to-sqlite]]. Do not mix conventions inside one file.

Good: `full_name`, `last_contact`, `target_date`.
Bad: `fullName`, `last-contact`, `Target Date`.

### 3. Typing rules

- **Strings** - quoted only when they contain special characters (colons, hashes, leading numbers). Plain text otherwise.
- **Dates** - always ISO `YYYY-MM-DD`. No timezones, no slashes, no month names. Cross-references [[GL-001-file-naming-conventions]] rule 2.
- **Datetimes** - ISO-8601 `YYYY-MM-DDTHH:MM:SSZ` when a wall-clock time matters. Otherwise prefer date.
- **Booleans** - `true` or `false`, lowercase.
- **Lists** - YAML array, one item per line, `-` prefix:
  ```yaml
  tags:
    - work
    - design
  ```
  Inline `[a, b, c]` is allowed for short lists but the multi-line form is preferred for readability.
- **Slugs and foreign keys** - kebab-case, matching the target file's stem exactly. See [[GL-001-file-naming-conventions]] rule 1.

### 4. Foreign-key fields store the slug, not the title

Locked decision: when one entity references another, the frontmatter field stores the **slug** of the target (the filename stem), and the UI resolves the slug to the target's `name` or `title` at render time.

```yaml
# In PKM/CRM/People/jane-doe.md
organization: acme-corp           # points to PKM/CRM/Organizations/acme-corp.md
```

Why slug not title: the slug is stable across renames inside frontmatter, the title is the field stored on the target file and may change. Storing the slug means a target rename (with file move) only needs to update one place.

The mypka-interface Properties tab renders the resolved title with the slug as a tooltip. The SQLite migration ([[SOP-002-convert-mypka-to-sqlite]]) resolves the slug to the FK integer at conversion time.

**Documented exception — `photo_sidecar` `people` field:** The `people` list in `photo_sidecar` notes uses wikilink form (`[[slug]]`) rather than plain slugs. This is intentional: Obsidian uses wikilinks to generate backlinks, which allows a CRM People file to surface all photos of a person via the backlinks panel without any separate query or manual maintenance. This deviation is canonical for `photo_sidecar` only. See the photo_sidecar schema in the Entity schemas section.

### 5. Required fields are minimal, optional fields are abundant

The team's bias: **require only what makes the note identifiable**. Every other field is optional and can be filled when the user has it.

Per entity, the required field is the one that names the thing:

| Entity | Required |
|---|---|
| Person | `full_name` |
| Organization | `name` |
| Project | `name` |
| Goal | `name` |
| Habit | `name` |
| Topic | `name` |
| Key Element | `name` |
| Document | `title` |
| Host | `name` |
| Service | `name` |
| Account | `name` |
| Software | `name` |
| photo_sidecar | `image` |
| photo_album | `album_slug` |

Everything else is optional. A note with three frontmatter fields is fine. A note with twenty is also fine. The shape stays consistent.

### 6. Never invent ad-hoc fields

If you find yourself wanting a field that is not in this Guideline:

1. Check the entity schema below.
2. If the field is genuinely missing and you will use it more than once, edit this Guideline first. Add the field with its typing rule and any cross-references.
3. Then use it.

One-off `notes_jane_likes` style keys break the SQLite migration silently. Free-form notes go in the body.

### 7. Secrets are pointers, never values

**Locked decision (2026-06-11): no credential value is ever written into a myPKA file.** This folder syncs to cloud storage; a password or API key written here is a plaintext secret in the cloud.

The Environment entities (Host, Service, Account, Software) carry three pointer fields instead:

- `secrets_ref` — WHERE the credential lives (`".env on davisglobe-vps-ash-1"`, `"Bitwarden > Homelab > Lighthouse iDRAC"`). Never the credential itself.
- `env_var_names` — the NAMES of environment variables a service or account uses. Names are documentation; values stay in the `.env` file on the host.
- `license_ref` — where a license key lives, never the key.

Usernames, IPs, ports, URLs, and hostnames are fine in frontmatter — they identify the door, not the key. If the pointer-only policy ever proves too slow in practice, the agreed fallback is **hybrid**: low-risk, LAN-only credentials may move inline after an explicit user decision recorded in a session log. High-value secrets (anything with spend, root access, or trading authority) stay pointers forever.

## Entity schemas

These are the canonical fields per entity. Field names are case-sensitive and match the SQLite column names in [[SOP-002-convert-mypka-to-sqlite]].

### People - `PKM/CRM/People/<slug>.md`

```yaml
---
full_name: Jane Doe                        # required — the LEGAL name
first_name: Jane                           # optional, derived if absent
last_name: Doe                             # optional, derived if absent
goes_by: Janie                             # optional — everyday/referred-to name when it differs from the legal name
maiden_name: Smith                         # optional — pre-marriage surname
relation: friend                           # colleague | friend | family | client | other
role: Product Designer
company: acme-corp                         # slug of an Organization
email: jane@example.com
phone: +1-415-555-0100                     # E.164 preferred
city: San Francisco
birth_date: 1990-03-14
linkedin_url: https://www.linkedin.com/in/janedoe
last_contact: 2026-05-09
tags:
  - work
  - design
---
```

Notes:
- `company` stores the slug of an Organization note. Per rule 4, the UI resolves it to the Organization's `name`.
- `relation` follows the SOP-002 convention: prefer one of `colleague`, `friend`, `family`, `client`, `other`. Free text accepted but limits queryability.
- `full_name` is the **legal** name. `goes_by` holds the everyday name when it differs (e.g. `full_name: Ariana Davis`, `goes_by: Anna`). Omit `goes_by` when the person is called by their legal first name. Added 2026-07-06 per rule 6.
- `maiden_name` documents a pre-marriage surname (already in live use, e.g. Bridget Davis née Borkowski). Added to schema 2026-07-06.
- Body section conventions: `## How we met`, `## Topics of common interest`, `## Notes`.

### Organizations - `PKM/CRM/Organizations/<slug>.md`

```yaml
---
name: Acme Corp                            # required
org_type: company                          # company | clinic | nonprofit | government | school | other
industry: software
website: https://www.acmecorp.example
email: hello@acmecorp.example
phone: +1-415-555-0199
city: San Francisco
tags:
  - vendor
---
```

Notes:
- `org_type` aligns with SOP-002's `organizations.type` column. The frontmatter key is `org_type` to avoid colliding with the YAML reserved-feeling word `type`.
- Body section conventions: `## What they do`, `## How we work together`, `## Notes`.

### Projects - `PKM/My Life/Projects/<slug>.md`

```yaml
---
name: Ship the Pricing Page Refresh        # required
status: active                             # planning | active | paused | done | archived
target_date: 2026-07-15
key_element: work                          # slug of a Key Element
linked_goals:
  - hit-50-mrr-by-q3
linked_people:
  - jane-doe
tags:
  - marketing
---
```

Notes:
- `status` enum is the team default. Use one of the listed values for queryability; free text is parsed but not categorized.
- `key_element`, `linked_goals`, `linked_people` all store slugs per rule 4.
- Body section conventions: `## Why this matters`, `## Status update`, `## Open threads`, `## Next steps`.

### Goals - `PKM/My Life/Goals/<slug>.md`

```yaml
---
name: Hit $50K MRR by Q3                   # required
status: active                             # planning | active | paused | done | abandoned
target_date: 2026-09-30
key_element: work                          # slug of a Key Element
linked_projects:
  - ship-pricing-refresh
tags:
  - revenue
---
```

Notes:
- A Goal is the destination; a Project is the work toward it. The relationship is `linked_projects` here, mirrored as `linked_goals` from the Project side.
- Body section conventions: `## Why this matters`, `## Definition of done`, `## Progress notes`.

### Habits - `PKM/My Life/Habits/<slug>.md`

```yaml
---
name: Morning Walk                         # required
cadence: daily                             # daily | weekdays | weekly | monthly | adhoc
status: active                             # active | paused | abandoned
started_on: 2026-04-01
key_element: health                        # slug of a Key Element
tags:
  - health
---
```

Notes:
- `cadence` is the rhythm; `status` is whether you are currently doing it.
- Streak tracking is a body-level concern (or an extension), not a frontmatter field. Frontmatter holds the definition, not the daily log.
- Body section conventions: `## Why this habit`, `## What it looks like`, `## Reflection`.

### Topics - `PKM/My Life/Topics/<slug>.md`

```yaml
---
name: Pricing Strategy                     # required
key_element: work                          # slug of a Key Element
parent_topic: business-strategy            # optional, slug of a parent Topic
tags:
  - strategy
---
```

Notes:
- A Topic is a recurring subject of thought - lighter than a Project, broader than a single Document.
- Topics can nest via `parent_topic` to a single parent. Multi-parent is not supported - keep the tree clean.
- Body section conventions: `## What I think about here`, `## Open questions`, `## Sources`.

### Key Elements - `PKM/My Life/Key Elements/<slug>.md`

```yaml
---
name: Work                                 # required
description_short: My professional life and the businesses I run
status: active                             # active | dormant
tags:
  - life
---
```

Notes:
- Key Elements are the top-level domains of life (Work, Health, Relationships, Money, Growth, etc.). There are typically 5 to 9 per user.
- Other entities point to a Key Element via the `key_element` field on Projects, Goals, Habits, and Topics.
- Body section conventions: `## What this covers`, `## What good looks like`, `## What I am ignoring`.

### Documents - `PKM/Documents/<slug>.md`

```yaml
---
title: Apartment Lease 2026                # required
doc_type: contract                         # contract | id | invoice | warranty | medical | tax | other
physical_location: top drawer of the desk
digital_location: Dropbox/Legal/2026-lease.pdf
issued_on: 2026-01-15
expiry_date: 2027-01-14
renewal_trigger: 2026-11-15                # date to act, not the document's own deadline
linked_people:
  - jane-doe                               # tenant, landlord, etc.
linked_organizations:
  - acme-property-management
tags:
  - housing
---
```

Notes:
- `title` is the field, not `name` - aligns with SOP-002's `documents.title` column.
- `physical_location` and `digital_location` are independent. A document can have both, either, or neither.
- `renewal_trigger` is the date you want to be reminded to act. The actual `expiry_date` may be later.
- Body section conventions: `## Summary`, `## Key terms`, `## Notes`.

### Hosts - `PKM/Environment/Hosts/<slug>.md`

A Host is any machine you own, rent, or administer: a physical server, a cloud VPS, a laptop, a desktop, a single-board computer.

```yaml
---
name: davisglobe-vps-ash-1                 # required
host_type: vps                             # physical | vps | laptop | desktop | sbc | other
status: active                             # planned | building | active | retired
provider: hetzner                          # who you rent/bought it from
os: Ubuntu 26.04 LTS
location: Ashburn, VA
specs: 4 vCPU / 8 GB RAM / 150 GB disk
ip_public: 178.156.163.139
ip_public_v6: 2a01:4ff:f4:67e5::1
ip_lan: 10.0.20.10
ip_tailscale: 100.91.84.117
dns_name: davisglobe-vps-ash-1.tailfe9a46.ts.net
access: ssh trader@178.156.163.139         # how to get in — the door, not the key
secrets_ref: SSH key on jeff-laptop        # WHERE credentials live (rule 7), never the value
renewal_date: 2027-06-11
monthly_cost: 12
linked_accounts:
  - hetzner                                # slugs of Accounts (the provider account, etc.)
tags:
  - trading
---
```

Notes:
- Per rule 7, `secrets_ref` is a pointer. No passwords, no keys, no tokens in this file, ever.
- `ip_lan` for homelab machines, `ip_public` for cloud machines, `ip_tailscale` when on the tailnet. A host can have all three.
- `status: building` is for hardware mid-assembly; `planned` for designed-on-paper.
- Body section conventions: `## What runs here`, `## Security posture`, `## Backups`, `## Open questions`.

### Services - `PKM/Environment/Services/<slug>.md`

A Service is a deployed thing that runs on a Host: an app, a Docker container, a VM, an LXC, a cron job, a database.

```yaml
---
name: Prophet Trader                       # required
status: active                             # planned | active | paused | retired
service_type: app                          # app | container | vm | lxc | cron_job | database | network | other
runtime: cron                              # docker | vm | lxc | systemd | cron | bare_metal | other
host: davisglobe-vps-ash-1                 # slug of a Host
install_path: /home/trader/prophet-trader
repo_path: C:\Users\jeff\dev\prophet-trader # where the code lives (local path or repo URL)
url: https://example.internal:8096
ports:
  - 8096
schedule: "30 9 * * 1-5 ET"                # cron expression or human description
env_file: /home/trader/prophet-trader/.env # pointer to the env file location (rule 7)
env_var_names:                             # variable NAMES only, never values (rule 7)
  - ALPACA_PAPER_API_KEY
monitoring: healthchecks.io dead-man's switch
depends_on:
  - some-other-service                     # slugs of Services
linked_accounts:
  - alpaca                                 # slugs of Accounts this service uses
tags:
  - trading
---
```

Notes:
- `host` stores the slug of a Host note per rule 4. One service, one host; if the same app runs on two hosts, that is two Service notes.
- `env_var_names` documents what the `.env` must contain so a rebuild is possible without archaeology. Values live only in the `.env` on the host.
- Body section conventions: `## What it does`, `## How it is deployed`, `## Runbook`, `## Open questions`.

### Accounts - `PKM/Environment/Accounts/<slug>.md`

An Account is a relationship with an external provider: hosting, an API, a SaaS subscription, an exchange, a domain registrar.

```yaml
---
name: Alpaca                               # required
status: active                             # active | trial | paused | cancelled
account_type: api                          # hosting | api | saas | exchange | domain | email | bot | other
provider_url: https://alpaca.markets
username: jeff@example.com
plan: Paper trading (free tier)
monthly_cost: 0
renewal_date: 2027-01-15
secrets_ref: .env on davisglobe-vps-ash-1  # WHERE the key/token lives (rule 7)
env_var_names:
  - ALPACA_PAPER_API_KEY
  - ALPACA_PAPER_SECRET_KEY
linked_services:
  - prophet-trader                         # slugs of Services that use this account
linked_hosts:
  - davisglobe-vps-ash-1                   # slugs of Hosts (for hosting providers)
tags:
  - trading
---
```

Notes:
- One file per provider account. If you hold two separate accounts at the same provider (personal + business), that is two notes.
- `renewal_date` + `monthly_cost` make "what am I paying for and when does it renew" a frontmatter query.
- Body section conventions: `## What it is for`, `## Key facts`, `## Open questions`.

### Software - `PKM/Environment/Software/<slug>.md`

Software is a tool you license, subscribe to, or depend on — tracked when forgetting it would cost money or break a rebuild.

```yaml
---
name: Claude Code                          # required
status: active                             # active | trialing | retired
software_type: subscription                # subscription | license | open_source | os | other
vendor: Anthropic
version: ""
installed_on:
  - jeff-laptop                            # slugs of Hosts
license_ref: ""                            # WHERE the license key lives (rule 7), never the key
renewal_date: 2027-01-15
monthly_cost: 20
tags:
  - ai
---
```

Notes:
- Not every package on every machine — only software whose loss, renewal, or license you need to track. OS-level inventory belongs in the Host note's body.
- Body section conventions: `## What I use it for`, `## Setup notes`, `## Open questions`.

### Photo Sidecars - `PKM/Images/YYYY/MM/<slug>.md`

A photo sidecar is a companion `.md` file for every image file in the vault. The sidecar slug **always matches** its image file slug exactly, same folder. Moving an image requires moving its sidecar. The sidecar is the SSOT for all per-image metadata — who is in the photo, when it was taken, what event it records.

```yaml
---
note_type: photo_sidecar
image: "[[Images/2026/07/2026-07-05-sea-ray-fusion-ms-av650.jpg]]"
date_taken: 2026-07-05
year: 2026
month: 7
people:
  - "[[alyssa]]"
  - "[[alex]]"
event: ""
topic_tags:
  - boat
  - sea-ray
photo_type: equipment
location: ""
description: ""
ai_pending: false
ai_confidence: null
confirmed: false
---
```

Notes:
- `note_type: photo_sidecar` — discriminator field. Obsidian Bases (and Dataview) filters photo sidecars from all other `.md` files with `WHERE note_type = "photo_sidecar"`. Required because sidecar files co-exist with other markdown files in `PKM/Images/` rather than living in their own isolated folder.
- `image` — wikilink to the image file, quoted so Obsidian resolves it as a link and creates a backlink from the image to the sidecar. This is the required field.
- `date_taken` — ISO date of actual capture. May differ from the filename date if the image was imported or renamed after the fact.
- `year` / `month` — integer copies of the date components for fast Bases filtering without date parsing. Both are optional but strongly recommended.
- `people` — **DOCUMENTED EXCEPTION TO RULE 4.** Uses wikilink form (`[[slug]]`) rather than plain slugs. Reason: Obsidian uses wikilinks to generate backlinks, which allows a CRM People file to surface all photos of a person via the backlinks panel without any separate query or manual maintenance. This deviation is intentional and canonical for `photo_sidecar` only.
- `event` — free text event name (e.g. `"Fourth of July 2026"`, `"Christmas morning"`). Optional.
- `topic_tags` — list of plain strings, not wikilinks. Parallel to body `#tags` but kept in frontmatter for Bases queries. Optional.
- `photo_type` — controlled vocabulary: `family | property | equipment | document | landscape | event`. Primary browse dimension. Optional but strongly recommended.
- `location` — free text location (e.g. `"Lake house dock"`, `"Ashburn, VA"`). Optional.
- `description` — one-sentence AI or user description of the image. Optional.
- `ai_pending` and `confirmed` — state machine for the AI-suggest + human-confirm pipeline. See state machine below.
- `ai_confidence` — controlled vocabulary: `high | medium | low`. Set only when `ai_pending: true`. Must be `null` when `ai_pending: false`.

**State machine — `ai_pending` / `confirmed`:**

| State | `ai_pending` | `confirmed` | Meaning |
|---|---|---|---|
| Uncatalogued | `false` | `false` | No AI pass run yet. Default. |
| AI-flagged | `true` | `false` | Claude identified probable people; Jeff has not reviewed. `people` may contain candidates. `ai_confidence` is set. |
| Confirmed | `false` | `true` | Jeff reviewed all `people` tags. Ground truth. |
| Rejected | `false` | `true` | Jeff reviewed and removed AI candidates. Still `confirmed: true` to prevent re-flagging. |

Never set both `ai_pending: true` and `confirmed: true` simultaneously. They are mutually exclusive.

**Standard sidecar body** — the image embed is the only expected body content:
```markdown
![[Images/YYYY/MM/slug.jpg]]
```

All metadata lives in frontmatter. The body is the preview surface, not a metadata store.

### Photo Albums - `PKM/Images/_albums/<slug>.md`

A photo album is a browse-surface collection file. Albums are derived from sidecar queries — they wikilink or embed sidecar files for a given event, person, or topic. **Albums never own metadata.** They reference it. The SSOT for any per-image fact is always the sidecar.

```yaml
---
note_type: photo_album
album_slug: alyssa
---
```

Notes:
- `note_type: photo_album` — discriminator. Distinguishes album collection files from sidecar files in Bases queries.
- `album_slug` — the slug identifying this collection. Required. Matches the filename stem.
- Albums can be regenerated by Claude during any cataloging session by scanning all sidecar files for matching `people`, `event`, or `topic_tags` values. Treat them as materialized views, not data stores.
- Body section: curated or generated wikilinks to sidecar files, organized by year or event. Example: `- [[2026-07-05-fourth-of-july-dock]] — Dock at the lake house`.

## Specialist contract fields

The schemas above govern PKM **entity notes**. Specialist **contracts** carry their own small set of frontmatter keys (`agent_version`, `agent_status`, `owner`, etc.). This section documents one optional contract-level field that is part of the v4 tool-agnostic core: `model`.

### `model` - optional

| Property | Value |
|---|---|
| Field name | `model` |
| Required? | **Optional.** Omit to inherit the session/harness default. |
| Applies to | Specialist contracts (`Team/<Name> - <Role>/AGENTS.md` frontmatter) and their host shims (`.claude/agents/<slug>.md`). |
| Type | Portable tier alias - one of `reasoning`, `balanced`, `fast`. An explicit `provider/model-id` string is also accepted (escape hatch, discouraged - see below). |

**Default is omit-to-inherit.** When `model` is absent, the specialist runs on whatever model the session or harness has selected. Most specialists should leave it unset. Set it only when a specialist's work has a clear, stable tier need.

**The value is a portable tier alias, not a concrete model name.** The contract stays provider-neutral; the harness adapter resolves the alias to a real model.

| Alias | Meaning | Use for |
|---|---|---|
| `reasoning` | Deepest reasoning, highest capability | Architect-grade work: schema design, security audits, multi-step planning. |
| `balanced` | The default specialist tier | Most specialist work. Good capability at sensible cost. |
| `fast` | Cheapest, highest-throughput | High-volume, low-judgment work: bulk formatting, simple extraction, triage fan-out. |

**The adapter owns alias-to-model resolution, not the contract.** A harness adapter maps each alias to a concrete model for that provider. For example, a Claude Code adapter maps `reasoning` to an Opus-class model, `balanced` to Sonnet, and `fast` to Haiku, and writes the resolved value into the host shim. The portable contract never names the concrete model; only the generated shim does. This keeps one contract runnable across any provider.

**OpenRouter is the supported BYO-key router.** A member who routes through OpenRouter supplies their own OpenRouter key and points the harness at OpenRouter's Anthropic-compatible endpoint via the `ANTHROPIC_BASE_URL` environment variable. The alias-to-slug mapping for OpenRouter (e.g. which OpenRouter model slug `balanced` resolves to) lives in the adapter and the member's harness config, never in the contract. BYO key, member's own account - this is the supported path.

**Escape hatch: explicit `provider/model-id` is permitted but flagged.** You may pin a concrete model with an explicit `provider/model-id` string (e.g. `anthropic/claude-opus-4`). The agnosticism-audit in `validation-script.sh` flags any such value as a **coupling warning**, because it pins a provider into the portable core and breaks the run-anywhere contract. Prefer the alias form. Reach for the explicit string only when a specialist genuinely depends on one specific model's behavior, and accept the warning as the documented record of that coupling.

> **ToS INVARIANT (legal/compliance — co-owned with Vex; no dedicated legal specialist hired yet).** If `model` resolves to an Anthropic model **and our own code makes the call** (not a first-party Anthropic client such as the Claude apps or Claude Code itself), that call MUST authenticate with an Anthropic API key, AWS Bedrock, or Google Vertex - **never** a subscription OAuth token. Never reuse `~/.claude/.credentials.json` or any subscription-session credential for programmatic calls. Routing the same call via OpenRouter is fine because it uses the member's own OpenRouter key (BYO). This invariant is non-negotiable and is enforced (co-owned with Vex) by the agnosticism-audit, which hard-fails on any reference to `~/.claude/.credentials.json` or OAuth-token reuse in the portable core.

## How to extend this Guideline

Your myPKA grows. New fields will surface. Two acceptable extension paths:

1. **Add a new optional field to an existing entity.** Edit the entity's schema above. Add the field with its typing rule. Commit. The SQLite migration in [[SOP-002-convert-mypka-to-sqlite]] will pick up new optional columns gracefully (they default to `NULL` for older notes).

2. **Add a new entity type.** Higher cost. Requires a new folder under `PKM/`, a new schema in this Guideline, a new section in [[SOP-002-convert-mypka-to-sqlite]], and a new template in [[Templates/INDEX]]. Do not do this casually.

Two rules that apply to both paths:

- **Pick one, document, never invent ad-hoc.** If two notes use different field names for the same thing, search and migration both rot.
- **Never rename a field without the SOP.** A rename here without a matching update in [[SOP-002-convert-mypka-to-sqlite]] silently breaks the SQLite migration. Coordinate the change.

## Cross-references

- [[GL-001-file-naming-conventions]] - slug rules, ISO date format, filename patterns.
- [[SOP-002-convert-mypka-to-sqlite]] - the SQLite migration contract. This Guideline's field names match SOP-002's column names.
- [[Templates/INDEX]] - copy-and-edit starter templates for every entity type defined here.

## Updates to this Guideline

If the rules change, update this file. Do not duplicate the change into SOPs, Workstreams, or templates. They `[[wikilink]]` here and inherit the change automatically.
