#!/usr/bin/env bash
#
# Install the Agent Workflow Kit into ~/.claude/.
#
# Non-destructive by design:
#   - Backs up anything it is about to replace, under ~/.claude/.backups/<timestamp>/
#   - Merges settings.json instead of overwriting it
#   - Refuses to overwrite a skill or agent you wrote yourself
#   - --dry-run shows every action without performing any of them
#
# Usage:
#   ./scripts/install.sh [--dry-run] [--force] [--uninstall]
#
#   --dry-run    print what would happen, change nothing
#   --force      overwrite files that are not kit-managed (still backs them up)
#   --uninstall  remove kit-managed files, restore nothing else

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
MANIFEST="$CLAUDE_DIR/.agent-kit-manifest"
ENV_FILE="$HOME/.config/agent-kit/env.sh"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$CLAUDE_DIR/.backups/$STAMP"
VERSION="$(sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$REPO_ROOT/.claude-plugin/plugin.json" | head -1)"

DRY_RUN=0
FORCE=0
UNINSTALL=0

for arg in "$@"; do
  case "$arg" in
    --dry-run)   DRY_RUN=1 ;;
    --force)     FORCE=1 ;;
    --uninstall) UNINSTALL=1 ;;
    -h|--help)   sed -n '2,20p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

# ---------------------------------------------------------------- output helpers

if [ -t 1 ]; then
  BOLD=$'\033[1m'; DIM=$'\033[2m'; RED=$'\033[31m'; YEL=$'\033[33m'; GRN=$'\033[32m'; OFF=$'\033[0m'
else
  BOLD=""; DIM=""; RED=""; YEL=""; GRN=""; OFF=""
fi

say()  { printf '%s\n' "$*"; }
act()  { printf '  %s%s%s %s\n' "$GRN" "→" "$OFF" "$*"; }
skip() { printf '  %s%s%s %s\n' "$DIM" "·" "$OFF" "$*"; }
warn() { printf '  %s%s%s %s\n' "$YEL" "!" "$OFF" "$*"; }
die()  { printf '%serror:%s %s\n' "$RED" "$OFF" "$*" >&2; exit 1; }

run() {
  if [ "$DRY_RUN" -eq 1 ]; then return 0; fi
  "$@"
}

# ---------------------------------------------------------------- preflight

command -v jq >/dev/null 2>&1 || die "jq is required. Install it with 'brew install jq' (macOS) or 'apt install jq' (Linux), then run this again."
[ -d "$REPO_ROOT/rules" ] || die "Run this from a clone of the kit — $REPO_ROOT/rules is missing."

mkdir -p "$CLAUDE_DIR"

# ---------------------------------------------------------------- uninstall

if [ "$UNINSTALL" -eq 1 ]; then
  say "${BOLD}Removing kit-managed files${OFF}"
  if [ ! -f "$MANIFEST" ]; then
    warn "No manifest at $MANIFEST — nothing to remove."
    exit 0
  fi
  while IFS= read -r rel; do
    [ -z "$rel" ] && continue
    target="$CLAUDE_DIR/$rel"
    if [ -e "$target" ]; then
      act "remove $rel"
      run rm -rf "$target"
    fi
  done < "$MANIFEST"
  run rm -f "$MANIFEST"
  say ""
  say "Kit files removed. Your settings.json, personal skills, and backups in"
  say "$CLAUDE_DIR/.backups/ were left alone."
  exit 0
fi

# ---------------------------------------------------------------- banner

say ""
say "${BOLD}Agent workflow kit${OFF} ${DIM}v${VERSION}${OFF}"
say "${DIM}source: $REPO_ROOT${OFF}"
say "${DIM}target: $CLAUDE_DIR${OFF}"
[ "$DRY_RUN" -eq 1 ] && say "${YEL}dry run — nothing will be written${OFF}"
say ""

NEW_MANIFEST="$(mktemp)"
trap 'rm -f "$NEW_MANIFEST"' EXIT

