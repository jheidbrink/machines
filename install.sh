#!/usr/bin/env bash

set -eu

host=$1

rsync --recursive --exclude=.mypy_cache ./ /etc/nixos/
ln -sf configuration-"${host}".nix /etc/nixos/configuration.nix
nixos-rebuild switch
