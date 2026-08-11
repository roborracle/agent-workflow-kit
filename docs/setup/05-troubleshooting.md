# 5. Troubleshooting

Start with `./scripts/doctor.sh` — most of what follows is here because the fix isn't obvious
from the failure message.

---

## The hooks don't block anything

**The assistant hasn't reloaded its settings.** Hooks are read at session start. Restart the
session after any install or settings change.

**`jq` isn't installed.** The hooks parse their input with `jq`; without it they exit without
deciding, which means everything is allowed. `brew install jq`, then restart.

**The hook files aren't executable.** `chmod +x ~/.claude/hooks/*.sh`. Re-running
`./scripts/install.sh` also fixes it.

**You installed the plugin instead of running the script.** Plugin hooks live in the plugin's
own directory and are wired by `hooks/hooks.json`. Confirm with `claude plugin details
agent-workflow` — the inventory should show `Hooks (1) PreToolUse`.

---

## A hook is blocking something legitimate

Say so — an over-blocking hook is a bug in this repository, and the fix is a test case plus a
narrower pattern. Open an issue with the exact command that got refused.

Two known-and-accepted over-blocks:

- `block-force-push.sh` matches the text `git push --force` anywhere in a command, including
  inside a quoted string. Refusing to echo a sentence about force pushing is a fair trade for a
  simple, auditable pattern.
- `block-destructive-ops.sh` refuses `git reset --hard origin/main`. That's a legitimate move
  when you're deliberately discarding local work — do it in your own terminal rather than through
  the assistant.

**Do not disable a hook to get past it.** If it's wrong, fix it in the repository so it's fixed
for everyone.

---

## The assistant ignores the standards

**`~/.claude/CLAUDE.md` doesn't exist.** The most common cause: you installed the plugin, which
doesn't write `CLAUDE.md`. Run `./scripts/install.sh`.

**A project-level `CLAUDE.md` is overriding it.** Project files layer on top of the global one.
Check the repository root.

**Your own `CLAUDE.md` was preserved.** The installer refuses to overwrite a `CLAUDE.md` you
wrote. It says so, but it's easy to miss in the output. `./scripts/install.sh --force` takes the
kit's version, after backing yours up.

---

## Skills don't appear

**Wrong nesting.** Skills must be exactly `skills/<name>/SKILL.md`. Nested any deeper and the
loader doesn't find them — silently, with no error. `./scripts/validate.sh` catches this.

**Frontmatter is malformed.** Needs `name` and `description`, and `name` must match the directory.
Also caught by `validate.sh`.

**Restart needed.** Skills are enumerated at session start.

---

## `install.sh` fails on `settings.json`

Your existing `~/.claude/settings.json` isn't valid JSON — usually a trailing comma from a
hand-edit. The installer refuses to merge into a file it can't parse, because a bad merge would
silently drop your configuration.

```bash
jq empty ~/.claude/settings.json     # shows the line and column
```

Fix it, then re-run. If you'd rather start over, move it aside and let the installer write a
fresh one from the baseline.

---

## Permission prompts on every command

That's working as intended. `skipDangerousModePermissionPrompt` is deliberately not in the team
baseline: the prompt is the last gate before an irreversible command runs against a client
environment.

You can turn it off in your own `~/.claude/settings.json` if you understand the trade. Don't add
it to this repository.

---

## `doctor.sh` can't check for updates

It needs `gh` authenticated and network access to read the latest release. This one is only a
warning — nothing is broken. Compare `.claude-plugin/plugin.json` against the
[releases page](https://github.com/roborracle/agent-workflow-kit/releases) by hand if you care.

---

## Everything is strange and you want a clean slate

```bash
./scripts/install.sh --uninstall
ls ~/.claude/.backups/                  # your originals are in here
./scripts/install.sh
./scripts/doctor.sh
```

---

## Still stuck

Open an issue on this repository with: what you ran, what you expected, what happened, and the
full `./scripts/doctor.sh` output. If it confused you it will confuse the next person, and the
answer belongs in this file.
