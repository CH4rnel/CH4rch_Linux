#!/bin/bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test: Verify autonomous auditor utility exists and enforces safe scanning.

set -e

echo "Running autonomous auditor tests..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AUDITOR_SCRIPT="$SCRIPT_DIR/build-tools/ch4rch-auditor"

# Test 1: Check ch4rch-auditor exists
echo "[TEST] Checking ch4rch-auditor exists..."
if [ ! -f "$AUDITOR_SCRIPT" ]; then
    echo "FAIL: ch4rch-auditor not found at $AUDITOR_SCRIPT"
    exit 1
fi
echo "PASS: ch4rch-auditor exists."

# Test 2: Check mandatory header
echo "[TEST] Checking mandatory header..."
if ! grep -q "𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭" "$AUDITOR_SCRIPT"; then
    echo "FAIL: Mandatory header missing in ch4rch-auditor"
    exit 1
fi
echo "PASS: Mandatory header present."

# Test 3: Check script is executable
echo "[TEST] Checking script is executable..."
if [ ! -x "$AUDITOR_SCRIPT" ]; then
    echo "FAIL: ch4rch-auditor is not executable"
    exit 1
fi
echo "PASS: ch4rch-auditor is executable."

# Test 4: Check required commands and safety checks
echo "[TEST] Checking required commands..."
if ! grep -q "scan-packages" "$AUDITOR_SCRIPT"; then
    echo "FAIL: scan-packages command missing"
    exit 1
fi
if ! grep -q "scan-permissions" "$AUDITOR_SCRIPT"; then
    echo "FAIL: scan-permissions command missing"
    exit 1
fi
if ! grep -q "report" "$AUDITOR_SCRIPT"; then
    echo "FAIL: report generation missing"
    exit 1
fi
if ! grep -q "hash-chain\|ch4rch-events" "$AUDITOR_SCRIPT"; then
    echo "FAIL: Audit logging/event publishing missing"
    exit 1
fi
echo "PASS: All required commands and safety checks present."

echo "All autonomous auditor tests passed."
exit 0