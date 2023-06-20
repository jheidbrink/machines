#!/usr/bin/env bash

# inspired by https://github.com/maxhbr/myconfig/blob/master/scripts/bootstrap.sh

set -eu

device=$1

echo "creating partitions"
parted --align optimal "$device" -- mklabel gpt
parted --align optimal "$device" -- mkpart ESP fat32 1MiB 4GiB
parted --align optimal "$device" -- mkpart primary 4GiB 100%
parted "$device" set 1 boot on
echo "Sleeping 3 seconds out of fear that device names might not be updated otherwise"
sleep 3

echo "creating fat filesystem for boot partition ${device}p1"
mkfs.fat -F 32 -n boot "${device}p1"


echo "creating ext4 filesystem, synchronizing cached writes and sleeping 5 seconds"
mkfs.ext4 "${device}p2" -L root
sync; sleep 5

echo "mounting filesystems"
mount /dev/disk/by-label/root /mnt
mkdir /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot


echo "Now you can run:"
echo "scripts/install_new_system.sh ${device}p2 <hostname>"
