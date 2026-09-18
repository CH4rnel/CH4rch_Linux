#!/bin/bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test: Verify NetVM and GUI isolation utilities exist and have correct structure.

set -e

echo "Running NetVM and GUI isolation tests..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NETVM_SCRIPT="$SCRIPT_DIR/build-tools/netvm-setup.sh"
GUI_SCRIPT="$SCRIPT_DIR/build-tools/gui-isolate.sh"

# Test 1: Check netvm-setup.sh exists and has header
echo "[TEST] Checking netvm-setup.sh..."
if [ ! -f "$NETVM_SCRIPT" ]; then
    echo "FAIL: netvm-setup.sh not found"
    exit 1
fi
if ! grep -q "𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭" "$NETVM_SCRIPT"; then
    echo "FAIL: Mandatory header missing in netvm-setup.sh"
    exit 1
fi
if ! grep -q "nftables\|ip netns" "$NETVM_SCRIPT"; then
    echo "FAIL: NetVM isolation logic (nftables/ip netns) missing"
    exit 1
fi
echo "PASS: netvm-setup.sh is valid."

# Test 2: Check gui-isolate.sh exists and has header
echo "[TEST] Checking gui-isolate.sh..."
if [ ! -f "$GUI_SCRIPT" ]; then
    echo "FAIL: gui-isolate.sh not found"
    exit 1
fi
if ! grep -q "𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭" "$GUI_SCRIPT"; then
    echo "FAIL: Mandatory header missing in gui-isolate.sh"
    exit 1
fi
if ! grep -q "waypipe\|virtio-vsock" "$GUI_SCRIPT"; then
    echo "FAIL: GUI isolation logic (waypipe/vsock) missing"
    exit 1
fi
echo "PASS: gui-isolate.sh is valid."

echo "All NetVM and GUI isolation tests passed."
exit 0