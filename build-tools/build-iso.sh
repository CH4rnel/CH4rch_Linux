#!/bin/bash
# 𒀭 𝙲𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Builds the final bootable ISO image for CH4rch Linux.

set -e

source "$(dirname "$0")/build.conf"

ISO_NAME="CH4rch-$(cat "$CH4RCH_SRC/VERSION")-x86_64.iso"
ISO_DIR="$CH4RCH_ISO/work"

mkdir -p "$CH4RCH_ISO"
rm -rf "$ISO_DIR"
mkdir -p "$ISO_DIR"

echo "[CH4RCH] Preparing ISO directory structure..."

# Copy the prepared rootfs into the ISO structure
# In a real scenario, this would be squashfs or similar, but for MVP we copy directly
cp -a "$CH4RCH_ROOTFS"/. "$ISO_DIR/"

# Ensure GRUB directory exists for grub-mkrescue
mkdir -p "$ISO_DIR/boot/grub"

# Create a minimal grub.cfg
cat > "$ISO_DIR/boot/grub/grub.cfg" << 'EOF'
set timeout=5
set default=0

menuentry "CH4rch Linux" {
    linux /boot/vmlinuz-linux root=/dev/sr0 rw init=/sbin/init
    initrd /boot/initramfs-linux.img
}
EOF

echo "[CH4RCH] Building ISO: $ISO_NAME"
grub-mkrescue -o "$CH4RCH_ISO/$ISO_NAME" "$ISO_DIR"

echo "[CH4RCH] ISO created successfully at: $CH4RCH_ISO/$ISO_NAME"

# Log to hash-chain
if [ -x "$CH4RCH_SRC/build-tools/hash-chain.sh" ]; then
    "$CH4RCH_SRC/build-tools/hash-chain.sh" "ISO_BUILD name=$ISO_NAME size=$(du -h "$CH4RCH_ISO/$ISO_NAME" | cut -f1)"
fi