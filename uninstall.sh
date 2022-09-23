#!/bin/bash
#
# Uninstall.

# Use ${BASH_SOURCE[0]} if script is not executed by source, else use $0
SOURCE="${BASH_SOURCE[0]:-$0}"
DIR_PATH="$( cd -- "$( dirname -- "$SOURCE" )" >/dev/null 2>&1 && pwd -P )"

source $DIR_PATH/sh_utils/index.sh

main() {
  uninstall_tools
  uninstall_shell

  uninstall_languages
  uninstall_pkgmanager
}

uninstall_tools() {
  if check_os $OS_MAC; then
    brew remove hub shfmt
    brew remove tmux wget ffmpeg
    brew remove kubectx
  fi
}

uninstall_shell() {
  rm -rf ~/.zinit/
}

uninstall_languages() {
  if check_os $OS_MAC; then
    brew remove --cask temurin

    brew remove go
    brew remove node yarn
  fi

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
