#!/bin/bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test: Verify declarative configuration utility exists and has correct structure.

set -e

echo "Running declarative configuration tests..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CH4RCHCTL_SCRIPT="$SCRIPT_DIR/build-tools/ch4rchctl"

# Test 1: Check ch4rchctl exists
echo "[TEST] Checking ch4rchctl exists..."
if [ ! -f "$CH4RCHCTL_SCRIPT" ]; then
    echo "FAIL: ch4rchctl not found at $CH4RCHCTL_SCRIPT"
    exit 1
fi
echo "PASS: ch4rchctl exists."

# Test 2: Check mandatory header
echo "[TEST] Checking mandatory header..."
if ! grep -q "𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭" "$CH4RCHCTL_SCRIPT"; then
    echo "FAIL: Mandatory header missing in ch4rchctl"
    exit 1
fi
echo "PASS: Mandatory header present."

# Test 3: Check script is executable
echo "[TEST] Checking script is executable..."
if [ ! -x "$CH4RCHCTL_SCRIPT" ]; then
    echo "FAIL: ch4rchctl is not executable"
    exit 1
fi
echo "PASS: ch4rchctl is executable."

# Test 4: Check required commands exist
echo "[TEST] Checking required commands..."
if ! grep -q "plan" "$CH4RCHCTL_SCRIPT"; then
    echo "FAIL: plan command missing"
    exit 1
fi
if ! grep -q "apply" "$CH4RCHCTL_SCRIPT"; then
    echo "FAIL: apply command missing"
    exit 1
fi
echo "PASS: All required commands present."

echo "All declarative configuration tests passed."
exit 0