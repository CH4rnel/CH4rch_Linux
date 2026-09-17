#!/bin/bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test: Verify all bash scripts in build-tools pass syntax check.

set -e

echo "Running CI linting tests..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_TOOLS_DIR="$SCRIPT_DIR/build-tools"

# Test 1: Check syntax of all .sh files and scripts without extension
echo "[TEST] Checking bash syntax in build-tools..."
find "$BUILD_TOOLS_DIR" -type f \( -name "*.sh" -o -name "ch4rchctl" \) | while read -r script; do
    # Skip empty files or directories
    [ -f "$script" ] || continue
    
    if ! bash -n "$script" 2>/dev/null; then
        echo "FAIL: Syntax error in $script"
        exit 1
    fi
done
echo "PASS: All build-tools scripts have valid bash syntax."

echo "All CI linting tests passed."
exit 0