#!/usr/bin/env bash
# PreToolUse(Bash) — refuse force pushes.
#
# Rewriting history on a branch anyone else has pulled destroys their work silently.
# See rules/git-workflow.md § Never.
#
# Reads the Claude Code PreToolUse event as JSON on stdin.

set -uo pipefail

INPUT=$(cat)
COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')

[ -z "$COMMAND" ] && exit 0

# Match -f / --force / --force-with-lease only as a standalone argument: preceded by
# whitespace, followed by whitespace, '=', or end of string. Using POSIX [[:space:]] rather
# than \s avoids matching the "-f" substring inside branch names such as
# "feature/corpus-coverage-fill".
if printf '%s' "$COMMAND" | grep -qiE 'git[[:space:]]+push.*[[:space:]](-f|--force(-with-lease)?)([[:space:]]|=|$)'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Force push blocked (rules/git-workflow.md). If history genuinely needs rewriting, that is a decision for the branch owner to make by hand — not something to do mid-task."
    }
  }'
fi

exit 0
