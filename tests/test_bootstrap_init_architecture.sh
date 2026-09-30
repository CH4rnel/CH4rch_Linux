#!/usr/bin/env bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test suite bootstrap-init.sh architectural compliance.
# Validates uses rootfs-overlay as single source of truth, calls s6-linux-init-maker.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
BOOTSTRAP_SCRIPT="$ROOT_DIR/build-tools/bootstrap-init.sh"

echo "Running tests for bootstrap-init architecture..."

FAILED=0

# Test 1: Uses rootfs-overlay as source (not s6-services/)
test_uses_rootfs_overlay() {
    if grep -q "s6-services/source" "$BOOTSTRAP_SCRIPT"; then
        echo "FAIL: bootstrap-init.sh uses osiroted s6-services/source"
        FAILED=1
        return 1
    fi
    if ! grep -q "rootfs-overlay/etc/s6-rc/source" "$BOOTSTRAP_SCRIPT"; then
        echo "FAIL: bootstrap-init.sh does not use rootfs-overlay/etc/s6-rc/source"
        FAILED=1
        return 1
    fi
    echo "PASS: Uses rootfs-overlay as single source of truth"
}

# Test 2: Calls s6-linux-init-maker
test_calls_s6_linux_init_maker() {
    if ! grep -q "s6-linux-init-maker" "$BOOTSTRAP_SCRIPT"; then
        echo "FAIL: bootstrap-init.sh does not call s6-linux-init-maker"
        FAILED=1
        return 1
    fi
    echo "PASS: Calls s6-linux-init-maker"
}

# Test 3: Creates /sbin/init symlink or executable
test_creates_sbin_init() {
    if ! grep -qE "sbin/init|rc\.init" "$BOOTSTRAP_SCRIPT"; then
        echo "FAIL: bootstrap-init.sh does not create /sbin/init or reference rc.init"
        FAILED=1
        return 1
    fi
    echo "PASS: Creates /sbin/init or references rc.init"
}

# Test 4: Compiles s6-rc database
test_compiles_s6rc() {
    if ! grep -q "s6-rc-compile" "$BOOTSTRAP_SCRIPT"; then
        echo "FAIL: bootstrap-init.sh does not call s6-rc-compile"
        FAILED=1
        return 1
    fi
    echo "PASS: Compiles s6-rc database"
}

# Test 5: No reference to orphaned s6-services/
test_no_orphaned_references() {
    if grep -qE "s6-services/(bundles|source)" "$BOOTSTRAP_SCRIPT"; then
        echo "FAIL: bootstrap-init.sh references orphaned s6-services/ directory"
        FAILED=1
        return 1
    fi
    echo "PASS: No orphaned s6-services/ references"
}

# Run tests
test_uses_rootfs_overlay
test_calls_s6_linux_init_maker
test_creates_sbin_init
test_compiles_s6rc
test_no_orphaned_references

if [[ $FAILED -eq 1 ]]; then
    echo ""
    echo "Some architecture tests FAILED."
    exit 1
fi

echo "All bootstrap-init architecture tests passed."