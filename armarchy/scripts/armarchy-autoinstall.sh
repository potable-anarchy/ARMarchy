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

echo "[0/10] Installing install tools..."
# Archboot is a minimal recovery environment and does not ship pacstrap/arch-chroot/
# genfstab or mkfs.fat by default. Pull them from the (online) live-environment pacman.
# NOTE: we deliberately partition with sfdisk (util-linux, always present) rather than
# parted -- parted needs device-mapper/libdevmapper, which pacman -Sy does not reliably
# provide in Archboot's trimmed RAM env (partial-upgrade soname skew).
pacman -Sy --noconfirm --needed arch-install-scripts dosfstools e2fsprogs

#######################################
# Partition and Format
#######################################

echo "[1/10] Partitioning disk $DISK..."
# GPT: 512MiB EFI System Partition + rest as Linux root. sfdisk 'uefi'/'linux' are
# type aliases for the EFI System and Linux filesystem GUIDs.
sfdisk --wipe always --wipe-partitions always "$DISK" <<SFDISK
label: gpt
start=1MiB, size=511MiB, type=uefi, name=ESP
type=linux, name=ARMarchy
SFDISK
# sfdisk re-reads the table itself; give udev a moment to create the node symlinks.
udevadm settle 2>/dev/null || true

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

# Install Omarchy to the system path its bootstrap hard-codes, so OMARCHY_PATH and
# the Lua config module path resolve the same way they do on a real Omarchy install.
arch-chroot /mnt git clone --depth 1 https://github.com/basecamp/omarchy.git /usr/share/omarchy

# Expose Omarchy's environment (OMARCHY_PATH + PATH) to every login shell, and put
# Omarchy's CLI on PATH (a real install ships these as /usr/bin/omarchy-*; we cloned,
# so symlink them from the repo's bin/).
cat > /mnt/etc/profile.d/omarchy.sh << 'PROFEOF'
# Load Omarchy's environment (OMARCHY_PATH + PATH) for all login shells.
[ -r /usr/share/omarchy/default/bash/env-bootstrap ] && . /usr/share/omarchy/default/bash/env-bootstrap
PROFEOF
arch-chroot /mnt bash -c 'for f in /usr/share/omarchy/bin/omarchy-*; do [ -f "$f" ] && ln -sf "$f" /usr/local/bin/; done'

# Per-user config application, written as a script and run as the user. This mirrors
# what Omarchy's own "omarchy-refresh-hyprland" does (copy config/hypr/*.lua into
# ~/.config/hypr), plus configs for the apps this image ships and Omarchy's shell rc.
cat > /mnt/usr/local/bin/armarchy-apply-omarchy << 'APPLYEOF'
#!/bin/bash
set -e
export OMARCHY_PATH=/usr/share/omarchy
mkdir -p ~/.config/hypr ~/.local/state/omarchy/toggles/hypr

# Omarchy's Hyprland Lua configs (hyprland.lua entry point + monitors/input/bindings/
# looknfeel/autostart overrides). This is the actual Omarchy desktop configuration.
cp -r "$OMARCHY_PATH"/config/hypr/. ~/.config/hypr/
cp "$OMARCHY_PATH"/default/hypr/toggles/flags.lua ~/.local/state/omarchy/toggles/hypr/ 2>/dev/null || true

# Omarchy configs for the tools this image ships.
for d in foot btop tmux git; do
  [ -e "$OMARCHY_PATH/config/$d" ] && cp -r "$OMARCHY_PATH/config/$d" ~/.config/
done
[ -e "$OMARCHY_PATH/config/starship.toml" ] && cp "$OMARCHY_PATH/config/starship.toml" ~/.config/

# Omarchy's shell environment (exports OMARCHY_PATH, aliases, PATH for the CLI).
cp "$OMARCHY_PATH/default/bashrc" ~/.bashrc

# ARM adaptation: Omarchy 4.0's top bar is quickshell-based (omarchy-launch-shell),
# which isn't part of this ARM image. Add a lightweight fallback bar + notifications
# to the USER autostart. Hyprland's Lua "hl" API is in scope here (loaded by bootstrap).
cat >> ~/.config/hypr/autostart.lua << 'AUTOEOF'

-- ARMarchy: fallback bar/notifications (Omarchy 4.0's quickshell bar isn't in this image).
hl.exec_cmd("pgrep -x waybar >/dev/null || waybar")
hl.exec_cmd("pgrep -x mako >/dev/null || mako")
AUTOEOF

# Minimal waybar config so the fallback bar renders cleanly.
mkdir -p ~/.config/waybar
cat > ~/.config/waybar/config << 'WAYBAREOF'
{
    "layer": "top", "position": "top", "height": 30,
    "modules-left": ["hyprland/workspaces"],
    "modules-center": ["clock"],
    "modules-right": ["cpu", "memory", "network"],
    "clock": { "format": "{:%Y-%m-%d %H:%M}" },
    "cpu": { "format": "CPU {usage}%" },
    "memory": { "format": "MEM {}%" },
    "network": { "format": "{ifname}: {ipaddr}" }
}
WAYBAREOF

# Startup script: load Omarchy's environment before launching Hyprland so the Lua
# config's OMARCHY_PATH-based module lookups resolve.
cat > ~/start-armarchy.sh << 'STARTEOF'
#!/bin/bash
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
mkdir -p "$XDG_RUNTIME_DIR"; chmod 700 "$XDG_RUNTIME_DIR"
[ -r /etc/profile.d/omarchy.sh ] && . /etc/profile.d/omarchy.sh
exec Hyprland
STARTEOF
chmod +x ~/start-armarchy.sh

cat > ~/README.txt << 'READMEEOF'
Welcome to ARMarchy Linux!

Start the desktop:  ./start-armarchy.sh   (or just: Hyprland)

Omarchy's real Hyprland configuration is applied in ~/.config/hypr (Lua).
Omarchy itself lives in /usr/share/omarchy (OMARCHY_PATH); its CLI is on PATH.
Note: Omarchy 4.0's quickshell bar isn't in this ARM image; a waybar fallback
is used instead. Customize the desktop by editing ~/.config/hypr/*.lua.
READMEEOF
APPLYEOF
chmod +x /mnt/usr/local/bin/armarchy-apply-omarchy
arch-chroot /mnt sudo -u $USERNAME bash -lc /usr/local/bin/armarchy-apply-omarchy

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
