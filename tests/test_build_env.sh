#!/bin/bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test: Verify build environment prerequisites and directory structure.

set -e

echo "Running build environment tests..."

# Test 1: Check required host tools
for cmd in pacman bsdtar make git; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "FAIL: Required command '$cmd' is not installed."
        exit 1
    fi
done
echo "PASS: All required host tools are present."

# Test 2: Check directory structure
for dir in build-tools pkgbuilds rootfs-overlay tests; do
    if [ ! -d "$dir" ]; then
        echo "FAIL: Required directory '$dir' is missing."
        exit 1
    fi
done
echo "PASS: Directory structure is valid."

echo "All build environment tests passed."
exit 0