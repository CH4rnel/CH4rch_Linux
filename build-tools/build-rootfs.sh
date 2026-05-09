#!/bin/bash
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
SigLevel = Optional TrustAll
LocalFileSigLevel = Optional

[$CH4RCH_REPO_NAME]
Server = file://$CH4RCH_REPO/\$arch
EOF

pacman -Sy \
    --noconfirm \
    --config "$CH4RCH_ROOTFS/etc/pacman.conf" \
    --root "$CH4RCH_ROOTFS" \
    --dbpath "$CH4RCH_ROOTFS/var/lib/pacman" \
    --cachedir "$CH4RCH_ROOTFS/var/cache/pacman/pkg" \
    ch4rch-base-files \
    ch4rch-s6-init \
    bash \
    glibc \
    linux \
    pacman \
    s6 \
    s6-rc \
    s6-linux-init \
    util-linux
