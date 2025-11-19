#!/bin/bash
# Full Omarchy Sync Script for ARM64 VM
# This script installs all Omarchy base packages and configures the system

set -e

echo "=== FULL OMARCHY SYNC FOR ARM64 VM ==="
echo ""
echo "This will:"
echo "  - Install all Omarchy base packages (135 packages)"
echo "  - Configure SDDM login manager"
echo "  - Set up all Omarchy configs"
echo "  - Enable required services"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# Create list of packages to install (exclude ARM64-incompatible packages)
EXCLUDE_PACKAGES=(
    "1password-beta"           # x86_64 only
    "1password-cli"            # x86_64 only
    "aether"                   # May not be available for ARM64
    "omarchy-chromium"         # Custom package
    "omarchy-nvim"             # Custom package
    "omarchy-walker"           # Custom package
    "spotify"                  # x86_64 only
    "typora"                   # May not be on ARM64
    "obsidian"                 # x86_64 only
    "signal-desktop"           # Check ARM64 availability
)

# Read base packages and filter
PACKAGES_TO_INSTALL=()
while IFS= read -r pkg; do
    # Skip comments and empty lines
    [[ "$pkg" =~ ^#.*$ ]] && continue
    [[ -z "$pkg" ]] && continue

    # Skip excluded packages
    skip=false
    for excluded in "${EXCLUDE_PACKAGES[@]}"; do
        if [[ "$pkg" == "$excluded" ]]; then
            echo "Skipping x86_64-only package: $pkg"
            skip=true
            break
        fi
    done

    $skip && continue

    # Check if already installed
    if pacman -Qq "$pkg" &>/dev/null; then
        echo "Already installed: $pkg"
    else
        PACKAGES_TO_INSTALL+=("$pkg")
    fi
done < ~/.local/share/omarchy/install/omarchy-base.packages

echo ""
echo "=== INSTALLING ${#PACKAGES_TO_INSTALL[@]} MISSING PACKAGES ==="
echo ""

if [ ${#PACKAGES_TO_INSTALL[@]} -gt 0 ]; then
    # Install official repo packages first
    PACMAN_PACKAGES=()
    AUR_PACKAGES=()

    for pkg in "${PACKAGES_TO_INSTALL[@]}"; do
        if pacman -Si "$pkg" &>/dev/null; then
            PACMAN_PACKAGES+=("$pkg")
        else
            AUR_PACKAGES+=("$pkg")
        fi
    done

    if [ ${#PACMAN_PACKAGES[@]} -gt 0 ]; then
        echo "Installing ${#PACMAN_PACKAGES[@]} official packages..."
        sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}" || echo "Some packages failed, continuing..."
    fi

    if [ ${#AUR_PACKAGES[@]} -gt 0 ]; then
        echo "Installing ${#AUR_PACKAGES[@]} AUR packages (this may take a while)..."
        for aur_pkg in "${AUR_PACKAGES[@]}"; do
            echo "Building $aur_pkg from AUR..."
            yay -S --needed --noconfirm "$aur_pkg" || echo "Failed to install $aur_pkg, skipping..."
        done
    fi
fi

echo ""
echo "=== CONFIGURING OMARCHY COMPONENTS ==="
echo ""

# Copy all default configs
echo "Copying Hyprland configs..."
omarchy-refresh-config hypr/hypridle.conf
omarchy-refresh-config hypr/hyprlock.conf

# Set up SDDM if installed
if command -v sddm &>/dev/null; then
    echo "Configuring SDDM login manager..."
    sudo systemctl enable sddm.service

    # Configure SDDM to use Hyprland
    sudo mkdir -p /etc/sddm.conf.d
    cat <<EOF | sudo tee /etc/sddm.conf.d/omarchy.conf
[Theme]
Current=breeze

[General]
InputMethod=
EOF
fi

# Enable services
echo "Enabling services..."
sudo systemctl enable --now avahi-daemon.service || true
sudo systemctl enable --now cups.service || true
sudo systemctl enable --now docker.service || true
sudo systemctl enable --now power-profiles-daemon.service || true
sudo systemctl enable --now ufw.service || true

# User services
systemctl --user enable --now wireplumber.service || true
systemctl --user enable --now pipewire.service || true
systemctl --user enable --now pipewire-pulse.service || true

echo ""
echo "=== CONFIGURING PLYMOUTH ==="
echo ""

# Ensure Plymouth is in mkinitcpio hooks
if ! grep -q "plymouth" /etc/mkinitcpio.conf; then
    echo "Adding Plymouth to initramfs..."
    sudo sed -i 's/^HOOKS=.*/HOOKS=(base systemd autodetect microcode modconf kms keyboard keymap sd-vconsole plymouth block filesystems fsck)/' /etc/mkinitcpio.conf
    sudo mkinitcpio -P
fi

echo ""
echo "=== OMARCHY SYNC COMPLETE ==="
echo ""
echo "Installed packages: $(pacman -Qq | wc -l)"
echo "Omarchy base packages target: 135 (excluding ARM64-incompatible)"
echo ""
echo "Next steps:"
echo "  1. Reboot to enable SDDM login screen"
echo "  2. Log in and Hyprland will auto-start with full Omarchy"
echo "  3. Use omarchy-menu (SUPER + ALT + SPACE) for all features"
echo ""
echo "To reboot now: sudo reboot"
