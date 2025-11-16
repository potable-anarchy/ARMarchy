# Omarchy Linux ARM64 VM for UTM

Setting up Omarchy Linux on ARM64 architecture in UTM with Hyprland window manager.

## Project Overview

Omarchy Linux is a beautiful, modern & opinionated Linux distribution by DHH, built on Arch Linux. However, it only provides official x86-64 ISOs. This project aims to run Omarchy on ARM64 (Apple Silicon) by:

1. Starting with Arch Linux ARM as the base system
2. Bootstrapping Omarchy components on top
3. Configuring Hyprland window manager for a modern desktop experience
4. Running everything in UTM with proper ARM64 virtualization

## Current Status

**✅ Completed:**
- Repository created and initialized
- Arch Linux ARM VM downloaded (532MB pre-built image from UTM gallery)
- VM imported and running in UTM
- Setup scripts created for automated installation

**⚠️ In Progress:**
- Installing QEMU guest agent for remote control
- Configuring SSH access to enable automated setup

**🔜 Next Steps:**
- Complete base system setup (SSH, guest agent, sudo)
- Bootstrap Omarchy components
- Install and configure Hyprland
- Set up GUI environment with proper display support
- Document the complete installation process

## Quick Start

### Prerequisites

- macOS with Apple Silicon (M1/M2/M3/M4)
- UTM installed from [https://mac.getutm.app](https://mac.getutm.app)
- Minimum 4GB RAM available for VM
- 20GB+ free disk space

### VM Setup

1. **Import the VM:**
   ```bash
   open ~/code/omarchy-arm64-vm/downloads/ArchLinux.utm
   ```

2. **Start the VM in UTM**

3. **Initial Setup (in VM console):**
   
   Login: `root` / `root`
   
   Run these commands to enable remote access:
   ```bash
   # Unlock pacman database if needed
   killall pacman 2>/dev/null || true
   rm -f /var/lib/pacman/db.lck
   
   # Install essential packages
   pacman -Sy --noconfirm qemu-guest-agent openssh git base-devel sudo vim
   
   # Enable services
   systemctl enable --now qemu-guest-agent
   systemctl enable --now sshd
   
   # Set password
   echo 'root:omarchy' | chpasswd
   
   # Get IP address for SSH
   ip -4 addr show | grep inet
   ```

4. **SSH into VM:**
   ```bash
   ssh root@<VM_IP_ADDRESS>
   # Password: omarchy
   ```

5. **Run automated setup:**
   ```bash
   # Copy setup script to VM
   scp ~/code/omarchy-arm64-vm/setup-vm.sh root@<VM_IP_ADDRESS>:/root/
   
   # SSH in and run it
   ssh root@<VM_IP_ADDRESS>
   chmod +x /root/setup-vm.sh
   /root/setup-vm.sh
   ```

## Repository Structure

```
omarchy-arm64-vm/
├── README.md              # This file
├── PROGRESS.md            # Detailed progress log and notes
├── downloads/             # Downloaded VM images (gitignored)
│   └── ArchLinux.utm/    # Arch Linux ARM VM
├── setup-vm.sh            # Main automated setup script
├── quick-setup.txt        # Quick reference commands
├── auto-setup.exp         # Expect script (non-functional - UTM limitation)
└── setup-via-gui.sh       # Manual setup instructions
```

## Architecture Decisions

### Why Arch Linux ARM?
- Omarchy is built on Arch Linux, so ARM variant provides the closest base
- Access to full Arch package repositories and AUR
- Lightweight and customizable
- Better package compatibility with Omarchy's components

### Why UTM?
- Native ARM64 virtualization on Apple Silicon
- Better performance than emulation
- Good GUI and some CLI support
- Free and open source

### Current Limitations
- `utmctl attach` command not yet implemented (can't automate console interaction)
- QEMU guest agent not pre-installed (requires manual initial setup)
- No official Omarchy ARM64 packages (need to adapt installation)

## Resources

- [Omarchy Official Site](https://omarchy.org/)
- [Omarchy GitHub](https://github.com/basecamp/omarchy)
- [UTM Documentation](https://docs.getutm.app/)
- [UTM Gallery - Arch Linux ARM](https://mac.getutm.app/gallery/archlinux-arm)
- [Arch Linux ARM](https://archlinuxarm.org/)
- [Hyprland](https://hyprland.org/)

## Credentials

**Default VM Login:**
- Username: `root`
- Password: `root` (changed to `omarchy` after setup)

**After Setup:**
- Username: `root` or `omarchy`
- Password: `omarchy`

## Contributing

This is a personal project for getting Omarchy running on ARM64. Feel free to fork and adapt for your own use.

---

*Last Updated: November 16, 2025*
*Project Status: Initial Setup Phase*
