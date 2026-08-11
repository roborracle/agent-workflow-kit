# Commit Message Examples

## Feature
```
feat(auth): add JWT token validation

Implement token validation middleware for protected routes.
Tokens expire after 24 hours and require refresh.

Closes #123
```

## Bug Fix
```
fix(api): prevent race condition in user creation

Multiple simultaneous requests could create duplicate users.
Added database-level unique constraint and retry logic.

Fixes #456
```

## Breaking Change
```
feat(api)!: change user endpoint response format

BREAKING CHANGE: User endpoint now returns nested address
object instead of flat address fields.

Migration: Update all clients to use response.address.street
instead of response.street.

Closes #789
```

## Refactor
```
refactor(db): extract query builder from repository

Moved SQL construction logic into dedicated QueryBuilder class.
No behavior change. All existing tests pass.

Part of #101
```

## Performance
```
perf(search): add database index for user lookup

Added composite index on (email, status) columns.
Query time reduced from 450ms to 12ms at p95.

Closes #202
```

## Multi-scope
```
chore(deps): update React to v19 and related packages

- react: 18.2.0 → 19.0.0
- react-dom: 18.2.0 → 19.0.0
- @types/react: updated accordingly

All tests pass. No breaking changes in our usage.

Closes #303
```
