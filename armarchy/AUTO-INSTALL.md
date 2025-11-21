# ARMarchy Automatic Installation

**Zero-interaction installation of ARMarchy Linux**

## Quick Start

### 1. Download Archboot ISO (284 MB)

```bash
curl -O https://release.archboot.com/aarch64/latest/iso/archboot-2025.11.21-02.06-6.17.8-1-aarch64-ARCH-latest-aarch64.iso
```

### 2. Create VM in UTM

- **Boot ISO**: Select downloaded ISO
- **Architecture**: ARM64
- **RAM**: 4GB+
- **CPU**: 4-8 cores
- **Disk**: 40GB
- **Start VM**

### 3. Run Automatic Installer

Boot from ISO, then run this single command:

```bash
curl -sL https://raw.githubusercontent.com/potable-anarchy/omarchy-arm64-vm/main/armarchy/scripts/armarchy-autoinstall.sh | bash
```

### 4. Wait

The installer will:
- Partition disk automatically
- Install base Arch Linux ARM (10-15 min)
- Install all ARMarchy packages (20-30 min)
- Configure Hyprland + Omarchy (5 min)
- Reboot automatically

**Total time: 35-50 minutes** (unattended)

### 5. Login & Start

After reboot:

```bash
# Login as: omarchy / armarchy

./start-armarchy.sh
```

Done! ARMarchy is running.

## Default Configuration

| Setting | Value |
|---------|-------|
| Hostname | `armarchy` |
| Username | `armarchy` |
| Password | `armarchy` |
| Timezone | `America/Los_Angeles` (Cupertino) |
| Disk | `/dev/vda` |

## Customization

Set environment variables before running installer:

```bash
export ARMARCHY_HOSTNAME="myvm"
export ARMARCHY_USER="myuser"
export ARMARCHY_PASS="mypassword"
export ARMARCHY_TZ="Europe/London"

curl -sL https://raw.githubusercontent.com/potable-anarchy/omarchy-arm64-vm/main/armarchy/scripts/armarchy-autoinstall.sh | bash
```

## What Gets Installed

### Desktop Environment
- Hyprland (Wayland compositor)
- Waybar (status bar)
- Mako (notifications)
- Wofi (app launcher)
- Foot (terminal)

### CLI Tools
- Modern utils: bat, eza, ripgrep, fd, fzf, zoxide
- System tools: btop, fastfetch, ncdu, tldr
- Development: git, lazygit, neovim, tmux, zsh

### GUI Applications
- Chromium browser
- mpv media player
- imv image viewer
- Zathura PDF reader

### Development Tools
- Rust (rustup)
- Go
- Python + pip
- Node.js + npm

## Manual Installation

If you prefer step-by-step control, see:
- [INSTALL-FROM-ISO.md](docs/INSTALL-FROM-ISO.md)

## Troubleshooting

### Different Disk Name

If your disk isn't `/dev/vda`:

```bash
# Find your disk
lsblk

# Download and edit script
curl -O https://raw.githubusercontent.com/potable-anarchy/omarchy-arm64-vm/main/armarchy/scripts/armarchy-autoinstall.sh
nano armarchy-autoinstall.sh  # Change DISK="/dev/vda" to your disk
bash armarchy-autoinstall.sh
```

### Installation Fails

Check internet connection:
```bash
ping archlinux.org
```

If no network, configure it first:
```bash
nmcli device wifi connect "SSID" password "PASSWORD"
```

### Disk Already Partitioned

The script will erase the disk. To start fresh:
```bash
wipefs -a /dev/vda
```

## Post-Installation

### Change Password

```bash
passwd
```

### Enable SSH Access

SSH is already enabled! Find your IP:

```bash
ip addr show
```

From your Mac:
```bash
ssh omarchy@<VM_IP>
```

### Update System

```bash
sudo pacman -Syu
```

### Install More Packages

```bash
sudo pacman -S <package-name>
```

## Time Breakdown

| Step | Duration |
|------|----------|
| Disk partitioning | 1 min |
| Base system install | 10-15 min |
| System configuration | 2 min |
| ARMarchy packages | 20-30 min |
| Omarchy setup | 3-5 min |
| **Total** | **35-50 min** |

## Comparison

| Method | Time | Interaction | Customization |
|--------|------|-------------|---------------|
| **Autoinstall** | 35-50 min | None | Via env vars |
| Manual ISO | 60-90 min | High | Full control |
| Prebuilt VM | 10 min | None | Post-install only |

---

**ARMarchy Linux** - Automatic installation for Apple Silicon Macs  
ARM64 + Omarchy = ARMarchy
