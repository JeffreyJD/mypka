---
agent_id: hawkeye
session_id: 2026-07-20-wifi-drop-and-iot-ssid-investigation
timestamp: 2026-07-20T21:30:00Z
type: mid-session-insight
linked_sops: []
linked_workstreams: []
linked_guidelines: []
linked_tasks:
  - tsk-2026-07-20-001-unifi-events-log-pull-wifi-drops
---

# Wi-Fi drop investigation continues, plus new IOT-SSID and US-24-adoption thread converge

## Context

Direct continuation of [[2026-07-20-celonis-storm-drive-sync-wifi-triage]] (same day, new session). That prior session ended with `tsk-2026-07-20-001` open and blocked: Sparky's triage was inconclusive without a live pull of the UCK G2 Plus controller's Events log. This session picked that thread back up, unblocked it, found the picture is much worse than believed, and — mid-session — Jeff surfaced two more threads (Downton Abbey-IOT total failure, and a power-outage detail) that converge on a single, more compelling theory than anything considered before. Writing this now, mid-session, per Jeff's explicit concern about losing this kind of synthesis between sessions — not waiting for close-session.

## What we did

- **Bastion** verified the Claude in Chrome browser extension was already installed/enabled on jeff-laptop (no install needed, contrary to initial assumption) — the real blocker was a live pairing/session step, resolved once Jeff opened the extension panel.
- **Hawkeye**, via now-connected browser tooling, found `https://192.168.1.12` (the documented UCK G2 Plus controller address) completely unreachable — not a cert warning, a full ARP-resolution failure on the LAN.
- **Bastion** ran a live connectivity diagnostic from jeff-laptop and confirmed: laptop's own Wi-Fi was strong and stable at that moment (not mid-flap), gateway/internet reachability clean, but `.12` specifically had zero ARP presence on the LAN — pointed at the controller itself, not the laptop.
- **Jeff** physically checked the UCK G2 Plus's own display and found it now running at **192.168.1.6**, not `.12`.
- **Sparky** corrected the IP drift across the vault: `PKM/Environment/Hosts/uck-g2-plus.md`, `PKM/Environment/network-design.md` (5 occurrences), `Team Knowledge/tasks/open/tsk-2026-07-20-001-...md`, `PKM/Environment/Hosts/jeff-laptop.md`, and (in a follow-up pass, see Insights below) `PKM/Environment/Hosts/us-24.md`'s embedded `set-inform` recovery command, which would have silently failed if run as originally written. Flagged one file left untouched as historical record: `Deliverables/2026-07-20-network-design-wifi-drops-jeff-laptop-triage.md`.
- **Hawkeye**, once `.6` was confirmed reachable and Jeff logged in himself (Hawkeye never touched the UniFi password), pulled the live Insights → Events log for MAC `34:6f:24:10:9a:99` and captured it to `Deliverables/2026-07-20-unifi-events-raw-log-jeff-laptop.md`.
- **Headline finding from the raw log:** this is not the 7-isolated-events picture from the prior session. The laptop has been disconnecting/reconnecting roughly every 2–35 minutes continuously, from at least ~4:50 AM through 5:26 PM today, including several sub-2-minute connections — and it continued even after Jeff power-cycled the laptop between sessions. UniFi's own event log does not expose 802.11 deauth/FT reason codes, so the 802.11r/FT hypothesis still can't be directly confirmed from this data, but every reassociation is to the same physical AP, and RSSI at connect time is oddly variable for a stationary device.
- **Jeff reported a second, separate issue:** Downton Abbey-IOT (VLAN 20, 2.4GHz-only SSID, set up 2026-06-13 for Ring cameras and the Nanit monitor) — devices cannot connect to it **at all**, and critically, this is universal across device types (phone, laptops, everything), not just IoT-class hardware.
- **Hawkeye** spot-checked the SSID config live: WPA2, PMF disabled, no MAC filtering/RADIUS, not hidden, 0 connected clients. Noticed the global 2.4GHz channel plan uses 40MHz-wide channels (1 and 11) — initially flagged as a possible cause, but downgraded once the "every device type" detail came in (40MHz mainly breaks cheap/battery IoT hardware, not phones/laptops).
- **Jeff surfaced the real lead:** "running theory was something to do with the provisioning" — pointing at the US-24 switch. Hawkeye read `PKM/Environment/Hosts/us-24.md` and found the switch's UniFi adoption has been **failed since 2026-06-13 and never resolved** — factory reset done, but SSH auth with default `ubnt/ubnt` fails because the reset didn't fully clear stored credentials. Documented current state: "VLAN configs from the controller have NOT been pushed to switch ports — IoT/Guest isolation is only enforced at the USG firewall level, not at the switch port level."
- **Jeff added:** power outages over the past 2 weeks likely power-cycled all network equipment — a plausible explanation for the UCK G2 Plus IP drift (no MAC-bound DHCP reservation existed for it, per `network-design.md`'s static-IP table), though it predates and doesn't explain the US-24 adoption failure itself (that's been broken since 2026-06-13).
- **Jeff's USB-to-Ethernet adapter arrived** — confirmed as the long-pending item needed for wired SSH access to hard-reset/adopt the US-24 switch. **Bastion** diagnosed it: driver is correctly installed (Realtek RTL8153, WHQL-signed, Windows' own driver store — this specific unit has worked on this laptop before), but the adapter is not currently present on the USB bus at all (Code 45 / phantom device) — a physical connection issue (unseated cable, wrong port, unpowered hub), not a driver problem. Needs Jeff to check the physical connection; a re-check afterward is a 30-second confirmation.
- **Hawkeye routing correction, self-caught:** sent the first two follow-up messages (universal-failure correction, US-24 theory) to the wrong background agent — an already-completed Sparky dispatch from earlier in the session, not the one actually working the Downton Abbey-IOT/WiFi-flap analysis. Caught via the recipient's own honest "I have no record of this" pushback rather than fabricating continuity, and immediately re-sent to the correct agent thread. The wrong-thread agent's response was still useful: it independently re-verified and fixed the `us-24.md` stale-IP issue on its own initiative rather than taking the claim on faith.

## Decisions made

None yet — the switch-adoption theory is a strong, well-supported hypothesis, not a confirmed root cause. No controller or switch configuration has been changed. The next real decision point is whether to proceed with the US-24 hard-reset/adopt procedure once the USB-Ethernet adapter is physically working — that's an operational fix, not a design decision requiring the same approval gate as something like disabling 802.11r, but it should still be done deliberately (see Open threads).

## Insights

- **A single unadopted switch can plausibly explain a "nothing connects" SSID failure that looks like a WiFi problem.** Downton Abbey-IOT's SSID config is unremarkable (WPA2, no filtering, standard settings) — the theory that actually explains *universal* failure across every device type is downstream of the switch, not the wireless config: an unadopted US-24 switch never received VLAN-to-port assignments from the controller, so even if the AP correctly tags client traffic for VLAN 20, the switch port it's plugged into may not trunk that VLAN correctly, silently dropping the traffic after WiFi association succeeds. This reframes what looked like a WiFi/RF investigation as fundamentally a wired-infrastructure provisioning gap that's been sitting unresolved for over a month.
- **Verify agent identity before sending a follow-up, not just the task content.** Two SendMessage calls in a row went to the wrong background agent because the two Sparky dispatches from this session were tracked by memory/name rather than by re-checking the actual agentId returned by the specific spawn call being followed up on. The failure mode is easy to fall into when multiple same-named-specialist agents are running concurrently in one session; the fix is to always match against the literal spawn-result ID for the specific dispatch being continued, not the specialist's name from a mental model of "the Sparky thread."
- **Live browser-driven data pulls (UniFi Events log, live SSID config check) surfaced findings that pure documentation review could not** — the prior session's Sparky triage, working from `network-design.md` alone, could not have found the IP drift, the true flap frequency, or the current IOT SSID config state. This is a concrete case for the standing open item (network-design.md pending #9) about building durable controller API access via Klinger — manual browser pulls work but depend on Hawkeye/Jeff being available to drive them.

## Realignments

- Jeff corrected the initial framing on Downton Abbey-IOT twice: first from "IoT devices specifically" to "every device type, universal failure" (which reweighted the diagnosis away from a channel-width/compatibility hypothesis), then supplied the actual root-cause lead himself ("something to do with the provisioning") rather than Hawkeye/Sparky arriving at it independently. Also explicitly flagged, unprompted, that this kind of cross-thread synthesis is exactly what he doesn't want lost between sessions — the direct trigger for writing this entry now instead of at close.

## Open threads

- [ ] **[[tsk-2026-07-20-001-unifi-events-log-pull-wifi-drops]]** — raw data now captured (`Deliverables/2026-07-20-unifi-events-raw-log-jeff-laptop.md`), Sparky analysis in progress at time of writing; task success criteria (root cause confirmed or revised hypothesis, recorded in `jeff-laptop.md`) not yet met.
- [ ] **Downton Abbey-IOT total connectivity failure** — no task file exists yet for this (flagged by the wrong-thread Sparky agent as a gap — should get a proper `SOP-010`-created task rather than living only in session context). Sparky investigating live, US-24 switch-adoption theory is the leading candidate, not yet confirmed.
- [ ] **US-24 switch adoption** — still failed, unresolved since 2026-06-13. `us-24.md`'s documented hard-reset/adopt procedure is ready to run (stale IP now fixed) once wired access exists.
- [ ] **USB-to-Ethernet adapter** — driver-ready, not physically connected/detected. Needs Jeff to check the physical connection (port, cable seating, avoid unpowered hubs), then a 30-second Bastion re-check before it's usable for the switch console session.
- [ ] Power-outage timeline — not yet correlated against the WiFi-flap timestamps or the exact date the UCK G2 Plus would have picked up its new lease. Nice-to-have, not blocking.
- Carried over, untouched: [[tsk-2026-07-19-003-potter-contract-scope-ambiguity]], first live WS-006 gate exercise, Google Drive sync backlog (~2,057-file queue, not resolved per prior session).

## Next steps

- Once Sparky's Downton Abbey-IOT and WiFi-flap writeups land: open a proper task for the IOT SSID issue (currently only tracked in this session log and the two agent dispatches), and decide with Jeff whether to proceed with the US-24 hard-reset once the adapter is physically connected.
- Jeff to physically re-seat/re-port the USB-Ethernet adapter; ping Bastion for the 30-second re-check.
- Do not repeat the wrong-agent-thread mistake: when following up on a specific dispatch, use its literal spawn-result agentId, not a name-based guess.

## Cross-links

- [[2026-07-20-celonis-storm-drive-sync-wifi-triage]] — the session this one continues from.
