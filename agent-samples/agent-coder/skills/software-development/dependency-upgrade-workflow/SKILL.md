---
name: dependency-upgrade-workflow
description: Use for package upgrades, lockfile changes, dependency security updates, and compatibility migrations.
---

# Dependency Upgrade Workflow

Use this skill when changing dependencies.

## Workflow

1. Identify direct versus transitive dependencies and why the upgrade is needed.
2. Read release notes or migration docs for breaking changes when the version jump is meaningful.
3. Update manifests and lockfiles together.
4. Run focused tests plus any build/type/lint checks affected by the dependency.
5. Note compatibility risks, rollback path, and follow-up cleanup.
