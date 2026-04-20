#!/bin/bash
set -e

ROOTFS="work/rootfs"
PKG_LIST="iso/packages.list"

mkdir -p "$ROOTFS"/var/lib/pacman
mkdir -p "$ROOTFS"/var/cache/pacman/pkg
mkdir -p "$ROOTFS"/etc/pacman.d

echo "[1] sync host databases"
pacman -Sy --noconfirm

echo "[2] initialize keyring in host"
pacman -Sy --noconfirm archlinux-keyring
pacman-key --init
pacman-key --populate archlinux

echo "[3] sync target root databases"
pacman --root "$ROOTFS" -Sy --noconfirm

echo "[4] install base packages into rootfs"

while read -r pkg; do
    [ -z "$pkg" ] && continue
    pacman --root "$ROOTFS" -Sy --noconfirm "$pkg"
done < "$PKG_LIST"

echo "[DONE]"
