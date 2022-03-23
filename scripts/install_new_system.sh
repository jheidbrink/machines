#!/usr/bin/env bash

set -euo pipefail

cryptroot_device=$1
target_hostname=$2

ls -l

if [[ ! -f configuration-${target_hostname}.nix ]]
then
	echo "Wrong directory, run this from root of machines repo"
	exit 1
fi

if [[ $(blkid  | grep crypto_LUKS | wc -l) -ne 1 ]]
then
	echo "Expected exactly one line containing crypto_LUKS in blkid output"
	exit 1
fi
cryptroot_uuid=$(blkid | grep crypto_LUKS | sed -e 's/.*UUID="\(.*\)" TYPE=.*/\1/')
echo "Add the following line to configuration-${target_hostname}.nix:"
echo "boot.initrd.luks.devices.crypted.device = \"/dev/disk/by-uuid/${cryptroot_uuid}\""
echo "Commit your changes somewhere persistent"

echo "Also, this script assumes that partitions and filesystems are created and mounted."
echo "when done, press enter"
read


echo "Calling nixos-generate-config"
nixos-generate-config --root /mnt


echo "Copying the generated hardware-configuration.nix to machines/${target_hostname}"
mkdir -p machines/${target_hostname}
cp -f /mnt/etc/nixos/hardware-configuration.nix machines/${target_hostname}/

echo "Make sure you import machines/${target_hostname} in configuration-${target_hostname}.nix"
echo "Make sure you commit the generated hardware-configuration.nix somewhere persistent"
echo "when done, press enter"
read

echo "Copying config and running nixos-install"
cp -r * /mnt/etc/nixos/
ln -sf configuration-${target_hostname}.nix /mnt/etc/nixos/configuration.nix
nixos-install
