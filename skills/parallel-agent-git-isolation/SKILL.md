---
name: parallel-agent-git-isolation
description: Use when planning to dispatch 2+ sub-agents that will each perform git operations (add/commit/branch). Mandates worktree isolation or sequential dispatch — never share a working directory + git index across concurrently-committing agents.
---

# Parallel Agent Git Isolation

## The Rule

**Parallel agents that perform git operations MUST use git worktrees (one per agent) OR be dispatched sequentially. Agents that read/write files only (no git ops) may share a working directory; the orchestrator handles the single commit. Never run multiple agents concurrently against a shared git index.**

## Why

Concurrent agents in the same cwd corrupt each other's commits:
- Each agent reads the working tree at `git add` time
- Files written by sibling agents (still uncommitted) leak into the staging set
- Sibling `git reset --soft` calls can orphan in-flight commits
- Result: commits with titles that don't match their tree contents; sometimes whole files disappear (orphaned in reflog only)

## How to Apply

Before dispatching parallel agents, classify their work:

```
Will any agent run git add / git commit / git branch ?
├── No (read/write only) → safe to share cwd; orchestrator commits at end
└── Yes → MUST isolate. Pick one:
    ├── Worktree-per-agent (preferred): invoke superpowers:using-git-worktrees,
    │   give each agent a fresh worktree path
    ├── Sequential dispatch: one at a time, await completion before next
    └── Files-only contract: agents do NOT commit; they only write to disk;
        orchestrator scans output, stages by path, commits in named groups
```

## Recovery (when the race has already happened)

1. `git reflog` — map orphaned SHAs (commits that were reset away)
2. `git show --name-only <sha>` for every recent commit — title may not match content
3. Recover orphaned files from the working tree (they're often still there as untracked)
4. Commit recovered files atomically with corrective titles (`feat(#N): … — content-bearing commit`)
5. Add audit comments on affected GitHub issues mapping content-SHA → issue
6. **Never** `--force`, `--amend`, or rebase a pushed branch to fix the labels. Additive corrective commits + audit comments are the only safe path.

## Reference

This rule exists because the failure is silent. Six parallel agents committing in one shared working directory will interleave `git add` and `git commit` calls, and the result is commits whose message describes work that landed in a *different* commit — plus orphaned changes attributed to nothing. Nothing errors. The branch looks fine. You find out weeks later when you try to revert one change and take three others with it.

Worktrees cost about a second to set up. Use them.
