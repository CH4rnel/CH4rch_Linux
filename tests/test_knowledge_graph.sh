#!/bin/bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test: Verify knowledge graph utility exists and has correct structure.

set -e

echo "Running knowledge graph tests..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KG_SCRIPT="$SCRIPT_DIR/build-tools/knowledge-graph"

# Test 1: Check knowledge-graph exists
echo "[TEST] Checking knowledge-graph exists..."
if [ ! -f "$KG_SCRIPT" ]; then
    echo "FAIL: knowledge-graph not found at $KG_SCRIPT"
    exit 1
fi
echo "PASS: knowledge-graph exists."

# Test 2: Check mandatory header
echo "[TEST] Checking mandatory header..."
if ! grep -q "𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭" "$KG_SCRIPT"; then
    echo "FAIL: Mandatory header missing in knowledge-graph"
    exit 1
fi
echo "PASS: Mandatory header present."

# Test 3: Check script is executable
echo "[TEST] Checking script is executable..."
if [ ! -x "$KG_SCRIPT" ]; then
    echo "FAIL: knowledge-graph is not executable"
    exit 1
fi
echo "PASS: knowledge-graph is executable."

# Test 4: Check required commands exist
echo "[TEST] Checking required commands..."
if ! grep -q "add-node" "$KG_SCRIPT"; then
    echo "FAIL: add-node command missing"
    exit 1
fi
if ! grep -q "add-edge" "$KG_SCRIPT"; then
    echo "FAIL: add-edge command missing"
    exit 1
fi
if ! grep -q "query" "$KG_SCRIPT"; then
    echo "FAIL: query command missing"
    exit 1
fi
if ! grep -q "export" "$KG_SCRIPT"; then
    echo "FAIL: export command missing"
    exit 1
fi
if ! grep -q "sqlite3" "$KG_SCRIPT"; then
    echo "FAIL: sqlite3 integration missing"
    exit 1
fi
echo "PASS: All required commands present."

echo "All knowledge graph tests passed."
exit 0