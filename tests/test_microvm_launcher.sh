#!/bin/bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test: Verify microVM launcher utility exists and has correct structure.

set -e

echo "Running microVM launcher tests..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MICROVM_SCRIPT="$SCRIPT_DIR/build-tools/microvm-launch.sh"

# Test 1: Check microvm-launch.sh exists
echo "[TEST] Checking microvm-launch.sh exists..."
if [ ! -f "$MICROVM_SCRIPT" ]; then
    echo "FAIL: microvm-launch.sh not found at $MICROVM_SCRIPT"
    exit 1
fi
echo "PASS: microvm-launch.sh exists."

# Test 2: Check mandatory header
echo "[TEST] Checking mandatory header..."
if ! grep -q "𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭" "$MICROVM_SCRIPT"; then
    echo "FAIL: Mandatory header missing in microvm-launch.sh"
    exit 1
fi
echo "PASS: Mandatory header present."

# Test 3: Check script is executable
echo "[TEST] Checking script is executable..."
if [ ! -x "$MICROVM_SCRIPT" ]; then
    echo "FAIL: microvm-launch.sh is not executable"
    exit 1
fi
echo "PASS: microvm-launch.sh is executable."

# Test 4: Check required parameters/flags are handled
echo "[TEST] Checking required parameters handling..."
if ! grep -q "\-\-rootfs" "$MICROVM_SCRIPT"; then
    echo "FAIL: --rootfs parameter handling missing"
    exit 1
fi
if ! grep -q "\-\-overlay" "$MICROVM_SCRIPT"; then
    echo "FAIL: --overlay parameter handling missing"
    exit 1
fi
if ! grep -q "cloud-hypervisor\|qemu-system-x86_64" "$MICROVM_SCRIPT"; then
    echo "FAIL: microVM backend (cloud-hypervisor or qemu) missing"
    exit 1
fi
echo "PASS: Required parameters and backends are present."

echo "All microVM launcher tests passed."
exit 0