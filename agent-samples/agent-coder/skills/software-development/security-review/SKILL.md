---
name: security-review
description: Use to review application changes for common security risks, secret handling, authorization, injection, unsafe file access, and data exposure.
---

# Security Review

Use this skill when code touches auth, permissions, external input, secrets, file access, network calls, payments, or data exposure.

## Checklist

- Authentication and authorization boundaries are enforced server-side.
- User input is validated before use in queries, shells, templates, paths, or redirects.
- Secrets are not logged, committed, sent to clients, or embedded in generated artifacts.
- Error handling does not expose sensitive internals.
- Dependencies and third-party calls are scoped to the minimum needed access.
- Tests or review notes cover the security-sensitive path.
