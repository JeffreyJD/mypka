# ADR-001 — Unified Alert & Notification Architecture

- **Status:** Proposed — pending Jeff's approval (human gate, not a formality)
- **Author:** Keystone (Architect) — read-only design authority; never implements
- **Date:** 2026-07-21
- **Supersedes:** none (first ADR in this repo)
- **Consulted:** [[Deliverables/2026-07-21-unified-alerting-architecture-research|B.J.'s external research brief]], [[Team Knowledge/Guidelines/GL-018-inbox-triage-and-classification]], [[Team Knowledge/SOPs/SOP-023-triage-inbox]], [[Team Knowledge/Workstreams/WS-006-software-change-lifecycle]], [[Team Knowledge/Workstreams/WS-007-infrastructure-change-lifecycle]], [[Team Knowledge/Guidelines/GL-017-specialist-handoff-protocol]], `PKM/Environment/Hosts/davisglobe-vps-ash-1.md`, `PKM/Environment/Accounts/{telegram-prophet-bot,healthchecks-io}.md`

## Why this ADR exists, and a note on scope

This started as five parallel domain surveys (email, home automation, homelab, network, VPS/software) plus external research, aimed at one incident: YoLink fridge/freezer alarms fired almost daily for a month, buried in email, unnoticed. Partway through drafting, Jeff reframed the priority directly: **the goal is not a one-time inbox cleanup — it's a standing, always-on assistant with a continuous view of everything landing in his inboxes (plural), not a tool he has to remember to invoke.** That reframe changes what ships first, not the underlying five-domain design. This ADR reflects both: it bundles two coupled decisions Jeff should approve together, because the second depends on the first's output.

- **Decision 1 (primary, near-term critical path):** how the email pipeline (GL-018/SOP-023, already designed and working in dry-run) becomes a *standing* multi-inbox assistant instead of an on-demand tool.
- **Decision 2 (complementary, ships in parallel where unblocked, later where not):** the shared cross-domain relay + severity scheme that home automation, homelab, network, and VPS/software alerts all funnel into — with email's `ALERT`-class output as one of its inputs, not a separate system.

Both share two non-negotiable cross-cutting rules: **human-in-the-loop confirmation**, generalized here from GL-018's email-specific rule into a system-wide invariant, and **no historical backfill on onboarding** (see "Cross-cutting decision" below for both).

A note on why this is one ADR covering two decisions rather than two: they were commissioned together, they share the confirmation/severity framework, and Decision 2's only live input today is Decision 1's output (email `ALERT` items). If a future change needs to revise only one of them, split it into a superseding ADR at that point rather than editing this one in place — see Keystone's standing rule against silent edits.

---

## Decision 1 — The email pipeline becomes a standing, scheduled, multi-inbox assistant

### Context

GL-018 and SOP-023 are fully designed and already shipped (taxonomy, three-tier priority override, propose-then-confirm, PKM routing). But as written, SOP-023 states plainly: it "runs on-demand only... or on a schedule once a trigger layer exists" — **that layer does not exist.** Today "the assistant" is a manual invocation inside an LLM session. That is structurally the same failure class as the incident that started this work: a system that only helps when a human remembers to ask it to. Only one inbox (`gmail-personal`) has actually been dry-run; `davisglobe` is architected for (`inbox_id`-scoped state already exists) but not onboarded. (`perficient` is out of scope entirely — an earlier draft carried it over from a stray session-log note that was itself wrong; Jeff confirmed it has nothing to do with this effort, and GL-018 has already been corrected to remove that reference.) Separately, Jeff confirmed sending email replies on his approval is a "must have" — resolved below to mean **both** draft and immediate-send, selectable per message, not a single fixed pipeline choice.

### The real question

Where does SOP-023 *run* when nobody is in a chat session, and what can it do unattended versus what still needs a human turn?

myPKA has no runtime of its own — "the folder is the system," no build step, no code execution inside `PKM/`, `Team Knowledge/`, etc. The vault lives on `jeff-laptop`'s Google Drive. The only always-on compute Jeff already owns is `davisglobe-vps-ash-1` (Hetzner VPS, already running Prophet Trader's cron jobs, already calling the Anthropic API directly from a cron-triggered script for LLM-driven work — `weekly_strategy_report.py` is the existing precedent for "a scheduled, unattended script calls an LLM API to do judgment work and produce output"). That precedent is the load-bearing fact this decision leans on: the mechanism to make SOP-023 "standing" already has a working analog on hardware Jeff already pays for.

### Options

**Option 1 — VPS runs fetch + classify + alert-push continuously; vault writes stay session-based (staged, reconciled next session).**
A scheduled script on `davisglobe-vps-ash-1` (cron or systemd timer) calls the Gmail API to fetch each onboarded inbox's window, calls the Anthropic API with the GL-018 taxonomy + SOP-023 procedure loaded as context to classify, executes only the two actions that stay entirely inside the mail domain's own already-granted credential (`TRASH` of unambiguous junk, `ARCHIVE`), and pushes every `ALERT` and `ACT` proposal through the shared relay (Decision 2) immediately — Jeff sees it on his phone in near-real-time. `FILE` writes (PKM notes, attachments) and `ACT` confirmations (actually creating the calendar event or task) are staged as structured records (message-id, category, disposition, proposed action, target PKM path) in a durable queue the next live myPKA session reconciles at open, per the existing dedup/idempotency state SOP-023 already tracks.
- *Cost:* Low — no new credential class, reuses the mail API scope Jeff already granted, reuses the VPS's existing Anthropic-API-from-cron pattern.
- *Risk:* Low blast radius — the only thing that can go unattended-wrong is a bad TRASH/ARCHIVE call, which is already 30-day-recoverable and already the mildest failure mode GL-018 defines ("a false positive is a nuisance, not a failure").
- *Reversibility:* Full — nothing outside the mail domain is touched without Jeff.
- *Gap against the "true standing assistant" ask:* the *filing* half still lags until Jeff next opens a session. The *alerting* half — the half that actually would have caught the fridge alarm — is fully real-time. This is the 80/20: solves the failure that triggered this work without the largest blast-radius decision below.

**Option 2 — VPS executes the full SOP-023 procedure unattended, including direct vault writes via the Google Drive API.**
Same as Option 1, but the VPS also holds a Drive API OAuth credential scoped to write into the vault's Drive folder directly, so `FILE` writes and (with a Telegram inline-approval mechanism, not designed here) even `ACT` confirmations complete with zero session dependency.
- *Cost:* Medium-high — a new OAuth credential class, a new attack surface (an unattended cloud process with write access to Jeff's personal knowledge vault), and — because it touches credentials and a write path into shared state — this graduates from a Keystone design sign-off to also needing Vex's security review before it ships, per WS-006's gate stack.
- *Risk:* This is the largest blast-radius change in the whole proposal. `FILE` was already permitted to auto-execute without a per-item nod even in the interactive design (GL-018's propose-then-confirm rule already carves out `FILE` as additive/non-destructive) — so this option does not loosen any *policy*, but it does substantially widen *who/what* can exercise that permission unattended, at vault scope rather than mail-API scope.
- *Reversibility:* Partial — a credential is revocable; a bad unattended `FILE` write to the vault before anyone reads the run summary is not, cheaply.
- Genuinely the "true standing assistant" shape Jeff described. Recommended as the deliberate **next step after Option 1 ships and earns trust**, not as v1.

**Option 3 — Do nothing (keep SOP-023 on-demand only).**
Stated because it is the honest baseline, not a strawman: zero new cost, zero new risk. Rejected because it is the exact status quo that produced the incident this whole effort exists to fix, and it directly contradicts Jeff's explicit reframe that on-demand is not the goal.

### Recommendation

**Option 1 now. Option 2 as an explicit, named future upgrade — not bundled into this approval, and gated on its own Vex security review when Jeff wants it.** Option 1 converts SOP-023 from "a tool" into "a standing watcher that pushes to your phone," which is the load-bearing half of Jeff's reframe (never miss something again) — it does not require inventing a new, larger-blast-radius credential path before that value is realized. Option 2 is real and worth doing, but deserves to stand on its own approval and its own security gate rather than riding in on this ADR's back.

### Sub-decision — where does the standing runner live?

`davisglobe-vps-ash-1` is tagged `trading` end-to-end and is the box that executes Prophet Trader's real trades. Loading personal-email-triage automation onto it blends two unrelated blast radii onto one host.

- **Option A — co-locate on `davisglobe-vps-ash-1`.** Lowest cost (already hardened, monitored, has the Anthropic-API-from-cron pattern proven). Risk: a bug in the mail-triage script is now running on the same host as live trading infrastructure, even if in a separate process/venv/user.
- **Option B — a new, small, dedicated VPS for "myPKA personal-automation" workloads** (this runner today; the alert relay in Decision 2 tomorrow). Clean separation, ~$5-10/mo. New `PKM/Environment/Hosts/` entry, new deploy target — a legitimate Pierce/DevOps decision under WS-006, not a Trapper/Sparky one (it's cloud, not physical homelab hardware).

**Recommendation: Option A now** (ship fast, cost is real but small, host is already well-hardened per its security posture notes), **revisit Option B once this runner and the Decision-2 relay are both live and stable** — at that point the combined "always-on personal-automation surface" may justify the small added cost of separation. Not a decision to make speculatively today.

### Multi-inbox onboarding

Per Jeff's reframe, `davisglobe` onboarding is near-term, not backlog — GL-018/SOP-023 are already `inbox_id`-scoped for exactly this. (`perficient` is explicitly out of scope — see the Context note above.) Sequencing: onboard `davisglobe` starting in `dry-run` per SOP-023's existing ramp discipline (~2 weeks of Jeff watching classifier precision before graduating to live), same as `gmail-personal`. This is Radar's existing procedure, unchanged — the only new fact is that once Option 1's standing runner exists, "dry-run" for a newly onboarded inbox means "push alerts, stage everything else," not "print to a chat session nobody's watching."

**Design lock — no historical backfill on onboarding.** When `davisglobe` (or any inbox onboarded after it) goes live, its per-inbox state marker starts at the onboarding timestamp — the standing runner processes only mail arriving from that point forward. There is no historical sweep as part of standard onboarding. The `gmail-personal` inbox's original 30-day backfill (the live cleanup that seeded GL-018 itself) was a one-time, separately-approved exception to bootstrap that specific inbox's cleanup at the start of this whole effort — it is not the onboarding pattern going forward and must not be repeated by default. If Jeff ever wants a genuine historical sweep of a newly onboarded inbox again, that is a fresh, explicit, separately-approved ask each time — never something the onboarding procedure does on its own initiative.

### Resolved — draft vs. send: both, selected per-message at approval time

**Jeff has ruled on this; it is no longer an open question.** He wants both paths available simultaneously, not a single fixed pipeline choice made once at design time: at the moment he approves a drafted reply, he chooses, per message, either **"approve as draft"** (creates the Gmail draft only; Jeff sends manually) or **"approve and send"** (fires immediately, no manual step). This is a per-message decision at approval time, not a global setting or a one-time architecture pick between the two.

**Architectural consequence:** the `send_reply(message)` interface seam proposed above needs to carry the approval outcome, not just the message — effectively `send_reply(message, outcome)` where `outcome ∈ {approve_as_draft, approve_and_send}`:
- `approve_as_draft` → calls `create_draft` only (already available today, no new credential).
- `approve_and_send` → calls the `gmail.send`-scoped connector directly. **This connector is therefore a required build, not an optional path gated on which pipeline Jeff picked** — "approve and send" cannot function at all without it. It moves out of "open decision" and into the sequencing table below as a concrete near-term item (see item 6), same priority tier as the Google Contacts connector, and — per Jeff's direction to Klinger — **folded into the same Google Cloud project/OAuth client Klinger is already scoping for Contacts**, so Jeff does one Cloud Console setup session covering both `contacts.readonly` and `gmail.send` instead of two separate sessions.

**Note for whoever implements the approval surface** (wherever that lives — chat, Telegram, or otherwise): every drafted-reply proposal must present **both** options clearly per message — "approve as draft" and "approve and send" — never a single binary "approve?" that only exercises one path. This is a UI/prompt-design requirement on top of the interface seam, not something the interface alone guarantees.

---

## Decision 2 — The shared cross-domain relay + severity scheme

### Context (five domains, current state)

| Domain | Owner | Current state |
|---|---|---|
| Email | Radar | Fully designed (GL-018/SOP-023); becomes standing per Decision 1 |
| Home automation (YoLink/Ring/Nanit) | Relay | Zero Environment footprint; incident-causing device (YoLink) confirmed unmonitored for a month |
| Homelab (Lighthouse/Watchtower/OPNsense) | Trapper | Not built; 0%-mid-assembly. Nothing to monitor yet. |
| Network (UniFi) | Sparky | Live, dashboard-only, zero push. Confirmed 5-week blind spot (unadopted switch). |
| VPS/software | Pierce | Most mature: Healthchecks.io (cron dead-man's-switch, working) + a Telegram bot (hardcoded, `prophet-trader`-only). GitHub Actions failures land as unread platform email — two recent silent misses. |

B.J.'s research (full detail in the brief) converges on: Healthchecks.io and Uptime Kuma solve different failure classes and should coexist; generalizing the existing Telegram bot is the lowest-friction fix available today; Home Assistant, once real, should be the single home-domain upstream; a 3-tier severity scheme (critical/needs-attention/informational) fits solo-operator scale; and — the single most load-bearing finding — **the relay itself needs an external heartbeat, because "silently stops alerting" is structurally the same failure this whole effort exists to fix, one level up.**

Note: these five rows describe the five *domains of origin* — who owns wiring each source into the relay. They are not the same as the four *delivery channels* Jeff wants below; several domains share one channel by design (see "Channel structure").

### The shared relay's shape — where does it live and who calls it?

Today the Telegram bot is "a plain Bot API POST call... trivial to generalize" but embedded inside `prophet-trader`'s own repo and `.env` — nothing outside that repo can reach it. This sub-question is about *where the relay's code and ownership live* — a separate question from *what transport/channel structure it uses*, addressed next.

**Option 1 — Generalize in place: expose an HTTP endpoint or importable module from within `prophet-trader`.** Lowest effort. Rejected as the end-state: it makes an unrelated project (trading) the de facto host for infrastructure that isn't about trading, coupling two deploy lifecycles and gate tiers that should stay independent (prophet-trader is Full-tier, cost-of-failure-gated; a notification relay is not a trading decision and shouldn't inherit Blake's phase-gate ceremony by association).

**Option 2 — Extract to a small, standalone, source-and-severity-tagged relay** (a callable script/CLI + thin importable interface — not necessarily a persistent daemon), owned outside `prophet-trader`, deployed on the same VPS initially (see Decision 1's Option A/B sub-decision — this and the email runner are the same "personal-automation surface" question). Every producer (SOP-023's alert digest, prophet-trader's own alerts, a future GitHub Actions failure webhook, a future Kuma/HA push) calls one interface: `send(source, severity, message, metadata)`.

**Recommendation: Option 2.** The cost is small (a callable script, not new infrastructure in the heavy sense) and it directly fixes the real architectural problem: today only `prophet-trader` can alert Jeff about anything, which is exactly backwards from "a unified alert layer." This location decision stands regardless of which transport wins below — extraction is about ownership and blast-radius separation from `prophet-trader`, not about which messaging technology or channel count sits behind it.

### Channel structure — real separation by group, not tags-in-one-stream

**This is a revision to the transport recommendation below, not to the interface or the location decision above.** Jeff has stated a requirement stronger than "one critical channel vs. one general channel": distinct channels per group of alerts, so he can mute or check each group independently — real separation, not message-text tags inside a single stream.

An earlier working interpretation of the grouping (five channels, one per domain of origin) has been **directly corrected by Jeff** to the following **four channels**, which supersedes that assumption and is now decided, not inferred:

1. **Trading** — Prophet Trader specifically (fills, crash notifications, EOD summaries, anything about the trading process itself). Kept fully separate from general infrastructure even though both run on the same VPS — a trading alert and a disk-space warning are not the same kind of thing to Jeff, regardless of which box produced them. `source: prophet-trader`.
2. **Infrastructure** — one combined channel for everything technical/ops: VPS non-trading concerns (`source: vps` — disk/memory/systemd, GitHub Actions CI/deploy failures across repos), homelab once built (`source: homelab` — Lighthouse/Watchtower/OPNsense), and network/UniFi (`source: network`) — **plus backups specifically**, called out by Jeff by name (`source: backup` — VPS rclone-to-B2 backups today; future Proxmox backups and OPNsense config backups once homelab exists). All of this is one group, not three or four separate ones.
3. **Home automation** — YoLink/Ring/Nanit/Home Assistant (`source: yolink`, `source: ring`, `source: nanit`, `source: home-assistant`), its own channel.
4. **Email** — unchanged from the original ask (`source: email`); already its own channel via GL-018/SOP-023's existing tiering, not folded into Infrastructure.

Severity (critical vs. informational) remains a **property within each of these four channels**, exactly as before — this correction changes only the grouping axis (four channels, grouped as above, instead of five-by-domain-of-origin), not the severity/confirmation logic, which is unaffected.

**One inference this ADR makes, flagged for confirmation rather than asserted as settled:** Healthchecks.io's three trading-cadence checks (Daily Routine, Weekly Autopsy, Weekly Strategy Report, Daily Fidelity Check) monitor whether the *trading process itself* ran — this ADR reads them as **Trading**-channel content, alongside fills/crash notifications, rather than Infrastructure. GitHub Actions CI/deploy failures — even for the `prophet-trader` repo itself — are read as **Infrastructure**-channel content per Jeff's explicit "VPS non-trading... GitHub Actions failures" example, since a deploy/CI failure is an ops concern distinct from whether the strategy is trading. This Trading-vs-Infrastructure split for Healthchecks specifically is Keystone's inference from Jeff's "non-trading" qualifier, not something Jeff stated as a rule for Healthchecks by name — worth a quick confirmation with Jeff when Pierce wires it, cheap to flip if wrong.

This still changes what "the relay" must support. The transport reassessment holds, updated to four channels instead of five:

- **Multiple Telegram bot tokens, one per channel (four total).** Each channel is a distinct bot + chat, called through the same relay interface (`send()` resolves `source` to the right channel, and each channel to its token/chat_id, before posting). The existing `prophet-trader` bot is reused directly as the **Trading** channel's bot — an exact fit, since that bot's entire original purpose (fills, crash alerts, EOD summaries) *is* the Trading channel's content. Three new bot tokens are needed: **Infrastructure**, **Home Automation**, **Email**. Real separation, mutable/checkable independently in the Telegram app Jeff already uses daily. Bonus: this also *reduces* the single-point-of-failure blast radius B.J.'s Finding 6 warns about — a revoked token today would silently kill 100% of alerting; under this model it silently kills one of four channels, which is itself more likely to be *noticed* precisely because the other three keep working normally. Cost: three new bot registrations via BotFather (trivial, same mechanism as the existing bot), three additional credentials to store per [[Team Knowledge/Guidelines/GL-013-credential-backup-hygiene-on-operational-hosts]] — a modest, not a large, increase in secret-management surface.
- **A single Telegram supergroup with Topics enabled** (one topic per channel). Real separation from Jeff's point of view (mutable per-topic), but it does **not** reduce the SPOF risk above — one bot token still underlies every topic, so a single revocation still blacks out all four channels simultaneously, same blast radius as today. It also requires standing up and administering a supergroup, more ceremony than registering three more bot tokens for no corresponding benefit here. **Rejected** relative to the multiple-bot-tokens option above — strictly worse on the one axis (blast radius) that matters most per B.J.'s own findings, for no offsetting gain.
- **ntfy**, per B.J.'s research, has first-class topics with per-topic access control — the most structurally "correct" fit for named, mutable channels, and each topic can carry its own access token, which would *also* reduce the SPOF blast radius (a leaked/revoked topic credential affects one topic, not all). The cost is real and was already characterized in B.J.'s brief before this requirement sharpened it: a new self-hosted service (or ntfy.sh cloud account) to deploy and keep healthy — itself a new moving part needing its own place in the heartbeat story — plus a new mobile app for Jeff to install and learn, versus Telegram, which he already uses daily for exactly this purpose.

**Revised recommendation: multiple Telegram bot tokens (one per channel, four total) for v1**, reusing the existing `prophet-trader` bot as the Trading channel. This satisfies the real-separation requirement immediately, at the lowest incremental cost, with zero new app or service for Jeff to adopt, and it is a strict blast-radius improvement over today's single-bot setup rather than a lateral move. **ntfy remains the pre-planned upgrade path** — per B.J.'s original guidance ("worth it once volume grows past a few/week"), now sharpened by this requirement to also read "worth it once Jeff wants per-topic credential scoping, not just per-topic display separation" — and the `send(source, severity, message, metadata)` interface is deliberately built so that swap changes only the destination-resolution logic inside the relay, not any producer's call site. This is the same abstraction benefit already designed into Decision 2 before this revision; it holds without rework.

**Nothing left open on the grouping axis itself** — Jeff has directly specified the four channels above. What remains open is only the *exhaustive membership* of each channel's sub-sources as new sources come online (e.g., confirming Proxmox/OPNsense backup-alert specifics once homelab exists, confirming Home Assistant's exact event types once real, and the Healthchecks Trading-vs-Infrastructure inference flagged above) — these are detail questions for the owning specialist (Trapper/Relay/Sparky/Pierce) to resolve when each source is actually wired, not open architecture questions.

### Severity tiers vs. email priority tiers — reconcile or separate?

**These are two different axes and forcing them into one scheme is a category error.** GL-018's priority-tier override (Tier 1 contact match / Tier 2 direct-human-correspondence / Tier 3 category-fallthrough) answers a **who** question — does the *sender* deserve to jump the queue? It presupposes a sender, which most non-email alerts don't have (a fridge alarm has no "contact"). B.J.'s severity scheme (Tier 1 critical / Tier 2 needs-attention / Tier 3 informational) answers a **what** question — how dangerous or costly is *this event*, independent of who or what produced it.

**Decision: keep them explicitly separate, named distinctly (GL-018 keeps "priority tier," the cross-domain scheme is "severity tier"), and connect them with one mapping rule rather than merging them:**

| Email disposition (GL-018) | Cross-domain severity (this ADR) | Rationale |
|---|---|---|
| `ALERT` (any priority tier, any category) | **Severity 1 — push now** | GL-018's `ALERT` already means "surface to Jeff now"; that's definitionally Tier-1-severity the moment it's pushed through the relay instead of left in an in-run digest. |
| `ACT` (no urgency signal — a routine task/reply proposal) | **Severity 2 — needs attention, not urgent** | Held for confirmation regardless; muted/digest delivery is enough. |
| `ACT` where the Tier-1/2 priority override also fired | **Severity 1** | A contact-match or direct-human message needing action doesn't wait for a digest. |
| `FILE` / `ARCHIVE` / `TRASH` | **Not in the alerting layer at all** | These never surface; no severity applies. |

This is the whole reconciliation: one small mapping table, not a unified taxonomy. Any future domain (home, homelab, network, VPS) just assigns severity directly per B.J.'s 3-tier scheme — it never touches the email priority-tier concept, because it has no sender to evaluate. **Per the channel-structure revision above, severity determines how a message behaves *within* its channel (loud vs. silent vs. logged-only) — it does not create a second set of channels alongside the four channels defined above.**

### Per-domain ingestion (only where a real decision exists today)

- **Email → relay:** Decision 1's standing runner posts directly, tagged `source: email`, landing in the **Email** channel; wiring is push, not pull.
- **VPS/software → relay:** splits across two channels, not one. Pierce generalizes the existing Telegram send call (Option 2 above) for prophet-trader's own trading alerts (fills, crash, EOD, and — per this ADR's inference above — the Healthchecks.io trading-cadence checks) → **Trading** channel, `source: prophet-trader`. Separately, Pierce adds a GitHub Actions failure-notification step that curls the relay on `workflow_run: failure` (any repo, including `prophet-trader`'s own CI) and wires general VPS host health (disk/memory/systemd) and the rclone backup job → **Infrastructure** channel, `source: vps` / `source: backup`. This directly closes both known silent misses (prophet-trader deploy, mypka snapshot-notify).
- **Home automation → relay:** Home Assistant is the correct long-term single upstream for this domain once it's real (YoLink and Ring both have documented HA integration paths). HA is not real today — it's an onboarding-wizard sandbox on `bridget-laptop`, stood up for an unrelated project. **This ADR does not design HA's eventual architecture** — that's premature ceremony against hardware/software that doesn't functionally exist yet for this purpose. What it does require now: Relay establishes *some* interim direct-to-relay path for the one device class that has already caused real harm (YoLink temp/offline alarms) — mechanism (webhook vs. polling script) is Relay's technical call, not this ADR's; the requirement is only "tag `source: yolink`, assign severity per event type, post to the relay" (landing in the **Home Automation** channel) without waiting for full HA to exist.
- **Network → relay:** Sparky needs a live UniFi controller login to confirm firmware version (governs native webhook support). If present, wire directly; if not, a lightweight polling script bridges the gap until Kuma exists. Either way, closing the 5-week blind spot (adoption-status/device-count check) doesn't need to wait for that firmware check — a simple scheduled probe pushed to the relay (`source: network`, landing in the **Infrastructure** channel, not a separate network channel) can ship regardless of what the firmware check finds.
- **Homelab → relay:** Nothing to build. Lighthouse/Watchtower/OPNsense don't exist yet. The only decision worth recording now is the *principle* — once built, Uptime Kuma is the natural homelab+network probe layer (per B.J.), feeding the same relay (`source: homelab`, plus `source: backup` for Proxmox/OPNsense config backups specifically) into the **Infrastructure** channel, same severity scheme, no new design needed at that time beyond wiring. Do not design Kuma's specific check list against hardware that isn't racked.

**Design lock — no historical backfill, any domain.** The same principle from Decision 1 applies to every domain here, not just email: when a new source is wired into the relay — home automation, network, homelab once built, VPS/software, or any future addition — it starts monitoring and alerting from its activation point forward only. Onboarding a domain never means importing or processing its historical data through the new pipeline: wiring YoLink into the relay does not mean replaying weeks of past temperature readings; wiring UniFi does not mean backfilling the 5-week adoption-gap's historical logs into an alert stream; a future Kuma deployment does not mean reprocessing homelab history that predates it. This is a design lock, stated explicitly so nobody building against this ADR later assumes backfill is expected — or safe to add speculatively — for any source, present or future.

### The non-negotiable: heartbeat on the relay itself

Per B.J.'s single most important finding, this ships **in the same change** that generalizes the relay, not as later hardening: a two-layer pattern —
1. An independent Healthchecks.io dead-man's-switch the relay pings on its own fixed schedule (proves the relay's own scheduled job ran).
2. A human-visible canary message sent *through* the relay on a fixed cadence, distinctly tagged (e.g., "relay heartbeat OK"), so Jeff would notice its *absence* the same way the fridge alarms' absence should have been noticed — a Telegram-token revocation fails exactly this way (silent), so the check must be something Jeff would miss seeing, not just a log line. **With per-channel bot tokens (four channels, per the revision above), the canary should fire through all four channels on its schedule, not just one** — a single-channel canary would not catch a different channel's token silently dying.

Ledger verifies this pairing actually catches a real outage once, shortly after it ships (a controlled test: rotate one channel's bot token deliberately, confirm the fidelity check surfaces it *for that channel specifically*, and confirm the other three channels are unaffected — proving both the detection and the blast-radius-containment claim above) — the same "should be working is not confirmation" standard WS-006/WS-007 already hold every other deploy to.

---

## Cross-cutting decision — human-in-the-loop confirmation, generalized

GL-018's propose-then-confirm rule is today written as an email-specific rule. It is generalized here into a system-wide invariant that applies to every domain in this ADR:

1. **No domain may auto-create a calendar event, task, ticket, or send an outbound message/command without Jeff's explicit approval.** This was already true for email; it now applies identically to a home-automation "should I create a task to fix the fridge" proposal, a network "should I file a ticket with the ISP" proposal, or anything else the relay's producers surface.
2. **The alerting layer's only autonomous action is *notify*.** It is not a remediation engine. Home Assistant *can* trigger automations that act on the physical world — this ADR draws the line that HA integrations in scope here are notify-only. Extending any domain from "propose" to "auto-remediate" (e.g., "if fridge >40°F for 1hr, auto-order a part") is a separate, explicit future decision requiring its own ADR and Jeff's approval — never an incremental scope-creep of this one.
3. **Reuse the existing task mechanism, don't invent a parallel one.** A home/homelab/network/VPS proposal that needs Jeff's nod and won't be resolved this turn should become a task via [[SOP-010-create-task]], exactly as SOP-023's `ACT` proposals already do — same backlog, same SSOT discipline, not a bespoke "home-automation proposal" format. One open question this surfaces, left to the implementer: does a proposal awaiting Jeff's confirmation need a distinct task `status` (e.g., `proposed`) separate from ordinary `open`, so "queued idea awaiting a yes/no" is visually distinct from "confirmed, ready to work"? That's a GL-004/task-schema call, not this ADR's to make.
4. **Destructive or infrastructure-changing actions stay gated exactly where they already are** — WS-007's irreversible-tier plan-and-approval gate for infrastructure, WS-006's design/build/deploy gates for software. This ADR's alerting layer does not create a new execution path around either; it only proposes into them.
5. **No domain backfills historical data through the alerting pipeline.** Every source — email included — starts monitoring from its activation/onboarding point forward only, never retroactively. This is a design lock, not an option weighed against alternatives; see the explicit statements under Decision 1's "Multi-inbox onboarding" and Decision 2's "Per-domain ingestion" sections above, which this point cross-references rather than restates.
6. **A confirmable proposal can resolve to more than one approved outcome, and the approval surface must present all of them.** Decision 1's draft-vs-send resolution is the first concrete instance of this: "approve" is not always a single binary. Wherever a proposal has more than one legitimate way to be approved (e.g., draft-only vs. send-now), the confirmation UI must expose the distinct outcomes explicitly rather than collapsing them into one generic "approve?" — this is a UI/prompt-design requirement, not a policy loosening of point 1 above.

---

## What ships now vs. what's deferred (revised sequencing, per Jeff's reframe)

Dependency order, with owner and blocker stated for each:

| # | Action | Owner | Blocked on |
|---|---|---|---|
| 1 | Build the standing multi-inbox runner (Decision 1, Option 1): fetch+classify+push-alert on `davisglobe-vps-ash-1`, `FILE`/`ACT` staged for next-session reconciliation | Pierce | Nothing — highest priority, ships first |
| 2 | Extract the shared relay (Decision 2, Option 2) as its own callable interface, wired to four Telegram bot channels (**Trading** — reusing the existing `prophet-trader` bot; **Infrastructure**, **Home Automation**, **Email** — three new bot tokens); wire the non-negotiable per-channel heartbeat (Healthchecks.io ping + canary through all four channels) in the *same* change, not after | Pierce (build) + Klinger (wiring/onboarding new sources) | Nothing |
| 3 | Wire GitHub Actions failures (any repo) into the relay's **Infrastructure** channel | Pierce | Depends on #2 existing |
| 4 | Confirm Healthchecks.io's own push-notification config in its UI (read/verify, not a build) | Pierce | Nothing |
| 5 | Onboard `davisglobe` inbox (each starts `dry-run`, ~2 weeks before graduating; no backfill — starts from onboarding time forward) | Radar | Depends on #1 existing (standing runner) to be worth doing now rather than manually |
| 6 | Build the `gmail.send`-scoped connector (required — "approve and send" cannot work without it) and wire the two-outcome reply approval (`approve_as_draft` / `approve_and_send`) into the runner's approval surface | Klinger (connector) + Pierce (runner wiring) | Jeff's single Cloud Console setup session (see item 7 — same session covers both scopes) |
| 7 | Google Contacts OAuth connector (fixes GL-018 Tier 1's under-matching proxy) — **folded into the same Google Cloud project/OAuth client as item 6's `gmail.send` scope**, per Jeff's direction to Klinger, so one Cloud Console session covers `contacts.readonly` and `gmail.send` together | Klinger | Jeff's ~5-10 min Cloud Console session (covers items 6 and 7 together) |
| 8 | Close GL-018's known category gap (insurance-claim, legal-notice, health, home-device-alert, infra-monitoring) — for the latter two specifically, route their email-arrival case through the relay too (Home Automation / Infrastructure channels respectively), not just PKM filing, since that's literally the failure that started this (a YoLink alert arriving as email was trashed because Jeff believed it was "tracked elsewhere") | Radar/Hawkeye | Nothing |
| 9 | Register YoLink/Ring/Nanit in the Environment registry; Relay's interim direct-to-relay wiring for YoLink specifically into the Home Automation channel (mechanism is Relay's call; no backfill of historical readings) | Relay | Nothing for the registry entries; a registry-schema question (what folder owns "cloud-connected consumer IoT device") may need a small GL-002 extension |
| 10 | Check UniFi controller firmware for native webhook support; ship the interim adoption/device-count probe into the Infrastructure channel regardless of that finding (forward-only, no backfill of the 5-week gap's historical logs) | Sparky | A live controller login |
| 11 | Ledger's one-time heartbeat-fidelity test (deliberately revoke/rotate one channel's bot token, confirm the pairing surfaces it for that channel and confirm the other three channels are unaffected) | Ledger | Depends on #2 |
| 12 | Evaluate splitting the standing runner + relay onto a dedicated small VPS instead of `davisglobe-vps-ash-1` | Pierce | Revisit once #1/#2 are live and stable — not a v1 decision |
| 13 | Design and deploy Uptime Kuma for homelab+network, feeding the Infrastructure channel (including Proxmox/OPNsense config backup checks) | Trapper | Lighthouse/OPNsense hardware — genuinely not built yet, do not design further now |
| 14 | Decision 1's Option 2 (full unattended vault writes via Drive API) | Pierce (build) + Vex (security review) | Jeff explicitly choosing to pursue it, as its own approval — not assumed by this ADR |
| 15 | Confirm the Trading-vs-Infrastructure split for Healthchecks.io's trading-cadence checks (this ADR's inference, flagged above) directly with Jeff when Pierce wires item 2/3 | Pierce/Hawkeye | Nothing — cheap to confirm alongside item 2, cheap to flip later if wrong |

Items 1-4 have no blocker and should be the first PR. Items 5-9 can run in parallel with 1-4 (different owners, no shared dependency); items 6-7 share a single Jeff action (one Cloud Console session) and should be batched together, not sequenced. Items 10-11 depend on small, cheap unblocks (a login, #2 existing). Items 12-14 are deliberately deferred — 13 because the hardware doesn't exist, 12 and 14 because they're real but lower-priority upgrades that deserve their own gate once the foundation is proven, not speculative work now. Item 15 is a cheap confirmation that should ride along with item 2, not block it.

---

## Governance artifacts recommended (not authored here — Keystone does not write Guidelines/Workstreams)

Checked against the live indices at draft time: next free Guideline slot is **GL-019**, next free Workstream slot is **WS-008**. Whoever writes these must re-run the collision check in [[GL-016-numbered-artifact-collision-check]] immediately before committing, since time will have passed.

**GL-019 (recommended title: "Cross-Domain Alert Severity & Confirmation")** — sketch of scope:
- The 3-tier severity scheme (critical/push-loud, needs-attention/muted-or-digest, informational/log-only-never-pushed), stated as a distinct axis from GL-018's priority tiers, with the reconciliation mapping table from Decision 2 above, and the explicit rule that severity is a per-message property *within* a channel, never a second channel axis.
- The universal propose-then-confirm rule, generalized from GL-018's email-specific version to every domain (the six points under "Cross-cutting decision" above, including the no-backfill design lock and the multi-outcome-approval-surface requirement).
- The relay's message envelope contract: `{source, severity, message, timestamp, metadata}` plus the destination-resolution rule (source → one of the four channels: Trading, Infrastructure, Home Automation, Email) — every new integration must populate `source` and `severity`.
- The heartbeat-on-the-relay requirement, stated as non-negotiable, with the two-layer pattern (dead-man's-switch + human-visible canary) — fired through **all four channels**, not just one.
- Names which specialist owns adding new `source` values to the vocabulary and mapping them to the correct existing channel (recommend Klinger, since Klinger owns relay/connector wiring) — and states that a new *channel* (as opposed to a new source feeding an existing channel) is a deliberate, Jeff-approved addition, not something a specialist adds unilaterally.

**WS-008 (recommended title: "Alert Ingestion & Relay Lifecycle")** — sketch of scope:
- Choreography: each domain owner (Radar–email, Relay–home automation, Trapper–homelab, Sparky–network, Pierce–VPS/software) tags their events per GL-019 and posts to the shared relay; note that Trapper, Sparky, and Pierce's non-trading VPS work all feed the **same** Infrastructure channel — multiple owners into one channel is expected and correct, not a conflict to resolve. Klinger owns the relay itself, its channel wiring, and onboarding new sources; Ledger owns the heartbeat-fidelity check.
- References GL-019 (rules) and GL-017 (handoff packet) for any cross-specialist handoff within this Workstream.
- Explicitly states this Workstream does **not** own homelab/network/VPS infrastructure design (WS-007's domain) or software build mechanics (WS-006's domain) — it owns only the alert *event flow*: producer → relay → channel → Jeff, plus the confirmation gate. Deliberately thin, similar in weight to WS-001 (daily journaling).
- Trigger: "a new alert-producing source needs wiring" or "a home/homelab/network/VPS/software event needs to reach Jeff." Every new-source onboarding step in this Workstream inherits the no-backfill design lock from GL-019 by default — it is not re-litigated per source. A new source normally maps into one of the four *existing* channels; adding a genuinely new channel is a deliberate, separately-approved change, not a default outcome of onboarding a new source.

A **separate, smaller amendment** worth flagging to whoever picks this up: SOP-023 currently says it runs "on a schedule once a trigger layer exists" — once Decision 1 ships, that sentence stops being aspirational and SOP-023 itself needs a small update pointing at the new standing-runner mechanism. Not a new SOP; an edit to the existing one.

---

## What's decided vs. what's left open for the implementer

**Decided by this ADR (pending Jeff's sign-off):**
- Decision 1, Option 1: the standing runner does fetch+classify+push-alert unattended; `FILE`/`ACT` execution stays session-reconciled for now (Option 2 explicitly deferred, not rejected).
- Decision 1, sub-decision: co-locate on `davisglobe-vps-ash-1` for now (Option A).
- Decision 1, draft-vs-send: **resolved** — both `approve_as_draft` and `approve_and_send` are supported, selected per-message at approval time; the `gmail.send` connector is a required build (folded into the same Cloud Console session as the Contacts connector), not an optional path.
- Decision 2, Option 2: extract the relay to its own callable interface, outside `prophet-trader`'s repo.
- Decision 2, channel structure: **four channels, directly specified by Jeff** — **Trading** (Prophet Trader only), **Infrastructure** (VPS non-trading, homelab, network, backups — combined), **Home Automation** (YoLink/Ring/Nanit/HA), **Email** (unchanged). Implemented as four Telegram bot tokens for v1 (reusing the existing `prophet-trader` bot for Trading), with ntfy named as the pre-planned upgrade path if per-topic credential scoping or volume later justifies it. The grouping axis itself is settled; only per-source membership details (flagged above) remain to confirm as each source is actually wired.
- Severity tiers and email priority tiers are separate axes, connected by the stated mapping table, not merged; severity is a property within a channel, not a second channel axis.
- Propose-then-confirm is a system-wide invariant; the alerting layer's only autonomous act is notify; a proposal with more than one approved outcome must present all outcomes explicitly at the approval surface.
- **No domain backfills historical data on onboarding** — every source starts from its activation point forward; the `gmail-personal` 30-day backfill was a one-time bootstrap exception, not a repeatable pattern. This is a design lock, not an option.
- The relay heartbeat (dead-man's-switch + canary) ships in the same change as the relay itself, fired through all four channels, not later and not just once.
- Sequencing order in the table above.

**Left open, for the named owner to resolve:**
- Exact transport behind the relay's per-channel `send()` interface today (four Telegram bot tokens) and when volume/credential-scoping needs justify swapping to ntfy (Pierce/Klinger's call, per B.J.'s "worth it past a few/week" guidance, now also informed by the per-topic-credential argument above).
- The Trading-vs-Infrastructure split for Healthchecks.io's trading-cadence checks — this ADR's inference (item 15 in the sequencing table), cheap to confirm with Jeff, cheap to flip if wrong.
- Whether a distinct `status: proposed` task state is needed versus reusing `status: open` (GL-004 owner's call).
- What Environment folder/entity schema fits a cloud-connected consumer IoT device that isn't quite a "Host" (Relay + GL-002 owner's call).
- Relay's exact mechanism for the interim YoLink-to-relay bridge (webhook vs. polling — Relay's technical call).
- Whether/when to split the runner+relay onto a dedicated VPS (Pierce's call, revisit after #1/#2 prove stable).
