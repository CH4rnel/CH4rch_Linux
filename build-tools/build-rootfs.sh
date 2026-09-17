#!/bin/bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Builds the minimal rootfs with strict package signature verification.

set -e

source "$(dirname "$0")/build.conf"

mkdir -p "$CH4RCH_ROOTFS"
mkdir -p "$CH4RCH_ROOTFS/var/lib/pacman"
mkdir -p "$CH4RCH_ROOTFS/var/cache/pacman/pkg"
mkdir -p "$CH4RCH_ROOTFS/etc/pacman.d"

cat > "$CH4RCH_ROOTFS/etc/pacman.conf" << EOF
[options]
Architecture = auto
CheckSpace
# Enforce signature verification for all repositories
SigLevel = Required DatabaseOptional
LocalFileSigLevel = Required

[$CH4RCH_REPO_NAME]
# Explicitly require signatures for CH4rch packages
SigLevel = Required
Server = file://$CH4RCH_REPO/\$arch
EOF

pacman -Sy \
    --noconfirm \
    --config "$CH4RCH_ROOTFS/etc/pacman.conf" \
    --root "$CH4RCH_ROOTFS" \
    --dbpath "$CH4RCH_ROOTFS/var/lib/pacman" \
    --cachedir "$CH4RCH_ROOTFS/var/cache/pacman/pkg" \
    bash \
    glibc \
    linux \
    pacman \
    s6 \
    s6-rc \
    s6-linux-init \
    util-linux \
    dhcpcd
    bubblewrap
    sqlite