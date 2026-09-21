#!/usr/bin/env bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# !Universal test: verifies that ALL bash scripts in the project!

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "Running universal shebang convention test..."

FAILED=0
CHECKED=0

# Find all .sh files in the project (excluding .git and tests/mocks)
while IFS= read -r -d '' file; do
    ((CHECKED++)) || true
    
    # Get relative path for cleaner output
    rel_path="${file#"$ROOT_DIR"/}"
    
    # Check line 1: must be a valid shebang
    line1=$(head -n 1 "$file")
    if [[ "$line1" != "#!/usr/bin/env bash" && "$line1" != "#!/bin/bash" ]]; then
        echo "FAIL: $rel_path — line 1 is not a valid shebang"
        echo "      Found: $line1"
        FAILED=1
        continue
    fi
    
    # Check line 2: must be the decorative comment
    line2=$(sed -n '2p' "$file")
    if [[ "$line2" != "# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭" ]]; then
        echo "FAIL: $rel_path — line 2 is not the decorative header"
        echo "      Found: $line2"
        FAILED=1
        continue
    fi
    
done < <(find "$ROOT_DIR" -name "*.sh" -type f \
    -not -path "*/.git/*" \
    -not -path "*/mocks*/*" \
    -not -path "*/test_rootfs_*" \
    -print0)

if [[ $FAILED -eq 1 ]]; then
    echo ""
    echo "FAILED: Some scripts violate the shebang convention."
    exit 1
fi

echo "PASS: All $CHECKED scripts follow the shebang convention"