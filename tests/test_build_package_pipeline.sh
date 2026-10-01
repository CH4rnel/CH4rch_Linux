#!/usr/bin/env bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test suite build-package.sh and repo-sync.sh integration.
# Validates packages are built, copied to PKGDEST, synced to repo, no dead code.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_PACKAGE_SCRIPT="$ROOT_DIR/build-tools/build-package.sh"
REPO_SYNC_SCRIPT="$ROOT_DIR/build-tools/repo-sync.sh"

echo "Running tests for build-package pipeline..."

FAILED=0

# Test 1: build-package.sh copies packages to PKGDEST
test_copies_to_pkgdest() {
    if ! grep -qE "PKGDEST|mv.*pkg\.tar" "$BUILD_PACKAGE_SCRIPT"; then
        echo "FAIL: build-package.sh does not copy packages to PKGDEST"
        FAILED=1
        return 1
    fi
    echo "PASS: build-package.sh copies packages to PKGDEST"
}

# Test 2: No dead code (extra/community repos)
test_no_dead_code() {
    if grep -qE "build_repo (extra|community)" "$BUILD_PACKAGE_SCRIPT"; then
        echo "FAIL: build-package.sh contains dead code (extra/community repos don't exist)"
        FAILED=1
        return 1
    fi
    echo "PASS: No dead code in build-package.sh"
}

# Test 3: repo-sync.sh reads from PKGDEST
test_repo_sync_reads_pkgdest() {
    if ! grep -q "CH4RCH_PKGDEST" "$REPO_SYNC_SCRIPT"; then
        echo "FAIL: repo-sync.sh does not reference CH4RCH_PKGDEST"
        FAILED=1
        return 1
    fi
    echo "PASS: repo-sync.sh reads from PKGDEST"
}

# Test 4: repo-sync.sh calls repo-add
test_repo_sync_calls_repo_add() {
    if ! grep -q "repo-add" "$REPO_SYNC_SCRIPT"; then
        echo "FAIL: repo-sync.sh does not call repo-add"
        FAILED=1
        return 1
    fi
    echo "PASS: repo-sync.sh calls repo-add"
}

# Test 5: build-package.sh only builds existing repos
test_builds_existing_repos() {
    if grep -q "build_repo core" "$BUILD_PACKAGE_SCRIPT"; then
        echo "PASS: build-package.sh builds core repo"
    else
        echo "FAIL: build-package.sh does not build core repo"
        FAILED=1
        return 1
    fi
}

# Run tests
test_copies_to_pkgdest
test_no_dead_code
test_repo_sync_reads_pkgdest
test_repo_sync_calls_repo_add
test_builds_existing_repos

if [[ $FAILED -eq 1 ]]; then
    echo ""
    echo "Some pipeline tests FAILED."
    exit 1
fi

echo "All build-package pipeline tests passed."