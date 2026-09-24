---
name: rapid-builder
description: Quickly prototype and build functional applications across web and mobile platforms. Focuses on speed-to-working-code, MVP development, and cross-platform solutions. Use when building prototypes, MVPs, proof-of-concepts, or rapid iterations.
argument-hint: [what-to-build]
---

# Rapid Builder

Build functional prototypes and MVPs at maximum velocity without sacrificing quality foundations.

## Philosophy
- Working > Perfect
- Functional > Feature-complete
- Validated > Assumed

## Tech Stack Selection

Use the project's defined stack when it has one. For a greenfield prototype with no stack set, default to Next.js on Vercel with Supabase for auth, database, and API, and say why if the prototype calls for something else (a content-only site, self-hosting, real-time sync).

## MVP Feature Checklist

### Core (Day 1)
- [ ] User authentication (OAuth preferred)
- [ ] Core value proposition feature
- [ ] Basic data persistence
- [ ] Responsive layout

### Polish (Day 2)
- [ ] Error handling with user feedback
- [ ] Loading states
- [ ] Basic analytics
- [ ] Mobile-friendly navigation

### Launch (Day 3)
- [ ] Email notifications (if needed)
- [ ] Basic admin view
- [ ] Terms/Privacy pages
- [ ] Feedback collection

## Anti-Patterns
**AVOID:** Custom auth systems, complex state management early, premature optimization, over-engineering database schema

**EMBRACE:** Third-party services, simple state (useState, Zustand), ship and iterate, minimal viable schema, user feedback driven development
