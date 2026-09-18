#!/bin/bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test: Verify remediation capability utility exists and enforces plan/apply flow.

set -e

echo "Running remediation capability tests..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REMEDIATE_SCRIPT="$SCRIPT_DIR/build-tools/ch4rch-remediate"

# Test 1: Check ch4rch-remediate exists
echo "[TEST] Checking ch4rch-remediate exists..."
if [ ! -f "$REMEDIATE_SCRIPT" ]; then
    echo "FAIL: ch4rch-remediate not found at $REMEDIATE_SCRIPT"
    exit 1
fi
echo "PASS: ch4rch-remediate exists."

# Test 2: Check mandatory header
echo "[TEST] Checking mandatory header..."
if ! grep -q "𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭" "$REMEDIATE_SCRIPT"; then
    echo "FAIL: Mandatory header missing in ch4rch-remediate"
    exit 1
fi
echo "PASS: Mandatory header present."

# Test 3: Check script is executable
echo "[TEST] Checking script is executable..."
if [ ! -x "$REMEDIATE_SCRIPT" ]; then
    echo "FAIL: ch4rch-remediate is not executable"
    exit 1
fi
echo "PASS: ch4rch-remediate is executable."

# Test 4: Check required commands exist (plan/apply flow)
echo "[TEST] Checking required commands..."
if ! grep -q "plan" "$REMEDIATE_SCRIPT"; then
    echo "FAIL: plan command missing"
    exit 1
fi
if ! grep -q "apply" "$REMEDIATE_SCRIPT"; then
    echo "FAIL: apply command missing"
    exit 1
fi
if ! grep -q "require_confirmation\|CONFIRM" "$REMEDIATE_SCRIPT"; then
    echo "FAIL: Confirmation enforcement logic missing"
    exit 1
fi
echo "PASS: All required commands and safety checks present."

echo "All remediation capability tests passed."
exit 0