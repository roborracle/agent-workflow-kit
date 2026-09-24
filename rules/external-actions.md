---
description: Confirmation gate for any tool call that sends, posts, publishes, or creates external state. Includes all MCP tools targeting third-party systems.
globs: *
alwaysApply: true
---

# External Actions — Confirmation Gate

This is gate category 4 in `CLAUDE.md` → "Autonomous Execution".

## The rule

Before any MCP tool call (or any other action) that sends, posts, publishes, schedules, comments, or creates external state — state the action and target in plain language, then wait for explicit in-session yes. Prior approval does NOT carry forward. Each external action requires fresh confirmation in the current message.

## Covered surfaces (non-exhaustive)

Tool names change as MCP servers update, so match on what a call does, not on its name.

- **Messaging** (Slack, email): sending, scheduling, replying, forwarding, reacting, drafting into a shared space, creating or editing canvases.
- **Calendars**: creating, updating, deleting, or responding to events.
- **File stores** (Google Drive and similar): creating or copying files and changing sharing permissions.
- **Project management** (Asana and similar): creating or updating tasks and projects, commenting, posting status updates.
- **Design tools** (Canva, Figma): commenting, exporting, publishing, committing edits, uploading assets, or creating files in a shared team.
- **Any new MCP tool** that creates state outside this conversation — default to gated unless its description is explicitly read-only.

## What does NOT trigger the gate

- Read-only MCP tools (search, get, list, read, fetch).
- Local file edits (covered by other gates if applicable).
- Tool calls inside the user's own environment that produce no externally-visible state.

When unsure whether a tool sends or only reads, treat it as gated and ask.

## What the confirmation looks like

State three things, then wait:
1. **What** — the action class and the specific tool.
2. **Where** — the target (channel, recipient, doc URL, calendar, etc.).
3. **Content** — a short preview of what will be sent (if the user hasn't already authored it verbatim).

Wait for "yes" in the current message. "Earlier you said go ahead" is not confirmation.

## When the user pre-authorizes

If the user explicitly says "send the message I just wrote to #general — yes, do it now" in the current message, that IS the confirmation. The gate fires on assumed authorization, not on explicit-in-the-message authorization.
