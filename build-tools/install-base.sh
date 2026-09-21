#!/usr/bin/env bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭

set -e

# shellcheck disable=SC1091
source "$(dirname "$0")/build.conf"

mkdir -p "$CH4RCH_ROOTFS"

pacman -Sy \
    --noconfirm \
    --root "$CH4RCH_ROOTFS" \
    --dbpath "$CH4RCH_ROOTFS/var/lib/pacman" \
    --cachedir "$CH4RCH_ROOTFS/var/cache/pacman/pkg" \
    bash \
    glibc \
    linux \
    pacman \
    s6 \
    s6-rc \
    s6-linux-init
