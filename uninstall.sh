#!/bin/bash
#
# Uninstall.

# Use ${BASH_SOURCE[0]} if script is not executed by source, else use $0
SOURCE="${BASH_SOURCE[0]:-$0}"
DIR_PATH="$( cd -- "$( dirname -- "$SOURCE" )" >/dev/null 2>&1 && pwd -P )"

source $DIR_PATH/sh_utils/index.sh

main() {
  uninstall_tools
  uninstall_mise
  uninstall_shell

  uninstall_languages
  uninstall_pkgmanager
}

uninstall_tools() {
  if check_os $OS_MAC; then
    brew remove tmux wget ffmpeg
  fi
}

uninstall_mise() {
  if check_cmd mise; then
    mise implode --config
  fi
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
