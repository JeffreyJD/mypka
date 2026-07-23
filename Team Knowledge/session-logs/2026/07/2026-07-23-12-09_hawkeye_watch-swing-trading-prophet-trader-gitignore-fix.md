---
agent_id: hawkeye
session_id: 2026-07-23-watch-swing-trading-prophet-trader-gitignore-fix
timestamp: 2026-07-23T16:09:04Z
type: close-session
linked_sops: ["SOP-010-create-task", "SOP-013-rebuild-task-index"]
linked_workstreams: []
linked_guidelines: ["GL-011-capture-watch-summaries-before-session-end", "GL-010-commit-and-push-before-session-close", "GL-001-file-naming-conventions", "GL-004-task-resource-linking"]
linked_tasks: ["tsk-2026-07-22-001-bj-research-capitulation-volume-exhaustion-reversal-signal", "tsk-2026-07-22-002-risk-based-position-sizing-quarterly-review"]
linked_journal_entries: []
---

# Watched a swing-trading video, screened it for Prophet Trader, caught a public-repo exposure risk during close

## Context

Session opened fresh (Google Calendar MCP auth had just succeeded via `/mcp`, unrelated to the rest of the session). Jeff asked to `/watch` a YouTube video on swing trading, then asked whether anything in it applied to Prophet Trader. That screening produced two tasks. At session close, the mandatory git-hygiene pass surfaced a pre-existing uncommitted `.gitignore` change that had gutted the personal-data exclusion rules on a public GitHub repo.

## What we did

