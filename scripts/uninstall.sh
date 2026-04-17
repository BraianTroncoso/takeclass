#!/usr/bin/env bash
set -euo pipefail

# uninstall.sh — removes takeclass symlinks from ~/.claude/
# Only removes symlinks that point back into this repo. Leaves other users' files alone.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_DIR="${CLAUDE_HOME:-$HOME/.claude}"

SKILL_DEST="$CLAUDE_DIR/skills/dev-english-practice"
CMD_DEST="$CLAUDE_DIR/commands/takeclass.md"

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
unlink_if_ours "$CMD_DEST" "$REPO_ROOT"
echo "Done."
