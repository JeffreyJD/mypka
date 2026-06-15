---
title: Homelab Servers Handoff Knowledge Dump — Export 1 of 3
doc_type: other
digital_location: Documents/homelab/homelab-servers-handoff-2026-04-17.md
issued_on: 2026-04-17
tags:
  - homelab
  - lighthouse
  - watchtower
  - opnsense
  - build-log
---

## Summary

330-line complete state dump of the three-server homelab build as of April 17, 2026. Compiled from prior Claude project context for Trapper. Covers hardware inventory, compatibility decisions, configuration decisions, current build status, open items, and budget snapshot.

## Key facts

| Server | Status as of 2026-04-17 |
|---|---|
| Lighthouse (R730XD) | ~40% Phase 1 complete, chassis arriving Apr 14, 0% assembled |
| Watchtower (R740) | Architecture only, 0% purchased |
| OPNsense (R340) | Chassis + parts shipping, scope needs clarification |

**Confirmed spend as of Apr 17:** ~$600+ of $1,680–2,208 total build estimate.

## Open blockers (as of Apr 17, 2026)

- iDRAC license: awaiting motorfixit reply with Service Tag
- BIOS version: can't order E5-2699 v4 until 2.10.0 confirmed
- OPNsense R340 scope: needs Jeff's confirmation
- Rack depth measurement: R730XD needs ≥32" internal depth — hard blocker before rails

## Notes

Full detail including eBay search strings, budget breakdown, and build philosophy in the source file. Trapper reads this as context for all homelab tasks. Updates tracked in `PKM/Documents/homelab/build-log.md` and `parts-compatibility.md`.
