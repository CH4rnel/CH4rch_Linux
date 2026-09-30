#!/usr/bin/env bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test suite build-iso.sh architectural compliance.
# Validates squashfs usage, UUID/LABEL search, no hardcoded devices, UEFI support.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_ISO_SCRIPT="$ROOT_DIR/build-tools/build-iso.sh"

echo "Running tests for P0-4 build-iso architecture..."

FAILED=0

# Test 1: No hardcoded root=/dev/sr0
test_no_hardcoded_root() {
    if grep -qE "root=/dev/sr[0-9]|root=/dev/cdrom" "$BUILD_ISO_SCRIPT"; then
        echo "FAIL: build-iso.sh contains hardcoded root=/dev/sr0"
        FAILED=1
        return 1
    fi
    echo "PASS: No hardcoded root=/dev/sr0"
}

# Test 2: Uses squashfs
test_squashfs_usage() {
    if ! grep -q "mksquashfs" "$BUILD_ISO_SCRIPT"; then
        echo "FAIL: build-iso.sh does not use mksquashfs"
        FAILED=1
        return 1
    fi
    echo "PASS: Uses mksquashfs"
}

# Test 3: GRUB uses search --file
test_grub_search_file() {
    if ! grep -q "search.*--file" "$BUILD_ISO_SCRIPT"; then
        echo "FAIL: GRUB config does not use search --file for root detection"
        FAILED=1
        return 1
    fi
    echo "PASS: GRUB uses search --file"
}

# Test 4: Uses root=LABEL or root=UUID
test_root_label_uuid() {
    if ! grep -qE "root=LABEL=|root=UUID=" "$BUILD_ISO_SCRIPT"; then
        echo "FAIL: build-iso.sh does not use root=LABEL or root=UUID"
        FAILED=1
        return 1
    fi
    echo "PASS: Uses root=LABEL or root=UUID"
}

# Test 5: Uses grub-mkrescue (not raw xorriso)
test_grub_mkrescue() {
    if ! grep -q "grub-mkrescue" "$BUILD_ISO_SCRIPT"; then
        echo "FAIL: build-iso.sh does not use grub-mkrescue"
        FAILED=1
        return 1
    fi
    echo "PASS: Uses grub-mkrescue"
}

# Test 6: No raw cp -a rootfs
test_no_raw_copy() {
    if grep -qE "cp -a.*rootfs.*iso" "$BUILD_ISO_SCRIPT"; then
        echo "FAIL: build-iso.sh uses raw cp -a instead of squashfs"
        FAILED=1
        return 1
    fi
    echo "PASS: No raw cp -a rootfs copy"
}

# Test 7: Explicit EFI modules
test_efi_modules() {
    if ! grep -qE "part_gpt|iso9660|fat" "$BUILD_ISO_SCRIPT"; then
        echo "FAIL: build-iso.sh does not specify EFI modules"
        FAILED=1
        return 1
    fi
    echo "PASS: Explicit EFI modules specified"
}

# Test 8: Logs to hash-chain
test_hash_chain_logging() {
    if ! grep -q "hash-chain.sh" "$BUILD_ISO_SCRIPT"; then
        echo "FAIL: build-iso.sh does not log to hash-chain"
        FAILED=1
        return 1
    fi
    echo "PASS: Logs to hash-chain"
}

# Run tests
test_no_hardcoded_root
test_squashfs_usage
test_grub_search_file
test_root_label_uuid
test_grub_mkrescue
test_no_raw_copy
test_efi_modules
test_hash_chain_logging

if [[ $FAILED -eq 1 ]]; then
    echo ""
    echo "Some architecture tests FAILED."
    exit 1
fi

echo "All build-iso architecture tests passed."