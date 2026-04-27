#!/usr/bin/env bash
set -euo pipefail
file=$(jq -r '.tool_input.file_path // .tool_input.path // ""')

protected=(
  ".env*"
  ".git/*"
  "package-lock.json"
  "yarn.lock"
  "*.pem"
  "*.key"
  "secrets/*"
)

for pattern in "${protected[@]}"; do
  if [[ "$pattern" == */* ]]; then
    # Directory pattern: check if the directory segment appears anywhere in the path
    dir="${pattern%/*}"
    escaped_dir="${dir//./\\.}"
    if echo "$file" | grep -qiE "(^|/)${escaped_dir}/"; then
      echo "Blocked: '$file' is protected. Explain why this edit is necessary." >&2
      exit 2
    fi
  else
    # Filename pattern: match against basename only
    escaped="${pattern//./\\.}"
    regex="${escaped//\*/.*}"
    if echo "$(basename "$file")" | grep -qiE "^${regex}$"; then
      echo "Blocked: '$file' is protected. Explain why this edit is necessary." >&2
      exit 2
    fi
  fi
done
exit 0