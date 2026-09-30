#!/usr/bin/env bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# installer/cli-installer.sh
# Purpose: Minimal CLI installer for CH4rch Linux (archinstall-style)
# Logic: 5-7 questions, disk partitioning, squashfs extraction, bootloader and config

set -euo pipefail

# Configuration
MOUNT_POINT="/mnt"
EFI_PART_SIZE="512M"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Question 1: Select disk
select_disk() {
    log_info "Available disks:"
    lsblk -d -o NAME,SIZE,TYPE | grep disk | nl
    
    read -rp "Select disk number: " disk_num
    DISK=$(lsblk -d -o NAME,TYPE | grep disk | sed -n "${disk_num}p" | awk '{print $1}')
    
    if [[ -z "$DISK" ]]; then
        log_error "Invalid disk selection"
        exit 1
    fi
    
    log_info "Selected disk: /dev/$DISK"
}

# Question 2: Hostname
select_hostname() {
    read -rp "Enter hostname [ch4rch]: " HOSTNAME
    HOSTNAME=${HOSTNAME:-ch4rch}
    log_info "Hostname: $HOSTNAME"
}

# Question 3: Username
select_username() {
    read -rp "Enter username: " USERNAME
    if [[ -z "$USERNAME" ]]; then
        log_error "Username cannot be empty"
        exit 1
    fi
    log_info "Username: $USERNAME"
}

# Question 4: User password
select_password() {
    read -rsp "Enter password for $USERNAME: " USER_PASSWORD
    echo
    if [[ -z "$USER_PASSWORD" ]]; then
        log_error "Password cannot be empty"
        exit 1
    fi
    log_info "Password set for $USERNAME"
}

# Question 5: Locale
select_locale() {
    read -rp "Enter locale [en_US.UTF-8]: " LOCALE
    LOCALE=${LOCALE:-en_US.UTF-8}
    log_info "Locale: $LOCALE"
}

# Question 6: Timezone
select_timezone() {
    read -rp "Enter timezone [UTC]: " TIMEZONE
    TIMEZONE=${TIMEZONE:-UTC}
    log_info "Timezone: $TIMEZONE"
}

# Question 7: Mirror (optional)
select_mirror() {
    read -rp "Enter mirror URL (or press Enter for default): " MIRROR
    if [[ -z "$MIRROR" ]]; then
        MIRROR="https://geo.mirror.pkgbuild.com/\$repo/os/\$arch"
    fi
    log_info "Mirror: $MIRROR"
}

# Partition disk: EFI + root
partition_disk() {
    log_info "Partitioning /dev/$DISK..."
    
    # Create GPT partition table
    sgdisk -o "/dev/$DISK"
    
    # Create EFI partition (512M)
    sgdisk -n 1:0:+${EFI_PART_SIZE} -t 1:ef00 "/dev/$DISK"
    
    # Create root partition (rest of disk)
    sgdisk -n 2:0:0 -t 2:8300 "/dev/$DISK"
    
    # Format partitions
    mkfs.fat -F 32 "/dev/${DISK}1"
    mkfs.ext4 -F "/dev/${DISK}2"
    
    # Mount partitions
    mount "/dev/${DISK}2" "$MOUNT_POINT"
    mkdir -p "$MOUNT_POINT/boot/efi"
    mount "/dev/${DISK}1" "$MOUNT_POINT/boot/efi"
    
    log_info "Disk partitioned and mounted"
}

# Extract squashfs from ISO/live media
extract_rootfs() {
    log_info "Extracting rootfs from squashfs..."
    
    # Find squashfs file (from ISO or live media)
    local squashfs_path=""
    
    # Try common locations
    for path in /run/initramfs/live/ch4rch/ch4rch_rootfs.sfs \
                /ch4rch/ch4rch_rootfs.sfs \
                ./ch4rch_rootfs.sfs; do
        if [[ -f "$path" ]]; then
            squashfs_path="$path"
            break
        fi
    done
    
    if [[ -z "$squashfs_path" ]]; then
        log_error "squashfs file not found"
        exit 1
    fi
    
    # Extract squashfs
    unsquashfs -f -d "$MOUNT_POINT" "$squashfs_path"
    
    log_info "Rootfs extracted successfully"
}

# Install GRUB bootloader
install_bootloader() {
    log_info "Installing GRUB bootloader..."
    
    # Install GRUB for UEFI
    arch-chroot "$MOUNT_POINT" grub-install \
        --target=x86_64-efi \
        --efi-directory=/boot/efi \
        --bootloader-id=CH4RCH \
        --removable
    
    # Generate GRUB config
    arch-chroot "$MOUNT_POINT" grub-mkconfig -o /boot/grub/grub.cfg
    
    log_info "Bootloader installed"
}

# Configure system
configure_system() {
    log_info "Configuring system..."
    
    # Set hostname
    echo "$HOSTNAME" > "$MOUNT_POINT/etc/hostname"
    
    # Create user
    arch-chroot "$MOUNT_POINT" useradd -m -G wheel -s /bin/bash "$USERNAME"
    echo "$USERNAME:$USER_PASSWORD" | arch-chroot "$MOUNT_POINT" chpasswd
    
    # Enable sudo for wheel group
    echo "%wheel ALL=(ALL) ALL" >> "$MOUNT_POINT/etc/sudoers"
    
    # Set locale
    echo "$LOCALE UTF-8" >> "$MOUNT_POINT/etc/locale.gen"
    arch-chroot "$MOUNT_POINT" locale-gen
    echo "LANG=$LOCALE" > "$MOUNT_POINT/etc/locale.conf"
    
    # Set timezone
    arch-chroot "$MOUNT_POINT" ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
    arch-chroot "$MOUNT_POINT" hwclock --systohc
    
    # Set mirror
    echo "Server = $MIRROR" > "$MOUNT_POINT/etc/pacman.d/mirrorlist"
    
    # Generate fstab
    genfstab -U "$MOUNT_POINT" >> "$MOUNT_POINT/etc/fstab"
    
    log_info "System configured"
}

# Main installation flow
main() {
    log_info "CH4rch Linux Installer"
    echo
    
    # Check root privileges
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        exit 1
    fi
    
    # Ask questions
    select_disk
    select_hostname
    select_username
    select_password
    select_locale
    select_timezone
    select_mirror
    
    echo
    log_info "Starting installation..."
    
    # Partition disk
    partition_disk
    
    # Extract rootfs
    extract_rootfs
    
    # Install bootloader
    install_bootloader
    
    # Configure system
    configure_system
    
    echo
    log_info "Installation completed successfully!"
    log_info "Please reboot and remove installation media"
}

# Run main function
main "$@"