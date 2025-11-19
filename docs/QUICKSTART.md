# Omarchy ARM64 - Quick Start Guide

## Starting the System

```bash
ssh omarchy@192.168.64.6  # Password: omarchy
./start-omarchy.sh
```

**Result:** Hyprland desktop appears in UTM window with waybar at top.

## Essential Keybindings

| Key | Action |
|-----|--------|
| `SUPER + RETURN` | Open terminal |
| `SUPER + Q` | Close window |
| `SUPER + B` | Open Chromium |
| `SUPER + N` | Open Neovim |
| `SUPER + F` | Fullscreen |
| `SUPER + Arrows` | Move focus |

## Common Tasks

### Launch Applications
```bash
# From terminal or SSH
export HYPRLAND_INSTANCE_SIGNATURE=$(ls -t /run/user/1001/hypr/ | head -1)
hyprctl dispatch exec chromium
hyprctl dispatch exec foot
hyprctl dispatch exec nvim
```

### Take Screenshot
```bash
grim -g "$(slurp)" ~/screenshot.png
```

### Check System Status
```bash
fastfetch      # System info
btop           # System monitor  
hyprctl monitors  # Display info
hyprctl clients   # Open windows
```

### File Navigation (Modern Tools)
```bash
eza -la        # List files (colored, with icons)
bat file.txt   # View file with syntax highlighting
fd pattern     # Find files
rg pattern     # Search in files
z directory    # Jump to directory (after using cd)
```

### Git Operations
```bash
lazygit        # Interactive git TUI
```

## Configuration

**Hyprland config:** `~/.config/hypr/hyprland.conf`  
**Waybar config:** `~/.config/waybar/`  
**Omarchy utils:** `~/.local/share/omarchy/bin/`

## Troubleshooting

### Display not showing
```bash
# Restart Hyprland
pkill Hyprland
./start-omarchy.sh
```

### Waybar not visible
```bash
export HYPRLAND_INSTANCE_SIGNATURE=$(ls -t /run/user/1001/hypr/ | head -1)
hyprctl dispatch exec waybar
```

### Check what's running
```bash
ps aux | grep -E "Hyprland|waybar|mako"
```

## Useful Omarchy Scripts

```bash
omarchy-cmd-screenshot     # Screenshot utility
omarchy-cmd-screenrecord   # Screen recording
omarchy-font-list          # List available fonts
omarchy-font-set           # Change font
```

All scripts in `~/.local/share/omarchy/bin/`

## System Specs

- **Arch Linux ARM** 6.17.8-1-aarch64
- **Hyprland** 0.52.1
- **RAM:** 2GB
- **Storage:** ~10GB used
- **Display:** 1280x800 (virtio-gpu-pci)

## Next Steps

1. Customize `~/.config/hypr/hyprland.conf`
2. Install additional apps via `yay`
3. Explore Omarchy utilities
4. Set up your development environment

---

**Full Documentation:** See `PROGRESS.md` and `README.md`
