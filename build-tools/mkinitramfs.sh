# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
#!/usr/bin/env bash
# mkinitramfs.sh
# Purpose: Generate the initial ramdisk (initramfs) for the CH4rch Linux kernel.
# Logic: Uses mkinitcpio within the chroot environment to ensure all dependencies 
#        (like s6-linux-init, eudev) are correctly resolved and bundled.

set -euo pipefail

# Configuration
CH4RCH_ROOTFS="${CH4RCH_ROOTFS:-$PWD/rootfs}"
KERNEL_VERSION="${KERNEL_VERSION:-linux}"
INITRAMFS_NAME="initramfs-linux.img"

echo "[*] Generating initramfs for $KERNEL_VERSION in $CH4RCH_ROOTFS"

# Ensure /boot directory exists in the target rootfs
mkdir -p "$CH4RCH_ROOTFS/boot"

# Ensure mkinitcpio is available in the rootfs (usually pulled by 'linux' dependency)
if ! arch-chroot "$CH4RCH_ROOTFS" pacman -Q mkinitcpio &> /dev/null; then
    echo "[*] mkinitcpio not found in rootfs. Installing..."
    arch-chroot "$CH4RCH_ROOTFS" pacman -Sy --noconfirm mkinitcpio
fi

echo "[*] Running mkinitcpio..."
# -r: alternate root directory
# -k: kernel preset/name
# -g: output image path (relative to the alternate root)
arch-chroot "$CH4RCH_ROOTFS" mkinitcpio -k "$KERNEL_VERSION" -g "/boot/$INITRAMFS_NAME"

# Verify the output was created
if [[ ! -f "$CH4RCH_ROOTFS/boot/$INITRAMFS_NAME" ]]; then
    echo "FAIL: $INITRAMFS_NAME was not generated in $CH4RCH_ROOTFS/boot/"
    exit 1
fi

echo "[*] Initramfs generation completed successfully: $CH4RCH_ROOTFS/boot/$INITRAMFS_NAME"