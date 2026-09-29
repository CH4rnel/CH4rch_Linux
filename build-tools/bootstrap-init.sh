#!/usr/bin/env bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Compiles s6-rc database and generates the s6-linux-init canonical init system.

set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "$0")/build.conf"

# Ensure target directories exist in rootfs
mkdir -p "$CH4RCH_ROOTFS/etc/s6-rc/source"
mkdir -p "$CH4RCH_ROOTFS/etc/s6-rc/compiled"

# Copy s6-rc services from single source of truth
if [ -d "$CH4RCH_SRC/s6-services/source" ]; then
    cp -r "$CH4RCH_SRC/s6-services/source/." "$CH4RCH_ROOTFS/etc/s6-rc/source/"
    echo "[CH4RCH] s6-services copied successfully from s6-services/source/"
else
    echo "[CH4RCH] ERROR: s6-services/source not found" >&2
    exit 1
fi

echo "[CH4RCH] Compiling s6-rc database..."
arch-chroot "$CH4RCH_ROOTFS" /usr/bin/s6-rc-compile \
    /etc/s6-rc/compiled \
    /etc/s6-rc/source

mkdir -p "$CH4RCH_ROOTFS/etc/s6-linux-init"

echo "[CH4RCH] s6-linux-init compilation completed"