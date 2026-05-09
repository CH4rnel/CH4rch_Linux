#!/bin/bash
set -e
source "$(dirname "$0")/build.conf"

echo "[CH4RCH] Installing s6 service sources..."

mkdir -p "$CH4RCH_ROOTFS/etc/s6-rc/source"
cp -r "$CH4RCH_SRC/packages/core/ch4rch-s6-init/service-source/." \
      "$CH4RCH_ROOTFS/etc/s6-rc/source/"

mkdir -p "$CH4RCH_ROOTFS/etc/s6-rc/compiled"

chroot "$CH4RCH_ROOTFS" /usr/bin/s6-rc-compile \
    /etc/s6-rc/compiled \
    /etc/s6-rc/source

mkdir -p "$CH4RCH_ROOTFS/etc/s6-linux-init"

chroot "$CH4RCH_ROOTFS" /usr/bin/s6-linux-init-maker \
    -c /etc/s6-linux-init/current \
    /run/service

ln -sf /etc/s6-linux-init/current/bin/init "$CH4RCH_ROOTFS/sbin/init"

echo "[CH4RCH] s6 canonical init generated."
