# Installing ARMarchy from ISO

This guide explains how to install ARMarchy Linux using the Archboot ISO.

## What You'll Need

- **Archboot ISO**: `archboot-2025.11.21-02.06-6.17.8-1-aarch64-ARCH-latest-aarch64.iso` (284 MB)
- **Download URL**: https://release.archboot.com/aarch64/latest/iso/
- **UTM** or other ARM64 hypervisor (Parallels, VMware)
- **Disk Space**: 20GB minimum, 40GB+ recommended
- **RAM**: 4GB minimum, 8GB+ recommended

## Installation Process

ARMarchy installation is a two-step process:

1. **Base Arch Linux ARM installation** using Archboot ISO
2. **ARMarchy transformation** using the install script

### Step 1: Create New VM in UTM

1. Open UTM
2. Click **"Create a New Virtual Machine"**
3. Select **"Virtualize"**
4. Choose **"Linux"**
5. Configure settings:
   - **Boot ISO**: Select the downloaded Archboot ISO
   - **Architecture**: ARM64 (aarch64)
   - **RAM**: 4096 MB or more
   - **CPU Cores**: 4-8 cores
   - **Disk Size**: 40 GB
6. Click **"Save"**

### Step 2: Boot from ISO

1. Start the VM
2. At the Archboot boot menu, select:
   - **"Arch Linux Archboot Environment"**
3. Wait for the system to boot to a shell prompt

### Step 3: Install Base Arch Linux ARM

The Archboot ISO provides an automated installation script:

```bash
# Run the automatic installation
archboot-quickinst.sh
```

Follow the prompts:
- **Hostname**: `armarchy`
- **Timezone**: Your timezone (e.g., `America/New_York`)
- **Locale**: `en_US.UTF-8`
- **Keyboard**: `us` (or your layout)
- **Disk**: `/dev/vda` (or whatever disk is shown)
- **Partition scheme**: Use defaults (automatic partitioning)
- **Filesystem**: ext4 (recommended)
- **Root password**: Set a secure password
- **Create user**: Yes (e.g., `omarchy`)
- **User password**: Set a secure password

The installation will take 10-30 minutes depending on your internet speed.

### Step 4: Download ARMarchy Installer

After base installation completes, but **before** rebooting:

```bash
# Mount the installed system
mount /dev/vda2 /mnt  # Adjust partition number if needed
arch-chroot /mnt

# Download ARMarchy installer
curl -O https://raw.githubusercontent.com/potable-anarchy/omarchy-arm64-vm/main/armarchy/scripts/install-armarchy.sh
chmod +x install-armarchy.sh

# Run ARMarchy installer
./install-armarchy.sh
```

The ARMarchy installer will:
- Install Hyprland and all Omarchy dependencies
- Clone Omarchy configurations
- Set up user environment
- Install ARMarchy utilities
- Configure first-boot setup

This process takes 20-40 minutes.

### Step 5: Complete Installation

```bash
# Exit chroot
exit

# Unmount
umount -R /mnt

# Power off
poweroff
```

### Step 6: Remove ISO and Boot

1. In UTM, edit the VM settings
2. Remove the ISO from the CD/DVD drive
3. Start the VM
4. Login with the user you created
5. Run the first-boot setup:

```bash
sudo armarchy-setup
```

### Step 7: Start ARMarchy

```bash
# Start Hyprland
Hyprland
```

Your ARMarchy environment should now be running!

## Post-Installation

### Create Startup Script

For convenience, create a startup script:

```bash
cat > ~/start-armarchy.sh << 'EOF'
#!/bin/bash
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export HYPRLAND_INSTANCE_SIGNATURE=$(ls -t /run/user/$(id -u)/hypr/ 2>/dev/null | head -1)
Hyprland
EOF

chmod +x ~/start-armarchy.sh
```

### SSH Access

Enable SSH for remote access:

```bash
sudo systemctl enable --now sshd

# Find your VM's IP
ip addr show
```

You can now SSH from your Mac:

```bash
ssh omarchy@<VM_IP>
```

### UTM Display Optimization

If you experience display issues:

1. In UTM, go to VM Settings → Display
2. Try different display adapters:
   - `virtio-ramfb-gl` (best for Hyprland)
   - `virtio-gpu-pci` (fallback)
3. Enable **"Resize guest to fit window"**

## Troubleshooting

### No Network Connection

```bash
# Check network status
ip addr show

# Restart network
sudo systemctl restart systemd-networkd
```

### Disk Space Issues

If you run out of space during installation:

```bash
# Clean package cache
sudo pacman -Scc

# Remove unnecessary packages
sudo pacman -Rns $(pacman -Qdtq)
```

### Display Not Working

If Hyprland doesn't start:

```bash
# Check logs
journalctl -u display-manager

# Try Sway instead (lighter compositor)
sudo pacman -S sway
sway
```

### Installation Script Fails

If `install-armarchy.sh` fails:

1. Check your internet connection
2. Run `pacman -Syu` to update package database
3. Try running the script again
4. Check `/var/log/pacman.log` for errors

## Alternative: Manual Installation

If you prefer to install packages manually without the script:

```bash
# Install Hyprland group
sudo pacman -S hyprland

# Install CLI tools
sudo pacman -S bat eza ripgrep fd fzf starship

# Install GUI apps
sudo pacman -S chromium mpv

# Clone Omarchy
git clone https://github.com/basecamp/omarchy.git ~/omarchy
```

Then manually copy configurations from the Omarchy repo.

## Next Steps

- Explore [Omarchy documentation](https://github.com/basecamp/omarchy)
- Customize Hyprland configs in `~/.config/hypr/`
- Install additional packages with `pacman -S <package>`
- Read the [ARMarchy README](../../README.md)

## Resources

- **Archboot Documentation**: https://archboot.com
- **Arch Linux ARM**: https://archlinuxarm.org
- **Omarchy**: https://github.com/basecamp/omarchy
- **Hyprland**: https://hyprland.org

---

**ARMarchy Linux** - ARM64 + Omarchy = ARMarchy  
For support, visit: https://github.com/potable-anarchy/omarchy-arm64-vm/issues
