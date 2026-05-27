---
name: release
description: Prepare and publish GitHub releases for software projects. Use when the user asks to release a new version, run a "/release" workflow, bump versions, create release commits or tags, generate release notes, publish GitHub Releases with `gh`, or verify a repo is ready to ship.
---

# Release

## Overview

Use this skill to release a new project version on GitHub with conservative checks, explicit user confirmation before irreversible publication, and release notes grounded in repository history.

## Release Workflow

1. Inspect the repository state.
   - Run `git status --short --branch`.
   - Identify the default branch and current branch with `git branch --show-current` and `git remote show origin` when needed.
   - Refuse to overwrite or revert unrelated uncommitted work. If release edits must touch dirty files, inspect them and work with the existing changes.

2. Discover release conventions.
   - Read project files before deciding the release process: `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `CHANGELOG*`, release scripts, CI workflows, and existing tags.
   - Prefer repo-defined commands such as `npm version`, `cargo release`, `semantic-release`, `goreleaser`, `changesets`, or Makefile targets over hand-editing metadata.
   - Check recent tags with `git tag --sort=-version:refname | head` and recent history with `git log --oneline --decorate -n 30`.

3. Determine the target version.
   - If the user provides a version, validate it against project conventions.
   - If not, infer the next version from the latest stable tag and commit history, then tell the user the inferred version and why.
   - Treat pre-release identifiers (`alpha`, `beta`, `rc`) and leading `v` tag prefixes consistently with existing tags.

4. Build release notes.
   - Base notes on commits, merged PRs, changelog fragments, or existing changelog conventions.
   - Use `gh pr list` or `gh release view` only when available and authenticated.
   - Keep notes concise and user-facing. Group by meaningful categories when there is enough material: Added, Changed, Fixed, Removed, Security, Internal.
   - Do not invent changes. If history is ambiguous, say what evidence was used.

5. Apply release edits.
   - Update version declarations, lockfiles, changelog, and generated metadata using the project's normal tooling.
   - Keep edits narrowly scoped to release artifacts unless the repo convention requires more.
   - Run formatting only when release tooling or changed files require it.

6. Verify before publishing.
   - Run the repo's standard validation for release risk: tests, lint, typecheck, build, or release dry-run.
   - Prefer targeted checks when the change is only metadata; broaden checks when generated artifacts, packaging, or published bundles are involved.
   - If a required network command fails because of sandboxing, request escalation rather than skipping it silently.

7. Ask before irreversible operations.
   - Before creating or pushing tags, pushing commits, publishing packages, or creating a GitHub Release, summarize the exact version, tag, commit, release notes source, verification commands, and commands to be run.
   - Get explicit user approval unless the user already gave a direct instruction to perform that exact action.

8. Publish the release.
   - Commit release edits if the repo convention uses a release commit.
   - Create annotated tags unless the repo clearly uses lightweight tags.
   - Push the release commit and tag with the minimal necessary commands.
   - Create the GitHub Release with `gh release create <tag> --title <title> --notes-file <file>` or the repo's release tool.
   - Mark pre-releases or drafts consistently with the requested version and existing practice.

9. Report the result.
   - Include the version, tag, release URL if available, commit pushed, and verification outcome.
   - If publication was not completed, state exactly what remains and the next command the user can approve or run.

## Command Preferences

- Use `rg`/`rg --files` for discovery.
- Use `gh` for GitHub release operations when installed and authenticated.
- Use non-interactive commands. Avoid interactive git or release tooling unless no non-interactive alternative exists.
- Use temp files for release notes when passing multi-line text to commands.
- Avoid destructive git operations. Never use `git reset --hard`, `git checkout -- <file>`, forced pushes, or tag deletion unless the user explicitly requests that specific operation.

## Versioning Heuristics

- Prefer the project's declared release policy over generic SemVer.
- If SemVer appears to be used:
  - Patch: bug fixes, docs corrections, dependency updates with no intended API change.
  - Minor: backward-compatible features or meaningful improvements.
  - Major: breaking API, CLI, config, schema, or behavior changes.
- If calendar versioning, package-specific schemes, or monorepo per-package versions are present, preserve that scheme.

## GitHub Release Notes

When the repo lacks a release notes template, use this compact structure:

```markdown
## What's Changed

- ...

## Verification

- `command`: passed
```

Omit empty sections. Include breaking changes prominently near the top when present.

## Failure Handling

- If the working tree is dirty, do not proceed until the release-impacting changes are understood.
- If tests fail, stop before publishing and summarize the failing command and relevant output.
- If authentication is missing for `gh`, explain the required login command and continue with local preparation only.
- If a tag already exists, inspect it and the matching release before deciding whether the request is already complete or needs a new version.
