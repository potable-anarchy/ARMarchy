# ARMarchy Linux

**ARM64 Linux distro built on Arch Linux ARM + Omarchy configs for Apple Silicon Macs**

```
    _    ____  __  __                  _          
   / \  |  _ \|  \/  | __ _ _ __ ___| |__  _   _ 
  / _ \ | |_) | |\/| |/ _` | '__/ __| '_ \| | | |
 / ___ \|  _ <| |  | | (_| | | | (__| | | | |_| |
/_/   \_\_| \_\_|  |_|\__,_|_|  \___|_| |_|\__, |
                                           |___/ 
```

## What is ARMarchy?

ARMarchy is a complete, ready-to-use Linux distribution designed specifically for ARM64 Apple Silicon Macs. It combines the power of Arch Linux ARM with the beautiful Omarchy Hyprland configuration by DHH/37signals.

### Key Features

- 🎯 **Built for Apple Silicon** - Optimized for M1/M2/M3/M4 Macs
- 🎨 **Beautiful Desktop** - Hyprland compositor with Omarchy styling
- ⚡ **Fast & Lightweight** - Minimal overhead, maximum performance
- 🛠️ **Developer Ready** - 100+ essential tools pre-installed
- 🔧 **Hypervisor Optimized** - Auto-detects UTM, Parallels, VMware
- 📦 **Complete Package** - No assembly required, works out of the box

## Download

### Prebuilt VM (Recommended)

Download the ready-to-use VM via BitTorrent (13GB):

```
magnet:?xt=urn:btih:b8edadd5b6293ee2e72194cd9d4ff008d5a90b2f&dn=armarchy-v1.0.0
```

Or download: [armarchy-v1.0.0.torrent](../omarchy-arm64-vm-v1.0.0.torrent)

### ISO Installer

Install ARMarchy from scratch using Archboot ARM64 ISO:

**Quick Install:** [QUICK-ISO-INSTALL.md](QUICK-ISO-INSTALL.md)  
**Full Guide:** [docs/INSTALL-FROM-ISO.md](docs/INSTALL-FROM-ISO.md)

**Download ISO (284 MB):**
```bash
# Auto-resolve the current Archboot ARM64 ISO (the filename rotates on each release)
ISO=$(curl -s https://release.archboot.com/aarch64/latest/iso/ | grep -oE 'archboot-[^"]*-aarch64-ARCH-latest-aarch64\.iso' | sort -u | head -1)
curl -O "https://release.archboot.com/aarch64/latest/iso/$ISO"
```

**Installation time:** ~45-60 minutes

## Quick Start

### UTM (Free)

1. Download ARMarchy VM
2. Open in UTM
3. Start VM
4. Login: `armarchy` / `armarchy`
5. Enjoy!

### Parallels Desktop

1. Import ARMarchy VM
2. Configure for ARM64
3. Start and enjoy

## What's Included

### Desktop Environment
- **Hyprland 0.52.1** - Modern Wayland compositor
- **Waybar** - Beautiful status bar
- **Mako** - Notification daemon
- **Wofi** - Application launcher

### CLI Tools
- Modern replacements: `bat`, `eza`, `ripgrep`, `fd`, `fzf`
- System tools: `btop`, `dust`, `fastfetch`
- Development: `git`, `lazygit`, `neovim`, `tree-sitter`

### GUI Applications
- Chromium browser
- Neovim (GUI-enabled)
- Foot terminal
- Media: `mpv`, `imv`

### Omarchy Utilities
- 50+ utility scripts
- Modular Hyprland configuration
- Custom keybindings
- Workspace management

## System Requirements

- **Mac:** Apple Silicon (M1/M2/M3/M4)
- **macOS:** 12.0+ (Monterey or later)
- **Hypervisor:** UTM, Parallels, or VMware
- **RAM:** 4GB minimum, 8GB+ recommended
- **Disk:** 20GB free space

## Default Credentials

- **Username:** `armarchy`
- **Password:** `armarchy`

⚠️ **Change these on first boot!**

## Keybindings

| Key | Action |
|-----|--------|
| `SUPER + RETURN` | Terminal |
| `SUPER + E` | App Launcher |
| `SUPER + B` | Browser |
| `SUPER + Q` | Close Window |
| `SUPER + F` | Fullscreen |
| `SUPER + M` | Exit Hyprland |

See full keybindings in `~/.config/hypr/bindings.conf`

## First Boot Setup

ARMarchy includes a first-boot wizard to:
- Create your user account
- Set hostname
- Configure timezone/locale
- Detect and optimize for your hypervisor
- Update system packages

## Building from Source

Want to customize ARMarchy? Build it yourself:

```bash
git clone https://github.com/potable-anarchy/armarchy.git
cd armarchy
./scripts/build-armarchy.sh
```

See [BUILD.md](docs/BUILD.md) for details.

## Architecture

ARMarchy is built on:
- **Base:** Arch Linux ARM (aarch64)
- **Kernel:** Latest mainline
- **Init:** systemd
- **Display:** Wayland (Hyprland)
- **Shell:** zsh with starship prompt

## Differences from Standard Omarchy

Omarchy is designed for x86_64 physical hardware. ARMarchy adapts it for ARM64 virtual machines:

- ✅ All Omarchy configurations work
- ✅ Hyprland, Waybar, Mako fully functional
- ❌ Some x86_64-only apps unavailable
- ❌ No uwsm session manager (apps via hyprctl)
- ⚠️ GPU limited to OpenGL 2.1 (virtio-gpu)

## Community & Support

- **GitHub:** [potable-anarchy/armarchy](https://github.com/potable-anarchy/armarchy)
- **Issues:** [Report bugs](https://github.com/potable-anarchy/armarchy/issues)
- **Discussions:** [Ask questions](https://github.com/potable-anarchy/armarchy/discussions)

## Credits

ARMarchy stands on the shoulders of giants:

- **Omarchy** - [basecamp/omarchy](https://github.com/basecamp/omarchy) by DHH/37signals
- **Hyprland** - [hyprland.org](https://hyprland.org)
- **Arch Linux ARM** - [archlinuxarm.org](https://archlinuxarm.org)

## License

MIT License - Free and open source

---

**ARMarchy** - *ARM64 + Omarchy = Beautiful Linux on Apple Silicon*
