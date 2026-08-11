---
name: api-client
description: Integrate with third-party APIs and webhooks. Covers authentication flows (OAuth, API keys, JWT), retry strategies, circuit breakers, rate limiting, webhook verification, and integration testing patterns.
user-invocable: false
---

# API Integration Client

## Integration Architecture

### Client Structure
Every third-party integration should follow this layered pattern:

```
Transport Layer    → HTTP client with retry, timeout, circuit breaker
Auth Layer         → Token management, refresh, key rotation
API Layer          → Typed methods per endpoint
Error Mapping      → External errors → internal domain errors
```

### HTTP Client Configuration
```typescript
const client = {
  baseURL: config.API_BASE_URL,
  timeout: 10_000,              // 10s default, override per endpoint
  retries: 3,                   // Only on 5xx and network errors
  retryDelay: (attempt) =>      // Exponential backoff with jitter
    Math.min(1000 * 2 ** attempt + Math.random() * 1000, 30_000),
  headers: {
    'User-Agent': 'MyApp/1.0',
    'Accept': 'application/json',
  },
};
```

## Authentication Patterns

### API Key
```typescript
// Header-based (preferred)
headers: { 'Authorization': `Bearer ${config.API_KEY}` }
// or
headers: { 'X-API-Key': config.API_KEY }
```

### OAuth 2.0 Client Credentials
Fetch token with client_id/client_secret, cache with buffer before expiry. See [reference/integration-patterns.md](reference/integration-patterns.md) for full implementation.

### HMAC Webhook Signature Verification
Use `crypto.timingSafeEqual` to compare HMAC-SHA256 digests. See [reference/integration-patterns.md](reference/integration-patterns.md).

## Resilience Patterns

### Circuit Breaker
Three states: CLOSED (normal) → OPEN (reject all) → HALF-OPEN (probe). Open after 5 failures in 60s, cooldown 30s. See [reference/integration-patterns.md](reference/integration-patterns.md).

### Rate Limit Handling
Read `x-ratelimit-remaining` and `x-ratelimit-reset` headers. On 429, respect `Retry-After`. See [reference/integration-patterns.md](reference/integration-patterns.md).

### Idempotency Keys
For non-idempotent operations, include `Idempotency-Key: {userId}-{operationId}-{timestamp}` header.

## Error Mapping
```typescript
function mapExternalError(status: number, body: unknown): AppError {
  switch (status) {
    case 400: return new ValidationError('Invalid request to upstream', { upstream: body });
    case 401: return new AuthError('Upstream authentication failed');
    case 404: return new NotFoundError('Upstream resource not found');
    case 429: return new RateLimitError('Upstream rate limit exceeded');
    default:  return new UpstreamError(`Upstream returned ${status}`, { status, body });
  }
}
```

## Integration Testing
- Record real API responses as fixtures (sanitize secrets)
- Replay fixtures in tests — never hit live APIs in CI
- Test error paths: timeout, 5xx, rate limit, malformed response
- Test auth token refresh flow
- Verify idempotency key handling
