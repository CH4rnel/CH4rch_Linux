#!/usr/bin/env bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test suite Agent Profile schema consistency and enforcement.
# Validates single schema across all profiles, no dangling references, enforcer exists.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
PROFILES_DIR="$ROOT_DIR/profiles"
ENFORCER_SCRIPT="$ROOT_DIR/build-tools/profile-enforcer.sh"

echo "Running tests for P2-3 agent profiles..."

FAILED=0

# Test 1: All profiles have isolation.backend field
test_isolation_backend() {
    for profile in "$PROFILES_DIR"/*.yaml; do
        [ -f "$profile" ] || continue
        if ! grep -q "^  backend:" "$profile"; then
            echo "FAIL: $(basename "$profile") missing isolation.backend"
            FAILED=1
        fi
    done
    [[ $FAILED -eq 0 ]] && echo "PASS: all profiles have isolation.backend"
}

# Test 2: All profiles have isolation.privilege field
test_isolation_privilege() {
    for profile in "$PROFILES_DIR"/*.yaml; do
        [ -f "$profile" ] || continue
        if ! grep -q "^  privilege:" "$profile"; then
            echo "FAIL: $(basename "$profile") missing isolation.privilege"
            FAILED=1
        fi
    done
    [[ $FAILED -eq 0 ]] && echo "PASS: all profiles have isolation.privilege"
}

# Test 3: All profiles have isolation.network field
test_isolation_network() {
    for profile in "$PROFILES_DIR"/*.yaml; do
        [ -f "$profile" ] || continue
        if ! grep -q "^  network:" "$profile"; then
            echo "FAIL: $(basename "$profile") missing isolation.network"
            FAILED=1
        fi
    done
    [[ $FAILED -eq 0 ]] && echo "PASS: all profiles have isolation.network"
}

# Test 4: No incompatible fields (restrictions, sandbox_profile)
test_no_incompatible_fields() {
    for profile in "$PROFILES_DIR"/*.yaml; do
        [ -f "$profile" ] || continue
        if grep -qE "^(restrictions|sandbox_profile):" "$profile"; then
            echo "FAIL: $(basename "$profile") has incompatible field (restrictions/sandbox_profile)"
            FAILED=1
        fi
    done
    [[ $FAILED -eq 0 ]] && echo "PASS: no incompatible fields in profiles"
}

# Test 5: All profiles have enabled field (default false)
test_enabled_field() {
    for profile in "$PROFILES_DIR"/*.yaml; do
        [ -f "$profile" ] || continue
        if ! grep -q "^enabled:" "$profile"; then
            echo "FAIL: $(basename "$profile") missing enabled field"
            FAILED=1
        fi
    done
    [[ $FAILED -eq 0 ]] && echo "PASS: all profiles have enabled field"
}

# Test 6: Capabilities use structured format (id + risk)
test_capabilities_structure() {
    for profile in "$PROFILES_DIR"/*.yaml; do
        [ -f "$profile" ] || continue
        # Check for structured capabilities (not plain strings)
        if grep -q "^  - \"" "$profile" && grep -q "capabilities:" "$profile"; then
            echo "FAIL: $(basename "$profile") uses plain string capabilities instead of structured format"
            FAILED=1
        fi
    done
    [[ $FAILED -eq 0 ]] && echo "PASS: capabilities use structured format"
}

# Test 7: profile-enforcer.sh exists and is executable
test_enforcer_exists() {
    if [[ ! -x "$ENFORCER_SCRIPT" ]]; then
        echo "FAIL: profile-enforcer.sh does not exist or is not executable"
        FAILED=1
        return 1
    fi
    echo "PASS: profile-enforcer.sh exists and is executable"
}

# Test 8: profile-enforcer.sh uses python for YAML parsing
test_enforcer_yaml_parsing() {
    if ! grep -qE "(python|yaml)" "$ENFORCER_SCRIPT"; then
        echo "FAIL: profile-enforcer.sh does not parse YAML"
        FAILED=1
        return 1
    fi
    echo "PASS: profile-enforcer.sh parses YAML"
}

# Run tests
test_isolation_backend
test_isolation_privilege
test_isolation_network
test_no_incompatible_fields
test_enabled_field
test_capabilities_structure
test_enforcer_exists
test_enforcer_yaml_parsing

if [[ $FAILED -eq 1 ]]; then
    echo ""
    echo "Some P2-3 tests FAILED."
    exit 1
fi

echo "All P2-3 agent profile tests passed."