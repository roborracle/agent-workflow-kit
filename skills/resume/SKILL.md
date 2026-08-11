---
name: resume
description: "Generate a project briefing showing where you left off with recommended next steps (where was I, pick up, status update, what was I working on)."
disable-model-invocation: true
context: fork
agent: general-purpose
allowed-tools: Bash(git *), Bash(gh *), Read, Grep, Glob
---

# Project Resume — Pick Up Where You Left Off

## Pre-fetched Project State

### Recent Commits
!`git log --oneline --decorate -10 2>/dev/null || echo "Not a git repository"`

### Working Directory
!`git status -sb 2>/dev/null || echo "Not a git repository"`

### Current Branch
!`git branch --show-current 2>/dev/null`

### Stashed Work
!`git stash list 2>/dev/null || echo "No stashes"`

### Recent Branches
!`git branch --sort=-committerdate --format='%(refname:short) (%(committerdate:relative))' 2>/dev/null | head -10`

### Files Changed in Last 24h
!`git log --since="24 hours ago" --name-only --pretty=format: 2>/dev/null | sort -u | grep -v '^$' || echo "None"`

### Open GitHub Issues
!`gh issue list --state open --limit 15 --json number,title,labels,updatedAt --jq '.[] | "#\(.number) \(.title) [\(.labels | map(.name) | join(", "))] (updated: \(.updatedAt | split("T")[0]))"' 2>/dev/null || echo "No GitHub CLI or repo"`

### Open PRs
!`gh pr list --state open --limit 10 2>/dev/null || echo "None"`

### Issues Closed This Week
!`gh issue list --state closed --limit 10 --json number,title,closedAt --jq '.[] | "#\(.number) \(.title) (closed: \(.closedAt | split("T")[0]))"' 2>/dev/null || echo "None"`

---

## Your Task

Using the pre-fetched data above, also scan for in-progress indicators:

```bash
grep -rn "TODO\|FIXME\|HACK\|XXX" src/ app/ --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" --include="*.php" --include="*.py" --include="*.go" --include="*.rs" 2>/dev/null | head -20
grep -rn "WIP\|TEMP\|PLACEHOLDER" src/ app/ --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" --include="*.php" --include="*.py" --include="*.go" --include="*.rs" 2>/dev/null | head -10
```

Also read the project CLAUDE.md and CHANGELOG.md if they exist.

Then generate this briefing:

```
# Project Resume: [PROJECT NAME]
## Generated: [DATE]

## Where We Left Off
[2-3 sentence narrative. What was being worked on? Completed or mid-stream?]

## Current State
- **Branch**: [current branch, clean/dirty]
- **Uncommitted changes**: [yes/no, what files]
- **Stashed work**: [count and descriptions]
- **Open issues**: [count, highlight high-priority]
- **Open PRs**: [count and status]

## Incomplete Work
[WIP items, uncommitted changes, open feature branches, TODOs with file locations]

## Recommended Next Steps
1. **IMMEDIATE** — [unfinished work, failing tests, uncommitted changes]
2. **HIGH** — [open high-priority issues or blocked work]
3. **MEDIUM** — [technical debt, open issues]
4. **LOW** — [improvements, optimizations]

## Quick Start
[Exact commands to resume work]
```

## Rules
- Be specific — file names, issue numbers, branch names
- Prioritize unfinished work over new work
- Uncommitted changes are always priority #1
- Flag anything broken or risky
