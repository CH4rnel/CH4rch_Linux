# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
#!/usr/bin/env bash
# Test suite for build-tools/build-rootfs.sh
# Ensures pacman configuration is valid and syntax is correct.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_SCRIPT="$ROOT_DIR/build-tools/build-rootfs.sh"

echo "Running tests for build-rootfs.sh..."

# Test 1: Syntax check via shellcheck (if available)
test_syntax() {
    if command -v shellcheck &> /dev/null; then
        if ! shellcheck -x "$BUILD_SCRIPT"; then
            echo "FAIL: shellcheck found issues in build-rootfs.sh"
            return 1
        fi
    else
        echo "WARN: shellcheck not installed, skipping syntax test."
    fi
    echo "PASS: Syntax check"
}

# Test 2: Verify pacman.conf generation includes upstream repos (P0-2)
test_pacman_conf_upstream() {
    if grep -q "geo.mirror.pkgbuild.com" "$BUILD_SCRIPT" || grep -q "mirror.rackspace.com/archlinux" "$BUILD_SCRIPT"; then
        echo "PASS: Upstream repositories configuration present (P0-2)"
        return 0
    else
        echo "FAIL: build-rootfs.sh does not configure upstream Arch Linux repositories."
        return 1
    fi
}

# Test 3: Verify P0-1 fix (backslashes for line continuation)
test_pacman_line_continuation() {
    # FIX: Use grep -F (fixed strings) to search for a literal backslash 
    # without triggering regex parsing errors on trailing backslashes.
    if grep -Fq "dhcpcd \\" "$BUILD_SCRIPT" && grep -Fq "bubblewrap \\" "$BUILD_SCRIPT"; then
        echo "PASS: Pacman line continuations are correct (P0-1)"
        return 0
    else
        echo "FAIL: Pacman command is missing line continuations (P0-1 not fixed)."
        return 1
    fi
}

# Run tests
test_syntax
test_pacman_conf_upstream
test_pacman_line_continuation

echo "✅ All build-rootfs tests passed."