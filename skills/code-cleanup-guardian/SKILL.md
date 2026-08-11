---
name: code-cleanup-guardian
description: Safely refactor and clean up code without breaking existing functionality. Use when doing any code cleanup, refactoring, formatting, removing dead code, or restructuring files. Prevents regression by enforcing incremental changes and mandatory testing.
user-invocable: false
---

# Code Cleanup Guardian

Core safety protocol is in `~/.claude/rules/code-cleanup-safety.md`. This skill adds tactical guidance.

## Refactoring Assessment

Before starting, classify the cleanup scope:

| Scope | Risk | Approach |
|-------|------|----------|
| Formatting only | Low | Autoformat, single commit, verify no logic diff |
| Rename/move | Medium | Update all references, verify with grep, test |
| Extract function/module | Medium | Ensure identical behavior, compare outputs |
| Change data flow | High | Write characterization tests first, then refactor |
| Remove feature/code path | High | Prove zero references, check feature flags, test |

## Refactoring Workflows

### Extract & Split
1. Identify the boundary (function, class, module)
2. Copy to new location — do NOT cut yet
3. Redirect callers to new location one at a time
4. Test after each caller redirect
5. Remove original only after all callers migrated and tests pass

### Safe Rename
1. `grep -r "oldName" src/` — count all references
2. Rename with IDE refactor tool or find-and-replace
3. `grep -r "oldName" src/` — confirm zero references remain
4. Check string literals, config files, and dynamic references
5. Test

### Dead Code Removal
1. `grep -rn "targetName" --include="*.{ts,tsx,js,jsx,py,php}" .`
2. Check for reflection, dynamic dispatch, or string-based references
3. Check test files — remove test coverage for dead code too
4. Remove in a dedicated commit with clear message

## Recovery Protocol

| Situation | Action |
|-----------|--------|
| Tests fail after one commit | `git revert HEAD` |
| Tests fail after multiple commits | `git log --oneline`, find last green, `git revert HEAD~N..HEAD` |
| Uncertain what broke | `git bisect start`, `git bisect bad`, `git bisect good <known-good>` |
| Everything is broken | `git reset --hard origin/main` (last resort) |
