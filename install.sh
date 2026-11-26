#!/usr/bin/env bash
#
# Install dotfiles.

# Use ${BASH_SOURCE[0]} if script is not executed by source, else use $0
SOURCE="${BASH_SOURCE[0]:-$0}"
DIR_PATH="$( cd -- "$( dirname -- "$SOURCE" )" >/dev/null 2>&1 && pwd -P )"
ROOT_PATH="$DIR_PATH"

source $DIR_PATH/sh_utils/index.sh

main() {
  install_pkgmanager

  install_essentials
  install_packages

  link_configs
  install_shell
  install_terminal

  setup_claude_statusline
  setup_herdr

  setup_git
  setup_gh

  if check_set $MISE_APPLY_FAILED; then
    warn "mise/apply.sh failed: fix the errors it printed and run it again"
    exit 1
  fi
  if check_set "$LINK_FAILED"; then
    warn "link.sh failed: fix the errors it printed and run it again"
    exit 1
  fi
  if check_set "$GHOSTTY_APPLY_FAILED"; then
    warn "ghostty/apply.sh failed: fix the errors it printed and run it again"
    exit 1
  fi
  if check_set "$HERDR_APPLY_FAILED"; then
    warn "herdr/apply.sh failed: fix the errors it printed and run it again"
    exit 1
  fi
}

install_pkgmanager() {
  if check_os $OS_MAC; then
    export PATH="/opt/homebrew/bin:$PATH"
  elif check_os $OS_LINUX; then
    sudo apt update
  fi

  if ! check_cmd mise; then
    info "Install mise"
    curl -fsSL https://mise.run | sh
    export PATH="$HOME/.local/bin:$PATH"
  fi
}

install_essentials() {
  if check_os $OS_MAC && ! xcode-select -p >/dev/null 2>&1; then
    info "Install Command Line Developer Tools for Xcode"
    xcode-select --install
    until xcode-select -p >/dev/null 2>&1; do
      sleep 5
    done
  fi
}

install_packages() {
  if ! check_cmd zsh; then
    ZSH_WAS_MISSING=1
  fi

  if ! "$ROOT_PATH/mise/apply.sh"; then
    MISE_APPLY_FAILED=1
  fi
  if check_cmd mise; then
    eval "$(mise activate bash --shims)"
  fi
}

link_configs() {
  info "Link the config files"
  if ! "$ROOT_PATH/link.sh"; then
    LINK_FAILED=1
  fi
}

install_shell() {
  if check_set $ZSH_WAS_MISSING && check_cmd zsh; then
    # Set default shell to zsh
    chsh -s "$(which zsh)"
  fi

  if check_os $OS_LINUX; then
    # apt's fzf is too old on Ubuntu 22.04/24.04 and Debian 12: the zshrc needs
    # fzf --zsh (0.48) and SessionX needs 0.41, so use the upstream binary
    if ! check_folder ~/.fzf; then
      git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    fi
    ~/.fzf/install --bin
  fi
}

install_terminal() {
  info "Set up Ghostty"
  if ! "$ROOT_PATH/ghostty/apply.sh"; then
    GHOSTTY_APPLY_FAILED=1
  fi
}

setup_claude_statusline() {
  info "Set up Claude Code statusline"
  "$ROOT_PATH/claude/install-statusline.sh"
}

setup_herdr() {
  info "Set up herdr"
  if ! "$ROOT_PATH/herdr/apply.sh"; then
    HERDR_APPLY_FAILED=1
  fi
}

setup_git() {
  # Set git settings/aliases
  git config --global alias.co checkout
  git config --global alias.br branch
  git config --global alias.com commit
  git config --global alias.st status
  git config --global alias.pr "pull --rebase"
  if check_os $OS_MAC; then
    git config --global credential.helper osxkeychain
  elif check_os $OS_LINUX; then
    git config --global credential.helper cache
  fi

  # if [ -z "$(git config --global --get user.email)" ]; then
  #   echo "Git user.name:"
  #   read -r user_name
  #   echo "Git user.email:"
  #   read -r user_email
  #   git config --global user.name "$user_name"
  #   git config --global user.email "$user_email"
  # fi
}

setup_gh() {
  # gsync in zsh/.zshrc deletes the branches of merged PRs with gh poi
  if ! check_cmd gh; then
    return
  fi
  # gh extension commands exit 4 without a login. gh auth token is not the
  # same check: it can find a Keychain token when hosts.yml has no login
  local extensions status=0
  extensions="$(gh extension list 2>/dev/null)" || status=$?
  if [[ $status -eq 4 ]]; then
    warn "gh is not logged in: run gh auth login, then gh extension install seachicken/gh-poi"
    return
  fi
  if ! grep -qF seachicken/gh-poi <<<"$extensions"; then
    info "Install gh-poi"
    if ! gh extension install seachicken/gh-poi; then
      warn "gh extension install seachicken/gh-poi failed: fix the errors it printed and run it again"
    fi
  fi
}

main "$@"
