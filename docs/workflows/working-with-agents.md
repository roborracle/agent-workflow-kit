# Working with skills, subagents, and hooks

Four kinds of thing ship in this kit, and they do genuinely different jobs. Knowing which is
which is the difference between a setup that helps and one that just costs tokens.

| | What it is | When it acts | Costs context |
|---|---|---|---|
| **Rule** | A standard the assistant reads | Always available | Yes, when loaded |
| **Skill** | A procedure it can follow | When invoked or when it matches the task | Only when invoked |
| **Subagent** | A specialist with its own context window | When delegated to | No — separate context |
| **Hook** | A shell script the harness runs | Before a matching tool call | None |

---

## Rules vs. hooks — the important distinction

A rule is text. A capable model can reason its way around any piece of text, and under pressure
it will: *this case is different, the user clearly wants me to proceed, the rule was written for
a different situation.*

A hook is a program that returns "deny". There is nothing to reason with.

So anything that genuinely must not happen is a hook, not a rule. The three in this kit — force
push, committed secrets, destructive operations — are the things where being talked out of it is
unacceptable. Everything else is a rule, because rules are cheaper and
allow judgment.

If you find yourself writing a rule that says "never, under any circumstances", you probably
want a hook.

---

## Subagents

Five ship with the kit. Each runs in its own context window, which is the point: they can read
fifty files and hand back a paragraph, and your main session never sees the fifty files.

| Subagent | Use it for | Notable |
|---|---|---|
| `debugger` | A bug, a failing test, unexplained behavior | Reproduces before fixing. Won't propose a fix it hasn't proven. |
| `security-auditor` | Vulnerability review, OWASP pass, pre-deploy check | **Read-only.** Cannot modify anything it audits. |
| `test-writer` | Adding coverage, fixing broken tests | Jest, Vitest, Playwright, Pytest, PHPUnit |
| `researcher` | Gathering information, comparing approaches | Runs on a fast model — cheap enough to use freely |
| `codebase-map` | An unfamiliar or inherited repository | Read-only. Produces an architectural map. |

`security-auditor` being unable to write is deliberate. An auditor that can edit the code it's
auditing will fix what it finds and report a clean result, and you lose the finding.

### Delegate when

- The task needs to read a lot to produce a little
- It's genuinely independent of what you're doing
- You want a second opinion that isn't anchored on the current conversation

### Don't delegate when

- It's a single file and under thirty minutes — the overhead exceeds the work
- The subagent would need context that only exists in your conversation
- **Two or more subagents would commit in the same working directory.** Give each a git worktree
  or run them one at a time. Concurrent agents interleave their git calls and produce commits
  whose messages describe work that landed somewhere else. Nothing errors. You find out weeks
  later when a revert takes three unrelated changes with it. See
  `skills/parallel-agent-git-isolation/SKILL.md`.

---

## Skills

43 of them. You don't need to remember the list — the assistant matches them to the task. The
ones worth knowing by name:

**Every session**
`/resume` picks up where the last session stopped. `/handoff` writes what the next session needs
— run it before you stop, not after you've forgotten.

**Before shipping**
`/code-reviewer` (security-first pass), `/a11y-audit` (WCAG 2.1 AA), `/dep-audit`,
`/release-manager` (version → tag → release → prod).

**When stuck**
`/unstuck` when you're looping on the same failing approach — it forces an architectural rethink
rather than another attempt. `/scrutinize` when a decision needs competing approaches evaluated
properly.

**Starting something**
`/init-project` scaffolds a new repository with the right config and a stack-appropriate pack.
`/sprint-planner` decomposes work into atomic, labeled issues.

Full list: [`docs/reference/skills.md`](../reference/skills.md).

---

## What this costs

The plugin reports roughly **3,800 tokens of always-on context** — that's every skill's name and
description, so the assistant knows what exists. Bodies load only when a skill actually fires.

Worth knowing when you're deciding whether to add something. A skill nobody invokes still charges
you its description on every request, forever. `claude plugin details agent-workflow` shows the
per-component breakdown.

---

## MCP servers

MCP servers extend what the assistant can reach — documentation, a browser, a connector. Each
enabled server costs context in every session, so turn them on as you need them rather than all
at once.

Setup is in [`docs/setup/03-keys-and-accounts.md`](../setup/03-keys-and-accounts.md). The rule
that matters: every credential is a `${VAR}` reference expanded from your environment, never a
literal value in `~/.mcp.json`.
