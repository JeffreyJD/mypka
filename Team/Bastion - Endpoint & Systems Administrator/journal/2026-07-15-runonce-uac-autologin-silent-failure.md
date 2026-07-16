---
agent_id: bastion
type: journal-entry
created: 2026-07-15T00:00:00Z
updated: 2026-07-15T00:00:00Z
topic: runonce-uac-autologin-silent-failure
tags: [wsl2, docker-desktop, runonce, uac, autologin, provisioning]
linked_session_logs: []
linked_tasks: []
related_journal_entries: []
status: durable
---

# A RunOnce + elevation chain scheduled around a reboot needs its own pre-elevation log line, or a silent failure looks like nothing happened at all

## Context
On `bridget-laptop`, `ha-docker-setup-01-power-wsl.bat` scheduled `ha-docker-setup-02-docker-ha.bat` to auto-launch via `HKCU\...\RunOnce` after a WSL2-install reboot. Autologin was also enabled separately. After the reboot, Jeff reported "I do not see anything running" — no visible console window, no report file, no error. No live access to the machine to confirm root cause.

## What I learned
A self-elevating script (`Start-Process ... -Verb RunAs -Wait`) launched via `RunOnce` after an `AutoAdminLogon` reboot has two failure modes that both look identical from the outside — "nothing happened" — and neither one leaves any evidence unless you deliberately log *before* the elevation attempt:
1. UAC consent prompts on the secure desktop time out and default to deny if nobody clicks fast enough — and autologin removes the "type your password" pause that normally anchors a user's attention to the screen right at logon, making a missed/timed-out prompt more likely, not less.
2. A batch file with no error handling around a `powershell -File ...` call will still reach its trailing `pause`/report lines even if the inner elevation failed — in theory. But if the RunOnce-launched window itself renders behind other startup windows or gets closed before anyone looks, that safety net is invisible too.

The fix isn't to avoid elevation (it's legitimately required) — it's to write an unconditional, pre-elevation log line to a shared append-only file (`runonce-launch-log.txt` in this case) at the earliest possible point in every stage of the chain: the `.bat` entry point, before the existence checks; and the `.ps1`, before the `Start-Process -Verb RunAs` call, then again in a try/catch around that call logging the specific outcome (elevation granted vs. the exact exception message). That log line is the only thing that survives a missed UAC prompt or a window that vanished before being seen — it turns "nothing happened" into "it fired at 7:42:03, requested elevation, and nobody answered before it gave up."

## When this applies
Any future provisioning sequence that: (a) schedules a next step via `RunOnce` (or Scheduled Tasks at logon) to survive a reboot, and (b) that next step self-elevates via UAC. This is a reusable pattern, not a one-off — expect to reuse it for future WSL2/Docker/toolchain bootstraps on personal client devices.

## When this does NOT apply
Scripts that run fully elevated already (no UAC prompt in the chain), or that don't span a reboot (interactive, single-session scripts don't need the same blind-spot mitigation — the user is right there to see failures happen).

## Evidence
- `C:\Users\jeff\My Drive\ha-docker-setup-01-power-wsl.ps1`, `ha-docker-setup-01-power-wsl.bat`, `ha-docker-setup-02-docker-ha.ps1`, `ha-docker-setup-02-docker-ha.bat` (outside the myPKA vault — provisioning scripts for the pool-monitor HA sandbox, [[pool-monitor-automation]])
- Diagnosis was informed reasoning, not confirmed root cause — no live access to `bridget-laptop` to observe the actual failure at the time it happened.
