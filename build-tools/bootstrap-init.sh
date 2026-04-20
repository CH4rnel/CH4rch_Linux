#!/bin/bash
set -e

ROOTFS="work/rootfs"

mkdir -p "$ROOTFS/etc/s6-linux-init"
mkdir -p "$ROOTFS/run/service"
mkdir -p "$ROOTFS/sbin"

echo "[1] correct init link"
ln -sf /usr/bin/s6-linux-init-init "$ROOTFS/sbin/init"

echo "[2] create service directory"
mkdir -p "$ROOTFS/run/service"

echo "[3] stage1 = svscan launcher"
cat > "$ROOTFS/etc/s6-linux-init/init-stage1" << 'EOF'
#!/bin/sh
exec s6-svscan /run/service
EOF

chmod +x "$ROOTFS/etc/s6-linux-init/init-stage1"

echo "[DONE]"