- Ran the `watch` skill on https://www.youtube.com/watch?v=k-X0164r66U (Lance / TheOneLance, swing trading strategy breakdown, 13:11). Full native-caption transcript, sampled frames, summarized structure and key claims.
- Routed the "anything usable for Prophet Trader" question to Blake (CIO) for screening rather than answering directly.
- Blake screened three ideas from the video against the IPS and current strategy configs, checking actual YAML (`momentum_breakout_stocks.yaml`) rather than reasoning from memory:
  - Capitulation/volume-exhaustion mean reversion — confirmed a real gap (no equity strategy currently maps to the IPS's `capitulation` regime class) — routed to B.J. for a research brief.
  - Stop-width-proportional-to-size sizing — confirmed Prophet Trader sizes fixed-% of equity while stops vary by ATR, a real but non-urgent doctrine gap — flagged for the next quarterly risk parameter review.
  - Continuation/momentum-with-catalyst — ruled redundant with strategies already running; declined to act mid-Phase-2 per IPS §7.7 restart-on-change rule.
- Created [[tsk-2026-07-22-001-bj-research-capitulation-volume-exhaustion-reversal-signal]] (assignee bj, priority 4) and [[tsk-2026-07-22-002-risk-based-position-sizing-quarterly-review]] (assignee blake, priority 4), each with cross-references walked per SOP-010.
- Rebuilt `Team Knowledge/tasks/INDEX.md` by hand (no committed rebuild script exists yet — see Insights) covering all 33 open / 0 in-progress / 26 done-this-month / 1 cancelled-this-month tasks.
- Wrote `Deliverables/2026-07-22-swing-trading-strategies-watch-summary.md` per GL-011 before the `/watch` plugin's temp directory could be lost.
- **Git hygiene finding:** `.gitignore`'s uncommitted working-tree content had been reduced to a single line (`.env`), dropping the exclusions for `PKM/`, `Documents/`, `Deliverables/`, `Team Inbox/`, `mypka.db*`, and `.mypka/` that were deliberately committed in b1af463. The `mypka` GitHub remote is **public**. Nothing had been pushed, so no actual exposure occurred, but committing the working tree as-is would have made Jeff's family CRM, journal, financial docs, and trading strategy details trackable/pushable to a public repo.
- Flagged this to Jeff before touching anything; he confirmed **restore the safe .gitignore**. Restored it via `git checkout -- .gitignore`, then added an explicit `.env` rule (the corrupted version's only line) so the actual secrets file — which had also gone untracked — can never be committed either.
- Staged and committed only the files this session touched (`.gitignore`, `Team Knowledge/tasks/INDEX.md`, the two new task files) — left unrelated untracked items (`.env.example`, `bin/`, `install-mypka.ps1`, `scripts/__pycache__/`, `scripts/track-b-inboxes.json`) alone since they weren't this session's to decide on. Pushed to `origin/main` (`e9e422f..3e41d5b`).

## Decisions made

- **Question:** Video-sourced strategy ideas — evaluate directly, or screen first?
  **Decision:** Blake screens against the IPS and actual configs before anything reaches a research task or formal evaluation; an anecdote from a video is never itself evidence.
- **Question:** `.gitignore`'s working tree had lost the personal-data exclusions — restore, investigate first, or treat as intentional?
  **Decision:** Jeff confirmed restore. Restored from the last commit and hardened with an explicit `.env` rule.

## Insights

- **`SOP-013-rebuild-task-index` has no committed script** — its own body says "the SOP body is the spec the LLM follows" when run by hand, but at 33+ open tasks doing this by careful manual reasoning risks drift. This session wrote a throwaway awk/bash rebuild script in the scratchpad to do it reliably and it worked, but that script isn't persisted anywhere — the next session doing this SOP starts from zero again. Worth considering whether `SOP-013` should ship an actual committed script (e.g. `scripts/rebuild-task-index.sh` or similar) rather than relying on an LLM re-deriving the awk logic each time.
- **A `.gitignore` regression can sit uncommitted for a full session (or longer) without being caught**, because `git status` alone doesn't distinguish "newly untracked because ignore rules changed" from "genuinely new files" — it took the mandatory GL-010 close-session pass to notice, and only because the untracked-directory collapse (`PKM/`, `Deliverables/`, `Team Inbox/` all appearing as bare directory entries) looked unusual against the earlier per-file untracked listing from session start. A `.gitignore` diff check specifically (not just `git status`) might belong somewhere in the standing session hygiene, not just an alert reader catching a shape anomaly.
- Windows/git-bash gotcha reconfirmed: iterating `for f in $(find ...)` word-splits on paths containing spaces (common in this vault — `Team Knowledge/`, `Team Inbox/`) and silently truncates them at the first space, which is what broke the first rebuild-index attempt. `while IFS= read -r f; do ... done < <(find ...)` is the fix; worth a general callout since this vault's folder names guarantee this bug will recur.

## Realignments

- _(none this session — the .gitignore question was flagged proactively before any action, so it's a clean confirm rather than a correction)_

## Open threads

- [ ] B.J. to produce the capitulation/volume-exhaustion research brief ([[tsk-2026-07-22-001-bj-research-capitulation-volume-exhaustion-reversal-signal]]) — not urgent, no deadline set.
- [ ] Blake to carry the risk-based sizing question into the next quarterly risk parameter review ([[tsk-2026-07-22-002-risk-based-position-sizing-quarterly-review]]) — rides existing cadence, no separate scheduling needed.
- [ ] Untracked files not addressed this session, left as-is pending owner attention: `.env.example` (looks like a safe template, never triaged), `bin/` and `install-mypka.ps1` (likely Cockpit launcher build output — unclear if these should be tracked or gitignored), `scripts/__pycache__/` (Python bytecode cache — almost certainly should be gitignored), `scripts/track-b-inboxes.json` (Klinger's Track B connector work, already partially committed in a concurrent session's `e9e422f`).
- [ ] Consider whether `SOP-013-rebuild-task-index` should get a committed script (see Insights).

## Next steps

- Next session boot: task INDEX.md is current as of this close; no rebuild needed unless new tasks land first.
- Whoever picks up git hygiene next should decide on the five untracked items listed above rather than letting them linger indefinitely.

## Cross-links

- [[2026-07-22-23-00_hawkeye_email-assistant-architecture-and-track-a-build]] — closest prior session log (same day, Hawkeye).
