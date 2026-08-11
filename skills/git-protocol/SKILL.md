---
name: git-protocol
description: "Audit git workflow compliance including branch architecture, commit standards, issue linkage, and production readiness (check git compliance, audit branches, git hygiene)."
disable-model-invocation: true
context: fork
agent: general-purpose
argument-hint: [branches|commits|issues|prod-check|hygiene]
allowed-tools: Bash(git *), Bash(gh *), Read, Grep, Glob
---

# Git Protocol Enforcement

Audit scope: $ARGUMENTS (blank = full audit)

## Pre-fetched State

### All Branches
!`git branch -a 2>/dev/null || echo "Not a git repository"`

### Current Branch
!`git branch --show-current 2>/dev/null`

### Last 20 Commits
!`git log --oneline -20 2>/dev/null`

### Open Issues
!`gh issue list --state open --limit 20 --json number,title,labels 2>/dev/null | jq -r '.[] | "#\(.number): \(.title)"' 2>/dev/null || echo "No GitHub CLI or repo"`

### Tracked .env Files
!`git ls-files 2>/dev/null | grep -E "\.env" || echo "None tracked"`

---

## Your Task

Using the pre-fetched data above, run a comprehensive audit:

### Phase 1: Branch Architecture
- Verify `main` and `prod` branches exist
- Validate all branch names follow `feature/*` or `hotfix/*` convention
- Flag non-standard names

### Phase 2: Commit Standards
- Check each of the last 20 commits against conventional format: `type(scope): description`
- Valid types: feat, fix, docs, style, refactor, perf, test, chore, build, ci, revert
- Flag commits without issue references (#N)

### Phase 3: Issue Linkage
- Identify commits without issue references
- Check for orphaned issues (no linked commits)

### Phase 4: Production Readiness
Scan for violations:
```bash
grep -rn --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" --include="*.py" --include="*.go" --include="*.rs" \
  -E "console\.(log|debug|info|warn|error)|debugger" src/ 2>/dev/null || echo "None found"
grep -rn --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" --include="*.py" --include="*.go" --include="*.rs" \
  -E "(TODO|FIXME|NOTE|HACK|XXX):" src/ 2>/dev/null || echo "None found"
find src/ -name "*.test.*" -o -name "*.spec.*" 2>/dev/null || echo "None found"
```

### Phase 5: Branch Hygiene
- Stale branches (14+ days no activity)
- Merged branches that can be deleted
- Branches without upstream tracking

### Generate Compliance Report

| Area | Check | Status |
|------|-------|--------|
| Branches | Core branches exist | OK/FAIL |
| Branches | Naming convention | X violations |
| Commits | Conventional format | X/20 compliant |
| Commits | Issue references | X/20 linked |
| Issues | Open count | X |
| Prod | Debug statements | X found |
| Prod | TODO comments | X found |
| Hygiene | Stale branches | X |
| Hygiene | Merged (deletable) | X |

**Overall compliance: X%**
