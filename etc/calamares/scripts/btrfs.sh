#!/bin/bash

# Made by TotallyDIO contact at totallydio@proton.me

set -euo pipefail

# Standard Calamares target root mount point (change only if your config uses a different path)
ROOT_MOUNT="/mnt"

log() {
    echo "[btrfs] $*"
}

error() {
    echo "[btrfs-boot-symlink] ERROR: $*" >&2
    exit 1
}

# 1. Verify if in valid place
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

# 3. Find the btrfs device
DEVICE=$(findmnt -no SOURCE "$ROOT_MOUNT")
if [[ -z "$DEVICE" ]]; then
    error "Could not determine Btrfs device for $ROOT_MOUNT"
fi

# 4. find the subvolume name or id
ROOT_FSTAB_ENTRY=$(grep -E '^\s*[^#].*\s+/\s+btrfs' "$ROOT_MOUNT/etc/fstab" 2>/dev/null | head -n1 || true)
SUBVOL=$(printf '%s\n' "$ROOT_FSTAB_ENTRY" | grep -o 'subvol=[^,[:space:]]*' | cut -d'=' -f2 | head -n1 || echo "")
SUBVOLID=$(printf '%s\n' "$ROOT_FSTAB_ENTRY" | grep -o 'subvolid=[^,[:space:]]*' | cut -d'=' -f2 | head -n1 || echo "")

if [[ -z "$SUBVOL" && -n "$SUBVOLID" ]]; then
    if [[ "$SUBVOLID" == "5" ]]; then
        log "Root is top-level subvolume (subvolid=5) – no boot symlink needed"
        exit 0
    fi
    SUBVOL=$(btrfs subvolume list -o "$ROOT_MOUNT" 2>/dev/null | awk -v id="$SUBVOLID" '$2==id {for (i=1; i<=NF; i++) if ($i == "path") {for (j=i+1; j<=NF; j++) printf "%s%s", $j, (j==NF?"":" "); print ""; exit}}')
    if [[ -z "$SUBVOL" ]]; then
        error "Could not resolve subvolume path for subvolid=$SUBVOLID"
    fi
fi

if [[ -z "$SUBVOL" ]]; then
    log "No subvol= or subvolid= option found in fstab – assuming plain Btrfs (no symlink needed)"
    exit 0
fi

log "Detected Btrfs device: $DEVICE"
log "Detected root subvolume name (volume name): $SUBVOL"

# 5. mount and make sym link
TEMP_MOUNT="/tmp/btrfs_top_$$"
mkdir -p "$TEMP_MOUNT"

cleanup() {
    if mountpoint -q "$TEMP_MOUNT" 2>/dev/null; then
        umount "$TEMP_MOUNT" || true
    fi
    [[ -d "$TEMP_MOUNT" ]] && rmdir "$TEMP_MOUNT" || true
}
trap cleanup EXIT

if ! mount -o ro,subvolid=5 "$DEVICE" "$TEMP_MOUNT"; then
    error "Failed to mount top-level Btrfs subvolume"
fi

# 6. Create the symbolic link for the boot directory
BOOT_PATH="$TEMP_MOUNT/boot"
if [[ -L "$BOOT_PATH" ]]; then
    CURRENT_TARGET=$(readlink "$BOOT_PATH")
    if [[ "$CURRENT_TARGET" == "$SUBVOL/boot" ]]; then
        log "Correct /boot symlink already exists in top-level subvolume"
    else
        log "Replacing existing /boot symlink in top-level subvolume"
        rm "$BOOT_PATH"
        ln -s "$SUBVOL/boot" "$BOOT_PATH"
        log "Updated symbolic link: /boot → $SUBVOL/boot"
    fi
elif [[ -e "$BOOT_PATH" ]]; then
    error "Top-level /boot exists and is not a symlink; cannot safely create the Btrfs boot symlink"
else
    ln -s "$SUBVOL/boot" "$BOOT_PATH"
    log "Created symbolic link: /boot → $SUBVOL/boot  (in top-level subvolume)"
fi

# 7. Cleaning up
umount "$TEMP_MOUNT"
rmdir "$TEMP_MOUNT"

log "Btrfs boot symlink setup completed successfully (volume name: $SUBVOL)"
exit 0