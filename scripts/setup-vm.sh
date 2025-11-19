#!/bin/bash
# Omarchy ARM64 VM Setup Script
set -e

echo "=== Omarchy ARM64 VM Setup ==="

# Update system
echo "[1/8] Updating system packages..."
pacman -Syu --noconfirm

# Install essential packages
echo "[2/8] Installing essential packages..."
pacman -S --noconfirm openssh git base-devel sudo wget curl vim

# Enable and start SSH
echo "[3/8] Enabling SSH service..."
systemctl enable sshd
systemctl start sshd

# Configure network
echo "[4/8] Configuring network..."
mkdir -p /etc/systemd/network
cat > /etc/systemd/network/20-wired.network << 'EOF'
[Match]
Name=en*

[Network]
DHCP=ipv4
EOF

systemctl enable systemd-networkd
systemctl enable systemd-resolved
systemctl restart systemd-networkd

# Create user
echo "[5/8] Creating user 'omarchy'..."
useradd -m -G wheel -s /bin/bash omarchy || true
echo "omarchy:omarchy" | chpasswd
echo "root:omarchy" | chpasswd

# Enable sudo
echo "[6/8] Configuring sudo..."
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Install yay
echo "[7/8] Installing yay..."
cd /tmp
sudo -u omarchy git clone https://aur.archlinux.org/yay.git || true
cd yay
sudo -u omarchy makepkg -si --noconfirm || true

# Install Hyprland
echo "[8/8] Installing Hyprland..."
pacman -S --noconfirm wayland wayland-protocols wlroots mesa libdrm \
    pixman libxkbcommon xcb-util-wm xcb-util-renderutil \
    libinput cairo pango seatd polkit

sudo -u omarchy yay -S --noconfirm hyprland || true

echo ""
echo "=== Setup Complete ==="
ip -4 addr show | grep inet
