#!/bin/bash
set -e

source "$(dirname "$0")/build.conf"

log() {
    echo "[CH4RCH] $1"
}

prepare_workspace() {

    log "Preparing workspace..."

    mkdir -p "$CH4RCH_WORK"
    mkdir -p "$CH4RCH_PKGDEST"
    mkdir -p "$CH4RCH_SRCDEST"
    mkdir -p "$CH4RCH_REPO/$CH4RCH_ARCH"
    mkdir -p "$CH4RCH_LOGS"
    mkdir -p "$CH4RCH_ISO"

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

log "Building ISO..."
"$CH4RCH_SRC/build-tools/build-iso.sh"

log "Build completed."
