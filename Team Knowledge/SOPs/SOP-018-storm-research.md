# SOP-018 — Storm Research

- **Default owner:** B.J.
- **Reusable by any agent.** This is a skill, not 1:1 ownership. B.J. is the default executor, but any specialist can invoke this SOP when they need a multi-perspective, citation-verified briefing on a topic.
- **Triggered by:** user says "run a STORM research on X", "storm this topic", "give me a STORM briefing on X", "storm research this", or wants a multi-perspective, citation-verified HTML briefing. Best for topics where multiple viewpoints and fact-checked claims matter; overkill for a simple factual lookup.
- **Output:** `Deliverables/YYYY-MM-DD-{topic-slug}-storm-research/report.html` (styled, for human reading) **and** `Deliverables/YYYY-MM-DD-{topic-slug}-storm-research/report.md` (plain, for agents/grep — same final content, no template chrome). One dated folder per run, per [[GL-004-task-resource-linking]]'s multi-file-deliverable convention — reuses the existing folder-archival pattern rather than inventing a new one.
- **Template:** `Team Knowledge/Templates/storm-report-template.html`
- **References:** [[GL-001-file-naming-conventions]], [[GL-002-frontmatter-conventions]]

## Purpose

Turns one topic into a verified, multi-perspective HTML briefing. Simulates five expert lenses on the topic, maps where they contradict each other, synthesizes everything into a single self-contained HTML report, then adversarially peer-reviews its own output and verifies every citation against its primary source before delivering. The output is one HTML file with no blind spots and no unchecked claims.

Run the full pipeline end to end. Do not shortcut a phase. This is heavier than a quick web lookup; that is the point.

## Portability

The procedure (lenses, contradiction mapping, synthesis, verification) is fully LLM-agnostic and works in any capable LLM. The parallel execution mechanism is Claude Code-specific. See Phase 1 for the two-path execution note. The HTML template at `Team Knowledge/Templates/storm-report-template.html` is required for the output format. No external scripts, APIs, or paid services required.

---

## Phase 0: Scope the topic

1. If the user provided a topic, use it. Otherwise ask what to research.
2. State your interpretation of the topic in one line and proceed. Only ask a clarifying question if the topic is genuinely ambiguous in a way that changes the research. Default to proceeding.
3. Identify the **reader's role** so the actionable section can target it. Infer it from the topic and stated context; if unclear, ask in one line, or default to "a practitioner or decision-maker in this field."
4. Derive a kebab-case `topic-slug` from the topic for the filename.
5. Tell the user the pipeline is running (5 lenses, then verify). One line.

---

## Phase 1: Five expert lenses (parallel agents)

**In Claude Code:** Spawn five `general-purpose` agents in a single message so they run concurrently. Each gets the same topic framing plus its own lens.

**In any other LLM (Cursor, Gemini CLI, plain chat):** Run each lens sequentially in the same conversation. Ask the LLM to adopt each expert persona in turn — paste the persona prompt with `{TOPIC}` and `{TOPIC_FRAME}` substituted, get the response, then move to the next. Collect all five before proceeding to Phase 2.

Use these exact prompts, substituting `{TOPIC}` and a one-line `{TOPIC_FRAME}` (your Phase 0 interpretation):

**1. THE PRACTITIONER** — `You are THE PRACTITIONER for: {TOPIC} ({TOPIC_FRAME}). You work with this daily. Do real web research (prioritize recent sources, case studies, practitioner threads, operator data). Surface the GAP between what hands-on operators know and what academics/pundits miss, and the practical realities (workflow friction, what actually works, where it breaks) that get ignored. Return EXACTLY: 1) CORE POSITION in 2 sentences. 2) STRONGEST EVIDENCE, 3-5 bullets each with a concrete data point/case/named source + URL. 3) THE ONE THING only a practitioner would say. Cite real sources with URLs. Under 400 words.`

**2. THE ACADEMIC** — `You are THE ACADEMIC for: {TOPIC} ({TOPIC_FRAME}). You care about peer-reviewed evidence and effect sizes, not anecdotes. Do real web research (peer-reviewed studies, arXiv, university and research-institute reports, journals). Answer: what does the rigorous evidence ACTUALLY say vs popular belief, and where does it CONTRADICT the hype. Return EXACTLY: 1) CORE POSITION in 2 sentences. 2) STRONGEST EVIDENCE, 3-5 bullets each tied to a named study/report + URL with the actual finding/effect size. 3) THE ONE THING only an academic would say. Flag where evidence is thin or contested, and note peer-review status (published vs preprint). Under 400 words.`

