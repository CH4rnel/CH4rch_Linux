#!/bin/bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Hash-chain logging utility for CH4rch Linux build and audit events.
# Implements an append-only ledger: H_n = HASH(H_{n-1} || record_n)

set -e

CHAIN_FILE="${CH4RCH_BUILDROOT:-/var/ch4rch-build}/audit-chain.log"

# Ensure directory exists
mkdir -p "$(dirname "$CHAIN_FILE")"

# Initialize chain file with genesis block if it doesn't exist
if [ ! -f "$CHAIN_FILE" ]; then
    echo "GENESIS $(date -u +%Y-%m-%dT%H:%M:%SZ) CH4rch-Linux-Trust-Chain-Init" > "$CHAIN_FILE"
fi

RECORD="$*"
PREV_HASH=$(tail -n 1 "$CHAIN_FILE" | awk '{print $1}')

# Use sha3-256sum if available, fallback to sha256sum for MVP compatibility
if command -v sha3-256sum &> /dev/null; then
    CURRENT_HASH=$(echo -n "${PREV_HASH}${RECORD}" | sha3-256sum | awk '{print $1}')
else
    CURRENT_HASH=$(echo -n "${PREV_HASH}${RECORD}" | sha256sum | awk '{print $1}')
fi

TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "${CURRENT_HASH} ${TIMESTAMP} ${RECORD}" >> "$CHAIN_FILE"

echo "[CH4RCH] Audit record appended. Hash: ${CURRENT_HASH}"