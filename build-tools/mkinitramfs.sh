#!/usr/bin/env bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# mkinitramfs.sh
# Purpose: Generate minimal initramfs for CH4rch Linux boot process.
# Logic: Creates a cpio archive with busybox, s6-linux-init, and essential
#        utilities to mount rootfs (via UUID/LABEL/squashfs) and hand off to s6 init.
# Fixes Implements initramfs generation with compliance.

set -euo pipefail

# shellcheck source=/dev/null
source "$(dirname "$0")/build.conf"

# Configuration
CH4RCH_ROOTFS="${CH4RCH_ROOTFS:-$CH4RCH_SRC/rootfs}"
CH4RCH_INITRAMFS="${CH4RCH_INITRAMFS:-$CH4RCH_ROOTFS/boot/initramfs-linux.img}"

echo "[*] Generating initramfs for CH4rch Linux..."

# Create temporary directory for initramfs structure
INITRAMFS_DIR=$(mktemp -d)
trap 'rm -rf "$INITRAMFS_DIR"' EXIT

echo "[*] Creating initramfs directory structure..."
mkdir -p "$INITRAMFS_DIR"/{bin,sbin,etc,proc,sys,dev,run}
mkdir -p "$INITRAMFS_DIR/usr/bin"

# Copy essential binaries from rootfs
echo "[*] Copying essential binaries..."
if [[ -f "$CH4RCH_ROOTFS/usr/bin/busybox" ]]; then
    cp "$CH4RCH_ROOTFS/usr/bin/busybox" "$INITRAMFS_DIR/usr/bin/"
    # Create busybox symlinks for common utilities
    for cmd in sh ash mount umount mkdir ln cp mv rm cat echo sleep blkid findfs losetup; do
        ln -sf /usr/bin/busybox "$INITRAMFS_DIR/bin/$cmd"
    done
else
    echo "[!] WARNING: busybox not found in rootfs, initramfs may be incomplete"
fi

# Copy s6-linux-init if present
if [[ -d "$CH4RCH_ROOTFS/etc/s6-linux-init" ]]; then
    cp -r "$CH4RCH_ROOTFS/etc/s6-linux-init" "$INITRAMFS_DIR/etc/"
    echo "[*] s6-linux-init configuration copied"
fi

# Create init script with ADR-01 compliance
echo "[*] Creating init script..."
cat << 'EOF' > "$INITRAMFS_DIR/init"
#!/bin/sh

# Mount essential filesystems
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev

# Parse kernel command line
CMDLINE=$(cat /proc/cmdline)

# Extract root parameter
ROOT_PARAM=""
for param in $CMDLINE; do
    case "$param" in
        root=*)
            ROOT_PARAM="${param#root=}"
            ;;
    esac
done

# Function to resolve root device
resolve_root() {
    local root_spec="$1"
    
    case "$root_spec" in
        UUID=*)
            uuid="${root_spec#UUID=}"
            echo "Resolving root by UUID: $uuid"
            blkid -U "$uuid" 2>/dev/null
            ;;
        LABEL=*)
            label="${root_spec#LABEL=}"
            echo "Resolving root by LABEL: $label"
            blkid -L "$label" 2>/dev/null
            ;;
        /dev/*)
            echo "Using direct device path: $root_spec"
            echo "$root_spec"
            ;;
        *)
            echo "Unknown root specification: $root_spec"
            return 1
            ;;
    esac
}

# Function to mount squashfs from ISO/live media
mount_squashfs() {
    local iso_device="$1"
    local squashfs_path="${2:-/ch4rch/ch4rch_rootfs.sfs}"
    
    echo "Mounting ISO device: $iso_device"
    mkdir -p /run/initramfs/live
    if ! mount -o ro "$iso_device" /run/initramfs/live; then
        echo "ERROR: Failed to mount ISO device"
        return 1
    fi
    
    echo "Mounting squashfs: $squashfs_path"
    mkdir -p /run/initramfs/squashfs
    if ! losetup -f "/run/initramfs/live$squashfs_path"; then
        echo "ERROR: Failed to setup loop device for squashfs"
        return 1
    fi
    
    local loop_dev
    loop_dev=$(losetup -j "/run/initramfs/live$squashfs_path" | cut -d: -f1)
    if ! mount -t squashfs "$loop_dev" /run/initramfs/squashfs; then
        echo "ERROR: Failed to mount squashfs"
        return 1
    fi
    
    echo "Squashfs mounted successfully"
    return 0
}

# Main root mounting logic
echo "Root parameter: ${ROOT_PARAM:-not specified}"

if [[ -z "$ROOT_PARAM" ]]; then
    echo "ERROR: No root= parameter specified in kernel command line"
    echo "Dropping to emergency shell"
    exec /bin/sh
fi

# Check if root is a squashfs path (live media boot)
if [[ "$ROOT_PARAM" == *"squashfs"* ]] || [[ "$ROOT_PARAM" == *".sfs"* ]]; then
    # Live media boot: find ISO device and mount squashfs
    echo "Detected squashfs boot, searching for ISO device..."
    
    # Try common CD-ROM devices
    for cdrom in /dev/sr0 /dev/cdrom /dev/dvd; do
        if [[ -b "$cdrom" ]]; then
            if mount_squashfs "$cdrom" "$ROOT_PARAM"; then
                echo "Switching to squashfs root..."
                exec switch_root /run/initramfs/squashfs /sbin/init
            fi
        fi
    done
    
    echo "ERROR: Failed to boot from squashfs"
    exec /bin/sh
fi

# Standard block device boot
ROOT_DEV=$(resolve_root "$ROOT_PARAM")

if [[ -z "$ROOT_DEV" ]] || [[ ! -b "$ROOT_DEV" ]]; then
    echo "ERROR: Failed to resolve root device: $ROOT_PARAM"
    echo "Dropping to emergency shell"
    exec /bin/sh
fi

echo "Mounting root filesystem from $ROOT_DEV"
mkdir -p /mnt/root
if ! mount "$ROOT_DEV" /mnt/root; then
    echo "ERROR: Failed to mount root filesystem"
    echo "Dropping to emergency shell"
    exec /bin/sh
fi

echo "Root filesystem mounted successfully"
echo "Switching to real root..."
exec switch_root /mnt/root /sbin/init
EOF
chmod +x "$INITRAMFS_DIR/init"

# Create mountpoints
mkdir -p "$INITRAMFS_DIR"/mnt/root
mkdir -p "$INITRAMFS_DIR"/run/initramfs/{live,squashfs}

# Generate cpio archive
echo "[*] Creating cpio archive..."
cd "$INITRAMFS_DIR"
find . | cpio -o -H newc 2>/dev/null | gzip > "$CH4RCH_INITRAMFS"

echo "[*] initramfs created at: $CH4RCH_INITRAMFS"
echo "[*] Size: $(du -h "$CH4RCH_INITRAMFS" | cut -f1)"