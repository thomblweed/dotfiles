#!/bin/bash
set -e

DOTFILES="$HOME/dotfiles"

symlink_dir() {
  local src="$DOTFILES/$1"
  local dest="$HOME/$2"
  mkdir -p "$(dirname "$dest")"
  rm -rf "$dest"
  ln -s "$src" "$dest"
  echo "✓ $dest -> $src"
}

symlink_file() {
  local src="$DOTFILES/$1"
  local dest="$HOME/$2"
  mkdir -p "$(dirname "$dest")"
  rm -f "$dest"
  ln -s "$src" "$dest"
  echo "✓ $dest -> $src"
}

symlink_dir  "claude/commands"          ".claude/commands"
symlink_dir  "archon/commands"          ".archon/commands"
symlink_dir  "archon/workflows"         ".archon/workflows"
symlink_file "agents/.skill-lock.json" ".agents/.skill-lock.json"

echo ""
echo "Done. Run 'npx skills install' to restore skills from lockfile."
