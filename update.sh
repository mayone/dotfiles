#!/bin/bash
#
# Update.

# Use ${BASH_SOURCE[0]} if script is not executed by source, else use $0
SOURCE="${BASH_SOURCE[0]:-$0}"
DIR_PATH="$( cd -- "$( dirname -- "$SOURCE" )" >/dev/null 2>&1 && pwd -P )"

source $DIR_PATH/sh_utils/index.sh

# Variables
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

main() {
  update_pkgmanager

  update_gcloud_cli

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
    # List outdated packages for manual upgrade
    warn "Outdated packages"
    brew outdated --greedy
  elif check_os $OS_LINUX; then
    sudo apt update
    # Update packages
    sudo apt upgrade
  fi
}

update_gcloud_cli() {
  if ! check_cmd gcloud; then
    info "No gcloud for update"
    return
  fi

  info "Update gcloud components"
  gcloud components update
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
