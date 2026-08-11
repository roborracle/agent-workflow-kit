---
name: code-reviewer
description: Comprehensive code review from senior engineering perspective following OWASP standards and industry best practices. Use after completing code development, before merging PRs, or when seeking quality assurance feedback.
argument-hint: [file-or-feature]
context: fork
agent: general-purpose
allowed-tools: Read, Grep, Glob, Bash(git diff*), Bash(git log*)
---

# Code Reviewer

Comprehensive code review following "Security-First, Performance-Second" principle.

## Review Phases

### Phase 1: Security Audit (OWASP Top 10)
- SQL Injection and parameterized queries
- Cross-Site Scripting (XSS) vulnerabilities
- Authentication and session management flaws
- Insecure direct object references
- Security misconfiguration
- Sensitive data exposure
- Missing access controls
- CSRF vulnerabilities

### Phase 2: Logic and Correctness
- Algorithm correctness and efficiency
- Edge case handling, null/undefined checks
- Race conditions and concurrency issues
- Resource cleanup and memory management

### Phase 3: Performance Analysis
- Time/space complexity (Big O)
- Database query optimization (N+1 problems)
- Caching opportunities
- Unnecessary re-renders or computations

### Phase 4: Code Quality
- SOLID principle adherence, DRY violations
- Naming conventions and clarity
- Function/class cohesion, cyclomatic complexity
- Documentation completeness

### Phase 5: Testing Coverage
- Unit test coverage and quality
- Integration test scenarios
- Edge case test coverage

## Severity Triage
| Level | Meaning | Action |
|-------|---------|--------|
| 🔴 Critical | Security vulnerabilities or data loss risks | Blocks deployment |
| 🟠 High | Bugs that will cause failures in production | Must fix before merge |
| 🟡 Medium | Performance issues or maintenance concerns | Should address soon |
| 🟢 Low | Code style or minor optimizations | Nice-to-have |

## Issue Format
```
**Severity**: [🔴/🟠/🟡/🟢]
**Location**: `path/to/file.ext:L42-L45`
**Problem**: Clear description
**Impact**: How this affects users or system
**Solution**: Concrete code example
```

## Also Highlight
- Well-implemented patterns
- Good architectural decisions
- Effective use of best practices

## Additional Resources

- For the full review checklist (security, logic, performance, quality, testing), see [reference/review-checklist.md](reference/review-checklist.md)
