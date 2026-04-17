#!/usr/bin/env bash
set -euo pipefail

# uninstall.sh — removes takeclass symlinks from ~/.claude/
# Only removes symlinks that point back into this repo. Leaves other users' files alone.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_DIR="${CLAUDE_HOME:-$HOME/.claude}"

SKILL_DEST="$CLAUDE_DIR/skills/dev-english-practice"

unlink_if_ours() {
  local dest="$1" expected_prefix="$2"
  if [[ -L "$dest" ]]; then
    local current
    current="$(readlink "$dest")"
    if [[ "$current" == "$expected_prefix"* ]]; then
      rm "$dest"
      echo "  removed $dest"
    else
      echo "  skip    $dest (points to $current, not this repo)"
    fi
  else
    echo "  skip    $dest (not a symlink)"
  fi
}

echo "Uninstalling takeclass from $CLAUDE_DIR"
unlink_if_ours "$SKILL_DEST" "$REPO_ROOT"

shopt -s nullglob
for cmd_src in "$REPO_ROOT"/commands/*.md; do
  unlink_if_ours "$CLAUDE_DIR/commands/$(basename "$cmd_src")" "$REPO_ROOT"
done
shopt -u nullglob

echo "Done."
