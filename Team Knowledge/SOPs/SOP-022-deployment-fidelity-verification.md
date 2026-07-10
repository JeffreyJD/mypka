# SOP-022 - Deployment Fidelity Verification

> **Default owner:** Ledger. Any agent can invoke this skill, but Ledger is the independent check — the specialist who authored or deployed the change should not be the one running this SOP on their own work.

Ledger's signature workflow. Checks whether what's actually deployed, scheduled, and configured matches what was validated and intended — before it ships (Fidelity Check), when execution moves between systems (Decommission Verification), when a dataset feeds a decision (Data Provenance Check), and on a standing recurring cadence independent of any single deploy (Environment Drift Audit).

- **Reusable by any agent.** This is a skill, not 1:1 ownership. Ledger is the default executor; any agent can invoke the procedure when they need it (e.g. Pierce self-checking before requesting Ledger's independent pass).
- **References:** [[GL-007-verify-before-acting-on-a-finding]], [[GL-008-read-registry-before-creating-new-state]], [[GL-001-file-naming-conventions]]
- **Triggered by:** any config-, schedule-, or data-bearing change before it ships; any migration of execution between hosts/systems; any dataset feeding a gate/promotion decision; the standing recurring audit cadence.

## Why this SOP exists

Graduated from six fidelity gaps found across one week of Prophet Trader / backend work (2026-07 — see [[2026-07-10-deployment-verification-engineer-hire-research]]): a config value that silently drifted from its gate-passing baseline, a scheduling-order defect, a feature declared but never wired to live data, an unreproducible source dataset, decommissioned infrastructure that was still live, and scheduled jobs with no success signal. None were caught by a test, a code review, or a strategy evaluation — all were caught by the user or an investigation the user triggered. This SOP is the standing process that should have caught each one; see the "Coverage map" at the bottom of this SOP for exactly which phase would have caught which incident.

## §1 — Pre-deploy Fidelity Check

Run before any change lands that touches: strategy/config parameters, environment variables, scheduled jobs (cron, systemd timers, Windows Task Scheduler), or the wiring between a declared data dependency and its live source.

1. **Identify the last approved baseline.** Not the last commit — the last value that actually passed a gate or was explicitly signed off. For Prophet Trader strategy config, this is the value in Blake's most recent strategy evaluation brief or Phase gate assessment. For infrastructure config, this is the current `PKM/Environment/Services/` or `PKM/Environment/Hosts/` entry.
2. **Diff the incoming value against that baseline.** Read both directly — the live/incoming value and the approved baseline value — side by side. Any deviation is a finding regardless of whether it looks intentional. Do not assume the author meant to change it; surface the delta and ask.
3. **Walk every declared dependency the change lists** (a feature, an env var, an external data feed, an API call) and confirm there is an actual live code path feeding it — not just that the variable or function reference exists in the code. Read the runtime data flow, not just the declaration. A referenced-but-never-populated input is a CRITICAL finding (this is exactly the class of bug that produced the permanent no-op VIX filter — the code referenced the variable, nothing ever populated it in the live snapshot).
4. **Check for scheduling collisions.** If the change adds or modifies a scheduled job, read the full schedule of every other job on the same host (`crontab -l`, `systemctl list-timers`, or the Windows Task Scheduler export) and confirm no read-before-write ordering conflict, no resource contention, no silent overlap.
5. **Check for a positive success signal.** If the change is or touches an automated/scheduled job, confirm it emits something Jeff can see on success — not just on failure. "No news is good news" is not an acceptable signal; require an explicit confirmation (notification, log line checked by a separate monitor, heartbeat).
6. **Write the Fidelity Verification Report** (template below). Verdict: PASS / FAIL / UNVERIFIED.

## §2 — Decommission Verification

Run whenever execution of a system, job, or process moves from one host/environment to another (e.g. a scheduled job moving from a laptop to a VPS).

1. **Directly inspect the OLD system.** Do not trust the migration record or the fact that the new system works. On Windows: open Task Scheduler (or query it) and read the actual enabled/disabled state of every task related to the migrated process. On Linux: read `crontab -l` and `systemctl list-timers --all` directly on the old host.
2. **Confirm the old path cannot fire** — not "is scheduled to be removed," not "should have been disabled." If it's still enabled, that is a CRITICAL finding regardless of how long the new system has been running clean.
3. **Disable or flag for disabling** anything still live, per the owning specialist's process (Pierce, typically).
4. **Write the Decommission Certificate** — what was checked, exact command/method used, state found, and what was changed.

## §3 — Environment Drift Audit (recurring)

Cadence: minimum monthly, plus triggered immediately after any migration (§2) or major config change (§1). This is the check that catches drift introduced *after* a clean deploy — a task silently re-enabled, a config hand-edited on a host, an old system nobody remembered to kill.

1. **Walk every registered host and service** in `PKM/Environment/Hosts/` and `PKM/Environment/Services/`.
2. **For each, directly inspect live state.** Do not infer from the registry note — the registry describes intent (per [[GL-008-read-registry-before-creating-new-state]]); this audit's whole purpose is confirming intent still matches reality. Read actual cron/systemd/Task Scheduler entries and actual running config values.
3. **Compare against two references:** the registry note, and (for anything gate-relevant) the last-approved spec, e.g. Blake's approved strategy config.
4. **Flag every discrepancy**, including observability gaps — a job that is running but has no verifiable success signal anywhere.
5. **Write the dated Environment Drift Audit report.**

## §4 — Data Provenance Check

Run when a dataset feeds (or is about to feed) a go/no-go, promotion, or Phase gate decision.

1. **Confirm the dataset's source, fetch method, and fetch date are documented** somewhere durable (not just "I think it came from X").
2. **Attempt to reproduce the dataset from the current live data source.** If it can't be reproduced, that is a blocking finding for any decision built on it — not a footnote appended after the fact.
3. **File the finding** inside whichever report (§1 or §3) triggered the check.

## Verdict rules (all four procedures)

- **PASS** — every declared dependency verified live, no undisclosed deviation from the approved baseline, no scheduling collision, no undecommissioned old system, observability confirmed, data provenance confirmed where applicable.
- **FAIL** — any CRITICAL finding: a referenced-but-unfed dependency, an old system still capable of firing after a migration, undisclosed drift from an approved gate value, or an unreproducible dataset feeding a live decision. Does not ship / does not close until fixed and re-checked by Ledger.
- **UNVERIFIED** — Ledger could not directly inspect the live system this session (no host/VPS access, no way to read the actual running state). Never upgrades to PASS on documentation, git history, or say-so alone (per [[GL-007-verify-before-acting-on-a-finding]]) — escalate to Hawkeye/Jeff for access.

## Report template

```
# Fidelity Verification Report: <project/system>

**Inspector:** Ledger
**Date:** YYYY-MM-DD
**Procedure:** Pre-deploy Fidelity Check | Decommission Verification | Environment Drift Audit | Data Provenance Check
**Verdict:** PASS | FAIL | UNVERIFIED

## Scope

<what was checked, which host/service/config, which baseline it was diffed against>

## Method

<exact commands/methods used to inspect live state — e.g. "read crontab -l on davisglobe-vps-ash-1 via SSH", "diffed live config.yaml preferred_regimes against Blake's 2026-06-XX strategy-eval brief">

## Findings

### [SEVERITY] <short title>

**What:** <the delta between intended and actual, stated precisely>

**Evidence:** <what was directly observed, not inferred>

**Baseline compared against:** <the approved value/spec this was diffed against>

**Recommendation:** <handoff — usually to Pierce for fix, or Blake for adjudication if the drift may be intentional>

(repeat per finding)

## Verdict

<PASS / FAIL / UNVERIFIED, one-sentence rationale>
```

## Output / definition of done

- [ ] Live state was directly inspected — never inferred from documentation, commit history, or say-so alone.
- [ ] Every finding names its verification method explicitly.
- [ ] Verdict is unambiguous: PASS, FAIL, or UNVERIFIED — no "mostly fine."
- [ ] Report written to `Deliverables/YYYY-MM-DD-<slug>.md` per the deliverable-type naming in [[Team/Ledger - Deployment Verification Engineer/AGENTS]].
- [ ] If FAIL, the owning specialist (usually Pierce, sometimes Blake for strategy-adjacent drift) is notified via Hawkeye with the report attached.
- [ ] If a fix happens, Ledger re-checks. No second-hand confirmation that the fix landed.
- [ ] For §3 (Drift Audit), the next audit date is set and (if it's the recurring cadence) noted for Hawkeye to track.

## Coverage map — what this SOP would have caught

| Founding incident | Phase that catches it |
|---|---|
| Strategy config silently drifted from gate-passing value | §1 step 2 (baseline diff) — and §3 if introduced between deploys |
| Backup scheduled ahead of its input job | §1 step 4 (scheduling collision check) |
| VIX filter never wired to live data — permanent no-op | §1 step 3 (declared-dependency-to-live-path check) |
| Backtest VIX dataset unreproducible | §4 (data provenance check) |
| Old Scheduled Tasks still firing after VPS migration | §2 (decommission verification) — and §3 as a standing backstop even if §2 was skipped |
| Two of three scheduled reports never send a success notification | §1 step 5 and §3 step 4 (observability coverage) |

## Updates to this SOP

- 2026-07-10 — created (Ledger's founding SOP, drafted by Potter per [[SOP-001-how-to-add-a-new-specialist]]), graduated from six Prophet Trader fidelity gaps surfaced the week of 2026-07-07.
