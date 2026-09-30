#!/usr/bin/env bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test suite verify agent capabilities run in isolation.
# Validates all system commands go through isolate.sh, not direct execution.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
CAPABILITIES_SCRIPT="$ROOT_DIR/build-tools/ch4rch-agent-capabilities"

echo "Running tests for P2-5 capabilities isolation..."

FAILED=0

# Test 1: No direct pacman calls
test_no_direct_pacman() {
    if grep -nE '^\s*pacman\s' "$CAPABILITIES_SCRIPT" | grep -v "isolate.sh"; then
        echo "FAIL: Direct pacman calls found (should use isolate.sh)"
        FAILED=1
        return 1
    fi
    echo "PASS: No direct pacman calls"
}

# Test 2: No direct df calls
test_no_direct_df() {
    if grep -nE '^\s*df\s' "$CAPABILITIES_SCRIPT" | grep -v "isolate.sh"; then
        echo "FAIL: Direct df calls found (should use isolate.sh)"
        FAILED=1
        return 1
    fi
    echo "PASS: No direct df calls"
}

# Test 3: No direct ip calls
test_no_direct_ip() {
    if grep -nE '^\s*ip\s' "$CAPABILITIES_SCRIPT" | grep -v "isolate.sh"; then
        echo "FAIL: Direct ip calls found (should use isolate.sh)"
        FAILED=1
        return 1
    fi
    echo "PASS: No direct ip calls"
}

# Test 4: No direct ss calls
test_no_direct_ss() {
    if grep -nE '^\s*ss\s' "$CAPABILITIES_SCRIPT" | grep -v "isolate.sh"; then
        echo "FAIL: Direct ss calls found (should use isolate.sh)"
        FAILED=1
        return 1
    fi
    echo "PASS: No direct ss calls"
}

# Test 5: Uses isolate.sh
test_uses_isolate() {
    if ! grep -q "isolate.sh" "$CAPABILITIES_SCRIPT"; then
        echo "FAIL: Script does not use isolate.sh"
        FAILED=1
        return 1
    fi
    echo "PASS: Script uses isolate.sh"
}

# Test 6: Uses profile-enforcer.sh
test_uses_profile_enforcer() {
    if ! grep -q "profile-enforcer.sh" "$CAPABILITIES_SCRIPT"; then
        echo "FAIL: Script does not use profile-enforcer.sh"
        FAILED=1
        return 1
    fi
    echo "PASS: Script uses profile-enforcer.sh"
}

# Test 7: Portable shebang
test_shebang() {
    local first_line
    first_line=$(head -n 1 "$CAPABILITIES_SCRIPT")
    if [[ "$first_line" != "#!/usr/bin/env bash" ]]; then
        echo "FAIL: Shebang is '$first_line', expected '#!/usr/bin/env bash'"
        FAILED=1
        return 1
    fi
    echo "PASS: Portable shebang"
}

# Run tests
test_no_direct_pacman
test_no_direct_df
test_no_direct_ip
test_no_direct_ss
test_uses_isolate
test_uses_profile_enforcer
test_shebang

if [[ $FAILED -eq 1 ]]; then
    echo ""
    echo "Some P2-5 tests FAILED."
    exit 1
fi

echo "All P2-5 capabilities isolation tests passed."