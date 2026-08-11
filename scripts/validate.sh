#!/usr/bin/env bash
#
# Validate the kit itself. Run this before opening a pull request; CI runs the same script.
#
# Checks:
#   1. Every JSON file parses
#   2. Every skill has usable frontmatter (a malformed skill fails silently at runtime — the
#      person who needed it just never gets it, and never finds out why)
#   3. Every agent has usable frontmatter
#   4. AGENTS.md is in sync with CLAUDE.md + rules/
#   5. The hook test suite passes
#   6. Shell scripts pass shellcheck, when shellcheck is available
#   7. No credential-shaped strings anywhere in the repository
#   8. No client or personal identifiers leaked into a public repository

set -uo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT" || exit 1

if [ -t 1 ]; then RED=$'\033[31m'; GRN=$'\033[32m'; BOLD=$'\033[1m'; DIM=$'\033[2m'; OFF=$'\033[0m'
else RED=""; GRN=""; BOLD=""; DIM=""; OFF=""; fi

FAILED=0
ok()   { printf '  %s✓%s %s\n' "$GRN" "$OFF" "$1"; }
bad()  { printf '  %s✗%s %s\n' "$RED" "$OFF" "$1"; FAILED=$((FAILED+1)); }
sect() { printf '\n%s%s%s\n' "$BOLD" "$1" "$OFF"; }

command -v jq >/dev/null 2>&1 || { echo "jq is required"; exit 2; }

# ---------------------------------------------------------------- 1. JSON

sect "JSON"
JSON_BAD=0
while IFS= read -r f; do
  jq empty "$f" >/dev/null 2>&1 || { bad "$f does not parse"; JSON_BAD=1; }
done < <(find . -name '*.json' -not -path './.git/*')
[ "$JSON_BAD" -eq 0 ] && ok "all JSON files parse"

# ---------------------------------------------------------------- 2. skills

sect "Skills"
SKILL_BAD=0
SKILL_N=0
while IFS= read -r f; do
  SKILL_N=$((SKILL_N+1))
  head -1 "$f" | grep -q '^---$' || { bad "$f: no frontmatter block"; SKILL_BAD=1; continue; }
  fm=$(awk 'NR>1 && /^---$/{exit} NR>1' "$f")
  printf '%s' "$fm" | grep -q '^name:'        || { bad "$f: frontmatter has no name:"; SKILL_BAD=1; }
  printf '%s' "$fm" | grep -q '^description:' || { bad "$f: frontmatter has no description:"; SKILL_BAD=1; }
  dir=$(basename "$(dirname "$f")")
  nm=$(printf '%s' "$fm" | sed -n 's/^name:[[:space:]]*"\{0,1\}\([^"]*\)"\{0,1\}$/\1/p' | tr -d '\r')
  if [ -n "$nm" ] && [ "$nm" != "$dir" ]; then
    bad "$f: frontmatter name '$nm' does not match directory '$dir'"
    SKILL_BAD=1
  fi
done < <(find skills -name SKILL.md 2>/dev/null)
[ "$SKILL_BAD" -eq 0 ] && ok "$SKILL_N skills have valid frontmatter"

# Depth check: the plugin loader only discovers skills/<name>/SKILL.md
if find skills -mindepth 3 -name SKILL.md 2>/dev/null | grep -q .; then
  bad "a skill is nested deeper than skills/<name>/SKILL.md — the plugin loader will not find it"
else
  ok "skill tree is at plugin-discoverable depth"
fi

# ---------------------------------------------------------------- 3. agents

