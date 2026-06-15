# Network Schema — Implementation Reference

Last updated: 2026-04-17
Maintained by: Trapper

> **Scope of this file:** Implementation-level reference only — specific device IPs,
> service port numbers, NFS exports, ZFS pool layout, and backup schedules.
>
> **For network architecture** (VLAN design, firewall intent, DNS chain, Tailscale
> design, 10GbE topology, WAN failover, backup strategy), see **`network-build.md`**.
> That file is the authoritative network-layer source of truth.

**Addressing scheme: 10.0.x.x throughout.** (Prior 192.168.x.x references are stale.)

---

## Static IP Assignments

Reconciled with EXPORT 2 (phased project plan docx is authoritative).

### VLAN 10 — Management (10.0.10.0/24)

| Device | IP |
|---|---|
| OPNsense R340 iDRAC | 10.0.10.5 |
| Lighthouse R730 iDRAC | 10.0.10.6 |
| Watchtower R740 iDRAC | 10.0.10.7 |
| Cloud Key Gen 2+ | 10.0.10.20 |

### VLAN 20 — Servers (10.0.20.0/24)

| Service | IP |
|---|---|
| Lighthouse Proxmox host | 10.0.20.10 |
| TrueNAS SCALE VM | 10.0.20.11 |
| AdGuard Home VM | **10.0.20.53** |
| Tailscale VM | **10.0.20.100** |

### VLAN 30 — Surveillance (10.0.30.0/24)

| Service | IP |
|---|---|
| Watchtower (Frigate host) | 10.0.30.10 |

### VLAN 50 — IoT (10.0.50.0/24)

| Service | IP |
|---|---|
| Home Assistant | 10.0.50.10 (port 8123) |

---

## Key Service Ports (for firewall reference)

| Service | Port(s) |
|---|---|
| Jellyfin | 8096 (HTTP), 8920 (HTTPS) |
| Immich | 2283 |
| Home Assistant | 8123 |
| Frigate UI | 5000 |
| NFS | 2049 |
| TrueNAS Web UI | 80 / 443 |
| AdGuard Home UI | 3000 (initial) / 80 |
| iDRAC 8 | 443 (HTTPS), 5900 (virtual console) |

---

## NFS Exports (TrueNAS datapool) — to 10.0.20.0/24

| Export | Dataset | Purpose |
|---|---|---|
| /media | datapool/media | Jellyfin library |
| /photos | datapool/photos | Immich storage |
| /files (aka /nextcloud) | datapool/files | Nextcloud data dir |
| /backups | datapool/backups | PBS backups, OPNsense/Cloud Key config backups |
| /ai-models | datapool/ai-models | Ollama model storage |
| /surveillance | datapool/surveillance | Frigate footage (mounted by Watchtower via 10.0.30.10 — firewall exception allows this VLAN-30 → VLAN-20 traffic) |

**NFS networks allowlist:** 10.0.20.0/24 (corrected from old 192.168.20.0/24)

---

## Storage Layout — Lighthouse ZFS Pools

| Pool | Devices | Layout | Use |
|---|---|---|---|
| bootpool | 2x SM863a 480GB | Mirror | Proxmox boot |
| vmstore | SN850X slots 1–2 | Mirror | VM disks |
| faststore | SN850X slots 3–4 | Mirror | Fast/scratch |
| datapool | 6x 6TB SAS | RAIDZ2 | TrueNAS — ~24TB usable |

**⚠️ Open decision:** Arch doc suggests unified 4-drive NVMe pool (striped-mirror) vs milestone doc's two separate mirrors (vmstore + faststore). Both valid — tradeoff is performance (single pool = more IOPS) vs. isolation (two pools = can destroy one without touching the other). Needs Jeffrey's call.

**Settings:**

- Compression: lz4 on all pools/datasets
- Snapshots: hourly for active, daily for media, weekly for surveillance
- Scrub: monthly
- ZFS ARC tuning: post-install

---

## Backups — Implementation Schedule

| Source | Destination | Frequency | Retention |
|---|---|---|---|
| Proxmox VMs / LXCs | datapool/backups | Nightly | 7 daily / 4 weekly / 3 monthly |
| AdGuard, Tailscale, HA, TrueNAS config | datapool/backups | Daily (critical) | 7 daily / 4 weekly / 3 monthly |
| OPNsense config | datapool/backups/opnsense/ | On every change | Rolling |
| Cloud Key config | datapool/backups/cloudkey/ | Daily | Rolling |

(Backup **strategy** — what the rules ensure — lives in `network-build.md` §4j.)
