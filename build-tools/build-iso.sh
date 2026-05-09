#!/bin/bash
set -e
source "$(dirname "$0")/build.conf"

ISO_NAME="CH4rch-$(cat $CH4RCH_SRC/VERSION)-x86_64.iso"

mkdir -p "$CH4RCH_ISO"

grub-mkrescue -o "$CH4RCH_ISO/$ISO_NAME" "$CH4RCH_SRC/iso"
echo "[CH4RCH] ISO created at $CH4RCH_ISO/$ISO_NAME"

