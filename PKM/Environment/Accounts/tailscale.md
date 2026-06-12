---
name: Tailscale
status: active
account_type: saas
provider_url: https://tailscale.com
username: jeffreyj2490@gmail.com (Google SSO)
plan: Personal (free)
monthly_cost: 0
renewal_date: ""
secrets_ref: device keys managed by Tailscale clients; admin via Tailscale console login
env_var_names: []
linked_services: []
linked_hosts:
  - davisglobe-vps-ash-1
  - jeff-laptop
tags:
  - network
---

# Tailscale

Mesh VPN tying the environment together. Tailnet domain: `tailfe9a46.ts.net`.

## Key facts

- Devices on the tailnet (from admin-console CSV export, 2026-06-12):

| Device | Host note | Tailscale IP | OS / client | Tags | Joined | **Key expiry** |
|---|---|---|---|---|---|---|
| `davisglobe-vps-ash-1` | [[davisglobe-vps-ash-1]] | 100.91.84.117 | Linux / 1.98.4 | `tag:trading` | 2026-06-11 | **disabled** (2026-06-11) |
| `laptop-k2i9ps34` | [[jeff-laptop]] | 100.120.6.80 | Windows 11 (26200) / 1.98.4 | — | 2026-06-11 | **2026-12-08** |
| `samsung-sm-s938u` | (phone — no host note) | 100.116.242.25 | Android 16 / 1.94.2 | — | 2026-02-01 | **2026-07-31** |

- Key expiry: **disabled on the VPS** (Jeff, 2026-06-11) — it stays on the tailnet indefinitely. Still enabled on laptop (2026-12-08) and phone (2026-07-31); both are attended devices that just re-prompt, acceptable.
- No subnet routers, exit nodes, Tailscale SSH, or Funnel configured yet — plain mesh.
- Devices also have stable IPv6 tailnet addresses (fd7a:115c:a1e0::/48 range) — in the CSV if ever needed.
- Homelab plan: a Tailscale subnet-router VM on [[lighthouse]] (10.0.20.100) will advertise all VLAN subnets; split DNS for `home.lan` via AdGuard Home. Survives router reboots — independent of [[opnsense-r340]].

## Key facts (admin)

- Login: Google SSO as **jeffreyj2490@gmail.com** (note: different from the davisglobe.com identity used elsewhere — this is the keys to the whole tailnet).

## Open questions

- Check ACL policy: default open tailnet, or rules around `tag:trading`?
- Phone key expires **2026-07-31** — it will prompt to re-auth, low risk, but expect it.
