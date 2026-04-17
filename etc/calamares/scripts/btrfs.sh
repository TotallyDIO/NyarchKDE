#!/bin/bash

# Made by TotallyDIO contact at totallydio@proton.me

set -euo pipefail

# Standard Calamares target root mount point (change only if your config uses a different path)
ROOT_MOUNT="/mnt"

log() {
    echo "[btrfs-boot-symlink] $*"
}

error() {
    echo "[btrfs-boot-symlink] ERROR: $*" >&2
    exit 1
}

# 1. Verify we are in a valid install environment
if ! mountpoint -q "$ROOT_MOUNT"; then
    log "No root mountpoint at $ROOT_MOUNT – skipping (not in install phase)"
    exit 0
fi

# 2. Confirm it is actually Btrfs
FS_TYPE=$(findmnt -no FSTYPE "$ROOT_MOUNT" 2>/dev/null || echo "")
if [[ "$FS_TYPE" != "btrfs" ]]; then
    log "Root filesystem is not Btrfs (type: $FS_TYPE) – skipping"
    exit 0
fi

# 3. Get the underlying Btrfs device
DEVICE=$(findmnt -no SOURCE "$ROOT_MOUNT")
if [[ -z "$DEVICE" ]]; then
    error "Could not determine Btrfs device for $ROOT_MOUNT"
fi

# 4. Dynamically read the subvolume name (volume name) from fstab
#    Example line: UUID=... / btrfs subvol=@,compress=zstd:3 0 1
SUBVOL=$(grep -E '^\s*[^#].*\s+/\s+btrfs' "$ROOT_MOUNT/etc/fstab" 2>/dev/null \
         | grep -o 'subvol=[^,[:space:]]*' \
         | cut -d'=' -f2 \
         | head -n1 || echo "")

if [[ -z "$SUBVOL" ]]; then
    log "No subvol= option found in fstab – assuming plain Btrfs (no symlink needed)"
    exit 0
fi

log "Detected Btrfs device: $DEVICE"
log "Detected root subvolume name (volume name): $SUBVOL"

# 5. Prepare temporary mount for top-level subvolume (ID 5 is always the root of the filesystem)
TEMP_MOUNT="/tmp/btrfs_top_$$"
mkdir -p "$TEMP_MOUNT"

if ! mount -o subvolid=5 "$DEVICE" "$TEMP_MOUNT"; then
    error "Failed to mount top-level Btrfs subvolume"
fi

# 6. Create the symbolic link for the boot directory (only if it doesn't already exist)
if [[ -e "$TEMP_MOUNT/boot" ]]; then
    log "boot entry already exists in top-level subvolume – skipping symlink creation"
else
    ln -s "$SUBVOL/boot" "$TEMP_MOUNT/boot"
    log "Created symbolic link: /boot → $SUBVOL/boot  (in top-level subvolume)"
fi

# 7. Clean up
umount "$TEMP_MOUNT"
rmdir "$TEMP_MOUNT"

log "Btrfs boot symlink setup completed successfully (volume name: $SUBVOL)"
exit 0