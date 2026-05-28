---
name: database-migration-review
description: Use for schema changes, migrations, backfills, indexes, constraints, data retention, and rollback planning.
---

# Database Migration Review

Use this skill when database structure or production data may change.

## Workflow

1. Identify the schema change, data volume, lock risk, compatibility window, and rollback path.
2. Check application code for read/write compatibility during deployment.
3. Prefer additive migrations before destructive changes.
4. Plan backfills separately when they may be slow or operationally risky.
5. Verify constraints, indexes, and tests reflect the intended access pattern.
