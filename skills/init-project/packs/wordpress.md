description: WordPress theme/plugin development conventions, deployment, and security.
globs: ["**/*.php", "**/*.css", "**/*.js"]
alwaysApply: false

# WordPress Conventions

## Project Structure
```
/app/public/
├── wp-admin/           [NEVER COMMIT]
├── wp-includes/        [NEVER COMMIT]
├── wp-content/
│   ├── themes/         [Custom theme in Git]
│   ├── plugins/        [Only custom plugins in Git]
│   └── uploads/        [NEVER COMMIT]
├── docs/               [Documentation]
└── .gitignore          [Properly configured]
```

## File Cleanup
- No backup files in theme directories (*.backup, *.bak, *.old)
- No test files in production code (test*.php, debug*.php)
- No scattered documentation — use /docs
- No hardcoded domains

## Deployment (Cloudways)
1. Never deploy directly to production
2. Always test on staging first
3. Always create backup before deployment
4. Never use force push
5. Verify deployment success

### Post-Deployment
```bash
wp cache flush
wp rewrite flush
wp search-replace 'old-domain' 'new-domain' --all-tables --dry-run
```

## Security
- Never store credentials in theme files
- Use `wp_nonce_field()` for form security
- Sanitize all inputs: `sanitize_text_field()`, `esc_html()`, `esc_attr()`
- Use `$wpdb->prepare()` for database queries
- Validate and sanitize all `$_GET`, `$_POST`, `$_REQUEST` data
