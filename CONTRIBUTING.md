# Contributing

This kit is the team's shared working agreement. It is meant to change — a rule nobody follows
is worse than no rule, and the way to fix that is to argue the rule down, not to quietly ignore
it.

## Before you open a pull request

```bash
./scripts/validate.sh
```

That runs everything CI runs: JSON parsing, skill and agent frontmatter, `AGENTS.md` freshness,
the hook test suite, shell syntax, a secret scan, and a check that no home paths or personal
addresses leaked into a public repository. If it passes locally, CI will pass.

## The one rule that trips people up

**Never edit `AGENTS.md` by hand.** It is generated from `CLAUDE.md` + `rules/`. Edit the source,
then:

```bash
./scripts/sync-agents-md.sh
```

and commit both. CI fails a pull request whose `AGENTS.md` doesn't match its sources, because a
drifted `AGENTS.md` means the Codex and Gemini users are silently working to a different standard
than everyone else.

## Adding a skill

```
skills/<name>/SKILL.md
```

One level deep — exactly `skills/<name>/SKILL.md`. Anything nested deeper is invisible to the
plugin loader, and it fails silently: the skill simply never fires and nobody finds out why.

Frontmatter needs `name` and `description`, and `name` must equal the directory name. Write the
description for the reader who has to decide whether to invoke it — say when to use it, not what
it is.

Supporting files (templates, references, checklists) go beside `SKILL.md` in the same directory.
Keep `SKILL.md` itself short; it is loaded far more often than it is followed.

## Adding or changing a rule

Rules are expensive. Each one is text that some assistant reads on some fraction of sessions
forever. Before adding one, check whether an existing rule covers it, and whether the problem is
better solved by a hook — a hook can't be rationalized past, and costs no context at all.

If you change a rule, say in the pull request body what went wrong that motivated it. A rule
without a reason attached gets deleted by the next person who finds it inconvenient.

## Adding a hook

Hooks are the enforcement layer, so they get held to a higher standard than the rest of the kit.

Add tests to `tests/hooks.test.sh` in **both** directions: the thing it should block, and at
least two realistic things it must not block. An over-blocking hook is worse than no hook,
because people turn it off and lose the real protection along with the false positive.

## Commits

Conventional commits, per `rules/git-workflow.md`.

## What does not belong here

This repository is public. Client names, project names, hostnames, internal URLs, credentials,
and anything else specific to work we've been paid for go in the private companion repository
instead. `./scripts/validate.sh` catches the obvious cases; it cannot catch a client's name in a
code comment. Read your own diff.
