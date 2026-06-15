---
agent_id: hawkeye
session_id: pka-migration-network-docs-2026-06-14
timestamp: 2026-06-14T20:00:00Z
type: close-session
linked_sops: []
linked_workstreams: []
linked_guidelines:
  - GL-002-frontmatter-conventions
  - GL-001-file-naming-conventions
---

# PKA-Jeffrey migration complete + network triage + documentation gaps audit

## Context

Continuation from the 2026-06-13 network rebuild session. Jeff came in with the US 24 switch still showing Adoption Failed, then broadened scope to cover network device placement questions, a full PKA-Jeffrey → mypka migration, fleet and life documentation, and a comprehensive gap audit.

## What we did

### Network — US 24 adoption triage (Hawkeye + Sparky)

- Confirmed DHCP Option 43 (`192.168.1.12`) should be left in place — beneficial after TFTP recovery, harmless now.
- Exhausted SSH credential attempts programmatically using Python paramiko + Windows OpenSSH with SSH_ASKPASS helper. Tried: ubnt/ubnt, ubnt/ubiquiti, admin/admin, admin/ubnt, admin/ubiquiti, root/ubnt, root/ubiquiti, and several more. All rejected. Switch has custom credentials that survived hard reset.
- Confirmed switch is running Dropbear SSH, reachable on port 22, supporting curve25519 and group14 KEX — it's not a connectivity issue, it's a credentials issue.
- **Conclusion:** TFTP firmware recovery is the only remaining path. Jeff purchasing USB-to-Ethernet adapter. Procedure documented in [[network-design]].

### Network device placement guidance (Sparky)

- Roku/streaming boxes → Downton Abbey (main) — mobile app compatibility, 5 GHz performance
- Ring cameras/sensors → Downton Abbey-IOT — cloud-only, no LAN access needed, isolation preferred
- Nanit baby monitor → Downton Abbey-IOT — 2.4 GHz only, cloud-based, isolation preferred for sensitive video stream
- 2.4 GHz vs 5 GHz for Roku: 5 GHz preferred for stationary streaming; both bands on same SSID with Fast Roaming, device selects automatically

### PKA-Jeffrey → mypka migration (Hawkeye + Margaret)

- Audited PKA-Jeffrey: 69 files across 17 directories
- Decisions: skip old agent files (keep current mypka AGENTS.md), leave jeffrey.db (empty — 0-byte file, deleted), delete PKA-Jeffrey after validation
- Migrated 44 content files into `PKM/Documents/` by domain (automobiles, branding, drones, food, genealogy, homelab, investing, lake-erie, travel) and `PKM/CRM/People/`
- Updated 13 Team AGENTS.md contracts: all `../PKA-Jeffrey/` paths → `PKM/Documents/`
- Updated 13 `.claude/agents/` shims: same path updates
- Updated PKM/Environment/ host files and INDEX: removed PKA-Jeffrey path references
- Fixed Topics, Documents, and remaining agent files with stale references
- Validated: 44/44 files present, 0 live PKA-Jeffrey references (only historical session logs retain the name — correct)
- Deleted jeffrey.db (confirmed empty)
- **Deleted PKA-Jeffrey/ permanently** after full validation pass
- Committed: `ac864f5`

### Documentation — vehicles (Hawkeye + Rizzo)

- Discovered: zero vehicle files existed in PKA-Jeffrey (fleet-overview was blank)
- Found repair record at `PKM/Documents/automobiles/2008-subaru-outback-repair-record.md`
- Built `PKM/Documents/automobiles/vehicles/2008-subaru-outback.md` from repair record — VIN, engine (EJ253), odometer 149,830 mi, full 2026-05-29 service history, active issues, deferred 150k items, both OBD scan records
- Updated fleet-overview.md with Subaru row
- Throttle body cleaner confirmed: CRC #05678 non-chlorinated (Subaru bore coating caution)

### Documentation — new files created (Hawkeye)

- `PKM/CRM/People/danielle-adamowicz.md` — converted to GL-002 frontmatter; role: Assistant Dockmaster, Erie Yacht Club; 2026-05-22 lift-in logged in boating activity table
- `PKM/My Life/Projects/ninth-street-fence.md` — 9th Street fence project (Zale)
- `PKM/My Life/Projects/european-32mm-cabinet-cnc.md` — CNC cabinet build (Zale)
- `PKM/My Life/Projects/draft-beer-jockey-box.md` — draft beer / jockey box (Zale)
- `PKM/My Life/Goals/find-florida-property.md` — FL property search, Trinity/New Port Richey, under $350K, trip 2026-06-17 (Mulcahy)
- Updated Projects/INDEX.md and Goals/INDEX.md

### Documentation gap audit (Hawkeye)

Full gap list surfaced — see Open threads below.

## Decisions made

