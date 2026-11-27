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
  require_devices

  local old_version new_version
  old_version="$(nixos-version)"

  info "Apply configuration.nix"
  diff -u /etc/nixos/configuration.nix "$NIX_DIR/configuration.nix" || true
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

require_devices() {
  local device missing=""

  while read -r device; do
    if [[ ! -e "$device" ]]; then
      warn "nix/configuration.nix names $device, which this machine does not have"
      missing=1
    fi
  done < <(grep -v '^[[:space:]]*#' "$NIX_DIR/configuration.nix" | grep -o '/dev/disk/[^"]*')

  if check_set "$missing"; then
    warn "Did not apply nix/configuration.nix: it is written for another machine or an earlier install. Adapt it to this machine and run nix/apply.sh again"
    exit 1
  fi
}

main "$@"
