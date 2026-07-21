# SOP-023 - Triage Inbox

- **Default owner:** Radar (incoming-traffic interception and routing). Reusable by any agent — this is a skill, not 1:1 ownership.
- **Triggered by:** Jeff runs a triage pass on one inbox — on demand ("triage my inbox"), or on a schedule once a trigger layer exists. Portable trigger phrase: *"triage inbox <inbox_id>"*.
- **References:** [[GL-018-inbox-triage-and-classification]] (the taxonomy, dispositions, propose-then-confirm rule, PKM routing — all judgment lives there, not here), [[GL-001-file-naming-conventions]], [[GL-002-frontmatter-conventions]], [[GL-004-task-resource-linking]], [[GL-012-confirm-dispatch-not-just-narrate-it]], [[SOP-010-create-task]] (for ACT→task proposals), [[SOP-016-write-journal-entry]].
- **Reusable by any agent.** Radar owns it because interception is Radar's role, but any code-capable agent can invoke it.

## Purpose

Take one email inbox from "full of unread mail" to "clean, with nothing
important missed." This SOP is the **mechanical** procedure: fetch, classify
(by delegating judgment to [[GL-018-inbox-triage-and-classification]]), then
dispatch each message to its disposition. It writes proposals for anything
requiring Jeff's nod and executes only the non-destructive/unambiguous actions,
exactly as GL-018 mandates.

This SOP is **LLM-agnostic** and written as a procedure any capable LLM can run.
Where a Claude Code-specific tool is the fast path, a two-path note gives the
equivalent for any other LLM.

## Inputs

- `inbox_id` — the stable short name of the inbox to process (e.g.
  `gmail-personal`, `davisglobe`). Required. Scopes all state.
- `mode` — `dry-run` (default) or `live`. Dry-run classifies and reports what it
  *would* do, writing nothing. Live executes FILE/ARCHIVE/TRASH and queues ACT
  proposals. Per [[GL-018-inbox-triage-and-classification]], stay in dry-run
  until Jeff graduates the inbox.
- `window` — how far back to look. Default: since the last successful run for
  this `inbox_id` (from the state marker). First run: Jeff specifies (e.g.
  "unread, last 30 days").

## Preconditions

- Read access to the inbox (via whatever mail connector/API the running harness
  has — Gmail API, IMAP, a connector tool). The SOP is agnostic to which.
- The per-inbox sender registry note exists (or is created empty on first run):
  `PKM/Environment/Accounts/inbox-<inbox_id>-sender-registry.md`.
- The per-inbox state marker exists (or is created on first run):
  `.mypka/inbox-state/<inbox_id>.json` — holds `last_run` timestamp and the set
  of processed message-ids (the dedup + idempotency layer).

## Procedure

### Phase 0 — Scope and load state

1. Resolve `inbox_id`, `mode`, `window`. Refuse to run if `inbox_id` is missing
   (never guess which inbox).
2. Read the state marker `.mypka/inbox-state/<inbox_id>.json`. Establish the
   fetch window: everything since `last_run` (or Jeff's explicit window on first
   run). Load the processed-message-id set for dedup.
3. Read the per-inbox sender registry and the shared taxonomy in
   [[GL-018-inbox-triage-and-classification]] into working context.

### Phase 1 — Fetch

4. Fetch message metadata for the window: message-id, sender, subject, date,
   snippet, label/category, attachment list. Skip any message-id already in the
   processed set (idempotency — a re-run never double-acts).

   - **In Claude Code / a connector-equipped harness:** call the mail search
     tool in batches (respect per-call page limits; paginate).
   - **In any other LLM:** run the equivalent IMAP/API query, or accept a pasted
     export, and process the same fields.

### Phase 2 — Classify (delegates all judgment to GL-018)

5. For each message, assign a **category** and **disposition** strictly per
   [[GL-018-inbox-triage-and-classification]]. Consult the sender registry
   first; classify fresh if the sender is unknown.
6. Produce, per message, a small structured record:

   ```
   {
     "message_id": "...",
     "inbox_id": "...",
     "sender": "...",
     "subject": "...",
     "category": "<one of GL-018 categories>",
     "disposition": "ALERT | ACT | FILE | ARCHIVE | TRASH",
     "reason": "one line, why this disposition",
     "proposed_action": { ... } | null,   // for ACT/FILE
     "pkm_route": "<folder path>" | null,  // for FILE
     "registry_suggestion": { ... } | null // new/changed sender row to ratify
   }
   ```

   - **In Claude Code:** classification can be a batched sub-agent pass over the
     fetched records.
   - **In any other LLM:** classify sequentially in-context; the record schema
     is identical.
7. **Escalate-when-uncertain (GL-018 hard rule):** any message that cannot be
   confidently placed → `category: unknown`, `disposition: ALERT`. Never trash
   on uncertainty.

### Phase 3 — Dispatch

