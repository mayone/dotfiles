#!/usr/bin/env bash

set -euo pipefail

HERDR_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd -P )"
CONFIG_PATH="${HERDR_CONFIG_PATH:-${XDG_CONFIG_HOME:-$HOME/.config}/herdr/config.toml}"

source "$HERDR_DIR/../sh_utils/index.sh"

main() {
  if ! check_cmd herdr; then
    echo "herdr is required: run mise/apply.sh first" >&2
    exit 1
  fi

  copy_config
  install_claude_integration
}

copy_config() {
  mkdir -p "$(dirname "$CONFIG_PATH")"
  if [[ -L "$CONFIG_PATH" ]]; then
    rm "$CONFIG_PATH"
  elif [[ -e "$CONFIG_PATH" ]] && ! cmp -s "$HERDR_DIR/config.toml" "$CONFIG_PATH"; then
    mv "$CONFIG_PATH" "$CONFIG_PATH.bak"
    warn "Moved the existing $CONFIG_PATH to $CONFIG_PATH.bak"
  fi
  cp "$HERDR_DIR/config.toml" "$CONFIG_PATH"
  info "Copied config.toml to $CONFIG_PATH"
}

install_claude_integration() {
  local profile failed=""

  for profile in "$HOME/.claude" "$HOME/.claude-work"; do
    if ! check_folder "$profile"; then
      continue
    fi

    info "Install the Claude Code integration in $profile"
    if ! CLAUDE_CONFIG_DIR="$profile" herdr integration install claude; then
      failed=1
      warn "The Claude Code integration failed in $profile"
    fi
  done

  if check_set "$failed"; then
    exit 1
  fi
}

main "$@"
