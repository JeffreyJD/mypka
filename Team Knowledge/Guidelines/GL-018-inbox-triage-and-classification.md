# GL-018 - Inbox Triage & Classification

- **Type:** Guideline (static rules; read on every inbox-triage action)
- **Applies to:** [[SOP-023-triage-inbox]] and any agent processing an email inbox
- **References:** [[GL-001-file-naming-conventions]], [[GL-002-frontmatter-conventions]], [[GL-004-task-resource-linking]], [[GL-012-confirm-dispatch-not-just-narrate-it]], [[SOP-010-create-task]]
- **Born** 2026-07-20 from Jeff's inbox-triage design session: a live cleanup of ~400 stale threads surfaced the need for a durable, portable taxonomy so the same judgment ("junk vs. keep vs. act") is applied identically every run, across multiple inboxes, by any LLM.

## Why this exists

Inbox triage is a judgment task before it is a mechanical one. The mechanical
half (fetch, label, archive, file) is easy and lives in [[SOP-023-triage-inbox]].
The judgment half — *is this junk, does this carry an action, does this belong in
the knowledge base* — is where quality is won or lost, and it must not drift
between runs, between inboxes, or between LLMs. This Guideline is the static
contract that keeps that judgment stable. The SOP wikilinks here rather than
restating any of it.

Two failure modes this guards against, in priority order:

1. **A false negative is a serious failure.** Missing one real message —
   a survey appointment, a service deadline, a note from a person who matters,
   a account/security alert — is the outcome this whole system exists to prevent.
   When uncertain, the rule is always *escalate toward the human's attention*,
   never *toward the trash*.
2. **A false positive is a nuisance, not a failure.** Archiving a promo that
   turned out mildly interesting costs nothing — it stays searchable. The
   taxonomy is therefore deliberately asymmetric: it trashes only what is
   unambiguously junk and routes everything with any signal to review.

## The four goals this taxonomy serves

Every classification decision maps back to one of Jeff's four stated goals:

1. **Never miss critical information or communication.** → the `ACT` and `ALERT`
   dispositions, and the escalate-when-uncertain rule.
2. **Support multiple inboxes across different domains.** → the per-inbox
   `inbox_id` context and the shared-vs-per-inbox taxonomy split below.
3. **Keep every inbox clean.** → the `TRASH` and `ARCHIVE` dispositions plus the
   filter-recommendation output.
4. **Convert/update knowledge into myPKA and file documents in the right PKM
   folder.** → the `FILE` disposition and the PKM routing table below.

## Categories (what a message *is*)

Category is the descriptive layer — what kind of mail this is. It is distinct
from **disposition** (what to *do*, next section). One category can map to
different dispositions depending on content.

