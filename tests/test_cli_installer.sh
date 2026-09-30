#!/usr/bin/env bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test suite minimal CLI installer.
# Validates disk partitioning, squashfs extraction, bootloader installation.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
INSTALLER_SCRIPT="$ROOT_DIR/installer/cli-installer.sh"

echo "Running tests for CLI installer..."

FAILED=0

# Test 1: Portable shebang
test_shebang() {
    local first_line
    first_line=$(head -n 1 "$INSTALLER_SCRIPT")
    if [[ "$first_line" != "#!/usr/bin/env bash" ]]; then
        echo "FAIL: Shebang is '$first_line', expected '#!/usr/bin/env bash'"
        FAILED=1
        return 1
    fi
    echo "PASS: Portable shebang"
}

# Test 2: Not a stub (must have real logic)
test_not_stub() {
    if grep -q "STUB.*not yet implemented" "$INSTALLER_SCRIPT"; then
        echo "FAIL: installer is still a stub"
        FAILED=1
        return 1
    fi
    echo "PASS: Not a stub"
}

# Test 3: Uses squashfs (not raw copy)
test_uses_squashfs() {
    if ! grep -qE "unsquashfs|squashfs" "$INSTALLER_SCRIPT"; then
        echo "FAIL: installer does not use squashfs"
        FAILED=1
        return 1
    fi
    echo "PASS: Uses squashfs for installation"
}

# Test 4: Disk partitioning function exists
test_disk_partitioning() {
    if ! grep -qE "partition|fdisk|sgdisk|parted" "$INSTALLER_SCRIPT"; then
        echo "FAIL: installer does not implement disk partitioning"
        FAILED=1
        return 1
    fi
    echo "PASS: Disk partitioning implemented"
}

# Test 5: Bootloader installation
test_bootloader() {
    if ! grep -qE "grub-install|bootctl|efibootmgr" "$INSTALLER_SCRIPT"; then
        echo "FAIL: installer does not install bootloader"
        FAILED=1
        return 1
    fi
    echo "PASS: Bootloader installation implemented"
}

# Test 6: User configuration
test_user_config() {
    if ! grep -qE "useradd|username|password" "$INSTALLER_SCRIPT"; then
        echo "FAIL: installer does not configure user"
        FAILED=1
        return 1
    fi
    echo "PASS: User configuration implemented"
}

# Test 7: Hostname configuration
test_hostname_config() {
    if ! grep -qE "hostname|/etc/hostname" "$INSTALLER_SCRIPT"; then
        echo "FAIL: installer does not configure hostname"
        FAILED=1
        return 1
    fi
    echo "PASS: Hostname configuration implemented"
}

# Test 8: Locale/timezone configuration
test_locale_config() {
    if ! grep -qE "locale|timezone|ln -sf.*zoneinfo" "$INSTALLER_SCRIPT"; then
        echo "FAIL: installer does not configure locale/timezone"
        FAILED=1
        return 1
    fi
    echo "PASS: Locale/timezone configuration implemented"
}

# Run tests
test_shebang
test_not_stub
test_uses_squashfs
test_disk_partitioning
test_bootloader
test_user_config
test_hostname_config
test_locale_config

if [[ $FAILED -eq 1 ]]; then
    echo ""
    echo "Some CLI installer tests FAILED."
    exit 1
fi

echo "All CLI installer tests passed."