#!/usr/bin/env bash
set -euo pipefail

source_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)
if [[ $# -eq 2 && "$1" == --existing-empty-git ]]; then
  existing_git=1
  requested_dest=$2
elif [[ $# -eq 1 ]]; then
  existing_git=0
  requested_dest=$1
else
  printf 'Usage: %s [--existing-empty-git] /absolute/path/to/project\n' "$0" >&2
  exit 2
fi
if [[ "$requested_dest" != /* || -z "$requested_dest" ]]; then
  printf 'Destination must be an absolute path.\n' >&2
  exit 2
fi
dest=$(realpath -m -- "$requested_dest")
if [[ "$dest" == "$source_dir" || "$dest" == "$source_dir/"* ]]; then
  printf 'Destination cannot be the template or inside it.\n' >&2
  exit 2
fi
if ((existing_git)); then
  if [[ ! -d "$dest/.git" ]] || git -C "$dest" rev-parse --verify HEAD >/dev/null 2>&1; then
    printf 'Existing destination must be an uncommitted Git repository: %s\n' "$dest" >&2
    exit 2
  fi
  shopt -s dotglob nullglob
  entries=("$dest"/*)
  shopt -u dotglob nullglob
  if [[ ${#entries[@]} -ne 1 || "${entries[0]}" != "$dest/.git" ]]; then
    printf 'Existing destination must contain only .git: %s\n' "$dest" >&2
    exit 2
  fi
else
  if [[ -e "$dest" ]]; then
    printf 'Destination already exists: %s\n' "$dest" >&2
    exit 2
  fi
  if [[ ! -d "$(dirname "$dest")" ]]; then
    printf 'Parent directory does not exist: %s\n' "$(dirname "$dest")" >&2
    exit 2
  fi
  mkdir -- "$dest"
fi
# Copy source content, not the template's Git history or transient agent state.
tar -C "$source_dir" --exclude='./.git' --exclude='./.worktrees' \
  --exclude='./.agent' --exclude='./README.md' --exclude='./PROJECT_README.md' \
  -cf - . | tar -C "$dest" -xf -
cp -- "$source_dir/PROJECT_README.md" "$dest/README.md"
cp -- "$source_dir/README.md" "$dest/SETUP_FROM_TEMPLATE.md"
printf 'Created %s\nTailor AGENTS.md, README.md, task/docs templates, and justfile before project work.\n' "$dest"