- **PKA-Jeffrey is retired.** mypka is the single source of truth. No exceptions going forward.
- **jeffrey.db deleted** — was a 0-byte placeholder, never populated. If SQL logging is ever wanted, Margaret builds a fresh schema from scratch.
- **Agent files from PKA-Jeffrey skipped** — current mypka AGENTS.md contracts are authoritative.
- **DHCP Option 43 stays** — beneficial after US 24 TFTP recovery, harmless to keep.
- **Streaming boxes (Roku) → main network; IoT sensors/cameras → IoT VLAN** — standing device placement policy.
- **Nanit baby monitor → IoT VLAN** — cloud-based, 2.4 GHz only, isolation preferred.

## Insights

- `diffie-hellman-group1-sha1` is fully removed from both modern paramiko (3.x) and Windows OpenSSH 9.5 — scripted SSH to legacy Ubiquiti devices requires older tooling (plink) or TFTP recovery. Keep this in mind for any future legacy UniFi adoption.
- Hot reset AND hard reset on the US 24 did not clear SSH credentials. TFTP firmware push is the only reliable credential wipe on this hardware.
- PKA-Jeffrey was a well-structured but largely empty scaffold — most domain knowledge files were stubs. The real knowledge will be built inside mypka going forward.
- Rizzo confirmed: vehicle fleet documentation was 100% missing before this session. Fleet builds from scratch.

## Realignments

- Jeff clarified there are TWO pending imports: (1) PKA-Jeffrey → mypka (now done), and (2) My Drive bulk import (~900 files) which remains on hold. These are separate efforts — do not conflate them.
- Rizzo was spawning from PKA-Jeffrey/automobiles/ — correct path is now PKM/Documents/automobiles/. All agents updated.

## Open threads

### Network
- [ ] US 24 TFTP recovery — Jeff purchasing USB-to-Ethernet adapter. When it arrives: download US-24 firmware .bin from ui.com, run Tftpd64, static IP 192.168.1.25 on adapter, hold reset + power-cycle, switch enters recovery at 192.168.1.20
- [ ] Switch port VLAN assignment — after US 24 adoption
- [ ] USG firmware update (4.4.57 → current)
- [ ] Rename APs in controller to meaningful names
- [ ] DHCP reservations for all infrastructure devices
- [ ] Band steering evaluation (after co-channel fix confirmed stable 1 week — confirmed stable since 2026-06-13)

### Vehicles
- [ ] Full vehicle fleet list needed from Jeff — only Subaru Outback documented
- [ ] Subaru: trim, color, transmission, registration expiry, insurance carrier/policy/expiry still `[NEEDED]`
- [ ] Pre-2026 Subaru service history — drop receipts in Team Inbox
- [ ] NHTSA recall check for Subaru VIN 4S4BP86C284304726 at nhtsa.gov/recalls
- [ ] Subaru active repair: vacuum/air leak → throttle body clean → idle relearn → LTFT verification

### Rentals
- [ ] Frank has zero property files — 9th Street and Alex-Pittsburgh Lease completely undocumented. Jeff to provide property addresses, tenant names, lease terms

### Gunsmithing
- [ ] Flagg has no build files — no AR-15/AR-10/1911 builds documented

### Car detailing
- [ ] Painless has no content — no product inventory, no session logs

### CRM
- [ ] Only 2 people, 2 orgs documented — tenants, contractors, marina contacts, vendors all missing

### Investing
- [ ] Winchester's holdings.md is all placeholders — actual positions needed

### My Life
- [ ] Key Elements are scaffold stubs — Jeff's real content needed for health, work, personal, homelab, lake-erie
- [ ] Goals: only FL property + sample. Financial, career, health goals missing
- [ ] Habits: only sample — actual habits not documented

### Homelab
- [ ] Lighthouse, Watchtower, OPNsense host files are stubs — build status, specs, running services thin

### Florida trip
- [ ] Jeff heading to Florida 2026-06-17 (3 days) — listings will arrive in Team Inbox; Mulcahy to process against Trinity/New Port Richey criteria

### My Drive bulk import
- [ ] Still on hold — ~900 files, mapping ready, 4 open questions (Rentals scope, Trip Planning personal docs, Woodworking confirm, 3D Printing domain). Jeff to confirm when ready to proceed.

## Next steps

- Jeff to bring USB-to-Ethernet adapter → TFTP recover US 24 → adopt → configure port VLANs
- Jeff to provide full vehicle fleet list so Rizzo can build remaining vehicle files
- Jeff to drop FL property listings in Team Inbox when available (before/during June 17 trip)
- Jeff to provide rental property details so Frank can build property files

## Cross-links

- [[2026-06-13-sparky-hawkeye_network-rebuild]] — prior session (UniFi full rebuild, Sparky hire)
- [[network-design]] — home network design document
- [[2008-subaru-outback]] — vehicle file built this session
- [[find-florida-property]] — goal created this session
