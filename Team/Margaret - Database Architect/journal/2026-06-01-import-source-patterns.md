---
agent: margaret
date: 2026-06-01
type: tier-0-learning
---

# Import source patterns — what to skip and what to handle specially

## What I learned

**OneNote `.one` files are binary — stubs only.** Microsoft OneNote section files (`.one`) and notebook files (`.onetoc2`) cannot be read as plain text. When encountered during a WS-002 import, create a stub document noting the file location and format, and flag to Jeff that a OneNote export (to PDF or DOCX) is needed to access the content.

**`myPKA/` and `My PKA/` folders in Google Drive are scaffold instances, not document sources.** These folders contain prior PKA scaffold installations, not user documents. Do not import from them via WS-002. If encountered during a bulk import scan, skip and note in the session log.

**`Trading Bot/` and similar active git repos in Google Drive — leave in place.** Active project repositories are not import candidates. Flag them as "active repo — skip" in the import manifest.

## When this applies

Every WS-002 import scan of Jeff's Google Drive or any drive containing mixed scaffold and document content.

## When this does NOT apply

Does not apply when Jeff explicitly asks to import a specific file from these locations.
