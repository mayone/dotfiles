#!/bin/bash
#
# Install dotfiles.

DIR_PATH=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

source $DIR_PATH/sh_utils/utils.sh

main() {
  install_homebrew
  install_languages

  install_shell
  install_terminal
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
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
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

  # Install OpenJDK
  info "Install OpenJDK"
  if check_os $OS_MAC; then
    brew install --cask temurin
  elif check_os $OS_LINUX; then
    sudo apt install default-jdk
  fi

  # Install Go
  if check_os $OS_MAC; then
    brew install go
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

  # Install Node.js
  if check_os $OS_MAC; then
    brew install node yarn
  fi
}

install_shell() {
  # Install Zsh
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

  # Copy zshrc
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

install_terminal() {
  # Install iTerm2
  if check_os $OS_MAC; then
    brew install --cask iterm2
  fi

  # Install tmux
  if check_os $OS_MAC; then
    brew install tmux
  elif check_os $OS_LINUX; then
    sudo apt install tmux
  fi

  # Copy tmux settings
  info "Copy .tmux.conf file"
  cp tmux/.tmux.conf ~/.tmux.conf
}

install_editor() {
  # Install VS Code
  if check_os $OS_MAC; then
    brew install --cask visual-studio-code
    # Copy vscode settings
    mkdir -p ~/Library/Application\ Support/Code/User
    cp vscode/* ~/Library/Application\ Support/Code/User/
  fi

  # Copy vim settings
  info "Copy .vimrc file"
  cp vim/.vimrc ~/.vimrc
}

install_tools() {
  if check_os $OS_MAC; then
    brew install kubectx hub shfmt
    brew install wget ffmpeg
    brew install --cask rectangle discord
    brew install --cask docker
    brew install --cask google-chrome
  fi
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
