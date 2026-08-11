---
description: Cache invalidation playbooks per stack. Triggers, commands, and post-invalidation health checks.
globs: *
alwaysApply: true
---

# Cache Invalidation Protocol

## Invalidation Triggers

Events that MUST trigger cache clearing:
- Configuration change (.env, config/ files modified)
- Dependency update (package.json, composer.json, requirements.txt modified)
- Build process modification (webpack/vite config, artisan changes)
- Database schema change (new migration executed)
- Pre-testing (before any formal test suite)
- Task finalization (before marking a task complete)

## Playbooks by Stack

### Node.js / React / Next.js
```bash
rm -rf node_modules/.cache .next dist build .parcel-cache .turbo
npm cache clean --force  # or yarn/pnpm equivalent
npm run build
```

### Laravel / PHP
```bash
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan optimize:clear
php artisan queue:restart
composer dump-autoload
php artisan cache:flush          # Redis/Memcached (if applicable)
redis-cli FLUSHALL               # development only
```

### Python
```bash
find . -type d -name __pycache__ -exec rm -rf {} +
find . -type f -name '*.py[cod]' -delete
pip cache purge
pytest --cache-clear
```

### Docker
```bash
docker-compose down
docker system prune -a --force
docker-compose build --no-cache
docker-compose up -d
```

### WordPress
```bash
wp cache flush
wp rewrite flush
rm -rf wp-content/cache/breeze/
wp transient delete --all
```

### Browser / UI
- Hard refresh (Cmd/Ctrl+Shift+R)
- Disable network cache in DevTools
- Clear all site data (cookies, localStorage)
- Verify in incognito/private browsing
- Test in an alternative browser

### CDN (Cloudflare)
- Purge entire cache via API
- Verify propagation: `curl -I <url>` → check `cf-cache-status: MISS`

## Post-Invalidation Health Check

After any playbook execution, verify:
- [ ] Service restarted without errors
- [ ] No new fatal errors in logs
- [ ] Application root URL returns HTTP 200
- [ ] API health endpoint responds correctly
- [ ] Database connection is active
- [ ] Key CSS/JS assets load with HTTP 200
- [ ] Browser console is error-free
