---
# Identity
id: tsk-2026-07-20-002
title: "Downton Abbey-IOT SSID total connectivity failure — confirm US-24 VLAN-trunking gap"

# Ownership & priority
assignee: sparky
priority: 2

# Status (mirrors folder location)
status: open
blocked_reason: blocked on US-24 switch adoption (physical wired access + hard-reset procedure), a separate approval-gated fix not part of this task
blocked_by: null

# Time
created: 2026-07-20T21:45:00Z
updated: 2026-07-20T21:45:00Z
due: null

# Provenance
created_by: sparky
source: hawkeye-dispatch-2026-07-20-wifi-drop-and-iot-ssid-investigation
parent: null

# Cross-references
linked_sops: []
linked_workstreams: []
linked_guidelines: []
linked_my_life: []
linked_session_logs:
  - 2026-07-20-21-30_hawkeye_wifi-drop-and-iot-ssid-mid-session-insight
linked_journal_entries: []
linked_deliverables: []

# Tagging
tags: [network, unifi, iot, ssid, incident, us-24, vlan]
---

# Downton Abbey-IOT SSID total connectivity failure — confirm US-24 VLAN-trunking gap

## What this is

The "Downton Abbey-IOT" SSID (VLAN 20, 192.168.2.0/24, 2.4 GHz only, set up 2026-06-13 for Ring cameras and the Nanit baby monitor — see [[network-design]] SSID register) currently cannot be connected to **at all**. Jeff confirmed this is universal across device types (phone, laptops, everything he tried) — not an IoT-hardware-specific compatibility issue, which rules out the usual cheap-IoT-radio suspects (e.g. 40 MHz-wide 2.4 GHz channels, which mainly break battery/low-power IoT chipsets, not phones/laptops).

This is a **distinct issue from the [[jeff-laptop]] WiFi-flap investigation** ([[tsk-2026-07-20-001-unifi-events-log-pull-wifi-drops]]) — different SSID, different symptom (zero connectivity vs. intermittent drops), surfaced in the same session but not causally linked to it.

## Leading theory (unconfirmed)

A live spot-check of the SSID config (WPA2, PMF disabled, no MAC filtering/RADIUS, not hidden, 0 connected clients) found nothing unusual — the SSID/wireless config itself is unremarkable. The theory that actually explains **universal, cross-device-type** failure is downstream of the wireless layer entirely:

**[[us-24]] (the core 24-port switch) has never completed UniFi adoption — failed since 2026-06-13, still unresolved.** Because it isn't adopted, VLAN-to-port assignments from the controller have never been pushed to its ports (documented in [[us-24]] § Current state: "VLAN configs from the controller have NOT been pushed to switch ports — IoT/Guest isolation is only enforced at the USG firewall level, not at the switch port level"). If a client associates to an AP and the AP correctly tags its traffic for VLAN 20, but the switch port the AP is plugged into doesn't trunk VLAN 20 (because that config was never pushed), the tagged traffic gets silently dropped at the switch — the client would associate to the SSID successfully at the WiFi layer but never get a usable L2/L3 path, which looks exactly like "can't connect at all" from every device's point of view regardless of hardware type.

This reframes what initially looked like a WiFi/RF problem as a **wired-infrastructure provisioning gap** that has been sitting unresolved for over a month, only now surfacing because someone is actually trying to use the IoT SSID for the first time since the 2026-06-13 rebuild.

## What would confirm or deny this

1. **Confirm US-24 adoption completes** via the documented hard-reset + SSH `set-inform` procedure in [[us-24]] (target corrected to `192.168.1.6` on 2026-07-20). This is gated on [[jeff-laptop]]'s USB-to-Ethernet adapter being physically connected and detected (diagnosed 2026-07-20 as a Code 45 phantom-device / cabling issue, not a driver problem — see [[jeff-laptop]] § Incidents).
2. **After adoption**, push the port VLAN assignments already planned in [[network-design]] § "Switch port VLAN assignments" (IoT AP ports → native VLAN 20, uplink/main-AP ports → native 1 tagged 20/30).
3. **Re-test Downton Abbey-IOT connectivity** from at least one device after the port VLAN push. If connectivity succeeds, the theory is confirmed. If it still fails, the wired-trunking theory is wrong or incomplete and the investigation reopens at L2/L3 on a per-port basis.
4. **Do not skip straight to the fix.** Per Sparky's operating discipline, any switch/VLAN configuration change (including the port assignments in step 2) requires a written design decision and Jeff's approval before execution — the US-24 hard-reset/adopt procedure itself is a separate, already-approved-in-principle operational step per [[network-design]] pending item #1, but the VLAN-to-port assignment that actually fixes this SSID is a reachability-affecting change and needs its own sign-off at the time it's executed.

## Context one click away

- Related: [[jeff-laptop]] § Incidents (2026-07-20 USB-Ethernet-adapter entry), [[us-24]] (adoption status, current state), [[network-design]] (SSID register, pending items #1/#2, Switch port VLAN assignments table)
- Sibling investigation, same session (different issue): [[tsk-2026-07-20-001-unifi-events-log-pull-wifi-drops]]
- Birthed in: [[2026-07-20-21-30_hawkeye_wifi-drop-and-iot-ssid-mid-session-insight]]

## Success criteria

- US-24 switch adoption completed and confirmed in [[uck-g2-plus]] controller (tracked jointly with [[network-design]] pending item #1 — this task does not duplicate that work, it depends on it)
- Switch port VLAN assignments pushed per the design in [[network-design]], with Jeff's approval obtained and logged before the push
- At least one device (any type) successfully connects to Downton Abbey-IOT and obtains a 192.168.2.0/24 address post-fix
- If connectivity still fails after the VLAN push, root cause theory is explicitly revised and re-investigated rather than left as a stale "leading theory"
- Findings recorded back into [[us-24]] and [[network-design]] (living docs) — this task's own body is not the system of record for the switch's state

## Updates
- 2026-07-20 21:45 (sparky) — created. Split out from [[tsk-2026-07-20-001-unifi-events-log-pull-wifi-drops]]'s investigation session per Jeff's flagged concern about this issue only existing in session-log context. Leading theory (US-24 unadopted → VLAN 20 not trunked to switch ports) documented above, not yet confirmed — blocked on physical USB-Ethernet adapter connectivity before the US-24 hard-reset/adopt procedure can even be attempted. No controller or switch configuration was touched in writing this task.

## Outcome
_(filled when status flips to done — see SOP-012-close-task)_
