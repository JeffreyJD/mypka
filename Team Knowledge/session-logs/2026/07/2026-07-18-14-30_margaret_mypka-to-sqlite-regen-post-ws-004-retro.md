---
agent_id: margaret
session_id: mypka-to-sqlite-regen-post-ws-004-retro
timestamp: 2026-07-18T14:30:00Z
type: end-of-session
linked_sops: ["SOP-002-convert-mypka-to-sqlite"]
linked_workstreams: ["WS-007-infrastructure-change-lifecycle"]
linked_guidelines: ["GL-002-frontmatter-conventions", "GL-014-windows-shell-interop-gotchas", "GL-015-credential-expansion-over-new-grants"]
---

# mypka.db regeneration after WS-004 Tier 2 retro + WS-007 ratification

## Context

Ten tasks closed 2026-07-18 from a WS-004 Tier 2 Team Retro plus WS-007
ratification: new Workstream WS-007, new Guidelines GL-014 and GL-015,
amendments to SOP-001, SOP-022, WS-002, GL-007, three specialist contracts
(Trapper, Bastion, Relay), Hawkeye's own contract, and root AGENTS.md. Per
WS-004 Tier 2 Step 6, the SQLite mirror gets regenerated after any approved
retro subset lands so the derived index reflects current framework state.
Hawkeye dispatched this regen directly; the markdown vault stayed canonical
and untouched throughout.

## What we did

- Wrote `mypka_to_sqlite.py` at the vault root (no prior version existed in
  this vault - it is a prompt-as-deliverable per SOP-002, generated fresh).
- Ran the pre-flight discovery pass that SOP-002 calls for before any
  conversion, which surfaced two structural findings addressed below
  (Documents is not flat; hidden build-artifact folders needed exclusion)
  before the real run.
- Executed the full three-pass migration (base entities -> FK-dependent
  entities -> content_index wikilink resolution) against the fifteen tables
  named in SOP-002.
- Regenerated `mypka.db` at the vault root (drop-and-recreate strategy,
  the SOP-002 default for a vault this size).
- Wrote this migration report.

## Schema produced

```sql
CREATE TABLE people (
    id INTEGER PRIMARY KEY,
    slug TEXT UNIQUE NOT NULL,
    full_name TEXT,
    first_name TEXT,
    last_name TEXT,
    goes_by TEXT,
    maiden_name TEXT,
    relation TEXT,
    email TEXT,
    phone TEXT,
    city TEXT,
    birth_date TEXT,
    linkedin_url TEXT,
    company TEXT,
    role TEXT,
    last_contact TEXT,
    notes TEXT
);

CREATE TABLE organizations (
    id INTEGER PRIMARY KEY,
    slug TEXT UNIQUE NOT NULL,
    name TEXT,
    type TEXT,
    industry TEXT,
    website TEXT,
    email TEXT,
    phone TEXT,
    city TEXT,
    notes TEXT
);

CREATE TABLE topics (
    id INTEGER PRIMARY KEY,
    slug TEXT UNIQUE NOT NULL,
    name TEXT,
    description TEXT,
    extra_json TEXT
);

CREATE TABLE key_elements (
    id INTEGER PRIMARY KEY,
    slug TEXT UNIQUE NOT NULL,
    name TEXT,
    description TEXT,
    extra_json TEXT
);

CREATE TABLE projects (
    id INTEGER PRIMARY KEY,
    slug TEXT UNIQUE NOT NULL,
    name TEXT,
    description TEXT,
    extra_json TEXT
);

CREATE TABLE goals (
    id INTEGER PRIMARY KEY,
    slug TEXT UNIQUE NOT NULL,
    name TEXT,
    description TEXT,
    key_element_id INTEGER,
    extra_json TEXT,
    FOREIGN KEY (key_element_id) REFERENCES key_elements(id)
);

CREATE TABLE habits (
    id INTEGER PRIMARY KEY,
    slug TEXT UNIQUE NOT NULL,
    name TEXT,
    description TEXT,
    extra_json TEXT
);

CREATE TABLE hosts (
    id INTEGER PRIMARY KEY,
    slug TEXT UNIQUE NOT NULL,
    name TEXT,
    host_type TEXT,
    status TEXT,
    provider TEXT,
    os TEXT,
    location TEXT,
    specs TEXT,
    ip_public TEXT,
    ip_public_v6 TEXT,
    ip_lan TEXT,
    ip_tailscale TEXT,
    dns_name TEXT,
    access TEXT,
    secrets_ref TEXT,
    renewal_date TEXT,
    monthly_cost TEXT,
    notes TEXT
);

CREATE TABLE accounts (
    id INTEGER PRIMARY KEY,
    slug TEXT UNIQUE NOT NULL,
    name TEXT,
    status TEXT,
    account_type TEXT,
    provider_url TEXT,
    username TEXT,
    plan TEXT,
    monthly_cost TEXT,
    renewal_date TEXT,
    secrets_ref TEXT,
    env_var_names TEXT,
    notes TEXT
);

CREATE TABLE services (
    id INTEGER PRIMARY KEY,
    slug TEXT UNIQUE NOT NULL,
    name TEXT,
    status TEXT,
    service_type TEXT,
    runtime TEXT,
    install_path TEXT,
    repo_path TEXT,
    url TEXT,
    schedule TEXT,
    env_file TEXT,
    monitoring TEXT,
    host_id INTEGER,
    ports TEXT,
    env_var_names TEXT,
    notes TEXT,
    FOREIGN KEY (host_id) REFERENCES hosts(id)
);

CREATE TABLE software (
    id INTEGER PRIMARY KEY,
    slug TEXT UNIQUE NOT NULL,
    name TEXT,
    status TEXT,
    software_type TEXT,
    vendor TEXT,
    version TEXT,
    license_ref TEXT,
    renewal_date TEXT,
    monthly_cost TEXT,
    notes TEXT
);

CREATE TABLE documents (
    id INTEGER PRIMARY KEY,
    slug TEXT UNIQUE NOT NULL,
    title TEXT,
    doc_type TEXT,
    physical_location TEXT,
    digital_location TEXT,
    expiry_date TEXT,
    renewal_trigger TEXT,
    notes TEXT
);

CREATE TABLE journal (
    id INTEGER PRIMARY KEY,
    slug TEXT UNIQUE NOT NULL,
    entry_date TEXT,
    category TEXT,
    entry_type TEXT,
    mood TEXT,
    energy TEXT,
    title TEXT,
    content TEXT,
    key_element_id INTEGER,
    project_id INTEGER,
    topic_id INTEGER,
    tags TEXT,
    FOREIGN KEY (key_element_id) REFERENCES key_elements(id),
    FOREIGN KEY (project_id) REFERENCES projects(id),
    FOREIGN KEY (topic_id) REFERENCES topics(id)
);

CREATE TABLE journal_media (
    id INTEGER PRIMARY KEY,
    journal_id INTEGER NOT NULL,
    file_path TEXT,
    media_type TEXT,
    mime_type TEXT,
    caption TEXT,
    image_data BLOB,
    sort_order INTEGER,
    FOREIGN KEY (journal_id) REFERENCES journal(id)
);

CREATE TABLE content_index (
    id INTEGER PRIMARY KEY,
    source_table TEXT NOT NULL,
    source_id INTEGER NOT NULL,
    target_table TEXT NOT NULL,
    target_id INTEGER NOT NULL
);
```

