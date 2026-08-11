---
name: sprint-planner
description: "Break down a project into sprints with atomic, testable tasks as GitHub Issues (plan sprints, decompose tasks, sprint breakdown)."
disable-model-invocation: true
argument-hint: [project-description]
allowed-tools: Bash(gh *), Bash(git *), Read, Grep, Glob
---

# Sprint Decomposition Protocol

## 1. Analyze
- Read existing project docs (CHANGELOG, README, PLAN, PRD)
- Map scope: components, dependencies, risks, unknowns
- Identify what "demoable" means at each increment
- List technical constraints and external dependencies

## 2. Decompose into Sprints
Each sprint:
- Single goal statement and concrete demo criteria
- Produces runnable software building on previous sprint
- Sprint 1 always results in something that runs
- No more than 20 tasks — split if larger
- No "infrastructure-only" sprints — every sprint is demoable

## 3. Atomize into Tasks
Each task:
- 1 commit. 1 purpose. 1 testable outcome.
- Has validation: tests preferred, or explicit manual verification
- Specifies: objective (one sentence), type, dependencies, files affected, validation, commit message
- Types: `feature` | `bugfix` | `refactor` | `test` | `docs` | `config` | `spike`
- If multiple purposes or can't describe in one sentence, split it

## 4. Wire Dependencies
- Explicit, acyclic dependency declarations
- Encoded as GitHub Issue references
- Front-load unknowns and spikes

## 5. Validate Coverage
- [ ] Every requirement maps to at least one task
- [ ] Every task serves a sprint goal (no orphans)
- [ ] Error handling and edge cases have dedicated tasks
- [ ] No task has multiple purposes
- [ ] No task lacks validation criteria
- [ ] No sprint lacks a demoable outcome
- [ ] Dependency graph is acyclic

## 6. Mandatory Subagent Review

Pass the full plan to a subagent:

> Review this sprint plan for: (1) task atomicity, (2) missing tests/validation, (3) dependency correctness, (4) coverage gaps, (5) sprint demoability, (6) ordering — unknowns front-loaded? (7) GitHub Issue structure. Flag as CRITICAL / WARNING / SUGGESTION with specific fixes.

Incorporate all CRITICAL and WARNING items before proceeding.

## 7. Create GitHub Issues

```bash
gh auth status && gh repo view

# Create labels
for label in feat fix refactor test docs config spike chore perf; do
  gh label create "type/$label" --force 2>/dev/null
done
for p in critical high medium low; do
  gh label create "priority/$p" --force 2>/dev/null
done

# Create milestones per sprint, then issues per task
```

## Output
Write the final plan to `docs/[project-name]-sprint-plan.md` containing:
- Project overview and success criteria
- Sprint summary table
- Full task details with GitHub Issue numbers
- Dependency graph (ASCII)
- Risk register
