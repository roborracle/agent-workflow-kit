#!/usr/bin/env bash
#
# Check that this machine is set up to do engineering work with this kit.
#
# Every FAIL line tells you the command that fixes it. Run this after install, after any
# `git pull` of the kit, and any time something behaves strangely.
#
# Exit codes: 0 = all good (warnings allowed), 1 = at least one FAIL.

set -uo pipefail

CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
ENV_FILE="$HOME/.config/agent-kit/env.sh"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO="roborracle/agent-workflow-kit"

if [ -t 1 ]; then
  BOLD=$'\033[1m'; DIM=$'\033[2m'; RED=$'\033[31m'; YEL=$'\033[33m'; GRN=$'\033[32m'; OFF=$'\033[0m'
else
  BOLD=""; DIM=""; RED=""; YEL=""; GRN=""; OFF=""
fi

FAILS=0
WARNS=0

pass() { printf '  %s✓%s %s\n' "$GRN" "$OFF" "$1"; }
warn() { printf '  %s!%s %s\n' "$YEL" "$OFF" "$1"; [ $# -gt 1 ] && printf '      %sfix: %s%s\n' "$DIM" "$2" "$OFF"; WARNS=$((WARNS+1)); return 0; }
fail() { printf '  %s✗%s %s\n' "$RED" "$OFF" "$1"; [ $# -gt 1 ] && printf '      %sfix: %s%s\n' "$DIM" "$2" "$OFF"; FAILS=$((FAILS+1)); return 0; }
head_() { printf '\n%s%s%s\n' "$BOLD" "$1" "$OFF"; }

printf '\n%sAgent workflow kit — environment check%s\n' "$BOLD" "$OFF"
printf '%s%s · %s%s\n' "$DIM" "$(uname -s)" "${SHELL##*/}" "$OFF"

# ---------------------------------------------------------------- tools

head_ "Required tools"
check_tool() {
  local bin="$1" why="$2" fix="$3"
  if command -v "$bin" >/dev/null 2>&1; then
    pass "$bin  ${DIM}$($bin --version 2>/dev/null | head -1 | cut -c1-40)${OFF}"
  else
    fail "$bin missing — $why" "$fix"
  fi
}
check_tool git  "everything"                 "xcode-select --install (macOS) or apt install git"
check_tool jq   "the safety hooks parse JSON with it" "brew install jq"
check_tool gh   "issue and PR workflow"      "brew install gh"
check_tool node "MCP servers run on it"      "brew install node  (or use nvm)"

if command -v claude >/dev/null 2>&1; then
  pass "claude  ${DIM}$(claude --version 2>/dev/null | head -1)${OFF}"
else
  warn "claude CLI not found — fine if you only use an IDE extension or another assistant" \
       "npm install -g @anthropic-ai/claude-code"
fi

# ---------------------------------------------------------------- github

head_ "GitHub access"
if ! command -v gh >/dev/null 2>&1; then
  fail "cannot check — gh is not installed" "brew install gh && gh auth login"
elif ! gh auth status >/dev/null 2>&1; then
  fail "not authenticated with GitHub" "gh auth login"
else
  GH_USER="$(gh api user --jq .login 2>/dev/null || echo '')"
  pass "authenticated as ${GH_USER:-unknown}"
fi

GIT_NAME="$(git config --global user.name 2>/dev/null || true)"
GIT_EMAIL="$(git config --global user.email 2>/dev/null || true)"
if [ -n "$GIT_NAME" ] && [ -n "$GIT_EMAIL" ]; then
  pass "git identity: $GIT_NAME <$GIT_EMAIL>"
else
  fail "git identity not set — commits will be attributed to nobody" \
       "git config --global user.name 'Your Name' && git config --global user.email 'you@example.com'"
fi

# ---------------------------------------------------------------- kit install

head_ "Kit installation"
KIT_VERSION="$(sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$REPO_ROOT/.claude-plugin/plugin.json" 2>/dev/null | head -1)"
[ -n "$KIT_VERSION" ] && printf '  %sthis clone: v%s%s\n' "$DIM" "$KIT_VERSION" "$OFF"

PLUGIN_INSTALLED=0
if command -v claude >/dev/null 2>&1 && claude plugin list 2>/dev/null | grep -q 'agent-workflow'; then
  PLUGIN_INSTALLED=1
  pass "installed as a plugin (agent-workflow)"
fi

SCRIPT_INSTALLED=0
if [ -f "$CLAUDE_DIR/.agent-kit-manifest" ]; then
  SCRIPT_INSTALLED=1
  pass "installed via script — $(wc -l < "$CLAUDE_DIR/.agent-kit-manifest" | tr -d ' ') managed paths"
fi

if [ "$PLUGIN_INSTALLED" -eq 0 ] && [ "$SCRIPT_INSTALLED" -eq 0 ]; then
  fail "the kit is not installed on this machine" "./scripts/install.sh"
fi

if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
  if diff -q "$REPO_ROOT/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md" >/dev/null 2>&1; then
    pass "CLAUDE.md matches this clone"
  else
    warn "~/.claude/CLAUDE.md differs from this clone" "./scripts/install.sh  (it backs up yours first)"
  fi
else
  fail "no ~/.claude/CLAUDE.md — the standards are not loaded in any session" "./scripts/install.sh"
fi

RULE_COUNT=$(ls -1 "$CLAUDE_DIR/rules"/*.md 2>/dev/null | wc -l | tr -d ' ')
SKILL_COUNT=$(find "$CLAUDE_DIR/skills" -maxdepth 2 -name SKILL.md 2>/dev/null | wc -l | tr -d ' ')
AGENT_COUNT=$(ls -1 "$CLAUDE_DIR/agents"/*.md 2>/dev/null | wc -l | tr -d ' ')
if [ "$SCRIPT_INSTALLED" -eq 1 ]; then
  [ "$RULE_COUNT" -gt 0 ]  && pass "$RULE_COUNT rules"   || fail "no rules installed" "./scripts/install.sh"
  [ "$SKILL_COUNT" -gt 0 ] && pass "$SKILL_COUNT skills" || fail "no skills installed" "./scripts/install.sh"
  [ "$AGENT_COUNT" -gt 0 ] && pass "$AGENT_COUNT agents" || fail "no agents installed" "./scripts/install.sh"
fi

# ---------------------------------------------------------------- hooks

head_ "Safety hooks"
if [ "$PLUGIN_INSTALLED" -eq 1 ]; then
  pass "wired by the plugin"
else
  SETTINGS="$CLAUDE_DIR/settings.json"
  if [ ! -f "$SETTINGS" ]; then
    fail "no ~/.claude/settings.json — hooks are not wired" "./scripts/install.sh"
  elif ! command -v jq >/dev/null 2>&1; then
    warn "cannot inspect settings.json without jq" "brew install jq"
  elif ! jq empty "$SETTINGS" >/dev/null 2>&1; then
    fail "~/.claude/settings.json is not valid JSON" "fix the syntax, then ./scripts/install.sh"
  else
    for h in block-force-push block-secret-commit block-destructive-ops; do
      if jq -e --arg h "$h" '[.. | strings] | any(contains($h))' "$SETTINGS" >/dev/null 2>&1; then
        if [ -x "$CLAUDE_DIR/hooks/$h.sh" ]; then
          pass "$h"
        else
          fail "$h is wired but $CLAUDE_DIR/hooks/$h.sh is missing or not executable" \
               "./scripts/install.sh"
        fi
      else
        fail "$h not wired into settings.json" "./scripts/install.sh"
      fi
    done
    if jq -e '.skipDangerousModePermissionPrompt == true' "$SETTINGS" >/dev/null 2>&1; then
      warn "skipDangerousModePermissionPrompt is true — the last gate before an irreversible command is off" \
           "remove that key from ~/.claude/settings.json unless you have a specific reason"
    fi
  fi
fi

# ---------------------------------------------------------------- credentials

head_ "Credentials"
if [ -f "$ENV_FILE" ]; then
  MODE="$(stat -f '%Lp' "$ENV_FILE" 2>/dev/null || stat -c '%a' "$ENV_FILE" 2>/dev/null)"
  if [ "$MODE" = "600" ]; then
    pass "$ENV_FILE (mode 600)"
  else
    fail "$ENV_FILE is mode ${MODE:-unknown} — other accounts on this machine can read your keys" \
         "chmod 600 $ENV_FILE"
  fi
  if grep -qE '^[[:space:]]*export[[:space:]]+[A-Z_]+=["'"'"']?[A-Za-z0-9_-]{16,}' "$ENV_FILE" 2>/dev/null; then
    pass "at least one credential is set"
  else
    warn "no credentials set yet — add them as services require them" "\$EDITOR $ENV_FILE"
  fi
else
  warn "$ENV_FILE does not exist" "./scripts/install.sh"
fi

if [ -f "$HOME/.mcp.json" ]; then
  if grep -qE '(sk-ant-|sk-proj-|gh[pousr]_|AIza|xox[abprs]-)[A-Za-z0-9_-]{16,}' "$HOME/.mcp.json" 2>/dev/null; then
    fail "~/.mcp.json contains what looks like a literal API key" \
         "replace the value with \${VAR_NAME} and export the variable from $ENV_FILE"
  else
    pass "~/.mcp.json has no literal credentials"
  fi
else
  warn "no ~/.mcp.json — MCP servers are unavailable" "cp mcp/.mcp.example.json ~/.mcp.json"
fi

# ---------------------------------------------------------------- version

head_ "Kit version"
LATEST=""
if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  LATEST="$(gh api "repos/$REPO/releases/latest" --jq '.tag_name // empty' 2>/dev/null || true)"
fi
# An error payload, an empty body, or anything that isn't tag-shaped means "couldn't check" —
# not "you are out of date". Reporting a 404 body as the latest version would be worse than
# saying nothing.
case "$LATEST" in
  v[0-9]*|[0-9]*) ;;
  *) LATEST="" ;;
esac
if [ -z "$LATEST" ]; then
  warn "no published release to compare against — skipping the version check"
elif [ "${LATEST#v}" = "$KIT_VERSION" ]; then
  pass "v$KIT_VERSION is current"
else
  warn "you are on v$KIT_VERSION; latest release is $LATEST" "git pull && ./scripts/install.sh"
fi

# ---------------------------------------------------------------- summary

printf '\n%s' "$BOLD"
if [ "$FAILS" -gt 0 ]; then
  printf '%d problem(s), %d warning(s)%s\n' "$FAILS" "$WARNS" "$OFF"
  printf 'Work through the FAIL lines above — each one lists its fix.\n\n'
  exit 1
elif [ "$WARNS" -gt 0 ]; then
  printf 'Ready, with %d warning(s)%s\n' "$WARNS" "$OFF"
  printf 'Warnings are optional to resolve. Nothing is blocking you.\n\n'
else
  printf 'Everything checks out.%s\n\n' "$OFF"
fi
exit 0
