#!/bin/bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test: Verify agent capabilities utility exists and has correct structure.

set -e

echo "Running agent capabilities tests..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CAPABILITIES_SCRIPT="$SCRIPT_DIR/build-tools/ch4rch-agent-capabilities"

# Test 1: Check ch4rch-agent-capabilities exists
echo "[TEST] Checking ch4rch-agent-capabilities exists..."
if [ ! -f "$CAPABILITIES_SCRIPT" ]; then
    echo "FAIL: ch4rch-agent-capabilities not found at $CAPABILITIES_SCRIPT"
    exit 1
fi
echo "PASS: ch4rch-agent-capabilities exists."

# Test 2: Check mandatory header
echo "[TEST] Checking mandatory header..."
if ! grep -q "𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭" "$CAPABILITIES_SCRIPT"; then
    echo "FAIL: Mandatory header missing in ch4rch-agent-capabilities"
    exit 1
fi
echo "PASS: Mandatory header present."

# Test 3: Check script is executable
echo "[TEST] Checking script is executable..."
if [ ! -x "$CAPABILITIES_SCRIPT" ]; then
    echo "FAIL: ch4rch-agent-capabilities is not executable"
    exit 1
fi
echo "PASS: ch4rch-agent-capabilities is executable."

# Test 4: Check required commands exist
echo "[TEST] Checking required commands..."
if ! grep -q "audit" "$CAPABILITIES_SCRIPT"; then
    echo "FAIL: audit command missing"
    exit 1
fi
if ! grep -q "inspect-cache" "$CAPABILITIES_SCRIPT"; then
    echo "FAIL: inspect-cache command missing"
    exit 1
fi
if ! grep -q "scan-local" "$CAPABILITIES_SCRIPT"; then
    echo "FAIL: scan-local command missing"
    exit 1
fi
echo "PASS: All required commands present."

echo "All agent capabilities tests passed."
exit 0