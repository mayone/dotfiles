#
# Exports
#

# History file configuration
typeset -g HISTSIZE=5000 SAVEHIST=5000 HISTFILE=~/.zsh_history

export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin:$GOROOT/bin:/usr/local/bin
[ -f ~/.cargo/env ] && source ~/.cargo/env
export LANG="en_US.UTF-8"

# NVM
export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

#
# Powerlevel10k instant prompt
#

typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#
# Aliases
#

if command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=never'
fi

if command -v eza >/dev/null 2>&1; then
  alias l='eza'     l.='eza -d .*'  la='eza -a' ll='eza -laah'
  alias ls='eza -F'
else
  alias l='ls -CF'  l.='ls -d .*'   la='ls -A'  ll='ls -alF'
fi

if command -v htop >/dev/null 2>&1; then
  alias top=htop
fi

alias df='df -h'    du='du -h'      cp='cp -v'  mv='mv -v'

# Git
if command -v hub >/dev/null 2>&1; then
  alias git=hub
fi
alias glog_branches="git log --color=always --oneline --decorate --graph --branches"

#
# Zinit (plugin manager)
#

# Zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d $ZINIT_HOME ]]; then
  print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
  mkdir -p "$(dirname $ZINIT_HOME)"
fi
if [[ ! -d $ZINIT_HOME/.git ]]; then
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" && \
    print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
    print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi
source "${ZINIT_HOME}/zinit.zsh"

autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Zinit annexes
zinit light-mode for \
  zdharma-continuum/zinit-annex-rust \
  zdharma-continuum/zinit-annex-as-monitor \
  zdharma-continuum/zinit-annex-patch-dl \
  zdharma-continuum/zinit-annex-bin-gem-node

#
# Load plugins
#

# Fast-syntax-highlighting & autosuggestions
zinit wait lucid for \
  atinit"ZINIT[COMPINIT_OPTS]=-C; zpcompinit; zpcdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
  atload"!_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions \
  blockf \
    zsh-users/zsh-completions

zinit wait lucid for \
  zdharma-continuum/zsh-unique-id \
  OMZ::lib/git.zsh \
  atload"unalias grv g" \
  OMZ::plugins/git/git.plugin.zsh

# Powerlevel10k
zinit ice depth=1
zinit light romkatv/powerlevel10k
