---
description: Security requirements for all projects.
globs: *
alwaysApply: true
---

# Security

- Validate all external inputs at boundaries. Sanitize before storing/processing.
- Parameterized queries only — never concatenate SQL.
- Secrets in environment variables only. Never commit `.env`, keys, passwords, or tokens.
- Every person uses their own credentials for every service. Shared accounts and shared API
  keys have no audit trail, can't be revoked individually, and make offboarding a guess. If a
  service can't issue per-person credentials, that's a finding — raise it.
- Enforced locally by `hooks/block-secret-commit.sh`, which refuses any `git commit` that stages
  a file matching a known secret pattern. The hook is a backstop, not a strategy — keep secrets
  out of the working tree in the first place.
- Authenticate at API gateway. Validate tokens server-side. Use RLS where applicable.
- Log security events (auth failures, rate limits). Never log sensitive data.
- Fail securely — errors must not reveal system internals. Specific exceptions with context.
