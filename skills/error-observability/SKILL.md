---
name: error-observability
description: Implement structured error handling, logging, metrics, and observability. Covers error hierarchies, correlation IDs, log levels, alerting thresholds, and health check endpoints.
user-invocable: false
---

# Error Handling & Observability

## Error Hierarchy Design

### Base Error Structure
```typescript
class AppError extends Error {
  constructor(
    message: string,
    public readonly code: string,        // Machine-readable: "AUTH_TOKEN_EXPIRED"
    public readonly statusCode: number,   // HTTP status: 401
    public readonly isOperational: boolean, // true = expected, false = programmer error
    public readonly context?: Record<string, unknown>
  ) {
    super(message);
    this.name = this.constructor.name;
  }
}
```

### Error Categories
| Category | Retry? | Alert? | Log Level | Example |
|----------|--------|--------|-----------|---------|
| Validation | No | No | warn | Invalid email format |
| Authentication | No | On spike | warn | Expired token |
| Authorization | No | On spike | warn | Insufficient permissions |
| Not Found | No | No | info | Resource doesn't exist |
| Conflict | No | No | warn | Duplicate entry |
| Rate Limit | Yes (backoff) | On threshold | warn | Too many requests |
| Upstream Failure | Yes (circuit breaker) | Yes | error | Third-party API down |
| Internal | No | Yes | error | Null pointer, type error |
| Infrastructure | Yes (limited) | Yes (page) | fatal | Database unreachable |

### Decision Tree: Retry vs. Fail
```
Is the error transient?
├── Yes → Has retry budget remaining?
│   ├── Yes → Retry with exponential backoff (base * 2^attempt + jitter)
│   └── No → Fail with "service temporarily unavailable"
└── No → Is it a client error (4xx)?
    ├── Yes → Return error to client with helpful message
    └── No → Log, alert, return generic 500
```

## Structured Logging

### Log Format (JSON)
```json
{
  "timestamp": "ISO-8601 timestamp",
  "level": "error",
  "message": "Payment processing failed",
  "correlationId": "req-abc123",
  "service": "payment-service",
  "traceId": "trace-xyz789",
  "error": { "code": "PAYMENT_DECLINED", "message": "Card declined by issuer" }
}
```

### Log Level Guidelines
| Level | When | Example |
|-------|------|---------|
| **debug** | Development-only detail | Variable values, query parameters |
| **info** | Normal operations worth recording | Request completed, user logged in, job finished |
| **warn** | Unexpected but handled | Retry succeeded, deprecated API used, rate limit approaching |
| **error** | Failure requiring investigation | Upstream timeout, unhandled rejection, data inconsistency |
| **fatal** | System cannot continue | Database connection lost, out of memory, config missing |

### What to NEVER Log
- Passwords, tokens, API keys, session IDs
- Full credit card numbers, SSNs, or PII
- Request/response bodies containing user data (log a hash or ID instead)
- Conversation or message content

### Correlation IDs
- Generate a unique ID at the entry point (API gateway, message consumer)
- Pass it through every function call, database query, and outgoing HTTP request
- Include it in every log line and error response
- Return it to the client for support reference

## Health Check Endpoints

### Liveness (`/health/live`)
Returns 200 if the process is running. No dependency checks.

### Readiness (`/health/ready`)
Returns 200 only if all critical dependencies are reachable:
```json
{
  "status": "healthy",
  "checks": {
    "database": { "status": "up", "latency_ms": 12 },
    "cache": { "status": "up", "latency_ms": 3 },
    "upstream_api": { "status": "up", "latency_ms": 89 }
  }
}
```

## Alerting Thresholds

| Metric | Warning | Critical | Action |
|--------|---------|----------|--------|
| Error rate (5xx) | > 1% of requests | > 5% of requests | Page on-call |
| Latency (p95) | > 500ms | > 2000ms | Investigate |
| Queue depth | > 1000 | > 10000 | Scale consumers |
| Disk usage | > 80% | > 95% | Expand storage |
| Memory usage | > 85% | > 95% | Investigate leaks |
