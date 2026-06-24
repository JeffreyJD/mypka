# Team - Agent Index

Routing table for the six specialists shipped on day one. Hawkeye reads this on every request to decide who handles what.

| Specialist | Role | Folder | Routes to them when |
|---|---|---|---|
| Hawkeye | Orchestrator, Librarian, Session-Log Author | [[Team/Hawkeye - Orchestrator/AGENTS]] | Every request lands here first. Hawkeye never executes domain work; he routes, then synthesizes. |
| Potter | HR | [[Team/Potter - HR/AGENTS]] | User wants to hire a new specialist, retire one, or audit team hygiene. Default owner of [[SOP-001-how-to-add-a-new-specialist]]. |
| B.J. | Researcher | [[Team/B.J. - Researcher/AGENTS]] | User asks a question that needs cross-source verification, fact-checking, or structured intelligence. |
| Radar | Journal Writer | [[Team/Radar - Journal Writer/AGENTS]] | User shares thoughts, screenshots, voice notes, photos, or anything that needs to land in the Journal or PKM. See [[WS-001-daily-journaling]]. |
| Klinger | Automation Specialist | [[Team/Klinger - Automation Specialist/AGENTS]] | API integrations, MCP servers, webhooks, OAuth flows, automation scripts. Connection layer for external imports — fetches the bytes, hands off to Margaret. Wires up external image generators when local image-gen isn't available. |
| Margaret | Database Architect | [[Team/Margaret - Database Architect/AGENTS]] | External knowledge imports — primary executor of [[WS-002-import-external-knowledge-base]]. Default owner of [[SOP-002-convert-mypka-to-sqlite]]. Frontmatter integrity audits, schema drift, GL-002 compliance. |

| Trapper | Homelab & Drone Engineer | [[Team/Trapper - Homelab & Drone Engineer/AGENTS]] | Anything touching Lighthouse (R730XD), Watchtower (R740), OPNsense (R340), drone builds (Farragut/Resolute/Intrepid), ArduPilot, Proxmox, TrueNAS, network/VLAN, parts compatibility, firmware. |
| Sydney | Personal Brand Agent | [[Team/Sydney - Personal Brand Agent/AGENTS]] | Resume tailoring, LinkedIn content, blog drafts, YouTube scripts, bios, anything that needs to sound like Jeff — direct, outcome-focused, no buzzwords. |
| Mulcahy | Personal Life Agent | [[Team/Mulcahy - Personal Life Agent/AGENTS]] | Journal entries, FL property search, personal contacts, personal finance, crypto portfolio context, life planning. Personal/ domain is sealed. |
| Henry | Lake Erie Agent | [[Team/Henry - Lake Erie Agent/AGENTS]] | Sea Ray 340 "Happy Ours", Sea-Doo RTI, Fishin' Impossible team, Lake Erie fishing intel, vessel maintenance, commissioning, slip logistics at Erie Yacht Club. |
| Tuttle | Genealogy Agent | [[Team/Tuttle - Genealogy Agent/AGENTS]] | Family tree research, DNA match analysis, archive lookups, source citation, brick wall strategies. GPS standard — every claim gets a source. |
| Igor | Food Agent | [[Team/Igor - Food Agent/AGENTS]] | BBQ smoking, grilling, flattop griddle cooking, cook plans, recipe adaptation, session logs, equipment recommendations. |
| Zale | Home Improvement Agent | [[Team/Zale - Home Improvement Agent/AGENTS]] | DIY project planning, materials lists, Erie PA permit guidance, framing/electrical/plumbing/finishing work. Known projects: 9th Street Fence, 32mm cabinet CNC build. |
| Frank | Rentals Manager | [[Team/Frank - Rentals Manager/AGENTS]] | Rental property management — tenant matters, lease questions, rent tracking, maintenance coordination, rental financials. |
| Flagg | Gunsmithing Agent | [[Team/Flagg - Gunsmithing Agent/AGENTS]] | AR-15/AR-10 builds, 1911 platform, parts compatibility, build documentation, compliance verification (federal + PA). Compliance always first. |
| Rizzo | Automobiles Agent | [[Team/Rizzo - Automobiles Agent/AGENTS]] | Vehicle maintenance tracking, service scheduling, recall/TSB lookup, fleet overview, registration and insurance expiry. |
| Painless | Car Detailing Agent | [[Team/Painless - Car Detailing Agent/AGENTS]] | Detailing process guidance, product selection, paint correction, ceramic coating, interior detailing, session logging. |
| Kellye | Travel Agent | [[Team/Kellye - Travel Agent/AGENTS]] | Domestic and international trip planning, itinerary building, document tracking, flight and accommodation research. |
| Winchester | Investment Strategist | [[Team/Winchester - Investment Strategist/AGENTS]] | Equities strategy, crypto portfolio (Core/Explore model), portfolio construction, rebalancing, watchlist updates, risk management, market intelligence. Never executes trades. |
| Blake | Chief Investment Officer | [[Team/Blake - Chief Investment Officer/AGENTS]] | Prophet Trader strategy evaluation, Phase gate readiness (paper → live capital), position sizing doctrine, regime-based deployment decisions, weekly strategy autopsy, new strategy go/no-go, risk parameter review. Scope: Prophet Trader only — personal portfolio is Winchester's domain. |
| Sparky | Network Architect | [[Team/Sparky - Network Architect/AGENTS]] | VLANs, firewall rules, UniFi controller administration (USG-Pro-4, US-24, AP AC Pro, UCK G2 Plus), wireless RF planning (channel assignment, Fast Roaming, SSID design), IP addressing schema, network security (IoT isolation, zone-based policy), network incident triage. |
| Pierce | Senior Developer | [[Team/Pierce - Senior Developer/AGENTS]] | Python development and debugging, GitHub Actions CI/CD pipelines, VPS application operations (davisglobe-vps-ash-1, prophet-trader, cron, systemd), software architecture decisions, git workflow enforcement (dev→main), Docker/containerization, adding new software projects to the portfolio. |

## Bootstrap rule

If this table shrinks below 3 rows, Hawkeye switches to Bootstrap Mode and prompts the user to hire replacements via Potter.

## Adding a new specialist

Follow [[SOP-001-how-to-add-a-new-specialist]]. Potter owns this procedure.
