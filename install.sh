#!/bin/bash
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

  if ! check_set $NO_DEV; then
    install_languages
  fi

  install_shell
  install_terminal
  install_editor

  setup_claude_statusline
  setup_herdr

  setup_git

  if check_set $MISE_APPLY_FAILED; then
    warn "mise/apply.sh failed: fix the errors it printed and run it again"
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

install_languages() {
  # Install Rust
  if ! check_cmd rustup; then
    info "Install Rust"
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    source ~/.cargo/env
    rustup default stable
    rustup toolchain install nightly

    # lints
    rustup component add clippy

    # Cross-compilation
    # rustup target add aarch64-apple-ios x86_64-apple-ios aarch64-apple-darwin
    # rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android
    rustup target add wasm32-unknown-unknown
  fi
}

install_shell() {
  if check_set $ZSH_WAS_MISSING && check_cmd zsh; then
    # Set default shell to zsh
    chsh -s "$(which zsh)"
  fi

  # Copy zshrc
  if check_exist ~/.zshrc; then
    :
    # info "Merging .zshrc files"
    # cat zsh/.zshrc | cat - ~/.zshrc > temp && rm ~/.zshrc && mv temp ~/.zshrc
  else
    info "Copy .zshrc file"
    cp zsh/.zshrc ~/.zshrc
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
  # Copy tmux settings
  info "Copy .tmux.conf file"
  cp tmux/.tmux.conf ~/.tmux.conf
}

install_editor() {
  if check_os $OS_MAC; then
    # Copy vscode settings
    mkdir -p ~/Library/Application\ Support/Code/User
    cp .vscode/settings.json ~/Library/Application\ Support/Code/User/settings.json
  fi

  # Copy vim settings
  info "Copy .vimrc file"
  cp vim/.vimrc ~/.vimrc
}

setup_claude_statusline() {
  info "Set up Claude Code statusline"
  "$ROOT_PATH/claude/install-statusline.sh"
}

setup_herdr() {
  info "Set up herdr"
  "$ROOT_PATH/herdr/apply.sh"
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

main "$@"
