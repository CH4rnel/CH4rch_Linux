#!/usr/bin/env bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭

set -e

# shellcheck disable=SC1091
source "$(dirname "$0")/build.conf"

KEYID=$(gpg --list-secret-keys --keyid-format LONG | grep sec | head -n1 | awk '{print $2}' | cut -d'/' -f2)

for pkg in "$CH4RCH_PKGDEST"/*.pkg.tar.zst; do
    [ -f "$pkg" ] || continue
    echo "[CH4RCH] Signing $(basename "$pkg")"
    gpg --batch --yes --detach-sign --default-key "$KEYID" "$pkg"
done
