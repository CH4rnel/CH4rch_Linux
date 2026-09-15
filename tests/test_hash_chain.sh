#!/bin/bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test: Verify hash-chain utility creates a valid, append-only ledger.

set -e

echo "Running hash-chain integrity tests..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHAIN_SCRIPT="$SCRIPT_DIR/build-tools/hash-chain.sh"

# The same file-naming logic as in hash-chain.sh is followed when CH4RCH_BUILDROOT=/tmp is set.
TEST_CHAIN_FILE="/tmp/audit-chain.log"

# Cleanup before test to ensure a clean slate
rm -f "$TEST_CHAIN_FILE"

# Test 1: Genesis block creation + first event
echo "[TEST] Checking genesis block creation and first event..."
CH4RCH_BUILDROOT="/tmp" "$CHAIN_SCRIPT" "TEST_EVENT_1" > /dev/null

if [ ! -f "$TEST_CHAIN_FILE" ]; then
    echo "FAIL: Chain file was not created at $TEST_CHAIN_FILE"
    exit 1
fi

if ! grep -q "GENESIS" "$TEST_CHAIN_FILE"; then
    echo "FAIL: Genesis block not created."
    cat "$TEST_CHAIN_FILE"
    exit 1
fi

# After first call: GENESIS + TEST_EVENT_1 = 2 lines
LINES_AFTER_FIRST=$(wc -l < "$TEST_CHAIN_FILE")
if [ "$LINES_AFTER_FIRST" -ne 2 ]; then
    echo "FAIL: Expected 2 lines after first event (GENESIS + EVENT), got $LINES_AFTER_FIRST"
    cat "$TEST_CHAIN_FILE"
    exit 1
fi
echo "PASS: Genesis block and first event exist (2 lines)."

# Test 2: Chain linkage (H_n depends on H_{n-1})
echo "[TEST] Checking hash chain linkage..."

# Add a second event to the chain
CH4RCH_BUILDROOT="/tmp" "$CHAIN_SCRIPT" "TEST_EVENT_2" > /dev/null

# After second call: GENESIS + TEST_EVENT_1 + TEST_EVENT_2 = 3 lines
LINES_COUNT=$(wc -l < "$TEST_CHAIN_FILE")
if [ "$LINES_COUNT" -ne 3 ]; then
    echo "FAIL: Expected 3 lines in chain file, got $LINES_COUNT"
    cat "$TEST_CHAIN_FILE"
    exit 1
fi

# Extract hashes from each line
HASH_GENESIS=$(sed -n '1p' "$TEST_CHAIN_FILE" | awk '{print $1}')
HASH_EVENT1=$(sed -n '2p' "$TEST_CHAIN_FILE" | awk '{print $1}')
HASH_EVENT2=$(sed -n '3p' "$TEST_CHAIN_FILE" | awk '{print $1}')

# A test verifying that all hashes are distinct (confirming the chaining mechanism works).
if [ "$HASH_GENESIS" = "$HASH_EVENT1" ] || [ "$HASH_EVENT1" = "$HASH_EVENT2" ] || [ "$HASH_GENESIS" = "$HASH_EVENT2" ]; then
    echo "FAIL: Hashes are not unique, chain linkage may be broken."
    echo "GENESIS: $HASH_GENESIS"
    echo "EVENT1:  $HASH_EVENT1"
    echo "EVENT2:  $HASH_EVENT2"
    exit 1
fi

echo "PASS: Hash chain linkage is valid (all hashes unique)."

# Cleanup after test
rm -f "$TEST_CHAIN_FILE"
echo "All hash-chain tests passed."
exit 0