## Row counts

| Table | Rows |
|---|---|
| people | 12 |
| organizations | 3 |
| topics | 8 |
| projects | 11 |
| key_elements | 5 |
| goals | 2 |
| habits | 1 |
| documents | 737 |
| hosts | 11 |
| services | 2 |
| accounts | 11 |
| software | 3 |
| journal | 3 |
| journal_media | 0 |
| content_index | 15 |

Counts reconcile against on-disk file counts for every folder except
`PKM/Documents/`, which is not flat (see "Notable finding" below) - 737
documents landed after recursively walking the folder and excluding two
files under a hidden `.esphome/` build-artifact tree (see below).
`journal_media` is 0 by design, not a bug: SOP-002 sources `journal_media`
rows from a `## Media` heading inside a journal entry, and none of the three
journal entries use that heading. `2026-05-04-first-day.md` does embed
`![[Images/2026/05/2026-05-04-sample-screenshot.png]]`, but inline in the
body prose with no `## Media` section wrapper, so per SOP-002's exact
mapping it correctly produces zero `journal_media` rows rather than a
guessed-at one. Flagging in case the intent was for that embed to be
captured - if so, either the entry needs a `## Media` heading added, or
SOP-002's mapping needs to loosen to catch bare embeds too (a schema
decision, not mine to make unilaterally).

## Notable findings (read before trusting this DB blindly)

1. **`PKM/Documents/` is not flat.** Unlike the other eleven entity folders,
   Documents has organically grown ~150 category subfolders (rentals/,
   woodworking/, homelab/, investing/, etc.) holding 737 markdown files -
   far more than the single flat file SOP-002's baseline schema assumed.
   The script now walks recursively. Because the same filename stem recurs
   across subfolders (12 collisions found - e.g. three different
   `frame-top-dxf.md` files under different CNC-axis folders, two different
   `lead-disclosure.md` files under different rental properties), the
   `documents.slug` column stores the path relative to `PKM/Documents/`
   (posix-style, no extension) rather than the bare filename stem that
   every other entity table uses. This is a deliberate, documented deviation
   from SOP-002's baseline mapping table, not silent schema improvisation -
   it should be ratified into SOP-002 itself if this pattern is expected to
   recur (flag for Hawkeye/user: propose a SOP-002 amendment).
2. **A hidden build-artifact tree was found inside the vault under
   `PKM/Documents/pool/.esphome/build/...`** - an ESPHome/PlatformIO build
   directory (`.piolibdeps`, `.pioenvs`) containing vendored third-party
   library files (libsodium, noise-c), two of which are `.md` files
   (`README.md`). These are not myPKA documents; they are build output that
   appears to have been copied into the vault rather than left in the
   pool-monitor project's own dev folder. The script excludes any path
   containing a dot-prefixed folder segment, so these 2 files were not
   ingested as `documents` rows. **This is worth a cleanup pass outside of
   this SOP-002 run** - recommend routing to Bastion or the user to confirm
   whether `PKM/Documents/pool/.esphome/` should be deleted from the vault
   entirely (it is build output, not a document).
