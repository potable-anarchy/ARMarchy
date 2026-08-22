#!/bin/bash
#
# ARMarchy Fully Automatic Installer
# Run this from the Archboot ISO to install ARMarchy with zero interaction
#
# Usage: curl -sL https://raw.githubusercontent.com/potable-anarchy/ARMarchy/main/armarchy/scripts/armarchy-autoinstall.sh | bash
#

set -e

# Configuration - edit these if needed
HOSTNAME="${ARMARCHY_HOSTNAME:-armarchy}"
USERNAME="${ARMARCHY_USER:-armarchy}"
PASSWORD="${ARMARCHY_PASS:-armarchy}"
TIMEZONE="${ARMARCHY_TZ:-America/Los_Angeles}"
LOCALE="en_US.UTF-8"
DISK="/dev/vda"  # Change if your disk is different

echo ""
echo "    _    ____  __  __                  _          "
echo "   / \\  |  _ \\|  \\/  | __ _ _ __ ___| |__  _   _ "
echo "  / _ \\ | |_) | |\\/| |/ _\` | '__/ __| '_ \\| | | |"
echo " / ___ \\|  _ <| |  | | (_| | | | (__| | | | |_| |"
echo "/_/   \\_\\_| \\_\\_|  |_|\\__,_|_|  \\___|_| |_|\\__, |"
echo "                                           |___/ "
echo ""
echo "ARMarchy Linux - Automatic Installer"
echo "====================================="
echo ""
echo "Configuration:"
echo "  Hostname: $HOSTNAME"
echo "  Username: $USERNAME"
echo "  Password: $PASSWORD"
echo "  Timezone: $TIMEZONE"
echo "  Disk: $DISK"
echo ""
echo "This will ERASE $DISK and install ARMarchy."
echo "Press Ctrl+C within 10 seconds to cancel..."
echo ""
sleep 10

#######################################
# Ensure install tools are present
#######################################
# The Archboot ISO is a minimal recovery environment and does not ship parted,
# pacstrap/arch-chroot/genfstab, or the mkfs tools in PATH by default. Pull them
# from the (already-configured, online) live-environment pacman before we start.

echo "[0/10] Installing partitioning/install tools..."
pacman -Sy --noconfirm --needed parted arch-install-scripts dosfstools e2fsprogs

#######################################
# Partition and Format
#######################################

echo "[1/10] Partitioning disk $DISK..."
parted -s "$DISK" mklabel gpt
parted -s "$DISK" mkpart primary fat32 1MiB 512MiB
parted -s "$DISK" set 1 esp on
parted -s "$DISK" mkpart primary ext4 512MiB 100%

echo "[2/10] Formatting partitions..."
yes | mkfs.fat -F32 "${DISK}1"
yes | mkfs.ext4 "${DISK}2"

echo "[3/10] Mounting filesystems..."
mount "${DISK}2" /mnt
mkdir -p /mnt/boot
mount "${DISK}1" /mnt/boot

#######################################
# Install Base System
#######################################

echo "[4/10] Installing base system (this takes 10-15 minutes)..."
pacstrap /mnt base base-devel linux linux-firmware \
    grub efibootmgr networkmanager openssh sudo

echo "[5/10] Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

#######################################
# Configure System
#######################################

echo "[6/10] Configuring system..."
arch-chroot /mnt /bin/bash << CHROOTEOF
set -e

# Timezone
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc

# Locale
echo "$LOCALE UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=$LOCALE" > /etc/locale.conf

# Hostname
echo "$HOSTNAME" > /etc/hostname
cat > /etc/hosts << HOSTSEOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
HOSTSEOF

# Bootloader
grub-install --target=arm64-efi --efi-directory=/boot --bootloader-id=ARMarchy
grub-mkconfig -o /boot/grub/grub.cfg

# Enable services
systemctl enable NetworkManager sshd

# Create user
useradd -m -G wheel -s /bin/bash $USERNAME
echo "$USERNAME:$PASSWORD" | chpasswd
echo "root:$PASSWORD" | chpasswd

# Enable sudo
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

CHROOTEOF

#######################################
# Install ARMarchy Packages
#######################################

echo "[7/10] Installing ARMarchy packages (this takes 20-30 minutes)..."
arch-chroot /mnt /bin/bash << 'PKGEOF'
set -e

# Hyprland and Wayland
pacman -S --noconfirm hyprland waybar mako wofi foot \
    grim slurp wl-clipboard polkit xdg-desktop-portal-hyprland \
    qt5-wayland qt6-wayland

# CLI Tools
pacman -S --noconfirm bat eza ripgrep fd fzf zoxide starship \
    fastfetch btop ncdu tldr httpie jq yq git lazygit neovim \
    tmux zsh zsh-completions

# GUI Applications
pacman -S --noconfirm chromium mpv imv zathura zathura-pdf-mupdf

# Fonts
pacman -S --noconfirm ttf-fira-code ttf-fira-sans ttf-liberation \
    noto-fonts noto-fonts-emoji ttf-dejavu

# Development
pacman -S --noconfirm rustup go python python-pip nodejs npm

PKGEOF

#######################################
# Install Omarchy Configuration
#######################################

echo "[8/10] Installing Omarchy configuration..."
arch-chroot /mnt /bin/bash << OMARCHYEOF
set -e

# Clone Omarchy as user
sudo -u $USERNAME bash << 'USEREOF'
cd ~
git clone https://github.com/basecamp/omarchy.git ~/omarchy

