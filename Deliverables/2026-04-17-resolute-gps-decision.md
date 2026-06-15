# Decision Memo — Resolute GPS Yes/No

**To:** Jeffrey
**From:** Trapper
**Date:** 2026-04-17
**Project:** drones/ — Resolute (FlyFishRC Atlas 4 LR)
**Status:** Awaiting approval
**Related:** drone_fleet.md, resolute.md, shared-kit.md

---

## The question

Does Resolute need to fly outdoor autonomous waypoint missions?

- **Yes** → add a GPS module (~12g), which consumes nearly all remaining weight margin.
- **No** → omit GPS, preserve margin for build slop, and restrict Resolute to manual / FPV-style flight.

This is a single yes/no that unblocks at least three downstream component decisions (FC selection, UART/I²C headroom, mission profile).

## Why it matters now

Current Resolute weight budget (from drone_fleet.md):

| Line item | Est. weight | Status |
|---|---|---|
| Frame (Atlas 4 LR) | 75g | Locked |
| Motors ×4 | 40g | TBD |
| 4-in-1 ESC | 8g | TBD |
| Flight controller | 5g | TBD |
| Battery (GNB 380 6S LiHV) | 60g | Locked |
| Camera (RPi Cam 3 Wide) | 4g | TBD |
| Companion SBC (Pi Zero 2W) | 10g | TBD |
| ELRS Rx | 2g | TBD |
| GPS | 12g | **This decision** |
| Props ×4 | 8g | TBD |
| Wiring / hardware | 12g | Estimate |
| **Estimated AUW** | **~236g** | |
| **Margin to 250g ceiling** | **~13.4g** | |

With GPS in: margin drops to ~1.4g before any build slop, solder mass, or spec-sheet optimism. Effectively zero.
Without GPS: margin stays at ~13.4g — which is still tight but leaves room for the small overages that always show up at final weigh-in.

## Options

### Option A — Include GPS (~12g)

**What you get**
- Full ArduCopter mission capability: waypoints, RTL, geofencing with GPS reference, position hold (Loiter), auto-land at home.
- Resolute becomes a second platform capable of the same autonomous surveillance missions as Farragut.
- Parity with the rest of the fleet on failsafe behavior (GPS-dependent RTL).

**What it costs**
- ~12g budget hit. Remaining margin ~1.4g — almost certainly blown on first weigh-in.
- Forces tighter spec-sheet shopping on every other TBD component.
- Likely forces giving up one of: camera, companion SBC, or heavier props. Something has to come out.
- FC must have a spare UART (most candidates do — not a hard constraint, just something to confirm).

**Candidate modules**
- BN-880 (~9–12g depending on variant) — leading candidate
- Lightweight M8N modules (~8–10g) if you're willing to skip the magnetometer and rely on IMU-derived heading

### Option B — Omit GPS

**What you get**
- Preserves ~13.4g of margin to absorb the inevitable final-assembly weight creep.
- Simpler build, fewer failure modes, cleaner wiring.
- Keeps all other TBD components on the table without weight-trimming pressure.

**What you give up**
- No waypoint missions on Resolute. AltHold / Stabilize / manual only.
- No GPS-based RTL. Failsafes fall back to AltHold or Land at current position.
- No geofencing by GPS coordinates (can still do altitude ceiling via barometer).
- Positional mission reuse from Farragut does not apply.

### Option C — Defer

Select and weigh every other component first. Re-run the math with real numbers. Decide GPS last.

**Tradeoff:** adds ~2 weeks to the decision tree but removes estimation error from the call.

## Trapper's recommendation

**Option B — omit GPS on Resolute.**

Reasoning:
1. The reference doc already describes Resolute's mission as "agile indoor/outdoor surveillance" with a hard sub-250g constraint. Indoor flight doesn't benefit from GPS, and outdoor agility work is typically manual/FPV anyway.
2. Farragut is the autonomous-waypoint platform. Resolute's role is agile and close-in. Forcing them into the same mission profile dilutes both.
3. A 1.4g margin on a 250g hard ceiling is not a margin — it's an inevitability of going over. Final weigh-in almost always reveals ~5–10g of optimism in spec sheets.
4. GPS can be added later if we build a second Resolute variant that explicitly targets outdoor autonomy.

Open to Option A if Jeffrey wants fleet-wide mission parity and is willing to cut camera or SBC to make weight.

## What I need from Jeffrey

- [ ] Approve **Option A** (include GPS) — I'll start sourcing BN-880 class modules and flag which other TBD item gets trimmed
- [ ] Approve **Option B** (omit GPS) — I'll lock "no GPS" into resolute.md and move on to FC/motor selection
- [ ] Approve **Option C** (defer) — I'll select all other components first and resurface this in ~2 weeks
- [ ] Request more info on a specific option

Nothing gets ordered until you check a box.

---
*Filed to: drones/leader-inbox/ per the Leader Inbox Rule. Nothing leaves the project without Jeffrey's sign-off.*
