#!/usr/bin/env bash

set -euo pipefail

MISE_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd -P )"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/mise"
ZPROFILE="${ZDOTDIR:-$HOME}/.zprofile"

source "$MISE_DIR/../sh_utils/index.sh"

main() {
  if ! check_cmd mise; then
    echo "mise is required: https://mise.jdx.dev/installing-mise.html" >&2
    exit 1
  fi
  require_main_checkout "$MISE_DIR/.." mise/apply.sh

  link_config "$MISE_DIR/global.toml" "$CONFIG_DIR/config.toml"
  if ! check_set "${NO_DEV:-}"; then
    link_config "$MISE_DIR/dev.toml" "$CONFIG_DIR/conf.d/dev.toml"
  fi

  if check_os "$OS_MAC" && ! check_cmd brew; then
    add_zprofile_line 'export PATH="/opt/homebrew/bin:$PATH"'
  fi
  if [[ "$(command -v mise)" == "$HOME/.local/bin/mise" ]]; then
    add_zprofile_line 'export PATH="$HOME/.local/bin:$PATH"'
  fi
  add_zprofile_line 'command -v mise >/dev/null 2>&1 && eval "$(mise activate zsh --shims)"'

  local packages_failed=""
  info "Install packages"
  if ! mise bootstrap --only packages; then
    packages_failed=1
    warn "Some packages failed to install; installing the tools anyway"
  fi

  info "Install tools"
  mise install

  if check_set "$packages_failed"; then
    warn "Some packages are missing: fix the errors above and run mise/apply.sh again"
    exit 1
  fi
}

add_zprofile_line() {
  local line="$1"

  if ! grep -qxF "$line" "$ZPROFILE" 2>/dev/null; then
    printf '%s\n' "$line" >> "$ZPROFILE"
    info "Added to $ZPROFILE: $line"
  fi
}

main "$@"
