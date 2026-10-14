#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
shopt -s nullglob
records=(tasks/active/*.md)
if ((${#records[@]} == 0)); then
  printf 'No active task records. Nothing to verify.\n'
  exit 0
fi
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  printf 'Cannot verify task base commits before Git initialization.\n' >&2
  exit 1
fi
status=0
for record in "${records[@]}"; do
  printf '\n=== %s ===\n' "$record"
  base=$(awk -F': *' '/^base_commit:/{print $2; exit}' "$record" | tr -d '[:space:]')
  if [[ -n "$base" && "$base" != *'<'* ]] && git cat-file -e "${base}^{commit}" 2>/dev/null; then
    git log --oneline "${base}..HEAD"
    git diff --stat "${base}..HEAD"
  else
    printf 'Missing or unresolvable base_commit. Reconcile this work record.\n' >&2
    status=1
  fi
done
printf '\n=== current working tree ===\n'
git status --short
exit "$status"
