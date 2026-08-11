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

## Tech Stack Selection (Speed Priority)

### Web
| Stack | Time to MVP | Best For |
|-------|-------------|----------|
| Next.js + Vercel | 1-2 days | Full-stack web apps |
| Remix + Fly.io | 1-2 days | Data-heavy apps |
| Astro | < 1 day | Content sites |

### Backend Services
| Stack | Time to MVP | Best For |
|-------|-------------|----------|
| Supabase | Hours | Auth + DB + API |
| Firebase | Hours | Real-time + Auth |
| PocketBase | Hours | Self-hosted simple |

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
