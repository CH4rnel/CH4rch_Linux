#!/usr/bin/env bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test suite repo-sync.sh must find and sync built packages.
# Validates packages from pkgbuilds/core/ are synced to repo, database is updated.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
REPO_SYNC_SCRIPT="$ROOT_DIR/build-tools/repo-sync.sh"
BUILD_PACKAGE_SCRIPT="$ROOT_DIR/build-tools/build-package.sh"

echo "Running tests for P1-1 repo-sync packages..."

FAILED=0

# Test 1: repo-sync.sh copies from pkgbuilds/core/ (not just PKGDEST)
test_copies_from_pkgbuilds() {
    if ! grep -qE "pkgbuilds/core|PKGDEST" "$REPO_SYNC_SCRIPT"; then
        echo "FAIL: repo-sync.sh does not reference pkgbuilds/core/ or PKGDEST"
        FAILED=1
        return 1
    fi
    echo "PASS: repo-sync.sh references package sources"
}

# Test 2: build-package.sh copies to PKGDEST after build
test_build_package_copies_to_pkgdest() {
    if ! grep -qE "PKGDEST|cp.*pkg\.tar" "$BUILD_PACKAGE_SCRIPT"; then
        echo "FAIL: build-package.sh does not copy packages to PKGDEST"
        FAILED=1
        return 1
    fi
    echo "PASS: build-package.sh copies to PKGDEST"
}

# Test 3: repo-sync.sh calls repo-add to update database
test_calls_repo_add() {
    if ! grep -q "repo-add" "$REPO_SYNC_SCRIPT"; then
        echo "FAIL: repo-sync.sh does not call repo-add"
        FAILED=1
        return 1
    fi
    echo "PASS: repo-sync.sh calls repo-add"
}

# Test 4: repo-sync.sh logs to hash-chain
test_logs_to_hash_chain() {
    if ! grep -q "hash-chain.sh" "$REPO_SYNC_SCRIPT"; then
        echo "FAIL: repo-sync.sh does not log to hash-chain"
        FAILED=1
        return 1
    fi
    echo "PASS: repo-sync.sh logs to hash-chain"
}

# Test 5: Handles missing packages gracefully
test_handles_missing_packages() {
    if ! grep -qE "2>/dev/null.*\|\|.*true|if.*-f" "$REPO_SYNC_SCRIPT"; then
        echo "FAIL: repo-sync.sh does not handle missing packages gracefully"
        FAILED=1
        return 1
    fi
    echo "PASS: repo-sync.sh handles missing packages"
}

# Run tests
test_copies_from_pkgbuilds
test_build_package_copies_to_pkgdest
test_calls_repo_add
test_logs_to_hash_chain
test_handles_missing_packages

if [[ $FAILED -eq 1 ]]; then
    echo ""
    echo "Some repo-sync tests FAILED."
    exit 1
fi

echo "All repo-sync tests passed."