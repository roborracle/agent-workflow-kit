---
name: pr-workflow
description: "Create a pull request with auto-generated title, body, and linked issues from commit history (create PR, open pull request, submit PR)."
disable-model-invocation: true
context: fork
agent: general-purpose
argument-hint: [base-branch]
allowed-tools: Bash(git *), Bash(gh *), Read, Grep, Glob
---

# Pull Request Workflow

## Pre-fetched Context

### Current Branch
!`git branch --show-current 2>/dev/null`

### Commits on This Branch (vs main)
!`git log main..HEAD --oneline 2>/dev/null || git log origin/main..HEAD --oneline 2>/dev/null || echo "Cannot determine commits vs main"`

### Changed Files
!`git diff main..HEAD --name-only 2>/dev/null || echo "Cannot determine changed files"`

### Diff Stats
!`git diff main..HEAD --stat 2>/dev/null || echo "Cannot determine diff stats"`

### Open Issues Referenced in Commits
!`git log main..HEAD --pretty=format:"%s" 2>/dev/null | grep -oE "#[0-9]+" | sort -u || echo "No issue references found"`

### Uncommitted Changes
!`git status --porcelain 2>/dev/null`

---

## Your Task

Using the pre-fetched data above:

### 1. Pre-flight Checks
- If there are uncommitted changes, warn the user
- If there are no commits vs main, abort with a message
- Verify the branch is pushed to remote: `git push -u origin $(git branch --show-current)`

### 2. Generate PR Content
From the commit history, generate:

**Title**: Under 70 characters, summarizing the change. Use the dominant commit type (feat/fix/refactor).

**Body**:
```markdown
## Summary
[2-3 bullet points describing what changed and why, derived from commit messages]

## Changes
[List of significant files changed with brief explanation]

## Issues
[List of Closes #N / Fixes #N from commit messages]

## Testing
- [ ] All tests passing
- [ ] Type checker passes
- [ ] Linter passes
- [ ] Manual testing completed
```

### 3. Create the PR
```bash
gh pr create --title "title" --body "$(cat <<'EOF'
body content
EOF
)"
```

### 4. Return the PR URL

## Rules
- Always link to issues found in commit messages
- Keep summary concise — the diff tells the full story
- Base branch defaults to `main` unless $ARGUMENTS specifies otherwise
