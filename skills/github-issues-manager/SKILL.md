---
name: github-issues-manager
description: Automatically create GitHub issues for every quantifiable task during planning and development. Use when breaking down features, planning sprints, organizing work, or any time work needs to be tracked.
argument-hint: [feature-or-task-description]
allowed-tools: Bash(gh *), Bash(git *), Read, Grep, Glob
---

# GitHub Issues Manager

Ensure every unit of work has a trackable GitHub issue with proper labels, acceptance criteria, and relationships.

## Issue Creation Protocol

**Before creating issues, gather context:**
```bash
gh repo view                    # Verify repository
gh milestone list               # Check existing milestones
gh label list                   # Review label taxonomy
```

**For each quantifiable task, create an issue:**
```bash
gh issue create \
  --title "[TYPE] Brief description" \
  --body "$(cat <<EOF
## Description
[What needs to be done]

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Context
[Why this is needed, related features]

## Technical Notes
[Implementation hints, gotchas]

## Related
- Depends on: #XX
- Blocks: #YY
- Part of: #ZZ
EOF
)" \
  --label "type/[TYPE]" \
  --label "priority/[PRIORITY]" \
  --milestone "[MILESTONE]"
```

## Issue Types

| Type | Use For |
|------|---------|
| `feat` | New feature or enhancement |
| `fix` | Bug fix |
| `refactor` | Code improvement without behavior change |
| `docs` | Documentation only |
| `test` | Test coverage |
| `chore` | Maintenance, dependencies |
| `perf` | Performance improvement |

## Priority Labels

- `priority/critical` - Blocking release
- `priority/high` - Important for sprint
- `priority/medium` - Should do soon
- `priority/low` - Nice to have

## Batch Issue Creation

When breaking down a feature into multiple issues:

```bash
# Create parent epic/feature issue first
PARENT=$(gh issue create --title "[feat] Feature Name" --body "..." --label "type/epic")

# Create child issues referencing parent
gh issue create --title "[feat] Subtask 1" --body "Part of $PARENT\n\n..."
gh issue create --title "[feat] Subtask 2" --body "Part of $PARENT\n\n..."
```

## Decision Examples

| User Request | Issues to Create |
|-------------|-----------------|
| "Add dark mode support" | 1. [feat] Add dark mode toggle (#1), 2. [feat] Create dark color palette (#2), 3. [feat] Update components (#3), 4. [test] Visual regression tests (#4), 5. [docs] Document theming (#5) |
| "Fix login on Safari" | 1. [fix] Investigate Safari login failure (#10), 2. [fix] Implement Safari-compatible auth (#11), 3. [test] Add Safari to E2E matrix (#12) |

## Rules

1. **One issue per deployable unit** - If it can be merged independently, it's one issue
2. **Clear acceptance criteria** - Anyone should verify completion
3. **Link everything** - Issues, PRs, commits reference each other
4. **Update, don't abandon** - If scope changes, update the issue
5. **Close with context** - Note what was done when closing
6. **Create issues BEFORE starting implementation**

## Additional Resources

- For issue creation templates (standard, epic, bug report), see [templates/issue-template.md](templates/issue-template.md)
