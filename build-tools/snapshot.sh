#!/bin/bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Btrfs snapshot management utility for CH4rch Linux rollback mechanism.
# Implements ADR-03: rollback via btrfs snapshots, not secondary package store.

set -e

source "$(dirname "$0")/build.conf"

SNAPSHOT_DIR="${CH4RCH_BUILDROOT:-/var/ch4rch-build}/snapshots"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

# Ensure snapshot directory exists
mkdir -p "$SNAPSHOT_DIR"

create_snapshot() {
    local name="${1:-auto-$TIMESTAMP}"
    local snapshot_path="$SNAPSHOT_DIR/$name"
    
    echo "[CH4RCH] Creating snapshot: $name"
    
    # For MVP: create a tarball of the rootfs as a "snapshot"
    # In production, this would use btrfs subvolume snapshot
    if [ -d "$CH4RCH_ROOTFS" ]; then
        tar -czf "$snapshot_path.tar.gz" -C "$CH4RCH_ROOTFS" . 2>/dev/null || {
            echo "[CH4RCH] WARNING: Failed to create snapshot archive"
            return 1
        }
        echo "[CH4RCH] Snapshot created: $snapshot_path.tar.gz"
        
        # Log to hash-chain
        if [ -x "$CH4RCH_SRC/build-tools/hash-chain.sh" ]; then
            "$CH4RCH_SRC/build-tools/hash-chain.sh" "SNAPSHOT_CREATE name=$name size=$(du -h "$snapshot_path.tar.gz" | cut -f1)"
        fi
    else
        echo "[CH4RCH] ERROR: Rootfs directory not found at $CH4RCH_ROOTFS"
        return 1
    fi
}

list_snapshots() {
    echo "[CH4RCH] Available snapshots:"
    if [ -d "$SNAPSHOT_DIR" ]; then
        ls -lh "$SNAPSHOT_DIR"/*.tar.gz 2>/dev/null || echo "No snapshots found."
    else
        echo "Snapshot directory does not exist."
    fi
}

rollback_snapshot() {
    local name="$1"
    local snapshot_path="$SNAPSHOT_DIR/$name.tar.gz"
    
    if [ ! -f "$snapshot_path" ]; then
        echo "[CH4RCH] ERROR: Snapshot '$name' not found at $snapshot_path"
        return 1
    fi
    
    echo "[CH4RCH] Rolling back to snapshot: $name"
    echo "[CH4RCH] WARNING: This will replace the current rootfs!"
    
    # Backup current rootfs before rollback
    if [ -d "$CH4RCH_ROOTFS" ]; then
        local backup_name="pre-rollback-$TIMESTAMP"
        echo "[CH4RCH] Creating pre-rollback backup: $backup_name"
        create_snapshot "$backup_name" > /dev/null 2>&1
    fi
    
    # Clean current rootfs
    rm -rf "$CH4RCH_ROOTFS"
    mkdir -p "$CH4RCH_ROOTFS"
    
    # Restore from snapshot
    tar -xzf "$snapshot_path" -C "$CH4RCH_ROOTFS" 2>/dev/null || {
        echo "[CH4RCH] ERROR: Failed to restore snapshot"
        return 1
    }
    
    echo "[CH4RCH] Rollback completed successfully."
    
    # Log to hash-chain
    if [ -x "$CH4RCH_SRC/build-tools/hash-chain.sh" ]; then
        "$CH4RCH_SRC/build-tools/hash-chain.sh" "SNAPSHOT_ROLLBACK name=$name"
    fi
}

# Main command dispatcher
case "${1:-}" in
    create)
        create_snapshot "${2:-}"
        ;;
    list)
        list_snapshots
        ;;
    rollback)
        if [ -z "${2:-}" ]; then
            echo "Usage: $0 rollback <snapshot-name>"
            exit 1
        fi
        rollback_snapshot "$2"
        ;;
    *)
        echo "Usage: $0 {create|list|rollback} [args]"
        echo "  create [name]     - Create a new snapshot"
        echo "  list              - List available snapshots"
        echo "  rollback <name>   - Rollback to specified snapshot"
        exit 1
        ;;
esac