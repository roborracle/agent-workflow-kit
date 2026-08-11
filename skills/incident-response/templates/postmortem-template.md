# Postmortem: [Incident Title]

**Date:** YYYY-MM-DD
**Severity:** SEV-X
**Duration:** X hours Y minutes
**Impact:** [users affected, revenue impact, data impact]
**Authors:** [who wrote this]

## Timeline (all times in UTC)

| Time | Event |
|------|-------|
| HH:MM | First alert / user report |
| HH:MM | Investigation started |
| HH:MM | Root cause identified |
| HH:MM | Mitigation applied |
| HH:MM | Service restored |
| HH:MM | Monitoring confirmed stable |

## Root Cause

[Technical explanation of what failed and why. Be specific.]

## Contributing Factors

- [Factor 1 — e.g., missing monitoring for this failure mode]
- [Factor 2 — e.g., no integration test for this path]
- [Factor 3 — e.g., documentation gap]

## What Went Well

- [e.g., Alert fired within 2 minutes]
- [e.g., Rollback procedure worked cleanly]

## What Went Poorly

- [e.g., Took 30 minutes to identify root cause]
- [e.g., No runbook for this scenario]

## Action Items

| Action | Owner | Priority | Issue |
|--------|-------|----------|-------|
| Add monitoring for X | | P1 | #NNN |
| Write runbook for Y | | P2 | #NNN |
| Add integration test for Z | | P2 | #NNN |
