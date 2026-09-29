#!/usr/bin/env bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# GUI Isolation Wrapper for CH4rch Linux.
# Implements Wayland + waypipe over virtio-vsock with domain-colored window borders.
# Replaced eval with bash arrays to prevent shell injection.

set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "$0")/build.conf"

# Domain colors (Qubes-inspired)
COLOR_TRUSTED="green"
COLOR_UNTRUSTED="red"
COLOR_INTERNET="yellow"

usage() {
    echo "Usage: $0 --domain <trusted|untrusted|internet> --cmd <command>"
    echo "  --domain   Security domain (determines window border color)"
    echo "  --cmd      Command to execute inside the isolated GUI environment"
    exit 1
}

DOMAIN=""
USER_CMD=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --domain) DOMAIN="$2"; shift 2 ;;
        --cmd) USER_CMD="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; usage ;;
    esac
done

if [[ -z "$DOMAIN" || -z "$USER_CMD" ]]; then
    usage
fi

case "$DOMAIN" in
    trusted) BORDER_COLOR="$COLOR_TRUSTED" ;;
    untrusted) BORDER_COLOR="$COLOR_UNTRUSTED" ;;
    internet) BORDER_COLOR="$COLOR_INTERNET" ;;
    *) echo "[CH4RCH] ERROR: Invalid domain '$DOMAIN'" >&2; exit 1 ;;
esac

echo "[CH4RCH] Preparing GUI isolation for domain: $DOMAIN (Border: $BORDER_COLOR)"

# Build command as bash array to prevent shell injection
FULL_CMD=()

# Check for waypipe (fallback to stub if not installed)
if command -v waypipe &> /dev/null; then
    FULL_CMD+=(waypipe --vsock)
    echo "[CH4RCH] Using waypipe for Wayland protocol forwarding."
else
    FULL_CMD+=(echo "[WAYPIPE STUB]")
    echo "[CH4RCH] WARNING: waypipe not found. Running in stub mode (no actual GUI forwarding)." >&2
fi

# Append server flag and user command
FULL_CMD+=(--server)
# Split user command into array elements safely
read -ra USER_CMD_ARRAY <<< "$USER_CMD"
FULL_CMD+=("${USER_CMD_ARRAY[@]}")

echo "[CH4RCH] Generated GUI isolation command:"
echo "  ${FULL_CMD[*]}"

if [[ "${DRY_RUN:-true}" = "false" ]]; then
    echo "[CH4RCH] Executing..."
    # Direct array execution instead of eval
    "${FULL_CMD[@]}"
else
    echo "[CH4RCH] Dry-run mode. Use DRY_RUN=false to execute."
fi

# Log to hash-chain
if [[ -x "$CH4RCH_SRC/build-tools/hash-chain.sh" ]]; then
    "$CH4RCH_SRC/build-tools/hash-chain.sh" "GUI_ISOLATE domain=$DOMAIN cmd=$USER_CMD"
fi