backup() {
  # backup <absolute-path> <relative-label>
  local src="$1" rel="$2"
  [ -e "$src" ] || return 0
  act "backup $rel → .backups/$STAMP/$rel"
  if [ "$DRY_RUN" -eq 0 ]; then
    mkdir -p "$(dirname "$BACKUP_DIR/$rel")"
    cp -R "$src" "$BACKUP_DIR/$rel"
  fi
}

is_kit_managed() {
  [ -f "$MANIFEST" ] && grep -Fxq "$1" "$MANIFEST"
}

# install_tree <source-dir> <relative-target-dir>
# Copies each immediate child. A child that already exists and is not kit-managed is left
# alone unless --force, because it is probably something the user wrote.
install_tree() {
  local src="$1" rel_dir="$2"
  local dest="$CLAUDE_DIR/$rel_dir"
  [ -d "$src" ] || return 0
  run mkdir -p "$dest"

  local child base rel
  for child in "$src"/*; do
    [ -e "$child" ] || continue
    base="$(basename "$child")"
    rel="$rel_dir/$base"
    printf '%s\n' "$rel" >> "$NEW_MANIFEST"

    if [ -e "$dest/$base" ] && ! is_kit_managed "$rel" && [ "$FORCE" -eq 0 ]; then
      warn "keep your own $rel  ${DIM}(--force to replace; a backup is taken either way)${OFF}"
      continue
    fi
    if [ -e "$dest/$base" ]; then
      if diff -rq "$child" "$dest/$base" >/dev/null 2>&1; then
        skip "unchanged $rel"
        continue
      fi
      backup "$dest/$base" "$rel"
    fi
    act "install $rel"
    run rm -rf "$dest/$base"
    run cp -R "$child" "$dest/$base"
  done
}

# ---------------------------------------------------------------- CLAUDE.md

say "${BOLD}Standards${OFF}"
if [ -f "$CLAUDE_DIR/CLAUDE.md" ] && ! is_kit_managed "CLAUDE.md" && [ "$FORCE" -eq 0 ]; then
  warn "keep your own CLAUDE.md  ${DIM}(--force to replace)${OFF}"
  warn "the kit's rules/ reference directives that live in the kit's CLAUDE.md — read"
  warn "$REPO_ROOT/CLAUDE.md and merge what you want into yours"
else
  if [ -f "$CLAUDE_DIR/CLAUDE.md" ] && ! diff -q "$REPO_ROOT/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md" >/dev/null 2>&1; then
    backup "$CLAUDE_DIR/CLAUDE.md" "CLAUDE.md"
  fi
  act "install CLAUDE.md"
  run cp "$REPO_ROOT/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
fi
printf '%s\n' "CLAUDE.md" >> "$NEW_MANIFEST"

install_tree "$REPO_ROOT/rules" "rules"

say ""
say "${BOLD}Skills, agents, hooks${OFF}"
install_tree "$REPO_ROOT/skills" "skills"
install_tree "$REPO_ROOT/agents" "agents"

# Hooks: hooks.json is for the plugin install path only; the script path uses settings.json.
run mkdir -p "$CLAUDE_DIR/hooks"
for hook in "$REPO_ROOT"/hooks/*.sh; do
  [ -e "$hook" ] || continue
  base="$(basename "$hook")"
  printf '%s\n' "hooks/$base" >> "$NEW_MANIFEST"
  if [ -f "$CLAUDE_DIR/hooks/$base" ] && diff -q "$hook" "$CLAUDE_DIR/hooks/$base" >/dev/null 2>&1; then
    skip "unchanged hooks/$base"
  else
    [ -f "$CLAUDE_DIR/hooks/$base" ] && backup "$CLAUDE_DIR/hooks/$base" "hooks/$base"
    act "install hooks/$base"
    run cp "$hook" "$CLAUDE_DIR/hooks/$base"
  fi
  run chmod +x "$CLAUDE_DIR/hooks/$base"
done

# ---------------------------------------------------------------- settings merge

say ""
say "${BOLD}Settings${OFF}"
SETTINGS="$CLAUDE_DIR/settings.json"
if [ ! -f "$SETTINGS" ]; then
  act "create settings.json from the baseline"
  run jq 'del(.["$comment"])' "$REPO_ROOT/settings.example.json" > "$SETTINGS.tmp" 2>/dev/null && run mv "$SETTINGS.tmp" "$SETTINGS"
else
  if ! jq empty "$SETTINGS" >/dev/null 2>&1; then
    die "$SETTINGS is not valid JSON. Fix or move it, then run this again."
  fi
  backup "$SETTINGS" "settings.json"
  act "merge baseline into settings.json  ${DIM}(your existing keys win)${OFF}"
  if [ "$DRY_RUN" -eq 0 ]; then
    # Baseline first, yours second: anything you already set is preserved. Hook arrays are
    # unioned so the kit's guards are added without dropping hooks you added yourself.
    jq -s '
      (.[0] | del(.["$comment"])) as $base
      | .[1] as $mine
      | ($base * $mine)
      | .hooks.PreToolUse = (
          (($base.hooks.PreToolUse // []) + ($mine.hooks.PreToolUse // []))
          | group_by(.matcher)
          | map({ matcher: .[0].matcher, hooks: (map(.hooks) | add | unique_by(.command)) })
        )
      | .enabledPlugins = (($base.enabledPlugins // {}) + ($mine.enabledPlugins // {}))
    ' "$REPO_ROOT/settings.example.json" "$SETTINGS" > "$SETTINGS.tmp"
    mv "$SETTINGS.tmp" "$SETTINGS"
  fi
fi

if [ "$DRY_RUN" -eq 0 ] && jq -e '.skipDangerousModePermissionPrompt == true' "$SETTINGS" >/dev/null 2>&1; then
  warn "your settings.json sets skipDangerousModePermissionPrompt: true"
  warn "that disables the last confirmation before an irreversible command runs — reconsider it"
fi

# ---------------------------------------------------------------- credentials

say ""
say "${BOLD}Credentials${OFF}"
if [ -f "$ENV_FILE" ]; then
  skip "$ENV_FILE already exists — left alone"
else
  act "create $ENV_FILE (mode 600)"
  if [ "$DRY_RUN" -eq 0 ]; then
    mkdir -p "$(dirname "$ENV_FILE")"
    cat > "$ENV_FILE" <<'ENVEOF'
# Personal credentials for AI tooling. Yours alone — never shared, never committed.
# Source this from your shell profile:
#
#   [ -f "$HOME/.config/agent-kit/env.sh" ] && . "$HOME/.config/agent-kit/env.sh"
#
# Leave a line commented out until you actually need that service.

# export ANTHROPIC_API_KEY=""     # only if you use API billing rather than a Claude subscription
# export CONTEXT7_API_KEY=""      # context7 MCP server
# export OPENAI_API_KEY=""        # only if you use Codex
ENVEOF
    chmod 600 "$ENV_FILE"
  fi
fi

PROFILE=""
case "${SHELL##*/}" in
  zsh)  PROFILE="$HOME/.zshrc" ;;
  bash) PROFILE="$HOME/.bashrc" ;;
