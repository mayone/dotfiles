#
# Exports
#

# History file configuration
typeset -g HISTSIZE=5000 SAVEHIST=5000 HISTFILE=~/.zsh_history

export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin:$GOROOT/bin:/usr/local/bin
source ~/.cargo/env
export LANG="en_US.UTF-8"

# NVM
export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

#
# Powerlevel10k instant prompt
#

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#
# Aliases
#

if command -v bat >/dev/null 2>&1; then
    alias cat='bat --paging=never'
fi

if command -v exa >/dev/null 2>&1; then
    alias l='exa'       l.='exa -d .*'  la='exa -a' ll='exa -laah'
    alias ls='exa -F'
else
    alias l='ls -CF'    l.='ls -d .*'   la='ls -A'  ll='ls -alF'
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
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
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
