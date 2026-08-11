# Agent Workflow Kit

An opinionated working setup for Claude Code: standards the assistant is held to, skills it can
invoke, subagents it can delegate to, and hooks it cannot argue its way past.

Clone it, run one script, and your assistant stops improvising. You keep your own accounts and
your own keys throughout — nothing here is shared credentials, and nothing phones home.

**New here?** Work through [`docs/setup/`](docs/setup/) in order. About 20 minutes.

---

## What's in it

| | | |
|---|---|---|
| **11 rules** | Standards, loaded on demand | Git workflow, security, testing gates, decision boundaries, reporting discipline |
| **43 skills** | Procedures it can invoke | Code review, releases, migrations, incident response, accessibility audits, sprint planning |
| **5 subagents** | Specialists with their own context | `debugger`, `security-auditor`, `test-writer`, `researcher`, `codebase-map` |
| **3 hooks** | Enforcement that can't be argued with | Blocks force pushes, committed secrets, destructive operations |
| **4 scripts** | Setup and diagnosis | `install.sh` (non-destructive), `doctor.sh`, `validate.sh`, `sync-agents-md.sh` |

Rules are advice — a capable model can reason its way around any piece of text, and under
pressure it will. Hooks are programs that return "deny". That's why the things that genuinely
must not happen are hooks, and everything else is a rule.

---

## Setup

### 1. Prerequisites

```bash
brew install git gh jq node          # macOS. Linux: apt/dnf equivalents.
npm install -g @anthropic-ai/claude-code
```

`jq` is not optional — the hooks parse their input with it, and they **fail open** without it.

### 2. Install

```bash
git clone https://github.com/roborracle/agent-workflow-kit.git
cd agent-workflow-kit
./scripts/install.sh --dry-run       # see exactly what it would touch
./scripts/install.sh
```

It will not clobber your existing setup. Anything it replaces is backed up to
`~/.claude/.backups/<timestamp>/`, `settings.json` is **merged** rather than overwritten, and any
skill or agent you wrote yourself is skipped unless you pass `--force`.

<details>
<summary>Or install it as a plugin</summary>

```
/plugin marketplace add roborracle/agent-workflow-kit
/plugin install agent-workflow@roborracle
```

You get the skills, subagents, and hooks with managed updates. It does **not** install
`CLAUDE.md` or `rules/` — the plugin system doesn't write to `~/.claude/`, so the plugin path
gives you the tooling without the standards. Run `./scripts/install.sh` as well, or copy those
two in yourself.
</details>

### 3. Verify

```bash
./scripts/doctor.sh
```

Every failure prints the command that fixes it. Don't start working until it's clean — a
half-installed kit fails silently, and everything looks fine.

---

## How work flows

```
issue  →  branch  →  build  →  verify  →  PR  →  merge  →  deploy
```

The two steps people skip are *issue* and *verify*, and they're the two that cost the most.

Issues carry three orthogonal labels — `priority/*`, `type/*`, `area/*` — and severity lives in
`priority/` and nowhere else. Commits are conventional and atomic; if the body needs the word
"also", it's two commits. Nothing is "done" until the tests, types, lint, and build have been run
*and looked at*.

Full version, including what to do when a project doesn't fit this shape:
[`docs/workflows/how-work-flows.md`](docs/workflows/how-work-flows.md).

---

## Day-to-day

| You want to | Do this |
|---|---|
| Pick up where you left off | `/resume` |
| Wrap up a session for your future self | `/handoff` |
| Review code before a PR | `/code-reviewer`, or the `security-auditor` subagent |
| Find a bug properly | The `debugger` subagent — it reproduces before it fixes |
| Understand an unfamiliar repo | The `codebase-map` subagent |
| Start a new project | `/init-project` |
| Ship a release | `/release-manager` |
| Handle a production incident | `/incident-response` |

Full catalogs: [skills](docs/reference/skills.md) · [subagents](docs/reference/agents.md) ·
[rules](docs/reference/rules.md) · [hooks](docs/reference/hooks.md)

---

## Using something other than Claude Code

Codex, Gemini CLI, Cursor, and most others read a single instruction file and have no concept of
on-demand rules. [`AGENTS.md`](AGENTS.md) is that file — the same standards with every rule
inlined.

It's generated from `CLAUDE.md` + `rules/`, and CI rejects a pull request where the two have
drifted, so it can't quietly go stale. The skills and subagents are Claude Code features and
won't carry over; the standards will.

---

## Staying current

```bash
git pull && ./scripts/install.sh && ./scripts/doctor.sh
```

`doctor.sh` tells you when your clone is behind the latest release.

---

## What this costs

The plugin reports roughly **3,800 tokens of always-on context** — every skill's name and
description, so the assistant knows what exists. Bodies load only when a skill fires. Run
`claude plugin details agent-workflow` for the per-component breakdown.

Worth knowing before you add anything: a skill nobody invokes still charges you its description
on every request, forever.

---

## Opinions you may want to change

This is a working setup, not a neutral framework. Some defaults are deliberately strict:

- **An issue exists before code does.** Reasonable for team work, heavy for a weekend project.
- **80% test coverage, zero lint errors, zero type errors** before anything is "done".
- **Dual `main`/`prod` branches.** Plenty of projects are fine with one branch and a gated
  pipeline — the kit just insists the project say which it uses.
- **Permission prompts stay on.** `skipDangerousModePermissionPrompt` is deliberately absent.

Every one of these is a file you can edit. `rules/` is the whole surface.

---

## Contributing

Issues and pull requests welcome. Run `./scripts/validate.sh` first — it's exactly what CI runs.
See [`CONTRIBUTING.md`](CONTRIBUTING.md).

MIT licensed. Copyright © 2026 Robert David Orr.
