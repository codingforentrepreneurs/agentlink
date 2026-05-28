# Agent Samples

Generic Hermes agent profiles that can be copied, installed, or used as starting points for a profile repo.

## Profiles

- `agent-cp`: executive direction, operating priorities, company-level tradeoffs, and accountability.
- `agent-cmo`: positioning, go-to-market strategy, campaign direction, and marketing performance.
- `agent-cpo`: product vision, roadmap decisions, PRDs, discovery synthesis, and launch readiness.
- `agent-coder`: implementation, debugging, tests, code review, CI triage, and repo maintenance.
- `agent-content-creator`: content drafting, editing, repurposing, packaging, and QA.

## Install

Install every sample profile:

```bash
agentlink profile install ./agent-samples --all --alias
```

Install one sample profile:

```bash
agentlink profile install ./agent-samples/agent-coder --alias
```

These profiles are intentionally generic. Rename, edit, and commit your own copies when you need organization-specific behavior.
