# GL-015 - Expand a Narrow Credential Before Minting a Broad One

> **This Guideline is a general rule any agent reads before requesting, provisioning, or recommending a new credential so a component can reach an existing system's data.** It applies whenever a new script, service, or routine needs something another part of the architecture already touches. SOPs, Workstreams, and specialist contracts `[[wikilink]]` here rather than restating the rule.

## The rule

**When a new component needs data or access that an existing, already-scoped credential could reach, expand or reuse that narrow credential instead of minting a new broad one.** Before reaching for "give the new thing its own credential," ask: does something in the current architecture already have a relationship to this data that could be narrowed and reused instead?

The test for "narrow enough to expand" is the blast radius, not convenience: a credential that is read-only, restricted to one bucket/table/prefix, or otherwise pre-scoped is a safer thing to extend than it is to replace with something broader. Extending it keeps the *new* credential's own blast radius small even if it leaks; minting a broad one to save a step hands out access the new component doesn't need and the rest of the system now has to defend against.

## When this does NOT apply

- **No existing credential is anywhere close in scope.** Forcing a fit onto an unrelated existing key is worse than a clean, purpose-built, narrowly-scoped new one. This rule is about reuse-when-reasonable, not reuse-at-all-costs.
- **The existing credential is itself overprivileged.** Extending access via an already-too-broad key just compounds the problem — narrow the existing one first if that's the case, then extend the narrowed version.

## Mechanical note: who can mint the narrower key

An operational credential (the kind used for day-to-day read/write) frequently does **not** carry key-management capability by default — it can't create other keys, and calling a key-creation API with it returns a bare `401`/`403`. Creating a new scoped key in that case typically requires the account's master credential or a key explicitly granted management capability, which most providers don't hand to routine automation. In practice: **a human creates the narrowly-scoped key through the provider's own console** — this is not something an agent holding only an operational credential can bootstrap for itself, and that limitation is a feature of the security model, not a bug to route around.

## Why this rule exists

2026-07-09: the Weekly Strategy Report cloud routine needed to read Prophet Trader's weekly data. The first design gave `davisglobe-vps-ash-1` a brand-new credential — write access to the entire private `mypka` vault repo — to solve what was actually a much narrower problem (read one folder's worth of JSON files). Jeff rejected it on sight: a compromised VPS with that credential could read/write the whole vault, not just trading data.

The shipped fix reused a trust relationship that already existed: the VPS already wrote Prophet Trader's data to a Backblaze B2 bucket nightly. Instead of a new git credential, a second B2 Application Key was created — read-only, restricted to one bucket, restricted to one file-name prefix (`data/autopsies/`) — and the cloud routine reads directly from B2. Zero new trust granted to the VPS; the new credential's blast radius, even leaked, is "read old summary numbers."

This same default was invoked at least twice more without ever being written down: refusing to hand a raw production Telegram bot token to a cloud routine, and minting a new write-scoped GitHub deploy key rather than reusing or broadening an existing one. Three invocations from memory, in three different contexts, is the signal that this belongs in a Guideline rather than being re-derived each time. See [[Team/Pierce - Senior Developer/journal/2026-07-09-prefer-expanding-a-narrow-credential-over-minting-a-broad-one]] for the full account, including the B2 key-management mechanical note above.

## Updates to this Guideline

- 2026-07-18 — created (Vex), per WS-004 Tier 2 Team Retro proposal 8, graduated from [[Team/Pierce - Senior Developer/journal/2026-07-09-prefer-expanding-a-narrow-credential-over-minting-a-broad-one]]. Placed as a standalone Guideline rather than folded into Vex's own contract: the pattern has already been invoked by more than one agent (Pierce on dev/architecture calls, Hawkeye on connection design) making credential-provisioning decisions outside a security audit — it is a team-wide default for anyone minting or requesting a credential, not a Vex-specific audit technique, so it belongs where every agent reads it rather than buried in one specialist's personal contract.
