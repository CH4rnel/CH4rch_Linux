#!/bin/bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Syncs built packages to the local repository and logs the action to the hash-chain.

set -e

source "$(dirname "$0")/build.conf"

mkdir -p "$CH4RCH_REPO/$CH4RCH_ARCH"

# Copy packages and signatures
cp -f "$CH4RCH_PKGDEST"/*.pkg.tar.zst* "$CH4RCH_REPO/$CH4RCH_ARCH/" 2>/dev/null || true

cd "$CH4RCH_REPO/$CH4RCH_ARCH"

rm -f *.db.tar.zst
rm -f *.files.tar.zst

echo "[CH4RCH] Updating repository database..."
repo-add -s -v "${CH4RCH_REPO_NAME}.db.tar.zst" *.pkg.tar.zst

# Log the repository update to the hash-chain
if [ -x "$CH4RCH_SRC/build-tools/hash-chain.sh" ]; then
    PKG_COUNT=$(ls -1 *.pkg.tar.zst 2>/dev/null | wc -l)
    "$CH4RCH_SRC/build-tools/hash-chain.sh" "REPO_SYNC arch=${CH4RCH_ARCH} repo=${CH4RCH_REPO_NAME} packages=${PKG_COUNT}"
else
    echo "[CH4RCH] WARNING: hash-chain.sh not found, audit logging skipped."
fi