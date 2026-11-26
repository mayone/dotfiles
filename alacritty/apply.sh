#!/usr/bin/env bash
#
# Link the Alacritty configuration.

set -euo pipefail

ALACRITTY_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd -P )"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/alacritty"

source "$ALACRITTY_DIR/../sh_utils/index.sh"

main() {
  require_main_checkout "$ALACRITTY_DIR/.." alacritty/apply.sh

  link_config "$ALACRITTY_DIR/alacritty.toml" "$CONFIG_DIR/alacritty.toml"
}

main "$@"
