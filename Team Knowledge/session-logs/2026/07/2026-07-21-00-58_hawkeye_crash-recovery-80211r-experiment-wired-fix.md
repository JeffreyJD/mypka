---
agent_id: hawkeye
session_id: 2026-07-21-crash-recovery-80211r-experiment-wired-fix
timestamp: 2026-07-21T00:58:59Z
type: end-of-session
linked_sops: []
linked_workstreams: []
linked_guidelines: []
linked_tasks:
  - tsk-2026-07-20-001-unifi-events-log-pull-wifi-drops
  - tsk-2026-07-20-002-downton-abbey-iot-total-connectivity-failure
linked_journal_entries: []
---

# Crash recovery, 802.11r experiment executed live, wired network fully restored

## Context

Jeff opened the session reporting the prior session had crashed mid-investigation of jeff-laptop's WiFi flapping and a related Downton Abbey-IOT SSID failure. That prior session had a Sparky dispatch in flight (US-24 switch-adoption analysis) that never returned, and an untracked session log + task update sitting uncommitted on disk. This session recovered that work, carried the investigation forward to a live, approved, executed diagnostic experiment, and separately resolved a wired-network connectivity problem on jeff-laptop end to end.

## What we did

- **Hawkeye** confirmed the crash state: found the interrupted mid-session-insight log (`2026-07-20-21-30_hawkeye_wifi-drop-and-iot-ssid-mid-session-insight`) and the modified `tsk-2026-07-20-001` sitting uncommitted, and committed both immediately so the captured findings weren't at risk.
- **Sparky** (background dispatch) analyzed the raw UniFi Events log against the WiFi-flap hypothesis: could not confirm 802.11r/FT directly (UniFi's Events log doesn't expose frame-level reason codes) but narrowed it to a dominant, RSSI-independent, single-AP reassociation pattern — the earlier "odd RSSI variability" is explained by ordinary laptop mobility, not an RF fault.
- **Sparky** opened `tsk-2026-07-20-002` for the separate Downton Abbey-IOT total-connectivity-failure issue (confirmed universal across device types), theorized as the still-unadopted US-24 switch never trunking VLAN 20 to its ports. Rebuilt `Team Knowledge/tasks/INDEX.md` in the same pass.
- **Jeff** approved a 24–48h controlled experiment: disable 802.11r Fast Roaming on the "Downton Abbey" SSID only, to help confirm/deny the FT hypothesis.
- **Sparky** drafted the design-decision record (`Deliverables/2026-07-20-design-decision-disable-80211r-downton-abbey.md`) — exact change scope, UI path (flagged uncertain pending live verification), duration, success/failure signal, mandatory rollback, and the reassociation-delay trade-off.
- **Hawkeye**, via live browser session against the UCK G2 Plus controller (Jeff logged in himself), executed the change: Settings → WiFi → Downton Abbey → Advanced → Roaming Assistance → unchecked Fast Roaming (802.11r) → Apply Changes. Confirmed at **2026-07-20T23:01:10Z UTC**. Only Downton Abbey was touched.
- **Jeff** reported a live WiFi drop during the browser session, just before the toggle was flipped — logged as one more pre-experiment baseline data point (approximate/self-reported timing, not yet confirmed against the controller log), not conflated with the experiment window.
- **Sparky** recorded the real execution timestamp and 24h/48h re-check dates (2026-07-21T23:01Z, 2026-07-22T23:01Z) across the design decision, `network-design.md`, `uck-g2-plus.md`, `jeff-laptop.md`, and `tsk-2026-07-20-001`.
- Separately, Jeff's USB-to-Ethernet adapter (needed for wired console access to the US-24 switch) came back into scope. **Bastion** confirmed the adapter was now detected on the USB bus (Code 45 phantom-device state cleared after Jeff physically reseated it) and had full link + gateway reachability.
- Jeff flagged the wired connection still looked wrong (Windows showed Ethernet as "No internet" / "Public network"). **Bastion** diagnosed the real cause: the adapter was holding an undocumented, gateway-less, DNS-less **manual static IP** (`192.168.1.25`) of unknown origin — confirmed via `network-design.md`'s reservation table that this was never an intentional assignment. Proved the adapter was still fit for the narrow switch-SSH task (`Test-NetConnection 192.168.1.137 -Port 22` succeeded) despite the "No internet" badge.
- Jeff asked for full internet connectivity on the wired adapter, not just LAN-local reachability. **Bastion** switched the interface from static to DHCP (needed a live UAC elevation click from Jeff mid-task), verified all six success criteria (new DHCP IP `192.168.1.252`, gateway, DNS, internet ping, DNS resolution, Windows profile now "Internet"/"Private"), and re-confirmed the switch-SSH path still worked afterward.
- **Hawkeye** closed the session per Jeff's request; the physical US-24 hard-reset/adopt work is deferred to tomorrow.

