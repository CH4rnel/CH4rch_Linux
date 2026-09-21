#!/usr/bin/env bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test suite for build-tools/mkinitramfs.sh
# Validates P0-3 fix: initramfs generation and integration into build pipeline.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
MKINITRAMFS_SCRIPT="$ROOT_DIR/build-tools/mkinitramfs.sh"
BUILD_ALL_SCRIPT="$ROOT_DIR/build-tools/build-all.sh"

echo "Running tests for mkinitramfs.sh..."

# Test 1: Shebang and decorative comment (SC1128 compliance)
test_shebang_and_header() {
    if [[ ! -f "$MKINITRAMFS_SCRIPT" ]]; then
        echo "FAIL: mkinitramfs.sh does not exist"
        return 1
    fi
    
    local first_line
    first_line=$(head -n 1 "$MKINITRAMFS_SCRIPT")
    if [[ "$first_line" != "#!/usr/bin/env bash" && "$first_line" != "#!/bin/bash" ]]; then
        echo "FAIL: First line must be a valid shebang (#!/usr/bin/env bash or #!/bin/bash)"
        echo "Found: $first_line"
        return 1
    fi
    
    local second_line
    second_line=$(sed -n '2p' "$MKINITRAMFS_SCRIPT")
    if [[ "$second_line" != "# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭" ]]; then
        echo "FAIL: Second line must be the decorative comment '# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭'"
        echo "Found: $second_line"
        return 1
    fi
    
    echo "PASS: Shebang and decorative header present"
}

# Test 2: Shellcheck compliance
test_syntax() {
    if ! command -v shellcheck &> /dev/null; then
        echo "FAIL: shellcheck is not installed."
        return 1
    fi
    if ! shellcheck -x "$MKINITRAMFS_SCRIPT"; then
        echo "FAIL: shellcheck found issues in mkinitramfs.sh"
        return 1
    fi
    echo "PASS: Syntax check (shellcheck)"
}

# Test 3: Script creates initramfs file
test_initramfs_creation() {
    local test_rootfs="$SCRIPT_DIR/test_rootfs_$$"
    local test_output="$SCRIPT_DIR/test_initramfs_$$"
    
    mkdir -p "$test_rootfs/boot"
    mkdir -p "$test_rootfs/usr/bin"
    mkdir -p "$test_rootfs/etc/s6-linux-init"
    
    # Mock minimal required files
    touch "$test_rootfs/usr/bin/busybox"
    touch "$test_rootfs/usr/bin/s6-linux-init"
    
    # Run mkinitramfs with test paths
    if ! CH4RCH_ROOTFS="$test_rootfs" CH4RCH_INITRAMFS="$test_output" "$MKINITRAMFS_SCRIPT"; then
        echo "FAIL: mkinitramfs.sh exited with error"
        rm -rf "$test_rootfs" "$test_output"
        return 1
    fi
    
    if [[ ! -f "$test_output" ]]; then
        echo "FAIL: initramfs file was not created at $test_output"
        rm -rf "$test_rootfs"
        return 1
    fi
    
    # Verify it's a valid cpio archive (gzip compressed)
    if ! file "$test_output" | grep -q "gzip compressed data"; then
        echo "FAIL: Created file is not a valid gzip-compressed initramfs"
        rm -rf "$test_rootfs" "$test_output"
        return 1
    fi
    
    rm -rf "$test_rootfs" "$test_output"
    echo "PASS: initramfs file created successfully"
}

# Test 4: Integration - mkinitramfs is called from build-all.sh
test_build_all_integration() {
    if ! grep -q "mkinitramfs" "$BUILD_ALL_SCRIPT"; then
        echo "FAIL: build-all.sh does not call mkinitramfs.sh"
        return 1
    fi
    
    # Verify it's called in the correct order (after bootstrap-init, before build-iso)
    local bootstrap_line build_iso_line mkinitramfs_line
    bootstrap_line=$(grep -n "bootstrap-init" "$BUILD_ALL_SCRIPT" | head -1 | cut -d: -f1)
    build_iso_line=$(grep -n "build-iso" "$BUILD_ALL_SCRIPT" | head -1 | cut -d: -f1)
    mkinitramfs_line=$(grep -n "mkinitramfs" "$BUILD_ALL_SCRIPT" | head -1 | cut -d: -f1)
    
    if [[ -z "$bootstrap_line" || -z "$build_iso_line" || -z "$mkinitramfs_line" ]]; then
        echo "FAIL: Could not find all required scripts in build-all.sh"
        return 1
    fi
    
    if ! (( bootstrap_line < mkinitramfs_line && mkinitramfs_line < build_iso_line )); then
        echo "FAIL: mkinitramfs is not called in correct order (should be between bootstrap-init and build-iso)"
        echo "bootstrap-init: line $bootstrap_line"
        echo "mkinitramfs: line $mkinitramfs_line"
        echo "build-iso: line $build_iso_line"
        return 1
    fi
    
    echo "PASS: mkinitramfs integrated into build-all.sh"
}

# Run tests
test_shebang_and_header
test_syntax
test_initramfs_creation
test_build_all_integration

echo "All mkinitramfs.sh tests passed."