#!/bin/bash
set -e

source "$(dirname "$0")/build.conf"

mkdir -p "$CH4RCH_ROOTFS"

echo "[CH4RCH] Bootstrap environment ready:"
echo "ROOTFS=$CH4RCH_ROOTFS"
