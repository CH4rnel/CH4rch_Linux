#!/bin/bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Compiles s6-rc database and generates the s6-linux-init canonical init system.

set -e
source "$(dirname "$0")/build.conf"

echo "[CH4RCH] Installing s6 service sources from overlay..."

# Ensure target directories exist in rootfs
mkdir -p "$CH4RCH_ROOTFS/etc/s6-rc/source"
mkdir -p "$CH4RCH_ROOTFS/etc/s6-rc/compiled"

# This ensures custom services (getty, network, base bundle) are present
# before compilation, supplementing or overriding any installed packages.
if [ -d "$CH4RCH_SRC/rootfs-overlay/etc/s6-rc/source" ]; then
    cp -r "$CH4RCH_SRC/rootfs-overlay/etc/s6-rc/source/." "$CH4RCH_ROOTFS/etc/s6-rc/source/"
    echo "[CH4RCH] Overlay services copied successfully."
else
    echo "[CH4RCH] WARNING: No s6-rc source overlay found at rootfs-overlay/etc/s6-rc/source"
fi

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