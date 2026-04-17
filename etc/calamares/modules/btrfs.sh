#!/bin/bash

# Detect root device
ROOT_DEVICE=$(findmnt -n -o SOURCE /)
FSTYPE=$(findmnt -n -o FSTYPE /)

echo "Root device: $ROOT_DEVICE"
echo "Filesystem: $FSTYPE"
# 67
if [[ "$FSTYPE" != "btrfs" ]]; then
    echo "Not a btrfs system"
    exit 1
fi

# Detect current subvolume
SUBVOL=$(findmnt -n -o OPTIONS / | grep -o 'subvol=[^,]*' | cut -d= -f2)
echo "Current subvolume: $SUBVOL"

# Mount top-level
TOP_MOUNT="/mnt/btrfs-top"
mkdir -p "$TOP_MOUNT"

mount -o subvolid=5 "$ROOT_DEVICE" "$TOP_MOUNT"

echo "Available subvolumes:"
btrfs subvolume list "$TOP_MOUNT"

# Ex: detect @boot
BOOT_SUBVOL=$(btrfs subvolume list "$TOP_MOUNT" | awk '{print $NF}' | grep '^@boot$')

if [[ -n "$BOOT_SUBVOL" ]]; then
    echo "Found boot subvolume: $BOOT_SUBVOL"
else
    echo "No @boot subvolume found"
fi