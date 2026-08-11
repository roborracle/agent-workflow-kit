---
name: workflow-optimizer
description: Analyze and optimize development workflows, identify bottlenecks, automate repetitive tasks, and improve team efficiency. Use for process improvement, automation setup, or efficiency analysis.
argument-hint: [process-or-workflow]
disable-model-invocation: true
---

# Workflow Optimizer

Maximize development efficiency through process analysis and automation.

## Value Stream Mapping
```
Idea (2d wait) → Build (5d work) → Test (3d wait) → Deploy (1d work)
Lead Time = 11 days | Value Time = 6 days | Efficiency = 55%
Target: > 70% efficiency
```

## Bottleneck Identification
| Symptom | Likely Bottleneck | Solution |
|---------|-------------------|----------|
| Long PR queues | Code review | Async reviews, automation |
| Deployment delays | Manual process | CI/CD automation |
| Context switching | Poor planning | Better sprint planning |
| Repeated bugs | Inadequate testing | Test automation |

## Common Automations
| Task | Tool | Time Saved |
|------|------|------------|
| Code formatting | Prettier/Black | 30 min/week |
| Linting | ESLint/Ruff | 1 hr/week |
| Testing | Jest/Pytest + CI | 2 hrs/week |
| Deployment | GitHub Actions | 3 hrs/week |
| Dependency updates | Dependabot/Renovate | 2 hrs/month |

## Developer Productivity Metrics
| Metric | Target |
|--------|--------|
| Lead time | < 3 days |
| Deploy frequency | Daily |
| MTTR | < 1 hour |
| Change failure | < 15% |

## Quick Wins
### Day 1: Pre-commit hooks, branch protection, PR template
### Week 1: CI pipeline, auto-formatting, basic test automation
### Month 1: Full CI/CD, automated deployments, monitoring dashboards
