# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
#!/usr/bin/env bash
# build-rootfs.sh
# Purpose: Bootstrap the minimal CH4rch Linux root filesystem.
# Logic: Configures pacman with upstream Arch repos, initializes keys, 
#        and installs the base toolchain and CH4rch core packages.

set -euo pipefail

# Configuration
CH4RCH_ROOTFS="${CH4RCH_ROOTFS:-$PWD/rootfs}"
CH4RCH_REPO="${CH4RCH_REPO:-$PWD/repo}"

echo "[*] Setting up rootfs directory at $CH4RCH_ROOTFS"
mkdir -p "$CH4RCH_ROOTFS"

echo "[*] Generating pacman.conf with upstream and local repositories"
cat << 'EOF' > "$CH4RCH_ROOTFS/etc/pacman.conf"
[options]
HoldPkg     = pacman glibc
Architecture = auto
Color
CheckSpace
SigLevel    = Required DatabaseOptional

# Upstream Arch Linux repositories (Required for bootstrap)
[core]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

# Local CH4rch repository
[ch4rch-core]
SigLevel = Optional TrustAll
Server = file://CH4RCH_REPO_PLACEHOLDER
EOF

# Replace placeholder with actual path safely
sed -i "s|CH4RCH_REPO_PLACEHOLDER|$CH4RCH_REPO|g" "$CH4RCH_ROOTFS/etc/pacman.conf"

# Ensure directory structure exists and provide a default upstream mirrorlist
mkdir -p "$CH4RCH_ROOTFS/etc/pacman.d"
echo "Server = https://geo.mirror.pkgbuild.com/\$repo/os/\$arch" > "$CH4RCH_ROOTFS/etc/pacman.d/mirrorlist"

echo "[*] Installing base toolchain packages"
# P0-1 FIX: Added missing backslashes for line continuation
pacman -Sy --root "$CH4RCH_ROOTFS" --cachedir "$CH4RCH_ROOTFS/var/cache/pacman/pkg" \
    pacman \
    glibc \
    linux \
    linux-firmware \
    s6 \
    s6-rc \
    s6-linux-init \
    eudev \
    dhcpcd \
    bubblewrap \
    sqlite

echo "[*] Rootfs bootstrap completed successfully."