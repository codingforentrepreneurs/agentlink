---
name: repo-orientation
description: Use at the start of coding work to map a repository, identify frameworks, find relevant files, and choose the smallest safe implementation path.
---

# Repo Orientation

Use this skill before non-trivial code changes.

## Workflow

1. Inspect the file tree, package manifests, test config, and framework conventions.
2. Search for existing implementations, helpers, tests, and naming patterns.
3. Identify the likely ownership boundary and avoid unrelated modules.
4. State the implementation surface, verification commands, and risks before editing when the change is substantial.

## Quality Bar

- Prefer `rg` and targeted file reads.
- Reuse existing local patterns.
- Do not invent a new architecture until the repo has shown that it needs one.
