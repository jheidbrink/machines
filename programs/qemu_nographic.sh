#!/usr/bin/env bash

set -euo pipefail

function log() {
  echo "$@" >&2
}

image=$1;
shift && amount_memory=${1:-8G}
shift && amount_cpus=${1:-4}
log "Starting qemu with image $image"
qemu-system-x86_64 \
  -machine accel=kvm,type=q35 \
  -cpu max \
  -smp "$amount_cpus" \
  -m "$amount_memory" \
  -nographic \
  `# -nic is a shortcut for -netdev and -device I think` \
  -nic user,model=e1000,mac=00:11:22:$((RANDOM % 100)):$((RANDOM % 100)):$((RANDOM % 100)) `# IP is configured via DHCP` \
  -drive if=virtio,format=qcow2,file="$image",cache=unsafe \
  `# note that -drive is a shortcut for -device and -blockdev, understands all blockdev options plus some more.`
