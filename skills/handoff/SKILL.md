---
name: handoff
description: "Use when ending, pausing, or wrapping up a working session, or when asked to write or update hand-off, continuity, or session-state docs (session end, hand off, wrap up, stopping here, pause work, update handoff)."
disable-model-invocation: true
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
---

# Session Hand-off

The read side of this is `resume`. This is the write side.

**Core principle: a hand-off is written for a reader with zero memory of this session.** Everything
you know that is not in a file is lost the moment the session ends. The test is not "did I write a
summary" — it is "could a stranger resume tomorrow without asking me anything."

## Step 0 — Find what already writes this. Do not skip.

Projects usually already have a hand-off mechanism, and hand-writing its output silently forks the
format.

```bash
ls .planning/ .continue-here.md 2>/dev/null
ls ~/.claude/commands/*/ 2>/dev/null | grep -iE "pause|handoff|session"
grep -rln "HANDOFF\|continue-here" ~/.claude/get-shit-done ~/.claude/commands 2>/dev/null
```

If a command owns the artifact, **match its schema exactly** — same filenames, same keys, same enum
values the reader parses. GSD projects: `/gsd:pause-work` writes `.planning/HANDOFF.json` **and**
`.planning/phases/XX/.continue-here.md`; `/gsd:resume-work` reads both. Writing one and not the other
leaves a half-handoff.

**Match the schema, not the framing.** Pause commands assume you stopped mid-task and hard-code that
assumption: `/gsd:pause-work` sets `"status": "paused"` and commits `wip: … paused at task X/Y`. If
your session ended *shipped*, running it unmodified writes a false state. Override exactly these:

| Field | Paused mid-task | Complete and shipped |
|---|---|---|
| `status` | `paused` / `in_progress` | `blocked` if a human gate remains, else `done` |
| commit prefix | `wip:` | `docs(handoff):` or `docs(log):` |
| `next_action` | the task you were inside | the gate or the next phase |

Use the reader's documented enum values — never invent one like `awaiting_checkpoint`, which parses
as nothing. Say in the commit body which defaults you overrode and why.

## The durability rule — the one that actually bites

Sort every fact into **one-shot** or **durable** before writing it anywhere.

| | One-shot | Durable |
|---|---|---|
| Holds | position, next action, in-flight state | environments, access, decisions, incidents, gotchas |
| Lifetime | consumed and **deleted** on resume | outlives every session |
| Home | `HANDOFF.json`, `.continue-here.md` | `docs/`, decision log, project README |

`.planning/HANDOFF.json` is explicitly deleted after a successful `/gsd:resume-work`. **Anything whose
only copy lives there dies on first resume.** Deploy commands, server access, why a decision was made,
how an incident was diagnosed — all durable. Put them in `docs/`, then *reference* them from the
one-shot file.

Before you finish, ask of every block you wrote: *if this file is deleted tomorrow, is anything
valuable gone?* If yes, move it and leave a pointer.

## If the artifact already exists — the usual case

Most invocations are a **delta pass, not a first write.** The file is there and mostly right, and
rewriting it wholesale churns good content and loses detail. Diff it instead:

1. **Re-verify every fact that can move**: SHAs, branch parity, dates, counts, phase/task numbers,
   "uncommitted files". Anything recording its own commit SHA is always one behind — prefer
   "last code commit X; docs commits after it" over a bare SHA that re-stales immediately.
2. **Check what already migrated.** If durable facts have since landed in `docs/`, do not duplicate
   them — replace with a pointer, and confirm the pointer's target is committed.
3. **Timestamps must be real.** A hand-typed midnight (`T00:00:00.000Z`) is a tell that nobody
   checked; take the actual time from the project's own tooling.
4. **Leave what is still true alone.** Only touch what drifted.

## What the hand-off must contain

Fill every slot. An empty slot is a finding, not an omission — write "none" and move on.

1. **Position** — phase/task, and whether it is *paused mid-task* or *complete and shipped*. These are
   different states; do not record shipped work as "paused at task N".
2. **What shipped** — with commit SHAs and issue numbers.
3. **What remains** — with enough context to start, not just a title.
4. **Blocked on a human** — separate from your own remaining work, and mark which are blocking.
5. **Decisions + rationale** — the *why*, because the what is already in the diff.
6. **Verification state** — what you actually ran and what it returned. "Tests pass" is worthless
   without which suites and how many.
7. **Incidents** — anything that broke and how it was fixed. Highest-value block for a successor;
   include the *symptom*, since that is what they will recognise.
8. **Next action** — one concrete first move, not a category.

## Sweep stale artifacts

Old hand-offs are read as current and actively mislead.

```bash
# Read the file's OWN claimed state. Git dates lie here: a stale checkpoint swept
# into an unrelated commit looks freshly touched.
for f in $(find .planning -name ".continue-here*.md" 2>/dev/null); do
  echo "$f: $(grep -hE '^(status|last_updated):' "$f" | tr '\n' ' ')"
done
```

A checkpoint whose own frontmatter says `phase_complete`, or that names a phase already closed, is
dead weight sitting in the resume path. **Deleting a tracked file is a confirmation gate** — propose
it with the evidence and wait. Meanwhile note it in the hand-off so a resume that trips over it knows
it is stale.

Also check the inverse: a `*-PLAN.md` with no matching `*-SUMMARY.md` makes a resume announce
incomplete work. If it is blocked on a human rather than unfinished, say so in a checkpoint — but
never write the missing SUMMARY yourself, which fakes a sign-off that never happened.

## Reconcile the whole file, not just your section

Hand-off files accrete. Adding a fresh block while an older block still says something else leaves
the file contradicting itself, and a stranger cannot tell which half to believe. **A file that
disagrees with itself is worse than one that is merely stale** — stale is at least consistently wrong.

After editing, grep the file for every date, SHA, phase number, and "last session" claim and make
them agree. Then check the pointers actually resolve:

```bash
grep -nE "last session|stopped at|[0-9a-f]{7}|20[0-9]{2}-[0-9]{2}" <handoff-file>
# every referenced path must exist AND be committed
git ls-files --error-unmatch <each-referenced-path>
```

A pointer to an uncommitted file is a dangling reference on every machine but yours.

## Verify before claiming

Do not write state you have not checked this session.

```bash
git status --porcelain                 # uncommitted_files must be true
git log --oneline <session-start>..HEAD
for b in main prod; do git rev-parse --short $b origin/$b; done
```

Then re-read the file as a stranger. If a claim cannot be traced to a file, command, or commit, cut it.

## Red flags — stop and fix

- Hand-writing a file that a command already owns
- Rich content in a file documented as one-shot or deleted-on-read
- Key names you invented sitting next to a parser that reads different ones
- "All tests pass" / "everything deployed" with no command or count behind it
- Recording shipped work as paused, or marking a phase advanced when a human gate is still open
- A stale checkpoint from a previous phase left in place
- A new block added while an older block in the same file still says something different
- A pointer to a file you have not committed

## Common mistakes

| Mistake | Fix |
|---|---|
| Writes a summary of *what happened* | Write what the next session must *do and know* |
| Durable facts in the one-shot file | Move to `docs/`, reference from the hand-off |
| Invented schema keys | Match the reader's parser, or you wrote for nobody |
| Advances phase state to feel finished | Human gates stay open until a human closes them |
| Buries the incident in prose | Give it its own block with the symptom first |
