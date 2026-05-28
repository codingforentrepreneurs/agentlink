# agent-cmo

Chief marketing officer profile for an organization. Use this agent for positioning, market strategy, GTM planning, launch strategy, campaign direction, channel strategy, growth priorities, and marketing performance interpretation.

This directory is the git-tracked source of truth for portable Hermes profile files.

Corresponding live Hermes profile:

```
${HERMES_ROOT:-$HOME/.hermes}/profiles/agent-cmo
```

Hermes reads the portable profile files through symlinks from the live profile directory back to this directory.

## Tracked and symlinked

- distribution.yaml
- SOUL.md
- config.yaml
- mcp.json
- skills/
- cron/
- profile.md

## Role boundary

Use `agent-cmo` for marketing leadership and strategic direction. Route execution-heavy content production to `agent-content-creator`, product promises to `agent-cpo`, and company-level tradeoffs to `agent-cp`.

## Runtime files

Do not commit runtime-only files such as .env, auth.json, memories/, sessions/, state.db*, logs/, workspace/, plans/, home/, local/, *_cache/, or tmp/.
