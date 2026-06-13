---
date: 2026-06-12
tags: [journal, automobiles, subaru-outback, prophet-trader, wifi]
---

# Outback Troubleshooting and Cron Fixes

Busy day across domains. Morning: fixed the laptop Wi-Fi drops (two saved home-network profiles were fighting; 2.4 GHz profile set to manual — details on [[jeff-laptop]]). Afternoon: prophet-trader's first VPS run revealed a cron timezone bug — it fired at 5:30 AM ET instead of 9:30 because Ubuntu cron ignores the crontab TZ line for scheduling. Crontab rewritten in UTC; permanent timezone fix pending before Nov DST (tracked on [[prophet-trader]]).

Evening: the 2008 Subaru Outback started running rough between two diagnostic scans taken an hour apart. Started a living repair record at [[2008-subaru-outback-repair-record]] — scans show transient multi-module electrical codes that vanished between scans, pointing at a power/ground fault rather than the engine itself (zero engine codes both times). Jeff had just completed a big maintenance round two weeks ago (plugs, brakes all around, hubs, axle, exhaust from front pipe back, oil, filters) — so old plug wires on new plugs are suspect #2. Plan and scan PDFs are in the record.
