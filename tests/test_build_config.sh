#!/bin/bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Test: Verify build.conf resolves paths correctly and is portable.

set -e

echo "Running build configuration tests..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="$SCRIPT_DIR/build-tools/build.conf"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "FAIL: build.conf not found at $CONFIG_FILE"
    exit 1
fi

# Check for mandatory header
if ! grep -q "𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭" "$CONFIG_FILE"; then
    echo "FAIL: Mandatory header missing in build.conf"
    exit 1
fi

# Check that CH4RCH_SRC is NOT hardcoded to $HOME
if grep -q 'CH4RCH_SRC="\$HOME' "$CONFIG_FILE"; then
    echo "FAIL: CH4RCH_SRC is hardcoded to \$HOME, breaking portability."
    exit 1
fi

# Check that dynamic resolution is present
if ! grep -q 'CH4RCH_SRC=".*(dirname.*BASH_SOURCE' "$CONFIG_FILE"; then
    echo "FAIL: Dynamic CH4RCH_SRC resolution not found."
    exit 1
fi

echo "PASS: Build configuration is portable and correctly formatted."
exit 0