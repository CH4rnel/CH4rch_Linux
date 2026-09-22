#!/bin/bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# NetVM Setup Utility for CH4rch Linux.
# Implements isolated network namespace with strict nftables default-drop policy.

set -e

# shellcheck disable=SC1091
source "$(dirname "$0")/build.conf"

NETVM_NS="ch4rch-netvm"
DRY_RUN="${DRY_RUN:-true}"

usage() {
    echo "Usage: $0 {create|destroy|status} [--run]"
    echo "  create   - Create isolated NetVM namespace and apply nftables rules"
    echo "  destroy  - Tear down the NetVM namespace"
    echo "  status   - Show current NetVM status"
    echo "  --run    - Actually execute (default is dry-run for safety)"
    exit 1
}

if [ "$2" = "--run" ]; then
    DRY_RUN="false"
fi

case "${1:-}" in
    create)
        echo "[CH4RCH] Setting up NetVM namespace: $NETVM_NS"
        if [ "$DRY_RUN" = "true" ]; then
            echo "[CH4RCH] DRY-RUN: Would execute:"
            echo "  ip netns add $NETVM_NS"
            echo "  ip link add veth-host type veth peer name veth-netvm netns $NETVM_NS"
            echo "  nft add table inet ch4rch_netvm"
            echo "  nft add chain inet ch4rch_netvm forward '{ type filter hook forward priority 0; policy drop; }'"
            echo "  [CH4RCH] Use --run to apply changes."
        else
            # Create namespace
            ip netns add "$NETVM_NS"
            
            # Create veth pair
            ip link add veth-host type veth peer name veth-netvm netns "$NETVM_NS"
            
            # Bring up host side
            ip link set veth-host up
            ip addr add 10.200.1.1/24 dev veth-host
            
            # Bring up netvm side
            ip netns exec "$NETVM_NS" ip link set lo up
            ip netns exec "$NETVM_NS" ip link set veth-netvm up
            ip netns exec "$NETVM_NS" ip addr add 10.200.1.2/24 dev veth-netvm
            
            # Apply strict nftables rules (default drop)
            nft add table inet ch4rch_netvm
            nft add chain inet ch4rch_netvm input '{ type filter hook input priority 0; policy drop; }'
            nft add rule inet ch4rch_netvm input iifname "veth-host" accept
            nft add chain inet ch4rch_netvm forward '{ type filter hook forward priority 0; policy drop; }'
            
            echo "[CH4RCH] NetVM namespace '$NETVM_NS' created with strict nftables policy."
            
            # Log to hash-chain
            if [ -x "$CH4RCH_SRC/build-tools/hash-chain.sh" ]; then
                "$CH4RCH_SRC/build-tools/hash-chain.sh" "NETVM_CREATE ns=$NETVM_NS policy=drop"
            fi
        fi
        ;;
    destroy)
        echo "[CH4RCH] Tearing down NetVM namespace: $NETVM_NS"
        if [ "$DRY_RUN" = "true" ]; then
            echo "[CH4RCH] DRY-RUN: Would execute:"
            echo "  ip netns delete $NETVM_NS"
            echo "  nft delete table inet ch4rch_netvm"
        else
            ip netns delete "$NETVM_NS" 2>/dev/null || true
            nft delete table inet ch4rch_netvm 2>/dev/null || true
            echo "[CH4RCH] NetVM namespace destroyed."
        fi
        ;;
    status)
        echo "[CH4RCH] NetVM Status:"
        if ip netns list | grep -q "$NETVM_NS"; then
            echo "  Namespace: ACTIVE"
            ip netns exec "$NETVM_NS" ip addr show veth-netvm 2>/dev/null | grep inet || echo "  IP: Not configured"
            echo "  Firewall:"
            nft list table inet ch4rch_netvm 2>/dev/null | grep "policy" || echo "  No nftables rules found"
        else
            echo "  Namespace: INACTIVE"
        fi
        ;;
    *)
        usage
        ;;
esac