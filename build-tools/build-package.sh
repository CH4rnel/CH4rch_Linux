#!/usr/bin/env bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# build-package.sh
# Purpose Build all CH4rch packages from pkgbuilds/core/
# Logic Iterates through pkgbuilds/core/*, runs makepkg, copies to PKGDEST.

set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "$0")/build.conf"

build_repo() {
    local repo_name="$1"
    local repo_dir="$CH4RCH_SRC/pkgbuilds/$repo_name"

    if [[ ! -d "$repo_dir" ]]; then
        echo "[CH4RCH] WARNING: Repository directory $repo_dir does not exist, skipping"
        return 0
    fi

    for dir in "$repo_dir"/*; do
        [[ -d "$dir" ]] || continue
        [[ -f "$dir/PKGBUILD" ]] || continue

        echo "[CH4RCH] Building $(basename "$dir")"

        cd "$dir"

        makepkg -sf --noconfirm \
            --syncdeps \
            --cleanbuild

        mv ./*.pkg.tar.zst "$CH4RCH_PKGDEST/" 2>/dev/null || true
        mv ./*.pkg.tar.zst.sig "$CH4RCH_PKGDEST/" 2>/dev/null || true
    done
}

# FIX: Only build repos that exist (core is the only one currently)
build_repo core

echo "[CH4RCH] Package build completed"