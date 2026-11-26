#!/bin/bash
#
# Link config files into the checkout.

#######################################
# Refuse to run from a linked worktree, where .git is a file and not a
# directory.
# Arguments:
#   Root of the checkout.
#   Name of the script, for the message.
# Returns:
#   1 in a linked worktree, 0 in the main checkout.
#######################################
require_main_checkout() {
  local root_path="$1" script_name="$2"

  if [[ -f "$root_path/.git" ]]; then
    echo "Run $script_name from the main checkout: links into a worktree break when the worktree is removed" >&2
    return 1
  fi
}

#######################################
# Link a config file of the checkout to the path where its program reads it.
# Arguments:
#   Config file in the checkout.
#   Path of the link.
#######################################
link_config() {
  local config_file="$1" link_path="$2"

  mkdir -p "$(dirname "$link_path")"
  if [[ -e "$link_path" && ! -L "$link_path" ]]; then
    mv "$link_path" "$link_path.bak"
    warn "Moved the existing $link_path to $link_path.bak"
  elif [[ -L "$link_path" && "$(readlink "$link_path")" != "$config_file" ]]; then
    warn "Relinked $link_path, which pointed to $(readlink "$link_path")"
  fi
  ln -sfn "$config_file" "$link_path"
  info "Linked $link_path"
}