3. **515 files failed frontmatter parsing** - all for the same reason ("no
   YAML frontmatter block found"), not a script bug. Breakdown below. The
   large majority (470 of 515) are pre-existing bulk-imported rental/
   woodworking/CNC documents that predate frontmatter discipline being
   applied to the Documents folder, plus 9 seeded-course-sample My Life/
   Environment notes that were never converted from the original
   free-prose scaffold shape. No fabrication occurred - every missing field
   landed as `NULL` per SOP-002's hard rule 2.

### Parse failures by folder (515 total)

| Folder | Count | Notes |
|---|---|---|
| `Documents/rentals` | 317 | no YAML frontmatter block found |
| `Documents/woodworking` | 139 | no YAML frontmatter block found |
| `My Life` | 10 | no YAML frontmatter block found |
| `Documents/homelab` | 10 | no YAML frontmatter block found |
| `Documents/branding` | 8 | no YAML frontmatter block found |
| `Documents/lake-erie` | 8 | no YAML frontmatter block found |
| `Documents/drones` | 6 | no YAML frontmatter block found |
| `Documents/investing` | 6 | no YAML frontmatter block found |
| `Environment` | 4 | no YAML frontmatter block found |
| `Documents/automobiles` | 2 | no YAML frontmatter block found |
| `Documents/pool` | 2 | no YAML frontmatter block found |
| `Documents/food` | 1 | no YAML frontmatter block found |
| `Documents/genealogy` | 1 | no YAML frontmatter block found |
| `Documents/travel` | 1 | no YAML frontmatter block found |

### Full parse-failure list (path -- reason)

<details><summary>Expand full list (515 files)</summary>

```
PKM/My Life/Topics/ai-tooling.md -- no YAML frontmatter block found
PKM/My Life/Topics/drone-builds.md -- no YAML frontmatter block found
PKM/My Life/Topics/homelab-infrastructure.md -- no YAML frontmatter block found
PKM/My Life/Topics/investing.md -- no YAML frontmatter block found
PKM/My Life/Topics/oracle-erp-delivery.md -- no YAML frontmatter block found
PKM/My Life/Topics/personal-branding.md -- no YAML frontmatter block found
PKM/My Life/Key Elements/health.md -- no YAML frontmatter block found
PKM/My Life/Projects/side-project-mvp.md -- no YAML frontmatter block found
PKM/My Life/Habits/morning-build-session.md -- no YAML frontmatter block found
PKM/Environment/Hosts/lighthouse.md -- no YAML frontmatter block found
PKM/Environment/Hosts/opnsense-r340.md -- no YAML frontmatter block found
PKM/Environment/Hosts/watchtower.md -- no YAML frontmatter block found
PKM/My Life/Goals/ship-mvp-by-q3.md -- no YAML frontmatter block found
PKM/Environment/Software/claude-code.md -- no YAML frontmatter block found
PKM/Documents/automobiles/fleet-overview.md -- no YAML frontmatter block found
PKM/Documents/automobiles/vehicles/2008-subaru-outback.md -- no YAML frontmatter block found
PKM/Documents/branding/best-of-class-resume-2026-draft.md -- no YAML frontmatter block found
PKM/Documents/branding/jeffrey-davis-best-of-class-resume-2026.md -- no YAML frontmatter block found
PKM/Documents/branding/jeffrey-davis-bio-2026.md -- no YAML frontmatter block found
PKM/Documents/branding/jeffrey-davis-perficient-resume-2026.md -- no YAML frontmatter block found
PKM/Documents/branding/jeffrey-davis-pmo-director.md -- no YAML frontmatter block found
PKM/Documents/branding/jeffrey-positioning.md -- no YAML frontmatter block found
PKM/Documents/branding/master-resume.md -- no YAML frontmatter block found
PKM/Documents/branding/perficient-resume-2026-draft.md -- no YAML frontmatter block found
PKM/Documents/drones/2026-04-17-farragut-motor-selection.md -- no YAML frontmatter block found
PKM/Documents/drones/2026-04-17-resolute-gps-decision.md -- no YAML frontmatter block found
PKM/Documents/drones/farragut.md -- no YAML frontmatter block found
PKM/Documents/drones/intrepid.md -- no YAML frontmatter block found
PKM/Documents/drones/resolute.md -- no YAML frontmatter block found
PKM/Documents/drones/shared-kit.md -- no YAML frontmatter block found
PKM/Documents/food/equipment.md -- no YAML frontmatter block found
PKM/Documents/genealogy/research-status.md -- no YAML frontmatter block found
PKM/Documents/homelab/2026-04-17-homelab-servers-handoff.md -- no YAML frontmatter block found
PKM/Documents/homelab/2026-04-17-lighthouse-r730xd-chassis-upgrade.md -- no YAML frontmatter block found
PKM/Documents/homelab/build-log.md -- no YAML frontmatter block found
PKM/Documents/homelab/homelab-servers-handoff-2026-04-17.md -- no YAML frontmatter block found
PKM/Documents/homelab/lighthouse-r730xd-pka-update-2026-04.md -- no YAML frontmatter block found
PKM/Documents/homelab/Lighthouse-R730XD-PKA-Update-April-2026.md -- no YAML frontmatter block found
PKM/Documents/homelab/network-build.md -- no YAML frontmatter block found
PKM/Documents/homelab/network-schema.md -- no YAML frontmatter block found
PKM/Documents/homelab/parts-compatibility.md -- no YAML frontmatter block found
PKM/Documents/homelab/reference-docs/lighthouse-r730xd-pka-update-2026-04.md -- no YAML frontmatter block found
PKM/Documents/investing/portfolio/holdings.md -- no YAML frontmatter block found
PKM/Documents/investing/strategies/crypto-strategy.md -- no YAML frontmatter block found
PKM/Documents/investing/strategies/equity-strategy.md -- no YAML frontmatter block found
PKM/Documents/investing/strategies/master-strategy.md -- no YAML frontmatter block found
PKM/Documents/investing/watchlists/crypto.md -- no YAML frontmatter block found
PKM/Documents/investing/watchlists/equities.md -- no YAML frontmatter block found
PKM/Documents/lake-erie/2026-04-13-put-in-scheduling.md -- no YAML frontmatter block found
PKM/Documents/lake-erie/2026-04-13-survey-summary-sea-ray.md -- no YAML frontmatter block found
PKM/Documents/lake-erie/fishin-impossible.md -- no YAML frontmatter block found
PKM/Documents/lake-erie/lake-erie-intel.md -- no YAML frontmatter block found
PKM/Documents/lake-erie/maintenance-log.md -- no YAML frontmatter block found
PKM/Documents/lake-erie/sea-ray-340-survey-2020.md -- no YAML frontmatter block found
PKM/Documents/lake-erie/sea-ray-340.md -- no YAML frontmatter block found
PKM/Documents/lake-erie/seadoo-rti.md -- no YAML frontmatter block found
PKM/Documents/pool/00-STATUS-SUMMARY.md -- no YAML frontmatter block found
PKM/Documents/pool/pool-monitor-build-guide.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/2014-2015-guthrie-3007-chestnut.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/2014-2015-perez-3005-chestnut.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/2015-2016-guthrie-3007-chestnut.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/2016-2017-guthrie-3007-chestnut.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/2016-parente-3007-chestnut.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/2017-2018-dolan-3007-chestnut.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/2017-2018-perez-3005-chestnut.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/2018-2018-dolan-3007-chestnut.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/2018-2019-perez-3005-chestnut.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/2019-2020-deyarmin-ponce-3007-chestnut.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/2019-2020-perez-3005-chestnut.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/2020-2021-deyarmin-ponce-3007-chestnut.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/2020-2021-perez-3005-chestnut.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/2021-2022-perez-2005-chestnut.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/2021-2022-perez-3005-chestnut.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/2021-2022-tran-pauline-3007-chestnut-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/2021-2022-tran-pauline-3007-chestnut-fully-exec.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/2021-2022-tran-pauline-3007-chestnut.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/20210504183822.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/20210504183835.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/20210504183857.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/20210504183926.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/20210504183951.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/20210504184005.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/20210504184042.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/20210504184054.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/20210504184102.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/20210504184110.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/20210504184124.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/20210504184131.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/20210504184149.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/20210504184154.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/2022-2023-tran-pauline-3007-chestnut-fully-exec.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/2022-2023-tran-pauline-3007-chestnut.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/2023/2022-2023-west-9th-cosignagreement-jjd-signed.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/2023/2023-2024-steves-3005-chestnut-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/2023/2023-2024-steves-3005-chestnut.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/2023/2023-2024-tran-pauline-3007-chestnut-signed.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/2023/2023-2024-tran-pauline-3007-chestnut.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/2023/lead-disclosure-steves-2023.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/2023/leadinyourhomebrochurelandbw508easypr.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/2025/2025-2026-wofle-3007-chestnut-lease.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/2025/lead-disclosure-wolfe-3007-chestnut.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/2026/2026-2027-ebner-3005-chestnut-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/2026/2026-2027-ebner-3005-chestnut.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/2026/2026-ebner-lead-disclosure.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/appliances-receipt-2022-for-erie-insurance.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/do-not-have-document.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/final-statement-guthrie.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/final-statment-perez-2022-06-05.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/floor1-bathroom.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/floor1-bathroom2.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/floor1-bedroom.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/floor1-bedroom2.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/floor1-dinning-room.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/floor1-dinning-room2.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/floor1-dinning-room3.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/floor1-kitchen.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/floor1-kitchen2.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/floor1-kitchen3.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/floor1-living-room.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/floor1-living-room2.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/floor1-living-room3.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/guthrie-account-2016-08-04.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/guthrie-eviction-notice-2016-05-16.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/guthrie-lease-2013-02-13.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/lead-disclosure-tran-pauline-3007-chestnut-2021.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/lead-disclosure-tran-pauline-3007-chestnut-20211.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/lupole-lease-2013-03-05.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/perez-2021-11-14-21-past-due-amount.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/perez-5-day-default-notice-2019-09-27.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/perez-5-day-default-notice-2019-11-17.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/perez-5-day-default-notice-2020-03-03.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/perez-5-day-default-notice-2021-12-14.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/perez-5-day-default-notice-2022-04-13.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/perez-5-day-default-notice.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/perez-damage-3005-chestnut-2022-05-27.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/perez-end-of-lease-letter-2021-06-01.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/perez-gecac-package-completed.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/perez-original-gecac-package.md -- no YAML frontmatter block found
PKM/Documents/rentals/chestnut-street/perez-termination-of-lease-2005-chestnut.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/2014/2014-2015-littlefield-lease.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/2014/littlefield-lease.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/2015/2015-2016-littlefield-lease.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/2015/littlefield-default-notice-2015-7-14.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/2021/2021-2022-russ-lease-fully-executed.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/2021/2021-2022-russ-lease.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/2021/lead-disclosure-russ-2021-01-09.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/2022/2022-2023-russ-lease-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/2022/2022-2023-russ-lease.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/2023/2023-2024-russ-lease-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/2023/2023-2024-russ-lease-fully-executed.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/2023/2023-2024-russ-lease.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/2024/2024-2025-russ-lease-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/2024/2024-2025-russ-lease.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/bathroom-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/bathroom-2.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/bedroom-back.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/eviction-notice-littlefield-2016-05-02.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/final-statement-littlefield.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/house-outside-street.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/img-0812.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/img-0813.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/img-0814.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/img-0815.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/img-0816.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/img-0817.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/img-0818.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/img-0819.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/img-0820.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/img-0821.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/img-0822.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/img-0823.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/img-0824.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/img-0825.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/img-0826.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/kens-court-date-balance-8-20-2015.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/kitchen.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/littlefield-account-7-19-2014.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/littlefield-billing-statement-8-29-14.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/living-room-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/living-room-2.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/notice-to-vacate-littlefield-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/east-32nd-street/notice-to-vacate-littlefield.md -- no YAML frontmatter block found
PKM/Documents/rentals/expenses/2012-expesnes.md -- no YAML frontmatter block found
PKM/Documents/rentals/expenses/2013-expesnes.md -- no YAML frontmatter block found
PKM/Documents/rentals/expenses/2014-expesnes.md -- no YAML frontmatter block found
PKM/Documents/rentals/expenses/2015-expesnes.md -- no YAML frontmatter block found
PKM/Documents/rentals/expenses/2016-expesnes.md -- no YAML frontmatter block found
PKM/Documents/rentals/expenses/2017-expesnes.md -- no YAML frontmatter block found
PKM/Documents/rentals/expenses/2018-expesnes.md -- no YAML frontmatter block found
PKM/Documents/rentals/expenses/2019-expesnes.md -- no YAML frontmatter block found
PKM/Documents/rentals/expenses/2020-expenses.md -- no YAML frontmatter block found
PKM/Documents/rentals/expenses/2021-apt-revenue.md -- no YAML frontmatter block found
PKM/Documents/rentals/expenses/2021-expenses.md -- no YAML frontmatter block found
PKM/Documents/rentals/expenses/2022-expenses.md -- no YAML frontmatter block found
PKM/Documents/rentals/expenses/2022-income.md -- no YAML frontmatter block found
PKM/Documents/rentals/expenses/2023-expenses.md -- no YAML frontmatter block found
PKM/Documents/rentals/expenses/2023-income.md -- no YAML frontmatter block found
PKM/Documents/rentals/expenses/2024-expenses-backup.md -- no YAML frontmatter block found
PKM/Documents/rentals/expenses/2024-expenses.md -- no YAML frontmatter block found
PKM/Documents/rentals/expenses/2024-income.md -- no YAML frontmatter block found
PKM/Documents/rentals/expenses/2025-expenses.md -- no YAML frontmatter block found
PKM/Documents/rentals/expenses/2025-income.md -- no YAML frontmatter block found
PKM/Documents/rentals/shared-documents/2021-rental-list.md -- no YAML frontmatter block found
PKM/Documents/rentals/shared-documents/alyssa-2019-lease-additional.md -- no YAML frontmatter block found
PKM/Documents/rentals/shared-documents/alyssa-2019-lease.md -- no YAML frontmatter block found
PKM/Documents/rentals/shared-documents/credit-authorization-loi-5-2-14.md -- no YAML frontmatter block found
PKM/Documents/rentals/shared-documents/lead-disclosure-west-9th.md -- no YAML frontmatter block found
PKM/Documents/rentals/shared-documents/lead-disclosure.md -- no YAML frontmatter block found
PKM/Documents/rentals/shared-documents/leadinyourhomebrochurelandbw508easypr.md -- no YAML frontmatter block found
PKM/Documents/rentals/shared-documents/plain-language-lease.md -- no YAML frontmatter block found
PKM/Documents/rentals/shared-documents/rental-application.md -- no YAML frontmatter block found
PKM/Documents/rentals/shared-documents/rental-cosignagreement.md -- no YAML frontmatter block found
PKM/Documents/rentals/shared-documents/w9-jeffrey-davis-signature.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/14733-300x.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/14734-300x.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/14735-300x.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/14736-300x.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/14737-300x.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/14738-300x.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2013-2014-317-west-9th.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2013-2014-davis-319-west-9th.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2013-2014-dietz-319-west-9th.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2013-2014-drake-319-west-9th.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2013-2014-paterson-319-west-9th.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2014-2015-317-west-9th.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2014-2015-osborne-319-west-9th-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2014-2015-osborne-319-west-9th.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2014-2015-paterson-319-west-9th.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2016-2017-317-west-9th.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2016-2017-unger-319-west-9th.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2017/2014-2015-paterson-319-west-9th-example.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2017/2017-2018-317-west-9th-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2017/2017-2018-317-west-9th-fagley-cosignagreement-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2017/2017-2018-317-west-9th-fagley-cosignagreement.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2017/2017-2018-317-west-9th-riley-cosignagreement-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2017/2017-2018-317-west-9th-riley-cosignagreement.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2017/2017-2018-317-west-9th-schon-cosignagreement-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2017/2017-2018-317-west-9th-schon-cosignagreement.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2017/2017-2018-317-west-9th.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2017/2017-2018-319-west-9th-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2017/2017-2018-319-west-9th-frauenknect-cosignagreem-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2017/2017-2018-319-west-9th-frauenknect-cosignagreem.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2017/2017-2018-319-west-9th-kisel-cosignagreement-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2017/2017-2018-319-west-9th-kisel-cosignagreement.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2017/2017-2018-319-west-9th-miller-cosignagreement-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2017/2017-2018-319-west-9th-miller-cosignagreement.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2017/2017-2018-319-west-9th.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2017/2017-2018-319-west-9th1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2017/w9th-street-renter-addresses-2017.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2018/2018-2019-319-west-9th-callaway-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2018/2018-2019-319-west-9th-callaway-cosignagreement-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2018/2018-2019-319-west-9th-callaway-cosignagreement.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2018/2018-2019-319-west-9th-callaway.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2018/2018-2019-319-west-9th-fuhrman-cosignagreement.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2018/2018-2019-319-west-9th-fuhrman-nesser.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2018/2018-2019-319-west-9th-nesser-cosignagreement.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2018/lead-disclosure-attachmenta-west-9th-street.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2019/2018-2019-317-west-9th.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2019/2019-2020-317-west-9th-chambers-cosignagreement.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2019/2019-2020-317-west-9th.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2019/2019-2020-319-west-9th-hawkins-cosign-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2019/2019-2020-319-west-9th-hawkins-cosign.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2019/2019-2020-319-west-9th-johnson-cosign-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2019/2019-2020-319-west-9th-johnson-cosign.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2019/2019-2020-319-west-9th-milostan-cosign-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2019/2019-2020-319-west-9th-milostan-cosign.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2019/2019-2020-319-west-9th-milostan-hawkins-johnson-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2019/2019-2020-319-west-9th-milostan-hawkins-johnson.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2019/lead-disclosure-2019-319-west-9th.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2020/2020-2021-317-west-9th.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2020/2020-2021-319-west-9th.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2020/319-clean-up-invoice.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2021/2020-2021-319-west-9th.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2021/2021-2021-317-west-9th.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2021/2021-2022-319-west-9th-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2021/2021-2022-319-west-9th-2.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2021/2021-2022-319-west-9th-co-sign-agreement.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2021/2021-2022-319-west-9th.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2021/319-west-9th-clean-up-invoice.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2021/lead-disclosure-319-west-9th.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2021/rental-application.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100442-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100442.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100451-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100451.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100455-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100455.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100512-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100512.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100516-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100516.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100521-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100521.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100528-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100528.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100530-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100530.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100534-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100534.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100537-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100537.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100539-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100539.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100543-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100543.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100550-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100550.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100555-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100555.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100600-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100600.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100604-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100604.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100610-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100610.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100630-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100630.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100633-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100633.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100636-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100636.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100638-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100638.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100641-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100641.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100648-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100648.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100651-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/20210801100651.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2022/2022-2023-319-west-9th.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2022/2022-2023-west-9th-cosignagreement.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2022/319-west-9th-clean-up-invoice.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2022/lease-addendum-319-west-9th-street-2023-06-18.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2022/lease-addendum-319-west-9th-street-2023-06-20.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2023/2023-2024-319-west-9th-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2023/2023-2024-319-west-9th.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2023/2023-2024-west-9th-cosignagreement-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2023/2023-2024-west-9th-cosignagreement.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2023/319-west-9th-clean-up-and-repairs-final-invoice.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2023/319-west-9th-door-repairs.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2023/lead-disclosure-west-9th.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2024/2024-2025-319-west-9th-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2024/2024-2025-319-west-9th-new-tenants.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2024/2024-2025-319-west-9th.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2024/319-west-9th-clean-up-invoice-2025.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2024/319-west-9th-st-non-renewal-of-lease-2025.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2024/319-west-9th-street-additional-tenants-2024-202.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/2024/lead-disclosure.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/317-west-9th-lease-document.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/317-west-9th.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/319-west-9th-lease-documents.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/319-west-9th-street-rent.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/alyssa-rent.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/dean-davis-agreement.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/docs-1353144-v1-deanaddendum.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/e130212-10-davis-w9th-insp-t-r.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/img20260614134855-1-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/img20260614134855-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/img20260614134855-2-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/img20260614134855-2.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/img20260614134855-3-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/img20260614134855-3.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/img20260614134855-4-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/img20260614134855-4.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/img20260614134855-5-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/img20260614134855-5.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/img20260614134855-6-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/img20260614134855-6.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/img20260614134855-7-1.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/img20260614134855-7.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/img20260614134855.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/signature-page.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/west-9th-insurance-form.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/west-9th-street-material-list.md -- no YAML frontmatter block found
PKM/Documents/rentals/west-9th-street/west-9th-street-renters-2017.md -- no YAML frontmatter block found
PKM/Documents/travel/travel-documents.md -- no YAML frontmatter block found
PKM/Documents/woodworking/all-in-one-bench-imperial-complete-pdf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/boo-tech-cnc/cnc-plans-v2-pdf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/diy-guide-rails-plans-vsc-tools-pdf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/drill-bit-test-results-docx.md -- no YAML frontmatter block found
PKM/Documents/woodworking/folding-table-base-docx.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/204709-lowrider-3-cnc-8b05c3d4-8be1-47d5-861d-8-pdf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/bearing-wheel-bracket-front-3mf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/bearing-wheel-bracket-rear-3mf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/brace-23p4-3mf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/brace-25-3mf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/brace-25p4-3mf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/front-rail-roller-3mf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/front-y-belt-base-3mf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/front-y-belt-base-right-3mf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/front-y-belt-holder-3mf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/front-y-belt-holder-right-3mf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/hose-hanger-3mf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/lr-core-3mf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/rail-block-18p1-3mf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/rail-block-23p4-3mf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/rail-block-25mm-3mf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/rail-block-25p4-3mf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/rear-rail-roller-3mf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/strut-plate-1400mm-dxf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/strut-plate-790mm-dxf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/temporary-strut-3mf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/x-drive-mount-3mf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/x-tensioner-3mf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/xz-leadscrew-stub-3mf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/xz-leadscrew-stub-right-3mf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/xz-plate-dxf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/xz-plate-left-3mf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/xz-plate-right-3mf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/y-drive-3mf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/y-tension-base-rear-3mf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/y-tension-base-rear-right-3mf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/y-tension-block-rear-3mf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/y-tension-block-rear-right-3mf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/yz-plate-dxf-v1-dxf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/yz-plate-dxf-v1-mirrored-dxf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/yz-plate-v1-3mf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/z-drive-3mf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/z-stop-m-v1-3mf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files/z-stop-v1-3mf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-3-cnc/lowrider-3-cnc-model-files-zip.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-4-cnc/lowrider-cnc-4-antibacklash-fixture/case-for-fluiddial-cnc-pendant-for-fluidnc-w-m5-zip.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-4-cnc/lowrider-cnc-4-calculator-xlsx.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-4-cnc/lowrider-cnc-4-fluid-dial-case/999824-case-for-fluiddial-cnc-pendant-for-fluid-pdf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-4-cnc/lowrider-cnc-4-fluid-dial-case/case-for-fluiddial-cnc-pendant-for-fluidnc-w-m5-zip.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-4-cnc/lowrider-cnc-4-fluid-dial-case/fluid-dial-bottom-no-magnets-w-support-for-bdri-stl.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-4-cnc/lowrider-cnc-4-fluid-dial-case/fluid-dial-bottom-with-magnets-in-w-support-for-stl.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-4-cnc/lowrider-cnc-4-fluid-dial-case/fluid-dial-bottom-with-magnets-out-w-support-fo-stl.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-4-cnc/lowrider-cnc-4-fluid-dial-case/fluid-dial-top-w-support-for-bdring-starter-kit-stl.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-4-cnc/lowrider-cnc-4-fluid-dial-case/stand-off-options-for-m3-machine-screw/stand-off-for-pcb-on-jackpot-for-m3-screw-stl.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-4-cnc/lowrider-cnc-4-fluid-dial-case/stand-off-options-for-m3-machine-screw/stand-off-for-pcb-on-jackpot-w-cat5-anchor-loop-stl.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-4-cnc/lowrider-cnc-4-fluid-dial-case/stand-off-options-for-tapered-self-tapping-screw/stand-off-for-pcb-on-jackpot-tapered-screw-stl.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-4-cnc/lowrider-cnc-4-fluid-dial-case/stand-off-options-for-tapered-self-tapping-screw/stand-off-for-pcb-on-jackpot-w-cat5-anchor-loop-stl.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-4-cnc/lowrider-cnc-4-fluid-dial-cradle/fluiddial-cradle-lr4-by-design8studio-v2-2-stl.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-4-cnc/lowrider-cnc-4-kinematic-tool-change-main-parta-do/lowrider-v4-cnc-kinematic-tool-less-quick-chang-zip.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-4-cnc/lowrider-cnc-4-kolbat-holder-3d-files/kobalt-tool-mount-and-dust-shoe-for-the-lowride-zip.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-4-cnc/lowrider-cnc-4-main-3d-files/lowrider-4-cnc-model-files-zip.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-4-cnc/lowrider-cnc-4-modified-mounts-for-doug-jamie-re/492583-modified-mounts-for-dougs-kinematic-lr3-pdf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-4-cnc/lowrider-cnc-4-modified-mounts-for-doug-jamie-re/fixed-base-mountains-bolt-clearance-stl.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-4-cnc/lowrider-cnc-4-modified-mounts-for-doug-jamie-re/long-double-pen-stl.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-4-cnc/lowrider-cnc-4-modified-mounts-for-doug-jamie-re/long-double-pen-x3-stl.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-4-cnc/lowrider-cnc-4-modified-mounts-for-doug-jamie-re/mobile-base-valleys-hex-stl.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-4-cnc/lowrider-cnc-4-modified-mounts-for-doug-jamie-re/modified-mounts-for-dougs-kinematic-lr3-accesso-zip.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-4-cnc/lowrider-cnc-4-modified-mounts-for-doug-jamie-re/neje-fixed-backend-stl.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-4-cnc/lowrider-cnc-4-modified-mounts-for-doug-jamie-re/part-a-main-mount-for-dw660-primo-and-lr3-stl.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-4-cnc/lowrider-cnc-4-modified-mounts-for-doug-jamie-re/part-b-fixed-base-with-mountains-stl.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-4-cnc/lowrider-cnc-4-modified-mounts-for-doug-jamie-re/part-c-mobile-base-with-valleys-stl.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-4-cnc/lowrider-cnc-4-modified-mounts-for-doug-jamie-re/soft-pen-holder-stl.md -- no YAML frontmatter block found
PKM/Documents/woodworking/lowrider-4-cnc/lowrider-cnc-4-peter-plates-3d-files/peter-plates-lowrider-4-model-files-zip.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/x-axis/base-frame-v2-dxf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/x-axis/base-frame-v2-idw.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/x-axis/base-frame-v2-pdf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/x-axis/frame-top-dxf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/x-axis/frame-top-idw.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/x-axis/frame-top-pdf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/x-axis/r-and-p-drive-assembly-pdf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/x-axis/rcncx2-idw.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/x-axis/rcncx2-pdf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/x-axis/rp-drive-antibacklash-assemblyparts-stp.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/x-axis/x-axis-bearing-mount-v2-dxf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/x-axis/x-axis-bearing-mount-v2-idw.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/x-axis/x-axis-bearing-mount-v2-pdf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/y-axis/ballnut-bracket-dxf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/y-axis/ballnut-bracket-idw.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/y-axis/ballnut-bracket-pdf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/y-axis/frame-top-dxf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/y-axis/frame-top-idw.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/y-axis/frame-top-pdf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/y-axis/proximity-mount-v2-dxf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/y-axis/proximity-mount-v2-idw.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/y-axis/proximity-mount-v2-pdf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/y-axis/rm2010-y-dxf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/y-axis/rm2010-y-idw.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/y-axis/rm2010-y-pdf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/y-axis/spacer-mba-dxf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/y-axis/spacer-mba-idw.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/y-axis/spacer-mba-pdf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/y-axis/y-axis-v3-dxf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/y-axis/y-axis-v3-idw.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/y-axis/y-axis-v3-pdf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/y-axis/y-sidewall-v3-y-dxf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/y-axis/y-sidewall-v3-y-idw.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/y-axis/y-sidewall-v3-y-pdf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/y-axis/y-sidewall-v3-y-plus-dxf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/y-axis/y-sidewall-v3-y-plus-idw.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/y-axis/y-sidewall-v3-y-plus-pdf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/z-axis/back-plate-v4-dxf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/z-axis/back-plate-v4-idw.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/z-axis/back-plate-v4-pdf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/z-axis/front-plate-v5-dxf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/z-axis/front-plate-v5-idw.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/z-axis/front-plate-v5-pdf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/z-axis/rm16-mount-v2-dxf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/z-axis/rm16-mount-v2-idw.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/z-axis/rm16-mount-v2-pdf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/z-axis/rm1605-z2-idw.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/z-axis/rm1605-z2-pdf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/z-axis/spacer-v3-dxf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/z-axis/spacer-v3-idw.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/z-axis/spacer-v3-pdf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/z-axis/tekno-plate-v2-dxf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/z-axis/tekno-plate-v2-idw.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/z-axis/tekno-plate-v2-pdf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/z-axis/top-plate-v4-dxf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/z-axis/top-plate-v4-idw.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/z-axis/top-plate-v4-pdf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/z-axis/z-axis-v5-dxf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/z-axis/z-axis-v5-idw.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/axis/z-axis/z-axis-v5-pdf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/electronics/roboeth-pdf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/partlist-xlsx.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/rcncx2-rar.md -- no YAML frontmatter block found
PKM/Documents/woodworking/robo-cnc/release-notes-txt.md -- no YAML frontmatter block found
PKM/Documents/woodworking/rolling-toolbox-pdf.md -- no YAML frontmatter block found
PKM/Documents/woodworking/woodshop-projects-txt.md -- no YAML frontmatter block found
```
</details>


## Unresolved wikilinks (3)

- `journal:2026-05-04-first-day` -> `[[dr-schmidt]]` - no matching
  `PKM/CRM/People/` file exists (the doctor from the seeded first-day entry
  was apparently never filed as a Person note under that slug).
- `journal:2026-06-11-environment-registry-kickoff` -> `[[GL-002-frontmatter-conventions]]`
  and `[[INDEX]]` - both correctly unresolved. These are **not** parsing
  failures; they are out-of-scope by design (see finding below).

## On the WS-007 / GL-014 / GL-015 question specifically

SOP-002's schema, as written, only ever ingests the twelve entity folders
under `PKM/` (people, organizations, topics, projects, key_elements, goals,
habits, journal, documents, hosts, services, accounts, software) plus the
`content_index` wikilink-resolution table built by scanning journal and
document bodies against those same twelve folders' slugs. **It has never
covered `Team Knowledge/` (SOPs, Workstreams, Guidelines) or `Team/`
(specialist contracts) at all** - there is no `sops`, `workstreams`, or
`guidelines` table in the schema, and no wikilink-scanning pass over
`Team Knowledge/` bodies. This is not a regression from today's retro; it
is SOP-002's scope boundary as originally written.

Concretely: `[[WS-007-infrastructure-change-lifecycle]]`,
`[[GL-014-windows-shell-interop-gotchas]]`, and
`[[GL-015-credential-expansion-over-new-grants]]` all exist correctly on
disk (confirmed), but the `content_index` table cannot "resolve" them
because nothing in this schema tracks them as targets - and in this vault,
nothing under `PKM/` currently links to them anyway (grepped `PKM/` for all
three slugs, zero hits), so the question is moot for this specific run but
would remain unanswerable even if a journal entry linked to them tomorrow.
**If Hawkeye/the user want the SQLite mirror to cover framework docs
(SOPs/Workstreams/Guidelines/specialist contracts), that is a SOP-002 schema
change** - new tables, a new pass, explicit approval - not something to
improvise inside a routine regen.

## Decisions made

- **Question:** Documents has duplicate filename stems across subfolders -
  overwrite, skip, or key differently?
  **Decision:** Key the `documents` table by path-relative slug instead of
  bare stem. No documents were dropped; nothing was silently overwritten.
- **Question:** The vault contains a `.esphome` build-artifact tree with 2
  stray `.md` files inside `PKM/Documents/pool/` - ingest them as documents?
  **Decision:** Exclude any path with a dot-prefixed folder segment from the
  recursive Documents walk. They are build output, not vault content: not
  the SQLite mirror's job to fix, flagged for a separate cleanup task
  instead.

## Insights

- The vault's real `PKM/Documents/` shape (nested category folders, 737
  files, duplicate stems) is materially different from SOP-002's baseline
  assumption of a flat `Documents/<slug>.md` folder. This has presumably
  been true since the bulk document import referenced in Jeff's
  "Pending bulk document import" project context - SOP-002 itself should
  probably be amended to document the recursive-walk + path-slug behavior
  as the canonical mapping for Documents, rather than leaving each
  conversion run to rediscover it. Flagging for Hawkeye to route as a
  SOP-002 amendment proposal.
