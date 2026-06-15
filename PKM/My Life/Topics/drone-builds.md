---
name: Drone Builds
key_element: homelab
tags:
  - ardupilot
  - autonomous
  - fpv
---

## What I think about here

Autonomous drone engineering using ArduPilot/ArduCopter firmware. Three builds: Farragut (large outdoor autonomous surveillance — Tarot 650, Pixhawk 6C, Jetson Orin NX companion computer, mLRS 915MHz, Phase 4: AprilTag autonomous landing), Resolute (sub-250g indoor/outdoor — FlyFishRC Atlas 4 LR, complete), Intrepid (future indoor build — planning phase).

Shared kit: RadioMaster TX16S Mark II Max ELRS controller, Mission Planner GCS, all video via RTSP to Frigate on Watchtower.

## Open questions

- Farragut GPS vs. non-GPS decision for motor selection (see drones/leader-inbox)
- Resolute GPS integration decision
- Intrepid specs TBD

## Sources

- `PKM/Documents/drones/farragut.md`
- `PKM/Documents/drones/resolute.md`
- `PKM/Documents/drones/shared-kit.md`
- [[homelab]] — Key Element
