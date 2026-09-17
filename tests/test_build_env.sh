#!/bin/bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test: Verify build environment prerequisites and directory structure.
# Compatible with both Arch Linux (local) and Ubuntu (GitHub Actions CI).

set -e

echo "Running build environment tests..."

# Test 1: Check generic required host tools (available on Ubuntu CI and Arch)
echo "[TEST] Checking generic build tools..."
for cmd in git make bash; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "FAIL: Required generic command '$cmd' is not installed."
        exit 1
    fi
done
echo "PASS: All generic required host tools are present."

# Test 2: Check Arch-specific tools ONLY if running on Arch Linux
if [ -f /etc/arch-release ] || command -v pacman &> /dev/null; then
    echo "[TEST] Checking Arch-specific build tools..."
    for cmd in pacman bsdtar arch-chroot; do
        if ! command -v "$cmd" &> /dev/null; then
            echo "FAIL: Required Arch command '$cmd' is not installed."
            exit 1
        fi
    done
    echo "PASS: All Arch-specific required host tools are present."
else
    echo "[TEST] Skipping Arch-specific tool check (not running on Arch Linux)."
fi

# Test 3: Check directory structure
echo "[TEST] Checking directory structure..."
for dir in build-tools pkgbuilds rootfs-overlay tests; do
    if [ ! -d "$dir" ]; then
        echo "FAIL: Required directory '$dir' is missing."
        exit 1
    fi
done
echo "PASS: Directory structure is valid."

echo "All build environment tests passed."
exit 0