sect "Agents"
AGENT_BAD=0
AGENT_N=0
for f in agents/*.md; do
  [ -e "$f" ] || continue
  AGENT_N=$((AGENT_N+1))
  head -1 "$f" | grep -q '^---$' || { bad "$f: no frontmatter block"; AGENT_BAD=1; continue; }
  fm=$(awk 'NR>1 && /^---$/{exit} NR>1' "$f")
  printf '%s' "$fm" | grep -q '^name:'        || { bad "$f: no name:"; AGENT_BAD=1; }
  printf '%s' "$fm" | grep -q '^description:' || { bad "$f: no description:"; AGENT_BAD=1; }
done
[ "$AGENT_BAD" -eq 0 ] && ok "$AGENT_N agents have valid frontmatter"

# ---------------------------------------------------------------- 4. AGENTS.md

sect "AGENTS.md sync"
if ./scripts/sync-agents-md.sh --check >/dev/null 2>&1; then
  ok "AGENTS.md matches CLAUDE.md + rules/"
else
  bad "AGENTS.md is stale — run ./scripts/sync-agents-md.sh and commit the result"
fi

# ---------------------------------------------------------------- 5. hook tests

sect "Hook behaviour"
if ./tests/hooks.test.sh >/dev/null 2>&1; then
  ok "all hook tests pass"
else
  bad "hook tests failed — run ./tests/hooks.test.sh to see which"
fi

# ---------------------------------------------------------------- 6. shellcheck

sect "Shell"
if command -v shellcheck >/dev/null 2>&1; then
  SH_BAD=0
  while IFS= read -r f; do
    shellcheck -S warning "$f" >/dev/null 2>&1 || { bad "shellcheck: $f"; SH_BAD=1; }
  done < <(find hooks scripts tests -name '*.sh' 2>/dev/null)
  [ "$SH_BAD" -eq 0 ] && ok "shellcheck clean"
else
  printf '  %s· shellcheck not installed — skipped (brew install shellcheck)%s\n' "$DIM" "$OFF"
fi

BASH_BAD=0
while IFS= read -r f; do
  bash -n "$f" 2>/dev/null || { bad "syntax error: $f"; BASH_BAD=1; }
done < <(find hooks scripts tests -name '*.sh' 2>/dev/null)
[ "$BASH_BAD" -eq 0 ] && ok "all shell scripts parse"

# ---------------------------------------------------------------- 7. secrets

sect "Secrets"
SECRET_PATTERNS='(AKIA[0-9A-Z]{16}|sk-ant-[A-Za-z0-9_-]{20,}|gh[pousr]_[A-Za-z0-9]{36,}|github_pat_[A-Za-z0-9_]{40,}|xox[abprs]-[A-Za-z0-9-]{10,}|AIza[0-9A-Za-z_-]{35}|-----BEGIN [A-Z ]*PRIVATE KEY-----)'
HITS=$(grep -rInE "$SECRET_PATTERNS" . \
  --exclude-dir=.git --exclude-dir=node_modules \
  2>/dev/null | grep -v 'AKIAIOSFODNN7EXAMPLE' | grep -v 'tests/hooks.test.sh' | grep -v 'scripts/validate.sh' || true)
if [ -n "$HITS" ]; then
  bad "credential-shaped strings found:"
  printf '%s\n' "$HITS" | head -10 | sed 's/^/      /'
else
  ok "no credential-shaped strings"
fi

# ---------------------------------------------------------------- 8. leakage

sect "Public-repo hygiene"
# This repository is public. Client names, personal project names, and absolute home paths
# do not belong in it — they belong in the private companion repository.
LEAK_PATTERNS='(/Users/[a-z]+/|/home/[a-z]+/|[A-Za-z0-9._%+-]+@(gmail|yahoo|hotmail|outlook)\.com)'
LEAKS=$(grep -rInE "$LEAK_PATTERNS" . \
  --exclude-dir=.git --exclude-dir=node_modules \
  --exclude='validate.sh' 2>/dev/null || true)
if [ -n "$LEAKS" ]; then
  bad "absolute home paths or personal email addresses found:"
  printf '%s\n' "$LEAKS" | head -10 | sed 's/^/      /'
else
  ok "no home paths or personal addresses"
fi

# ---------------------------------------------------------------- summary

printf '\n'
if [ "$FAILED" -gt 0 ]; then
  printf '%s%d check(s) failed%s\n\n' "$RED" "$FAILED" "$OFF"
  exit 1
fi
printf '%sAll checks passed.%s\n\n' "$GRN" "$OFF"
exit 0
