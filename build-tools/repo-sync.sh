#!/bin/bash
set -e

source "$(dirname "$0")/build.conf"

mkdir -p "$CH4RCH_REPO/$CH4RCH_ARCH"

cp -f "$CH4RCH_PKGDEST"/*.pkg.tar.zst* \
      "$CH4RCH_REPO/$CH4RCH_ARCH/" \
      2>/dev/null || true

cd "$CH4RCH_REPO/$CH4RCH_ARCH"

rm -f *.db.tar.zst
rm -f *.files.tar.zst

repo-add -s -v \
    ${CH4RCH_REPO_NAME}.db.tar.zst \
    *.pkg.tar.zst
