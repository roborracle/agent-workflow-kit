# Database Design Patterns

## Schema Conventions
- Primary keys: UUID v4 (not auto-increment)
- Audit columns on every table: `created_at`, `updated_at`, `deleted_at` (soft delete)
- Normalize to 3NF, denormalize deliberately for read performance
- Foreign keys with appropriate ON DELETE behavior

## Index Strategy
```sql
-- Simple index for frequent lookups
CREATE INDEX idx_users_email ON users(email);

-- Composite for multi-column queries (order matters)
CREATE INDEX idx_orders_user_status ON orders(user_id, status);

-- Partial index for subset queries
CREATE INDEX idx_active_users ON users(email) WHERE deleted_at IS NULL;

-- Covering index (includes all needed columns)
CREATE INDEX idx_users_lookup ON users(email) INCLUDE (name, role);
```

## Common Patterns

### Soft Deletes
```sql
ALTER TABLE users ADD COLUMN deleted_at TIMESTAMP NULL;
-- Query: WHERE deleted_at IS NULL
```

### Polymorphic Associations
```sql
CREATE TABLE comments (
  id UUID PRIMARY KEY,
  commentable_type VARCHAR(50),  -- 'post', 'page', 'product'
  commentable_id UUID,
  body TEXT
);
CREATE INDEX idx_comments_poly ON comments(commentable_type, commentable_id);
```

### JSON Columns (for flexible attributes)
```sql
ALTER TABLE products ADD COLUMN metadata JSONB DEFAULT '{}';
CREATE INDEX idx_products_metadata ON products USING GIN(metadata);
```

### Materialized Views (for expensive aggregations)
```sql
CREATE MATERIALIZED VIEW daily_stats AS
SELECT date_trunc('day', created_at) as day, count(*) as total
FROM orders GROUP BY 1;

-- Refresh periodically
REFRESH MATERIALIZED VIEW CONCURRENTLY daily_stats;
```

## Anti-Patterns to Avoid
- N+1 queries (use JOINs or eager loading)
- Unbounded queries (always LIMIT)
- Missing indexes on foreign keys
- Over-indexing (each index slows writes)
- Storing computed values without refresh strategy
