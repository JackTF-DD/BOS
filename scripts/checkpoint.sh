#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p .agent/logs
timestamp=$(date +%Y%m%d-%H%M%S)
log=".agent/logs/checkpoint-${timestamp}.log"
{
  printf 'Checkpoint: %s\n' "$timestamp"
  printf '=== Git state ===\n'
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git status --short --branch
    git diff --stat
  else
    printf 'Git not initialized.\n'
  fi
  printf '=== project test recipe ===\n'
  if command -v just >/dev/null 2>&1; then
    just test
  else
    printf 'just unavailable; no tests run.\n'
    exit 1
  fi
} >"$log" 2>&1 || { printf 'Checkpoint checks failed or are not configured: %s\n' "$log" >&2; exit 1; }
printf 'Checkpoint recorded: %s\nUpdate the active task record with the actual result and next action.\n' "$log"
