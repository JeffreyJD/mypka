---
agent_id: hawkeye + sparky
session_id: network-rebuild-2026-06-13
timestamp: 2026-06-14T02:30:00Z
type: close-session
linked_sops: []
linked_workstreams: []
linked_guidelines:
  - GL-002-frontmatter-conventions
---

# Session log — Home network rebuild + Sparky hire

## Context

Continuation of the Wi-Fi diagnosis sessions from earlier today. Root cause (co-channel 5 GHz interference between two AP AC Pros both on channel 149) was already identified. This session executed the fix by rebuilding the entire UniFi network from scratch using a newly purchased UCK G2 Plus controller. Jeff was operating from his phone's hotspot throughout as the home Wi-Fi was unstable.

## What we did

### Sparky hired (Potter)

- New specialist **Sparky** (Network Architect, CCIE-level) onboarded via SOP-001.
- Contract: `Team/Sparky - Network Architect/AGENTS.md`
- Shim: `.claude/agents/sparky.md`
- Sparky owns the network layer — VLANs, firewall rules, UniFi administration, RF planning, IP schema. Trapper keeps homelab hardware; Sparky owns the network underneath.

### UniFi network rebuild (Hawkeye + Sparky)

**Hardware involved:**
- UCK G2 Plus (new purchase) — controller
- USG-Pro-4 — router/firewall
- US 24 — 24-port managed switch
- 2x AP AC Pro — one per floor

**Process:**
1. UCK G2 Plus connected to home network, discovered via unifi.ui.com (DIRECT)
2. All four devices showed "Managed by Another Console" (old controller offline since 2021)
3. Factory reset and adopted: both AP AC Pros (firmware updated to 6.8.2), USG-Pro-4 (firmware 4.4.57)
4. US 24: adoption failed after factory reset — SSH credentials not clearing with hot-reset. Hard reset (power-cycle while holding reset) deferred to tomorrow with USB-to-Ethernet adapter.

**Networks created:**

| Network | VLAN | Subnet |
|---|---|---|
| Default (LAN) | 1 | 192.168.1.0/24 |
| IoT | 20 | 192.168.2.0/24 |
| Guest | 30 | 192.168.3.0/24 |

**SSIDs created:**

| SSID | Network | Bands | Fast Roaming |
|---|---|---|---|
| Downton Abbey | Default | 2.4 + 5 GHz | Enabled |
| Downton Abbey-IOT | IoT | 2.4 GHz only | — |
| Downton Abbey-Guest | Guest | 2.4 + 5 GHz | — |

**RF plan — co-channel fix:**

| AP | 2.4 GHz | 5 GHz |
|---|---|---|
| AP First Floor (Living Room) | Ch. 1, 20 MHz | Ch. 36, 40 MHz |
| AP Second Floor (Master Bedroom) | Ch. 11, 20 MHz | Ch. 149, 40 MHz |

**Firewall rules (LAN In, Drop, Before Predefined):**
- Block IOT → LAN
- Block Guest → LAN
- Block Guest → IOT

**Result:** Jeff reconnected [[jeff-laptop]] to "Downton Abbey" and confirmed working. Co-channel drops resolved.

### Documentation created (Sparky + Hawkeye)

- `PKM/Environment/Hosts/uck-g2-plus.md` — controller
- `PKM/Environment/Hosts/usg-pro-4.md` — router
- `PKM/Environment/Hosts/us-24.md` — switch (adoption pending)
- `PKM/Environment/Hosts/ap-firstfloor-livingroom.md` — AP ch. 36
- `PKM/Environment/Hosts/ap-secondfloor-masterbedroom.md` — AP ch. 149
- `PKM/Environment/network-design.md` — comprehensive network design document
- `PKM/Environment/Hosts/jeff-laptop.md` — updated with resolution
- `PKM/Environment/INDEX.md` — 5 new hosts added, network-design linked

## Decisions made

- **UniFi rebuild from scratch:** old controller gone 2+ years, no backup. Fresh start was the right call.
- **Three-network design now, four-AP design later:** IoT + Guest + Main segregated today. Second AP pair per room deferred to when hardware arrives.
- **USB-to-Ethernet adapter:** Jeff purchasing so Sparky can configure via API/SSH without phone app. Avoids typos in config.
- **Passwords:** stored in password manager only — not written to myPKA (GL-002 Rule 7).

## Insights

- Hot-reset (holding reset while powered on) on the US 24 did NOT clear SSH credentials — requires hard reset (power-cycle while holding reset). This is underdocumented in Ubiquiti's own adoption failure screen.
- "Before Predefined" toggle in UniFi firewall rules is critical — without it, drop rules are processed after the auto-generated allow rules and have no effect.
- The UniFi mobile app defaults firewall rule Type to "Internet In" not "LAN In" — must be changed manually for inter-VLAN rules.
- Phone hotspot drops (6:12, 6:19) were cellular carrier hiccups — Wi-Fi radio stayed connected. Different failure mode from the UniFi co-channel drops.

## Open threads

- [ ] US 24 hard reset + adoption (power-cycle method) — tomorrow, with USB-to-Ethernet adapter
- [ ] Switch port VLAN assignment after adoption
- [ ] USG firmware update (4.4.57 → current)
- [ ] Rename APs in controller to meaningful names
- [ ] Confirm [[jeff-laptop]] stable on Downton Abbey overnight — zero co-channel drops expected
- [ ] Verify prophet-trader Monday run fires at 09:30 ET (first run under permanent timezone fix)
- [ ] Subaru Outback repair (intake/vacuum leak → idle relearn → fuel trims)
- [ ] Alpaca key scoping; B2 restore test; Tailscale ACL review

## Cross-links

- [[2026-06-13-08-13_hawkeye_close-session-laptop-vps-outback]] — earlier session same day (VPS timezone fix, Outback diagnosis)
- [[2026-06-13-08-45_hawkeye_close-session-wifi-durable-fix]] — earlier session same day (laptop-side Wi-Fi settings)
- [[network-design]] — comprehensive network design document
- [[jeff-laptop]] — Wi-Fi resolution recorded
