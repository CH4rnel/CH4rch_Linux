#!/bin/bash
set -e
source "$(dirname "$0")/build.conf"

KEYID=$(gpg --list-secret-keys --keyid-format LONG | grep sec | head -n1 | awk '{print $2}' | cut -d'/' -f2)

for pkg in "$CH4RCH_PKGDEST"/*.pkg.tar.zst; do
    [ -f "$pkg" ] || continue
    echo "[CH4RCH] Signing $(basename "$pkg")"
    gpg --batch --yes --detach-sign --default-key "$KEYID" "$pkg"
done
