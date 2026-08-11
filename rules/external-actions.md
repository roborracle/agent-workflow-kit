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

- **Slack** — `slack_send_message`, `slack_schedule_message`, `slack_add_reaction`, `slack_create_canvas`, `slack_update_canvas`, `slack_send_message_draft`
- **Gmail** — any send/reply/forward action
- **Google Calendar** — `create_event`, `update_event`, `delete_event`, `respond_to_event`
- **Google Drive** — `create_file`, `copy_file`, sharing permission changes
- **Asana** — `create_tasks`, `update_tasks`, `add_comment`, `create_project_*`, status updates
- **Canva** — `comment-on-design`, `export-design`, `commit-editing-transaction`, `request-outline-review`, anything that publishes
- **Figma** — `add_code_connect_map`, `send_code_connect_mappings`, `upload_assets`, `create_new_file` if it writes to a shared Figma team
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
