#!/usr/bin/env bash

set -euo pipefail

GHOSTTY_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd -P )"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"

source "$GHOSTTY_DIR/../sh_utils/index.sh"

main() {
  require_main_checkout "$GHOSTTY_DIR/.." ghostty/apply.sh

  move_legacy_config
  link_config "$GHOSTTY_DIR/config.ghostty" "$CONFIG_DIR/config.ghostty"
  if check_os "$OS_MAC"; then
    link_config "$GHOSTTY_DIR/macos.ghostty" "$CONFIG_DIR/macos.ghostty"
  else
    link_config "$GHOSTTY_DIR/linux.ghostty" "$CONFIG_DIR/linux.ghostty"
  fi
}

move_legacy_config() {
  local legacy_path="$CONFIG_DIR/config"

  if [[ -e "$legacy_path" || -L "$legacy_path" ]]; then
    mv "$legacy_path" "$legacy_path.bak"
    warn "Moved $legacy_path to $legacy_path.bak: Ghostty loads it next to config.ghostty"
  fi
}

main "$@"
