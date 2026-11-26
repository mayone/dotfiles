#!/usr/bin/env bash
#
# Link the zsh, tmux, and Vim config of this checkout into the home directory.

set -euo pipefail

# sh_utils/index.sh overwrites DIR_PATH, so keep the repo root separately
ROOT_PATH="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd -P )"

source "$ROOT_PATH/sh_utils/index.sh"

main() {
  require_main_checkout "$ROOT_PATH" link.sh

  link_config "$ROOT_PATH/zsh/.zshrc" "${ZDOTDIR:-$HOME}/.zshrc"
  link_config "$ROOT_PATH/tmux/.tmux.conf" "$HOME/.tmux.conf"
  link_config "$ROOT_PATH/vim/.vimrc" "$HOME/.vimrc"
}

main "$@"
