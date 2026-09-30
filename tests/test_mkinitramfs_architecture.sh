#!/usr/bin/env bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test suite mkinitramfs.sh architectural compliance.
# Validates UUID/LABEL support, squashfs mounting, kernel parameter parsing.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
MKINITRAMFS_SCRIPT="$ROOT_DIR/build-tools/mkinitramfs.sh"

echo "Running tests for P0-3 mkinitramfs architecture..."

FAILED=0

# Test 1: No hardcoded device paths
test_no_hardcoded_devices() {
    if grep -qE "/dev/sd[a-z][0-9]|/dev/vd[a-z][0-9]" "$MKINITRAMFS_SCRIPT"; then
        echo "FAIL: mkinitramfs.sh contains hardcoded device paths (violates ADR-01)"
        FAILED=1
        return 1
    fi
    echo "PASS: No hardcoded device paths"
}

# Test 2: Init script reads kernel parameters
test_kernel_params() {
    if ! grep -q "/proc/cmdline" "$MKINITRAMFS_SCRIPT"; then
        echo "FAIL: init script does not read /proc/cmdline"
        FAILED=1
        return 1
    fi
    echo "PASS: Init script reads kernel parameters"
}

# Test 3: UUID/LABEL support
test_uuid_label_support() {
    if ! grep -qE "UUID=|LABEL=" "$MKINITRAMFS_SCRIPT"; then
        echo "FAIL: mkinitramfs.sh does not support UUID= or LABEL= root specification"
        FAILED=1
        return 1
    fi
    echo "PASS: UUID/LABEL support present"
}

# Test 4: Squashfs support
test_squashfs_support() {
    if ! grep -qE "squashfs|loop" "$MKINITRAMFS_SCRIPT"; then
        echo "FAIL: mkinitramfs.sh does not support squashfs mounting"
        FAILED=1
        return 1
    fi
    echo "PASS: Squashfs support present"
}

# Test 5: blkid or findfs usage for device resolution
test_device_resolution() {
    if ! grep -qE "blkid|findfs|findfs" "$MKINITRAMFS_SCRIPT"; then
        echo "FAIL: mkinitramfs.sh does not use blkid/findfs for device resolution"
        FAILED=1
        return 1
    fi
    echo "PASS: Device resolution tools present"
}

# Test 6: Emergency shell fallback
test_emergency_shell() {
    if ! grep -qE "exec.*sh|emergency|rescue" "$MKINITRAMFS_SCRIPT"; then
        echo "FAIL: mkinitramfs.sh does not provide emergency shell fallback"
        FAILED=1
        return 1
    fi
    echo "PASS: Emergency shell fallback present"
}

# Run tests
test_no_hardcoded_devices
test_kernel_params
test_uuid_label_support
test_squashfs_support
test_device_resolution
test_emergency_shell

if [[ $FAILED -eq 1 ]]; then
    echo ""
    echo "Some P0-3 architecture tests FAILED."
    exit 1
fi

echo "All P0-3 mkinitramfs architecture tests passed."