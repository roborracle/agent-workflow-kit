---
name: git-commit-helper
description: Create properly formatted, detailed commit messages following Conventional Commits specification. Use when committing changes, preparing commits, or when user needs help with commit message best practices.
user-invocable: false
---

# Git Commit Helper

Create clear, detailed commit messages following Conventional Commits specification.

## Commit Message Format
```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

## Commit Types
| Type | Use For |
|------|---------|
| `feat` | New features |
| `fix` | Bug fixes |
| `docs` | Documentation changes |
| `style` | Code style (formatting, semicolons) |
| `refactor` | Code refactoring without feature changes |
| `perf` | Performance improvements |
| `test` | Adding or updating tests |
| `chore` | Maintenance tasks |
| `build` | Build system or dependency changes |
| `ci` | CI configuration changes |
| `revert` | Reverting previous commits |

## Analysis Workflow
1. Check staged changes: `git diff --staged`
2. Review recent commits for style: `git log --oneline -10`
3. Analyze: What changed? Why? Impact on users? Breaking changes? Related issues?

## Message Guidelines
- Subject line under 50 characters
- Use imperative mood ("Add feature" not "Added feature")
- Separate subject from body with blank line
- Wrap body at 72 characters
- Explain what and why, not how

## Examples
```
feat(auth): add JWT token validation

Implement token validation middleware for protected routes.
Tokens expire after 24 hours and require refresh.

Closes #123
```

```
feat(api)!: change user endpoint response format

BREAKING CHANGE: User endpoint now returns nested address object
instead of flat address fields.

Closes #789
```

## Pre-Commit Checklist
- [ ] Changes are staged (`git add`)
- [ ] Tests pass
- [ ] Linting passes
- [ ] Type checking passes
- [ ] Commit message follows format
- [ ] Related issues referenced

## Additional Resources

- For detailed commit message examples (features, fixes, breaking changes, refactors, performance), see [examples/commit-messages.md](examples/commit-messages.md)
