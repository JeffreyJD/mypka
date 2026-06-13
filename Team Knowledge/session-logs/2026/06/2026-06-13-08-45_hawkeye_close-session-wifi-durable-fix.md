---
agent_id: hawkeye
session_id: close-session-wifi-durable-fix
timestamp: 2026-06-13T12:45:00Z
type: close-session
linked_sops: []
linked_workstreams: []
linked_guidelines: []
---

# Close session — laptop Wi-Fi durable fix + driver investigation

## Context

Continuation after the 08:13 close: the earlier manual-profile Wi-Fi fix did NOT hold — drops returned and Jeff was manually band-switching to recover. This session diagnosed the adapter properly and applied a durable fix, then investigated a driver update Jeff requested.

## What we did (Trapper)

- Pulled disconnect reason codes: every drop = "user wants to establish a new connection" → confirmed **band-SSID flapping** (one router, two band names), not signal/hardware. Earlier manual-profile fix reverted whenever Jeff manually reconnected to 2.4.
- Applied a four-part durable fix on [[jeff-laptop]] (ASUS Vivobook X1502ZA, MediaTek MT7921): roaming Medium-High→Lowest, adapter power management disabled (PnPCapabilities=24), power-plan wireless→Max Performance, profiles set 5G auto/priority-1 + 2.4 manual. Two settings needed elevation → ran via an elevated process (Start-Process -Verb RunAs writing a log file, read back from the non-elevated session).
- Verified: pinned to Downton Abbey-5G, 802.11ac ~360 Mbps, zero flap events post-fix; internet confirmed (ping + DNS + MS connect test 200). The tray "globe" icon Jeff saw was a cosmetic transient during reconnect.
- Driver: Windows Update reports 3.0.1.1335 (2025-03) current. Newer MediaTek branch exists only on third-party/forum sites — deliberately not used. Concluded the driver was never the cause; settings fix resolved it. Recorded make/model/serial on the host note.
- Commit `8f04f64`.

## Decisions made

- **Question:** Update the MT7921 driver?
  **Decision:** No forced update — WU shows current; third-party/forum drivers avoided (risk). Optional MyASUS Live Update left to Jeff. Driver was not the root cause.

## Insights

- Disconnect *reason codes* are the fast discriminator: "establish a new connection" = profile/band flapping (client-side), vs media/hardware reasons = signal/power. Always pull the reason before changing settings.
- Ultimate root cause is router-side (two band-SSIDs instead of one band-steered SSID). Client-side fix is durable but the clean fix would be a single SSID on the router.
- Elevated changes from a non-admin session: write a `.ps1`, launch via `Start-Process -Verb RunAs`, log to a file, read back. Worked cleanly.

## Realignments

- _(none)_

## Open threads

- [ ] Wi-Fi: if any drop recurs, last lever is `netsh wlan delete profile name="Downton Abbey"` (kill the 2.4 profile so nothing remains to flap to).
- [ ] Optional: MyASUS Live Update driver check (peace-of-mind only).
- [ ] Carried: prophet-trader permanent timezone fix before 2026-11-01; verify Monday VPS run at 09:30 ET; Outback repair Monday (air leak → idle relearn → fuel trims); Alpaca key scoping; B2 restore test; Tailscale ACL review.

## Next steps

- Monday: confirm corrected VPS run; pick up Outback resolution when Jeff reports back.

## Cross-links

- [[2026-06-13-08-13_hawkeye_close-session-laptop-vps-outback]] — earlier close same day.
