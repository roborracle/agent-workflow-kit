#!/usr/bin/env bash
# PreToolUse(Bash) — refuse a commit that stages a credential.
#
# This is a backstop, not a strategy. Keep secrets out of the working tree in the first place
# (see rules/security.md). But a credential that reaches a remote — even a private one — has to
# be treated as compromised and rotated, and this hook is far cheaper than that.
#
# Reads the Claude Code PreToolUse event as JSON on stdin.

set -uo pipefail

INPUT=$(cat)
COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')

[ -z "$COMMAND" ] && exit 0
printf '%s' "$COMMAND" | grep -qiE 'git[[:space:]]+commit' || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

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

# 1. Staged environment files. .env.example / .env.sample / .env.template are fine — they are
#    the documented placeholders. Anything else named .env is not.
STAGED=$(git diff --cached --name-only 2>/dev/null || true)
ENV_HIT=$(printf '%s\n' "$STAGED" \
  | grep -E '(^|/)\.env' \
  | grep -vE '\.(example|sample|template|dist)$' || true)

if [ -n "$ENV_HIT" ]; then
  deny "Environment file staged for commit: $(printf '%s' "$ENV_HIT" | tr '\n' ' '). Secrets belong in the environment, never in the repository (rules/security.md). Unstage it with 'git restore --staged <file>' and confirm it is listed in .gitignore."
fi

# 2. Credential-shaped strings in the staged diff.
DIFF=$(git diff --cached -U0 2>/dev/null | grep '^+' | grep -v '^+++' || true)
[ -z "$DIFF" ] && exit 0

declare -a PATTERNS=(
  'AKIA[0-9A-Z]{16}'                                  # AWS access key id
  'sk-ant-[A-Za-z0-9_-]{20,}'                         # Anthropic
  'sk-(proj-)?[A-Za-z0-9]{32,}'                       # OpenAI
  'gh[pousr]_[A-Za-z0-9]{36,}'                        # GitHub token
  'github_pat_[A-Za-z0-9_]{40,}'                      # GitHub fine-grained PAT
  'xox[abprs]-[A-Za-z0-9-]{10,}'                      # Slack
  'AIza[0-9A-Za-z_-]{35}'                             # Google API key
  '-----BEGIN [A-Z ]*PRIVATE KEY-----'                # Private key block
  '(password|passwd|secret|api[_-]?key|auth[_-]?token)["'"'"']?[[:space:]]*[:=][[:space:]]*["'"'"'][^"'"'"']{12,}["'"'"']'
)

for pattern in "${PATTERNS[@]}"; do
  if printf '%s' "$DIFF" | grep -qE "$pattern"; then
    deny "Possible credential in staged changes — matched pattern /${pattern}/. Review with 'git diff --cached', remove the value, and move it to an environment variable (rules/security.md). If this is a false positive (a fixture, a test double, or documentation), commit it outside this session or adjust the fixture so it does not look like a live key."
  fi
done

exit 0
