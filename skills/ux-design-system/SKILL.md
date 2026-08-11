---
name: ux-design-system
description: Comprehensive UX/UI design system covering premium design patterns, brand consistency, visual storytelling, design reviews, and delightful micro-interactions. Use for holistic design system creation, brand-aligned UI work, or adding personality to interfaces.
user-invocable: false
---

# UX Design System

Holistic design system expertise combining premium UX patterns, brand consistency, visual storytelling, and delightful interactions.

## Core Capabilities

1. **Premium UX Design**: Sophisticated interaction patterns, premium visual hierarchy, refined micro-animations
2. **Brand Guardian**: Color palette enforcement, typography adherence, voice/tone consistency
3. **Visual Storytelling**: Hero sections that captivate, data visualization, progressive disclosure
4. **Design Review**: Visual/UX/Brand/Technical review phases
5. **Delightful Micro-Interactions**: Button hover states, loading states, success celebrations

## Design System Components

### Typography Scale
```css
--text-xs: 0.75rem; --text-sm: 0.875rem; --text-base: 1rem;
--text-lg: 1.125rem; --text-xl: 1.25rem; --text-2xl: 1.5rem;
--text-3xl: 1.875rem; --text-4xl: 2.25rem;
```

### Spacing System
```css
--space-1: 0.25rem; --space-2: 0.5rem; --space-3: 0.75rem;
--space-4: 1rem; --space-6: 1.5rem; --space-8: 2rem;
--space-12: 3rem; --space-16: 4rem;
```

### Animation Tokens
```css
--ease-out: cubic-bezier(0, 0, 0.2, 1);
--ease-in-out: cubic-bezier(0.4, 0, 0.2, 1);
--duration-fast: 150ms; --duration-normal: 300ms; --duration-slow: 500ms;
```

## Design Review Checklist

### Visual Audit
- [ ] Consistent spacing using design tokens
- [ ] Typography hierarchy clear
- [ ] Color contrast meets WCAG AA (4.5:1)
- [ ] Visual weight balanced
- [ ] Alignment on grid

### UX Audit
- [ ] Clear user flow
- [ ] Obvious call-to-action
- [ ] Error states designed
- [ ] Loading states present
- [ ] Empty states considered

### Brand Audit
- [ ] Colors from brand palette only
- [ ] Fonts match brand guidelines
- [ ] Tone of voice consistent
- [ ] Imagery style aligned

## Anti-Patterns to Avoid
- Generic stock photography
- Overused gradient combinations
- Excessive animation
- Inconsistent iconography
- Typography without hierarchy
- Colors that don't serve purpose
- Decoration without function
