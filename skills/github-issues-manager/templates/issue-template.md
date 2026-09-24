# Issue Template

## Standard Issue
```bash
gh issue create \
  --title "[TYPE] Brief description" \
  --body "$(cat <<EOF
## Description
[What needs to be done and why]

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Technical Notes
[Implementation hints, gotchas, dependencies]

## Related
- Depends on: #XX
- Blocks: #YY
EOF
)" \
  --label "type/[TYPE]" \
  --label "priority/[P0|P1|P2]" \
  --label "area/[AREA]"
```

## Epic/Parent Issue
```bash
PARENT=$(gh issue create --title "[feat] Epic: Feature Name" \
  --body "$(printf '## Overview\n[Feature description]\n\n## Child Issues\n[Will be linked below]')" \
  --label "type/epic")

# Create child issues referencing parent
gh issue create --title "[feat] Subtask 1" --body "Part of $PARENT"
```

## Bug Report
```bash
gh issue create \
  --title "[fix] Bug description" \
  --body "$(cat <<EOF
## Bug Description
[What's happening vs what should happen]

## Steps to Reproduce
1. Step 1
2. Step 2
3. Step 3

## Expected Behavior
[What should happen]

## Actual Behavior
[What happens instead]

## Environment
- Browser/OS:
- Version:
EOF
)" \
  --label "type/bug" \
  --label "priority/P1" \
  --label "area/[AREA]"
```
