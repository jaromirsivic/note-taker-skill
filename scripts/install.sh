#!/bin/sh

set -eu

usage() {
  cat <<'EOF'
Usage: ./scripts/install.sh [TARGET_PROJECT]

Install note-taker-skill for Cursor, Codex, and Claude in TARGET_PROJECT.
TARGET_PROJECT defaults to the current directory.
EOF
}

if [ "${1-}" = "--help" ] || [ "${1-}" = "-h" ]; then
  usage
  exit 0
fi

if [ "$#" -gt 1 ]; then
  usage >&2
  exit 2
fi

script_dir=$(CDPATH= cd "$(dirname "$0")" && pwd)
package_root=$(CDPATH= cd "$script_dir/.." && pwd)
source_skill="$package_root/.agents/skills/note-taker-skill"
target_input=${1:-.}

if [ ! -f "$source_skill/SKILL.md" ]; then
  printf '%s\n' "Error: canonical skill not found at $source_skill" >&2
  exit 1
fi

case $target_input in
  /*) ;;
  *) target_input="$(pwd)/$target_input" ;;
esac

mkdir -p "$target_input"
target_root=$(CDPATH= cd "$target_input" && pwd)

copy_skill() {
  destination=$1
  mkdir -p "$destination"

  if [ "$source_skill" = "$destination" ]; then
    printf '%s\n' "Using canonical skill at $destination"
    return
  fi

  rm -rf "$destination"
  mkdir -p "$destination"
  cp -R "$source_skill/." "$destination/"
  printf '%s\n' "Installed skill at $destination"
}

# Cursor and Codex both discover the open-standard .agents location.
copy_skill "$target_root/.agents/skills/note-taker-skill"

# Claude uses its native project skill location.
copy_skill "$target_root/.claude/skills/note-taker-skill"

printf '%s\n' "note-taker-skill installation complete."
