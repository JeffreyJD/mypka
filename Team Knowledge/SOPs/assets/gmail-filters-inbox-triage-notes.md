# Gmail Filter Seed Set — Repeat Junk Senders (companion to GL-018 / SOP-023)

**Companion to:** [[GL-018-inbox-triage-and-classification]], [[SOP-023-triage-inbox]].
**File:** `gmail-filters-inbox-triage.xml` (26 rules). **Born:** 2026-07-20.

## What this is

A ready-to-import Gmail filter set targeting the confirmed **repeat promotional
senders** identified during the 2026-07-20 inbox cleanup — the ~15-20 senders
that cycled through nearly every batch (Home Depot, Banggood, The Parking Spot,
MSC Cruises, SeatGeek, SeaWorld parks, DiscountFilters, and the rest). Each rule
**trashes on arrival** and can be run against existing mail to bulk-clear the
backlog in one pass, instead of trashing hundreds of near-identical threads one
at a time.

This is the durable version of GL-018 Goal 3 (keep inboxes clean): stop the pile
from rebuilding rather than repeatedly shoveling it out. It is also the concrete
seed for [[SOP-023-triage-inbox]] Phase 4's per-run "filter recommendations"
output — future runs append new repeat offenders to this same set.

## How to apply (Jeff, ~2 minutes)

1. Gmail → Settings (gear) → **See all settings** → **Filters and Blocked
   Addresses** → **Import filters** (bottom of page).
2. Choose `gmail-filters-inbox-triage.xml` → **Open file** → **Create filters**.
3. On the confirmation page, **tick "Also apply filter to matching
   conversations"** before creating — this is what clears the existing backlog.
   Leave it unticked if you only want it to affect future mail.
4. Create. Done — backlog for these senders goes to Trash (recoverable 30 days),
   and future sends from them skip straight to Trash.

## What these rules deliberately do NOT touch (important)

Per GL-018's **purpose-over-sender** rule, senders that emit *both* marketing and
real account/statement mail are **excluded** from this trash-everything set,
because a blanket filter would trash their account mail too. These stay
per-message decisions:

- **Coinbase** — account/security kept, marketing trashed, by message.
- **Hilton** — Honors statements kept, points/promo blasts trashed.
- **AwardWallet** — personalized account roundups kept, pure offer blasts judged.
- **Emerald Club / National** — eStatements & account notices kept, "ONE TWO
  FREE" style promos trashed.

**LinkedIn / social note:** the LinkedIn rules trash the *notification emails*
only (`invitations@`, `notifications-noreply@`, `messages-noreply@`,
`jobs-listings@`, `jobalerts-noreply@`). The real invitations and DMs live inside
LinkedIn — Jeff actions them in the app, so nothing is lost. If Jeff ever relies
on email to see a specific person's LinkedIn DM, drop the `messages-noreply@`
rule. Instagram notifications are trashed the same way.

Also excluded (kept senders — never filter to trash): **Ali Kochno / STELLAR MLS**
(the Florida house search — Gmail miscategorizes it as promotional; it is
high-value), **Chase**, **Sunnyside Chevrolet** service, **FlightAware**,
**Ubiquiti / ui.com**, **Erie Yacht Club** (though past-dated EYC events are
trashed per the past-event rule).

If Jeff later decides a hobby newsletter is worth keeping (e.g.
**cabinetplans.io** for cabinetmaking), remove/never-add its rule and add it to
the GL-018 keep list instead.

## Note on match precision

Rules match on the sending **subdomain** (e.g. `mg.homedepot.com`,
`m.seaworldparks.com`) rather than the bare brand domain, so they hit the
marketing stream specifically and won't catch a transactional message sent from a
different subdomain (e.g. a real order/receipt from `homedepot.com`). If Home
Depot order receipts ever start landing in Trash, narrow or remove that rule.
The Lowe's, marine, and auto-dealer rules use `OR` to fold two related marketing
domains into one rule.

## Maintenance

1. Record the filtered senders as `promotional`/standing-disposition TRASH rows
   in the per-inbox sender registry
   (`PKM/Environment/Accounts/inbox-gmail-personal-sender-registry.md`), so the
   classifier and the filters agree.
2. On future SOP-023 runs, when a new sender crosses the "seen 3+ times, always
   junk" threshold, append a matching `<entry>` to this XML and re-import (or
   have Jeff re-import). Keep the exclusion list above authoritative — never add
   a split-purpose or kept sender to the trash set.
3. Multi-inbox: this set is scoped to `gmail-personal` (which is aggregating
   davisglobe mail). When `davisglobe`/`perficient` get their own `inbox_id`,
   build a parallel filter set from that inbox's observed senders — do not assume
   trust/junk carries across inboxes.

## Provenance

Seed set built 2026-07-20 from ~397 promotional/social threads triaged in a live
cleanup. Senders included here were observed as pure marketing with no
account/transactional mail to this inbox across the session. Split-purpose and
high-value senders were excluded by design.
