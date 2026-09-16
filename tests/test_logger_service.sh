#!/bin/bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test: Verify logger service exists and is included in base bundle.

set -e

echo "Running logger service tests..."

SOURCE_DIR="rootfs-overlay/etc/s6-rc/source"

# Test 1: Check logger service exists
echo "[TEST] Checking logger service definition..."
if [ ! -d "$SOURCE_DIR/logger" ]; then
    echo "FAIL: logger service directory missing."
    exit 1
fi

if [ ! -f "$SOURCE_DIR/logger/type" ]; then
    echo "FAIL: logger/type missing."
    exit 1
fi

if [ "$(cat "$SOURCE_DIR/logger/type")" != "oneshot" ]; then
    echo "FAIL: logger should be oneshot type."
    exit 1
fi

if [ ! -f "$SOURCE_DIR/logger/up" ]; then
    echo "FAIL: logger/up missing."
    exit 1
fi
echo "PASS: logger service is correctly defined."

# Test 2: Check logger is in base bundle
echo "[TEST] Checking logger in base bundle..."
if ! grep -q "^logger$" "$SOURCE_DIR/base/contents"; then
    echo "FAIL: logger not in base bundle."
    exit 1
fi
echo "PASS: logger is in base bundle."

echo "All logger service tests passed."
exit 0