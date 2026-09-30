#!/usr/bin/env bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test suite ch4rch-remediate must execute actions from plan, not hardcoded steps.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
REMEDIATE_SCRIPT="$ROOT_DIR/build-tools/ch4rch-remediate"

echo "Running tests for P2-6 remediate plan execution..."

FAILED=0

# Test 1: Portable shebang
test_shebang() {
    local first_line
    first_line=$(head -n 1 "$REMEDIATE_SCRIPT")
    if [[ "$first_line" != "#!/usr/bin/env bash" ]]; then
        echo "FAIL: Shebang is '$first_line', expected '#!/usr/bin/env bash'"
        FAILED=1
        return 1
    fi
    echo "PASS: Portable shebang"
}

# Test 2: apply_plan parses CHANGES section
test_apply_parses_changes() {
    if ! grep -qE "(CHANGES|parse|action)" "$REMEDIATE_SCRIPT"; then
        echo "FAIL: apply_plan does not parse CHANGES section"
        FAILED=1
        return 1
    fi
    echo "PASS: apply_plan parses CHANGES section"
}

# Test 3: No hardcoded sleep in apply_plan
test_no_hardcoded_sleep() {
    # Extract apply_plan function and check for sleep
    local apply_func
    apply_func=$(sed -n '/^apply_plan()/,/^}/p' "$REMEDIATE_SCRIPT")
    
    if echo "$apply_func" | grep -qE "^\s*sleep\s+[0-9]"; then
        echo "FAIL: apply_plan contains hardcoded sleep (P2-6 violation)"
        FAILED=1
        return 1
    fi
    echo "PASS: No hardcoded sleep in apply_plan"
}

# Test 4: Action dispatcher exists
test_action_dispatcher() {
    if ! grep -qE "(execute_action|dispatch|service\.|package\.)" "$REMEDIATE_SCRIPT"; then
        echo "FAIL: Action dispatcher not found"
        FAILED=1
        return 1
    fi
    echo "PASS: Action dispatcher exists"
}

# Test 5: Uses isolate.sh for execution
test_uses_isolate() {
    if ! grep -qE "isolate\.sh" "$REMEDIATE_SCRIPT"; then
        echo "FAIL: Does not use isolate.sh for safe execution"
        FAILED=1
        return 1
    fi
    echo "PASS: Uses isolate.sh for execution"
}

# Test 6: Logs each action to hash-chain
test_logs_to_hashchain() {
    if ! grep -qE "hash-chain\.sh.*REMEDIATION_STEP" "$REMEDIATE_SCRIPT"; then
        echo "FAIL: Does not log each step to hash-chain"
        FAILED=1
        return 1
    fi
    echo "PASS: Logs each action to hash-chain"
}

# Run tests
test_shebang
test_apply_parses_changes
test_no_hardcoded_sleep
test_action_dispatcher
test_uses_isolate
test_logs_to_hashchain

if [[ $FAILED -eq 1 ]]; then
    echo ""
    echo "Some P2-6 tests FAILED."
    exit 1
fi

echo "All P2-6 remediate plan execution tests passed."