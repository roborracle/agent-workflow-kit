---
name: survey
description: "Run a project health diagnostic covering git hygiene, dependency security, test health, and stale issues (project health check, run diagnostics, what needs attention)."
disable-model-invocation: true
context: fork
agent: general-purpose
argument-hint: [health|git|tests|security|deps]
allowed-tools: Bash(git *), Bash(gh *), Bash(npm *), Bash(composer *), Read, Grep, Glob
---

# Project Survey — Health Check

## Pre-fetched State

### Git Status
!`git status -sb 2>/dev/null || echo "Not a git repository"`

### Current Branch
!`git branch --show-current 2>/dev/null`

### Recent Commits
!`git log --oneline -5 2>/dev/null`

### Stashes
!`git stash list 2>/dev/null || echo "None"`

### Open GitHub Issues
!`gh issue list --state open --limit 20 2>/dev/null || echo "No GitHub CLI or repo"`

### Dependency Health (Node)
!`npm outdated 2>/dev/null || echo "Not a Node project"`

### Security Audit (Node)
!`npm audit --json 2>/dev/null | jq '.metadata.vulnerabilities' 2>/dev/null || echo "No npm audit available"`

### Dependency Health (PHP)
!`composer outdated --direct 2>/dev/null || echo "Not a PHP project"`

---

## Your Task

Using the pre-fetched data above, also check:

1. **Test Health** — Run the project's test suite and report pass/fail count, coverage, skipped tests
2. **Code Quality** — Find files over 350 lines, count TODO/FIXME markers, find debug statements
3. **Stale Issues** — Flag issues with no activity in 30+ days

Then generate this report:

```
PROJECT HEALTH: [HEALTHY | WARNING | CRITICAL]

Issues:
[Critical items — fix now]
[Warnings — fix soon]
[Suggestions — when convenient]

Recommended next actions:
1. [Most impactful]
2. [Second priority]
3. [Third priority]
```
