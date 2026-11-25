#!/usr/bin/env bash

set -euo pipefail

GHOSTTY_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd -P )"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"

source "$GHOSTTY_DIR/../sh_utils/index.sh"

main() {
  if [[ -f "$GHOSTTY_DIR/../.git" ]]; then
    echo "Run ghostty/apply.sh from the main checkout: links into a worktree break when the worktree is removed" >&2
    exit 1
  fi

  link_config "$GHOSTTY_DIR/config.ghostty" "$CONFIG_DIR/config.ghostty"
  if check_os "$OS_MAC"; then
    link_config "$GHOSTTY_DIR/macos.ghostty" "$CONFIG_DIR/macos.ghostty"
  else
    link_config "$GHOSTTY_DIR/linux.ghostty" "$CONFIG_DIR/linux.ghostty"
  fi
}

# The same as link_config in mise/apply.sh
link_config() {
  local config_file="$1" link_path="$2"

  mkdir -p "$(dirname "$link_path")"
  if [[ -e "$link_path" && ! -L "$link_path" ]]; then
    mv "$link_path" "$link_path.bak"
    warn "Moved the existing $link_path to $link_path.bak"
  elif [[ -L "$link_path" && "$(readlink "$link_path")" != "$config_file" ]]; then
    warn "Relinked $link_path, which pointed to $(readlink "$link_path")"
  fi
  ln -sfn "$config_file" "$link_path"
  info "Linked $link_path"
}

main "$@"
