#!/bin/bash
#
# Update.

# Use ${BASH_SOURCE[0]} if script is not executed by source, else use $0
SOURCE="${BASH_SOURCE[0]:-$0}"
DIR_PATH="$( cd -- "$( dirname -- "$SOURCE" )" >/dev/null 2>&1 && pwd -P )"

source $DIR_PATH/sh_utils/index.sh

# Variables
ZINIT_HOME="$HOME/.zinit"

main() {
  update_pkgmanager

  update_rust
  # update_pip
  update_zinit
}

update_pkgmanager() {
  info "Update packages"
  if check_os $OS_MAC; then
    if ! check_cmd brew; then
      info "No brew for update"
      return
    fi

    # Update Homebrew
    brew update
    # Update packages
    brew upgrade
  elif check_os $OS_LINUX; then
    sudo apt update
    # Update packages
    sudo apt upgrade
  fi
}

update_rust() {
  if ! check_cmd rustup; then
    info "No rust for update"
    return
  fi

  info "Update rust"
  rustup update
}

update_pip() {
  if ! check_cmd pip3; then
    info "No pip3 for update"
    return
  fi

  info "Update pip3"
  pip3 install --upgrade pip
}

update_zinit() {
  if ! check_exist "${ZINIT_HOME}"; then
    info "No zinit for update"
    return
  fi

  info "Update zinit"
  zsh -ic 'zi self-update; zi update -p 20'
}

main "$@"