## Decisions made

- **Proceed with the 802.11r-disable experiment over a packet capture, as the first diagnostic step.** Jeff chose the simpler/less-disruptive-to-set-up option; packet capture remains the fallback if the experiment is inconclusive.
- **Switch jeff-laptop's Ethernet adapter from static to DHCP**, since the static assignment was confirmed undocumented/accidental rather than intentional, and Jeff explicitly wants full internet connectivity on that interface, not just LAN-local reachability for the switch task.
- **US-24 hard-reset/adoption deferred to tomorrow** — Jeff wants to confirm the wired connection is solid first (done) and will do the physical switch work in a subsequent session.

## Insights

- **UniFi's Events log has a hard ceiling: no 802.11 frame-level reason codes.** Any future WiFi-flap-style investigation on this network should budget for a monitor-mode packet capture as the real confirmation tool — the controller's own UI can narrow a hypothesis but can't close it out.
- **A tool successfully doing narrow test A does not mean it passes broader test B — and both can be true and reported without contradiction.** Bastion's gateway-ping success and Windows' "No internet" badge looked contradictory to Jeff but were both accurate: same-subnet L2/L3 reachability and full-internet-path reachability are different tests with different requirements (gateway + DNS + route for the latter). Worth stating both the narrow result and its scope explicitly next time, rather than reporting "it works" unqualified — that's what triggered the follow-up confusion this session.
- **A subagent without Bash/browser tools can produce a fully-specified design decision, but live execution against a real controller/device still requires a dispatch (or Hawkeye directly) with the right tool access.** This session repeated the pattern from the prior one: Sparky (Read/Write/Edit/Glob/Grep only) drafted the 802.11r change precisely, but Hawkeye had to drive the actual browser session because no specialist dispatch has live browser tools. Same shape applies to tomorrow's SSH `set-inform` step — that'll need Bastion (has Bash) executing Sparky's specified command, not Sparky itself.

## Realignments

- None this session — Jeff's course corrections (choosing the 802.11r experiment, pushing back on "wired connection is good" with concrete evidence, asking for full internet not just LAN reachability) were normal steering, not corrections of a misread.

## Open threads

- [ ] **US-24 physical hard-reset + adoption** — not started. Procedure documented in `PKM/Environment/Hosts/us-24.md`: power off → hold reset → power on while holding → hold until LEDs cycle → release, wait 2 min → SSH to `192.168.1.137` as `ubnt`/`ubnt`, run `set-inform http://192.168.1.6:8080/inform`. Jeff will do the physical steps; SSH step routes to Bastion once ready.
- [ ] **`tsk-2026-07-20-002` (Downton Abbey-IOT)** — blocked on the US-24 adoption above.
- [ ] **802.11r experiment re-check** — 24h mark ~2026-07-21T23:01Z (tomorrow evening, ~7 PM local), 48h mark ~2026-07-22T23:01Z. Needs a fresh Events log pull for MAC `34:6F:24:10:9A:99`, compared against the pre-experiment baseline, then **mandatory rollback** (re-enable 802.11r) regardless of outcome.
- [ ] **`tsk-2026-07-20-001`** — stays open pending that re-check comparison.
- [ ] **Origin of the stray static IP on jeff-laptop's Ethernet adapter** — unresolved and possibly undeterminable. Jeff deferred further digging; not blocking anything.
- Carried over, untouched: `tsk-2026-07-19-003-potter-contract-scope-ambiguity`, first live WS-006 gate exercise, Google Drive sync backlog (~2,057-file queue).

## Next steps

- Tomorrow: Jeff does the physical US-24 hard reset; Hawkeye routes the SSH adoption step to Bastion once the switch is in adoption-pending state.
- After adoption: push the planned VLAN 20 port assignments (network-design.md § pending item #2), then re-test Downton Abbey-IOT connectivity to confirm or deny `tsk-2026-07-20-002`'s leading theory.
- Tomorrow evening (~7 PM local): pull the Events log for the 24h re-check on the 802.11r experiment.
- Day after (~7 PM local): 48h re-check, then re-enable 802.11r regardless of outcome (mandatory rollback per the design decision).

## Cross-links

- [[2026-07-20-21-30_hawkeye_wifi-drop-and-iot-ssid-mid-session-insight]] — the crashed session this one recovers from and continues.
- [[2026-07-20-celonis-storm-drive-sync-wifi-triage]] — the session before that.