- 515 parse failures is a large number but is entirely attributable to two
  known, pre-existing gaps (unconverted bulk-imported Documents, and a
  handful of seeded-course-sample My Life/Environment notes) - not new
  damage from today's framework changes. Worth a dedicated frontmatter
  compliance audit deliverable if the user wants the Documents backlog
  tackled, per Margaret's recurring audit duty.

## Open threads

- [ ] Confirm with Jeff/Bastion whether `PKM/Documents/pool/.esphome/`
      (ESPHome/PlatformIO build output, not vault content) should be
      deleted from the vault.
- [ ] Consider a SOP-002 amendment documenting the Documents recursive-walk
      + path-relative-slug behavior as canonical, since it will recur on
      every future regen otherwise.
- [ ] The 515-file frontmatter gap under `PKM/Documents/` is a known,
      pre-existing backlog (bulk import predates frontmatter discipline) -
      not blocking, but worth a scoped audit deliverable if/when the user
      wants those documents brought up to the GL-002 schema.
- [ ] `dr-schmidt` wikilink in the seeded first-day journal entry has no
      matching Person note - low priority (seeded course sample), flag only.

## Next steps

- No action required for this regen - `mypka.db` is live and reflects
  current vault state including WS-007/GL-014/GL-015 file existence (even
  though those file types are out of SOP-002's tracked-table scope).
- Next regen trigger: another approved WS-004 Tier 2 retro subset landing,
  or the next routine SOP-002 invocation.
