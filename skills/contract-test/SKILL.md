---
name: contract-test
description: Detect breaking API changes before merge. Covers response shape validation, backward compatibility checks, deprecation workflows, and consumer-driven contract testing patterns.
user-invocable: false
---

# Contract Testing & API Compatibility

## Breaking Change Detection

### What Constitutes a Breaking Change
| Change | Breaking? | Safe Alternative |
|--------|-----------|-----------------|
| Remove a field from response | Yes | Deprecate first, remove after grace period |
| Rename a field | Yes | Add new field, keep old one, deprecate old |
| Change field type (string → number) | Yes | Add new field with new type |
| Change field from optional to required | Yes | Keep optional, validate in business logic |
| Add a new optional field | No | Safe to add anytime |
| Add a new required field to request | Yes | Make it optional with a default |
| Change error response format | Yes | Version the error format |
| Remove an endpoint | Yes | Return 410 Gone with migration guide |
| Change URL path | Yes | Keep old path as redirect/alias |

### Pre-Merge Compatibility Check

Before merging any API change:

1. **Diff response types** — Compare before/after TypeScript types or JSON schemas
2. **Check all consumers** — grep for endpoint usage across services and client apps
3. **Run contract tests** — verify existing consumers still work with new response shape
4. **Check generated clients** — if using OpenAPI codegen, regenerate and check for compile errors

### Response Shape Validation
```typescript
// Define the contract as a schema
const UserResponseSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  name: z.string(),
  createdAt: z.string().datetime(),
  // Optional fields can be added without breaking
  avatar: z.string().url().optional(),
});

// Validate in integration tests
test('GET /users/:id returns valid response shape', async () => {
  const response = await api.get('/users/test-id');
  const result = UserResponseSchema.safeParse(response.data);
  expect(result.success).toBe(true);
});
```

## Deprecation Workflow

### Timeline
```
Week 0:  Add deprecation header + docs
         Sunset-Deprecation: true
         Sunset: {SUNSET_DATE}

Week 1-4: Monitor usage of deprecated endpoint/field
          Log warnings when deprecated features are accessed

Week 4:  Contact remaining consumers directly

Week 8:  Remove deprecated feature (or extend if consumers remain)
```

### Deprecation Header Pattern
```typescript
// Add to deprecated endpoints
res.setHeader('Deprecation', 'true');
res.setHeader('Sunset', '{SUNSET_DATE}');
res.setHeader('Link', '</api/v2/users>; rel="successor-version"');
```

## Consumer-Driven Contract Testing

### Provider Side (API)
```typescript
// Contract test: verify the API still satisfies consumer expectations
describe('User API Contract', () => {
  it('returns fields that Consumer A depends on', async () => {
    const response = await request(app).get('/api/users/1');
    // Consumer A uses: id, email, name
    expect(response.body).toHaveProperty('id');
    expect(response.body).toHaveProperty('email');
    expect(response.body).toHaveProperty('name');
    expect(typeof response.body.id).toBe('string');
    expect(typeof response.body.email).toBe('string');
  });
});
```

### Consumer Side (Client)
```typescript
// Contract test: verify the client handles the expected response shape
describe('User API Client Contract', () => {
  it('correctly parses user response', () => {
    const mockResponse = { id: '123', email: 'test@example.com', name: 'Test' };
    const user = parseUserResponse(mockResponse);
    expect(user.id).toBe('123');
  });
});
```

## API Versioning Strategy

| Strategy | Pros | Cons | When to Use |
|----------|------|------|-------------|
| URL path (`/v1/`, `/v2/`) | Clear, easy to route | URL pollution | Public APIs with long-lived consumers |
| No versioning (evolve in place) | Simplest | Must never break | Internal + careful evolution |

## Rules
- New fields: always optional (additive changes are safe)
- Removed fields: deprecate with sunset date, never remove without warning
- Type changes: add new field, never change existing field type
- Every breaking change must bump the API version
- Contract tests run in CI — failures block merge
