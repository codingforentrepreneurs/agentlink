# agent-coder

Focused software engineering profile for an organization. Use this agent for code implementation, debugging, tests, CI triage, code review, repo maintenance, developer tooling, and Git/GitHub workflows.

This directory is the git-tracked source of truth for portable Hermes profile files.

Corresponding live Hermes profile:

```
${HERMES_ROOT:-$HOME/.hermes}/profiles/agent-coder
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

## Bundled capabilities

- Software development planning, spikes, test-driven development, debugging, and code review
- Python and Node debugging workflows
- GitHub authentication, issues, PRs, code review, and repo management
- DevOps automation hooks that support engineering delivery
- Native MCP and coding-agent orchestration where it directly supports software work

## Excluded by design

This profile should not carry media, personal productivity, smart-home, social, gaming, generic creative, or non-engineering research skill bundles. Keep those capabilities in the profiles that own those jobs.

## Runtime files

Do not commit runtime-only files such as .env, auth.json, memories/, sessions/, state.db*, logs/, workspace/, plans/, home/, local/, *_cache/, or tmp/.
