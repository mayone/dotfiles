#!/usr/bin/env bash
#
# Run the Nix garbage collector.

nix-channel --update
nix-env -u --always
rm /nix/var/nix/gcroots/auto/*
nix-collect-garbage -d