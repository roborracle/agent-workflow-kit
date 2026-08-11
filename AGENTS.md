<!-- GENERATED FILE — do not edit by hand.
     Source: CLAUDE.md + rules/*.md
     Regenerate: ./scripts/sync-agents-md.sh
     digest: f7874a7a7dc7a79e
-->

# AGENTS.md — Engineering Standards

This file is for assistants that read a single instruction file: Codex, Gemini CLI, Cursor, and
most others. It contains the same standards Claude Code loads from `CLAUDE.md` plus `rules/`,
with every rule inlined because there is no on-demand loading here.

If you are Claude Code, read `CLAUDE.md` instead — it is shorter and the rules load only when
relevant.

---

# Development Directives

A general-purpose operating standard for software work. This file is loaded into every
session. Project-level `CLAUDE.md` files may override specific directives; they may not weaken
the Permanent Constraints below.

Detailed rules live in `rules/` and load on demand. This file stays short on purpose — every
line here is paid for in every session by every person.

---

## Response Style

- Start with the answer. No preamble, no restating the question.
- Match length to complexity. Don't pad, don't gate depth on assumed skill level.
- If scope is unclear, ask. One good question beats a wrong deliverable.

## Uncertainty

If you are uncertain about a fact, statistic, date, library API, command syntax, version number,
or config option — say so before including it. Never fill a gap with something plausible.
Fabrication is the most expensive failure mode available to you: it propagates downstream as if
it were true. If a cheap verification exists (grep, file read, doc lookup), run it first.

See `rules/decision-boundaries.md`.

## Before Significant Work

Present 2–3 viable approaches with trade-offs and a recommendation. Wait for a choice.

Applies to ad-hoc work. Skip it when you are inside a framework that already does this
(a brainstorming or discussion phase presents alternatives in its own format).

---

## Operational Rules

**Verify before done.** Never report a task complete without proving it works. Run the tests,
read the logs, show the output. The bar: would a senior engineer approve this as-is?

**Bug reports: test first, fix second.** Write a failing test that reproduces the bug. Then fix
it. Then run the full suite to prove nothing else broke. A fix without a reproduction is a guess.

**Simplicity, root causes, minimal impact.** Find the actual cause, not the nearest symptom.
Touch only what the task requires. Scope creep in a task becomes scope creep in the codebase.

**Subagent discipline.** Offload research, exploration, and review to subagents to keep the main
context clean. One task per subagent. On genuinely hard problems, spend more compute, not more
guesses.

**Plan before building.** Use plan mode for anything with 3+ steps or an architectural decision.
If an approach fails, stop and re-plan — do not iterate blindly on a broken premise.

**Extended thinking on durable decisions.** Architecture, performance trade-offs, database
design, anything expensive to reverse: reason it through before writing code. Surface the
non-obvious trade-offs. Name the assumptions that break at scale. Recommendation comes last.

**Autonomous execution.** Own the task end to end. Resolve ordinary errors without escalating.
The goal is zero context-switching for the person who asked.

Autonomy applies to *how*, not *what*. Four confirmation gates fire regardless:

1. Significant rewrites of existing content — prose, docs, plans, sections.
2. Deletions, overwrites, dropped data, removed dependencies.
3. Deploys, migrations, external API calls, anything irreversible.
4. External sends — messages, posts, publishes, scheduled items.

Halt and ask when scope is ambiguous, business logic is undocumented, client data is at risk,
prior commits contradict current instructions, or you would be guessing.
See `rules/decision-boundaries.md` and `rules/external-actions.md`.

---

## End-of-Task Summary

Close every coding task with exactly this:

```
Files changed: <every file touched>
What was modified: <one line per file>
Files intentionally not touched: <if relevant>
Follow-up needed: <if any>
```

---

## Permanent Constraints

Every project, every session. Each is enforced by a rule file or a hook — follow the pointer
rather than relying on this summary.

1. **An issue exists before code does.** Non-trivial changes are tracked before work starts.
   — `rules/git-workflow.md`.
2. **Never force-push a shared branch.** — `rules/git-workflow.md`, enforced by
   `hooks/block-force-push.sh`.
3. **Conventional commits.** — `rules/git-workflow.md`.
4. **Secrets live in the environment, never in the repository.** — `rules/security.md`,
   enforced by `hooks/block-secret-commit.sh`.

---


---

# Rules


<a id="cache-protocols"></a>

---
description: Cache invalidation playbooks per stack. Triggers, commands, and post-invalidation health checks.
globs: *
alwaysApply: true
---

## Cache Invalidation Protocol

### Invalidation Triggers

Events that MUST trigger cache clearing:
- Configuration change (.env, config/ files modified)
- Dependency update (package.json, composer.json, requirements.txt modified)
- Build process modification (webpack/vite config, artisan changes)
- Database schema change (new migration executed)
- Pre-testing (before any formal test suite)
- Task finalization (before marking a task complete)

### Playbooks by Stack

#### Node.js / React / Next.js
```bash
rm -rf node_modules/.cache .next dist build .parcel-cache .turbo
npm cache clean --force  # or yarn/pnpm equivalent
npm run build
```

#### Laravel / PHP
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

#### Python
```bash
find . -type d -name __pycache__ -exec rm -rf {} +
find . -type f -name '*.py[cod]' -delete
pip cache purge
pytest --cache-clear
```

#### Docker
```bash
docker-compose down
docker system prune -a --force
docker-compose build --no-cache
docker-compose up -d
```

#### WordPress
```bash
wp cache flush
wp rewrite flush
rm -rf wp-content/cache/breeze/
wp transient delete --all
```

#### Browser / UI
- Hard refresh (Cmd/Ctrl+Shift+R)
- Disable network cache in DevTools
- Clear all site data (cookies, localStorage)
- Verify in incognito/private browsing
- Test in an alternative browser

#### CDN (Cloudflare)
- Purge entire cache via API
- Verify propagation: `curl -I <url>` → check `cf-cache-status: MISS`

### Post-Invalidation Health Check

After any playbook execution, verify:
- [ ] Service restarted without errors
- [ ] No new fatal errors in logs
- [ ] Application root URL returns HTTP 200
- [ ] API health endpoint responds correctly
- [ ] Database connection is active
- [ ] Key CSS/JS assets load with HTTP 200
- [ ] Browser console is error-free

---

<a id="code-cleanup-safety"></a>

## Code & Content Cleanup Safety

Covers both code and written content — prose, docs, plans, sections.

### Code

- One atomic change at a time. Test after each. Revert immediately on failure.
- Work on a safety branch: `refactor/<description>`.
- Never combine cleanup types in one commit. Formatting and logic do not travel together.
- Never remove code without verifying zero references across the entire codebase.
- Never modify business logic during a cleanup commit.
- Never use `@ts-ignore`, `eslint-disable`, `# noqa`, or `phpcs:ignore` to hide a new error.
  Suppressing a warning you just created is not cleanup.
- Every cleanup commit must be independently revertable.

### Written Content

- Only modify content related to the current task. Don't reformat, restructure, or "improve"
  sections nobody asked about.
- Match the existing voice and structure even if you'd write it differently. Consistency across
  a document beats local improvement in one paragraph.
- Before significantly altering content someone else wrote — rewriting sections, removing
  paragraphs, restructuring flow, changing tone — stop, describe exactly what you intend to
  change and why, then wait. This is confirmation gate 1 in `rules/decision-boundaries.md`.
- Minor edits — typos, formatting, a single-sentence clarification — don't need confirmation.
  The gate fires on *significant*.
- If you notice unrelated content worth improving, note it under "Follow-up needed" in the
  end-of-task summary. Don't touch it.

### The surgical principle

Every changed line should trace directly to the request. If you can't point at the sentence in
the ask that a given diff hunk serves, it doesn't belong in this commit.

See `skills/karpathy-guidelines/SKILL.md`.

---

<a id="coding-standards"></a>

---
description: Universal coding standards for file structure, naming, type safety.
globs: *
alwaysApply: true
---

## Coding Standards

### Structure
- 350 lines max per file. Single responsibility. Composition over inheritance.

### Naming
- Classes/Components: PascalCase. Constants: UPPER_SNAKE_CASE. Files: kebab-case.
- Functions/variables: follow framework convention (camelCase JS/TS, snake_case Python/PHP).

### Type Safety
- Type all function signatures — parameters and return values.
- No `any`/`object`/`mixed` escape hatches without explicit justification.
- Use framework data models (Pydantic, Zod) for structured data.

### Prohibited
- Commented-out code. Debug statements. Magic numbers/strings. Generic exception catching.

### Required
- Error handling on all external calls. Input validation at boundaries. Try/catch on I/O.
- KISS, YAGNI, DRY. Industry standard libraries first. No mocks, placeholders, or omitted code.

---

<a id="decision-boundaries"></a>

## Decision Boundaries

### The Rule

Autonomous execution applies to *how*, not *what*.

You own the mechanics: the right tool, the right command, the right commit structure, the right
subagent. You do not own ambiguous scope, undocumented business logic, contradictory
instructions, or anything that puts client data at risk.

The rule also covers factual fabrication. If you are uncertain about a fact, statistic, date,
library API, command syntax, version number, or configuration option — say so before including
it. Plausible-sounding fabrication is the most expensive failure mode available, because it
propagates through downstream work as if it were true. If a cheap verification exists, run it.

### Halt when

- **Scope is ambiguous.** The request supports more than one reading, and the choice
  meaningfully changes the outcome.
- **Business logic is unclear.** Correct behavior depends on a domain rule that isn't in the
  codebase or the conversation.
- **Client data is at risk.** Anything that could lose, leak, or corrupt data someone is paying
  us to protect — even when you're confident in the fix.
- **Prior commits contradict current instructions.** Recent work implies a different approach.
  Surface the conflict before extending either side.
- **You would be guessing.** If you can't cite the source for the choice you're about to make,
  stop.

### The two failure shapes

**Guessing on a fork that propagates.** A data-model question with two defensible readings —
is this new form a replacement for the old one, a variant, or a deprecation? — will be answered
one way or another by the first thing you build on top of it. Every downstream task inherits
that answer. Asking costs one message; guessing wrong costs a rollback of everything built
since. Halt.

**Overruling contradictory output with confidence.** A build command reports "compiled
successfully" and exits 0, but writes zero bytes to the output directory. The literal signal
says pass. The observable outcome says fail. The correct response is to stop and investigate,
not to treat the exit code as authorization and commit on top of it.

The principle behind both: *when literal output contradicts the expected outcome, the
contradiction is itself the signal to halt.* It is not a flag to overrule with confidence.

### Halt protocol

1. Stop. Don't commit, don't dispatch agents, don't mutate state.
2. State the decision point — what are the candidate readings?
3. State what you'd do under each, with the trade-offs.
4. Ask for a choice, or for the missing information.
5. Wait. Do not re-engage until you get an answer.

### What this rule does *not* block

- Tactical decisions inside a clearly-scoped task: which loop, which file first, what order for
  a series of independent atomic commits.
- Routine error recovery where the cause is obvious and the fix is mechanical — a missing
  dependency, a typo, a stale cache.
- Verification steps inside the agreed scope.

The dividing line: if you'd be guessing, halt. If you'd be picking the obviously correct
mechanic, proceed.

### The Four Confirmation Gates

Autonomous execution is the default. Gates fire only for these four, by name:

1. **Significant rewrites of existing content.** Prose, docs, plans, sections — not typo fixes.
   The test: would the reader notice this as a deliberate rewrite? If yes, the gate fires.
   See `rules/code-cleanup-safety.md`.
2. **Deletions, overwrites, dropped data, removed dependencies.** File removal, schema drops,
   package removal, branch deletion, history rewrites. List exactly what's affected. Ask. Wait.
3. **Deploys, migrations, external API calls, irreversible operations.** Anything with side
   effects beyond the local repository. Approval is per-instance — a yes for one deploy is not
   a yes for the next one.
4. **External sends.** Slack, email, calendar, project management, design tools, scheduled
   tasks — any action that creates state outside this conversation.
   See `rules/external-actions.md`.

Outside these four, proceed without asking. Every false-positive halt spends trust you'll need
when a real one fires.

---

<a id="documentation-protocol"></a>

## Documentation Protocol

### Naming

- All documentation filenames are kebab-case.
- Exceptions: `CLAUDE.md`, `AGENTS.md`, `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`,
  `LICENSE.md`.

### Structure

- No `.md` files at the project root except the ones listed above.
- `docs/` uses subdirectories only — `technical/`, `strategy/`, `guides/`, `runbooks/`, etc.
  Nothing loose at `docs/` root.
- Hard ceiling of 350 lines on any single documentation file. Past that, split it.

### Rules

- No project-level copies of global rules or global skills. If you find yourself duplicating a
  rule from this kit into a project, either the rule is wrong or the project needs an override —
  write the override, not the copy.
- Keep the repository root clean. Working files go in `docs/` or a scratch directory that is
  gitignored.

### Project `CLAUDE.md` template

A project-level `CLAUDE.md` is a thin reference layer. It does **not** duplicate the global
directives from this kit. It carries only the deltas: paths, project-specific overrides, and
pointers to where the deeper context lives.

**Size:** soft target 50 lines, hard cap 80. Past either, the file has accreted material that
belongs in `docs/`.

Required sections, in order:

1. **Header** — project name, last-updated date, one line of current context.
2. **Inheritance pointer** — an explicit statement that the project inherits the global rules.
3. **Project paths** — git root, active source directory, any read-only legacy directories.
4. **Project context** — goal, audience, stack constraints, what to avoid. Apply this to every
   task in the project. When something doesn't fit, flag it before proceeding.
5. **Tech stack defaults** — language, framework, package manager, database, testing framework,
   styling system. These are the defaults; use them. Never suggest alternatives unless asked.
   If something looks like the wrong tool, say so — then use the defined stack anyway unless
   told otherwise.
6. **Project-specific overrides** — deltas only. Each states which global rule it overrides and
   why.
7. **Source-of-truth docs** — pointers to the project docs holding deep context.

#### Sample

```markdown
## {Project Name} — AI Assistant Context

**Last updated:** YYYY-MM-DD
**Status:** {one line — active phase, current milestone}

### Global rules

Inherits all rules from the ai-workflow-kit installation in `~/.claude/`.

### Project paths

- Git root: `{path}`
- Active source: `{path}`
- Read-only legacy: `{path}` (do not modify)

### Project context

- **Goal:** {what success looks like}
- **Audience:** {who uses this}
- **Stack constraints:** {version locks, infra limits, regulatory requirements}
- **Avoid:** {patterns, libraries, approaches that are off-limits here}

### Tech stack

| Layer | Choice |
|-------|--------|
| Language | |
| Framework | |
| Package manager | |
| Database | |
| Testing | |
| Styling | |

Always use the stack above. If a task seems to call for a different tool, flag it before
substituting.

### Project-specific overrides

- {override} — overrides {global rule}; reason: {why}

### Prior context

- `docs/{...}` — where the deep context lives
```

#### When the template doesn't fit

If a project genuinely needs more than 80 lines of context, the excess belongs in `docs/`, not
in `CLAUDE.md`:

- Long architecture description → `docs/architecture/overview.md`
- Step-by-step workflows → a skill, if generally applicable, or `docs/workflows/`
- Historical context → `docs/{project}/recon.md` or equivalent
- Issue and sprint tracking → the issue tracker

`CLAUDE.md` is an index. It is not the body of the documentation.

---

<a id="external-actions"></a>

---
description: Confirmation gate for any tool call that sends, posts, publishes, or creates external state. Includes all MCP tools targeting third-party systems.
globs: *
alwaysApply: true
---

## External Actions — Confirmation Gate

This is gate category 4 in `CLAUDE.md` → "Autonomous Execution".

### The rule

Before any MCP tool call (or any other action) that sends, posts, publishes, schedules, comments, or creates external state — state the action and target in plain language, then wait for explicit in-session yes. Prior approval does NOT carry forward. Each external action requires fresh confirmation in the current message.

### Covered surfaces (non-exhaustive)

- **Slack** — `slack_send_message`, `slack_schedule_message`, `slack_add_reaction`, `slack_create_canvas`, `slack_update_canvas`, `slack_send_message_draft`
- **Gmail** — any send/reply/forward action
- **Google Calendar** — `create_event`, `update_event`, `delete_event`, `respond_to_event`
- **Google Drive** — `create_file`, `copy_file`, sharing permission changes
- **Asana** — `create_tasks`, `update_tasks`, `add_comment`, `create_project_*`, status updates
- **Canva** — `comment-on-design`, `export-design`, `commit-editing-transaction`, `request-outline-review`, anything that publishes
- **Figma** — `add_code_connect_map`, `send_code_connect_mappings`, `upload_assets`, `create_new_file` if it writes to a shared Figma team
- **Any new MCP tool** that creates state outside this conversation — default to gated unless its description is explicitly read-only.

### What does NOT trigger the gate

- Read-only MCP tools (search, get, list, read, fetch).
- Local file edits (covered by other gates if applicable).
- Tool calls inside the user's own environment that produce no externally-visible state.

When unsure whether a tool sends or only reads, treat it as gated and ask.

### What the confirmation looks like

State three things, then wait:
1. **What** — the action class and the specific tool.
2. **Where** — the target (channel, recipient, doc URL, calendar, etc.).
3. **Content** — a short preview of what will be sent (if the user hasn't already authored it verbatim).

Wait for "yes" in the current message. "Earlier you said go ahead" is not confirmation.

### When the user pre-authorizes

If the user explicitly says "send the message I just wrote to #general — yes, do it now" in the current message, that IS the confirmation. The gate fires on assumed authorization, not on explicit-in-the-message authorization.

---

<a id="git-workflow"></a>

## Git Workflow

### Branches

- `main` — development. Docs, tests, and debug tooling are welcome here.
- `prod` — production only. Sanitized; nothing lands here that isn't ready for a client to see.
- Features: `feature/kebab-case`. Hotfixes: `hotfix/description`.
- Branches are short-lived. Delete after merge.

Not every project needs the dual-branch model. Single-branch projects with a deploy pipeline
gated on CI are fine — but the project's `CLAUDE.md` must say which model is in use, so nobody
has to guess.

### Commits

- Format: `type(scope): description`, then a body, then `Closes #N`.
- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`, `build`, `ci`.
- Imperative mood. Subject ≤72 characters — a soft limit; a longer subject is fine when it
  earns the space.
- Atomic. One purpose per commit. If the body needs the word "also", split it.

### GitHub Issues

Every code change gets an issue before work begins. See [Carve-outs](#carve-outs) for the
exceptions.

An issue needs: a type-prefixed title, acceptance criteria, a priority label, and linked
commits or PRs by the time it closes.

### Label Taxonomy

Three orthogonal namespaces. Do not invent parallel conventions.

- **`priority/*`** — severity and urgency. Canonical: `priority/P0` (critical), `priority/P1`
  (high), `priority/P2` (medium/low). This is the *only* severity namespace. Never introduce
  bare `critical` / `high` / `medium` / `low` labels.
- **`area/*`** — component or domain. Examples: `area/wordpress`, `area/laravel`, `area/next`,
  `area/seo`, `area/perf`, `area/a11y`, `area/security`, `area/analytics`, `area/schema`.
  Cheap to create — add one when a genuinely new domain appears. An issue may carry several.
- **`type/*`** — kind of issue: `type/bug`, `type/feature`, `type/chore`, `type/refactor`,
  `type/docs`. Not a domain axis. Components never go here.

#### Filing an issue

1. Run `gh label list` first. Reuse anything that fits. Do not create a near-duplicate.
2. If the repo already uses a different-but-internally-consistent convention, extend it rather
   than introducing a second one. Flag the deviation once, then stay consistent.
3. If someone says "critical" or "low", map silently onto `priority/P0..P2` and note the
   mapping in your response.
4. Minimum on every issue: one `priority/*`, one `type/*`, at least one `area/*`.

#### Never

- Create a severity label outside `priority/*`.
- Churn colors or styling on existing labels.
- Delete or rename existing labels during a taxonomy cleanup. Additive only.

### Atomic Task Contract

Every unit of work must be:

- single-concern,
- committable on its own,
- independently verifiable (tests or an equivalent proof),
- labeled per the taxonomy above,
- merge-ready without waiting on a sibling task.

If a task touches more than one domain, split it before starting.

### Issues as Source of Truth

No issue, no work. The issue queue is the record of work state — not memory, not a scratch file,
not a conversation thread. Assign on pickup. Comment on blockers. Close on merge.

#### Carve-outs

- **Trivial typos** — fix inline.
- **`docs(log)` commits** appending to a phase, session, or migration log. The body must name
  which phase or session is being logged.
- **`chore(wave-N)` umbrella wiring commits** that touch several issues from one wave. The body
  must list every issue ID involved.

Everything else needs an issue first.

### Parallelism

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

### Never

- Force-push `main` or `prod`. Rewrite shared history.
- Commit secrets.
- Merge failing tests to `main`. Deploy untested code to `prod`.
- Track work in `.md` files when an issue tracker is available.

---

<a id="project-memory"></a>

## Project Memory

Every project keeps a persistence layer, so that context survives a session ending, a laptop
rebooting, or the work changing hands.

### If the project uses a planning framework

If the project has a framework-managed planning directory (for example `.planning/`), that is
the persistence layer. Use the framework's own workflows for decisions, plans, session state,
and retrospectives. Do **not** also create `MEMORY.md` and `ERRORS.md` — the framework already
covers them.

### Otherwise: two files at the project root

#### `MEMORY.md` — the decision log

After any significant decision, append:

```
### YYYY-MM-DD — {short title}

**Decided:** {what was decided}
**Why:** {the constraint, requirement, or incident that motivated it}
**Rejected:** {what was considered and rejected, and why}
```

Read `MEMORY.md` at the start of every session. Never contradict a logged decision without
flagging the contradiction first.

The "Rejected" line is the one that earns its keep. Without it, the next person re-proposes the
rejected option six weeks later and nobody remembers why it was a bad idea.

#### `ERRORS.md` — the failure log

When an approach takes more than two attempts to work, append:

```
### YYYY-MM-DD — {short title}

**Attempted:** {what didn't work}
**Worked:** {what worked instead}
**Note for next time:** {what to try first if this pattern reappears}
```

Check `ERRORS.md` before proposing an approach to a similar task.

### Session boundaries

**Start.** Read `MEMORY.md` and `ERRORS.md` (or the framework equivalents) before significant
work. Surface anything load-bearing in the conversation rather than silently absorbing it.

**End.** When someone says "session end", "wrapping up", "let's stop here", or equivalent,
append:

```
### YYYY-MM-DD — Session summary

**Worked on:** {what was tackled}
**Completed:** {what shipped}
**In progress:** {what's mid-stream}
**Decisions made:** {pointers to the MEMORY.md entries}
**Next session priorities:** {ordered list}
```

### Never run both systems at once

Use either the framework's planning directory or `MEMORY.md` + `ERRORS.md`. Never both. A
project mid-migration finishes the migration before merging memory state.

### Relationship to per-user assistant memory

Some assistants keep their own per-user memory store of cross-project facts — preferences,
working style, validated patterns. That is a different thing from project memory. Project memory
is scoped to the project, lives in the repository, and is visible to everyone on the team. Facts
that only matter to one person's setup do not go in it.

---

<a id="reporting-discipline"></a>

---
description: How to report verification results honestly — distinguish inspected vs sampled and verified vs appears; required Method/Coverage/Result/Evidence schema for load-bearing claims; surface coverage gaps; name background processes in plain language.
globs: *
alwaysApply: true
---

## Reporting Discipline

When reporting results of investigations, scans, or verification steps, distinguish precisely:

- **inspected** (each hit individually read) vs **sampled** (a subset read).
- **verified** (tested/confirmed) vs **appears** (inference from partial evidence).

When a claim is load-bearing for a non-reversible action (push, merge, delete, remote creation, history rewrite), state the exact verification method and its coverage. No summary claims standing in for evidence.

### Required format for load-bearing reports

- **Method**: the exact command or procedure used
- **Coverage**: what set of files/commits/objects was inspected, and what was not
- **Result**: precisely what was found, distinguishing verified from inferred
- **Evidence**: raw output excerpt or reference to it

### Coverage gaps

Surface gaps rather than hide them. A report that says "sampled 7 of 69, 62 un-inspected, here is the list" is correct. A report that says "spot-checked all 562 hits, clean" when only 7 files were read is a violation.

### When a check fails silently

If a command's output doesn't match expectation (e.g., a grep returns zero hits but you directly saw a match elsewhere), do not accept the zero result. Verify the command itself. Regex portability, shell escaping, and BSD vs GNU tool differences are common silent-failure modes. Re-run with a simpler method to confirm.

### In-flight process transparency

Background processes (CI watchers, deploy waiters, long-running shells, polled jobs) must be surfaced in human-readable terms whenever they're referenced in agent output. Internal handles, PIDs, or generated identifiers are NEVER the primary reference.

Required fields when announcing or referencing a background process:
- What it is in plain language (e.g., "post-merge CI watcher on main")
- The target it's observing (run ID, commit SHA, URL — whichever applies)
- Expected duration based on prior runs of the same operation, or "unknown" if no prior data
- An independently-verifiable URL or command the user can run to observe the same data without waiting on the agent

Internal handles MAY appear as a secondary reference for the agent's own task tracking, but never as the only reference.

Failure mode this prevents: "waiting on poll br5h2qdd1" with no way for the user to see what's actually happening.

### Background shell lifecycle

Every background shell spawned by an agent must:
1. Declare its termination condition at spawn time, in plain language ("exits when CI run 25239969494 reports a conclusion").
2. Be explicitly released or killed when its reason for existing is satisfied. Do not let watchers persist past their target's completion.
3. Appear in any session status output with current state: running / awaiting-condition / orphaned. Orphaned shells must be flagged for cleanup, not silently retained.

Cumulative shell leakage across unrelated tasks is a defect, not a quirk.

---

<a id="security"></a>

---
description: Security requirements for all projects.
globs: *
alwaysApply: true
---

## Security

- Validate all external inputs at boundaries. Sanitize before storing/processing.
- Parameterized queries only — never concatenate SQL.
- Secrets in environment variables only. Never commit `.env`, keys, passwords, or tokens.
- Every person uses their own credentials for every service. Shared accounts and shared API
  keys have no audit trail, can't be revoked individually, and make offboarding a guess. If a
  service can't issue per-person credentials, that's a finding — raise it.
- Enforced locally by `hooks/block-secret-commit.sh`, which refuses any `git commit` that stages
  a file matching a known secret pattern. The hook is a backstop, not a strategy — keep secrets
  out of the working tree in the first place.
- Authenticate at API gateway. Validate tokens server-side. Use RLS where applicable.
- Log security events (auth failures, rate limits). Never log sensitive data.
- Fail securely — errors must not reveal system internals. Specific exceptions with context.

---

<a id="testing-quality"></a>

## Quality Gate

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

### Build Verification (commit-time gate)

Before any commit that includes code changes, run the project's build and confirm exit code 0.

The build is the last line of defense. A commit that lands on top of a broken build poisons
every commit after it and obscures which change actually caused the breakage.

Per stack:

- **npm / `wp-scripts` projects** — `npm run build` returns 0. Warnings are follow-up issues;
  errors block the commit.
- **Composer projects** — `composer install` returns 0.
- **Plain WordPress themes with no build pipeline** — not applicable, skip.
- **Docs-only commits** — not applicable, skip.

#### Exit code 0 is not sufficient

A build that reports success while emitting nothing has failed. Bundlers will happily print
"compiled successfully" after resolving an entry point that doesn't match your source layout,
producing an empty output directory in a few milliseconds. The exit code is clean. The artifact
is empty. Anything you commit on top of it is untested.

Verify that build artifacts **exist and have non-trivial size**, not just that the command
returned 0. A suspiciously fast build is the tell.

---

<!-- end generated content · digest: f7874a7a7dc7a79e -->
