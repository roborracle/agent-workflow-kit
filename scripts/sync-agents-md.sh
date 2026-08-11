#!/usr/bin/env bash
#
# Generate AGENTS.md from CLAUDE.md + rules/.
#
# Assistants that aren't Claude Code (Codex, Gemini CLI, Cursor, and most others) read a single
# AGENTS.md and have no concept of on-demand rule files. So AGENTS.md carries the full text of
# every rule inlined, while CLAUDE.md stays short and references them.
#
# CLAUDE.md and rules/ are the source of truth. AGENTS.md is derived and should never be edited
# by hand — CI rejects a pull request whose AGENTS.md doesn't match its sources.
#
# Usage:
#   ./scripts/sync-agents-md.sh           regenerate AGENTS.md
#   ./scripts/sync-agents-md.sh --check   exit 1 if AGENTS.md is stale (used by CI)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

OUT="AGENTS.md"
CHECK=0
[ "${1:-}" = "--check" ] && CHECK=1

sha() {
  if command -v shasum >/dev/null 2>&1; then shasum -a 256 "$@" | awk '{print $1}'
  else sha256sum "$@" | awk '{print $1}'
  fi
}

# One digest over every source file, in a stable order.
SOURCES=$(printf 'CLAUDE.md\n'; ls -1 rules/*.md | sort)
DIGEST=$(printf '%s\n' "$SOURCES" | while IFS= read -r f; do sha "$f"; done | sha | cut -c1-16)

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

{
  cat <<EOF
<!-- GENERATED FILE — do not edit by hand.
     Source: CLAUDE.md + rules/*.md
     Regenerate: ./scripts/sync-agents-md.sh
     digest: $DIGEST
-->

# AGENTS.md — Engineering Standards

This file is for assistants that read a single instruction file: Codex, Gemini CLI, Cursor, and
most others. It contains the same standards Claude Code loads from \`CLAUDE.md\` plus \`rules/\`,
with every rule inlined because there is no on-demand loading here.

If you are Claude Code, read \`CLAUDE.md\` instead — it is shorter and the rules load only when
relevant.

---

EOF

  # Strip the rule index table from the end of CLAUDE.md — the rules themselves follow inline,
  # so a table of file pointers would be noise.
  sed '/^## Rule Index$/,$d' CLAUDE.md

  cat <<'EOF'

---

# Rules

EOF

  for f in rules/*.md; do
    printf '\n<a id="%s"></a>\n\n' "$(basename "$f" .md)"
    # Demote every heading one level so rule H1s sit under the "# Rules" H1 above.
    sed 's/^#/##/' "$f"
    printf '\n---\n'
  done

  cat <<EOF

<!-- end generated content · digest: $DIGEST -->
EOF
} > "$TMP"

if [ "$CHECK" -eq 1 ]; then
  if [ ! -f "$OUT" ]; then
    echo "AGENTS.md is missing. Run ./scripts/sync-agents-md.sh" >&2
    exit 1
  fi
  if ! diff -q "$TMP" "$OUT" >/dev/null 2>&1; then
    echo "AGENTS.md is out of date with CLAUDE.md / rules/." >&2
    echo "Run ./scripts/sync-agents-md.sh and commit the result." >&2
    diff -u "$OUT" "$TMP" | head -40 >&2
    exit 1
  fi
  echo "AGENTS.md is current (digest $DIGEST)."
  exit 0
fi

mv "$TMP" "$OUT"
trap - EXIT
LINES=$(wc -l < "$OUT" | tr -d ' ')
echo "Wrote $OUT — $LINES lines, digest $DIGEST"
