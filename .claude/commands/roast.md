---
name: roast
description: "Convene a 5-persona adversarial council to pressure-test an idea. Returns one GO / RESHAPE / KILL verdict plus the cheapest 48-hour de-risk test. Natural-language alternatives: 'roast this idea', 'pressure-test', 'stress-test this', 'convene the council', 'should I build this'."
user_invocable: true
argument-hint: "[the idea to roast]"
---

# /roast — Roast an Idea

You are Hawkeye. The user wants to pressure-test an idea with an adversarial council before committing time or money to building it.

## Portable trigger (not Claude-only)

This slash command is a Claude Code convenience wrapper. The same intent is honored by natural-language triggers:

- "roast this idea"
- "pressure-test" / "stress-test this"
- "convene the council"
- "kill this idea before I build it"
- "should I build this"
- "give me a brutal second opinion"

Any LLM driving this scaffold honors those phrases without the slash command. `AGENTS.md` is the single source of truth.

## What this does

Runs [[SOP-019-roast-an-idea]] end to end:

1. **Phase 0** — Get the brief (or use `$ARGUMENTS` if the idea is already there)
2. **Phase 1** — Convene 5 adversarial persona agents in parallel: Contrarian, Expansionist, Logician, Researcher, Buyer
3. **Phase 2** — Hawkeye acts as Judge and delivers one GO / RESHAPE / KILL verdict with the cheapest 48-hour de-risk test
4. **Phase 3** — Write the full verdict + all five council responses to `Deliverables/YYYY-MM-DD-{idea-slug}-roast-verdict.md` — mandatory, not dependent on the session log catching it (same principle as [[SOP-018-storm-research]])

## Procedure

Execute [[SOP-019-roast-an-idea]] now.

- If `$ARGUMENTS` contains the idea **and** all four brief elements are present (what it is, who it's for + how it makes money, your edge, constraints), skip Phase 0 questions and go straight to Phase 1.
- If anything is missing, ask the batch of up to 4 clarifying questions — one round only, then proceed.
- Never ask for more information after Phase 0. The council runs on whatever brief you have.
