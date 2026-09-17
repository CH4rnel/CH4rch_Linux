#!/bin/bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test: Verify process isolation utility exists and has correct structure.

set -e

echo "Running process isolation tests..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ISOLATE_SCRIPT="$SCRIPT_DIR/build-tools/isolate.sh"

# Test 1: Check isolate.sh exists
echo "[TEST] Checking isolate.sh exists..."
if [ ! -f "$ISOLATE_SCRIPT" ]; then
    echo "FAIL: isolate.sh not found at $ISOLATE_SCRIPT"
    exit 1
fi
echo "PASS: isolate.sh exists."

# Test 2: Check mandatory header
echo "[TEST] Checking mandatory header..."
if ! grep -q "𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭" "$ISOLATE_SCRIPT"; then
    echo "FAIL: Mandatory header missing in isolate.sh"
    exit 1
fi
echo "PASS: Mandatory header present."

# Test 3: Check script is executable
echo "[TEST] Checking script is executable..."
if [ ! -x "$ISOLATE_SCRIPT" ]; then
    echo "FAIL: isolate.sh is not executable"
    exit 1
fi
echo "PASS: isolate.sh is executable."

# Test 4: Check required commands exist
echo "[TEST] Checking required commands..."
if ! grep -q "run_sandboxed" "$ISOLATE_SCRIPT"; then
    echo "FAIL: run_sandboxed function missing"
    exit 1
fi
if ! grep -q "bwrap" "$ISOLATE_SCRIPT"; then
    echo "FAIL: bwrap integration missing"
    exit 1
fi
echo "PASS: All required commands present."

echo "All process isolation tests passed."
exit 0