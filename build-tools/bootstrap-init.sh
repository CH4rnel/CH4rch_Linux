#!/usr/bin/env bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Compiles s6-rc database and generates the s6-linux-init canonical init system.
# Fixes Uses rootfs-overlay as single source of truth, calls s6-linux-init-maker.

set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "$0")/build.conf"

# Ensure target directories exist in rootfs
mkdir -p "$CH4RCH_ROOTFS/etc/s6-rc/source"
mkdir -p "$CH4RCH_ROOTFS/etc/s6-rc/compiled"

# FIX: Copy s6-rc services from single source of truth (rootfs-overlay)
if [ -d "$CH4RCH_SRC/rootfs-overlay/etc/s6-rc/source" ]; then
    cp -r "$CH4RCH_SRC/rootfs-overlay/etc/s6-rc/source/." "$CH4RCH_ROOTFS/etc/s6-rc/source/"
    echo "[CH4RCH] s6-rc services copied from rootfs-overlay/etc/s6-rc/source/"
else
    echo "[CH4RCH] ERROR: rootfs-overlay/etc/s6-rc/source not found" >&2
    exit 1
fi

echo "[CH4RCH] Compiling s6-rc database..."
arch-chroot "$CH4RCH_ROOTFS" /usr/bin/s6-rc-compile \
    /etc/s6-rc/compiled \
    /etc/s6-rc/source

echo "[CH4RCH] s6-rc database compiled successfully"

# Generate s6-linux-init canonical init system
echo "[CH4RCH] Generating s6-linux-init canonical init..."
arch-chroot "$CH4RCH_ROOTFS" /usr/bin/s6-linux-init-maker \
    -1 \
    -c /etc/s6-linux-init \
    /etc/s6-linux-init

# Create /sbin/init symlink to s6-linux-init rc.init
if [ ! -e "$CH4RCH_ROOTFS/sbin/init" ]; then
    ln -sf /etc/s6-linux-init/scripts/rc.init "$CH4RCH_ROOTFS/sbin/init"
    echo "[CH4RCH] Created /sbin/init -> /etc/s6-linux-init/scripts/rc.init"
fi

echo "[CH4RCH] s6-linux-init compilation completed"