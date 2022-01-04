#!/bin/bash
#
# Install dotfiles.

DIR_PATH=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

source $DIR_PATH/sh_utils/utils.sh

main() {
  install_homebrew
  install_languages

  install_terminal
  install_shell
  install_vim
  install_editor
  install_tools

  setup_git
}

install_clt() {
  # Install Command Line Developer Tools for Xcode
  if check_cmd xcode-select; then
    xcode-select --install
  fi
}

install_homebrew() {
  if ! check_os $OS_MAC; then
    return
  fi

  if ! check_cmd brew; then
    info "Install Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  fi
}

install_languages() {
  # Install GCC
  if check_os $OS_LINUX; then
    sudo apt update
    if ! check_cmd gcc || ! check_cmd make; then
      sudo apt install build-essential
    fi
  fi

  if check_os $OS_MAC; then
    brew install go
    brew install node yarn
  fi

  # Install OpenJDK
  if ! check_cmd java; then
    info "Install OpenJDK"
    if check_os $OS_MAC; then
      brew install --cask adoptopenjdk
    elif check_os $OS_LINUX; then
      sudo apt install default-jdk
    fi
  fi

  # Install Rust
  if ! check_cmd rustup; then
    info "Install Rust"
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    source ~/.cargo/env
    rustup default stable

    # lints
    rustup component add clippy

    # Cross-compilation
    #rustup target add aarch64-apple-ios x86_64-apple-ios
    #rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android
  fi
}

install_terminal() {
  if check_os $OS_MAC; then
    brew install --cask iterm2
  fi
}

install_shell() {
  # Install zsh
  if ! check_cmd zsh; then
    info "Install Zsh"
    if check_os $OS_MAC; then
      brew install zsh zsh-completions
    elif check_os $OS_LINUX; then
      sudo apt install zsh
    fi

    # Set default shell to zsh
    chsh -s "$(which zsh)"
  fi

  # Merge zshrc contents if one already exists, otherwise just copy it over
  if check_exist ~/.zshrc; then
    :
    # info "Merging .zshrc files"
    # cat zsh/.zshrc | cat - ~/.zshrc > temp && rm ~/.zshrc && mv temp ~/.zshrc
  else
    info "Copy .zshrc file"
    cp zsh/.zshrc ~/.zshrc
  fi

  # Install Nerdfonts
  # if check_os $OS_MAC; then
  #   brew tap homebrew/cask-fonts
  #   brew install --cask font-meslo-lg-nerd-font
  #   brew install --cask font-fira-code-nerd-font
  # fi
}

install_vim() {
  info "Copy .vimrc file"
  cp vim/.vimrc ~/.vimrc
}

install_editor() {
  if check_os $OS_MAC; then
    brew install --cask visual-studio-code
    # Copy vscode settings
    mkdir -p ~/Library/Application\ Support/Code/User
    cp vscode/* ~/Library/Application\ Support/Code/User/
  fi
}

install_tools() {
  if check_os $OS_MAC; then
    brew install kubectx hub shfmt
    brew install tmux wget ffmpeg
  fi
  # Copy tmux settings
  info "Copy .tmux.conf file"
  cp tmux/.tmux.conf ~/.tmux.conf
}

setup_git() {
  # Set git settings/aliases
  git config --global alias.co checkout
  git config --global alias.br branch
  git config --global alias.com commit
  git config --global alias.st status
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