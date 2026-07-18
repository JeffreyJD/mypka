#!/usr/bin/env python3
"""
mypka_to_sqlite.py

Regenerates mypka.db - a SQLite mirror of the myPKA markdown vault.
Markdown stays canonical; this script produces a derived, regeneratable
performance layer. Read-only on the vault; writes only mypka.db and
(by the caller) the migration report.

Implements Team Knowledge/SOPs/SOP-002-convert-mypka-to-sqlite.md.

Usage:
    python mypka_to_sqlite.py [vault_root]

Default vault_root is the current working directory.
"""

import json
import os
import re
import sqlite3
import sys
from pathlib import Path

import yaml

# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------

VAULT_ROOT = Path(sys.argv[1]) if len(sys.argv) > 1 else Path.cwd()
DB_PATH = VAULT_ROOT / "mypka.db"

FRONTMATTER_RE = re.compile(r"^---\s*\n(.*?\n)---\s*\n(.*)$", re.DOTALL)
WIKILINK_RE = re.compile(r"\[\[([^\]|#]+)(?:\|[^\]]*)?(?:#[^\]]*)?\]\]")
# Embeds (![[path]]) are distinct from cross-reference wikilinks ([[slug]]) per
# SOP-002's Context section. This variant excludes any [[...]] immediately
# preceded by "!" so image/file embeds are never treated as entity references.
CROSSREF_RE = re.compile(r"(?<!!)\[\[([^\]|#]+)(?:\|[^\]]*)?(?:#[^\]]*)?\]\]")
H1_RE = re.compile(r"^#\s+(.+)$", re.MULTILINE)

parse_failures = []   # (path, reason)
unresolved_links = []  # (source_table, source_slug, target_slug)


def read_note(path: Path):
    """Return (frontmatter_dict_or_None, body_str) for a markdown file."""
    try:
        raw = path.read_text(encoding="utf-8")
    except UnicodeDecodeError as e:
        parse_failures.append((str(path), f"encoding error: {e}"))
        return None, ""

    m = FRONTMATTER_RE.match(raw)
    if not m:
        parse_failures.append((str(path), "no YAML frontmatter block found"))
        return {}, raw

    fm_text, body = m.group(1), m.group(2)
    try:
        fm = yaml.safe_load(fm_text)
        if fm is None:
            fm = {}
        if not isinstance(fm, dict):
            parse_failures.append((str(path), "frontmatter did not parse to a mapping"))
            fm = {}
    except yaml.YAMLError as e:
        parse_failures.append((str(path), f"YAML parse error: {e}"))
        fm = {}

    return fm, body


def first_h1(body: str):
    m = H1_RE.search(body)
    return m.group(1).strip() if m else None


def body_after_h1(body: str):
    m = H1_RE.search(body)
    if not m:
        return body.strip()
    return body[m.end():].strip()


def list_notes(folder: Path):
    """All .md files directly in folder, excluding INDEX.md, sorted."""
    if not folder.exists():
        return []
    return sorted(
        p for p in folder.glob("*.md")
        if p.name.upper() != "INDEX.MD"
    )


def list_notes_recursive(folder: Path):
    """All .md files anywhere under folder (any depth), excluding INDEX.md.

    Unlike the other eleven entity folders (flat, one file per concept per
    root AGENTS.md), PKM/Documents/ has organically grown category
    subfolders (automobiles/, branding/, 3d-printing/, etc.). Walking
    recursively here is required or hundreds of real documents get silently
    dropped from the mirror.
    """
    if not folder.exists():
        return []
    return sorted(
        p for p in folder.rglob("*.md")
        if p.name.upper() != "INDEX.MD"
        and not any(part.startswith(".") for part in p.relative_to(folder).parts)
    )


