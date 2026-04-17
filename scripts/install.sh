#!/usr/bin/env bash
set -euo pipefail

# install.sh — symlinks the takeclass skill and all commands into ~/.claude/
# Idempotent: safe to run multiple times. Picks up any new commands in commands/ automatically.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_DIR="${CLAUDE_HOME:-$HOME/.claude}"

SKILL_SRC="$REPO_ROOT/skills/dev-english-practice"
SKILL_DEST="$CLAUDE_DIR/skills/dev-english-practice"

mkdir -p "$CLAUDE_DIR/skills" "$CLAUDE_DIR/commands"

link() {
  local src="$1" dest="$2"
  if [[ -L "$dest" ]]; then
    local current
    current="$(readlink "$dest")"
    if [[ "$current" == "$src" ]]; then
      echo "  ok      $dest -> $src"
      return 0
    fi
    echo "  replace $dest (was -> $current)"
    rm "$dest"
  elif [[ -e "$dest" ]]; then
    echo "  ERROR   $dest exists and is not a symlink. Remove it manually and re-run." >&2
    return 1
  fi
  ln -s "$src" "$dest"
  echo "  link    $dest -> $src"
}

echo "Installing takeclass from $REPO_ROOT into $CLAUDE_DIR"
link "$SKILL_SRC" "$SKILL_DEST"

shopt -s nullglob
for cmd_src in "$REPO_ROOT"/commands/*.md; do
  link "$cmd_src" "$CLAUDE_DIR/commands/$(basename "$cmd_src")"
done
shopt -u nullglob

echo "Done. Run '/takeclass' or '/takeclass-recap' in Claude Code to try it."
