#!/usr/bin/env bash

set -euo pipefail

target_hostname="$1"

ls -l

if [[ ! -f configuration-${target_hostname}.nix ]]
then
	echo "Wrong directory, run this from root of machines repo"
	exit 1
fi

echo "Calling nixos-generate-config"
nixos-generate-config --root /mnt

echo "Copying the generated hardware-configuration.nix to machines/${target_hostname}"
mkdir -p "machines/${target_hostname}"
cp -f /mnt/etc/nixos/hardware-configuration.nix "machines/${target_hostname}/"

echo "Make sure you import machines/${target_hostname} in configuration-${target_hostname}.nix"
echo "Make sure you commit the generated hardware-configuration.nix somewhere persistent"
echo "when done, press enter"
read -r

echo "Copying config and running nixos-install"
cp -r ./* /mnt/etc/nixos/
ln -sf "configuration-${target_hostname}.nix" /mnt/etc/nixos/configuration.nix
nixos-install
