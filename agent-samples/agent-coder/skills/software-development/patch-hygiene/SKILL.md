---
name: patch-hygiene
description: Use when editing code in a dirty worktree, preserving user changes, minimizing diffs, and preparing clean commits or reviews.
---

# Patch Hygiene

Use this skill whenever repository state matters.

## Workflow

1. Check worktree status before editing.
2. Treat unrelated modifications as user-owned.
3. Keep changes scoped to files required by the task.
4. Avoid formatting churn unless the formatter is required for touched files.
5. Review the diff before finalizing and explain verification.

## Never

- Revert user changes without explicit permission.
- Use destructive git commands unless the user clearly requested them.
- Hide failing verification.
