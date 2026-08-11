# 1. Prerequisites

Everything you need on the machine before installing the kit. About 10 minutes, most of it
waiting on downloads.

---

## Tools

| Tool | Why | Required? |
|------|-----|-----------|
| `git` | Everything | Yes |
| `jq` | The safety hooks parse their input with it | Yes |
| `gh` | GitHub CLI — issues, PRs, org access | Yes |
| `node` | MCP servers and most build tooling run on it | Yes |
| `claude` | The assistant itself | If you're using Claude Code |
| `shellcheck` | Only needed if you contribute to this repo | No |

`jq` deserves a note: without it the hooks can't read their input and silently stop protecting
you. `doctor.sh` checks for it specifically.

### macOS

```bash
# Homebrew, if you don't have it
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install git gh jq node
npm install -g @anthropic-ai/claude-code
```

If `git` prompts to install Command Line Tools, let it finish first, then re-run.

### Linux (Debian/Ubuntu)

```bash
sudo apt update && sudo apt install -y git jq curl

# GitHub CLI — not in the default repositories
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  | sudo tee /etc/apt/sources.list.d/github-cli.list
sudo apt update && sudo apt install -y gh

# Node via nvm, so you aren't fighting sudo for global installs
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
source ~/.nvm/nvm.sh && nvm install --lts

npm install -g @anthropic-ai/claude-code
```

### Windows

Use WSL2 with Ubuntu and follow the Linux instructions inside it. The hooks are bash scripts and
the whole kit assumes a Unix filesystem. Native Windows is not supported.

---

## Accounts

**GitHub.** The issue and pull-request workflow assumes `gh` is authenticated. Everything else in
the kit works without it, but you'd be dropping the parts that matter most.

**Claude.** Either a Claude subscription (you sign in through the browser, no API key to manage)
or an Anthropic API key if you're doing something that bills per token. If you don't know which
you have, you have a subscription.

That's the whole list. The kit deliberately doesn't require anything else — MCP servers and
connectors are opt-in, and the two that ship enabled by default need no credentials at all.

---

## Check yourself

```bash
git --version && gh --version && jq --version && node --version && claude --version
```

Five version strings, no "command not found" → continue to
[2. Install](02-install.md).
