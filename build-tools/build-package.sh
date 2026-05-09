#!/bin/bash
set -e

source "$(dirname "$0")/build.conf"

build_repo() {
    REPO_NAME=$1

    for dir in "$CH4RCH_SRC/pkgbuilds/$REPO_NAME"/*; do

        [ -d "$dir" ] || continue
        [ -f "$dir/PKGBUILD" ] || continue

        echo "[CH4RCH] Building $(basename "$dir")"

        cd "$dir"

        makepkg -sf --noconfirm \
            --syncdeps \
            --cleanbuild

        mv *.pkg.tar.zst "$CH4RCH_PKGDEST/" 2>/dev/null || true
        mv *.pkg.tar.zst.sig "$CH4RCH_PKGDEST/" 2>/dev/null || true
    done
}

build_repo core
build_repo extra
build_repo community
