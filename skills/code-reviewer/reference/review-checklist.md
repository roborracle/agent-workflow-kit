# Code Review Checklist

## Security (OWASP Top 10)
- [ ] SQL injection: parameterized queries used
- [ ] XSS: user input sanitized before rendering
- [ ] Authentication: tokens validated server-side
- [ ] Authorization: access controls enforced per-resource
- [ ] CSRF: anti-CSRF tokens for state-changing requests
- [ ] Sensitive data: not logged, not in URLs, not in error messages
- [ ] Security headers: CSP, HSTS, X-Frame-Options
- [ ] Dependencies: no known critical vulnerabilities

## Logic
- [ ] Edge cases handled (null, empty, max values, concurrent access)
- [ ] Error paths return appropriate status codes and messages
- [ ] Business rules correctly implemented per requirements
- [ ] Race conditions addressed in concurrent code
- [ ] Transactions used where atomicity is required

## Performance
- [ ] No N+1 query patterns
- [ ] Appropriate indexes exist for query patterns
- [ ] Large datasets paginated
- [ ] Expensive operations cached where appropriate
- [ ] No unnecessary re-renders (frontend)
- [ ] Bundle size impact considered

## Code Quality
- [ ] Single responsibility per function/class
- [ ] Types on all function signatures
- [ ] No `any`, `object`, or escape hatches without justification
- [ ] Error handling on all external calls
- [ ] No debug statements, commented-out code, or magic numbers
- [ ] Files under 350 lines
- [ ] Naming follows conventions

## Testing
- [ ] Tests exist for new/changed functionality
- [ ] Happy path covered
- [ ] Edge cases covered
- [ ] Error handling tested
- [ ] No flaky test patterns
- [ ] Coverage maintained or improved

## Severity Guide
- CRITICAL (blocks merge): Security vulnerabilities, data loss risk, broken functionality
- HIGH (must fix): Logic errors, missing error handling, performance regressions
- MEDIUM (should fix): Code quality issues, missing tests, unclear naming
- LOW (nice to have): Style preferences, minor optimizations, documentation
