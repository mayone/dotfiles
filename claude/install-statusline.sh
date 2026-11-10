#!/bin/sh
set -eu

DIR=$(cd "$(dirname "$0")" && pwd -P)
TARGET="$HOME/.claude/statusline.sh"

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required" >&2
  exit 1
fi

if command -v npm >/dev/null 2>&1; then
  npm ci --prefix "$DIR" --no-audit --no-fund
else
  echo "npm not found: the statusline uses ccusage from PATH" >&2
fi

mkdir -p "$HOME/.claude"
if [ -e "$TARGET" ] && [ ! -L "$TARGET" ]; then
  mv "$TARGET" "$TARGET.bak"
  echo "Moved the existing $TARGET to $TARGET.bak"
fi
ln -sfn "$DIR/statusline.sh" "$TARGET"

for profile in "$HOME/.claude" "$HOME/.claude-work"; do
  [ -d "$profile" ] || continue
  settings="$profile/settings.json"
  [ -s "$settings" ] || echo '{}' > "$settings"
  updated=$(jq '.statusLine = {type: "command", command: "~/.claude/statusline.sh", padding: 0}' "$settings")
  printf '%s\n' "$updated" > "$settings"
  echo "Set statusLine in $settings"
done
