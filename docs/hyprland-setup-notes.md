# Hyprland Installation and Setup Notes

## Current Status

**Installation In Progress:**
- Installing Hyprland 0.52.1 and dependencies
- Total packages: 182
- Download size: 186 MB
- Estimated time: 15-30 minutes

**Packages Being Installed:**
- `hyprland` - Wayland compositor
- `waybar` - Status bar for Wayland
- `kitty` - GPU-accelerated terminal emulator
- `wofi` - Application launcher
- `swww` - Wallpaper daemon for Wayland
- Plus 177 dependencies (Mesa, Wayland, GTK, etc.)

## After Installation Completes

### Step 1: Configure UTM Display

Currently the VM only has console display. We need GPU support for Hyprland.

**UTM Settings to Change:**
1. Stop the VM
2. Edit VM settings in UTM
3. Display tab:
   - **Emulated Display Card:** virtio-gpu-pci (or virtio-ramfb-gl)
   - **Resolution:** 1920x1080 (or preferred)
   - Enable **"Retina Mode"** if using high-DPI display
4. System tab:
   - Verify **GPU** is enabled
5. Save and restart VM

### Step 2: Create Hyprland Configuration

SSH into the VM and create config files:

```bash
ssh omarchy@192.168.64.6

# Create Hyprland config directory
mkdir -p ~/.config/hypr

# Create basic Hyprland config
cat > ~/.config/hypr/hyprland.conf << 'EOF'
# Monitor configuration
monitor=,preferred,auto,1

# Execute apps at launch
exec-once = waybar
exec-once = swww-daemon

# Environment variables
env = XCURSOR_SIZE,24
env = WLR_NO_HARDWARE_CURSORS,1

# Keybindings
$mainMod = SUPER

bind = $mainMod, RETURN, exec, kitty
bind = $mainMod, Q, killactive
bind = $mainMod, M, exit
bind = $mainMod, E, exec, wofi --show drun
bind = $mainMod, F, fullscreen

# Move focus with mainMod + arrow keys
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

# Window rules
windowrulev2 = float, class:^(wofi)$

# General settings
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
    animation = borderangle, 1, 8, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

dwindle {
    pseudotile = yes
    preserve_split = yes
}

master {
    new_status = master
}

gestures {
    workspace_swipe = off
}
EOF
```

### Step 3: Launch Hyprland

From the VM console or SSH with X11 forwarding:

```bash
# Option 1: Direct launch (if logged into console)
Hyprland

# Option 2: Start from TTY
# Login to console, then:
export XDG_RUNTIME_DIR=/run/user/$(id -u)
Hyprland

# Option 3: Create a display manager entry (future)
# Install ly, sddm, or gdm for graphical login
```

### Step 4: Test Basic Functionality

Once Hyprland launches:
- **Super + Enter**: Open Kitty terminal
- **Super + E**: Open Wofi launcher
- **Super + Q**: Close focused window
- **Super + M**: Exit Hyprland

## Troubleshooting

### If Hyprland Won't Start

1. Check logs:
   ```bash
   journalctl --user -xe
   ```

2. Verify display device:
   ```bash
   echo $DISPLAY
   ls -la /dev/dri/
   ```

3. Check Wayland socket:
   ```bash
   echo $WAYLAND_DISPLAY
   ls -la $XDG_RUNTIME_DIR/
   ```

### If No GPU Acceleration

1. Install Mesa drivers:
   ```bash
   sudo pacman -S mesa mesa-utils
   ```

2. Test OpenGL:
   ```bash
   glxinfo | grep renderer
   ```

3. Check virtio-gpu kernel module:
   ```bash
   lsmod | grep virtio
   ```

## Additional Packages to Consider

**Terminal Emulators:**
- `alacritty` - Lightweight alternative to Kitty
- `foot` - Minimal Wayland terminal

**Status Bars:**
- `eww` - Widget system (alternative to Waybar)
- `yambar` - Lightweight status bar

**Launchers:**
- `rofi-wayland` - More feature-rich launcher
- `fuzzel` - Minimal launcher

**File Managers:**
- `thunar` - GTK file manager
- `pcmanfm` - Lightweight file manager
- `ranger` - Terminal file manager

**System Tools:**
- `grim` - Screenshot tool for Wayland
- `slurp` - Region selector for screenshots
- `wl-clipboard` - Clipboard manager
- `mako` - Notification daemon

**Theming:**
- `qt5-wayland` - Qt5 Wayland support
- `qt6-wayland` - Qt6 Wayland support
- `nwg-look` - GTK theme switcher
- `kvantum` - Qt theme engine

## Next Steps After Hyprland Works

1. Install Omarchy-specific components
2. Apply Omarchy theming
3. Set up development environment
4. Configure keybindings to match Omarchy defaults
5. Install Omarchy application suite

---

*Installation started: November 16, 2025 17:30 PST*
