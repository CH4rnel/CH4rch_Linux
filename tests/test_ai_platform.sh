#!/bin/bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test: Verify AI supervision platform utility exists and has correct structure.

set -e

echo "Running AI platform tests..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AI_SCRIPT="$SCRIPT_DIR/build-tools/ch4rch-ai"

# Test 1: Check ch4rch-ai exists
echo "[TEST] Checking ch4rch-ai exists..."
if [ ! -f "$AI_SCRIPT" ]; then
    echo "FAIL: ch4rch-ai not found at $AI_SCRIPT"
    exit 1
fi
echo "PASS: ch4rch-ai exists."

# Test 2: Check mandatory header
echo "[TEST] Checking mandatory header..."
if ! grep -q "𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭" "$AI_SCRIPT"; then
    echo "FAIL: Mandatory header missing in ch4rch-ai"
    exit 1
fi
echo "PASS: Mandatory header present."

# Test 3: Check script is executable
echo "[TEST] Checking script is executable..."
if [ ! -x "$AI_SCRIPT" ]; then
    echo "FAIL: ch4rch-ai is not executable"
    exit 1
fi
echo "PASS: ch4rch-ai is executable."

# Test 4: Check required commands exist
echo "[TEST] Checking required commands..."
if ! grep -q "enable" "$AI_SCRIPT"; then
    echo "FAIL: enable command missing"
    exit 1
fi
if ! grep -q "disable" "$AI_SCRIPT"; then
    echo "FAIL: disable command missing"
    exit 1
fi
if ! grep -q "status" "$AI_SCRIPT"; then
    echo "FAIL: status command missing"
    exit 1
fi
if ! grep -q "profile" "$AI_SCRIPT"; then
    echo "FAIL: profile command missing"
    exit 1
fi
echo "PASS: All required commands present."

echo "All AI platform tests passed."
exit 0