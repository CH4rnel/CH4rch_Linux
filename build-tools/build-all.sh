#!/usr/bin/env bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Main build orchestrator for CH4rch Linux.
# Executes the build pipeline in strict order: packages -> sign -> repo -> rootfs -> init -> initramfs -> config -> iso -> snapshot.

set -euo pipefail

# shellcheck source=/dev/null
source "$(dirname "$0")/build.conf"

log() {
    echo "[CH4RCH] $1"
}

log_warning() {
    echo "[CH4RCH] WARNING: $1" >&2
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

log "Step 1/8: Building packages..."
"$CH4RCH_SRC/build-tools/build-package.sh"

log "Step 2/8: Signing packages..."
"$CH4RCH_SRC/build-tools/sign-packages.sh"

log "Step 3/8: Syncing repository..."
"$CH4RCH_SRC/build-tools/repo-sync.sh"

log "Step 4/8: Building rootfs..."
"$CH4RCH_SRC/build-tools/build-rootfs.sh"

log "Step 5/8: Compiling init system..."
"$CH4RCH_SRC/build-tools/bootstrap-init.sh"

log "Step 6/8: Generating initramfs..."
"$CH4RCH_SRC/build-tools/mkinitramfs.sh"

# Apply declarative configuration
log "Step 7/8: Applying declarative configuration..."
if [ -x "$CH4RCH_SRC/build-tools/ch4rchctl" ]; then
    "$CH4RCH_SRC/build-tools/ch4rchctl" apply || {
        log_warning "Configuration apply failed, but build continued."
    }
else
    log_warning "ch4rchctl not found, skipping configuration apply."
fi

log "Step 8/8: Building ISO..."
"$CH4RCH_SRC/build-tools/build-iso.sh"

# Create snapshot after successful build
log "Creating build snapshot..."
if [ -x "$CH4RCH_SRC/build-tools/snapshot.sh" ]; then
    "$CH4RCH_SRC/build-tools/snapshot.sh" create "build-$(cat "$CH4RCH_SRC/VERSION")-$(date +%Y%m%d-%H%M%S)" 2>/dev/null || {
        log_warning "Snapshot creation failed, but build completed."
    }
else
    log_warning "snapshot.sh not found, skipping snapshot creation."
fi

log "Build completed successfully."