#!/usr/bin/env bash
#
# Uninstall.

# Use ${BASH_SOURCE[0]} if script is not executed by source, else use $0
SOURCE="${BASH_SOURCE[0]:-$0}"
DIR_PATH="$( cd -- "$( dirname -- "$SOURCE" )" >/dev/null 2>&1 && pwd -P )"

source $DIR_PATH/sh_utils/index.sh

main() {
  uninstall_herdr
  uninstall_mise
  uninstall_terminal
  uninstall_shell

  uninstall_languages
  uninstall_pkgmanager
}

uninstall_herdr() {
  if ! check_cmd herdr; then
    return
  fi

  local profile
  for profile in "$HOME/.claude" "$HOME/.claude-work"; do
    if check_folder "$profile"; then
      CLAUDE_CONFIG_DIR="$profile" herdr integration uninstall claude
    fi
  done
}

uninstall_mise() {
  if check_cmd mise; then
    mise implode --config
  fi
}

uninstall_terminal() {
  rm -rf ~/.tmux/plugins
}

uninstall_shell() {
  ZINIT_DIR="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/"
  rm -rf $ZINIT_DIR
}

uninstall_languages() {
  rustup self uninstall
}

uninstall_pkgmanager() {
  if check_os $OS_MAC; then
    if check_cmd brew; then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
    fi
  fi
}

main "$@"