**3. THE SKEPTIC** — `You are THE SKEPTIC for: {TOPIC} ({TOPIC_FRAME}). You think the mainstream view is overstated or wrong. Build the STRONGEST steelman bear case. Do real web research for backlash, failures, contradicting data, policy/regulatory changes, debunkings. Answer: the strongest counterargument, and what proponents conveniently ignore. Return EXACTLY: 1) CORE POSITION in 2 sentences. 2) STRONGEST EVIDENCE, 3-5 bullets each with a concrete source + URL. 3) THE ONE THING only a skeptic would say. Be rigorous, not contrarian for sport. Cite real sources with URLs. Under 400 words.`

**4. THE ECONOMIST** — `You are THE ECONOMIST for: {TOPIC} ({TOPIC_FRAME}). You follow the money. Do real web research for revenues, valuations, market size, funding flows, unit economics, incentives. Answer: who profits from the current narrative, and what financial incentives shape the research and hype. Return EXACTLY: 1) CORE POSITION in 2 sentences. 2) STRONGEST EVIDENCE, 3-5 bullets each with a real number (revenue/valuation/market size/funding) + named source + URL. 3) THE ONE THING only an economist would say (the follow-the-money insight). Cite real figures with URLs. Under 400 words.`

**5. THE HISTORIAN** — `You are THE HISTORIAN for: {TOPIC} ({TOPIC_FRAME}). You have seen disruption cycles before and look for patterns. Do real web research for genuine historical parallels (prior technologies, manias, market shifts). Answer: what parallels actually fit, and what we learn from how they played out (who won, who lost, what stabilized). Return EXACTLY: 1) CORE POSITION in 2 sentences. 2) STRONGEST EVIDENCE, 3-5 bullets each a specific historical case with dates/outcomes + a source URL. 3) THE ONE THING only a historian would say (the pattern no one else surfaces). Cite sources with URLs. Under 400 words.`

When all five return, post a 2-3 line note in chat: which way they converge, and the sharpest disagreement. Keep raw briefs out of chat.

---

## Phase 2: Map the contradictions

Working only from the five briefs, determine (inline, no agents):

1. **Direct conflicts** — where two or more lenses claim opposite things. Name the specific clashing claims, not just topics.
2. **Strongest vs weakest evidence** — which lens is best-supported (rank: peer-reviewed causal > official data > anecdote/analogy) and which is weakest, with why.
3. **The resolving question** — the single empirical question that would settle the biggest contradiction.
4. **Universal agreement** — what every lens confirms, even opponents. This is the likely-true load-bearing finding.
5. **The blind spot** — what NO lens addressed. This becomes the "missing 6th lens" and feeds the Frontier Question.

This map is not a separate deliverable. It is the raw material for the report's findings (supports/challenges), hidden connection, 6th-lens box, and frontier question.

---

## Phase 3: Synthesize the HTML report

1. Read `Team Knowledge/Templates/storm-report-template.html`. Clone it; do not rebuild the CSS.
2. Fill every section. Mapping from the phases:
   - **60-second summary** — decision-maker-grade, nuance not headline. Lead with the settled fact, then the contested interpretation.
   - **5 key findings, ranked by reliability** — most important things now known, highest reliability first. Each carries a 1-10 confidence score (set in Phase 4) and Supported-by / Challenged-by chips drawn from the contradiction map.
   - **Hidden connection** — the non-obvious link from Phase 2 that only appears across all five lenses.
   - **Key assumption / missing 6th lens** — the blind spot from Phase 2, framed as the lens that could change the conclusions.
   - **Actionable insight** — 3-6 specific moves for the reader's role identified in Phase 0. Specific, not abstract.
   - **Claim safety guide** — assert / caveat / avoid, populated after Phase 4 verification.
   - **Frontier question** — the one question that would change everything.
   - **References** — every citation with a verification-status tag (set in Phase 4).
3. Write to `Deliverables/YYYY-MM-DD-{topic-slug}-storm-research/report.html` (create the dated folder — and `Deliverables/` itself if needed; follow [[GL-001-file-naming-conventions]] for the date prefix on the folder name).

---

## Phase 4: Adversarial peer review + verification (do not skip)

This is what separates Storm Research from a normal report. Run it before delivering.

**4a. Self-review (inline).** Score each of the 5 findings 1-10 for reliability and justify. Identify the weakest link and what would verify it. Run a bias check (which lens dominated the synthesis, what got underweighted). Name the missing 6th perspective. Assign an honest overall grade.

