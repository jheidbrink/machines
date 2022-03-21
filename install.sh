#!/usr/bin/env bash

set -eu

host=$1

cp -r * /etc/nixos/
ln -sf configuration-$host.nix /etc/nixos/configuration.nix
nixos-rebuild switch
