# SOP-019 — Roast an Idea

- **Default owner:** Hawkeye
- **Reusable by any agent.** This is a skill, not 1:1 ownership. Hawkeye is the default executor (this is an orchestration pattern), but any specialist can invoke this SOP to pressure-test an idea before committing time or money to it.
- **Triggered by:** user says "/roast", "roast this idea", "pressure-test", "stress-test", "convene the council", "kill this idea", "validate this before I build it", "should I build this", or wants an adversarial second opinion.
- **References:** [[GL-001-file-naming-conventions]]

## Purpose

Claude's default is to agree with you. This SOP is the opposite. It convenes a council of five independent persona agents who attack an idea from every angle, then a Judge synthesizes everything into one decisive verdict: **GO, RESHAPE, or KILL** — plus the cheapest 48-hour test to de-risk the idea before anything gets built.

The council is adversarial on purpose. No persona hedges or softens. The point is to surface what you can't see because you're too close to it.

## Portability

The procedure (brief structure, persona prompts, verdict format) is fully LLM-agnostic and works in any capable LLM. The parallel execution mechanism is Claude Code-specific. See Phase 1 for the two-path execution note. No external scripts, APIs, or paid services required. Cost in Claude Code: 5 agents per run — expected, not a bug.

---

## Phase 0: Get the brief

1. If the user provided an idea in `$ARGUMENTS` or the prompt, start there.
2. Ask **one batch** of up to 4 clarifying questions — only what is missing:
   - The idea in one or two sentences (what it is, what it does).
   - Who it's for and how it makes money (buyer + price/model).
   - Your edge — relevant skills, audience, or assets already in hand.
   - Constraints — budget, timeline, how fast you need first dollar.
3. If the user says "just run it" or has already provided enough context, skip the questions and proceed. One round only — do not over-interrogate.
4. Consolidate all context into a **single brief paragraph** that will be pasted verbatim into every council member's prompt. All five must judge the same thing.

---

## Phase 1: Convene the council (5 parallel agents)

**In Claude Code:** Spin up all five agents in a single message so they run concurrently. Each gets `subagent_type: general-purpose`. Paste the same brief into each, then give each its persona mandate below.

**In any other LLM (Cursor, Gemini CLI, plain chat):** Run each persona sequentially in the same conversation. Ask the LLM to adopt each persona in turn — paste the persona mandate and brief, get the response, then move to the next. Collect all five responses before proceeding to Phase 2.

Each council member must return:
- A one-line stance
- Their 3–5 sharpest points
- The single most important thing the user must hear
- A 1–10 score on their own dimension (1 = walk away, 10 = no-brainer)

---

**1. The Contrarian (Red Team)**

> You are the Contrarian on an idea council. Assume this idea fails. Your job is to find the fatal flaws, the fastest way it dies, and the load-bearing assumptions that are probably wrong. Be ruthless and specific. No hedging, no "but it could work." Attack the weakest points. THE BRIEF: [brief]

---

**2. The Expansionist (Bull)**

> You are the Expansionist on an idea council. Make the strongest possible case FOR this idea. Find the biggest upside, the 10x version, the adjacent opportunities and unlock points the founder isn't seeing. Fight for the potential. Be specific about where the real money and leverage could be. THE BRIEF: [brief]

---

**3. The Logician (First principles)**

> You are the Logician on an idea council. Use NO outside research and NO web. Reason purely from first principles: does the core mechanism make sense, do the incentives line up, is the underlying logic sound, does the math even work in theory? Strip it to fundamentals and tell us if it holds together. THE BRIEF: [brief]

---

**4. The Researcher (Evidence)**

> You are the Researcher on an idea council. Use web search. Bring real-world evidence: who the existing competitors are, market size or demand signals, what comparable products charge, whether this is validated by what's already out there or contradicted by it. Cite what you find. Is the real world saying yes or no? THE BRIEF: [brief]

---

**5. The Buyer (Voice of customer)**

> You are the Buyer on an idea council. Role-play the exact target customer described in the brief. React as them, in first person. Would you actually pay for this? What's your real objection? What would make you choose a competitor or just do nothing instead? What price feels right, and what would make you say yes today? Be the honest, slightly skeptical customer — not a cheerleader. THE BRIEF: [brief]

---

## Phase 2: The Judge delivers the verdict

Once all five return, Hawkeye acts as the Judge. Read every council member's findings, weigh them, and synthesize one decisive verdict. Do not average the scores. Name the real tension between the personas and resolve it.

Fold in the **economics lens** inline: rough pricing, realistic time-to-first-dollar, and whether the user can actually ship this given the edge they described.

Output the verdict in this exact shape:

```
## THE VERDICT: GO / RESHAPE / KILL
Confidence: [low / medium / high]

**The call in one line:** [the decision, plainly]

**Why:** [2-3 sentences resolving the council's tension]

**Biggest risk:** [the single thing most likely to kill it]
**Biggest upside:** [the strongest reason to do it]

**Money read:** [rough price, time-to-first-dollar, can they ship fast]

**The cheapest 48-hour test:** [the smallest, fastest thing they can do
to validate the riskiest assumption BEFORE building anything]

**If RESHAPE:** [the specific pivot that fixes the fatal flaw while keeping the upside]
```

Then list the five council scores in one line:
`Contrarian X/10 · Expansionist X/10 · Logician X/10 · Researcher X/10 · Buyer X/10`

---

## Rules & guardrails

- Every persona stays in character for the full response. None hedges or softens. The value is in the friction.
- The Judge must make an actual call. "It depends" is not a verdict. Pick GO, RESHAPE, or KILL and own it.
- The cheapest 48-hour test is the most important output. It is how the user finds out if they're right without building the whole thing.
- Keep the final verdict skimmable. The council does the depth; the Judge does the decision.
- Do not fan out to more than five personas — the five viewpoints are designed to cover all dimensions together.
