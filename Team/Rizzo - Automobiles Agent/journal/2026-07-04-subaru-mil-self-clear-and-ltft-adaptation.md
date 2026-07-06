---
agent_id: rizzo
type: journal-entry
created: 2026-07-04T00:00:00Z
updated: 2026-07-04T00:00:00Z
topic: subaru-mil-self-clear-and-ltft-post-highway-adaptation
tags:
  - subaru
  - obd
  - ltft
  - mil
  - load-dependent-fault
  - diagnostic-methodology
  - cooling
linked_session_logs: []
linked_tasks: ["tsk-2026-06-30-001"]
related_journal_entries: ["2026-07-01-subaru-obd-drive-analysis"]
status: durable
---

# MIL self-clearing between load sessions is diagnostic evidence of a load-dependent fault

## Context

The 2026-07-01 17:34 driveway idle session (950 rows, 25 min stationary) was analyzed against the earlier 15:26 highway drive session from the same day. Two patterns emerged that are durable diagnostic principles: MIL self-clearing behavior, and post-highway LTFT adaptation at idle.

## What I learned

**1. When a MIL code is ON at the end of a drive session but OFF at the start of a subsequent idle session, the fault is load-dependent.**

The 15:26 drive session ended with MIL = 1, dtc_count = 1. By 17:35 (approximately 103 minutes later), MIL = 0, dtc_count = 0. No one cleared codes. The ECU self-cleared. This means the fault condition did not re-confirm on whatever key cycles occurred between the two sessions.

On OBD-II platforms, a confirmed fault (two drive cycle failures) remains stored until cleared — unless it is a type A fault that clears after a set number of consecutive warm drive cycles without re-failure. A fault that clears itself in ~100 minutes of key-off time, with no intervention, almost certainly only triggers under load conditions that were NOT present during the intervening period (which appears to have been key-off/engine stopped). The car did not idle between 15:52 and 17:35 — it was stationary.

Implication: the P-code is a misfire or lean event that only crosses the OBD-II detection threshold under acceleration or highway load. This is mechanically consistent with the intake air leak diagnosis — the leak is a fixed-volume unmetered air source that is a large fraction of idle airflow but negligible at highway load. Under heavy load, the lean condition is not severe enough to trigger a misfire threshold. At moderate acceleration (the 15:32 MIL event was at 53 km/h), the cylinder(s) may be just at the lean misfire threshold — enough to confirm a DTC. At stationary idle, no misfire, so the code does not re-confirm.

**Never conclude that a fault is resolved just because a subsequent session shows MIL = 0.** If the subsequent session is idle-only, the load conditions that triggered the original fault were never revisited. The MIL will light again on the next drive.

**2. LTFT adapts downward at idle when preceded by a highway drive session — this is ECU recalibration, not a physical repair.**

The June 30 idle session and the July 1 morning sessions showed LTFT B1 locked at +15.62%, LTFT B2 at +10.16%. After the July 1 15:26 highway drive (which drove LTFT near zero at highway load), the July 1 17:34 idle session started at the same 15.62/10.16 values but within 90 seconds the ECU adapted them downward: B1 → 14.06%, B2 → 7.81%. These values then locked for the rest of the 25-minute session.

The ECU uses learned LTFT maps indexed by load and RPM. After a highway drive with diverse load points, the map may contain freshly updated cells that then influence how aggressively the idle cell is trimmed on the next start. The downward adaptation is real ECU behavior, but the underlying cause (unmetered air at idle from the leak) is unchanged. The ECU is simply finding a slightly different equilibrium trim that satisfies its lambda target.

The practical consequence: if you measure LTFT immediately after a highway drive, you may get a lower idle LTFT reading than if you measure from a cold soak. For the EZ30D lean condition, use the cold-soak reading (or first warm-up from ambient) as the more conservative baseline — it better reflects worst-case lean correction demand.

**3. Fan kick-on signature in OBD data: load drop + MAF step-down at threshold temperature.**

When the cooling fans kick on, the alternator increases load to supply the fan motors. This shows as a discrete step-down in:
- Engine load: 26%→20% (fan electrical draw loads the alternator, which loads the engine)
- MAF: 4.24→3.56 g/s (slightly lower airflow as the ECU manages the additional load)
- RPM: 715→696 (slight idle dip)

This pattern is visible in the OBD data at 17:45:56 when coolant hit 113°C. The step-down is not gradual — it is a step change coincident with fan activation. This is useful for confirming fan operation even without a visual observer: a sudden load/MAF step-down at expected operating temperature is the electrical fingerprint of fan engagement.

The critical negative finding: even with fans confirmed running (both electrically confirmed via the data signature and visually confirmed by Jeff), the coolant still climbed from 113°C to 114°C over the next 15 minutes. Fans alone cannot maintain safe operating temperature. This confirms a cooling flow or heat-transfer problem, not a fan problem.

**4. STFT B1 hot-idle escalation is a consistent EZ30D lean pattern above 113°C.**

At full operating temperature on this EZ30D, STFT B1 climbs from near-zero at warm-up to a sustained 3.91–5.47% at 113–114°C. Combined with LTFT B1 at 14.06%, total commanded lean correction exceeds 18% at hot idle. This is above the threshold where lean misfire becomes likely on a six-cylinder engine at idle RPM (695–710 RPM).

The escalation is temperature-dependent, not time-dependent. As coolant rises from 90°C to 113°C, STFT B1 progressively increases. This suggests either: (a) the intake air leak volume increases with engine bay heat expansion (rubber components relax as they heat), or (b) there is a separate high-temperature lean contribution (e.g., higher fuel vaporization reducing delivered fuel mass at hot soak). The coupler sleeve inspection should prioritize running the engine to temperature before inspecting for visible cracks — a hairline crack may only open enough to admit significant air when the rubber is fully heat-soaked.

## When this applies

- Any future session where MIL is ON at end of drive but OFF at start of next session — the fault is load-dependent; do not declare it resolved.
- Any LTFT measurement taken after a recent highway drive — adjust for post-drive adaptation; cold-soak LTFT is more conservative.
- Any OBD session where cooling fans cannot be visually observed — look for the load/MAF step-down pattern at expected fan activation temperature (~95°C on this platform).
- Any hot-idle STFT comparison — note whether coolant was at full temperature (113°C+) or only warm (85–98°C); STFT at 90°C is not comparable to STFT at 113°C on this vehicle.

## Evidence

- Idle session CSV (17:34): `C:\Users\jeff\dev\obd-scanner\logs\2026-07-01-17-34-2008-subaru-outback-log.csv` (950 rows, 17:35:02–18:00:23)
- Drive session CSV (15:26): `C:\Users\jeff\dev\obd-scanner\logs\2026-07-01-15-26-2008-subaru-outback-log.csv` (992 rows, 15:27–15:52)
- Vehicle record: [[2008-subaru-outback]]
- Active task: [[tsk-2026-06-30-001-subaru-ez30d-active-diagnostic]]
- Prior journal entry: [[2026-07-01-subaru-obd-drive-analysis]]
