#!/usr/bin/env bash
# PreToolUse(Bash) — refuse catastrophic filesystem and database operations.
#
# These are the commands with no undo. None of them are things an assistant should run
# mid-task without a human deliberately typing them. Confirmation gate 2 in
# rules/decision-boundaries.md.
#
# Reads the Claude Code PreToolUse event as JSON on stdin.

set -uo pipefail

INPUT=$(cat)
COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')

[ -z "$COMMAND" ] && exit 0

deny() {
  jq -n --arg reason "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
  exit 0
}

# Recursive delete aimed at a root, a home directory, or an unset variable that would expand
# to one. "rm -rf $BUILD_DIR" with BUILD_DIR unset is the classic way to erase a home folder.
if printf '%s' "$COMMAND" | grep -qE 'rm[[:space:]]+(-[a-zA-Z]*[rR][a-zA-Z]*[[:space:]]+)+(-[a-zA-Z]+[[:space:]]+)*(/|~|\$HOME|"\$HOME"|\$\{HOME\})[[:space:]]*$|rm[[:space:]]+-[a-zA-Z]*[rR][a-zA-Z]*[fF]?[[:space:]]+/[[:space:]]'; then
  deny "Recursive delete targeting a root or home directory blocked (rules/decision-boundaries.md, gate 2). If this is genuinely intended, run it by hand outside this session."
fi

# Destructive database operations.
if printf '%s' "$COMMAND" | grep -qiE '\bDROP[[:space:]]+(DATABASE|SCHEMA)\b|\bTRUNCATE[[:space:]]+TABLE\b|wp[[:space:]]+db[[:space:]]+(drop|reset)\b|mysqladmin[[:space:]]+.*\bdrop\b'; then
  deny "Destructive database operation blocked (rules/decision-boundaries.md, gate 2). Dropping or truncating is irreversible without a verified backup. Confirm the target environment and the backup, then run it by hand."
fi

# History rewrites on a shared clone.
if printf '%s' "$COMMAND" | grep -qE 'git[[:space:]]+(filter-branch|filter-repo)\b|git[[:space:]]+reset[[:space:]]+--hard[[:space:]]+origin/(main|master|prod|production)\b'; then
  deny "Shared-history rewrite blocked (rules/git-workflow.md). Discuss before rewriting anything that has been pushed."
fi

exit 0
