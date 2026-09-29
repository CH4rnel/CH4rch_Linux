#!/usr/bin/env bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test suite for s6-rc bundle consistency.
# Validates: single source of truth in s6-services/, all services exist, dependencies are valid.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
S6RC_SOURCE="$ROOT_DIR/s6-services/source"

echo "Running tests for s6-rc bundle consistency..."

# Test 1: Single source of truth — no duplicates in rootfs-overlay
test_single_source() {
    if [[ -d "$ROOT_DIR/rootfs-overlay/etc/s6-rc/source" ]]; then
        echo "FAIL: duplicate s6-rc source exists in rootfs-overlay/etc/s6-rc/source/"
        return 1
    fi
    echo "PASS: single source of truth (s6-services/source/)"
}

# Test 2: All services listed in base/contents physically exist
test_services_exist() {
    local contents_file="$S6RC_SOURCE/base/contents"
    if [[ ! -f "$contents_file" ]]; then
        echo "FAIL: base/contents not found in s6-services/source/"
        return 1
    fi

    local failed=0
    while IFS= read -r service; do
        [[ "$service" =~ ^#.*$ || -z "$service" ]] && continue

        if [[ ! -d "$S6RC_SOURCE/$service" ]]; then
            echo "FAIL: service '$service' listed in base/contents but directory does not exist"
            failed=1
        fi
    done < "$contents_file"

    if [[ $failed -eq 1 ]]; then
        return 1
    fi
    echo "PASS: all services in base/contents exist"
}

# Test 3: Dependencies reference valid services (not types like 'longrun')
test_valid_dependencies() {
    local known_types=("bundle" "longrun" "oneshot")
    local failed=0

    for dep_file in "$S6RC_SOURCE"/*/dependencies; do
        [[ ! -f "$dep_file" ]] && continue
        local service_name
        service_name=$(basename "$(dirname "$dep_file")")

        while IFS= read -r dep; do
            [[ "$dep" =~ ^#.*$ || -z "$dep" ]] && continue

            for t in "${known_types[@]}"; do
                if [[ "$dep" == "$t" ]]; then
                    echo "FAIL: $service_name/dependencies contains '$t' which is an s6-rc type, not a service"
                    failed=1
                fi
            done

            if [[ ! -d "$S6RC_SOURCE/$dep" ]]; then
                echo "FAIL: $service_name depends on '$dep' which does not exist"
                failed=1
            fi
        done < "$dep_file"
    done

    if [[ $failed -eq 1 ]]; then
        return 1
    fi
    echo "PASS: all dependencies reference valid services"
}

# Test 4: bootstrap-init.sh uses s6-services/source/
test_bootstrap_integration() {
    if ! grep -q "s6-services/source" "$ROOT_DIR/build-tools/bootstrap-init.sh"; then
        echo "FAIL: bootstrap-init.sh does not reference s6-services/source/"
        return 1
    fi
    echo "PASS: bootstrap-init.sh uses s6-services/source/"
}

# Test 5: bootstrap-init.sh uses correct shebang
test_bootstrap_shebang() {
    local first_line
    first_line=$(head -n 1 "$ROOT_DIR/build-tools/bootstrap-init.sh")
    if [[ "$first_line" != "#!/usr/bin/env bash" ]]; then
        echo "FAIL: bootstrap-init.sh shebang is '$first_line', expected '#!/usr/bin/env bash'"
        return 1
    fi
    echo "PASS: bootstrap-init.sh uses portable shebang"
}

# Run tests
test_single_source
test_services_exist
test_valid_dependencies
test_bootstrap_integration
test_bootstrap_shebang

echo "All s6-rc bundle tests passed."