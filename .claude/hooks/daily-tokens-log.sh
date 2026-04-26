#!/usr/bin/env bash
set -euo pipefail

read -r input
hook_event=$(echo "$input" | jq -r '.hook_event_name // empty')

[[ "$hook_event" != "SessionEnd" ]] && exit 0

today=$(date +%Y%m%d)
log_dir="$HOME/.claude/token-usage"
mkdir -p "$log_dir"

npx ccusage daily --since $today -q '.totals' > $log_dir/$today.log 2>/dev/null || true

exit 0