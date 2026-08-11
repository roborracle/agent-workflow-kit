description: Next.js App Router, React, and Tailwind CSS conventions for Next.js projects.
globs: ["**/*.tsx", "**/*.ts", "**/*.jsx", "**/*.css"]
alwaysApply: false

# Next.js Conventions

## App Router
- Use `page.tsx` files in route directories
- Client components must be marked with `'use client'` at the top
- Use kebab-case for directory names, PascalCase for component files
- Prefer named exports over default exports
- Minimize `'use client'` directives:
  - Keep most components as React Server Components (RSC)
  - Only use client components for interactivity, wrap in `Suspense` with fallback UI
  - Create small client component wrappers around interactive elements
- Avoid unnecessary `useState` and `useEffect`:
  - Use server components for data fetching
  - Use React Server Actions for form handling
  - Use URL search params for shareable state
- Use `nuqs` for URL search param state management

## Tailwind CSS

### No Inline Styles
Always use Tailwind utility classes over `style=""` attributes.

```html
<!-- Forbidden -->
<div style="color: red;">Not allowed</div>

<!-- Required -->
<div class="text-red-500">Correct</div>
```

### Arbitrary Values (Permitted)
Use Tailwind's bracket syntax for custom values:
```html
<div class="top-[117px] text-[#1da1f2]">Custom values</div>
<div class="grid-cols-[1fr_2fr_1fr]">Custom grid</div>
<div class="w-[calc(100%-2rem)]">Custom calculations</div>
```

### Responsive Design
Mobile-first with responsive prefixes:
```html
<div class="w-full md:w-1/2 lg:w-1/3">Responsive</div>
```

### Component Patterns
Use `@apply` for repeated patterns:
```css
@layer components {
  .btn-primary {
    @apply px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600;
  }
}
```

### Rules
- Never use `style=""` — use arbitrary values `[value]` syntax instead
- Follow Tailwind naming conventions in arbitrary values (`p-[15px]` not `style="padding: 15px"`)
- Use state variants: `hover:`, `focus:`, `active:`
- Use spacing utilities: `space-y-4`, `gap-4`
