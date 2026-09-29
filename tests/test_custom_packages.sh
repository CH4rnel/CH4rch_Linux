#!/usr/bin/env bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test suite for custom CH4rch packages installation.
# Validates: ch4rch-base-files and ch4rch-s6-init are included in build-rootfs.sh.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_ROOTFS_SCRIPT="$ROOT_DIR/build-tools/build-rootfs.sh"

echo "Running tests for custom packages installation..."

# Test 1: Verify ch4rch-base-files is installed
test_base_files_installed() {
    if ! grep -q "ch4rch-base-files" "$BUILD_ROOTFS_SCRIPT"; then
        echo "FAIL: ch4rch-base-files is not installed in build-rootfs.sh"
        return 1
    fi
    echo "PASS: ch4rch-base-files is installed"
}

# Test 2: Verify ch4rch-s6-init is installed
test_s6_init_installed() {
    if ! grep -q "ch4rch-s6-init" "$BUILD_ROOTFS_SCRIPT"; then
        echo "FAIL: ch4rch-s6-init is not installed in build-rootfs.sh"
        return 1
    fi
    echo "PASS: ch4rch-s6-init is installed"
}

# Test 3: Verify local repository is configured
test_local_repo_configured() {
    if ! grep -q "ch4rch-core" "$BUILD_ROOTFS_SCRIPT"; then
        echo "FAIL: local ch4rch-core repository is not configured in build-rootfs.sh"
        return 1
    fi
    echo "PASS: local repository is configured"
}

# Run tests
test_base_files_installed
test_s6_init_installed
test_local_repo_configured

echo "All custom packages tests passed."