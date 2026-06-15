# Decision Memo — Farragut Motor Selection (and Count)

**To:** Jeffrey
**From:** Trapper
**Date:** 2026-04-17
**Project:** drones/ — Farragut (Tarot 650 Sport)
**Status:** Awaiting approval
**Related:** drone_fleet.md, farragut.md, shared-kit.md

---

## The question

Two linked decisions that unlock the entire downstream Farragut BOM:

1. **Frame configuration:** quadcopter (X4) or hexacopter (X6)?
2. **Motor choice:** T-Motor MN3508 380KV (current candidate) or alternative?

These are the keystone decisions. Until they're made, ESC selection, battery voltage, battery capacity, comms link current draw, and AUW / thrust-to-weight modeling are all blocked.

## Why it matters now

The Tarot 650 Sport frame supports both X4 and X6 configurations. The choice cascades:

| Decision driven by motor+count | Impact |
|---|---|
| ESC count and current rating | 4 vs 6 ESCs, sized to peak motor current |
| Battery voltage (4S vs 6S) | Driven by motor KV and target prop RPM |
| Battery capacity (8–16 Ah) | Driven by total current draw × target flight time |
| PDB headroom | Matek PM12S-3 rated for 12S / ~200A — fine either way, but current budget changes |
| Payload capacity | Affects camera/gimbal and companion computer options downstream |
| Redundancy profile | X6 survives single motor/ESC failure; X4 does not |

Mission profile in the reference doc: "autonomous waypoint surveillance, long-range, RTSP to Frigate." That implies extended flight time over property, carrying a Jetson-class companion computer plus a camera/gimbal — payload estimated in the 600g–1000g range depending on gimbal choice.

## Options

### Option A — Quad (X4) with T-Motor MN3508 380KV

This is what the reference doc currently lists as the candidate configuration.

**Specs**
- 4 × MN3508 380KV on the 650mm frame
- Target battery: 6S LiPo, 10000–12000 mAh range
- Props: ~13" (13x4.4 or 14x4.8 typical on this motor/KV pairing)
- Estimated thrust: ~900g per motor at hover throttle → ~3600g total
- Typical AUW with payload: ~2200–2600g → thrust-to-weight ~1.4–1.6

**Pros**
- Simpler build: 4 motors, 4 ESCs, 4 props to balance and maintain
- Lower component cost (~$200–250 less than hex)
- Lighter without payload → longer flight time on same battery
- Proven configuration for the 650-class frame

**Cons**
- No redundancy. Single motor or ESC failure = crash.
- Thrust-to-weight is adequate but not generous — payload headroom is limited
- For long-range autonomous work, losing a motor mid-mission is more than theoretical

### Option B — Hex (X6) with T-Motor MN3508 380KV

Same motor, six of them.

**Specs**
- 6 × MN3508 380KV on the 650mm frame in hex config
- Target battery: 6S LiPo, 12000–16000 mAh
- Estimated thrust: ~900g × 6 = ~5400g
- Typical AUW with payload and bigger battery: ~2800–3400g → thrust-to-weight ~1.6–1.9

**Pros**
- Motor-out survivability. ArduCopter handles hex motor failure gracefully with the right failsafes configured.
- More payload headroom → more camera/gimbal options and bigger companion computer options
- Better hover efficiency at higher AUW (more props sharing the load)

**Cons**
- 2 extra motors, 2 extra ESCs, 2 extra props
- ~50% more component cost on the power system
- Heavier airframe → requires larger battery → diminishing returns on flight time
- More complex wiring, more failure surfaces
- Longer build time

### Option C — Different motor class (quad or hex)

Alternatives worth considering if MN3508 380KV isn't the right match:

| Motor | KV | Best for | Notes |
|---|---|---|---|
| T-Motor MN3510 360KV | 360 | Heavier payload, 6S, 15" props | ~10% more thrust, ~20% more weight per motor |
| T-Motor MN4006 380KV | 380 | Heavy-lift, 6S | Overkill for 650 frame unless payload grows significantly |
| Sunnysky X3508S 380KV | 380 | Budget alternative to MN3508 | ~40% cheaper, ~5% less efficient |

None of these have been priced or spec-verified — this would need a research pass if Jeffrey wants to look beyond the MN3508.

## Trapper's recommendation

**Option B — hex (X6) with T-Motor MN3508 380KV.**

Reasoning:
1. Farragut's mission is long-range autonomous work over Jeffrey's property, carrying a Jetson-class companion plus camera/gimbal. That's payload-heavy and unforgiving-of-failure work.
2. Motor-out survivability matters more on a drone flying GPS waypoint missions beyond visual line of sight than on a manual quad. A failed motor on an X4 mid-mission drops a $2–3k build into a tree.
3. The additional cost of 2 motors + 2 ESCs + 2 props is small relative to total fleet investment (companion computer alone is in the $600–800 range for a Jetson Orin NX).
4. Hex gives payload headroom that protects the camera/gimbal decision from being over-constrained later.
5. The MN3508 380KV is a well-documented motor on this frame class with ample community data for tuning.

Would recommend Option A instead only if budget is the primary constraint or if Jeffrey wants the simpler build as a learning platform before considering a future hex.

Would recommend Option C only if Jeffrey has a specific heavier payload in mind (e.g., larger gimbal, dual-camera package) that MN3508 can't handle cleanly.

## What I need from Jeffrey

- [ ] Approve **Option A** — quad, MN3508 380KV. I'll spec ESCs (4x, ~40A) and battery (6S, ~10Ah) next.
- [ ] Approve **Option B** — hex, MN3508 380KV. I'll spec ESCs (6x, ~40A) and battery (6S, ~14Ah) next.
- [ ] Approve **Option C** — different motor class. I'll run a research pass on the alternatives above (or any specific motor you want evaluated) and come back with a second memo.
- [ ] Request more info — specific thrust/weight modeling, cost comparison, flight-time estimates, or vendor/availability check.

Nothing gets ordered until you check a box. ESC, battery, and prop selection all queue behind this decision.

---
*Filed to: drones/leader-inbox/ per the Leader Inbox Rule. Nothing leaves the project without Jeffrey's sign-off.*
