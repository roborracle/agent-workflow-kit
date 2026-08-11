# Git Workflow

## Branches

- `main` — development. Docs, tests, and debug tooling are welcome here.
- `prod` — production only. Sanitized; nothing lands here that isn't ready for a client to see.
- Features: `feature/kebab-case`. Hotfixes: `hotfix/description`.
- Branches are short-lived. Delete after merge.

Not every project needs the dual-branch model. Single-branch projects with a deploy pipeline
gated on CI are fine — but the project's `CLAUDE.md` must say which model is in use, so nobody
has to guess.

## Commits

- Format: `type(scope): description`, then a body, then `Closes #N`.
- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`, `build`, `ci`.
- Imperative mood. Subject ≤72 characters — a soft limit; a longer subject is fine when it
  earns the space.
- Atomic. One purpose per commit. If the body needs the word "also", split it.

## GitHub Issues

Every code change gets an issue before work begins. See [Carve-outs](#carve-outs) for the
exceptions.

An issue needs: a type-prefixed title, acceptance criteria, a priority label, and linked
commits or PRs by the time it closes.

## Label Taxonomy

Three orthogonal namespaces. Do not invent parallel conventions.

- **`priority/*`** — severity and urgency. Canonical: `priority/P0` (critical), `priority/P1`
  (high), `priority/P2` (medium/low). This is the *only* severity namespace. Never introduce
  bare `critical` / `high` / `medium` / `low` labels.
- **`area/*`** — component or domain. Examples: `area/wordpress`, `area/laravel`, `area/next`,
  `area/seo`, `area/perf`, `area/a11y`, `area/security`, `area/analytics`, `area/schema`.
  Cheap to create — add one when a genuinely new domain appears. An issue may carry several.
- **`type/*`** — kind of issue: `type/bug`, `type/feature`, `type/chore`, `type/refactor`,
  `type/docs`. Not a domain axis. Components never go here.

### Filing an issue

1. Run `gh label list` first. Reuse anything that fits. Do not create a near-duplicate.
2. If the repo already uses a different-but-internally-consistent convention, extend it rather
   than introducing a second one. Flag the deviation once, then stay consistent.
3. If someone says "critical" or "low", map silently onto `priority/P0..P2` and note the
   mapping in your response.
4. Minimum on every issue: one `priority/*`, one `type/*`, at least one `area/*`.

### Never

- Create a severity label outside `priority/*`.
- Churn colors or styling on existing labels.
- Delete or rename existing labels during a taxonomy cleanup. Additive only.

## Atomic Task Contract

Every unit of work must be:

- single-concern,
- committable on its own,
- independently verifiable (tests or an equivalent proof),
- labeled per the taxonomy above,
- merge-ready without waiting on a sibling task.

If a task touches more than one domain, split it before starting.

## Issues as Source of Truth

No issue, no work. The issue queue is the record of work state — not memory, not a scratch file,
not a conversation thread. Assign on pickup. Comment on blockers. Close on merge.

### Carve-outs

- **Trivial typos** — fix inline.
- **`docs(log)` commits** appending to a phase, session, or migration log. The body must name
  which phase or session is being logged.
- **`chore(wave-N)` umbrella wiring commits** that touch several issues from one wave. The body
  must list every issue ID involved.

Everything else needs an issue first.

## Parallelism

Before dispatching multiple agents, classify the work:

- Independent — no shared files, no sequential dependency → parallel is appropriate.
- Dependent → sequence it, one worker.
- Trivial — single file, under thirty minutes → no subagent, just do it.

Parallelism overhead is real. When in doubt, ask first.

**If two or more agents will run `git add` / `git commit` / `git branch`, they must be isolated
in separate worktrees or dispatched sequentially.** Concurrent agents in one working directory
interleave their git calls and produce commits whose messages describe work that landed
somewhere else. Nothing errors; you find out weeks later. See
`skills/parallel-agent-git-isolation/SKILL.md`.

## Never

- Force-push `main` or `prod`. Rewrite shared history.
- Commit secrets.
- Merge failing tests to `main`. Deploy untested code to `prod`.
- Track work in `.md` files when an issue tracker is available.