def as_list(value):
    """Normalize a frontmatter field that should be a list of slugs."""
    if value is None:
        return []
    if isinstance(value, list):
        return [str(v).strip() for v in value if v]
    if isinstance(value, str):
        # handle inline "[[a]], [[b]]" or single "[[a]]" strings
        found = WIKILINK_RE.findall(value)
        if found:
            return [f.strip() for f in found]
        v = value.strip()
        return [v] if v else []
    return []


def strip_wikilink(s):
    """Strip [[ ]] from a single wikilink-shaped string, else return as-is."""
    if s is None:
        return None
    s = str(s).strip()
    m = WIKILINK_RE.match(s)
    if m:
        return m.group(1).strip()
    return s.lstrip("[").rstrip("]").strip() or None


# ---------------------------------------------------------------------------
# Schema
# ---------------------------------------------------------------------------

SCHEMA = """
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
"""

MIME_MAP = {
    ".png": "image/png", ".jpg": "image/jpeg", ".jpeg": "image/jpeg",
    ".gif": "image/gif", ".webp": "image/webp", ".svg": "image/svg+xml",
}


def main():
    if DB_PATH.exists():
        DB_PATH.unlink()

    conn = sqlite3.connect(DB_PATH)
    conn.executescript(SCHEMA)
    conn.commit()
    cur = conn.cursor()

    # -----------------------------------------------------------------
    # Pass 1: entities with no journal/document FKs
    # -----------------------------------------------------------------
    slug_dicts = {}  # table_name -> {slug: id}

    def insert_simple(folder_rel, table, fields_fn):
        folder = VAULT_ROOT / folder_rel
        by_slug = {}
        for path in list_notes(folder):
            slug = path.stem
            fm, body = read_note(path)
            row = fields_fn(slug, fm, body, path)
            cols = list(row.keys())
            placeholders = ", ".join("?" for _ in cols)
            cur.execute(
                f"INSERT INTO {table} ({', '.join(cols)}) VALUES ({placeholders})",
                [row[c] for c in cols],
            )
            by_slug[slug] = cur.lastrowid
        slug_dicts[table] = by_slug
        return by_slug

    # people
    def people_fields(slug, fm, body, path):
        full_name = fm.get("full_name") or first_h1(body)
        first_name = fm.get("first_name")
        last_name = fm.get("last_name")
        if full_name and not first_name and not last_name:
            parts = full_name.split(" ", 1)
            first_name = parts[0]
            last_name = parts[1] if len(parts) > 1 else None
        return {
            "slug": slug,
            "full_name": full_name,
            "first_name": fm.get("first_name", first_name),
            "last_name": fm.get("last_name", last_name),
            "goes_by": fm.get("goes_by"),
            "maiden_name": fm.get("maiden_name"),
            "relation": fm.get("relation"),
            "email": fm.get("email"),
            "phone": fm.get("phone"),
            "city": fm.get("city"),
            "birth_date": fm.get("birth_date"),
            "linkedin_url": fm.get("linkedin_url"),
            "company": fm.get("company"),
            "role": fm.get("role"),
            "last_contact": fm.get("last_contact"),
            "notes": body_after_h1(body),
        }

    insert_simple("PKM/CRM/People", "people", people_fields)

    # organizations
    def org_fields(slug, fm, body, path):
        return {
            "slug": slug,
            "name": fm.get("name") or first_h1(body),
            "type": fm.get("org_type"),
            "industry": fm.get("industry"),
            "website": fm.get("website"),
            "email": fm.get("email"),
            "phone": fm.get("phone"),
            "city": fm.get("city"),
            "notes": body_after_h1(body),
        }

    insert_simple("PKM/CRM/Organizations", "organizations", org_fields)

    # topics, key_elements, projects, habits (generic "extra_json" shape)
    KNOWN_TOP_LEVEL = {"name", "slug"}

    def generic_fields(slug, fm, body, path):
        name = fm.get("name") or first_h1(body)
        extra = {k: v for k, v in fm.items() if k not in KNOWN_TOP_LEVEL}
        return {
            "slug": slug,
            "name": name,
            "description": body_after_h1(body),
            "extra_json": json.dumps(extra, default=str) if extra else None,
        }

    insert_simple("PKM/My Life/Topics", "topics", generic_fields)
    insert_simple("PKM/My Life/Key Elements", "key_elements", generic_fields)
    insert_simple("PKM/My Life/Projects", "projects", generic_fields)
    insert_simple("PKM/My Life/Habits", "habits", generic_fields)

    # hosts
    def host_fields(slug, fm, body, path):
        return {
            "slug": slug,
            "name": fm.get("name") or first_h1(body),
            "host_type": fm.get("host_type"),
            "status": fm.get("status"),
            "provider": fm.get("provider"),
            "os": fm.get("os"),
            "location": fm.get("location"),
            "specs": fm.get("specs"),
            "ip_public": fm.get("ip_public"),
            "ip_public_v6": fm.get("ip_public_v6"),
            "ip_lan": fm.get("ip_lan"),
            "ip_tailscale": fm.get("ip_tailscale"),
            "dns_name": fm.get("dns_name"),
            "access": fm.get("access"),
            "secrets_ref": fm.get("secrets_ref"),
            "renewal_date": fm.get("renewal_date"),
            "monthly_cost": fm.get("monthly_cost"),
            "notes": body_after_h1(body),
        }

    insert_simple("PKM/Environment/Hosts", "hosts", host_fields)

    # accounts
    def account_fields(slug, fm, body, path):
        env_vars = fm.get("env_var_names")
        return {
            "slug": slug,
            "name": fm.get("name") or first_h1(body),
            "status": fm.get("status"),
            "account_type": fm.get("account_type"),
            "provider_url": fm.get("provider_url"),
            "username": fm.get("username"),
            "plan": fm.get("plan"),
            "monthly_cost": fm.get("monthly_cost"),
            "renewal_date": fm.get("renewal_date"),
            "secrets_ref": fm.get("secrets_ref"),
            "env_var_names": json.dumps(env_vars) if env_vars else None,
            "notes": body_after_h1(body),
        }

    insert_simple("PKM/Environment/Accounts", "accounts", account_fields)

    # goals (needs key_element_id resolved after key_elements pass -> do in pass 2)
    goal_folder = VAULT_ROOT / "PKM/My Life/Goals"
    goals_raw = []
    for path in list_notes(goal_folder):
        slug = path.stem
        fm, body = read_note(path)
        goals_raw.append((slug, fm, body, path))

    ke_by_slug = slug_dicts.get("key_elements", {})
    goals_by_slug = {}
    for slug, fm, body, path in goals_raw:
        ke_slug = strip_wikilink(fm.get("key_element"))
        ke_id = ke_by_slug.get(ke_slug) if ke_slug else None
        if ke_slug and ke_id is None:
            unresolved_links.append(("goals", slug, ke_slug))
        extra = {k: v for k, v in fm.items() if k not in {"name", "slug", "key_element"}}
        row = {
            "slug": slug,
            "name": fm.get("name") or first_h1(body),
            "description": body_after_h1(body),
            "key_element_id": ke_id,
            "extra_json": json.dumps(extra, default=str) if extra else None,
        }
        cols = list(row.keys())
        cur.execute(
            f"INSERT INTO goals ({', '.join(cols)}) VALUES ({', '.join('?' for _ in cols)})",
            [row[c] for c in cols],
        )
        goals_by_slug[slug] = cur.lastrowid
    slug_dicts["goals"] = goals_by_slug

    conn.commit()

    # -----------------------------------------------------------------
    # Pass 2: entities with FKs into pass-1 tables (services, software, documents, journal)
    # -----------------------------------------------------------------

    # services -> host_id
    services_by_slug = {}
    for path in list_notes(VAULT_ROOT / "PKM/Environment/Services"):
        slug = path.stem
        fm, body = read_note(path)
        host_slug = strip_wikilink(fm.get("host"))
        host_id = slug_dicts.get("hosts", {}).get(host_slug) if host_slug else None
        if host_slug and host_id is None:
            unresolved_links.append(("services", slug, host_slug))
        ports = fm.get("ports")
        env_vars = fm.get("env_var_names")
        row = {
            "slug": slug,
            "name": fm.get("name") or first_h1(body),
            "status": fm.get("status"),
            "service_type": fm.get("service_type"),
            "runtime": fm.get("runtime"),
            "install_path": fm.get("install_path"),
            "repo_path": fm.get("repo_path"),
            "url": fm.get("url"),
            "schedule": fm.get("schedule"),
            "env_file": fm.get("env_file"),
            "monitoring": fm.get("monitoring"),
            "host_id": host_id,
            "ports": json.dumps(ports) if ports else None,
            "env_var_names": json.dumps(env_vars) if env_vars else None,
            "notes": body_after_h1(body),
        }
        cols = list(row.keys())
        cur.execute(
            f"INSERT INTO services ({', '.join(cols)}) VALUES ({', '.join('?' for _ in cols)})",
            [row[c] for c in cols],
        )
        services_by_slug[slug] = cur.lastrowid
    slug_dicts["services"] = services_by_slug

    # software (installed_on resolved via content_index in pass 3)
    def software_fields(slug, fm, body, path):
        return {
            "slug": slug,
            "name": fm.get("name") or first_h1(body),
            "status": fm.get("status"),
            "software_type": fm.get("software_type"),
            "vendor": fm.get("vendor"),
            "version": fm.get("version"),
            "license_ref": fm.get("license_ref"),
            "renewal_date": fm.get("renewal_date"),
            "monthly_cost": fm.get("monthly_cost"),
            "notes": body_after_h1(body),
        }

    insert_simple("PKM/Environment/Software", "software", software_fields)

    # documents
    # Unlike the other eleven entity folders, PKM/Documents/ is not flat -
    # it has organically grown category subfolders (automobiles/, branding/,
    # rentals/<property>/<year>/, etc.), and the same filename stem recurs
    # in more than one subfolder (e.g. multiple "frame-top-dxf.md"). A bare
    # filename-stem slug is not a unique identity contract here the way it
    # is for People/Projects/Topics/etc., so the documents table's `slug`
    # is the file's path relative to PKM/Documents/ (posix-style, no
    # extension) instead of the bare stem. This is reported explicitly in
    # the migration report as a documented deviation from the SOP-002
    # baseline mapping, not a silent schema improvisation.
    documents_folder = VAULT_ROOT / "PKM/Documents"
    documents_by_slug = {}
    seen_stems = {}
    for path in list_notes_recursive(documents_folder):
        rel = path.relative_to(documents_folder)
        rel_slug = rel.with_suffix("").as_posix()
        stem = path.stem
        seen_stems.setdefault(stem, []).append(rel_slug)

        fm, body = read_note(path)
        row = {
            "slug": rel_slug,
            "title": fm.get("title") or first_h1(body),
            "doc_type": fm.get("doc_type"),
            "physical_location": fm.get("physical_location"),
            "digital_location": fm.get("digital_location"),
            "expiry_date": fm.get("expiry_date"),
            "renewal_trigger": fm.get("renewal_trigger"),
            "notes": body_after_h1(body),
        }
        cols = list(row.keys())
        cur.execute(
            f"INSERT INTO documents ({', '.join(cols)}) VALUES ({', '.join('?' for _ in cols)})",
            [row[c] for c in cols],
        )
        documents_by_slug[rel_slug] = cur.lastrowid
        # also index the bare stem -> row, for content_index cross-reference
        # resolution ([[some-document-slug]] links in prose use the bare
        # filename stem, not the full path). Only when the stem is unique;
        # ambiguous stems are left unresolved rather than guessed at.
    for stem, rel_slugs in seen_stems.items():
        if len(rel_slugs) == 1:
            documents_by_slug.setdefault(stem, documents_by_slug[rel_slugs[0]])

    duplicate_stems = {stem: paths for stem, paths in seen_stems.items() if len(paths) > 1}
    slug_dicts["documents"] = documents_by_slug

    # journal (nested YYYY/MM)
    journal_root = VAULT_ROOT / "PKM/Journal"
    journal_paths = []
    if journal_root.exists():
        journal_paths = sorted(
            p for p in journal_root.rglob("*.md") if p.name.upper() != "INDEX.MD"
        )

    MEDIA_HEADING_RE = re.compile(r"^##\s+Media\s*$", re.MULTILINE)
    NEXT_HEADING_RE = re.compile(r"^##\s+", re.MULTILINE)
    EMBED_RE = re.compile(r"!\[\[([^\]]+)\]\]")
    CAPTION_RE = re.compile(r"^_(.+)_\s*$")

    journal_by_slug = {}
    journal_media_rows = []

    for path in journal_paths:
        slug = path.stem
        fm, body = read_note(path)
        entry_date = fm.get("date")
        if not entry_date:
            m = re.match(r"^(\d{4}-\d{2}-\d{2})-", slug)
            entry_date = m.group(1) if m else None

        title = first_h1(body)
        # content: after title heading, up to (not including) ## Media or ## Links
        content = body_after_h1(body)
        cut_idx = len(content)
        for hm in NEXT_HEADING_RE.finditer(content):
            heading_line = content[hm.start():].split("\n", 1)[0].strip().lower()
            if heading_line in ("## media", "## links"):
                cut_idx = hm.start()
                break
        content_main = content[:cut_idx].strip()

        ke_slug = strip_wikilink(fm.get("key_element"))
        proj_slug = strip_wikilink(fm.get("project"))
        topic_slug = strip_wikilink(fm.get("topic"))
        ke_id = slug_dicts.get("key_elements", {}).get(ke_slug) if ke_slug else None
        proj_id = slug_dicts.get("projects", {}).get(proj_slug) if proj_slug else None
        topic_id = slug_dicts.get("topics", {}).get(topic_slug) if topic_slug else None
        if ke_slug and ke_id is None:
            unresolved_links.append(("journal", slug, ke_slug))
        if proj_slug and proj_id is None:
            unresolved_links.append(("journal", slug, proj_slug))
        if topic_slug and topic_id is None:
            unresolved_links.append(("journal", slug, topic_slug))

        tags = fm.get("tags")
        row = {
            "slug": slug,
            "entry_date": entry_date,
            "category": fm.get("category"),
            "entry_type": fm.get("entry_type"),
            "mood": fm.get("mood"),
            "energy": fm.get("energy"),
            "title": title,
            "content": content_main,
            "key_element_id": ke_id,
            "project_id": proj_id,
            "topic_id": topic_id,
            "tags": json.dumps(tags) if tags else None,
        }
        cols = list(row.keys())
        cur.execute(
            f"INSERT INTO journal ({', '.join(cols)}) VALUES ({', '.join('?' for _ in cols)})",
            [row[c] for c in cols],
        )
        journal_id = cur.lastrowid
        journal_by_slug[slug] = journal_id

        # ## Media section -> journal_media rows
        mm = MEDIA_HEADING_RE.search(body)
        if mm:
            rest = body[mm.end():]
            nm = NEXT_HEADING_RE.search(rest)
            media_section = rest[:nm.start()] if nm else rest
            lines = media_section.split("\n")
            sort_order = 0
            i = 0
            while i < len(lines):
                em = EMBED_RE.search(lines[i])
                if em:
                    file_path = em.group(1).strip()
                    caption = None
                    if i + 1 < len(lines):
                        cm = CAPTION_RE.match(lines[i + 1].strip())
                        if cm:
                            caption = cm.group(1).strip()
                    ext = os.path.splitext(file_path)[1].lower()
                    media_type = "screenshot" if ("screenshot" in file_path.lower() or "social" in file_path.lower()) else "image"
                    journal_media_rows.append({
                        "journal_id": journal_id,
                        "file_path": file_path,
                        "media_type": media_type,
                        "mime_type": MIME_MAP.get(ext),
                        "caption": caption,
                        "image_data": None,
                        "sort_order": sort_order,
                    })
                    sort_order += 1
                i += 1

    slug_dicts["journal"] = journal_by_slug

    for row in journal_media_rows:
        cols = list(row.keys())
        cur.execute(
            f"INSERT INTO journal_media ({', '.join(cols)}) VALUES ({', '.join('?' for _ in cols)})",
            [row[c] for c in cols],
        )

    conn.commit()

    # -----------------------------------------------------------------
    # Pass 3: content_index — wikilinks scanned from journal + documents bodies
    # -----------------------------------------------------------------
    # Build a combined slug -> (table, id) lookup across all entity tables
    combined = {}
    for table, by_slug in slug_dicts.items():
        for slug, rid in by_slug.items():
            combined.setdefault(slug, []).append((table, rid))

    def index_links(source_table, source_id, body_text, source_slug):
        for target_slug in CROSSREF_RE.findall(body_text):
            target_slug = target_slug.split("/")[-1].strip()  # normalize path-qualified links
            if not target_slug:
                continue
            hits = combined.get(target_slug)
            if not hits:
                unresolved_links.append((source_table, source_slug, target_slug))
                continue
            for target_table, target_id in hits:
                cur.execute(
                    "INSERT INTO content_index (source_table, source_id, target_table, target_id) VALUES (?, ?, ?, ?)",
                    (source_table, source_id, target_table, target_id),
                )

    # journal bodies
    for path in journal_paths:
        slug = path.stem
        fm, body = read_note(path)
        jid = journal_by_slug.get(slug)
        if jid is not None:
            index_links("journal", jid, body, slug)

    # document bodies (scan for [[person-slug]] mentions per SOP-002 step 4)
    for path in list_notes(VAULT_ROOT / "PKM/Documents"):
        slug = path.stem
        fm, body = read_note(path)
        did = slug_dicts.get("documents", {}).get(slug)
        if did is not None:
            index_links("documents", did, body, slug)

    conn.commit()

    # -----------------------------------------------------------------
    # Validation counts
    # -----------------------------------------------------------------
    tables = [
        "people", "organizations", "topics", "projects", "key_elements",
        "goals", "habits", "documents", "hosts", "services", "accounts",
        "software", "journal", "journal_media", "content_index",
    ]
    counts = {}
    for t in tables:
        cur.execute(f"SELECT COUNT(*) FROM {t}")
        counts[t] = cur.fetchone()[0]

    conn.close()

    print("=== mypka_to_sqlite.py run complete ===")
    print(f"DB written to: {DB_PATH}")
    print("\nRow counts:")
    for t in tables:
        print(f"  {t}: {counts[t]}")

    print(f"\nParse failures: {len(parse_failures)}")
    for p, reason in parse_failures:
        print(f"  {p} -- {reason}")

    print(f"\nUnresolved wikilinks: {len(unresolved_links)}")
    for src_table, src_slug, target in unresolved_links:
        print(f"  {src_table}:{src_slug} -> [[{target}]]")

    print(f"\nDuplicate document filename stems (kept via path-qualified slug): {len(duplicate_stems)}")
    for stem, paths in duplicate_stems.items():
        print(f"  {stem}: {paths}")

    # Emit a machine-readable summary for the report writer
    summary = {
        "counts": counts,
        "parse_failures": parse_failures,
        "unresolved_links": unresolved_links,
        "duplicate_document_stems": duplicate_stems,
    }
    (VAULT_ROOT / "_mypka_to_sqlite_last_run.json").write_text(
        json.dumps(summary, indent=2, default=str), encoding="utf-8"
    )


if __name__ == "__main__":
    main()
