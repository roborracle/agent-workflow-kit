---
name: db-migrate
description: Design and execute safe database migrations. Covers schema evolution, zero-downtime patterns, rollback strategies, and data backfills for SQL and NoSQL databases.
argument-hint: [migration-description]
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Database Migration Manager

## Migration Safety Protocol

### Before Writing the Migration
1. **Classify the change** — additive (safe), destructive (dangerous), or transformative (requires expand-contract)
2. **Check table size** — large tables need batched operations to avoid locks
3. **Identify dependencies** — foreign keys, views, triggers, stored procedures that reference the target
4. **Plan rollback** — every migration must have a reverse migration

### Migration Classification

| Type | Risk | Pattern |
|------|------|---------|
| Add column (nullable) | Low | Direct ALTER |
| Add column (NOT NULL + default) | Medium | Add nullable → backfill → set NOT NULL |
| Remove column | High | Expand-contract (stop reading → deploy → drop) |
| Rename column | High | Add new → copy data → update code → drop old |
| Change column type | High | Add new column → backfill with cast → swap |
| Add index | Medium | CREATE INDEX CONCURRENTLY (Postgres) or equivalent |
| Drop table | Critical | Verify zero references → soft-delete first → drop after grace period |

### Zero-Downtime Pattern: Expand-Contract

For any breaking schema change:

**Phase 1 — Expand** (backward compatible)
```sql
-- Add new column, keep old one
ALTER TABLE users ADD COLUMN full_name VARCHAR(255);
```

**Phase 2 — Migrate** (backfill data)
```sql
-- Batch update to avoid table locks
UPDATE users SET full_name = first_name || ' ' || last_name
WHERE full_name IS NULL
LIMIT 1000;
```

**Phase 3 — Transition** (code reads new, writes both)
- Deploy application code that writes to both columns
- Reads from new column with fallback to old

**Phase 4 — Contract** (remove old)
```sql
-- Only after all code uses new column
ALTER TABLE users DROP COLUMN first_name, DROP COLUMN last_name;
```

### Migration File Template
```sql
-- Migration: [description]
-- Author: [name]
-- Date: [date]
-- Reversible: Yes/No
-- Estimated duration: [time on production data size]
-- Lock level: [none/row/table]

-- UP
[migration SQL]

-- DOWN (rollback)
[reverse SQL]

-- VERIFY (post-migration check)
[validation query that confirms success]
```

### Pre-Flight Checklist
- [ ] Migration runs in a transaction (or is idempotent if it cannot)
- [ ] Rollback migration tested
- [ ] No full table locks on tables with >100K rows
- [ ] Indexes created CONCURRENTLY where supported
- [ ] Default values set at application level, not database level (for large tables)
- [ ] Verified on staging with production-sized dataset
- [ ] Backup confirmed before execution

### Anti-Patterns
- Adding NOT NULL without a default on a large table (locks entire table)
- Running data migration in the same transaction as schema migration
- Dropping columns before all code paths stop referencing them
- Using ORM auto-migration in production without reviewing generated SQL
- Assuming migration duration from dev dataset size

### Data Migration Patterns
- **Backfill**: Batch updates with LIMIT/OFFSET, sleep between batches
- **Transform**: ETL pipeline with progress tracking and resumability
- **Seed**: Idempotent INSERT ... ON CONFLICT DO NOTHING
