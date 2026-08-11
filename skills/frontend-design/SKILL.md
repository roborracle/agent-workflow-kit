---
name: frontend-design
description: Create distinctive, production-grade frontend interfaces with high design quality. Use when building web components, pages, applications, React/Vue/Angular components, handling state management, or optimizing frontend performance. Generates creative, polished code avoiding generic AI aesthetics.
argument-hint: [component-or-page-description]
---

# Frontend Design & Development

Create distinctive, production-grade frontend interfaces that avoid generic "AI slop" aesthetics.

## Design Thinking

Before coding, commit to a BOLD aesthetic direction:
- **Purpose**: What problem does this solve? Who uses it?
- **Tone**: Pick an extreme - brutally minimal, maximalist chaos, retro-futuristic, organic/natural, luxury/refined, playful, editorial, brutalist, art deco, soft/pastel, industrial
- **Constraints**: Framework, performance, accessibility requirements
- **Differentiation**: What makes this UNFORGETTABLE?

## Frontend Aesthetics Guidelines

### Typography
- Choose beautiful, unique, interesting fonts
- Avoid generic fonts (Arial, Inter, Roboto)
- Pair distinctive display font with refined body font

### Color & Theme
- Commit to cohesive aesthetic with CSS variables
- Dominant colors with sharp accents outperform timid palettes

### Motion
- Use animations for effects and micro-interactions
- Focus on high-impact moments: orchestrated page loads with staggered reveals
- Scroll-triggering and surprising hover states

### Spatial Composition
- Unexpected layouts, asymmetry, overlap, diagonal flow
- Grid-breaking elements
- Generous negative space OR controlled density

### Backgrounds & Visual Details
- Create atmosphere and depth, not solid colors
- Gradient meshes, noise textures, geometric patterns
- Layered transparencies, dramatic shadows, decorative borders

## Tailwind CSS Enforcement

**MANDATORY**: Use ONLY Tailwind utility classes for styling.

```tsx
// ✅ CORRECT
<div className="flex items-center justify-between p-4 bg-white rounded-lg shadow-md">

// ❌ FORBIDDEN - Inline styles
<div style={{ padding: '16px' }}>

// ❌ FORBIDDEN - CSS-in-JS
const StyledDiv = styled.div`padding: 16px;`
```

## Performance Targets
```yaml
Core Web Vitals:
  LCP: < 2.5s
  FID: < 100ms
  CLS: < 0.1
  INP: < 200ms
Bundle: Initial JS < 100KB gzipped
Runtime: 60fps animations
```

## Accessibility (WCAG 2.1 AA)
- Semantic HTML structure
- ARIA labels and roles
- Keyboard navigation
- Color contrast validation (4.5:1)

## NEVER Use
- Generic fonts (Inter, Roboto, Arial, system fonts)
- Cliched color schemes (purple gradients on white)
- Predictable layouts and component patterns
- Cookie-cutter design lacking context-specific character

## Additional Resources

- For design tokens (typography scale, spacing system, animation tokens, color strategy, breakpoints), see [reference/design-tokens.md](reference/design-tokens.md)
