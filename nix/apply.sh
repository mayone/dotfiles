#!/usr/bin/env bash
#
# Apply Nix configuration.

sudo cp configuration.nix /etc/nixos
sudo nixos-rebuild switch