#!/usr/bin/env bash
#
# Tests for the PreToolUse safety hooks.
#
# A hook that over-blocks is worse than no hook — people disable it and lose the protection
# entirely. So every hook is tested in both directions: it must deny what it targets and it
# must stay out of the way of everything else.
#
# Usage: ./tests/hooks.test.sh

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOKS="$REPO_ROOT/hooks"

if [ -t 1 ]; then RED=$'\033[31m'; GRN=$'\033[32m'; DIM=$'\033[2m'; OFF=$'\033[0m'
else RED=""; GRN=""; DIM=""; OFF=""; fi

PASSED=0
FAILED=0

# expect <deny|allow> <hook> <command> [description]
expect() {
  local want="$1" hook="$2" cmd="$3" desc="${4:-$3}"
  local out got
  out=$(printf '%s' "$cmd" | jq -Rs '{tool_input:{command:.}}' | "$HOOKS/$hook" 2>/dev/null)
  if printf '%s' "$out" | grep -q '"permissionDecision"[[:space:]]*:[[:space:]]*"deny"'; then
    got="deny"
  else
    got="allow"
  fi
  if [ "$got" = "$want" ]; then
    printf '  %s✓%s %s %s(%s)%s\n' "$GRN" "$OFF" "$desc" "$DIM" "$want" "$OFF"
    PASSED=$((PASSED+1))
  else
    printf '  %s✗%s %s — expected %s, got %s\n' "$RED" "$OFF" "$desc" "$want" "$got"
    FAILED=$((FAILED+1))
  fi
}

command -v jq >/dev/null 2>&1 || { echo "jq is required to run these tests"; exit 2; }

echo
echo "block-force-push.sh"
expect deny  block-force-push.sh 'git push --force origin main'
expect deny  block-force-push.sh 'git push -f'
expect deny  block-force-push.sh 'git push --force-with-lease origin feature/x'
expect allow block-force-push.sh 'git push origin main'
expect allow block-force-push.sh 'git push origin feature/corpus-coverage-fill' \
       'branch name containing "-f" is not a force flag'
expect allow block-force-push.sh 'git log --format=%h'
expect allow block-force-push.sh 'echo "do not git push --force"' \
       'note: substring match means even a quoted mention is refused (acceptable over-block)'

echo
echo "block-destructive-ops.sh"
expect deny  block-destructive-ops.sh 'rm -rf /'
expect deny  block-destructive-ops.sh 'rm -rf $HOME'
expect deny  block-destructive-ops.sh 'wp db reset --yes'
expect deny  block-destructive-ops.sh 'mysql -e "DROP DATABASE production"'
expect deny  block-destructive-ops.sh 'git reset --hard origin/main'
expect deny  block-destructive-ops.sh 'git filter-branch --tree-filter "rm -f secret" HEAD'
expect allow block-destructive-ops.sh 'rm -rf node_modules' 'ordinary cleanup is allowed'
expect allow block-destructive-ops.sh 'rm -rf ./build/cache'
expect allow block-destructive-ops.sh 'wp db export backup.sql'
expect allow block-destructive-ops.sh 'git reset --hard HEAD~1' 'local reset is the author'"'"'s business'

echo
echo "block-secret-commit.sh"
TMPREPO="$(mktemp -d)"
(
  cd "$TMPREPO" || exit 1
  git init -q . && git config user.email t@t.t && git config user.name T

  # Clean commit
  echo "hello" > readme.txt && git add readme.txt
  printf '%s' 'git commit -m "docs: readme"' | jq -Rs '{tool_input:{command:.}}' \
    | "$HOOKS/block-secret-commit.sh" > "$TMPREPO/out-clean" 2>/dev/null

  # Staged .env
  git reset -q && echo "SECRET=1" > .env && git add -f .env
  printf '%s' 'git commit -m "chore: env"' | jq -Rs '{tool_input:{command:.}}' \
    | "$HOOKS/block-secret-commit.sh" > "$TMPREPO/out-env" 2>/dev/null

  # .env.example is fine
  git reset -q && rm -f .env && echo "SECRET=" > .env.example && git add -f .env.example
  printf '%s' 'git commit -m "chore: env example"' | jq -Rs '{tool_input:{command:.}}' \
    | "$HOOKS/block-secret-commit.sh" > "$TMPREPO/out-envexample" 2>/dev/null

  # Key-shaped string in a staged source file
  git reset -q && rm -f .env.example
  printf 'const k = "AKIAIOSFODNN7EXAMPLE";\n' > config.js && git add config.js
  printf '%s' 'git commit -m "feat: config"' | jq -Rs '{tool_input:{command:.}}' \
    | "$HOOKS/block-secret-commit.sh" > "$TMPREPO/out-key" 2>/dev/null
) >/dev/null 2>&1

check_file() {
  local want="$1" file="$2" desc="$3" got="allow"
  grep -q '"deny"' "$file" 2>/dev/null && got="deny"
  if [ "$got" = "$want" ]; then
    printf '  %s✓%s %s %s(%s)%s\n' "$GRN" "$OFF" "$desc" "$DIM" "$want" "$OFF"; PASSED=$((PASSED+1))
  else
    printf '  %s✗%s %s — expected %s, got %s\n' "$RED" "$OFF" "$desc" "$want" "$got"; FAILED=$((FAILED+1))
  fi
}
check_file allow "$TMPREPO/out-clean"      'ordinary commit'
check_file deny  "$TMPREPO/out-env"        'staged .env'
check_file allow "$TMPREPO/out-envexample" 'staged .env.example'
check_file deny  "$TMPREPO/out-key"        'AWS-shaped key in staged diff'
rm -rf "$TMPREPO"

echo
if [ "$FAILED" -gt 0 ]; then
  printf '%s%d failed%s, %d passed\n\n' "$RED" "$FAILED" "$OFF" "$PASSED"
  exit 1
fi
printf '%s%d passed%s\n\n' "$GRN" "$PASSED" "$OFF"
exit 0
