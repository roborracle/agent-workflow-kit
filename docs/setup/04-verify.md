# 4. Verify

Don't start working until this is clean. A half-installed kit fails quietly — the standards
aren't loaded, the hooks don't fire, and everything *looks* fine.

---

## Run the doctor

```bash
cd ai-workflow-kit
./scripts/doctor.sh
```

It checks, in order:

1. Required tools are installed
2. You're authenticated with GitHub
3. Your git commit identity is set
4. The kit is installed, and `~/.claude/CLAUDE.md` matches your clone
5. All three hooks are wired *and* executable
6. `ai-env.sh` exists with mode 600, and `~/.mcp.json` has no literal keys
7. Your clone isn't behind the latest release

Every failure prints the command that fixes it. Warnings are optional — they flag things that
aren't blocking you.

---

## Prove the hooks actually fire

The doctor confirms the hooks are wired. This confirms they work. Worth doing once, because a
hook that's configured but broken is the worst of both worlds.

```bash
./tests/hooks.test.sh
```

21 tests, both directions — each hook must block what it targets *and* stay out of the way of
ordinary work.

Then try it live. In a scratch git repository, write a file containing a fake AWS key
(`AKIAIOSFODNN7EXAMPLE`), stage it, and ask your assistant to commit. It should be refused with a
message pointing at `rules/security.md`. If the commit goes through, the hooks aren't loaded —
restart your assistant so it re-reads `settings.json`, then re-run `doctor.sh`.

---

## Confirm the assistant loaded the standards

Start a session and ask:

> What are the four confirmation gates, and where is the label taxonomy defined?

A correct answer names the four gates (significant content rewrites; deletions and overwrites;
deploys, migrations, and irreversible operations; external sends) and points at
`rules/git-workflow.md` for `priority/*`, `area/*`, and `type/*`.

If it doesn't know, `CLAUDE.md` isn't loading. Check that `~/.claude/CLAUDE.md` exists and
restart the session.

---

## Working checklist

- [ ] `./scripts/doctor.sh` reports no failures
- [ ] `./tests/hooks.test.sh` passes
- [ ] A commit containing a credential is refused
- [ ] The assistant can state the four gates

All four → you're set up. Start with [how work flows](../workflows/how-work-flows.md).

Something failing → [5. Troubleshooting](05-troubleshooting.md).
