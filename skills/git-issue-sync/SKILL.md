---
name: git-issue-sync
description: "Audit git history against GitHub Issues to find untracked work and ensure compliance (sync issues, find untracked commits, issue compliance)."
disable-model-invocation: true
context: fork
agent: general-purpose
allowed-tools: Bash(git *), Bash(gh *), Read, Grep, Glob
---

# Git Issue Compliance Audit

## Pre-fetched State

### Working Directory
!`git status --porcelain 2>/dev/null || echo "Not a git repository"`

### Last 20 Commits
!`git log --oneline -20 2>/dev/null`

### Open Issues
!`gh issue list --state open --limit 50 --json number,title,labels 2>/dev/null || echo "No GitHub CLI or repo"`

### Recently Closed Issues
!`gh issue list --state closed --limit 20 --json number,title,closedAt 2>/dev/null || echo "None"`

### Open PRs
!`gh pr list --state open 2>/dev/null || echo "None"`

### All Branches
!`git branch -a 2>/dev/null`

---

## Your Task

Using the pre-fetched data above:

### 1. Find Untracked Work
- Identify commits that don't reference an issue number (#N)
- Identify modified files with no associated issue
- Flag commits missing conventional format

### 2. Create Missing Issues
For every untracked piece of work, create an issue:
```bash
gh issue create \
  --title "[TYPE] Description" \
  --body "## Description\n[What was done]\n\n## Commits\n- SHA: [description]" \
  --label "type/[TYPE]"
```

### 3. Update Existing Issues
- Add progress comments to open issues related to current work
- Close completed issues with `gh issue close N -c "..."`
- Link commits to issues retroactively in comments

### 4. PR Audit
- Every open PR must reference an issue via `Closes #N` or `Fixes #N`
- Flag PRs without linked issues

### 5. Branch Hygiene
- Orphaned branches without associated issues
- Branches with no activity in 14+ days
- Names not following `feature/` or `hotfix/` convention

### 6. Report
- Total work items identified
- Issues created this session
- Issues updated
- Non-compliant commits (no issue reference)
- PR linkage status
- Compliance score (%)

Push all issue updates to GitHub immediately.
