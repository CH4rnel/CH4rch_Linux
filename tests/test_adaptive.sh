#!/bin/bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test: Verify adaptive engine utility exists and has correct structure.

set -e

echo "Running adaptive engine tests..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ADAPTIVE_SCRIPT="$SCRIPT_DIR/build-tools/ch4rch-adaptive"

# Test 1: Check ch4rch-adaptive exists
echo "[TEST] Checking ch4rch-adaptive exists..."
if [ ! -f "$ADAPTIVE_SCRIPT" ]; then
    echo "FAIL: ch4rch-adaptive not found at $ADAPTIVE_SCRIPT"
    exit 1
fi
echo "PASS: ch4rch-adaptive exists."

# Test 2: Check mandatory header
echo "[TEST] Checking mandatory header..."
if ! grep -q "𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭" "$ADAPTIVE_SCRIPT"; then
    echo "FAIL: Mandatory header missing in ch4rch-adaptive"
    exit 1
fi
echo "PASS: Mandatory header present."

# Test 3: Check script is executable
echo "[TEST] Checking script is executable..."
if [ ! -x "$ADAPTIVE_SCRIPT" ]; then
    echo "FAIL: ch4rch-adaptive is not executable"
    exit 1
fi
echo "PASS: ch4rch-adaptive is executable."

# Test 4: Check required commands exist
echo "[TEST] Checking required commands..."
if ! grep -q "analyze" "$ADAPTIVE_SCRIPT"; then
    echo "FAIL: analyze command missing"
    exit 1
fi
if ! grep -q "threshold" "$ADAPTIVE_SCRIPT"; then
    echo "FAIL: threshold configuration missing"
    exit 1
fi
if ! grep -q "react" "$ADAPTIVE_SCRIPT"; then
    echo "FAIL: react command missing"
    exit 1
fi
echo "PASS: All required commands present."

echo "All adaptive engine tests passed."
exit 0