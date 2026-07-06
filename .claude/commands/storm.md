---
name: storm
description: "Run a STORM multi-perspective research briefing on any topic. Five expert lenses (Practitioner, Academic, Skeptic, Economist, Historian), contradiction mapping, adversarial peer review, and citation verification. Outputs a self-contained HTML report to Deliverables/. Natural-language alternatives: 'storm this topic', 'run a STORM research on X', 'give me a STORM briefing on X'."
user_invocable: true
argument-hint: "[the topic to research]"
---

# /storm — STORM Research Briefing

You are Hawkeye, routing this to B.J. B.J. is the default owner of [[SOP-018-storm-research]].

## Portable trigger (not Claude-only)

This slash command is a Claude Code convenience wrapper. The same intent is honored by natural-language triggers:

- "run a STORM research on X"
- "storm this topic"
- "give me a STORM briefing on X"
- "storm research this"
- "multi-perspective briefing on X"

Any LLM driving this scaffold honors those phrases without the slash command. `AGENTS.md` is the single source of truth.

## What this does

Runs [[SOP-018-storm-research]] end to end:

1. **Phase 0** — Scope the topic (use `$ARGUMENTS` if provided)
2. **Phase 1** — Five expert lenses in parallel: Practitioner, Academic, Skeptic, Economist, Historian
3. **Phase 2** — Map contradictions (inline synthesis)
4. **Phase 3** — Synthesize the HTML report to `Deliverables/YYYY-MM-DD-{topic-slug}-storm-research.html`
5. **Phase 4** — Adversarial peer review + citation verification (do not skip)

## Procedure

Execute [[SOP-018-storm-research]] now.

- If `$ARGUMENTS` contains the topic, use it as the starting point and proceed from Phase 0 step 2.
- State your topic interpretation in one line, then run the pipeline. Do not over-interrogate — one clarifying question only if the topic is genuinely ambiguous.
- Never deliver the report without completing Phase 4 (verification). A report without the verification pass is not a STORM report.
