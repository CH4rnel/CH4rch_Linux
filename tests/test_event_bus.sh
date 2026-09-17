#!/bin/bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test: Verify event bus utility exists and has correct structure.

set -e

echo "Running event bus tests..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EVENTS_SCRIPT="$SCRIPT_DIR/build-tools/ch4rch-events"

# Test 1: Check ch4rch-events exists
echo "[TEST] Checking ch4rch-events exists..."
if [ ! -f "$EVENTS_SCRIPT" ]; then
    echo "FAIL: ch4rch-events not found at $EVENTS_SCRIPT"
    exit 1
fi
echo "PASS: ch4rch-events exists."

# Test 2: Check mandatory header
echo "[TEST] Checking mandatory header..."
if ! grep -q "𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭" "$EVENTS_SCRIPT"; then
    echo "FAIL: Mandatory header missing in ch4rch-events"
    exit 1
fi
echo "PASS: Mandatory header present."

# Test 3: Check script is executable
echo "[TEST] Checking script is executable..."
if [ ! -x "$EVENTS_SCRIPT" ]; then
    echo "FAIL: ch4rch-events is not executable"
    exit 1
fi
echo "PASS: ch4rch-events is executable."

# Test 4: Check required commands exist
echo "[TEST] Checking required commands..."
if ! grep -q "publish" "$EVENTS_SCRIPT"; then
    echo "FAIL: publish command missing"
    exit 1
fi
if ! grep -q "subscribe" "$EVENTS_SCRIPT"; then
    echo "FAIL: subscribe command missing"
    exit 1
fi
if ! grep -q "list" "$EVENTS_SCRIPT"; then
    echo "FAIL: list command missing"
    exit 1
fi
echo "PASS: All required commands present."

echo "All event bus tests passed."
exit 0