# Farragut — Large Outdoor Autonomous Surveillance Drone

Named after Admiral David Farragut — US Navy naming convention.

## Build Specification

| Component          | Model / Spec           | Status       |
|--------------------|------------------------|--------------|
| Frame              | Tarot 650 Sport        | Build phase  |
| Flight Controller  | Pixhawk 6C             | Build phase  |
| Companion Computer | Jetson Orin NX         | Build phase  |
| Motors             | T-Motor MN3508         | Build phase  |
| Radio Link         | mLRS 915MHz            | Build phase  |
| GCS                | Mission Planner        | Shared       |
| Controller         | TX16S Mark II Max ELRS | Shared       |

## Purpose
Large outdoor autonomous surveillance.
Primary use case: autonomous patrol missions with Jetson-powered
computer vision feeding Frigate on Watchtower.

## Video
RTSP feed → Frigate NVR on Watchtower R740

## Phase 4 (Future)
AprilTag-based autonomous precision landing and charging station.
Evaluated using AprilTag on Jetson Orin NX.

## Build Status
Phase: Active build
Next: Motor mounting and ESC wiring

## ArduPilot Config
- Config files: drones/ardupilot-configs/farragut.param
- Mission plans: drones/mission-plans/farragut/
