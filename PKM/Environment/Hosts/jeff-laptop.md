---
name: jeff-laptop
host_type: laptop
status: active
provider: ""
os: Windows 11 Home + WSL
location: with Jeff
specs: ASUS Vivobook X1502ZA (F1502ZA), serial N4N0CV060188156; Win 11 Home + WSL; Wi-Fi MediaTek MT7921 Wi-Fi 6 (driver 3.0.1.1335, 2025-03)
ip_public: ""
ip_lan: ""
ip_tailscale: 100.120.6.80
dns_name: laptop-k2i9ps34.tailfe9a46.ts.net
access: local
secrets_ref: local .env files per project; Claude Code standard login
renewal_date: ""
monthly_cost: ""
linked_accounts:
  - tailscale
  - anthropic
tags:
  - dev
---

# jeff-laptop

Primary development machine. Personal — **not** corporate: Claude Code uses direct Anthropic auth, no Portkey, no Bedrock, no corporate gateway.

## What runs here

- Claude Code ([[claude-code]]) — daily driver for dev and for the myPKA team.
- prophet-trader dev checkout at `C:\Users\jeff\dev\prophet-trader` (Python venv, 251 tests passing on Windows). Deployed copy runs on [[davisglobe-vps-ash-1]] — see [[prophet-trader]].
- **No scheduled jobs** — Windows Task Scheduler and WSL crontab confirmed empty 2026-06-11. All crons moved to the VPS.

## Security posture

- On the tailnet at 100.120.6.80 as `laptop-k2i9ps34` (Tailscale 1.98.4, joined 2026-06-11, key expiry 2026-12-08 — see [[tailscale]]).
- Local prophet-trader `.env` holds dev keys. Never put the Alpaca read+write key here — that key lives only on the VPS (see [[alpaca]]).

## Network notes

- **Wi-Fi drops — root cause & durable fix (2026-06-13).** Symptom: drops every few minutes, requiring manual band-switching. Every disconnect logged reason "user wants to establish a new connection" (NOT signal/hardware loss) = the laptop **flapping between the two SSIDs of one router** ("Downton Abbey" 2.4 GHz / "Downton Abbey-5G" 5 GHz). The 2026-06-12 "set 2.4 to manual" fix did NOT hold — reverted whenever Jeff manually reconnected to 2.4. Four-part durable fix applied (last two needed elevation):
  1. Roaming Aggressiveness: Medium-High → **Lowest** (`RoamIndicateTh`) — stops eager band-hopping.
  2. Adapter power management **disabled** — `PnPCapabilities=24` at `HKLM:\...\Class\{4d36e972-...}\0000` — stops radio power-down micro-drops.
  3. Power-plan Wireless Adapter Settings → **Maximum Performance** (AC+DC).
  4. Profiles: 5G `connectionmode=auto` + `profileorder priority=1`; 2.4 `connectionmode=manual`.
  Result: holds Downton Abbey-5G, 802.11ac, ~400 Mbps. If it ever flaps again, the bulletproof step is to **delete the 2.4 "Downton Abbey" profile** entirely (`netsh wlan delete profile name="Downton Abbey"`). Ultimate root cause is router-side: two band-SSIDs instead of one band-steered SSID.
- **ROOT CAUSE FOUND + FIXED 2026-06-13:** recurring 1–2 minute internet dropouts on 5 GHz only, every 4–6 min, this laptop only. Cause: the two UniFi APs broadcast "Downton Abbey-5G" on the SAME 5 GHz channel (149) with near-equal signal; the MT7921 can't distinguish co-channel same-SSID APs and stalls its data path trying to roam. **RESOLVED 2026-06-13:** full UniFi network rebuild — UCK G2 Plus installed, both APs factory reset and re-adopted, channels separated ([[ap-firstfloor-livingroom]] → ch. 36, [[ap-secondfloor-masterbedroom]] → ch. 149), Fast Roaming (802.11r) enabled. Network rebuilt with three SSIDs: Downton Abbey (main), Downton Abbey-IOT, Downton Abbey-Guest. Laptop reconnected to "Downton Abbey" and confirmed working.
- **Driver update (checked 2026-06-13):** Windows Update reports MT7921 driver **3.0.1.1335 (2025-03) as current** — no newer driver via WU or Device Manager auto-search. A newer MediaTek branch (~1.1146.x) appears only on third-party sites (DriverIdentifier/DrvHub) and a ROG forum post — **deliberately NOT used** (malware/instability risk, not X1502ZA-validated). Safe path if ever wanted: MyASUS → Live Update, or asus.com → X1502ZA → Driver & Utility → WLAN. Rollback: Device Manager → adapter → Driver → Roll Back Driver. **Note: the driver was never the cause — the settings fix resolved the flapping; driver update is optional.**
- **Connectivity verified 2026-06-13:** post-fix, IP 192.168.1.247, gw/DNS 192.168.1.1, MS connect test 200, DNS resolves. A transient tray "globe" icon during reconnect is cosmetic, not a real outage. Stable on 5 GHz since 08:22, zero flap events after the fix.

## Backups

Not documented yet — see Open questions.

## Open questions

- Document laptop make/model/specs.
- Define a backup story for the laptop (My Drive covers the PKA folders; what about `C:\Users\jeff\dev\`?).
