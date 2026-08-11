# How work flows

```
issue  →  branch  →  build  →  verify  →  PR  →  merge  →  deploy
```

Seven steps. The two people skip are *issue* and *verify*, and those are the two that cost the
most when skipped.

---

## 1. Issue

**No issue, no work.** The issue queue is the record of what's happening — not Slack, not a
scratch file, not your memory of what you agreed in a meeting.

```bash
gh issue create --title "fix(seo): canonical tag missing on archive pages" \
  --label "priority/P1,type/bug,area/seo"
```

Every issue carries three kinds of label:

| Namespace | Means | Values |
|---|---|---|
| `priority/*` | How urgent | `P0` critical · `P1` high · `P2` medium/low |
| `type/*` | What kind | `bug` `feature` `chore` `refactor` `docs` |
| `area/*` | What domain | `wordpress` `laravel` `next` `seo` `perf` `a11y` `security` … |

Run `gh label list` before creating a label. Reuse what fits. Never create a bare `critical` or
`high` label — severity lives in `priority/*` and nowhere else.

An issue needs acceptance criteria. "Fix the header" is not a criterion; "the canonical tag
resolves to the paginated URL on `/blog/page/2`" is.

**Exceptions** — a typo fix, a log-append commit, or a wave-wiring commit that lists its issue
IDs. Everything else needs an issue first. Details in `rules/git-workflow.md`.

### Make each issue atomic

One concern, committable on its own, independently verifiable, mergeable without waiting on a
sibling. If it touches two domains, it's two issues. Splitting up front is cheap; splitting a
half-built branch is not.

---

## 2. Branch

```bash
git checkout main && git pull
git checkout -b feature/canonical-tag-pagination
```

`feature/kebab-case` for work, `hotfix/description` for emergencies. Short-lived — a branch open
for three weeks is a merge conflict with a countdown on it.

---

## 3. Build

Conventional commits, atomic:

```
fix(seo): resolve canonical tag to paginated URL

Archive pages past page 1 emitted the page-1 canonical, collapsing
the series in the index.

Closes #142
```

If the body needs the word "also", it's two commits.

**Working with the assistant here**: it should present two or three approaches before anything
non-trivial, use plan mode for work with three or more steps, and stop rather than guess when
scope is ambiguous. If it's guessing, tell it to stop — that behavior is in the standards and
it's supposed to be held to them.

---

## 4. Verify

This is the step people skip, and the one the standards are strictest about. **Never report a
task complete without proving it works.**

- Tests pass — unit and integration
- Type checker: zero errors
- Linter: zero errors
- The build returns 0 **and produces artifacts**

That last one is not pedantry. A bundler will print "compiled successfully" in fifty
milliseconds after resolving an entry point that doesn't match your source layout, and write
nothing at all. The exit code is clean. The output directory is empty. Everything committed on
top of it is untested. A suspiciously fast build is the tell — check that the artifacts exist and
have real size.

If the UI changed: Chrome, Firefox, Safari, and mobile at 360×800.

---

## 5. Pull request

```bash
gh pr create --fill
```

The PR body should say what changed, why, and how it was verified — the actual commands and
their output, not "tested locally". See `rules/reporting-discipline.md`: distinguish what you
*inspected* from what you *sampled*, and what you *verified* from what you're *inferring*.

For review, the `security-auditor` subagent reads a diff for vulnerabilities without being able
to modify anything, and `/code-reviewer` does a general pass. Neither replaces a person reading
it.

---

## 6. Merge

Squash or merge into `main` once review passes and CI is green. Delete the branch. Close the
issue if the PR didn't close it automatically.

---

## 7. Deploy

`main` is development. `prod` is what a client can see. Promotion happens deliberately, never
automatically, and never with failing tests.

Not every project uses the dual-branch model — some use a single branch with a gated pipeline.
Whichever it is, the project's own `CLAUDE.md` must say so, so nobody has to guess.

Deployment procedures are project-specific by nature. Document yours in the project's own
`CLAUDE.md` or a runbook — including the rollback command, which nobody should be working out
for the first time during an incident.

---

## When something goes wrong in production

`/incident-response` walks triage → mitigate → root cause → blameless postmortem. Mitigate
first: restore service, then find out why. A rollback you can explain afterwards beats a fix you
reasoned about while the site was down.

---

## The four times to stop and ask

Autonomy is the default, for you and for the assistant. These four override it:

1. **Significant rewrites** of content someone else wrote.
2. **Deletions and overwrites** — files, schemas, dependencies, branches, history.
3. **Deploys, migrations, and anything irreversible.** Approval for one is not approval for the
   next.
4. **External sends** — anything that creates state outside the conversation.

Plus the general case: if you'd be guessing, stop. `rules/decision-boundaries.md` has the full
protocol.
