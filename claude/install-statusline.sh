#!/bin/sh
set -eu

DIR=$(cd "$(dirname "$0")" && pwd -P)
TARGET="$HOME/.claude/statusline.sh"
DEPS="$HOME/.claude/statusline"

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required" >&2
  exit 1
fi

if command -v npm >/dev/null 2>&1; then
  mkdir -p "$DEPS"
  cp "$DIR/package.json" "$DIR/package-lock.json" "$DEPS/"
  npm ci --prefix "$DEPS" --no-audit --no-fund
else
  echo "npm not found: the statusline uses ccusage from PATH" >&2
fi

mkdir -p "$HOME/.claude"
if [ -L "$TARGET" ]; then
  rm "$TARGET"
elif [ -e "$TARGET" ] && ! cmp -s "$DIR/statusline.sh" "$TARGET"; then
  mv "$TARGET" "$TARGET.bak"
  echo "Moved the existing $TARGET to $TARGET.bak"
fi
cp "$DIR/statusline.sh" "$TARGET"
echo "Copied statusline.sh to $TARGET"

for profile in "$HOME/.claude" "$HOME/.claude-work"; do
  [ -d "$profile" ] || continue
  settings="$profile/settings.json"
  [ -s "$settings" ] || echo '{}' > "$settings"
  updated=$(jq '.statusLine = {type: "command", command: "~/.claude/statusline.sh", padding: 0}' "$settings")
  printf '%s\n' "$updated" > "$settings"
  echo "Set statusLine in $settings"
done
