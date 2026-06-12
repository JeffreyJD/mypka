---
name: davisglobe-vps-ash-1
host_type: vps
status: active
provider: hetzner
os: Ubuntu 26.04 LTS
location: Ashburn, VA
specs: 4 vCPU / 8 GB RAM / 150 GB disk
ip_public: 178.156.163.139
ip_public_v6: ""
ip_lan: ""
ip_tailscale: ""
dns_name: ""
access: ssh trader@178.156.163.139
secrets_ref: SSH key on jeff-laptop
renewal_date: ""
monthly_cost: ""
linked_accounts:
  - hetzner
tags:
  - trading
---

# davisglobe-vps-ash-1

## What runs here

The Services on this host, each as a `[[wikilink]]` to its Service note. One line of context each.

## Security posture

Firewall state, SSH policy, fail2ban, update strategy, anything an auditor would ask. Per [[GL-002-frontmatter-conventions]] rule 7: describe WHERE credentials live, never the credentials.

## Backups

What gets backed up, to where, how often, and whether restore has been tested.

## Open questions

Anything unconfirmed about this machine — provider, renewal, pending hardening items.
