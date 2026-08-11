# Documentation Protocol

## Naming

- All documentation filenames are kebab-case.
- Exceptions: `CLAUDE.md`, `AGENTS.md`, `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`,
  `LICENSE.md`.

## Structure

- No `.md` files at the project root except the ones listed above.
- `docs/` uses subdirectories only — `technical/`, `strategy/`, `guides/`, `runbooks/`, etc.
  Nothing loose at `docs/` root.
- Hard ceiling of 350 lines on any single documentation file. Past that, split it.

## Rules

- No project-level copies of global rules or global skills. If you find yourself duplicating a
  rule from this kit into a project, either the rule is wrong or the project needs an override —
  write the override, not the copy.
- Keep the repository root clean. Working files go in `docs/` or a scratch directory that is
  gitignored.

## Project `CLAUDE.md` template

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

### Sample

```markdown
# {Project Name} — AI Assistant Context

**Last updated:** YYYY-MM-DD
**Status:** {one line — active phase, current milestone}

## Global rules

Inherits all rules from the ai-workflow-kit installation in `~/.claude/`.

## Project paths

- Git root: `{path}`
- Active source: `{path}`
- Read-only legacy: `{path}` (do not modify)

## Project context

- **Goal:** {what success looks like}
- **Audience:** {who uses this}
- **Stack constraints:** {version locks, infra limits, regulatory requirements}
- **Avoid:** {patterns, libraries, approaches that are off-limits here}

## Tech stack

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

## Project-specific overrides

- {override} — overrides {global rule}; reason: {why}

## Prior context

- `docs/{...}` — where the deep context lives
```

### When the template doesn't fit

If a project genuinely needs more than 80 lines of context, the excess belongs in `docs/`, not
in `CLAUDE.md`:

- Long architecture description → `docs/architecture/overview.md`
- Step-by-step workflows → a skill, if generally applicable, or `docs/workflows/`
- Historical context → `docs/{project}/recon.md` or equivalent
- Issue and sprint tracking → the issue tracker

`CLAUDE.md` is an index. It is not the body of the documentation.
