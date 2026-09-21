# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
#!/usr/bin/env bash
# Test suite for build-tools/mkinitramfs.sh
# Ensures the initramfs generation script is present, executable, and contains valid logic.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
MKINITRAMFS_SCRIPT="$ROOT_DIR/build-tools/mkinitramfs.sh"

echo "Running tests for mkinitramfs.sh..."

# Test 1: Script exists and is not empty (P0-3 check)
test_script_exists() {
    if [[ ! -s "$MKINITRAMFS_SCRIPT" ]]; then
        echo "FAIL: mkinitramfs.sh is missing or empty (P0-3 violation)"
        return 1
    fi
    echo "PASS: mkinitramfs.sh exists and is not empty"
}

# Test 2: Script is executable
test_script_executable() {
    if [[ ! -x "$MKINITRAMFS_SCRIPT" ]]; then
        echo "FAIL: mkinitramfs.sh is not executable"
        return 1
    fi
    echo "PASS: mkinitramfs.sh is executable"
}

# Test 3: Script contains initramfs generation logic
test_script_logic() {
    if ! grep -qE "mkinitcpio|cpio|initramfs" "$MKINITRAMFS_SCRIPT"; then
        echo "FAIL: mkinitramfs.sh does not contain initramfs generation logic"
        return 1
    fi
    echo "PASS: mkinitramfs.sh contains generation logic"
}

# Run tests
test_script_exists
test_script_executable
test_script_logic

echo "All mkinitramfs tests passed."