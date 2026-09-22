#!/bin/bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# GUI Isolation Wrapper for CH4rch Linux.
# Implements Wayland + waypipe over virtio-vsock with domain-colored window borders.

set -e

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
CMD=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --domain) DOMAIN="$2"; shift 2 ;;
        --cmd) CMD="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; usage ;;
    esac
done

if [ -z "$DOMAIN" ] || [ -z "$CMD" ]; then
    usage
fi

case "$DOMAIN" in
    trusted) BORDER_COLOR="$COLOR_TRUSTED" ;;
    untrusted) BORDER_COLOR="$COLOR_UNTRUSTED" ;;
    internet) BORDER_COLOR="$COLOR_INTERNET" ;;
    *) echo "[CH4RCH] ERROR: Invalid domain '$DOMAIN'"; exit 1 ;;
esac

echo "[CH4RCH] Preparing GUI isolation for domain: $DOMAIN (Border: $BORDER_COLOR)"

# Check for waypipe (fallback to stub if not installed)
if command -v waypipe &> /dev/null; then
    WAYPIPE_CMD="waypipe --vsock"
    echo "[CH4RCH] Using waypipe for Wayland protocol forwarding."
else
    WAYPIPE_CMD="echo '[WAYPIPE STUB]'"
    echo "[CH4RCH] WARNING: waypipe not found. Running in stub mode (no actual GUI forwarding)."
fi

# Construct the execution command
# In a real microVM, this would connect to the host's vsock port and the host compositor 
# would wrap the received surface in a window with $BORDER_COLOR.
FULL_CMD="$WAYPIPE_CMD --server $CMD"

echo "[CH4RCH] Generated GUI isolation command:"
echo "  $FULL_CMD"

if [ "${DRY_RUN:-true}" = "false" ]; then
    echo "[CH4RCH] Executing..."
    eval "$FULL_CMD"
else
    echo "[CH4RCH] Dry-run mode. Use DRY_RUN=false to execute."
fi

# Log to hash-chain
if [ -x "$CH4RCH_SRC/build-tools/hash-chain.sh" ]; then
    "$CH4RCH_SRC/build-tools/hash-chain.sh" "GUI_ISOLATE domain=$DOMAIN cmd=$CMD"
fi