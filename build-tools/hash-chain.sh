#!/usr/bin/env bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Hash-chain logging utility for CH4rch Linux build and audit events.
# Implements an append-only ledger: H_n = HASH(H_{n-1} || record_n)
# FIX: Added external anchor (git-commit), verification, and status commands.

set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "$0")/build.conf"

CHAIN_FILE="${CH4RCH_BUILDROOT:-/var/ch4rch-build}/audit-chain.log"
ANCHOR_REPO="${CH4RCH_ANCHOR_REPO:-$CH4RCH_SRC/.audit-anchor}"

# Ensure directory exists
mkdir -p "$(dirname "$CHAIN_FILE")"

# Initialize chain file with genesis block if it doesn't exist
if [[ ! -f "$CHAIN_FILE" ]]; then
    echo "GENESIS $(date -u +%Y-%m-%dT%H:%M:%SZ) CH4rch-Linux-Trust-Chain-Init" > "$CHAIN_FILE"
fi

# Hash function with fallback
compute_hash() {
    local data="$1"
    if command -v sha3-256sum &> /dev/null; then
        echo -n "$data" | sha3-256sum | awk '{print $1}'
    else
        echo -n "$data" | sha256sum | awk '{print $1}'
    fi
}

# Append record to chain (default behavior)
append_record() {
    local record="$*"
    local prev_hash
    prev_hash=$(tail -n 1 "$CHAIN_FILE" | awk '{print $1}')
    
    local current_hash
    current_hash=$(compute_hash "${prev_hash}${record}")
    
    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    
    echo "${current_hash} ${timestamp} ${record}" >> "$CHAIN_FILE"
    echo "[CH4RCH] Audit record appended. Hash: ${current_hash}"
}

# Anchor: publish last hash to external git repository
anchor() {
    echo "[CH4RCH] Anchoring chain to external repository..."
    
    local last_hash
    last_hash=$(tail -n 1 "$CHAIN_FILE" | awk '{print $1}')
    local last_timestamp
    last_timestamp=$(tail -n 1 "$CHAIN_FILE" | awk '{print $2}')
    
    # Initialize anchor repo if not exists
    if [[ ! -d "$ANCHOR_REPO/.git" ]]; then
        mkdir -p "$ANCHOR_REPO"
        git -C "$ANCHOR_REPO" init --quiet
        git -C "$ANCHOR_REPO" config user.email "audit@ch4rch.local"
        git -C "$ANCHOR_REPO" config user.name "CH4RCH Audit"
    fi
    
    # Write anchor file
    local anchor_file="$ANCHOR_REPO/anchor.txt"
    echo "${last_hash} ${last_timestamp}" > "$anchor_file"
    
    # Commit anchor
    git -C "$ANCHOR_REPO" add anchor.txt
    git -C "$ANCHOR_REPO" commit -m "Anchor: ${last_hash} @ ${last_timestamp}" --quiet
    
    local commit_hash
    commit_hash=$(git -C "$ANCHOR_REPO" rev-parse HEAD)
    
    echo "[CH4RCH] Chain anchored to git commit: ${commit_hash}"
    echo "[CH4RCH] Anchor hash: ${last_hash}"
}

# Verify: check chain integrity and compare with anchor
verify() {
    echo "[CH4RCH] Verifying chain integrity..."
    
    local prev_hash="GENESIS"
    local line_num=0
    local failed=0
    
    while IFS= read -r line; do
        ((line_num++)) || true
        
        # Skip genesis line
        if [[ $line_num -eq 1 ]]; then
            if [[ ! "$line" =~ ^GENESIS ]]; then
                echo "FAIL: Line 1 is not GENESIS"
                failed=1
                break
            fi
            continue
        fi
        
        # Parse line
        local hash timestamp record
        hash=$(echo "$line" | awk '{print $1}')
        timestamp=$(echo "$line" | awk '{print $2}')
        record=$(echo "$line" | cut -d' ' -f3-)
        
        # Compute expected hash
        local expected_hash
        expected_hash=$(compute_hash "${prev_hash}${record}")
        
        if [[ "$hash" != "$expected_hash" ]]; then
            echo "FAIL: Integrity check failed at line $line_num"
            echo "  Expected: ${expected_hash}"
            echo "  Found:    ${hash}"
            failed=1
            break
        fi
        
        prev_hash="$hash"
    done < "$CHAIN_FILE"
    
    if [[ $failed -eq 1 ]]; then
        echo "[CH4RCH] INTEGRITY CHECK FAILED - chain has been tampered with!"
        exit 1
    fi
    
    echo "[CH4RCH] Chain integrity verified (all hashes match)"
    
    # Compare with anchor if exists
    if [[ -f "$ANCHOR_REPO/anchor.txt" ]]; then
        local anchor_hash
        anchor_hash=$(awk '{print $1}' "$ANCHOR_REPO/anchor.txt")
        local current_hash
        current_hash=$(tail -n 1 "$CHAIN_FILE" | awk '{print $1}')
        
        if [[ "$anchor_hash" == "$current_hash" ]]; then
            echo "[CH4RCH] Chain matches external anchor ✓"
        else
            echo "[CH4RCH] WARNING: Chain does not match anchor"
            echo "  Anchor:   ${anchor_hash}"
            echo "  Current:  ${current_hash}"
            echo "[CH4RCH] Run 'hash-chain.sh anchor' to update anchor"
        fi
    else
        echo "[CH4RCH] No external anchor found. Run 'hash-chain.sh anchor' to create one."
    fi
}

# Status: show current chain state
status() {
    echo "[CH4RCH] Hash-chain status:"
    echo "  Chain file: $CHAIN_FILE"
    
    if [[ -f "$CHAIN_FILE" ]]; then
        local record_count
        record_count=$(wc -l < "$CHAIN_FILE")
        echo "  Records: $record_count"
        
        local last_hash
        last_hash=$(tail -n 1 "$CHAIN_FILE" | awk '{print $1}')
        echo "  Last hash: ${last_hash}"
        
        local last_timestamp
        last_timestamp=$(tail -n 1 "$CHAIN_FILE" | awk '{print $2}')
        echo "  Last record: ${last_timestamp}"
    else
        echo "  Chain file does not exist"
    fi
    
    if [[ -f "$ANCHOR_REPO/anchor.txt" ]]; then
        local anchor_hash
        anchor_hash=$(awk '{print $1}' "$ANCHOR_REPO/anchor.txt")
        echo "  Anchor hash: ${anchor_hash}"
        
        if [[ -d "$ANCHOR_REPO/.git" ]]; then
            local anchor_commit
            anchor_commit=$(git -C "$ANCHOR_REPO" rev-parse HEAD 2>/dev/null || echo "unknown")
            echo "  Anchor commit: ${anchor_commit}"
        fi
    else
        echo "  No external anchor"
    fi
}

# Main command dispatcher
case "${1:-}" in
    anchor)
        anchor
        ;;
    verify)
        verify
        ;;
    status)
        status
        ;;
    *)
        # Default behavior: append record
        append_record "$@"
        ;;
esac