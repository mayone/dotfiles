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

# Oh My Zsh libraries (key bindings, completion styles, directory and history
# options), loaded first so the settings below override them
ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
[[ -d $ZSH_CACHE_DIR ]] || mkdir -p "$ZSH_CACHE_DIR"
zinit for \
  OMZL::completion.zsh \
  OMZL::directories.zsh \
  OMZL::functions.zsh \
  OMZL::history.zsh \
  OMZL::key-bindings.zsh \
  OMZL::misc.zsh

#
# Exports
#

# History file configuration
typeset -g HISTSIZE=5000 SAVEHIST=5000 HISTFILE=~/.zsh_history

# Keep PATH entries unique, e.g. in nested shells
typeset -U path PATH

export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin:/usr/local/bin
# Native installers such as claude put binaries here
export PATH=$HOME/.local/bin:$PATH
# fzf cloned by install.sh on Linux, ahead of an older system fzf
[ -d ~/.fzf/bin ] && export PATH=$HOME/.fzf/bin:$PATH
[ -f ~/.cargo/env ] && source ~/.cargo/env
export LANG="en_US.UTF-8"

# NVM
export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# fzf key bindings and completion; skipped when fzf is older than 0.48 and
# has no --zsh, which would print "unknown option" in every new shell
if command -v fzf >/dev/null 2>&1 && _fzf_init="$(fzf --zsh 2>/dev/null)"; then
  eval "$_fzf_init"
fi
unset _fzf_init

#
# Aliases
#

if command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=never'
fi

if command -v eza >/dev/null 2>&1; then
  alias l='eza'     l.='eza -d .*'  la='eza -a' ll='eza -laah'
  # --classify=auto, not -F: eza's zsh completion takes the word after -F as
  # its value, so file names stop completing
  alias ls='eza --classify=auto'
else
  alias l='ls -CF'  l.='ls -d .*'   la='ls -A'  ll='ls -alF'
fi

if command -v htop >/dev/null 2>&1; then
  alias top=htop
fi

alias df='df -h'    du='du -h'      cp='cp -v'  mv='mv -v'

if command -v claude >/dev/null 2>&1; then
  alias cl='cd ~/claude-workspace && CLAUDE_CODE_SUBAGENT_MODEL=opus claude --effort max'
  alias clop='cd ~/claude-workspace && ANTHROPIC_MODEL=claude-opus-5-5[1m] claude --effort max'
  alias clso='cd ~/claude-workspace && ANTHROPIC_MODEL=claude-sonnet-5-5   claude --effort max'

  # A work machine makes cl-work the default with this ~/.zshenv. It sets the
  # default once per process tree, so child shells keep the parent's profile:
  #   if [[ -z $CL_PROFILE_DEFAULTED ]]; then
  #     export CL_PROFILE_DEFAULTED=1
  #     export CLAUDE_CONFIG_DIR=$HOME/.claude-work
  #   fi
  alias cl-pers='unset CLAUDE_CONFIG_DIR'
  alias cl-work='export CLAUDE_CONFIG_DIR=$HOME/.claude-work'
fi

# Git
alias glog_branches="git log --color=always --oneline --decorate --graph --branches"

# Fetch and prune, delete local branches of merged PRs with gh poi after a
# confirmation (it also removes their clean linked worktrees, ignored files
# included), then fast-forward every local branch that is behind its upstream:
# the branch you end up on, the rest, and those checked out in other worktrees
# without uncommitted changes. Diverged branches only get a warning.
# Replaces `hub sync`; needs seachicken/gh-poi.
gsync() {
  git fetch --all --prune || return
  local plan deleted
  if plan=$(gh poi --dry-run) && [[ $plan == *'Deleted branches'* ]]; then
    deleted=${${plan#*Deleted branches}%%Branches not deleted*}
    if [[ $deleted != *'There are no branches'* ]]; then
      print -r -- "gh poi would delete:${deleted%$'\n\n'}"
      if read -q '?Delete them? [y/N] '; then
        print
        gh poi
      else
        print
      fi
    fi
  fi
  local head branch old upstream track wt rc=0
  head=$(git symbolic-ref -q HEAD)
  while IFS=: read -r branch old upstream track wt; do
    [[ refs/heads/$branch == "$head" ]] && continue
    case $track in
      '<>') print -ru2 -- "warning: skipped '$branch': diverged from its upstream" ;;
      '<')
        if [[ -z $wt ]]; then
          git fetch -q . "${upstream}:refs/heads/$branch" || { rc=1; continue; }
        elif [[ -z $(git -C "$wt" status --porcelain --untracked-files=no) ]]; then
          git -C "$wt" merge --ff-only -q "$upstream" || { rc=1; continue; }
        else
          print -ru2 -- "warning: skipped '$branch': uncommitted changes in $wt"
          continue
        fi
        print -r -- "Updated branch $branch (was $old)."
        ;;
    esac
  done < <(git for-each-ref --format='%(refname:lstrip=2):%(objectname:short):%(upstream):%(upstream:trackshort):%(worktreepath)' refs/heads)
  git merge --ff-only '@{u}' || rc=1
  return $rc
}

#
# Load plugins
#

# Fast-syntax-highlighting & autosuggestions. compinit runs without -C, so
# ~/.zcompdump is rebuilt when completion files change (no global compinit)
zinit wait lucid for \
  atinit"ZINIT[COMPINIT_OPTS]=-i; zpcompinit; zpcdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
  atload"!_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions \
  blockf \
    zsh-users/zsh-completions

# Powerlevel10k
zinit ice depth=1
zinit light romkatv/powerlevel10k

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
