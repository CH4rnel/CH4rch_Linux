#!/usr/bin/env bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test suite for build-tools/build-iso.sh
# Validates fix: squashfs, UUID-based root search, and proper EFI configuration.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_ISO_SCRIPT="$ROOT_DIR/build-tools/build-iso.sh"

echo "Running tests for build-iso.sh..."

test_shebang_and_header() {
    if [[ ! -f "$BUILD_ISO_SCRIPT" ]]; then
        echo "FAIL: build-iso.sh does not exist"
        return 1
    fi
    
    local first_line
    first_line=$(head -n 1 "$BUILD_ISO_SCRIPT")
    if [[ "$first_line" != "#!/usr/bin/env bash" && "$first_line" != "#!/bin/bash" ]]; then
        echo "FAIL: First line must be a valid shebang"
        echo "Found: $first_line"
        return 1
    fi
    
    local second_line
    second_line=$(sed -n '2p' "$BUILD_ISO_SCRIPT")
    if [[ "$second_line" != "# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭" ]]; then
        echo "FAIL: Second line must be the decorative comment"
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
    if ! shellcheck -x "$BUILD_ISO_SCRIPT"; then
        echo "FAIL: shellcheck found issues in build-iso.sh"
        return 1
    fi
    echo "PASS: Syntax check (shellcheck)"
}

# Test 3: Verify squashfs usage (no raw cp -a)
test_squashfs_usage() {
    if grep -q "cp -a.*rootfs.*iso_dir" "$BUILD_ISO_SCRIPT"; then
        echo "FAIL: build-iso.sh uses raw 'cp -a' instead of squashfs (P0-4 violation)"
        return 1
    fi
    
    if ! grep -q "mksquashfs" "$BUILD_ISO_SCRIPT"; then
        echo "FAIL: build-iso.sh does not use mksquashfs (P0-4 violation)"
        return 1
    fi
    
    echo "PASS: squashfs usage verified"
}

# Test 4: Verify UUID-based root search (no hardcoded /dev/sr0)
test_uuid_based_root() {
    if grep -q "root=/dev/sr0" "$BUILD_ISO_SCRIPT"; then
        echo "FAIL: build-iso.sh hardcodes 'root=/dev/sr0' (P0-4 violation, breaks USB boot)"
        return 1
    fi
    
    # Check for UUID or LABEL based search (archiso-style)
    if ! grep -qE "(UUID=|LABEL=|archisosearch|cow_spacefs)" "$BUILD_ISO_SCRIPT"; then
        echo "FAIL: build-iso.sh does not implement UUID/LABEL-based root search"
        return 1
    fi
    
    echo "PASS: UUID-based root search verified"
}

# Test 5: Verify EFI configuration
test_efi_configuration() {
    if ! grep -qE "(grub-mkrescue.*--modules|efiboot|efi\.img)" "$BUILD_ISO_SCRIPT"; then
        echo "FAIL: build-iso.sh does not properly configure EFI modules"
        return 1
    fi
    
    echo "PASS: EFI configuration verified"
}

# Test 6: Verify initramfs integration
test_initramfs_integration() {
    if ! grep -q "initramfs" "$BUILD_ISO_SCRIPT"; then
        echo "FAIL: build-iso.sh does not reference initramfs"
        return 1
    fi
    
    # Verify grub.cfg includes initrd line
    if ! grep -q "initrd.*initramfs" "$BUILD_ISO_SCRIPT"; then
        echo "FAIL: build-iso.sh does not include initrd in grub.cfg"
        return 1
    fi
    
    echo "PASS: initramfs integration verified"
}

# Run tests
test_shebang_and_header
test_syntax
test_squashfs_usage
test_uuid_based_root
test_efi_configuration
test_initramfs_integration

echo "All build-iso.sh tests passed."