# 2. Install

About 5 minutes.

---

## Authenticate with GitHub first

```bash
gh auth login
```

Choose **GitHub.com** → **HTTPS** → **authenticate in browser**. Let it configure git for you
when it offers.

Then set your commit identity, if you haven't on this machine:

```bash
git config --global user.name  "Your Name"
git config --global user.email "you@example.com"
```

This matters more than it looks. Your name on the commit is the authorship record for client
work — see `rules/git-workflow.md`.

---

## Clone and install

```bash
git clone https://github.com/roborracle/agent-workflow-kit.git
cd ai-workflow-kit
./scripts/install.sh --dry-run
```

Read the dry-run output. It lists every file it would write, back up, or leave alone. Then:

```bash
./scripts/install.sh
```

### What it does

- Installs `CLAUDE.md`, `rules/`, `skills/`, `agents/`, and `hooks/` into `~/.claude/`
- **Merges** `settings.example.json` into your `~/.claude/settings.json` — your existing keys
  win, and hooks you added yourself are kept alongside the kit's
- Creates `~/.config/agent-kit/env.sh` with mode 600 for your keys
- Records what it installed in `~/.claude/.agent-kit-manifest`

### What it will not do

- Overwrite a skill, agent, or `CLAUDE.md` you wrote yourself. It warns and skips. Pass
  `--force` if you actually want the kit's version.
- Replace anything without backing it up first, to `~/.claude/.backups/<timestamp>/`.
- Touch your keys, your shell profile, or anything outside `~/.claude` and
  `~/.config/agent-kit`.

### If you already had a Claude Code setup

The installer is built for exactly this case. It'll tell you which of your files it left alone;
compare them against the kit's versions and merge by hand whatever you want. Nothing is lost —
the backup directory has your originals.

---

## Alternative: install as a plugin

```
/plugin marketplace add roborracle/agent-workflow-kit
/plugin install agent-workflow@roborracle
```

Run these inside Claude Code. You get the 43 skills, 5 subagents, and 4 hooks, with updates
managed by `/plugin`.

**It does not install `CLAUDE.md` or `rules/`** — those are loaded from `~/.claude/`, which the
plugin system doesn't write to. So the plugin path gives you the tools but not the standards.
Run `./scripts/install.sh` as well, or copy `CLAUDE.md` and `rules/` into `~/.claude/` yourself.

For most people the script alone is the simpler answer.

---

## Uninstall

```bash
./scripts/install.sh --uninstall
```

Removes only what the kit installed, per the manifest. Your settings, personal skills, and
backups stay.

---

Next: [3. Keys and accounts](03-keys-and-accounts.md).
