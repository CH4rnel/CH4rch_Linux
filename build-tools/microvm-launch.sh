#!/usr/bin/env bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# MicroVM Launcher for CH4rch Linux.
# Disposable VM with read-only golden image + tmpfs/overlay.
# Replaced eval with bash arrays to prevent shell injection.

set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "$0")/build.conf"

# Default values
BACKEND="qemu"
ROOTFS=""
OVERLAY_DIR=""
MEMORY="512M"
CPUS="1"
DRY_RUN="true"

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  --backend <qemu|cloud-hypervisor>  MicroVM backend (default: qemu)"
    echo "  --rootfs <path>                    Path to read-only golden image (required)"
    echo "  --overlay <path>                   Path to writable overlay directory (required)"
    echo "  --memory <size>                    RAM size (default: 512M)"
    echo "  --cpus <count>                     Number of vCPUs (default: 1)"
    echo "  --run                              Actually execute the VM (default is dry-run)"
    echo "  --help                             Show this help message"
    exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --backend) BACKEND="$2"; shift 2 ;;
        --rootfs) ROOTFS="$2"; shift 2 ;;
        --overlay) OVERLAY_DIR="$2"; shift 2 ;;
        --memory) MEMORY="$2"; shift 2 ;;
        --cpus) CPUS="$2"; shift 2 ;;
        --run) DRY_RUN="false"; shift ;;
        --help) usage ;;
        *) echo "Unknown option: $1"; usage ;;
    esac
done

# Validate required arguments
if [[ -z "$ROOTFS" || -z "$OVERLAY_DIR" ]]; then
    echo "[CH4RCH] ERROR: --rootfs and --overlay are required." >&2
    usage
fi

if [[ ! -f "$ROOTFS" ]]; then
    echo "[CH4RCH] ERROR: Rootfs image not found at $ROOTFS" >&2
    exit 1
fi

# Prepare overlay directory
mkdir -p "$OVERLAY_DIR"
echo "[CH4RCH] Prepared ephemeral overlay at: $OVERLAY_DIR"

# Determine backend executable
if [[ "$BACKEND" = "cloud-hypervisor" ]]; then
    if command -v cloud-hypervisor &> /dev/null; then
        VM_CMD="cloud-hypervisor"
    else
        echo "[CH4RCH] WARNING: cloud-hypervisor not found, falling back to qemu-system-x86_64" >&2
        VM_CMD="qemu-system-x86_64"
        BACKEND="qemu"
    fi
else
    VM_CMD="qemu-system-x86_64"
fi

# Check KVM access
if [[ ! -w /dev/kvm ]]; then
    echo "[CH4RCH] WARNING: No write access to /dev/kvm. Performance will be degraded (TCG mode)." >&2
fi

# P2-2 FIX: Build command as bash array to prevent shell injection
if [[ "$BACKEND" = "cloud-hypervisor" ]]; then
    CMD=(
        "$VM_CMD"
        "--cpus" "boot=$CPUS"
        "--memory" "size=$MEMORY"
        "--disk" "path=$ROOTFS"
        "--disk" "path=$OVERLAY_DIR"
        "--console" "off"
        "--serial" "tty"
    )
else
    CMD=(
        "$VM_CMD"
        "-enable-kvm"
        "-m" "$MEMORY"
        "-smp" "$CPUS"
        "-drive" "file=$ROOTFS,format=raw,readonly=on,if=virtio"
        "-drive" "file=$OVERLAY_DIR,format=raw,if=virtio"
        "-nographic"
        "-serial" "mon:stdio"
    )
fi

echo "[CH4RCH] Generated MicroVM command:"
echo "  ${CMD[*]}"

if [[ "$DRY_RUN" = "true" ]]; then
    echo "[CH4RCH] Dry-run mode. Use --run to actually start the MicroVM."
else
    echo "[CH4RCH] Starting MicroVM..."

    # Log to hash-chain
    if [[ -x "$CH4RCH_SRC/build-tools/hash-chain.sh" ]]; then
        "$CH4RCH_SRC/build-tools/hash-chain.sh" "MICROVM_LAUNCH backend=$BACKEND rootfs=$ROOTFS"
    fi

    # fix. Direct array execution instead of eval
    "${CMD[@]}"

    # Cleanup overlay after exit (Disposable VM behavior)
    echo "[CH4RCH] MicroVM exited. Cleaning up ephemeral overlay..."
    rm -rf "$OVERLAY_DIR"
fi