#!/bin/bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Process isolation utility for CH4rch Linux.
# Implements ADR-07: lightweight sandboxing via bubblewrap (bwrap).

set -e

source "$(dirname "$0")/build.conf"

run_sandboxed() {
    local cmd="$@"
    
    if ! command -v bwrap &> /dev/null; then
        echo "[CH4RCH] ERROR: bubblewrap (bwrap) not installed"
        echo "[CH4RCH] Install with: pacman -S bubblewrap"
        return 1
    fi
    
    echo "[CH4RCH] Running command in sandboxed environment..."
    
    # Basic bwrap sandbox configuration
    bwrap \
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
        -- $cmd
    
    echo "[CH4RCH] Sandboxed execution completed."
    
    # Log to hash-chain
    if [ -x "$CH4RCH_SRC/build-tools/hash-chain.sh" ]; then
        "$CH4RCH_SRC/build-tools/hash-chain.sh" "SANDBOX_EXEC cmd=$cmd"
    fi
}

# Main command dispatcher
case "${1:-}" in
    run)
        shift
        if [ -z "$*" ]; then
            echo "Usage: $0 run <command>"
            exit 1
        fi
        run_sandboxed "$@"
        ;;
    *)
        echo "Usage: $0 {run} [args]"
        echo "  run <command>  - Execute command in isolated sandbox"
        exit 1
        ;;
esac