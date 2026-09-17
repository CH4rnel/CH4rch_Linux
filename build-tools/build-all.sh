#!/bin/bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Main build orchestrator for CH4rch Linux.
# Executes the build pipeline in strict order: packages -> sign -> repo -> rootfs -> init -> config -> iso -> snapshot.

set -e

source "$(dirname "$0")/build.conf"

log() {
    echo "[CH4RCH] $1"
}

prepare_workspace() {
    log "Preparing workspace..."
    mkdir -p "$CH4RCH_WORK" "$CH4RCH_PKGDEST" "$CH4RCH_SRCDEST" \
             "$CH4RCH_REPO/$CH4RCH_ARCH" "$CH4RCH_LOGS" "$CH4RCH_ISO"
    
    # Clean previous rootfs to ensure a reproducible build
    rm -rf "$CH4RCH_ROOTFS"
    mkdir -p "$CH4RCH_ROOTFS"
}

prepare_workspace

log "Building packages..."
"$CH4RCH_SRC/build-tools/build-package.sh"

log "Signing packages..."
"$CH4RCH_SRC/build-tools/sign-packages.sh"

log "Syncing repository..."
"$CH4RCH_SRC/build-tools/repo-sync.sh"

log "Building rootfs..."
"$CH4RCH_SRC/build-tools/build-rootfs.sh"

log "Compiling init..."
"$CH4RCH_SRC/build-tools/bootstrap-init.sh"

# Apply declarative configuration
log "Applying declarative configuration..."
if [ -x "$CH4RCH_SRC/build-tools/ch4rchctl" ]; then
    "$CH4RCH_SRC/build-tools/ch4rchctl" apply || {
        log "WARNING: Configuration apply failed, but build continued."
    }
else
    log "WARNING: ch4rchctl not found, skipping configuration apply."
fi

log "Building ISO..."
"$CH4RCH_SRC/build-tools/build-iso.sh"

# Create snapshot after successful build
log "Creating build snapshot..."
if [ -x "$CH4RCH_SRC/build-tools/snapshot.sh" ]; then
    "$CH4RCH_SRC/build-tools/snapshot.sh" create "build-$(cat "$CH4RCH_SRC/VERSION")-$(date +%Y%m%d-%H%M%S)" 2>/dev/null || {
        log "WARNING: Snapshot creation failed, but build completed."
    }
else
    log "WARNING: snapshot.sh not found, skipping snapshot creation."
fi

log "Build completed successfully."