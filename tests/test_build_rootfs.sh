#!/usr/bin/env bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test suite for build-tools/build-rootfs.sh
# Ensures pacman configuration is valid, syntax is correct, and core packages are included.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_SCRIPT="$ROOT_DIR/build-tools/build-rootfs.sh"

echo "Running tests for build-rootfs.sh..."

# Test 1: Syntax check via shellcheck (MANDATORY)
test_syntax() {
    if ! command -v shellcheck &> /dev/null; then
        echo "FAIL: shellcheck is not installed."
        return 1
    fi
    if ! shellcheck -x "$BUILD_SCRIPT"; then
        echo "FAIL: shellcheck found issues in build-rootfs.sh"
        return 1
    fi
    echo "PASS: Syntax check (shellcheck)"
}

# Test 2: Verify pacman.conf generation includes upstream repos (P0-2)
test_pacman_conf_upstream() {
    if ! grep -q "Server = https://geo.mirror.pkgbuild.com/\$repo/os/\$arch" "$BUILD_SCRIPT" && \
       ! grep -q "Server = http://mirror.rackspace.com/archlinux/\$repo/os/\$arch" "$BUILD_SCRIPT"; then
        echo "FAIL: build-rootfs.sh does not configure upstream Arch Linux repositories."
        return 1
    fi
    echo "PASS: Upstream repositories configuration present"
}

# Test 3: Verify CH4rch custom packages are installed (P1-1)
test_ch4rch_packages_included() {
    if ! grep -q "ch4rch-base-files" "$BUILD_SCRIPT"; then
        echo "FAIL: ch4rch-base-files is missing from the installation list (P1-1 violation)."
        return 1
    fi
    if ! grep -q "ch4rch-s6-init" "$BUILD_SCRIPT"; then
        echo "FAIL: ch4rch-s6-init is missing from the installation list (P1-1 violation)."
        return 1
    fi
    echo "PASS: CH4rch custom packages are included in installation"
}

# Run tests
test_syntax
test_pacman_conf_upstream
test_ch4rch_packages_included

echo "All build-rootfs tests passed."