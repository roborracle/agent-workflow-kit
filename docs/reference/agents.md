# Subagent catalog

Five specialists. Each runs in its own context window — they can read fifty files and hand back
a paragraph without any of those fifty files entering your session.

Ask for one by name ("use the debugger subagent on this") or describe the task and let the
assistant pick.

---

## `debugger`

**For:** a reported bug, a failing test, unexplained behavior, a performance regression.

Works in phases: reproduce, isolate, identify root cause, fix, verify no regression. It will not
propose a fix for something it hasn't reproduced — which is the whole point, because the fix for
a bug you haven't reproduced is a guess with a diff attached.

Can read and write. Memory is scoped to the project, so it accumulates that project's failure
patterns over time.

## `security-auditor`

**For:** vulnerability review, an OWASP Top 10 pass, dependency analysis, secrets detection,
pre-deploy checks.

**Read-only** — `Write` and `Edit` are explicitly denied. That's deliberate: an auditor that can
edit the code it's auditing will quietly fix what it finds and report clean, and you lose the
finding along with any record that it existed.

Runs on the strongest model available. Memory is scoped to the user, so vulnerability patterns
carry across projects.

## `test-writer`

**For:** adding coverage, fixing broken tests, validating a change.

Knows Jest, Vitest, Playwright, Pytest, and PHPUnit. Writes tests that catch real bugs rather
than tests that pass — a distinction worth enforcing in review, since coverage percentage is
easy to reach and easy to fake.

## `researcher`

**For:** investigating a question, comparing approaches, gathering documentation, finding where
something lives in a large codebase.

Read-only, and runs on a fast model — cheap enough to reach for freely. When you don't know
which of six files to read, this is faster than reading six files.

## `codebase-map`

**For:** an unfamiliar or inherited repository, onboarding onto a project, or a legacy codebase
nobody remembers.

Read-only. Scans structure, dependencies, entry points, data flow, and key abstractions, and
returns an architectural map. The first thing to run when you're handed something you've never
seen.

---

## Dispatching more than one

Fine when the tasks are genuinely independent — no shared files, no ordering dependency.

**Not fine when two or more will run `git add` / `git commit` / `git branch` in the same working
directory.** Their git calls interleave and produce commits whose messages describe work that
landed in a different commit, plus changes attributed to nothing. Nothing errors, the branch
looks normal, and you find out weeks later when reverting one change takes three others with it.

Give each agent its own git worktree, or dispatch them one at a time. See
`skills/parallel-agent-git-isolation/SKILL.md`.

---

## Adding one

`agents/<name>.md`, frontmatter with `name`, `description`, `tools`, and `model`. Use
`disallowedTools` when the agent should not be able to modify what it examines — the
`security-auditor` is the model to copy.

Keep the description specific about *when* to use it. That description is what the assistant
matches against, and a vague one means the agent never fires or fires constantly.
