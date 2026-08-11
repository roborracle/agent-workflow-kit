---
name: changelog-enforcer
description: Ensure mandatory changelog updates accompany every code change. Use to maintain CHANGELOG.md with proper formatting, track user-facing changes, and document releases.
argument-hint: [version-or-period]
disable-model-invocation: true
allowed-tools: Read, Edit, Bash(git *), Bash(gh *), Grep, Glob
---

# Changelog Enforcer

Ensure every user-facing code change includes proper CHANGELOG.md documentation.

## CHANGELOG Format (Keep a Changelog)
```markdown
## [Unreleased]

### Added
- New features

### Changed
- Changes in existing functionality

### Fixed
- Bug fixes

### Security
- Vulnerability fixes
```

## When to Update
**ALWAYS:** New features, bug fixes, API changes, config changes, security patches
**SKIP:** Internal refactoring, test-only changes, docs-only changes, build config

## Entry Format
```markdown
### Added
- Feature description (#issue-number)
```

## Release Process
1. Move [Unreleased] entries to new version section
2. Add release date
3. Create git tag
4. Push tag to trigger release
