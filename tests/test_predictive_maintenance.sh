#!/bin/bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test: Verify predictive maintenance utility exists and implements Weibull analysis.

set -e

echo "Running predictive maintenance tests..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PREDICTIVE_SCRIPT="$SCRIPT_DIR/build-tools/ch4rch-predictive"

# Test 1: Check ch4rch-predictive exists
echo "[TEST] Checking ch4rch-predictive exists..."
if [ ! -f "$PREDICTIVE_SCRIPT" ]; then
    echo "FAIL: ch4rch-predictive not found at $PREDICTIVE_SCRIPT"
    exit 1
fi
echo "PASS: ch4rch-predictive exists."

# Test 2: Check mandatory header
echo "[TEST] Checking mandatory header..."
if ! grep -q "𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭" "$PREDICTIVE_SCRIPT"; then
    echo "FAIL: Mandatory header missing in ch4rch-predictive"
    exit 1
fi
echo "PASS: Mandatory header present."

# Test 3: Check script is executable
echo "[TEST] Checking script is executable..."
if [ ! -x "$PREDICTIVE_SCRIPT" ]; then
    echo "FAIL: ch4rch-predictive is not executable"
    exit 1
fi
echo "PASS: ch4rch-predictive is executable."

# Test 4: Check required commands and Weibull implementation
echo "[TEST] Checking required commands..."
if ! grep -q "analyze" "$PREDICTIVE_SCRIPT"; then
    echo "FAIL: analyze command missing"
    exit 1
fi
if ! grep -q "predict" "$PREDICTIVE_SCRIPT"; then
    echo "FAIL: predict command missing"
    exit 1
fi
if ! grep -q "weibull\|Weibull" "$PREDICTIVE_SCRIPT"; then
    echo "FAIL: Weibull distribution implementation missing"
    exit 1
fi
if ! grep -q "telemetry\|metrics" "$PREDICTIVE_SCRIPT"; then
    echo "FAIL: Telemetry integration missing"
    exit 1
fi
echo "PASS: All required commands and Weibull implementation present."

echo "All predictive maintenance tests passed."
exit 0