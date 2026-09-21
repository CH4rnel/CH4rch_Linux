#!/usr/bin/env bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test suite for build-tools/isolate.sh
# Validates P2-1/P2-2 fixes: array usage, security flags, and shellcheck compliance.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
ISOLATE_SCRIPT="$ROOT_DIR/build-tools/isolate.sh"

echo "Running tests for isolate.sh..."

# Test 1: Syntax check via shellcheck (MANDATORY)
test_syntax() {
    if ! command -v shellcheck &> /dev/null; then
        echo "FAIL: shellcheck is not installed."
        return 1
    fi
    if ! shellcheck -x "$ISOLATE_SCRIPT"; then
        echo "FAIL: shellcheck found issues in isolate.sh"
        return 1
    fi
    echo "PASS: Syntax check (shellcheck)"
}

# Test 2: Verify word-splitting protection (P2-2 fix)
test_word_splitting_protection() {
    local mock_dir="$SCRIPT_DIR/mocks_$$"
    mkdir -p "$mock_dir/build-tools"

    # Mock bwrap to capture arguments exactly as passed
    # Use EOF (not 'EOF') so $mock_dir is substituted at creation time
    cat << EOF > "$mock_dir/bwrap"
#!/usr/bin/env bash
printf "%s\n" "\$@" > "$mock_dir/bwrap_args.txt"
EOF
    chmod +x "$mock_dir/bwrap"

    # Mock hash-chain in the expected location (\$CH4RCH_SRC/build-tools/)
    cat << EOF > "$mock_dir/build-tools/hash-chain.sh"
#!/usr/bin/env bash
exit 0
EOF
    chmod +x "$mock_dir/build-tools/hash-chain.sh"

    # Run isolate with arguments containing spaces
    # CH4RCH_SRC must point to mock_dir so isolate.sh finds mock hash-chain.sh
    if ! PATH="$mock_dir:$PATH" CH4RCH_SRC="$mock_dir" "$ISOLATE_SCRIPT" run echo "hello world" "arg with spaces"; then
        echo "FAIL: isolate.sh exited with error."
        rm -rf "$mock_dir"
        return 1
    fi

    local args_file="$mock_dir/bwrap_args.txt"
    if [[ ! -f "$args_file" ]]; then
        echo "FAIL: bwrap mock was not called."
        rm -rf "$mock_dir"
        return 1
    fi

    # Check if arguments are preserved exactly (no word splitting)
    if ! grep -q "hello world" "$args_file" || ! grep -q "arg with spaces" "$args_file"; then
        echo "FAIL: Word splitting occurred or arguments were lost (P2-2 violation)."
        echo "Captured bwrap arguments:"
        cat "$args_file"
        rm -rf "$mock_dir"
        return 1
    fi

    rm -rf "$mock_dir"
    echo "PASS: Word splitting protection (array usage)"
}

# Test 3: Verify security flags for fakeroot model (P2-1 fix)
test_security_flags() {
    local mock_dir="$SCRIPT_DIR/mocks_sec_$$"
    mkdir -p "$mock_dir/build-tools"

    cat << EOF > "$mock_dir/bwrap"
#!/usr/bin/env bash
printf "%s\n" "\$@" > "$mock_dir/bwrap_args.txt"
EOF
    chmod +x "$mock_dir/bwrap"

    cat << EOF > "$mock_dir/build-tools/hash-chain.sh"
#!/usr/bin/env bash
exit 0
EOF
    chmod +x "$mock_dir/build-tools/hash-chain.sh"

    if ! PATH="$mock_dir:$PATH" CH4RCH_SRC="$mock_dir" "$ISOLATE_SCRIPT" run echo "test"; then
        echo "FAIL: isolate.sh exited with error."
        rm -rf "$mock_dir"
        return 1
    fi

    local args_file="$mock_dir/bwrap_args.txt"
    if [[ ! -f "$args_file" ]]; then
        echo "FAIL: bwrap mock was not called."
        rm -rf "$mock_dir"
        return 1
    fi

    if ! grep -q -- "--unshare-user" "$args_file"; then
        echo "FAIL: --unshare-user flag is missing (P2-1 violation). Fakeroot model not enforced."
        rm -rf "$mock_dir"
        return 1
    fi

    # Check for --cap-drop followed by ALL (they are separate arguments)
    if ! grep -q -- "--cap-drop" "$args_file"; then
        echo "FAIL: --cap-drop flag is missing (P2-1 violation). Capabilities not dropped."
        rm -rf "$mock_dir"
        return 1
    fi

    # Verify ALL is present (as the value for --cap-drop)
    if ! grep -q "^ALL$" "$args_file"; then
        echo "FAIL: 'ALL' value for --cap-drop is missing (P2-1 violation)."
        rm -rf "$mock_dir"
        return 1
    fi

    rm -rf "$mock_dir"
    echo "PASS: Security flags present (fakeroot model)"
}

# Run tests
test_syntax
test_word_splitting_protection
test_security_flags

echo "All isolate.sh tests passed."