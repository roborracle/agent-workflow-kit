# Project Memory

Every project keeps a persistence layer, so that context survives a session ending, a laptop
rebooting, or the work changing hands.

## If the project uses a planning framework

If the project has a framework-managed planning directory (for example `.planning/`), that is
the persistence layer. Use the framework's own workflows for decisions, plans, session state,
and retrospectives. Do **not** also create `MEMORY.md` and `ERRORS.md` — the framework already
covers them.

## Otherwise: two files at the project root

### `MEMORY.md` — the decision log

After any significant decision, append:

```
## YYYY-MM-DD — {short title}

**Decided:** {what was decided}
**Why:** {the constraint, requirement, or incident that motivated it}
**Rejected:** {what was considered and rejected, and why}
```

Read `MEMORY.md` at the start of every session. Never contradict a logged decision without
flagging the contradiction first.

The "Rejected" line is the one that earns its keep. Without it, the next person re-proposes the
rejected option six weeks later and nobody remembers why it was a bad idea.

### `ERRORS.md` — the failure log

When an approach takes more than two attempts to work, append:

```
## YYYY-MM-DD — {short title}

**Attempted:** {what didn't work}
**Worked:** {what worked instead}
**Note for next time:** {what to try first if this pattern reappears}
```

Check `ERRORS.md` before proposing an approach to a similar task.

## Session boundaries

**Start.** Read `MEMORY.md` and `ERRORS.md` (or the framework equivalents) before significant
work. Surface anything load-bearing in the conversation rather than silently absorbing it.

**End.** When someone says "session end", "wrapping up", "let's stop here", or equivalent,
append:

```
## YYYY-MM-DD — Session summary

**Worked on:** {what was tackled}
**Completed:** {what shipped}
**In progress:** {what's mid-stream}
**Decisions made:** {pointers to the MEMORY.md entries}
**Next session priorities:** {ordered list}
```

## Never run both systems at once

Use either the framework's planning directory or `MEMORY.md` + `ERRORS.md`. Never both. A
project mid-migration finishes the migration before merging memory state.

## Relationship to per-user assistant memory

Some assistants keep their own per-user memory store of cross-project facts — preferences,
working style, validated patterns. That is a different thing from project memory. Project memory
is scoped to the project, lives in the repository, and is visible to everyone on the team. Facts
that only matter to one person's setup do not go in it.
