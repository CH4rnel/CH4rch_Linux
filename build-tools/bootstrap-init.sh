#!/bin/bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Compiles s6-rc database and generates the s6-linux-init canonical init system.

set -e
source "$(dirname "$0")/build.conf"

echo "[CH4RCH] Installing s6 service sources..."

# Ensure source directory exists in rootfs
mkdir -p "$CH4RCH_ROOTFS/etc/s6-rc/source"

if [ -d "$CH4RCH_SRC/packages/core/ch4rch-s6-init/service-source" ]; then
    cp -r "$CH4RCH_SRC/packages/core/ch4rch-s6-init/service-source/." \
          "$CH4RCH_ROOTFS/etc/s6-rc/source/"
fi

mkdir -p "$CH4RCH_ROOTFS/etc/s6-rc/compiled"

echo "[CH4RCH] Compiling s6-rc database..."
arch-chroot "$CH4RCH_ROOTFS" /usr/bin/s6-rc-compile \
    /etc/s6-rc/compiled \
    /etc/s6-rc/source

mkdir -p "$CH4RCH_ROOTFS/etc/s6-linux-init"

echo "[CH4RCH] Generating s6-linux-init canonical init..."
arch-chroot "$CH4RCH_ROOTFS" /usr/bin/s6-linux-init-maker \
    -c /etc/s6-linux-init/current \
    /run/service

ln -sf /etc/s6-linux-init/current/bin/init "$CH4RCH_ROOTFS/sbin/init"

echo "[CH4RCH] s6 canonical init generated successfully."