#!/usr/bin/env bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭

set -e

# shellcheck disable=SC1091
source "$(dirname "$0")/build.conf"

mkdir -p "$CH4RCH_ROOTFS"

echo "[CH4RCH] Bootstrap environment ready:"
echo "ROOTFS=$CH4RCH_ROOTFS"
