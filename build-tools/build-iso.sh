#!/usr/bin/env bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# build-iso.sh
# Purpose: Build the final bootable ISO image for CH4rch Linux.
# Logic: Uses squashfs for rootfs compression, UUID/LABEL-based root search 
#        in GRUB, and explicit EFI/UEFI configuration.

set -euo pipefail

# Load configuration if available
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/build.conf" ]; then
    # shellcheck disable=SC1091
    source "$SCRIPT_DIR/build.conf"
fi

# Configuration with defaults
CH4RCH_SRC="${CH4RCH_SRC:-$(dirname "$SCRIPT_DIR")}"
CH4RCH_ROOTFS="${CH4RCH_ROOTFS:-$CH4RCH_SRC/rootfs}"
CH4RCH_ISO="${CH4RCH_ISO:-$CH4RCH_SRC/iso}"
ISO_NAME="CH4rch-$(cat "$CH4RCH_SRC/VERSION")-x86_64.iso"
ISO_DIR="$CH4RCH_ISO/work"
ISO_LABEL="CH4RCH_ISO"

echo "[*] Preparing ISO directory structure at $ISO_DIR"
mkdir -p "$CH4RCH_ISO"
rm -rf "$ISO_DIR"
mkdir -p "$ISO_DIR/boot/grub"
mkdir -p "$ISO_DIR/ch4rch"

echo "[*] Copying kernel and initramfs to ISO boot directory"
cp "$CH4RCH_ROOTFS/boot/vmlinuz-linux" "$ISO_DIR/boot/"
cp "$CH4RCH_ROOTFS/boot/initramfs-linux.img" "$ISO_DIR/boot/"

echo "[*] Creating squashfs image of rootfs"
mksquashfs "$CH4RCH_ROOTFS" "$ISO_DIR/ch4rch/ch4rch_rootfs.sfs" \
    -comp xz -noappend -no-recovery

echo "[*] Generating GRUB configuration with UUID/LABEL search"
cat > "$ISO_DIR/boot/grub/grub.cfg" << EOF
set timeout=5
set default=0

menuentry "CH4rch Linux" {
    search --no-floppy --file --set=root /ch4rch/ch4rch_rootfs.sfs
    linux /boot/vmlinuz-linux root=LABEL=$ISO_LABEL rw init=/sbin/init
    initrd /boot/initramfs-linux.img
}
EOF

echo "[*] Building ISO: $ISO_NAME"
# Explicitly include modules for EFI/UEFI boot
grub-mkrescue -o "$CH4RCH_ISO/$ISO_NAME" "$ISO_DIR" --modules=part_gpt,part_msdos,fat,iso9660,search,configfile,normal,chain -- -volid "$ISO_LABEL" # EFI/UEFI support

echo "[*] ISO created successfully at: $CH4RCH_ISO/$ISO_NAME"

# Log to hash-chain
if [ -x "$CH4RCH_SRC/build-tools/hash-chain.sh" ]; then
    "$CH4RCH_SRC/build-tools/hash-chain.sh" "ISO_BUILD name=$ISO_NAME size=$(du -h "$CH4RCH_ISO/$ISO_NAME" | cut -f1)"
fi