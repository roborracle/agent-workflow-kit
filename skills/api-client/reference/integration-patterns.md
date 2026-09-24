# API Integration Patterns Reference

## OAuth 2.0 Client Credentials

```typescript
async function getAccessToken(): Promise<string> {
  // Check cache first
  if (cached && cached.expiresAt > Date.now() + 60_000) return cached.token;

  const response = await fetch(tokenUrl, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'client_credentials',
      client_id: config.CLIENT_ID,
      client_secret: config.CLIENT_SECRET,
      scope: 'required-scope',
    }),
  });

  // Cache with buffer before expiry
  cached = { token: data.access_token, expiresAt: Date.now() + data.expires_in * 1000 };
  return cached.token;
}
```

## HMAC Webhook Signature Verification

```typescript
function verifyWebhookSignature(payload: string, signature: string, secret: string): boolean {
  const expected = Buffer.from(crypto.createHmac('sha256', secret).update(payload).digest('hex'));
  const received = Buffer.from(signature);
  // timingSafeEqual throws on unequal lengths; treat that as a mismatch
  return received.length === expected.length && crypto.timingSafeEqual(received, expected);
}
```

## Circuit Breaker States

```
CLOSED (normal) → error threshold exceeded → OPEN (reject all)
OPEN → after cooldown period → HALF-OPEN (allow one probe)
HALF-OPEN → probe succeeds → CLOSED
HALF-OPEN → probe fails → OPEN (reset cooldown)
```

**Thresholds:**
- Open after 5 failures in 60 seconds
- Cooldown: 30 seconds
- Half-open probe: 1 request

## Rate Limit Handling

```typescript
// Read rate limit headers from response
const remaining = parseInt(response.headers['x-ratelimit-remaining']);
const resetAt = parseInt(response.headers['x-ratelimit-reset']) * 1000;

if (remaining === 0) {
  const waitMs = resetAt - Date.now();
  await sleep(waitMs);
}

// On 429: respect Retry-After (RFC 9110: delay-seconds OR an HTTP-date)
if (response.status === 429) {
  const header = response.headers['retry-after'] ?? '';
  const seconds = Number(header);
  const retryAfterMs = Number.isFinite(seconds) && header.trim() !== ''
    ? seconds * 1000
    : Math.max(0, Date.parse(header) - Date.now()) || 1000; // fallback when absent or unparseable
  await sleep(retryAfterMs);
}
```

## Idempotency Keys

For non-idempotent operations (POST, payment processing), generate the key once per logical operation and reuse it on every retry:
```typescript
const idempotencyKey = pendingOperation.idempotencyKey ?? crypto.randomUUID(); // persist with the operation
headers: { 'Idempotency-Key': idempotencyKey }
```
