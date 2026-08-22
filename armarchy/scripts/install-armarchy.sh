#!/bin/bash
#
# ARMarchy Installation Script
# Transforms a fresh Arch Linux ARM installation into ARMarchy
#
# Usage: Run this script after booting from Archboot ISO and
#        completing base Arch Linux ARM installation
#

set -e

ARMARCHY_VERSION="1.1.0"
OMARCHY_REPO="https://github.com/basecamp/omarchy.git"

echo "=================================="
echo "ARMarchy Linux Installer v${ARMARCHY_VERSION}"
echo "=================================="
echo ""
echo "This script will install ARMarchy Linux on your system."
echo "ARMarchy = ARM64 + Omarchy"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Please run as root"
    exit 1
fi

# Check if running on ARM64
if [ "$(uname -m)" != "aarch64" ]; then
    echo "ERROR: ARMarchy requires ARM64 (aarch64) architecture"
    exit 1
fi

echo "Step 1: Updating system packages..."
pacman -Syu --noconfirm

echo ""
echo "Step 2: Installing base packages..."
pacman -S --noconfirm \
    base-devel \
    git \
    wget \
    curl \
    openssh \
    sudo \
    neovim \
    htop

echo ""
echo "Step 3: Installing Hyprland and Wayland packages..."
pacman -S --noconfirm \
    hyprland \
    waybar \
    mako \
    wofi \
    foot \
    grim \
    slurp \
    wl-clipboard \
    polkit \
    xdg-desktop-portal-hyprland

echo ""
echo "Step 4: Installing CLI utilities..."
pacman -S --noconfirm \
    bat \
    eza \
    ripgrep \
    fd \
    fzf \
    zoxide \
    starship \
    fastfetch \
    btop \
    ncdu \
    tldr \
    httpie \
    jq \
    yq

echo ""
echo "Step 5: Installing GUI applications..."
pacman -S --noconfirm \
    chromium \
    mpv \
    imv \
    zathura \
    zathura-pdf-mupdf

echo ""
echo "Step 6: Installing fonts..."
pacman -S --noconfirm \
    ttf-fira-code \
    ttf-fira-sans \
    ttf-liberation \
    noto-fonts \
    noto-fonts-emoji

echo ""
echo "Step 7: Cloning Omarchy configuration..."
if [ ! -d "/opt/omarchy" ]; then
    git clone "$OMARCHY_REPO" /opt/omarchy
    echo "Omarchy cloned to /opt/omarchy"
else
    echo "Omarchy already exists at /opt/omarchy"
fi

echo ""
echo "Step 8: Setting up user environment..."
read -p "Enter username for ARMarchy user: " USERNAME

if id "$USERNAME" &>/dev/null; then
    echo "User $USERNAME already exists"
else
    useradd -m -G wheel -s /bin/bash "$USERNAME"
    echo "Created user: $USERNAME"
    passwd "$USERNAME"
fi

echo ""
echo "Step 9: Enabling sudo for wheel group..."
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

echo ""
echo "Step 10: Installing Omarchy configs for user..."
sudo -u "$USERNAME" bash << 'USEREOF'
cd ~

# Create config directories
mkdir -p ~/.config/{hypr,waybar,mako,wofi,foot}

# Copy Omarchy configs (adapt as needed)
if [ -d "/opt/omarchy/configs" ]; then
    cp -r /opt/omarchy/configs/* ~/.config/ 2>/dev/null || true
fi

# Setup shell configuration
if [ -f "/opt/omarchy/.bashrc" ]; then
    cp /opt/omarchy/.bashrc ~/.bashrc
fi

if [ -f "/opt/omarchy/.zshrc" ]; then
    cp /opt/omarchy/.zshrc ~/.zshrc
fi

echo "User configurations installed"
USEREOF

echo ""
echo "Step 11: Installing ARMarchy first-boot setup..."
cp /opt/armarchy/scripts/first-boot-setup.sh /usr/local/bin/armarchy-setup
chmod +x /usr/local/bin/armarchy-setup

echo ""
echo "Step 12: Enabling essential services..."
systemctl enable sshd

echo ""
echo "=================================="
echo "ARMarchy Installation Complete!"
echo "=================================="
echo ""
echo "    _    ____  __  __                  _          "
echo "   / \\  |  _ \\|  \\/  | __ _ _ __ ___| |__  _   _ "
echo "  / _ \\ | |_) | |\\/| |/ _\` | '__/ __| '_ \\| | | |"
echo " / ___ \\|  _ <| |  | | (_| | | | (__| | | | |_| |"
echo "/_/   \\_\\_| \\_\\_|  |_|\\__,_|_|  \\___|_| |_|\\__, |"
echo "                                           |___/ "
echo "          ARM64 + Omarchy = ARMarchy"
echo ""
echo "Next steps:"
echo "1. Reboot your system"
echo "2. Login as user: $USERNAME"
echo "3. Run 'armarchy-setup' to complete configuration"
echo "4. Start Hyprland with: Hyprland"
echo ""
echo "Documentation: https://github.com/potable-anarchy/ARMarchy"
echo ""