Process records grouped by disposition. **Honor propose-then-confirm from
[[GL-018-inbox-triage-and-classification]] — no auto calendar/task creation, no
auto-delete of human-direct/account-security/unknown mail, no outbound sends.**

8. **TRASH** (only `promotional`, `social-notification`, registry-confirmed
   `newsletter-bulk`): move to trash. Recoverable ~30 days. One item per call if
   the connector requires it; batch where possible.
9. **ARCHIVE**: remove from inbox, keep searchable.
10. **FILE** (additive, may execute in live mode without per-item nod):
    - Route per the GL-018 PKM routing table to the owning folder.
    - Create or append the note per [[GL-002-frontmatter-conventions]] /
      [[GL-001-file-naming-conventions]]. Capture the *knowledge* (the decision,
      the fact), not just a link.
    - Store any keep-worthy attachment to the routed folder (or object
      storage/TrueNAS for large binaries per host convention); create/update the
      `documents` entity note with `digital_location`, `doc_type`,
      `expiry_date`/`renewal_trigger` if any.
    - **In Claude Code:** use file-write tools directly. **In any other LLM:**
      emit the exact file path + full contents for the human/harness to write.
11. **ACT** (propose only): build the concrete proposal and queue it.
    - Appointment/date → a drafted calendar event (title, start/end, location,
      source message-id) held for approval.
    - Actionable, no date → a drafted task per [[SOP-010-create-task]] (do not
      skip its duplicate-check and GL-016 collision loop when the task is
      actually created after approval).
    - Never create the event/task outright in this step.
12. **ALERT**: add to the run's alert digest (below). Leave the message in the
    inbox.
13. **Registry suggestions**: collect any new/changed sender rows as *proposals*
    appended to the run summary for Jeff to ratify. Never auto-write the
    registry — it is trust state.

### Phase 4 — Report, persist state, close

14. **Emit the run summary** (the single most important output). Structure:
    - **Alerts** — the `ALERT` digest, most important first. This is Goal 1 and
      Goal 3's payoff: "here is what mattered."
    - **Proposals awaiting your nod** — every `ACT` calendar/task draft.
    - **Filed** — what was written to which PKM folder (knowledge + docs).
    - **Cleaned** — counts archived/trashed, by category.
    - **Registry changes to ratify** — proposed sender-row additions/edits.
    - **Filter recommendations** — for high-frequency junk senders seen this
      run, a suggested mail-filter rule so they skip the inbox next time
      (supports Goal 3 durably). The living seed set for `gmail-personal` is
      [[Team Knowledge/SOPs/assets/gmail-filters-inbox-triage-notes|gmail-filters-inbox-triage.xml]]
      (26 rules, 2026-07-20) — append new confirmed-junk senders here rather
      than starting a new file, and re-import in Gmail after appending.
    - **In Claude Code:** deliver the alert digest to Jeff's active interface
      (e.g. a Telegram push once that layer exists). **In any other LLM:** print
      the summary; Jeff reads it in-session.
15. **Persist state**: on a successful run, update
    `.mypka/inbox-state/<inbox_id>.json` — set `last_run` to the run start
    timestamp and add every processed message-id to the set. In `dry-run` mode,
    **do not** advance state (so the same window can be re-examined). Only
    advance state for actions actually taken.
16. **Journal** (per [[SOP-016-write-journal-entry]]): if the run taught
    something durable (a new sender pattern, a routing gap, a taxonomy edge
    case), Radar writes a journal entry so the learning persists.

## Guardrails

- **Idempotent.** Re-running the same window never double-acts — the processed
  message-id set is the guard. Safe to re-run after an interruption.
- **Read-mostly on the inbox; additive on the vault.** The only destructive mail
  action is TRASH of unambiguous junk (30-day recoverable). The vault is only
  ever appended to or has notes created — never destructive.
- **One inbox per run.** State is per `inbox_id`; never process two inboxes in
  one state context (GL-018 multi-inbox rule).
- **Propose-then-confirm is not optional** (GL-018). A drafted action is not a
  taken action ([[GL-012-confirm-dispatch-not-just-narrate-it]]).
- **Dry-run is the default.** Live writes to calendar/tasks are Jeff's explicit,
  per-inbox, per-category graduation decision.
- **False negative >> false positive in severity.** When the call is close,
  route to ALERT, not TRASH.

## Two-path summary (LLM-agnostic standard)

- **In Claude Code:** connector/mail tools for fetch and label; batched
  sub-agent classification; direct file-writes for FILE; Telegram/interface push
  for the alert digest. Slash-command entry point is the doorbell; this SOP is
  the procedure.
- **In any other LLM (Cursor, Gemini CLI, plain chat):** equivalent IMAP/API or
  pasted-export fetch; sequential in-context classification with the same record
  schema; emit exact file paths + contents for FILE; print the run summary and
  alert digest. No harness-specific step is load-bearing.
