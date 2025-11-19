#!/bin/bash
# Safe System Upgrade Script (Run via SSH after initial setup)
# This script carefully upgrades the system to avoid library conflicts

set -e  # Exit on any error

VM_IP="${1:-192.168.64.6}"  # Default IP from last session

echo "=== Safe Arch Linux ARM Upgrade Script ==="
echo "Connecting to VM at: $VM_IP"
echo ""

# Connect via SSH and run upgrade commands
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${VM_IP} << 'ENDSSH'

echo "Step 1: Update package database..."
pacman -Sy

echo ""
echo "Step 2: Install openssl-1.1 compatibility package first..."
# Check if openssl-1.1 is available in repos
# If not, we'll need to build from AUR later

echo ""
echo "Step 3: Upgrade core system packages carefully..."
# Upgrade in stages to avoid breaking systemd
pacman -S --noconfirm --needed \
    glibc \
    systemd \
    systemd-libs

echo ""
echo "Step 4: Upgrade remaining packages..."
pacman -Syu --noconfirm

echo ""
echo "Step 5: Install development tools..."
pacman -S --noconfirm --needed \
    base-devel \
    git \
    sudo \
    vim

echo ""
echo "Step 6: Create omarchy user..."
if ! id omarchy &>/dev/null; then
    useradd -m -G wheel -s /bin/bash omarchy
    echo 'omarchy:omarchy' | chpasswd
fi

echo ""
echo "Step 7: Configure sudo for wheel group..."
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

echo ""
echo "=== System upgrade complete! ==="
echo "You can now SSH as: ssh omarchy@${VM_IP}"
echo "Password: omarchy"

ENDSSH

echo ""
echo "=== Upgrade completed successfully! ==="
echo "VM IP: $VM_IP"
echo "SSH as root: ssh root@$VM_IP (password: omarchy)"
echo "SSH as user: ssh omarchy@$VM_IP (password: omarchy)"
