#!/usr/bin/env bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test suite hash-chain external anchor and verification.
# Validates anchor command exists, verify detects tampering, status works.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
HASH_CHAIN_SCRIPT="$ROOT_DIR/build-tools/hash-chain.sh"

echo "Running tests for P2-4 hash-chain anchor..."

FAILED=0

# Test 1: Portable shebang
test_shebang() {
    local first_line
    first_line=$(head -n 1 "$HASH_CHAIN_SCRIPT")
    if [[ "$first_line" != "#!/usr/bin/env bash" ]]; then
        echo "FAIL: Shebang is '$first_line', expected '#!/usr/bin/env bash'"
        FAILED=1
        return 1
    fi
    echo "PASS: Portable shebang"
}

# Test 2: anchor command exists
test_anchor_command() {
    if ! grep -qE '^\s*anchor\(\)' "$HASH_CHAIN_SCRIPT"; then
        echo "FAIL: anchor() function not found"
        FAILED=1
        return 1
    fi
    if ! grep -qE 'anchor\)' "$HASH_CHAIN_SCRIPT"; then
        echo "FAIL: anchor case in dispatcher not found"
        FAILED=1
        return 1
    fi
    echo "PASS: anchor command exists"
}

# Test 3: verify command exists
test_verify_command() {
    if ! grep -qE '^\s*verify\(\)' "$HASH_CHAIN_SCRIPT"; then
        echo "FAIL: verify() function not found"
        FAILED=1
        return 1
    fi
    if ! grep -qE 'verify\)' "$HASH_CHAIN_SCRIPT"; then
        echo "FAIL: verify case in dispatcher not found"
        FAILED=1
        return 1
    fi
    echo "PASS: verify command exists"
}

# Test 4: status command exists
test_status_command() {
    if ! grep -qE '^\s*status\(\)' "$HASH_CHAIN_SCRIPT"; then
        echo "FAIL: status() function not found"
        FAILED=1
        return 1
    fi
    if ! grep -qE 'status\)' "$HASH_CHAIN_SCRIPT"; then
        echo "FAIL: status case in dispatcher not found"
        FAILED=1
        return 1
    fi
    echo "PASS: status command exists"
}

# Test 5: verify detects tampering
test_verify_detects_tampering() {
    # Create temporary directory for chain file
    local temp_dir
    temp_dir=$(mktemp -d)
    local chain_file="$temp_dir/audit-chain.log"
    
    # Write invalid chain (hashes don't match)
    cat > "$chain_file" << 'EOF'
GENESIS 2026-09-30T00:00:00Z CH4rch-Linux-Trust-Chain-Init
abc123 2026-09-30T00:01:00Z RECORD1
def456 2026-09-30T00:02:00Z RECORD2
EOF
    
    # Try to verify (should fail because hashes don't match)
    local output
    output=$(CH4RCH_BUILDROOT="$temp_dir" "$HASH_CHAIN_SCRIPT" verify 2>&1) || true
    
    if echo "$output" | grep -q "INTEGRITY CHECK FAILED"; then
        echo "PASS: verify detects tampering"
    else
        echo "FAIL: verify does not detect tampering"
        echo "Output was:"
        echo "$output"
        FAILED=1
    fi
    
    rm -rf "$temp_dir"
}

# Test 6: anchor uses git
test_anchor_uses_git() {
    if ! grep -qE "(git|anchor)" "$HASH_CHAIN_SCRIPT"; then
        echo "FAIL: anchor does not use git"
        FAILED=1
        return 1
    fi
    echo "PASS: anchor uses git for external anchor"
}

# Run tests
test_shebang
test_anchor_command
test_verify_command
test_status_command
test_verify_detects_tampering
test_anchor_uses_git

if [[ $FAILED -eq 1 ]]; then
    echo ""
    echo "Some P2-4 tests FAILED."
    exit 1
fi

echo "All P2-4 hash-chain anchor tests passed."