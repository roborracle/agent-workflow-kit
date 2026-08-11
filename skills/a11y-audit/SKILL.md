---
name: a11y-audit
description: Audit frontend code for WCAG 2.1 AA accessibility compliance including semantic HTML, ARIA, keyboard navigation, and color contrast.
disable-model-invocation: true
argument-hint: [file-or-component]
allowed-tools: Read, Grep, Glob, Bash(npx *)
---

# Accessibility Audit (WCAG 2.1 AA)

## Audit Checklist

### 1. Semantic HTML
Scan for:
- `<div>` or `<span>` used where semantic elements should be (`<nav>`, `<main>`, `<article>`, `<section>`, `<header>`, `<footer>`, `<aside>`, `<button>`, `<a>`)
- Click handlers on non-interactive elements (`<div onClick>` instead of `<button>`)
- Missing `<label>` elements for form inputs
- Missing `<h1>`-`<h6>` hierarchy (skipped heading levels)
- Tables without `<th>`, `<caption>`, or `scope` attributes

### 2. ARIA Attributes
Scan for:
- Interactive elements missing `aria-label` or visible text
- Custom widgets missing appropriate ARIA roles
- Dynamic content missing `aria-live` regions
- Modal/dialog missing `aria-modal` and focus trap
- Toggle controls missing `aria-expanded` or `aria-pressed`
- Images missing `alt` text (or decorative images missing `alt=""`)

### 3. Keyboard Navigation
Check for:
- Elements with `onClick` but no `onKeyDown`/`onKeyUp`
- `tabIndex` greater than 0 (disrupts natural tab order)
- Missing focus styles (`:focus-visible` CSS)
- Focus traps in modals/dialogs
- Skip navigation link at page top

### 4. Color Contrast
Check for:
- Text colors against background colors meeting 4.5:1 ratio (normal text)
- Large text meeting 3:1 ratio
- Non-text elements (icons, borders) meeting 3:1 ratio
- Information conveyed only through color (needs shape/text alternative)

### 5. Motion and Media
Check for:
- Animations without `prefers-reduced-motion` media query
- Auto-playing media without pause controls
- Flashing content (3 flashes per second limit)

## Automated Scan

If available, run:
```bash
npx axe-cli http://localhost:3000 --exit 2>/dev/null || echo "axe-cli not available — manual review only"
```

## Report Format

For each issue found:
```
**Severity**: Critical / Major / Minor
**Rule**: WCAG success criterion (e.g., 1.1.1 Non-text Content)
**Location**: file:line
**Problem**: What's wrong
**Fix**: Exact code change needed
```

### Severity Guide
- **Critical**: Prevents access entirely (missing alt text, no keyboard access, no labels)
- **Major**: Significantly impairs experience (poor contrast, missing ARIA, broken focus)
- **Minor**: Suboptimal but functional (heading hierarchy, decorative images)

## Summary
```
ACCESSIBILITY: [PASS | ISSUES FOUND]

Critical: X issues (blocks deployment)
Major: X issues (should fix before release)
Minor: X issues (improve when convenient)

Top 3 fixes for maximum impact:
1. [fix]
2. [fix]
3. [fix]
```
