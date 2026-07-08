# GL-008 - Read the Relevant Registry Note Before Creating New State

> **This Guideline is a general rule every agent reads before creating anything new on a host, in an account, or as a service** — a project folder, a cloned repo, a new service registration, a new local tool install. SOPs and Workstreams `[[wikilink]]` here rather than restating the rule.

## The rule

**Before deciding where or how to create something new, read the Environment registry note for the host/service/account it touches — not just the folder you're about to create.** `PKM/Environment/Hosts/`, `Services/`, `Accounts/`, and `Software/` exist precisely so that conventions ("this is where local projects live," "this is the naming pattern," "this account already has three services on it") are written down once. An agent that skips straight to "does a plausible folder exist" instead of "what does the registry say" will invent a second convention next to the first one.

This generalizes a rule Pierce's contract already applies narrowly to VPS changes ("read the current Environment registry before making any config change") to **every** agent, for **every** kind of new local/registry-adjacent state — not just VPS operations.

## Practical check

Before creating new state, in order:

1. **Identify the host it lands on** (usually `jeff-laptop` for local tools, or a named VPS for deployed services).
2. **Read that host's note in `PKM/Environment/Hosts/`.** It documents existing conventions — "what runs here," established folder patterns, prior projects.
3. **If the note is silent on the convention you need**, do a full, unabridged directory listing of the relevant location before picking a new path — not a truncated `ls | head -N` that can silently hide an existing folder.
4. **After creating the new state**, update the host/service/account note in the same session so the next agent doesn't have to rediscover it.

## Why this rule exists

2026-07-07: asked to set up `token-dashboard` (a local Python tool), Hawkeye ran `ls` on the home directory, truncated the output with `head -30`, and didn't see the pre-existing `~/dev` folder (lowercase, sorts after the uppercase Windows folders — cut off by the truncation). Cloned into a newly-created `~/projects` instead. `PKM/Environment/Hosts/jeff-laptop.md` already documented `~/dev` as home to `prophet-trader` — reading that note first would have caught it immediately, no directory listing required. The mistake was caught only because Jeff asked why `dev` wasn't used, and the folder had to be moved after the fact (complicated further by a stray locked-handle issue during the move).

## When this does NOT apply

- One-off scratch work that isn't meant to persist (temp files, throwaway scripts) — the registry is for durable state, not every ephemeral action.
- The registry note is confirmed absent (new host, nothing registered yet) — in that case, step 3 (full directory listing) is the fallback, and the agent should create the registry note once the convention is established, per [[GL-002-frontmatter-conventions]].

## Updates to this Guideline

- 2026-07-08 — created (Hawkeye), graduated from the token-dashboard `~/dev` vs `~/projects` near-miss, surfaced by Jeff during the same session as [[GL-007-verify-before-acting-on-a-finding]].
