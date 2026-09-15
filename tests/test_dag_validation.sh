#!/bin/bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test: Validate s6-rc service graph integrity (no dangling dependencies, all services defined).

set -e

echo "Running DAG validation tests..."

SOURCE_DIR="rootfs-overlay/etc/s6-rc/source"
BASE_CONTENTS="$SOURCE_DIR/base/contents"

# Test 1: Check that all services in base/contents exist
echo "[TEST] Checking base bundle services exist..."
while IFS= read -r service; do
    # Skip comments and empty lines
    [[ "$service" =~ ^#.*$ || -z "$service" ]] && continue
    
    if [ ! -d "$SOURCE_DIR/$service" ]; then
        echo "FAIL: Service '$service' listed in base/contents but directory missing."
        exit 1
    fi
done < "$BASE_CONTENTS"
echo "PASS: All base bundle services exist."

# Test 2: Check that each service has required files (type + run/up)
echo "[TEST] Checking service definitions..."
for service_dir in "$SOURCE_DIR"/*/; do
    service_name=$(basename "$service_dir")
    
    # Skip base bundle itself
    [ "$service_name" = "base" ] && continue
    
    if [ ! -f "$service_dir/type" ]; then
        echo "FAIL: Service '$service_name' missing 'type' file."
        exit 1
    fi
    
    service_type=$(cat "$service_dir/type")
    if [ "$service_type" = "longrun" ]; then
        if [ ! -f "$service_dir/run" ]; then
            echo "FAIL: Longrun service '$service_name' missing 'run' file."
            exit 1
        fi
    elif [ "$service_type" = "oneshot" ]; then
        if [ ! -f "$service_dir/up" ]; then
            echo "FAIL: Oneshot service '$service_name' missing 'up' file."
            exit 1
        fi
    elif [ "$service_type" = "bundle" ]; then
        if [ ! -f "$service_dir/contents" ]; then
            echo "FAIL: Bundle '$service_name' missing 'contents' file."
            exit 1
        fi
    else
        echo "FAIL: Service '$service_name' has unknown type '$service_type'."
        exit 1
    fi
done
echo "PASS: All services have required definition files."

# Test 3: Check that all dependencies point to existing services
echo "[TEST] Checking dependency references..."
for service_dir in "$SOURCE_DIR"/*/; do
    service_name=$(basename "$service_dir")
    deps_file="$service_dir/dependencies"
    
    [ -f "$deps_file" ] || continue
    
    while IFS= read -r dep; do
        [[ "$dep" =~ ^#.*$ || -z "$dep" ]] && continue
        
        if [ ! -d "$SOURCE_DIR/$dep" ]; then
            echo "FAIL: Service '$service_name' depends on '$dep', which does not exist."
            exit 1
        fi
    done < "$deps_file"
done
echo "PASS: All dependency references are valid."

echo "All DAG validation tests passed."
exit 0