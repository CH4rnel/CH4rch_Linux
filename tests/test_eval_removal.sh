#!/usr/bin/env bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test suite for verify eval removal and bash array usage.
# Validates no eval in security-critical scripts, proper array-based execution.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "Running tests for P2-2 eval removal..."

FAILED=0

# Test 1: No eval in microvm-launch.sh
test_no_eval_microvm() {
    local script="$ROOT_DIR/build-tools/microvm-launch.sh"
    if grep -nE '^\s*eval\s' "$script"; then
        echo "FAIL: microvm-launch.sh still uses eval (P2-2 violation)"
        FAILED=1
        return 1
    fi
    echo "PASS: microvm-launch.sh has no eval"
}

# Test 2: No eval in gui-isolate.sh
test_no_eval_gui() {
    local script="$ROOT_DIR/build-tools/gui-isolate.sh"
    if grep -nE '^\s*eval\s' "$script"; then
        echo "FAIL: gui-isolate.sh still uses eval (P2-2 violation)"
        FAILED=1
        return 1
    fi
    echo "PASS: gui-isolate.sh has no eval"
}

# Test 3: microvm-launch.sh uses bash arrays
test_array_microvm() {
    local script="$ROOT_DIR/build-tools/microvm-launch.sh"
    if ! grep -qE 'CMD=\(' "$script"; then
        echo "FAIL: microvm-launch.sh does not use bash arrays for command construction"
        FAILED=1
        return 1
    fi
    if ! grep -qE '"\$\{CMD\[@\]\}"' "$script"; then
        echo "FAIL: microvm-launch.sh does not expand array with \"\${CMD[@]}\""
        FAILED=1
        return 1
    fi
    echo "PASS: microvm-launch.sh uses bash arrays"
}

# Test 4: gui-isolate.sh uses bash arrays
test_array_gui() {
    local script="$ROOT_DIR/build-tools/gui-isolate.sh"
    if ! grep -qE 'FULL_CMD=\(' "$script"; then
        echo "FAIL: gui-isolate.sh does not use bash arrays for command construction"
        FAILED=1
        return 1
    fi
    if ! grep -qE '"\$\{FULL_CMD\[@\]\}"' "$script"; then
        echo "FAIL: gui-isolate.sh does not expand array with \"\${FULL_CMD[@]}\""
        FAILED=1
        return 1
    fi
    echo "PASS: gui-isolate.sh uses bash arrays"
}

# Test 5: Both scripts use portable shebang
test_shebangs() {
    for script in "$ROOT_DIR/build-tools/microvm-launch.sh" "$ROOT_DIR/build-tools/gui-isolate.sh"; do
        local first_line
        first_line=$(head -n 1 "$script")
        if [[ "$first_line" != "#!/usr/bin/env bash" ]]; then
            echo "FAIL: $(basename "$script") shebang is '$first_line'"
            FAILED=1
            return 1
        fi
    done
    echo "PASS: both scripts use portable shebang"
}

# Test 6: No eval anywhere in build-tools/
test_no_eval_anywhere() {
    local count
    # Use '|| true' to prevent pipefail from exiting when grep finds nothing
    count=$(grep -rlE '^\s*eval\s' "$ROOT_DIR/build-tools/" --include="*.sh" 2>/dev/null | wc -l || true)
    # Normalize: trim whitespace
    count=$(echo "$count" | tr -d '[:space:]')
    
    if [[ "$count" -gt 0 ]]; then
        echo "FAIL: eval found in $count build-tools scripts:"
        grep -rlE '^\s*eval\s' "$ROOT_DIR/build-tools/" --include="*.sh" || true
        FAILED=1
        return 1
    fi
    echo "PASS: no eval in any build-tools script"
}

# Run tests
test_no_eval_microvm
test_no_eval_gui
test_array_microvm
test_array_gui
test_shebangs
test_no_eval_anywhere

if [[ $FAILED -eq 1 ]]; then
    echo ""
    echo "Some P2-2 tests FAILED."
    exit 1
fi

echo "All P2-2 eval removal tests passed."