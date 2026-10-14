#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
printf '=== project ===\n'
printf '%s\n' "$PWD"
printf '\n=== Git ===\n'
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git status --short --branch
  git log --oneline -5 2>/dev/null || true
else
  printf 'No Git repository initialized yet.\n'
fi
printf '\n=== active work records ===\n'
shopt -s nullglob
records=(tasks/active/*.md)
if ((${#records[@]})); then
  printf '%s\n' "${records[@]}"
else
  printf 'None. Start one from tasks/TEMPLATE.md.\n'
fi
printf '\nRead AGENTS.md, the relevant task record, and docs/INDEX.md.\n'
