---
id: tsk-2026-07-18-013
title: "Resolve or explicitly park two West 9th Street tenant-identity ambiguities from the June import"
assignee: frank
priority: 3
status: open
blocked_reason: null
blocked_by: null
created: 2026-07-18T12:29:33Z
updated: 2026-07-18T12:29:33Z
due: null
created_by: hawkeye
source: outside-audit-handoff-2026-07-18
parent: null
linked_sops:
  - SOP-010-create-task
  - SOP-012-close-task
linked_workstreams: []
linked_guidelines:
  - GL-002-frontmatter-conventions
linked_my_life: []
linked_journal_entries: []
linked_session_logs:
  - 2026-06-29-15-30_margaret_rentals-enrichment
linked_deliverables:
  - 2026-07-18-ws-007-post-ratification-audit
tags: [rentals, crm, tenant-identity, data-quality]
---

# Resolve or explicitly park two West 9th Street tenant-identity ambiguities from the June import

## What this is

Margaret's 2026-06-29 rentals bulk-import enrichment surfaced two unresolved tenant-identity questions that never got a task and don't appear in any close-session log — the WS-004 Tier 2 retro (2026-07-18) mined journals and session-logs for the whole team and still didn't surface these, because they live in neither. An outside audit ([[2026-07-18-ws-007-post-ratification-audit]]) flagged this as "the one genuinely dropped thread" from the whole retro cycle — personal CRM data with no owner and no tracking, and nothing else in the team's normal learning-capture mechanisms will re-surface it.

Two items, from `[[2026-06-29-15-30_margaret_rentals-enrichment]]`:

1. **Deyarmin-Ponce and Tran-Pauline** — both hyphenated names in the CRM. Could be (a) a single tenant with a compound surname, or (b) two co-tenants listed together. CRM files were created as single entities pending clarification; binary lease documents (not text-extractable at import time) would resolve it.
2. **317 West 9th primary tenant names, 2013–2021** — stub files for multiple year-folders (2013-2014, 2014-2015, 2016-2017, 2019-2020, 2020-2021, 2021) don't contain person names in filenames or extractable metadata. Cosigners are on record (Fagley, Riley, Schon for 2017-2018; Chambers for 2019-2020) but primary tenants are unknown. Related: 319 West 9th's 2024-2025 new-tenant stubs are also unnamed, and the 2020-2023 year-folders for both 317 and 319 have the same gap.

## Context one click away

- Origin: [[2026-06-29-15-30_margaret_rentals-enrichment]] (see items 2-4 in that log's open questions)
- Flagged by: [[2026-07-18-ws-007-post-ratification-audit]] (Item 1)
- Frontmatter schema for CRM/rental entities: [[GL-002-frontmatter-conventions]]

## Success criteria

- Deyarmin-Ponce / Tran-Pauline: resolved to one or two CRM People entries (read the binary lease docs if that's what it takes), or explicitly parked with a documented reason if resolution isn't currently possible
- 317 West 9th 2013-2021 and 319 West 9th 2020-2025 primary tenant names: identified from the source lease documents, or explicitly parked as unresolvable from available records
- Whichever ambiguities get parked (not resolved) are recorded in a way that will actually resurface later — not silently dropped a second time

## Updates

- 2026-07-18 12:29 (hawkeye) — created from an outside audit's handoff, assigned to Frank (owns tenant matters) with Margaret's original import session as context.
