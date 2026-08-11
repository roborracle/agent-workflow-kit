---
name: system-architect
description: Design scalable backend systems, APIs, databases, and infrastructure. Covers microservices, monoliths, event-driven architecture, caching strategies, and system integration patterns. Use for architectural decisions, system design, API design, or database modeling.
argument-hint: [system-or-component]
---

# System Architect

Design robust, scalable systems with sound architectural principles.

## Architecture Decision Process

### 1. Requirements Gathering
- Functional requirements
- Non-functional requirements (performance, scale, security)
- Constraints (budget, timeline, team skills)
- Integration requirements
- Compliance needs

### 2. Architecture Selection

| Pattern | Best For | Trade-offs |
|---------|----------|------------|
| Monolith | MVPs, small teams | Simple deploy, harder to scale |
| Microservices | Large scale, multiple teams | Complex ops, better scaling |
| Serverless | Event-driven, variable load | Cold starts, vendor lock-in |
| Event-Driven | Async workflows, decoupling | Complexity, eventual consistency |

## API Design Principles

### RESTful API Standards

Standard CRUD endpoints (`GET`, `POST`, `PUT`, `PATCH`, `DELETE`) with nested resources. Consistent response envelope with `data`, `meta`, and `error` fields.

See [reference/api-patterns.md](reference/api-patterns.md) for endpoint conventions, response/error formats, status codes, pagination, and filtering.

## Database Design

### Schema Design Principles
- Normalize to 3NF, denormalize for performance
- Use UUIDs for distributed systems
- Include audit columns (created_at, updated_at)
- Design for query patterns
- Plan for migrations

### Index Strategy & Common Patterns

See [reference/db-patterns.md](reference/db-patterns.md) for index examples (simple, composite, partial, covering), soft deletes, polymorphic associations, JSON columns, and materialized views.

## Scalability Patterns

### Caching Strategy
| Layer | Tool | TTL | Use Case |
|-------|------|-----|----------|
| CDN | Cloudflare | Hours | Static assets |
| Application | Redis | Minutes | Session, computed |
| Database | Query cache | Seconds | Frequent queries |

### Event-Driven Architecture
- Domain Events: Business occurrences (OrderPlaced)
- Integration Events: Cross-service communication
- Command Events: Action requests
- Dead letter queues for failure handling
- Retry with exponential backoff

## Security Architecture
- Authentication at API gateway
- Authorization per endpoint
- Input validation
- Rate limiting
- Encryption in transit (TLS) and at rest
- Audit logging
- Secrets management

## Performance Targets
```yaml
API Response Times:
  p50: < 100ms
  p95: < 500ms
  p99: < 1000ms
Availability: 99.9%
Database Query: < 50ms average
Cache Hit Rate: > 90%
```

## Anti-Patterns to Avoid
- Distributed monolith
- Chatty microservices
- Shared database between services
- Synchronous chains
- Missing circuit breakers
- Unbounded queries
- N+1 database queries

## Additional Resources

- For detailed API design patterns (REST endpoints, response formats, status codes, pagination), see [reference/api-patterns.md](reference/api-patterns.md)
- For database design patterns (indexes, soft deletes, polymorphic associations, materialized views), see [reference/db-patterns.md](reference/db-patterns.md)
