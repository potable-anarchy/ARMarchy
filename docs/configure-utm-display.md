# How to Configure UTM Display for Hyprland

## Current Issue
The VM is running in **console-only mode** (serial terminal). Hyprland requires a graphical display with GPU support.

## Solution: Add GPU-Accelerated Display

### Manual Steps (UTM GUI)

1. **Stop the VM** (if running)
   ```bash
   /Applications/UTM.app/Contents/MacOS/utmctl stop ArchLinux
   ```

2. **Open UTM app** and select the ArchLinux VM

3. **Edit Settings** (right-click VM → Edit, or click the settings icon)

4. **Display Configuration:**
   - Click **"Display"** in the sidebar
   - Click **"New..."** to add a new display device
   - **Emulated Display Card:** Select `virtio-gpu-pci` or `virtio-ramfb-gl`
   - **Resolution:** 
     - Width: 1920
     - Height: 1080
     - (or your preferred resolution)
   - Enable **"Retina Mode"** if you have a high-DPI display
   
5. **Remove Console Display (optional):**
   - If you see a "Serial" or "Console" display, you can remove it
   - Or keep it as a backup for troubleshooting

6. **System Settings (verify):**
   - Click **"System"** in sidebar
   - Ensure **"GPU"** or **"Hardware acceleration"** is enabled
   
7. **Save** the configuration

8. **Start the VM**
   ```bash
   /Applications/UTM.app/Contents/MacOS/utmctl start ArchLinux
   ```

### What You Should See

After restarting with the new display:
- A graphical window (not just text console)
- TTY login prompt in the graphical window
- Ability to switch TTYs with Ctrl+Alt+F1, F2, etc.

### If Display Doesn't Work

**Fallback Option 1: Use SPICE Display**
- In UTM settings, try **"Console Only"** mode with SPICE
- This provides basic graphics without full GPU acceleration

**Fallback Option 2: Use VNC**
- Install TigerVNC in the VM:
  ```bash
  sudo pacman -S tigervnc
  ```
- Start VNC server and connect from macOS

**Fallback Option 3: Keep Console + SSH**
- Use the console for system management
- Use SSH for all command-line work
- Consider X11 forwarding for GUI apps

## After Display Configuration

Once the VM boots with a graphical display:

1. **Login at TTY** (the graphical login prompt)
   - Username: `omarchy`
   - Password: `omarchy`

2. **Set XDG_RUNTIME_DIR** (if not set)
   ```bash
   export XDG_RUNTIME_DIR=/run/user/$(id -u)
   ```

3. **Launch Hyprland**
   ```bash
   Hyprland
   ```

4. **Test Basic Functionality**
   - Super+Enter: Open terminal
   - Super+E: Open app launcher
   - Super+Q: Close window
   - Super+M: Exit Hyprland

## Alternative: Auto-start Hyprland on Login

Add to `~/.bash_profile` or `~/.zprofile`:

```bash
# Auto-start Hyprland on TTY1
if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
    exec Hyprland
fi
```

This will automatically launch Hyprland when you login on TTY1.

## GPU Driver Verification

Once in the VM with display:

```bash
# Check if virtio-gpu is loaded
lsmod | grep virtio

# Check DRI devices
ls -la /dev/dri/

# Install and test Mesa
sudo pacman -S mesa-utils
glxinfo | grep -i renderer
```

Expected output:
- `/dev/dri/card0` and `/dev/dri/renderD128` should exist
- `virtio_gpu` module should be loaded
- glxinfo should show "virgl" or "virtio" renderer

---

*Note: UTM's virtio-gpu support on Apple Silicon is still evolving. Some features may have limitations compared to native Linux installations.*
