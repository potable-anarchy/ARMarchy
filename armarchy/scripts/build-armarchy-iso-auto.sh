#!/bin/bash
#
# Build ARMarchy Auto-Install ISO
# Creates a customized Archboot ISO that installs ARMarchy automatically
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARMARCHY_ROOT="$(dirname "$SCRIPT_DIR")"
WORK_DIR="/tmp/armarchy-iso-build"
ISO_DIR="$ARMARCHY_ROOT/../downloads"
BASE_ISO="archboot-2026.08.20-02.07-7.2.0-1-aarch64-ARCH-latest-aarch64.iso"
OUTPUT_ISO="armarchy-linux-v1.1.0-aarch64-auto.iso"

echo "=================================="
echo "ARMarchy Auto-Install ISO Builder"
echo "=================================="
echo ""

# Check if running on macOS
if [ "$(uname)" != "Darwin" ]; then
    echo "This script is designed for macOS"
    exit 1
fi

# Check for required tools
for cmd in mkisofs xorriso; do
    if ! command -v $cmd &> /dev/null; then
        echo "Installing required tool: $cmd"
        brew install $cmd 2>/dev/null || {
            echo "ERROR: Please install $cmd with: brew install cdrtools xorriso"
            exit 1
        }
    fi
done

echo "Step 1: Preparing build directory..."
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"/{mnt,extract,overlay}

echo ""
echo "Step 2: Mounting base ISO..."
if [ ! -f "$ISO_DIR/$BASE_ISO" ]; then
    echo "ERROR: Base ISO not found at $ISO_DIR/$BASE_ISO"
    echo "Please download it first with:"
    echo "  curl -O https://release.archboot.com/aarch64/latest/iso/$BASE_ISO"
    exit 1
fi

# Mount ISO on macOS
hdiutil attach -mountpoint "$WORK_DIR/mnt" "$ISO_DIR/$BASE_ISO"

echo ""
echo "Step 3: Extracting ISO contents..."
rsync -a "$WORK_DIR/mnt/" "$WORK_DIR/extract/"

echo ""
echo "Step 4: Unmounting base ISO..."
hdiutil detach "$WORK_DIR/mnt"

echo ""
echo "Step 5: Creating autoinstall configuration..."

# Create autoinstall script
cat > "$WORK_DIR/overlay/autoinstall.sh" << 'AUTOEOF'
#!/bin/bash
#
# ARMarchy Automatic Installation Script
# Runs on first boot from ISO
#

set -e

# Default configuration
HOSTNAME="armarchy"
USERNAME="omarchy"
PASSWORD="armarchy"
TIMEZONE="America/New_York"
LOCALE="en_US.UTF-8"
DISK="/dev/vda"

echo "======================================"
echo "ARMarchy Automatic Installation"
echo "======================================"
echo ""

# Partition disk automatically
echo "Partitioning $DISK..."
parted -s "$DISK" mklabel gpt
parted -s "$DISK" mkpart primary fat32 1MiB 512MiB
parted -s "$DISK" set 1 esp on
parted -s "$DISK" mkpart primary ext4 512MiB 100%

# Format partitions
echo "Formatting partitions..."
mkfs.fat -F32 "${DISK}1"
mkfs.ext4 -F "${DISK}2"

# Mount filesystems
echo "Mounting filesystems..."
mount "${DISK}2" /mnt
mkdir -p /mnt/boot
mount "${DISK}1" /mnt/boot

# Install base system
echo "Installing base system..."
pacstrap /mnt base base-devel linux linux-firmware

# Generate fstab
echo "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot and configure
echo "Configuring system..."
arch-chroot /mnt /bin/bash << CHROOTEOF
# Set timezone
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc

# Set locale
echo "$LOCALE UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=$LOCALE" > /etc/locale.conf

# Set hostname
echo "$HOSTNAME" > /etc/hostname
cat > /etc/hosts << HOSTSEOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
HOSTSEOF

# Install bootloader
pacman -S --noconfirm grub efibootmgr
grub-install --target=arm64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Install networking
pacman -S --noconfirm networkmanager openssh
systemctl enable NetworkManager sshd

# Create user
useradd -m -G wheel -s /bin/bash $USERNAME
echo "$USERNAME:$PASSWORD" | chpasswd
echo "root:$PASSWORD" | chpasswd

# Enable sudo for wheel
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Install ARMarchy
echo "Installing ARMarchy packages..."
pacman -S --noconfirm \
    hyprland waybar mako wofi foot grim slurp wl-clipboard \
    polkit xdg-desktop-portal-hyprland \
    bat eza ripgrep fd fzf zoxide starship fastfetch btop ncdu \
    chromium mpv imv neovim git

