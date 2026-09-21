#!/usr/bin/env bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Process isolation utility for CH4rch Linux.
# Implements ADR-07: lightweight sandboxing via bubblewrap (bwrap).
# Fixes P2-1/P2-2: Prevents shell injection via proper bash array handling
# and enforces fakeroot/unprivileged model via user namespaces and capability dropping.

set -euo pipefail

# shellcheck source=/dev/null
source "$(dirname "$0")/build.conf"

run_sandboxed() {
    # P2-2 FIX: Use array to prevent word splitting and globbing vulnerabilities
    local cmd_array=("$@")

    if ! command -v bwrap &> /dev/null; then
        echo "[CH4RCH] ERROR: bubblewrap (bwrap) not installed" >&2
        echo "[CH4RCH] Install with: pacman -S bubblewrap" >&2
        return 1
    fi

    echo "[CH4RCH] Running command in sandboxed environment..." >&2

    # P2-1 FIX: Added --unshare-user, uid/gid mapping, and --cap-drop ALL
    # to enforce the declared "fakeroot" and unprivileged isolation model.
    # Inside the namespace, UID 0 is mapped to the real user, preventing privilege escalation.
    bwrap \
        --unshare-user \
        --uid-map "0:$(id -u):1" \
        --gid-map "0:$(id -g):1" \
        --cap-drop ALL \
        --ro-bind /usr /usr \
        --ro-bind /lib /lib \
        --ro-bind /lib64 /lib64 \
        --ro-bind /bin /bin \
        --ro-bind /sbin /sbin \
        --dev /dev \
        --proc /proc \
        --tmpfs /tmp \
        --tmpfs /var/log \
        --unshare-pid \
        --unshare-net \
        --die-with-parent \
        -- "${cmd_array[@]}"

    local exit_code=$?
    echo "[CH4RCH] Sandboxed execution completed with exit code $exit_code." >&2

    # Log to hash-chain safely
    if [[ -x "${CH4RCH_SRC:-}/build-tools/hash-chain.sh" ]]; then
        # Safely serialize array to string for logging using printf %q
        local cmd_str
        printf -v cmd_str "%q " "${cmd_array[@]}"
        "${CH4RCH_SRC}/build-tools/hash-chain.sh" "SANDBOX_EXEC cmd=$cmd_str" || true
    fi

    return $exit_code
}

# Main command dispatcher
case "${1:-}" in
    run)
        shift
        if [[ $# -eq 0 ]]; then
            echo "Usage: $0 run <command> [args...]" >&2
            exit 1
        fi
        run_sandboxed "$@"
        ;;
    *)
        echo "Usage: $0 {run} [args]" >&2
        echo "  run <command>  - Execute command in isolated sandbox" >&2
        exit 1
        ;;
esac