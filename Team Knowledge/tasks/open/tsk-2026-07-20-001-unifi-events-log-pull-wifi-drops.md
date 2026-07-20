---
# Identity
id: tsk-2026-07-20-001
title: "Pull UCK G2 Plus Events log for jeff-laptop MAC to confirm/deny WiFi-drop root cause"

# Ownership & priority
assignee: sparky
priority: 2

# Status (mirrors folder location)
status: open
blocked_reason: null
blocked_by: null

# Time
created: 2026-07-20T00:00:00Z
updated: 2026-07-20T00:00:00Z
due: null

# Provenance
created_by: sparky
source: hawkeye-dispatch-2026-07-20-wifi-drop-triage
parent: null

# Cross-references
linked_sops: []
linked_workstreams: []
linked_guidelines: []
linked_my_life: []
linked_session_logs: []
linked_journal_entries: []
linked_deliverables:
  - 2026-07-20-network-design-wifi-drops-jeff-laptop-triage

# Tagging
tags: [network, unifi, wifi, incident, jeff-laptop]
---

# Pull UCK G2 Plus Events log for jeff-laptop MAC to confirm/deny WiFi-drop root cause

## What this is

On 2026-07-20, [[jeff-laptop]] had 7 disconnect-then-instant-reconnect cycles to the "Downton Abbey" SSID. Bastion ruled out every client-side cause. Sparky's network-side triage (from documented state only — no live controller access in that dispatch) ruled out DFS forced-channel-switch (ch. 36 is non-DFS) and a repeat of the June 13 co-channel duplication, and confirmed Band Steering / client-RSSI-steering are not configured — but could not confirm or deny the leading hypothesis (802.11r Fast Roaming / MT7921 FT interoperability quirk) because it had no API/SSH/UI access to the UCK G2 Plus controller.

This task is the concrete next step: pull the controller's Insights → Events log (UniFi app, or `https://192.168.1.12` on the LAN) filtered to client MAC `34:6F:24:10:9A:99` for 2026-07-20, covering at minimum 07:00–14:30, and hand the raw event data (reason codes, RRM/FT frames, any AP-side log lines) to Sparky for analysis. This is a read-only pull — no controller change, no approval gate needed.

If the log confirms an FT/roam-triggered deauth pattern, Sparky will draft a design decision (disable 802.11r on Downton Abbey as a controlled experiment) for Jeff's approval before any change is made — that is a separate, later step, not part of this task.

## Context one click away
- Working artifacts:
  - [[2026-07-20-network-design-wifi-drops-jeff-laptop-triage]]
- Related: [[jeff-laptop]] § Incidents (2026-07-20), [[network-design]] Pending items #8/#9

## Success criteria
- Raw Events log export (or screenshot/copy) for MAC `34:6F:24:10:9A:99`, 2026-07-20, obtained and reviewed
- Deauth/reassociate reason codes identified for each of the 7 timestamps (07:17, 08:19, 11:50, 12:05, 13:31, 14:03, 14:05)
- Root cause upgraded from "inconclusive" to either confirmed (with evidence) or a revised hypothesis, recorded back into [[2026-07-20-network-design-wifi-drops-jeff-laptop-triage]] and [[jeff-laptop]]

## Updates
- 2026-07-20 00:00 (sparky) — created; blocked on obtaining controller access (no API/SSH/UI tool available to this Sparky dispatch — needs Jeff, Hawkeye, or a Klinger-built connector to pull the export)
