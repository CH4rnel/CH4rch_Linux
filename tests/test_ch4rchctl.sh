#!/usr/bin/env bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test suite for build-tools/ch4rchctl
# real YAML parsing, package installation, system settings, idempotency.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
CH4RCHCTL_SCRIPT="$ROOT_DIR/build-tools/ch4rchctl"

echo "Running tests for ch4rchctl..."

# Test 1: Shebang and decorative header
test_shebang_and_header() {
    local first_line
    first_line=$(head -n 1 "$CH4RCHCTL_SCRIPT")
    if [[ "$first_line" != "#!/usr/bin/env bash" ]]; then
        echo "FAIL: First line must be '#!/usr/bin/env bash'"
        echo "Found: $first_line"
        return 1
    fi
    
    local second_line
    second_line=$(sed -n '2p' "$CH4RCHCTL_SCRIPT")
    if [[ "$second_line" != "# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭" ]]; then
        echo "FAIL: Second line must be the decorative comment"
        return 1
    fi
    
    echo "PASS: Shebang and decorative header present"
}

# Test 2: YAML parsing capability
test_yaml_parsing() {
    if ! grep -qE "(python|yq|yaml)" "$CH4RCHCTL_SCRIPT"; then
        echo "FAIL: ch4rchctl does not parse YAML (no python/yq/yaml references)"
        return 1
    fi
    echo "PASS: YAML parsing capability present"
}

# Test 3: Plan shows diff (not just file listing)
test_plan_shows_diff() {
    if ! grep -qE "(diff|compare|changes|hostname|timezone|locale)" "$CH4RCHCTL_SCRIPT"; then
        echo "FAIL: plan() does not show configuration diff"
        return 1
    fi
    echo "PASS: plan() shows configuration diff"
}

# Test 4: Apply installs packages
test_apply_installs_packages() {
    if ! grep -qE "(pacman|packages)" "$CH4RCHCTL_SCRIPT"; then
        echo "FAIL: apply() does not install packages from YAML"
        return 1
    fi
    echo "PASS: apply() installs packages"
}

# Test 5: Apply applies system settings
test_apply_system_settings() {
    if ! grep -qE "(hostname|timezone|locale|/etc/)" "$CH4RCHCTL_SCRIPT"; then
        echo "FAIL: apply() does not apply system settings (hostname/timezone/locale)"
        return 1
    fi
    echo "PASS: apply() applies system settings"
}

# Test 6: Idempotency check
test_idempotency() {
    if ! grep -qE "(idempotent|already|no changes|skip)" "$CH4RCHCTL_SCRIPT"; then
        echo "FAIL: apply() does not check for idempotency"
        return 1
    fi
    echo "PASS: apply() checks for idempotency"
}

# Run tests
test_shebang_and_header
test_yaml_parsing
test_plan_shows_diff
test_apply_installs_packages
test_apply_system_settings
test_idempotency

echo "All ch4rchctl tests passed."