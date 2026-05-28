# agent-content-creator

Production-focused content creator profile for an organization. Use this agent for creating, editing, repurposing, packaging, and QA'ing content from approved strategy briefs and source material.

This directory is the git-tracked source of truth for portable Hermes profile files.

Corresponding live Hermes profile:

```
${HERMES_ROOT:-$HOME/.hermes}/profiles/agent-content-creator
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

Use `agent-content-creator` for publishable asset production. Escalate strategic ambiguity to `agent-cmo`, product claims to `agent-cpo`, technical claims to `agent-coder`, and approval conflicts to `agent-cp`.

## Runtime files

Do not commit runtime-only files such as .env, auth.json, memories/, sessions/, state.db*, logs/, workspace/, plans/, home/, local/, *_cache/, or tmp/.