# Clone Omarchy
git clone https://github.com/basecamp/omarchy.git /home/$USERNAME/omarchy
chown -R $USERNAME:$USERNAME /home/$USERNAME/omarchy

# Setup user configs
sudo -u $USERNAME bash << USEREOF
cd ~
mkdir -p ~/.config/{hypr,waybar,mako,wofi,foot}

# Copy any Omarchy configs that exist
if [ -d ~/omarchy/config ]; then
    cp -r ~/omarchy/config/* ~/.config/ 2>/dev/null || true
fi

# Create startup script
cat > ~/start-armarchy.sh << 'STARTEOF'
#!/bin/bash
export XDG_RUNTIME_DIR="/run/user/\$(id -u)"
mkdir -p "\$XDG_RUNTIME_DIR"
chmod 700 "\$XDG_RUNTIME_DIR"
Hyprland
STARTEOF
chmod +x ~/start-armarchy.sh
USEREOF

CHROOTEOF

# Unmount and finish
echo "Cleaning up..."
umount -R /mnt

echo ""
echo "======================================"
echo "ARMarchy Installation Complete!"
echo "======================================"
echo ""
echo "System will reboot in 10 seconds..."
echo ""
echo "Default credentials:"
echo "  Username: $USERNAME"
echo "  Password: $PASSWORD"
echo ""
echo "After reboot, login and run:"
echo "  ./start-armarchy.sh"
echo ""
sleep 10
reboot
AUTOEOF

chmod +x "$WORK_DIR/overlay/autoinstall.sh"

echo ""
echo "Step 6: Modifying boot configuration for autostart..."

# Modify grub config to auto-run installer
cat > "$WORK_DIR/extract/boot/grub/grub.cfg" << 'GRUBEOF'
set timeout=5
set default=0

menuentry "ARMarchy Linux - Automatic Installation" {
    linux /boot/vmlinuz-linux archisobasedir=arch archisolabel=ARCH_$(date +%Y%m) quiet autoinstall
    initrd /boot/initramfs-linux.img
}

menuentry "ARMarchy Linux - Manual Installation" {
    linux /boot/vmlinuz-linux archisobasedir=arch archisolabel=ARCH_$(date +%Y%m)
    initrd /boot/initramfs-linux.img
}
GRUBEOF

# Add autoinstall service
mkdir -p "$WORK_DIR/extract/etc/systemd/system"
cat > "$WORK_DIR/extract/etc/systemd/system/armarchy-autoinstall.service" << 'SERVICEEOF'
[Unit]
Description=ARMarchy Automatic Installation
After=network.target

[Service]
Type=oneshot
ExecStart=/autoinstall.sh
StandardOutput=journal+console
StandardError=journal+console

[Install]
WantedBy=multi-user.target
SERVICEEOF

# Copy autoinstall script to ISO
cp "$WORK_DIR/overlay/autoinstall.sh" "$WORK_DIR/extract/"

echo ""
echo "Step 7: Building ARMarchy ISO..."
cd "$WORK_DIR/extract"

xorriso -as mkisofs \
    -iso-level 3 \
    -full-iso9660-filenames \
    -volid "ARMARCHY_AUTO" \
    -eltorito-boot boot/grub/i386-pc/eltorito.img \
    -eltorito-catalog boot/grub/boot.cat \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    -isohybrid-mbr /usr/lib/syslinux/bios/isohdpfx.bin \
    -eltorito-alt-boot \
    -e boot/grub/efi.img \
    -no-emul-boot \
    -isohybrid-gpt-basdat \
    -output "$ISO_DIR/$OUTPUT_ISO" \
    .

echo ""
echo "Step 8: Cleaning up..."
cd /
rm -rf "$WORK_DIR"

echo ""
echo "======================================"
echo "ARMarchy ISO Build Complete!"
echo "======================================"
echo ""
echo "Output: $ISO_DIR/$OUTPUT_ISO"
echo ""
echo "Size: $(du -h "$ISO_DIR/$OUTPUT_ISO" | cut -f1)"
echo ""
echo "To use:"
echo "1. Create new VM in UTM"
echo "2. Boot from $OUTPUT_ISO"
echo "3. Select 'ARMarchy Linux - Automatic Installation'"
echo "4. Wait 30-45 minutes"
echo "5. Login with omarchy/armarchy"
echo "6. Run ./start-armarchy.sh"
echo ""
