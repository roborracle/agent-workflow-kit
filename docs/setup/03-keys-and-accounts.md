# 3. Keys and accounts

Every person uses their own credentials for everything. No exceptions, no shared logins.

Not because of policy theatre — because a shared key can't be attributed to anyone, can't be
revoked for one person, and makes offboarding a guess about what to rotate. Per-person
credentials cost nothing and remove all three problems.

---

## Where keys live

One file, mode 600, outside any repository:

```
~/.config/agent-kit/env.sh
```

`install.sh` creates it. Open it and fill in only what you actually need:

```bash
$EDITOR ~/.config/agent-kit/env.sh
```

```bash
# export ANTHROPIC_API_KEY=""   # only if you bill per token rather than using a subscription
# export CONTEXT7_API_KEY=""    # context7 MCP server
# export OPENAI_API_KEY=""      # only if you use Codex
```

Leave a line commented out until the service is actually in your way. An unused key is still a
key someone can steal.

Then source it from your shell:

```bash
echo '[ -f "$HOME/.config/agent-kit/env.sh" ] && . "$HOME/.config/agent-kit/env.sh"' >> ~/.zshrc
exec zsh
```

(`~/.bashrc` if you use bash.)

---

## The rules

**Never paste a key into a file inside a repository.** Not `.env` that you'll "remember to
gitignore", not a config file, not a comment, not a test fixture. `hooks/block-secret-commit.sh`
will refuse the commit, but treat that as a safety net that fired, not as the workflow.

**Never paste a key into a chat, an issue, or a ticket.** If you need to hand someone a
credential, use the password manager.

**A key that has been committed is compromised.** Even to a private repository, even if you force
push it away — assume it was seen, rotate it. Rotating takes two minutes. Not rotating is a
finding in an audit.

**Rotate on any suspicion, and when someone leaves.** Both are cheap. Neither is optional.

---

## Claude

Most people sign in with a **Claude subscription**: run `claude`, follow the browser prompt,
done. No key to manage, nothing to put in `ai-env.sh`.

You only need `ANTHROPIC_API_KEY` if you're building something that calls the API directly, or
running automation that can't do an interactive login. If you're not sure, you don't need it.

---

## MCP servers

MCP servers give the assistant extra abilities — reading documentation, driving a browser,
reaching a connector. They're opt-in, and each one you enable costs context in every session, so
enable them as you need them rather than all at once.

```bash
cp mcp/.mcp.example.json ~/.mcp.json
```

The example ships three: `memory` and `browser` need no credentials at all, `context7` wants a
free key for documentation lookups.

Every credential in that file is written as `${VAR_NAME}` and expanded from your environment at
launch. **Keep it that way.** A literal key in `~/.mcp.json` is one screen-share away from being
someone else's key — `doctor.sh` checks for exactly this and fails if it finds one.

Connectors for project management, chat, storage, and design tools authenticate interactively
with your own account rather than through this file. Treat every one of them as write-gated —
see `rules/external-actions.md`.

---

## Check it

```bash
ls -l ~/.config/agent-kit/env.sh     # should read -rw-------
./scripts/doctor.sh
```

Next: [4. Verify](04-verify.md).
