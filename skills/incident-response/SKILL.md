---
name: incident-response
description: Handle production incidents with structured triage, communication, and blameless postmortems. Covers severity classification, rollback decisions, stakeholder updates, and follow-up issue creation.
disable-model-invocation: true
argument-hint: [severity-or-description]
allowed-tools: Read, Grep, Glob, Bash(git *), Bash(gh *)
---

# Incident Response & Postmortem

## Severity Classification

| Severity | Impact | Response Time | Examples |
|----------|--------|--------------|---------|
| **SEV-1** | Service down, data loss, security breach | Immediate | Production database unreachable, auth bypass, data corruption |
| **SEV-2** | Major feature broken, significant user impact | < 1 hour | Payments failing, login broken for subset of users |
| **SEV-3** | Minor feature degraded, workaround exists | < 4 hours | Slow search, email notifications delayed |
| **SEV-4** | Cosmetic, minimal impact | Next business day | UI glitch, non-critical log errors |

## Incident Response Protocol

### Phase 1: Assess (first 5 minutes)
1. What is broken? (symptom, not cause)
2. Who is affected? (all users, subset, internal only)
3. When did it start? (check monitoring, recent deployments)
4. What changed recently? (`git log --oneline -10`, recent deploys)

### Phase 2: Decide — Fix Forward or Roll Back
```
Was there a recent deployment?
├── Yes → Does reverting the deploy fix the issue?
│   ├── Yes → ROLL BACK immediately
│   └── No → Fix forward (the deploy isn't the cause)
└── No → Fix forward (investigate root cause)
```

**Rollback command:**
```bash
# Revert to last known good
git checkout prod
git revert HEAD
git push origin prod
# Deploy the reverted version
```

### Phase 3: Mitigate
- Apply the smallest change that stops the bleeding
- This is NOT the final fix — it's a bandage
- Accept technical debt temporarily to restore service

### Phase 4: Communicate
**Status update template:**
```
[INCIDENT] [SEV-X] [Service Name]

Status: Investigating | Identified | Monitoring | Resolved
Impact: [who is affected and how]
Start time: [when it began]
Current action: [what we're doing right now]
Next update: [when to expect the next update]
```

### Phase 5: Resolve and Verify
- Confirm the fix resolves the root cause (not just the symptom)
- Monitor for recurrence (15 min, 1 hour, 24 hours)
- Mark incident as resolved only after monitoring period

## Blameless Postmortem

After resolution, conduct a blameless postmortem within 48 hours. Use the [postmortem template](templates/postmortem-template.md).

## Rules
- Never blame individuals — focus on systems and processes
- Every postmortem produces at least 2 action items with GitHub Issues
- Action items must have owners and deadlines
- Share postmortems with the team — learning is the goal
