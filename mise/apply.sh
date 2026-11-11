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

  info "Install packages and tools"
  mise bootstrap --only packages,tools
}

link_config() {
  local config_file="$1" link_path="$2"

  mkdir -p "$(dirname "$link_path")"
  if [[ -e "$link_path" && ! -L "$link_path" ]]; then
    mv "$link_path" "$link_path.bak"
    warn "Moved the existing $link_path to $link_path.bak"
  fi
  ln -sfn "$config_file" "$link_path"
  info "Linked $link_path"
}

add_zprofile_line() {
  local line="$1"

  if ! grep -qxF "$line" "$ZPROFILE" 2>/dev/null; then
    printf '%s\n' "$line" >> "$ZPROFILE"
    info "Added to $ZPROFILE: $line"
  fi
}

main "$@"
