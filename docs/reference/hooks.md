# Hooks

Three shell scripts that run before every `Bash` tool call and can refuse it.

Hooks exist because rules don't always hold. A rule is text, and a capable model can reason its
way around any piece of text — *this case is different, they clearly want me to proceed*. A hook
returns "deny" and there is nothing to argue with.

So the three things that genuinely must not happen are hooks. Everything else is a rule, because
rules are cheaper and leave room for judgment.

They cost no model context at all — the harness runs them, the model never sees them.

---

## `block-force-push.sh`

Refuses `git push --force`, `-f`, and `--force-with-lease` on any branch.

Rewriting history on a branch someone else has pulled destroys their work silently. If history
genuinely needs rewriting, that's a decision for the branch owner to make deliberately in their
own terminal.

The pattern matches `-f` only as a standalone argument, so a branch named
`feature/corpus-coverage-fill` doesn't trip it. It does match the text anywhere in the command,
including inside a quoted string — refusing to echo a sentence about force pushing is a fair
trade for a pattern that's simple enough to audit.

## `block-secret-commit.sh`

Refuses a `git commit` that stages an environment file or a credential-shaped string.

Checks two things: staged `.env` files (`.env.example`, `.env.sample`, and `.env.template` are
fine — those are the documented placeholders), and the staged diff against patterns for AWS,
Anthropic, OpenAI, GitHub, Slack, Google, and PEM private keys, plus a generic
`password = "…"` shape.

This is a backstop, not a strategy. A credential that reaches a remote — even a private one —
has to be treated as compromised and rotated. The hook is much cheaper than that.

## `block-destructive-ops.sh`

Refuses three classes of command with no undo:

- Recursive deletes aimed at `/`, `~`, or `$HOME` — including the classic `rm -rf $BUILD_DIR`
  where `BUILD_DIR` is unset and expands to nothing
- `DROP DATABASE`, `DROP SCHEMA`, `TRUNCATE TABLE`, `wp db drop`, `wp db reset`
- `git filter-branch`, `git filter-repo`, and `git reset --hard origin/<shared-branch>`

Ordinary work is unaffected: `rm -rf node_modules`, `wp db export`, and `git reset --hard HEAD~1`
all pass.

---

## Testing

```bash
./tests/hooks.test.sh
```

27 cases, both directions. Every hook is tested for what it must block *and* for realistic things
it must not — an over-blocking hook is worse than no hook, because people disable it and lose the
real protection along with the false positive.

If a hook blocks something legitimate, that's a bug in this repository. Open an issue with the
exact command. Don't disable the hook locally — fix it for everyone.

---

## How they're wired

**Script install:** `settings.example.json` merges a `PreToolUse` block into
`~/.claude/settings.json`, pointing at `~/.claude/hooks/*.sh`. The merge unions hook arrays, so
hooks you added yourself survive.

**Plugin install:** `hooks/hooks.json` wires them from `${CLAUDE_PLUGIN_ROOT}`.

Having both is harmless — a denied command is denied twice.

They all need `jq`. Without it they exit without deciding, which means everything is allowed.
`doctor.sh` checks for this specifically.
