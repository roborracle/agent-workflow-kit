# Quality Gate

Before any task is marked complete, every applicable check must pass:

- All tests passing — unit and integration.
- Type checker: zero errors.
- Linter: zero errors.
- No critical security vulnerabilities in dependencies.
- Test coverage at or above 80%.
- Performance targets met: LCP under 3s, API p95 under 200ms, DB p95 under 50ms.
- Browser tests passing if UI changed: Chrome, Firefox, Safari, and mobile at 360×800.

Targets are defaults, not dogma. A project whose `CLAUDE.md` sets different numbers wins — but
it has to set them explicitly. Silently skipping a gate is not the same as agreeing it doesn't
apply.

## Build Verification (commit-time gate)

Before any commit that includes code changes, run the project's build and confirm exit code 0.

The build is the last line of defense. A commit that lands on top of a broken build poisons
every commit after it and obscures which change actually caused the breakage.

Per stack:

- **npm / `wp-scripts` projects** — `npm run build` returns 0. Warnings are follow-up issues;
  errors block the commit.
- **Composer projects** — `composer install` returns 0.
- **Plain WordPress themes with no build pipeline** — not applicable, skip.
- **Docs-only commits** — not applicable, skip.

### Exit code 0 is not sufficient

A build that reports success while emitting nothing has failed. Bundlers will happily print
"compiled successfully" after resolving an entry point that doesn't match your source layout,
producing an empty output directory in a few milliseconds. The exit code is clean. The artifact
is empty. Anything you commit on top of it is untested.

Verify that build artifacts **exist and have non-trivial size**, not just that the command
returned 0. A suspiciously fast build is the tell.
