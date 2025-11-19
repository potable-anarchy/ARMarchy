# Building Omarchy ARM64 VM

This guide walks you through building the Omarchy ARM64 VM from scratch.

## Why Build from Source?

The complete VM is ~87GB, which is too large for GitHub releases. Building from source ensures you get the latest packages and can customize the installation.

**Estimated Time:** 1-2 hours (mostly automated)

## Prerequisites

- **Mac:** Apple Silicon (M1/M2/M3/M4)
- **macOS:** 12.0+ (Monterey or later)
- **UTM:** Latest version ([download here](https://mac.getutm.app))
- **Disk Space:** 100GB free recommended
- **RAM:** 8GB+ recommended

## Quick Build Method

### Step 1: Install UTM

Download and install UTM from https://mac.getutm.app

### Step 2: Create Base Arch Linux VM

1. Download Arch Linux ARM ISO (included in this repo's downloads)
2. Open UTM and create a new VM:
   - **System:** Virtualize (ARM64)
   - **Operating System:** Linux
   - **RAM:** 4096 MB (4GB)
   - **CPU:** 4 cores
   - **Storage:** 100GB

3. **Important Display Settings:**
   - Display: virtio-gpu-pci
   - Resolution: 1280x800 or higher

4. Boot from the ISO and follow basic Arch Linux installation

### Step 3: Run Automated Setup

Once you have a basic Arch Linux installation:

```bash
# Clone this repository on your Mac
git clone https://github.com/potable-anarchy/omarchy-arm64-vm.git
cd omarchy-arm64-vm

# SSH into the VM (after setting up SSH)
ssh root@<vm-ip>

# Run the setup script
curl -sSL https://raw.githubusercontent.com/potable-anarchy/omarchy-arm64-vm/main/scripts/setup-vm.sh | bash
```

### Step 4: Install Omarchy Configuration

```bash
# SSH as your user (not root)
ssh omarchy@<vm-ip>

# Sync Omarchy configs
curl -sSL https://raw.githubusercontent.com/potable-anarchy/omarchy-arm64-vm/main/scripts/sync-full-omarchy.sh | bash
```

## Manual Build Method

For complete control, follow these detailed guides:

1. **[Arch Install Guide](arch-install-guide.md)** - Complete Arch Linux ARM installation
2. **[UTM Setup Guide](UTM-SETUP-GUIDE.md)** - Optimize UTM configuration
3. **[Hyprland Setup](hyprland-setup-notes.md)** - Install and configure Hyprland
4. **[Display Configuration](configure-utm-display.md)** - Fix any display issues

## Post-Installation

### Access the VM

```bash
# SSH access
ssh omarchy@<vm-ip>
# Default password: omarchy

# Start Hyprland
./start-omarchy.sh
```

### Customize

The VM includes all Omarchy configurations at:
- `~/.config/hypr/` - Hyprland configs
- `~/.local/share/omarchy/` - Omarchy scripts and utilities

Feel free to modify any configs to suit your preferences.

## Package List

The automated setup installs 100+ packages including:

### Base System
- linux, linux-firmware, base-devel
- networkmanager, openssh, sudo

### CLI Tools
- bat, eza, ripgrep, fd, fzf, zoxide, starship
- git, lazygit, neovim, btop, dust, fastfetch

### Wayland/Hyprland
- hyprland, waybar, mako, wofi
- grim, slurp, wl-clipboard
- hypridle, hyprlock, hyprpicker

### GUI Applications
- chromium, foot (terminal)
- imv (image viewer), mpv (media player)

### Fonts
- ttf-jetbrains-mono-nerd
- noto-fonts, noto-fonts-emoji

## Troubleshooting

### Display Issues

If Hyprland doesn't start or has glitches:
- Ensure virtio-gpu-pci is selected in UTM
- Check resolution is set to 1280x800 or higher
- See [Display Configuration Guide](configure-utm-display.md)

### Performance Issues

- M1/M2 Macs: Expect some lag due to OpenGL 2.1 limitation
- M3+ Macs: Better performance
- Consider using simpler apps if rendering is slow

### Package Installation Fails

```bash
# Update package database
sudo pacman -Syu

# Clear package cache
sudo pacman -Scc
```

## Optimization Tips

### Reduce VM Size

After installation:

```bash
# Clear package cache
sudo pacman -Scc --noconfirm

# Clear journal logs
sudo journalctl --vacuum-time=1d

# Clear user caches
rm -rf ~/.cache/*
```

### Improve Performance

- Allocate more RAM (8GB+ if available)
- Use more CPU cores (6-8 if available)
- Enable GPU acceleration in UTM settings

## Contributing

Found a way to improve the build process? See [CONTRIBUTING.md](../CONTRIBUTING.md)

## Support

- **Issues:** https://github.com/potable-anarchy/omarchy-arm64-vm/issues
- **Discussions:** Use GitHub Discussions for questions
- **Omarchy Docs:** https://github.com/basecamp/omarchy

---

**Next:** [Quick Start Guide](QUICKSTART.md) to use your new VM
