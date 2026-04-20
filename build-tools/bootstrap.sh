#!/bin/bash
set -e

ROOTFS_DIR="work/rootfs"
PKG_LIST="iso/packages.list"
OVERLAY="rootfs-overlay"

rm -rf work
mkdir -p "$ROOTFS_DIR"

mkdir -p "$ROOTFS_DIR"/{bin,boot,etc,home,lib,lib64,opt,root,run,sbin,usr,var,tmp}

if [ ! -f "$PKG_LIST" ]; then
    exit 1
fi

cp -r "$OVERLAY"/* "$ROOTFS_DIR"/

mkdir -p "$ROOTFS_DIR"/{dev,proc,sys}

touch "$ROOTFS_DIR/etc/fstab"

if [ ! -f "$ROOTFS_DIR/etc/hostname" ]; then
    echo "mydistro" > "$ROOTFS_DIR/etc/hostname"
fi

if [ ! -f "$ROOTFS_DIR/bin/bash" ]; then
    :
fi
