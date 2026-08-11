# Rules

Eleven files in `rules/`, plus `CLAUDE.md` which holds the directives themselves and points at
the rest.

`CLAUDE.md` is deliberately short — every line in it is loaded into every session for every
person on the team. The rules it references load only when relevant.

| Rule | Read it when |
|---|---|
| [`git-workflow.md`](../../rules/git-workflow.md) | Filing an issue, naming a branch, writing a commit, choosing a label, dispatching parallel agents |
| [`decision-boundaries.md`](../../rules/decision-boundaries.md) | You're unsure whether to proceed or ask. The four confirmation gates live here. |
| [`security.md`](../../rules/security.md) | Handling input, storing secrets, writing auth, logging anything |
| [`coding-standards.md`](../../rules/coding-standards.md) | Naming, file size, type safety, what's prohibited |
| [`testing-quality.md`](../../rules/testing-quality.md) | Before calling anything done. The build-verification gate is here. |
| [`code-cleanup-safety.md`](../../rules/code-cleanup-safety.md) | Refactoring, or editing prose someone else wrote |
| [`reporting-discipline.md`](../../rules/reporting-discipline.md) | Reporting what you found — inspected vs. sampled, verified vs. inferred |
| [`external-actions.md`](../../rules/external-actions.md) | Anything that sends, posts, publishes, or schedules |
| [`documentation-protocol.md`](../../rules/documentation-protocol.md) | Naming a doc, structuring `docs/`, writing a project `CLAUDE.md` |
| [`cache-protocols.md`](../../rules/cache-protocols.md) | Something works locally but not after deploy |
| [`project-memory.md`](../../rules/project-memory.md) | Starting or ending a session on a project |

---

## The five that get broken most

**Verify before done.** Never report complete without proving it. Run the tests, read the output,
show it. Exit code 0 is not proof — a build can report success and emit nothing.

**An issue exists before code does.** The issue queue is the record of work state. Not Slack,
not a text file, not memory.

**Atomic commits.** One purpose each. If the body needs "also", split it.

**Halt when you'd be guessing.** Ambiguous scope, undocumented business logic, contradictory
prior commits, client data at risk. Asking costs one message. Guessing wrong costs everything
built on the wrong assumption.

**Inspected is not sampled.** "Checked all 562 results" when you read seven of them is a false
report, and it's load-bearing when someone acts on it.

---

## Changing a rule

Rules are meant to be argued with — a rule nobody follows is worse than no rule, because it
teaches people that the standards are decorative.

If one is wrong, open a pull request against it and say in the body what went wrong that
motivates the change. A rule without a reason attached gets deleted by the next person who finds
it inconvenient.

Before adding a new one, ask whether a hook would do the job better. Hooks can't be reasoned
past and cost no context. See [`CONTRIBUTING.md`](../../CONTRIBUTING.md).

---

## For non-Claude assistants

[`AGENTS.md`](../../AGENTS.md) contains all eleven rules inlined, generated from these sources.
CI rejects a pull request where the two have drifted.
