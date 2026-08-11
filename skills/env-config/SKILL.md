---
name: env-config
description: Design and manage application configuration across environments. Covers environment variable conventions, startup validation, config parity checks, and .env.example maintenance.
user-invocable: false
---

# Environment & Configuration Manager

## Environment Variable Design

### Naming Convention
```
[APP]_[CATEGORY]_[NAME]

APP_DB_HOST=localhost
APP_DB_PORT=5432
APP_REDIS_URL=redis://localhost:6379
APP_STRIPE_SECRET_KEY=sk_test_...
APP_LOG_LEVEL=info
APP_FEATURE_NEW_CHECKOUT=true
```

### Required vs. Optional
```typescript
// Required — fail fast at startup if missing
const DB_HOST = requireEnv('APP_DB_HOST');

// Optional — use sensible default
const LOG_LEVEL = process.env.APP_LOG_LEVEL || 'info';
const PORT = parseInt(process.env.PORT || '3000', 10);
```

### Startup Validation Pattern
```typescript
function validateConfig(): Config {
  const errors: string[] = [];

  const required = ['DATABASE_URL', 'SESSION_SECRET', 'API_KEY'];
  for (const key of required) {
    if (!process.env[key]) errors.push(`Missing required: ${key}`);
  }

  const port = parseInt(process.env.PORT || '3000', 10);
  if (isNaN(port) || port < 1 || port > 65535) {
    errors.push(`Invalid PORT: ${process.env.PORT}`);
  }

  if (errors.length > 0) {
    console.error('Configuration errors:\n' + errors.map(e => `  - ${e}`).join('\n'));
    process.exit(1);
  }

  return { /* validated config object */ };
}
```

## .env File Management

### .env.example Template
```bash
# Database
APP_DB_HOST=localhost         # Required — local or cloud DB host

# External Services
APP_STRIPE_SECRET_KEY=        # Required — get from Stripe dashboard

# Application
APP_LOG_LEVEL=info            # debug | info | warn | error
```

### Rules
- `.env` is ALWAYS in `.gitignore` — never committed
- `.env.example` is ALWAYS committed — documents all variables
- Every variable in `.env` must exist in `.env.example` (with empty or default value)
- Comments in `.env.example` explain where to get each value
- Mark required vs. optional clearly

## Environment Parity

### Configuration per Environment
| Variable | Development | Staging | Production |
|----------|------------|---------|------------|
| LOG_LEVEL | debug | info | warn |
| API keys | test keys | test keys | production keys |

### Parity Check
Verify staging mirrors production config structure:
- Same env vars defined (different values expected)
- Same services connected (different instances)
- Same feature flags available (different states OK)

## Feature Flags
```typescript
// Simple boolean flags from env vars
const FEATURES = {
  newCheckout: process.env.APP_FEATURE_NEW_CHECKOUT === 'true',
  betaApi: process.env.APP_FEATURE_BETA_API === 'true',
};

// Usage
if (FEATURES.newCheckout) { /* new path */ }
```

## Anti-Patterns
- Hardcoded values that differ between environments (URLs, ports, keys)
- Reading `process.env` deep inside business logic (read at startup, pass as config)
- Environment-specific `if` statements in code (`if (NODE_ENV === 'production')`)
- Secrets in docker-compose.yml, CI config, or Dockerfiles
- Using `NODE_ENV` for anything other than framework behavior
