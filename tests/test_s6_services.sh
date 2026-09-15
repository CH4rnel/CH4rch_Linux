#!/bin/bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test: Verify critical s6-rc services are defined correctly in the source directory.

set -e

echo "Running s6-rc service definition tests..."

SRCTREE="rootfs-overlay/etc/s6-rc/source"

# Test 1: Check getty service exists and has required files
echo "Checking getty service..."
if [ ! -f "$SRCTREE/getty/type" ]; then
    echo "FAIL: getty/type missing"
    exit 1
fi
if [ ! -f "$SRCTREE/getty/run" ]; then
    echo "FAIL: getty/run missing"
    exit 1
fi
if [ ! -x "$SRCTREE/getty/run" ]; then
    echo "FAIL: getty/run is not executable"
    exit 1
fi
echo "PASS: getty service is correctly defined."

# Test 2: Check network service exists and has required files
echo "Checking network service..."
if [ ! -f "$SRCTREE/network/type" ]; then
    echo "FAIL: network/type missing"
    exit 1
fi
if [ ! -f "$SRCTREE/network/run" ]; then
    echo "FAIL: network/run missing"
    exit 1
fi
if [ ! -x "$SRCTREE/network/run" ]; then
    echo "FAIL: network/run is not executable"
    exit 1
fi
echo "PASS: network service is correctly defined."

# Test 3: Check base bundle includes critical services
echo "Checking base bundle contents..."
if [ ! -f "$SRCTREE/base/contents" ]; then
    echo "FAIL: base/contents missing"
    exit 1
fi
if ! grep -q "getty" "$SRCTREE/base/contents"; then
    echo "FAIL: getty not in base bundle"
    exit 1
fi
if ! grep -q "network" "$SRCTREE/base/contents"; then
    echo "FAIL: network not in base bundle"
    exit 1
fi
echo "PASS: base bundle includes getty and network."

echo "All s6-rc service tests passed."
exit 0