# Create config directories
mkdir -p ~/.config/{hypr,waybar,mako,wofi,foot,nvim}

# Basic Hyprland config
cat > ~/.config/hypr/hyprland.conf << 'HYPREOF'
# ARMarchy Hyprland Configuration

monitor=,1280x800@60,auto,1

exec-once = waybar
exec-once = mako

input {
    kb_layout = us
    follow_mouse = 1
    touchpad {
        natural_scroll = yes
    }
}

general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)
    layout = dwindle
}

decoration {
    rounding = 10
    blur {
        enabled = true
        size = 3
        passes = 1
    }
    drop_shadow = yes
    shadow_range = 4
    shadow_render_power = 3
    col.shadow = rgba(1a1a1aee)
}

animations {
    enabled = yes
    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

# Keybindings
\$mainMod = SUPER

bind = \$mainMod, RETURN, exec, foot
bind = \$mainMod, Q, killactive,
bind = \$mainMod, M, exit,
bind = \$mainMod, E, exec, wofi --show drun
bind = \$mainMod, B, exec, chromium
bind = \$mainMod, F, fullscreen,
bind = \$mainMod, V, togglefloating,

# Move focus
bind = \$mainMod, left, movefocus, l
bind = \$mainMod, right, movefocus, r
bind = \$mainMod, up, movefocus, u
bind = \$mainMod, down, movefocus, d

# Workspaces
bind = \$mainMod, 1, workspace, 1
bind = \$mainMod, 2, workspace, 2
bind = \$mainMod, 3, workspace, 3
bind = \$mainMod, 4, workspace, 4
bind = \$mainMod, 5, workspace, 5

bind = \$mainMod SHIFT, 1, movetoworkspace, 1
bind = \$mainMod SHIFT, 2, movetoworkspace, 2
bind = \$mainMod SHIFT, 3, movetoworkspace, 3
bind = \$mainMod SHIFT, 4, movetoworkspace, 4
bind = \$mainMod SHIFT, 5, movetoworkspace, 5
HYPREOF

# Basic Waybar config
cat > ~/.config/waybar/config << 'WAYBAREOF'
{
    "layer": "top",
    "position": "top",
    "height": 30,
    "modules-left": ["hyprland/workspaces"],
    "modules-center": ["clock"],
    "modules-right": ["cpu", "memory", "network"],
    "clock": {
        "format": "{:%Y-%m-%d %H:%M}"
    },
    "cpu": {
        "format": "CPU {usage}%"
    },
    "memory": {
        "format": "MEM {}%"
    },
    "network": {
        "format": "{ifname}: {ipaddr}"
    }
}
WAYBAREOF

# Create startup script
cat > ~/start-armarchy.sh << 'STARTEOF'
#!/bin/bash
export XDG_RUNTIME_DIR="/run/user/\$(id -u)"
mkdir -p "\$XDG_RUNTIME_DIR"
chmod 700 "\$XDG_RUNTIME_DIR"
exec Hyprland
STARTEOF
chmod +x ~/start-armarchy.sh

# Create README
cat > ~/README.txt << 'READMEEOF'
Welcome to ARMarchy Linux!

To start the desktop environment, run:
  ./start-armarchy.sh

Or simply:
  Hyprland

Default credentials:
  Username: $USERNAME
  Password: $PASSWORD

Keybindings:
  SUPER + RETURN  : Terminal
  SUPER + E       : App launcher
  SUPER + B       : Browser
  SUPER + Q       : Close window
  SUPER + M       : Exit

Documentation:
  https://github.com/potable-anarchy/ARMarchy

Omarchy configs are in: ~/omarchy
READMEEOF

USEREOF

OMARCHYEOF

#######################################
# Final Setup
#######################################

echo "[9/10] Creating post-install message..."
cat > /mnt/etc/motd << 'MOTDEOF'

    _    ____  __  __                  _
   / \  |  _ \|  \/  | __ _ _ __ ___| |__  _   _
  / _ \ | |_) | |\/| |/ _` | '__/ __| '_ \| | | |
 / ___ \|  _ <| |  | | (_| | | | (__| | | | |_| |
/_/   \_\_| \_\_|  |_|\__,_|_|  \___|_| |_|\__, |
                                           |___/
           ARM64 + Omarchy = ARMarchy

Welcome to ARMarchy Linux!

To start the desktop environment:
  ./start-armarchy.sh

Documentation: https://github.com/potable-anarchy/ARMarchy

MOTDEOF

echo "[10/10] Unmounting and finishing..."
umount -R /mnt

echo ""
echo "======================================"
echo "ARMarchy Installation Complete!"
echo "======================================"
echo ""
echo "    _    ____  __  __                  _          "
echo "   / \\  |  _ \\|  \\/  | __ _ _ __ ___| |__  _   _ "
echo "  / _ \\ | |_) | |\\/| |/ _\` | '__/ __| '_ \\| | | |"
echo " / ___ \\|  _ <| |  | | (_| | | | (__| | | | |_| |"
echo "/_/   \\_\\_| \\_\\_|  |_|\\__,_|_|  \\___|_| |_|\\__, |"
echo "                                           |___/ "
echo ""
echo "System will reboot in 10 seconds..."
echo ""
echo "After reboot, login and run: ./start-armarchy.sh"
echo ""
echo "Default credentials:"
echo "  Username: $USERNAME"
echo "  Password: $PASSWORD"
echo ""
echo "To change password after login: passwd"
echo ""

sleep 10
reboot