**4b. Verify every citation (parallel agents).** Spawn `general-purpose` agents in one message, one per distinct citation cluster (group related claims; ~4-6 agents). Each agent prompt:

`Independently verify a citation against its PRIMARY source. Be skeptical; do not trust secondary blog summaries. CLAIM: {claim + cited figure + named source}. Find the actual primary source. Confirm or correct: exact title/authors/venue/year/URL, the real figure or effect size as published, sample/method and any author-stated limits, and peer-review status (published vs preprint). For any contested claim, find the strongest credible counter-source. Return: VERDICT = CONFIRMED / PARTIALLY CONFIRMED (list corrections) / UNVERIFIED / FALSE, then the corrected one-line citation, then 2-4 bullets of specifics with the primary URL. Under 280 words.`

**4c. Apply corrections.** Edit the report:
- Fix any wrong figures, titles, dates, or mischaracterizations.
- Downgrade confidence scores where evidence turned out thin; demote preprints and contested claims into the "Contested signal" sidebar.
- Re-attribute single-survey or commissioned stats honestly.
- Fill the verification banner (`X fabricated, Y corrected, Z demoted`) and the per-citation status tags.
- Populate the claim safety guide from the verdicts.

**4d. Write the markdown twin.** Once the HTML is at its final, corrected v2 state, render the same content as plain markdown to `report.md` in the same dated folder as `report.html` — do this last so corrections are only applied once, not duplicated across two files. Structure (headings only, no CSS/template chrome):

```markdown
# {Topic title}

**Date** · **Method: 5 lenses + verification** · **Audience: {role}**
**Verified:** N/N citations checked, X fabricated, Y corrected, Z demoted

## 60-Second Summary
{same content as the HTML .ceo block}

## Five Key Findings, Ranked by Reliability
### 1. {finding title} — Reliability: {label} ({score}/10)
{finding body}
- Supported by: {lenses/sources}
- Challenged by: {lenses/sources, or "No one"}

{repeat for all 5; include any Contested/Demoted sidebars as a `> **Contested — do not assert:**` blockquote}

## The Hidden Connection
{same content as the HTML .connection block}

## The Assumption This Rests On (Missing 6th Lens)
{same content}

## What To Actually Do Differently
{numbered action items}

## What's Safe to Assert
**Safe:** {list}
**Say with a caveat:** {list}
**Don't assert:** {list}

## The Frontier Question
{the question + why it matters}

## Evidence Base — Verification Status
{one line per citation: status tag, full citation, URL}
```

The two files must never disagree — the markdown is a direct re-rendering of the final HTML's content, not a separate summary.

---

## Output

1. Final deliverables, both inside `Deliverables/YYYY-MM-DD-{topic-slug}-storm-research/`: `report.html` (styled, v2 post-verification) **and** `report.md` (plain twin, same content).
2. Open the HTML for the user: Windows → `Start-Process <path>`. macOS → `open <path>`. Linux → `xdg-open <path>`. The markdown twin doesn't need opening — it's for agents/grep, not visual reading.
3. In chat, give: both file paths, the verification tally (`N/N checked, X fabricated, Y corrected, Z demoted`), the one universal finding, the frontier question, and the claim safety summary. Keep it tight.
4. Cross-link the folder from wherever it's referenced, using `[[YYYY-MM-DD-{topic-slug}-storm-research/report.html]]` — never a bare basename, since the folder's two files share one. Per [[GL-001-file-naming-conventions]]'s `[[path/filename]]` collision-risk convention.

---

## Notes & guardrails

- **Real research only.** Every lens and every citation must trace to a real, fetched source. No invented studies, numbers, or URLs. If a figure can't be verified, demote or cut it; never paper over it.
- **The panel is author-built.** Always disclose this in the report. Agreement across lenses is a strong hypothesis, not independent proof. Do not present convergence as consensus of the field.
- **Verification is mandatory.** A report delivered without Phase 4 is not a Storm Research report. The verification banner must be truthful.
- **Reliability = evidence quality, not confidence.** Score on the source hierarchy: peer-reviewed causal > official policy/financial data > single commissioned survey > analogy > preprint.
- **Target the reader, not a default person.** The actionable insight and claim safety guide speak to the role identified in Phase 0. Keep them generic if no role is given.
- **Cost.** This spawns ~9-11 agents per run. That is expected. Do not fan out wider than five lenses or one verifier per citation cluster.
- **Design.** Clean white and professional (Montserrat / Roboto Mono, blue accent). Keep the template CSS verbatim. Do not swap in a different visual style.
