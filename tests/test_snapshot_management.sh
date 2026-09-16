#!/bin/bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test: Verify snapshot management utility exists and has correct structure.

set -e

echo "Running snapshot management tests..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SNAPSHOT_SCRIPT="$SCRIPT_DIR/build-tools/snapshot.sh"

# Test 1: Check snapshot.sh exists
echo "[TEST] Checking snapshot.sh exists..."
if [ ! -f "$SNAPSHOT_SCRIPT" ]; then
    echo "FAIL: snapshot.sh not found at $SNAPSHOT_SCRIPT"
    exit 1
fi
echo "PASS: snapshot.sh exists."

# Test 2: Check mandatory header
echo "[TEST] Checking mandatory header..."
if ! grep -q "𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭" "$SNAPSHOT_SCRIPT"; then
    echo "FAIL: Mandatory header missing in snapshot.sh"
    exit 1
fi
echo "PASS: Mandatory header present."

# Test 3: Check script is executable
echo "[TEST] Checking script is executable..."
if [ ! -x "$SNAPSHOT_SCRIPT" ]; then
    echo "FAIL: snapshot.sh is not executable"
    exit 1
fi
echo "PASS: snapshot.sh is executable."

# Test 4: Check required functions exist
echo "[TEST] Checking required functions..."
if ! grep -q "create_snapshot" "$SNAPSHOT_SCRIPT"; then
    echo "FAIL: create_snapshot function missing"
    exit 1
fi
if ! grep -q "list_snapshots" "$SNAPSHOT_SCRIPT"; then
    echo "FAIL: list_snapshots function missing"
    exit 1
fi
if ! grep -q "rollback_snapshot" "$SNAPSHOT_SCRIPT"; then
    echo "FAIL: rollback_snapshot function missing"
    exit 1
fi
echo "PASS: All required functions present."

echo "All snapshot management tests passed."
exit 0