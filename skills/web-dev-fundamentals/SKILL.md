---
name: web-dev-fundamentals
description: Web development standards for HTML structure, CSS organization, JavaScript loading, fonts, performance, images, and SEO basics. Use when writing or reviewing HTML, CSS, JavaScript, JSX/TSX, Vue/Svelte/React components, WordPress theme files, Blade templates, or Twig templates; when auditing page performance or crawlability; or when setting up a new web project's base template. Does NOT apply to backend PHP (Laravel controllers/models/services, API handlers, plain PHP business logic) — those don't need frontend standards loaded.
---

# Web Development Fundamentals

Use this skill for any frontend or full-stack web work. The rules below were previously always-loaded as `rules/web-dev-fundamentals.md` — they now load only when the skill is active, since they're irrelevant on backend-only or non-web work.

## HTML Structure

### Semantic HTML (Mandatory)
- Use `<header>`, `<nav>`, `<main>`, `<article>`, `<section>`, `<aside>`, `<footer>` appropriately
- Use `<h1>`-`<h6>` for heading hierarchy (one H1 per page)
- Use `<figure>`/`<figcaption>`, `<time>`, `<address>`, `<blockquote>`/`<cite>`, `<abbr>`, `<dl>`/`<dt>`/`<dd>`

### DOM Size Limit
- Maximum 900 HTML DOM elements per page
- Larger DOMs increase memory usage, slow rendering, and hurt crawl efficacy

### JS / HTML Parity
- JS-rendered and JS-disabled HTML must match: internal links, anchor texts, images, hierarchy, font sizes, layout
- Use SSR / SSG (Next.js, Nuxt, equivalent)

## CSS

### Selector Depth
- Maximum 2 CSS selectors per rule
- Allowed: `.header .nav-link`, `.btn-primary`, `article p`
- Forbidden: `.header .nav .nav-list .nav-item .nav-link`

### File Organization
- Maximum 2 CSS files in `<head>`: `head-foot.css` (shared) + `[page-type].css` (page-specific)

### Critical CSS
- Inline critical CSS for above-the-fold content in `<style>` within `<head>`
- Include: H1 font, logo, navigation, intro paragraph, first headline image styles

## JavaScript

### Defer Non-Essential
- Defer all marketing, tracking, analytics, chat widgets, social embeds
- Use Google Tag Manager for all deferred scripts

### Build File Exclusion
- Block framework build files from crawlers via `robots.txt`: `/_next/static/chunks/*.js`, etc.

## Fonts

### Local Fonts (Mandatory)
```css
@font-face {
  font-family: 'FontName';
  src: local('FontName'), url('/fonts/font.woff2') format('woff2');
  font-display: swap;
}
```

### Typography Sizes (Recommended)
H1: 42px, H2: 36px, H3: 32px, H4: 28px, H5: 24px, H6: 20px, Body: 18px. Minimum mobile: 14px.

## Performance

- Server response time: under 100ms
- H1 should be the Largest Contentful Paint element (text-based LCP is faster and more predictable)
- Preload: header/footer CSS, above-the-fold headline image
- DNS-prefetch: only for Google Tag Manager
- Cache via CDN (Cloudflare or equivalent): header/footer content, CSS, static assets

## Images

### Format
- Preferred: AVIF (better compression than WebP)
- Fallback: WebP
- Avoid: JPEG / PNG for photographic content

### Optimization
- Responsive images with `srcset`
- `width` and `height` attributes (prevent CLS)
- Lazy loading for below-the-fold images
- Preload above-the-fold headline images

## SEO

### Sitemap
- Multiple sitemaps by topic / category
- Always use `lastmod`, never use `priority` or `changefreq`
- Include images and hreflang references

### Hreflang
- Implement in: HTML `<head>`, HTTP response headers, and sitemap

### Canonicalization
- Canonical in HTTP response headers AND HTML `<head>`
- `og:url` must match canonical URL

### Meta Tags (Required)
`og:title`, `og:description`, `og:image`, `og:url`, `twitter:card`, `twitter:title`, `twitter:description`, `twitter:image`

## HTML Head Ordering

Elements in `<head>` must follow this order:
1. `<meta charset>`
2. `<meta name="viewport">`
3. `<title>`
4. `<meta name="description">`
5. `<link rel="canonical">`
6. `<link rel="alternate" hreflang>`
7. Open Graph tags
8. Twitter Card tags
9. `<style>` (critical CSS)
10. `<link rel="preload">`
11. `<link rel="stylesheet">` (head-foot.css first)
12. `<link rel="stylesheet">` (page-specific)
13. `<link rel="dns-prefetch">`
