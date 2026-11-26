#!/usr/bin/env bash
#
# Link the VSCodium settings.

set -euo pipefail

VSCODE_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd -P )"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/VSCodium/User"

source "$VSCODE_DIR/../sh_utils/index.sh"

main() {
  require_main_checkout "$VSCODE_DIR/.." .vscode/apply_vscodium.sh

  link_config "$VSCODE_DIR/settings.json" "$CONFIG_DIR/settings.json"
}

main "$@"