| Category | Definition | Typical disposition |
|---|---|---|
| `human-direct` | A real person writing to Jeff (or Bridget) specifically — not a list. | ALERT or ACT |
| `account-security` | Login alerts, password resets, 2FA, statements, fraud notices, renewals from a service Jeff holds an account with. | ALERT (security) / ACT (renewal) / FILE (statement) |
| `financial` | Bank, card, brokerage, crypto, invoices, receipts, tax. | FILE + ACT if action needed |
| `appointment-scheduling` | Anything proposing, confirming, or reminding about a date/time — service reminders, reservations, surveys, lift-ins, viewings. | ACT (calendar) |
| `personal-interest` | Genuine subscriptions and memberships Jeff actively values (boat club, aviation, points/miles trackers, home-search agent). | ARCHIVE, or ACT if it carries a date. |
| `reference-knowledge` | Product firmware/EOL notices, order confirmations worth keeping, documentation, anything that updates a fact myPKA tracks (a host, a vehicle, a document expiry). | FILE |
| `promotional` | Retailer deals, sales, marketing blasts. | TRASH |
| `social-notification` | LinkedIn/social platform notification noise. | TRASH (unless a real person's direct message). |
| `newsletter-bulk` | Mailing lists Jeff does not act on. | ARCHIVE or TRASH per the sender registry. |
| `unknown` | Cannot be confidently placed. | ALERT — surface to Jeff, never trash. |

## Dispositions (what to *do*)

| Disposition | Action | Reversible? |
|---|---|---|
| `ALERT` | Notify Jeff now (the run's alert digest). Leave in inbox. Never auto-act. | n/a |
| `ACT` | Propose a concrete action (calendar event, task) — **propose only, see propose-then-confirm below**. | n/a |
| `FILE` | Write/append knowledge into the correct PKM folder and/or store the attachment; see PKM routing. | Yes — additive |
| `ARCHIVE` | Remove from inbox, keep searchable. | Yes |
| `TRASH` | Move to trash (recoverable ~30 days). Only for unambiguous junk. | Yes (30d) |

## Propose-then-confirm (hard rule)

**No triage run ever auto-creates a calendar event or a task, or auto-sends any
outbound message, or auto-deletes a `human-direct` / `account-security` /
`unknown` message.** For every `ACT` item, the run produces a *proposal* — the
drafted calendar event or the drafted task — and holds it for Jeff's approval.
Only `FILE` (additive, non-destructive knowledge writes), `ARCHIVE`, and `TRASH`
of unambiguously-junk categories (`promotional`, `social-notification`,
registry-confirmed `newsletter-bulk`) may execute without a per-item nod, and
even those are reported in the run summary.

This mirrors [[GL-012-confirm-dispatch-not-just-narrate-it]]: a proposed action
is not a done action, and the run must never narrate an action it has not
actually queued for confirmation.

Ramp: until Jeff has watched the classifier's judgment across enough runs to
trust its precision (recommend ~2 weeks), the SOP runs **dry-run first** —
classify and report what it *would* do, write nothing. Graduation to live writes
is Jeff's explicit call, per category.

## Multi-inbox handling (Goal 2)

The system is inbox-agnostic. Each run is scoped to one `inbox_id` (a stable
short name, e.g. `gmail-personal`, `davisglobe`). All state is
keyed by `inbox_id` so inboxes never cross-contaminate.

- **Shared across inboxes:** the category definitions, dispositions,
  propose-then-confirm rule, and PKM routing table (this Guideline).
- **Per-inbox:** the sender registry (below) is partitioned by `inbox_id`; a
  sender trusted in one inbox is not automatically trusted in another. The
  last-run state marker (see SOP-023) is per-inbox.
- A message from the *same* human across two inboxes is deduped by
  message-id at the FILE/ALERT step so Jeff is not alerted twice.

## Sender registry (per-inbox, grows over time)

The registry is the learned layer: a table of known senders and their standing
disposition, stored per inbox at
`PKM/Environment/Accounts/inbox-<inbox_id>-sender-registry.md`. Seeded from the
2026-07-20 cleanup, extended every run. Format per row: sender-domain-or-address
· category · standing-disposition · note. The SOP consults it first; anything not
in the registry is classified fresh and, if confidently junk or confidently
valuable, *proposed* as a new registry row for Jeff to ratify (never
auto-written — the registry is trust state).

### Past events carry no action (date governs, not sender)

For `appointment-scheduling` and event mail, the **event date** decides
disposition, independent of sender trust. An event whose date has already passed
carries no action and is not knowledge worth filing — it is noise. It goes to
TRASH even when the sender is one Jeff keeps (e.g. Erie Yacht Club).

- **Future-dated event** from a kept sender → ALERT/ACT (propose calendar) or
  Follow up for review.
- **Past-dated event**, any sender → TRASH. Do not flag, do not file.
- **No parseable date** but clearly a standing/recurring notice → treat by
  sender rule (Follow up if kept).

The classifier must read the date out of the subject/body before dispositioning
event mail. When a run processes mail well after arrival (the manual-launch lag),
many "kept sender" events will already be stale — trashing them is correct, not
a false negative, because the actionable window has closed.

### Purpose overrides sender (critical rule)

A sender's disposition is **per-message-purpose, not per-sender**. Many senders
emit *both* transactional/account mail and marketing mail from the same or
adjacent domains. The registry standing-disposition is only a default; every
message is re-checked against its actual purpose before dispatch:

- **Account / security / statement / transactional** → treat as
  `account-security` or `financial`: ALERT or FILE. Never trash, even if the
  sender also spams. Signals: login/2FA, password reset, fraud/security notice,
  monthly statement, receipt, renewal, balance, "your account," a specific
  transaction or reservation confirmation.
- **Marketing / promotional** from the *same* sender → `promotional`: TRASH.
  Signals: sale, % off, "last chance," "misses you," product launch, points
  *offer* (as opposed to a points *statement*), generic newsletter.

Worked examples from the 2026-07-20 pass:
- **Coinbase**: account/portfolio-activity and security mail → keep (ALERT);
  "your crypto portfolio misses you" re-engagement blast → trash.
- **Hilton**: "Your April Hilton Honors Monthly Statement" → keep (FILE/ALERT);
  "2,000 Points per stay" / "breakfast included" promos → trash.
- **AwardWallet**: the account's balance/roundup for Jeff's tracked programs →
  keep; a pure card-offer marketing blast → judgment call, lean keep only if it
  reads as the personalized roundup he subscribes to.

When a sender appears in the registry, store *both* dispositions if it emits
both, e.g. `coinbase.com · financial/promotional · ALERT account-mail, TRASH
marketing · split by purpose`. The classifier must read the individual message,
not stop at the sender row.

Seed entries confirmed in the 2026-07-20 pass (inbox `gmail-personal`):

- Keep/ALERT: Coinbase, Chase, Hilton Honors, AwardWallet, Sunnyside Chevrolet
  (service), Ali Kochno / realtor home-search, Erie Yacht Club, FlightAware,
  Ubiquiti (ui.com).

**Named high-value senders (never trash, override Gmail category):**
- **Ali Kochno / STELLAR MLS** (`STELLAR@stellarmatrix.com`, subject "Homes for
  you from Ali Kochno", to jeff@ and bridget@davisglobe.com) — this is Jeff and
  Bridget's **active Florida house search** (winter home, Tampa area, zip ~34655).
  Gmail persistently miscategorizes it as `promotional`; the registry **overrides
  that** — category `personal-interest`/`reference-knowledge`, disposition
  ALERT + FILE. New matching listings route to
  `PKM/My Life/Goals/find-florida-property.md`. Never trash, never archive
  silently — property matches are exactly the "don't miss it" case (Goal 1).
- Trash/`promotional`: Banggood, Home Depot, Lowe's, The Parking Spot, MSC
  Cruises, SeatGeek, Vevor, Turtle Wax, Harbor Freight, Peacock, HBO Max,
  Best Western marketing (distinct from account mail).
- Trash/`social-notification`: LinkedIn notifications (excluding direct
  member-to-member messages).

### Priority-tier override system (hard rule)

Above and independent of the category/disposition table, every message is
first checked against a three-tier priority system. Tiers 1 and 2 exist for
one purpose — **don't let a real person get buried** — and both outrank
ordinary category-based judgment, including any existing sender-registry row.
Tier 3 is everything that doesn't match Tier 1 or Tier 2, and falls through to
the category/disposition table exactly as this Guideline already defines it,
unchanged.

#### Tier 1 — Contact match (highest)

If the sender's email address matches an entry in Jeff's Google Contacts, the
disposition is always **ALERT + ACT** — never `TRASH`, never `ARCHIVE`, never
`FILE`-only — regardless of category and regardless of any existing
sender-registry row for that sender. This overrides everything else in this
Guideline, including a registry-confirmed `TRASH`/`ARCHIVE` standing
disposition, for that specific message.

This is stronger than Tier 2 below and stronger than the general
`human-direct` category's typical "ALERT or ACT." A contact match makes `ACT`
— a concrete drafted task or follow-up, per [[SOP-010-create-task]] —
**mandatory**, not situational. A contact-matched message is never left
sitting as an ALERT-only digest line with nothing proposed.

**Technical dependency (stated honestly):** this check requires a Google
Contacts (People API) lookup. **No such connector exists yet** — Hawkeye is
having Klinger scope building one. Until it exists, the interim proxy is:
cross-reference the sender's email address against `PKM/CRM/People/*.md`
frontmatter (the `email` field) — people Jeff has already logged as real
contacts in the vault. This proxy is **incomplete and will under-match** until
the real connector lands: `PKM/CRM/People/` only holds whoever has been
logged there, not Jeff's full Google Contacts list. A sender the proxy misses
is not thereby excluded from this rule's intent — it simply falls through to
Tier 2, then Tier 3, until the real lookup exists. Do not treat a proxy miss
as a considered "not a contact" verdict.

#### Tier 2 — Direct human correspondence, sender not a known contact

A real individual person writing directly to Jeff — not a mailing list, not a
marketing/bulk blast, not a `no-reply`/`notifications@` automated sender —
still gets escalated even when that sender isn't (yet) in Contacts or CRM.
This is a strengthening of the existing `human-direct` category: **`ALERT` is
now mandatory** for this tier, not just typical. `ACT` remains judgment-based
on whether the content actually carries an action — this matches the
category table's existing "ALERT or ACT" for `human-direct`, the only change
is that the `ALERT` half is now non-negotiable rather than the usual case.

"Real person" cannot be pure vibes — it needs concrete, mechanical signals a
classifier can actually check, cheaply, without deep judgment:

**Signals *for* Tier 2** (the more of these present, the stronger the case):
- Single addressed recipient — Jeff (or Jeff + a small named group), not
  bcc'd into a list.
- No bulk-mail headers present: no `List-Unsubscribe`, no `List-Id`, no
  `Precedence: bulk`.
- Sender address is not a `no-reply@` / `donotreply@` / `notifications@` /
  `alerts@` pattern.
- Body reads as personal correspondence: references specific context, asks a
  direct question, isn't templated marketing copy.

**Signals *against* Tier 2** (any one of these means this is NOT Tier 2 — it
falls through to Tier 3, the ordinary category table):
- Any bulk-mail header present (`List-Unsubscribe`, `List-Id`,
  `Precedence: bulk`).
- Sender is clearly automated or transactional (a system, a service, a
  notification pipeline — even if it's mail Jeff cares about, like an account
  alert; those are handled by the `account-security`/`financial` categories,
  not Tier 2).
- Content is templated/promotional even when personalized with a name (e.g.
  "Hi Jeffrey, ..." mail-merge marketing is not Tier 2 just because it uses
  his name).

This check is deliberately mechanical — header and sender-pattern inspection
plus a quick read of whether the body is templated — not an open-ended
judgment call. When genuinely ambiguous after checking these signals, GL-018's
existing escalate-when-uncertain rule applies: route to `unknown` / `ALERT`
rather than guessing a Tier 3 disposition.

#### Tier 3 — everything else

No Tier 1 match, no Tier 2 signals. Falls through to the
category/disposition table earlier in this Guideline exactly as already
defined — no changes to that table from this section.

Born 2026-07-21 (Jeff's explicit ruling; Tier 2 added same day as a
refinement generalizing the original contact-match rule into an explicit
three-tier system). Applies to every inbox-triage run going forward,
per-inbox, from this date on.

## PKM routing table (Goal 4)

When a message is `FILE`, its knowledge and/or attachment routes to the folder
that owns that fact. Follow [[GL-002-frontmatter-conventions]] for the note
schema and [[GL-001-file-naming-conventions]] for names. Routing is by *subject
of the fact*, not by sender:

| If the message concerns… | Route to | Note/example |
|---|---|---|
| A vehicle (service, recall, registration) | `PKM/Documents/automobiles/` + update the vehicle file | e.g. Silverado service → append to its vehicle note |
| A homelab host/service/device (firmware, EOL, order) | `PKM/Environment/Hosts/` or `Services/` | e.g. Ubiquiti firmware notice → host note |
| The boat / Lake Erie | `PKM/Documents/lake-erie/` | e.g. Yacht Club lift-in, survey docs |
| A financial statement/receipt/tax doc | `PKM/Documents/` (finance) + `documents` entity | store attachment, log expiry/renewal if any |
| A person's news (new role, contact change) | `PKM/CRM/People/<slug>.md` | update the CRM note |
| An account renewal/plan/credential change | `PKM/Environment/Accounts/<slug>.md` | update renewal_date, plan |
| A property / Florida search | `PKM/My Life/Goals/find-florida-property.md` | append listing/agent note |
| General reference worth keeping, no home yet | `PKM/Documents/` with a clear `doc_type` | create the note; flag for Jeff to reclassify |

If no folder clearly owns the fact, `FILE` degrades to `ALERT` with a suggested
folder — never silently dropped.

## Attachments and documents

An attachment worth keeping is stored to the routed PKM folder (or to object
storage / TrueNAS per the host convention for large binaries), and a `documents`
entity note is created/updated with its `digital_location`, `doc_type`, and any
`expiry_date` / `renewal_trigger`. The email body's decision (the "why we kept
this") goes in the note so the knowledge, not just the file, is captured.

## When NOT to apply this Guideline

- One-off manual "clean up my inbox with me" sessions where Jeff is in the loop
  live (like the 2026-07-20 session) — the taxonomy informs it, but the
  interactive human call overrides any table here.
- Inboxes Jeff has explicitly excluded from automation.

## Provenance

Born 2026-07-20. Seeded from a live triage of the `gmail-personal` inbox
(~400 stale promotional + social threads cleared; a review lane of account,
financial, boat-club, aviation, home-search, and vehicle-service senders set
aside under the existing "Follow up" label). Numbered GL-018 as the next free
Guideline slot per [[GL-016-numbered-artifact-collision-check]]; re-confirmed
free immediately before writing to the vault on 2026-07-20 (Hawkeye).

Companion filter seed set: [[Team Knowledge/SOPs/assets/gmail-filters-inbox-triage-notes|gmail-filters-inbox-triage]] (26 Gmail filter rules for confirmed repeat-junk senders, applied by Jeff outside the vault).
