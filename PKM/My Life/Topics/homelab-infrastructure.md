---
name: Homelab Infrastructure
key_element: homelab
tags:
  - proxmox
  - truenas
  - networking
  - self-hosted
---

## What I think about here

Self-hosted infrastructure philosophy. Running Proxmox VE on Lighthouse (R730XD) with TrueNAS SCALE VM for storage, Frigate NVR on Watchtower (R740), OPNsense on R340 router. Services: Jellyfin, Immich, Home Assistant, Vaultwarden, local AI stack (Ollama), Nextcloud, AdGuard Home, Tailscale.

Network: 10GbE core (USW-Aggregation), VLAN segmentation (Management/Servers/Surveillance/IoT/Clients/Guest), 10.0.x.x addressing.

## Open questions

- Unified 4-drive NVMe pool vs. two separate mirrors (vmstore + faststore) on Lighthouse — Jeff's call pending
- R730 CPU upgrade to E5-2699 v4 timing and heatsink selection (confirmed compatible: YY2R8, 0TY129, 0PXDG5, 0GDK4, NGC09)
- Watchtower GPU passthrough for Frigate AI acceleration

## Sources

- `PKM/Documents/homelab/network-schema.md`
- `PKM/Documents/homelab/network-build.md`
- `PKM/Documents/homelab/build-log.md`
- [[homelab]] — Key Element