esac
if [ -n "$PROFILE" ] && [ -f "$PROFILE" ] && ! grep -q 'agent-kit/env.sh' "$PROFILE" 2>/dev/null; then
  warn "add this line to $PROFILE, then open a new terminal:"
  say "      ${DIM}[ -f \"\$HOME/.config/agent-kit/env.sh\" ] && . \"\$HOME/.config/agent-kit/env.sh\"${OFF}"
fi

if [ ! -f "$HOME/.mcp.json" ]; then
  warn "no ~/.mcp.json — copy mcp/.mcp.example.json there when you want MCP servers"
fi

# ---------------------------------------------------------------- finish

if [ "$DRY_RUN" -eq 0 ]; then
  sort -u "$NEW_MANIFEST" > "$MANIFEST"
fi

say ""
if [ "$DRY_RUN" -eq 1 ]; then
  say "${YEL}Dry run complete. Nothing was written.${OFF}"
  say "Run without --dry-run to apply."
else
  say "${GRN}Installed.${OFF}"
  [ -d "$BACKUP_DIR" ] && say "Backups of anything replaced: ${DIM}$BACKUP_DIR${OFF}"
  say ""
  say "Next: ${BOLD}./scripts/doctor.sh${OFF} to confirm everything is wired up."
fi
say ""
