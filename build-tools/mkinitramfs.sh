#!/usr/bin/env bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# mkinitramfs.sh
# Purpose: Generate minimal initramfs for CH4rch Linux boot process.
# Logic: Creates a cpio archive with busybox, s6-linux-init, and essential
#        utilities to mount rootfs and hand off to s6 init system.
# Fixes P0-3: Implements initramfs generation and integrates into build pipeline.

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
    for cmd in sh ash mount umount mkdir ln cp mv rm cat echo sleep; do
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

# Create init script
echo "[*] Creating init script..."
cat << 'EOF' > "$INITRAMFS_DIR/init"
#!/bin/sh

# Mount essential filesystems
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev

# Find and mount root filesystem
# Try common root devices
for root_dev in /dev/sda1 /dev/sda2 /dev/vda1 /dev/vda2; do
    if [ -b "$root_dev" ]; then
        echo "Attempting to mount root from $root_dev"
        if mount "$root_dev" /mnt/root 2>/dev/null; then
            echo "Root filesystem mounted successfully"
            break
        fi
    fi
done

# If root not mounted, drop to emergency shell
if ! mountpoint -q /mnt/root; then
    echo "ERROR: Failed to mount root filesystem"
    echo "Dropping to emergency shell"
    exec /bin/sh
fi

# Switch root to mounted filesystem
echo "Switching to real root..."
exec switch_root /mnt/root /sbin/init
EOF
chmod +x "$INITRAMFS_DIR/init"

# Create mountpoint for root
mkdir -p "$INITRAMFS_DIR/mnt/root"

# Generate cpio archive
echo "[*] Creating cpio archive..."
cd "$INITRAMFS_DIR"
find . | cpio -o -H newc 2>/dev/null | gzip > "$CH4RCH_INITRAMFS"

echo "[*] initramfs created at: $CH4RCH_INITRAMFS"
echo "[*] Size: $(du -h "$CH4RCH_INITRAMFS" | cut -f1)"