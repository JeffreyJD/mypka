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
updated: 2026-07-20T21:45:00Z
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
  - 2026-07-20-unifi-events-raw-log-jeff-laptop

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
  - [[2026-07-20-unifi-events-raw-log-jeff-laptop]]
- Related: [[jeff-laptop]] § Incidents (2026-07-20), [[network-design]] Pending items #8/#9
- Split-off task (separate issue, same investigation): [[tsk-2026-07-20-002-downton-abbey-iot-total-connectivity-failure]]

## Success criteria
- Raw Events log export (or screenshot/copy) for MAC `34:6F:24:10:9A:99`, 2026-07-20, obtained and reviewed
- Deauth/reassociate reason codes identified for each of the 7 timestamps (07:17, 08:19, 11:50, 12:05, 13:31, 14:03, 14:05)
- Root cause upgraded from "inconclusive" to either confirmed (with evidence) or a revised hypothesis, recorded back into [[2026-07-20-network-design-wifi-drops-jeff-laptop-triage]] and [[jeff-laptop]]

## Updates
- 2026-07-20 00:00 (sparky) — created; blocked on obtaining controller access (no API/SSH/UI tool available to this Sparky dispatch — needs Jeff, Hawkeye, or a Klinger-built connector to pull the export)
- 2026-07-20 (sparky) — **New, distinct finding — registry drift, not a re-triage of the WiFi-flap itself.** During live troubleshooting, Bastion's ARP diagnostic found the controller IP documented above (`192.168.1.12`) completely unresponsive on the LAN (no ARP entry, not a timeout). Jeff physically confirmed the device's actual IP via its own display: `192.168.1.6`. Confirmed live via browser — `https://192.168.1.6` serves the UniFi login page. Canonical record corrected in [[uck-g2-plus]] (see its Corrections log) and in [[network-design]]. **This unblocks the Events-log pull this task exists for** — the controller is reachable at the corrected address. The actual log pull (login + Insights → Events export for MAC `34:6F:24:10:9A:99`) is being done live by Jeff/Hawkeye now, outside this task's automated scope — this entry just removes the "no controller access" blocker noted above.
- 2026-07-20 (sparky) — **Raw log captured and analyzed.** Hawkeye's live pull ([[2026-07-20-unifi-events-raw-log-jeff-laptop]]) landed; Sparky analyzed it against this task's success criteria. Two outcomes:
  1. **Scope correction:** the flap is far worse than the original 7-timestamp sample — near-continuous disconnect/reconnect roughly every 2–35 min, ~4:50 AM–5:26 PM, surviving a mid-day reboot.
  2. **Success criterion "deauth/reassociate reason codes identified for each of the 7 timestamps" cannot be met** — confirmed via a sampled CEF-log expansion that UniFi's Events log does not expose 802.11 frame-level reason codes at all, for any timestamp. This is a tooling ceiling, not an incomplete analysis.
  Root cause is **REVISED, not confirmed**: most consistent with an RSSI-independent, single-AP (living-room AC Pro, ch. 36) reassociation loop; 802.11r/MT7921 FT interoperability remains the leading candidate with stronger circumstantial evidence (same-AP pattern, disconnects occur at both strong and weak RSSI) but still unconfirmed because the controller UI can't surface frame-level data. What would confirm it: (a) a monitor-mode packet capture during a live flap (read-only, no approval gate), or (b) the already-proposed 24–48h 802.11r-disable experiment, which needs a written design decision and **Jeff's explicit approval** — not authorized here. Full writeup: [[2026-07-20-network-design-wifi-drops-jeff-laptop-triage]] § Findings appendix. Registered in [[jeff-laptop]] § Incidents (new entry, prior 7-event entries left intact as historical record).
  **Recommendation:** the "root cause upgraded from inconclusive" criterion is met (via the revised/leading hypothesis above, clearly labeled as such); the reason-codes-per-timestamp criterion is unmeetable with current tooling and should be treated as satisfied-with-a-documented-limitation rather than blocking closure. Hawkeye/Jeff to decide whether to close this task now (with the 802.11r-disable experiment tracked as a fresh, separate task once Jeff decides to pursue it) or leave it open pending the packet-capture option. Sparky did not move this file.
  A second, unrelated issue surfaced in the same investigation session — Downton Abbey-IOT SSID total connectivity failure — was split into its own task: [[tsk-2026-07-20-002-downton-abbey-iot-total-connectivity-failure]].
