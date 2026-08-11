# Design Token Reference

## Typography Scale
| Token | Size | Line Height | Use |
|-------|------|-------------|-----|
| text-xs | 0.75rem | 1rem | Captions, labels |
| text-sm | 0.875rem | 1.25rem | Secondary text |
| text-base | 1rem | 1.5rem | Body text |
| text-lg | 1.125rem | 1.75rem | Subheadings |
| text-xl | 1.25rem | 1.75rem | Section titles |
| text-2xl | 1.5rem | 2rem | Page subtitles |
| text-3xl | 1.875rem | 2.25rem | Page titles |
| text-4xl | 2.25rem | 2.5rem | Hero text |

## Spacing System
| Token | Value | Use |
|-------|-------|-----|
| space-1 | 0.25rem | Tight inline spacing |
| space-2 | 0.5rem | Related elements |
| space-3 | 0.75rem | Form inputs |
| space-4 | 1rem | Standard padding |
| space-6 | 1.5rem | Card padding |
| space-8 | 2rem | Section spacing |
| space-12 | 3rem | Large gaps |
| space-16 | 4rem | Section separation |

## Animation Tokens
| Token | Value | Use |
|-------|-------|-----|
| ease-smooth | cubic-bezier(0.4, 0, 0.2, 1) | General transitions |
| ease-bounce | cubic-bezier(0.34, 1.56, 0.64, 1) | Playful interactions |
| ease-snap | cubic-bezier(0, 0, 0.2, 1) | Quick responses |
| duration-fast | 150ms | Hovers, color changes |
| duration-normal | 250ms | Standard transitions |
| duration-slow | 400ms | Complex animations |

## Color Strategy
Define as CSS custom properties:
```css
:root {
  --color-primary: ;      /* Main brand color */
  --color-secondary: ;    /* Supporting color */
  --color-accent: ;       /* Sharp accent for CTAs */
  --color-surface: ;      /* Background surfaces */
  --color-text: ;         /* Primary text */
  --color-text-muted: ;   /* Secondary text */
  --color-border: ;       /* Borders and dividers */
  --color-error: ;        /* Error states */
  --color-success: ;      /* Success states */
}
```

## Breakpoints
| Name | Min Width | Use |
|------|-----------|-----|
| sm | 640px | Mobile landscape |
| md | 768px | Tablet |
| lg | 1024px | Desktop |
| xl | 1280px | Large desktop |
| 2xl | 1536px | Ultra-wide |

## Performance Targets
- LCP < 2.5s
- FID < 100ms
- CLS < 0.1
- INP < 200ms
- JS bundle < 100KB gzipped
