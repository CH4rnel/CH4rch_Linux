#!/bin/bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test: Verify telemetry utility exists and has correct structure.

set -e

echo "Running telemetry tests..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TELEMETRY_SCRIPT="$SCRIPT_DIR/build-tools/ch4rch-telemetry"

# Test 1: Check ch4rch-telemetry exists
echo "[TEST] Checking ch4rch-telemetry exists..."
if [ ! -f "$TELEMETRY_SCRIPT" ]; then
    echo "FAIL: ch4rch-telemetry not found at $TELEMETRY_SCRIPT"
    exit 1
fi
echo "PASS: ch4rch-telemetry exists."

# Test 2: Check mandatory header
echo "[TEST] Checking mandatory header..."
if ! grep -q "𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭" "$TELEMETRY_SCRIPT"; then
    echo "FAIL: Mandatory header missing in ch4rch-telemetry"
    exit 1
fi
echo "PASS: Mandatory header present."

# Test 3: Check script is executable
echo "[TEST] Checking script is executable..."
if [ ! -x "$TELEMETRY_SCRIPT" ]; then
    echo "FAIL: ch4rch-telemetry is not executable"
    exit 1
fi
echo "PASS: ch4rch-telemetry is executable."

# Test 4: Check required commands exist
echo "[TEST] Checking required commands..."
if ! grep -q "collect" "$TELEMETRY_SCRIPT"; then
    echo "FAIL: collect command missing"
    exit 1
fi
if ! grep -q "cpu" "$TELEMETRY_SCRIPT"; then
    echo "FAIL: cpu metric missing"
    exit 1
fi
if ! grep -q "memory" "$TELEMETRY_SCRIPT"; then
    echo "FAIL: memory metric missing"
    exit 1
fi
if ! grep -q "disk" "$TELEMETRY_SCRIPT"; then
    echo "FAIL: disk metric missing"
    exit 1
fi
if ! grep -q "services" "$TELEMETRY_SCRIPT"; then
    echo "FAIL: services metric missing"
    exit 1
fi
echo "PASS: All required commands present."

echo "All telemetry tests passed."
exit 0