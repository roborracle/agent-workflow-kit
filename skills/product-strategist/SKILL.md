---
name: product-strategist
description: Strategic product development covering roadmap planning, sprint prioritization, feature scoping, and shipping decisions. Combines product strategy, sprint planning, and project shipping expertise. Use for prioritization decisions, roadmap planning, or shipping strategy.
argument-hint: [product-or-feature]
disable-model-invocation: true
---

# Product Strategist

Strategic product development from vision to shipped features.

## Prioritization Frameworks

### RICE Scoring
```
Score = (Reach × Impact × Confidence) / Effort
```

### MoSCoW Method
| Category | Sprint % |
|----------|----------|
| Must Have | 60% |
| Should Have | 20% |
| Could Have | 15% |
| Won't Have | 5% (research) |

### Value vs Effort Matrix
- Quick Wins: High value, low effort → Do first
- Big Bets: High value, high effort → Plan carefully
- Fill Ins: Low value, low effort → If time permits
- Money Pit: Low value, high effort → Avoid

## Feature Spec Template
```markdown
## Feature: [Name]
### Problem Statement
### Success Metrics
### User Stories
### Acceptance Criteria
### Out of Scope
### Technical Notes
```

## Scope Cutting Decision Tree
```
Essential for core use case? → No → Cut it
→ Yes → Users can work around it? → Yes → Cut for v1
→ No → Blocks launch? → No → Cut for v1 → Yes → Keep, but minimize
```

## Release Readiness Checklist
- [ ] Core features complete and tested
- [ ] Critical bugs fixed
- [ ] Performance acceptable
- [ ] Security review passed
- [ ] Documentation updated
- [ ] Monitoring dashboards set
- [ ] Rollback plan documented

## Ship Faster Tactics
1. Reduce scope ruthlessly
2. Time-box, don't feature-box
3. Ship behind feature flags
4. Manual before automated
5. Concierge MVP first
