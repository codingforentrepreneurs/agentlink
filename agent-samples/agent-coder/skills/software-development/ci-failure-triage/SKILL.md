---
name: ci-failure-triage
description: Use to diagnose failing CI, tests, builds, lint, type checks, deployment checks, or release gates.
---

# CI Failure Triage

Use this skill when a check is failing or flaky.

## Workflow

1. Identify the failing job, command, environment, and first meaningful error.
2. Reproduce locally with the narrowest equivalent command when possible.
3. Distinguish code failures, test failures, dependency drift, environment issues, and flaky timing.
4. Fix the smallest root cause and rerun the relevant check.
5. Report what failed, what changed, and what remains unverified.
