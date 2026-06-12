---
name: Anthropic
status: active
account_type: api
provider_url: https://www.anthropic.com
username: jeff@davisglobe.com
plan: ""
monthly_cost: ""
renewal_date: ""
secrets_ref: Claude Code standard login on jeff-laptop; ANTHROPIC_API_KEY in .env on davisglobe-vps-ash-1
env_var_names:
  - ANTHROPIC_API_KEY
linked_services:
  - prophet-trader
linked_hosts: []
tags:
  - ai
---

# Anthropic

Claude access for both daily knowledge work ([[claude-code]] on [[jeff-laptop]]) and [[prophet-trader]]'s agent council.

## Key facts

- **Personal account, direct auth** — no Portkey, no Bedrock, no corporate gateway (this machine is not Perficient-managed).
- API usage is expected to be prophet-trader's largest cost line: roughly $50–200/month at Phase 2; the weekly autopsy is the single most expensive workflow.

## Open questions

- Record the plan (Pro/Max/API tier) and typical monthly spend once a few billing cycles land.
- Consider a named/scoped API key per agent or project so spend is attributable (the "intern gets their own key" principle).
