#!/usr/bin/env bash
#
# Apply Nix configuration.
# Extra arguments go to `nixos-rebuild switch`, e.g. `--upgrade` to also
# update the nixos channel.

set -euo pipefail

# sh_utils/index.sh overwrites DIR_PATH, so keep this directory separately
NIX_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd -P )"

source "$NIX_DIR/../sh_utils/index.sh"

main() {
  local old_version new_version
  old_version="$(nixos-version)"

  info "Apply configuration.nix"
  sudo cp "$NIX_DIR/configuration.nix" /etc/nixos/
  sudo nixos-rebuild switch "$@"

  new_version="$(nixos-version)"
  if [[ "$new_version" == "$old_version" ]]; then
    info "NixOS unchanged: $new_version"
  else
    ok "NixOS $old_version -> $new_version"
  fi

  if [[ "$(readlink -f /run/booted-system/kernel)" != "$(readlink -f /run/current-system/kernel)" ]]; then
    warn "Kernel changed, reboot to apply"
  fi
}

main "$@"
