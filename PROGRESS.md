# Progress Log - Omarchy ARM64 VM Setup

## Session: November 16-17, 2025 - OMARCHY ON ARM64 IN PROGRESS! 🚀

### Current Status (as of November 17, 01:37 PST)
✅ **Hyprland fully operational on ARM64!**  
✅ **Omarchy configurations fully integrated!**  
🔄 **Application stack installation: 577/~700 packages** (in progress)  
✅ Display output active at 1280x800 via virtio-gpu-pci  
✅ Omarchy's waybar + mako notifications running  
✅ **Nerd Fonts fixed** - Cascadia Code Nerd Font installed, waybar icons displaying  
✅ 70+ applications installed (CLI + GUI)  
✅ Neovim, Chromium, mpv, and all core tools  
✅ Omarchy utilities in PATH  
✅ One-command startup script  
✅ Window management with Omarchy keybindings  
✅ Modular config structure from Omarchy  

### Objective
Get FULL Omarchy Linux running in an ARM64 VM in UTM with complete functionality. **IN PROGRESS!**

### Latest Session Goals
- Install ALL Omarchy applications for complete functionality
- Fix waybar icon display issues (✅ COMPLETED - fonts installed)
- Enable all system services (bluetooth, NetworkManager, etc.)

---

## ✅ MAJOR BREAKTHROUGH - Working Arch Linux ARM VM!

### Summary
After multiple attempts with old pre-built VMs that had library dependency issues, we successfully upgraded a fresh VM to a fully working, modern Arch Linux ARM system.

---

## Complete Progress

### Phase 1: Initial Attempts ❌

**Problem:** Pre-built UTM Gallery VM (from 2022) had severe library dependency issues
- glibc 2.35 (needed 2.36-2.38)
- Old OpenSSL 1.1 (needed OpenSSL 3.x)
- Any `pacman -Sy` operation created partial upgrades that broke systemd and SSH

**Failures:**
1. Tried installing SSH first → dependency hell
2. Tried manual library extraction → still incompatible
3. Attempted partial upgrade → kernel panic on reboot

### Phase 2: The Successful Strategy ✅

**Key Insight:** Do a full atomic upgrade of ALL packages before rebooting

**Winning Approach:**
1. Import completely fresh pre-built VM
2. Login as `alarm` (not root)
3. Run ONE comprehensive upgrade command that updates everything atomically
4. Reboot into the upgraded system

**Command Used:**
```bash
rm -f /var/lib/pacman/db.lck && pacman -Syu --noconfirm && \
pacman -S --noconfirm openssh qemu-guest-agent base-devel git sudo vim && \
useradd -m -G wheel -s /bin/bash omarchy && \
echo 'omarchy:omarchy' | chpasswd && \
echo 'root:omarchy' | chpasswd && \
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers && \
echo -e "\nPermitRootLogin yes\nPasswordAuthentication yes" >> /etc/ssh/sshd_config
```

### Phase 3: Current System Status ✅

**VM Configuration:**
- **VM Name:** ArchLinux
- **UUID:** 2F2C4095-EC5B-49CD-A654-FE17D7EC7CAA
- **Status:** ✅ Running and fully operational
- **IP Address:** 192.168.64.6
- **SSH Access:** ✅ Working perfectly

**System Information:**
```
Kernel: Linux 6.17.8-1-aarch64-ARCH
OS: Arch Linux ARM (November 15, 2025 build)
Architecture: aarch64 (ARM64 native)
Init System: systemd (fully functional)
```

**Installed and Configured:**
- ✅ SSH server (openssh) - password auth enabled
- ✅ QEMU guest agent
- ✅ Base development tools (base-devel)
- ✅ Git, sudo, vim
- ✅ Yay (AUR helper) v12.5.2
- ✅ Go compiler (for AUR builds)

**User Accounts:**
- `root` / password: `omarchy`
- `alarm` / password: `alarm` (default user)
- `omarchy` / password: `omarchy` (created, wheel group, passwordless sudo)

**Network:**
- Shared network mode (UTM default)
- DHCP assigned: 192.168.64.6
- Internet access: ✅ Working
- SSH accessible from host: ✅ Working

---

## Achievements

### ✅ Completed Tasks

1. **VM Setup & Import**
   - Downloaded pre-built Arch ARM VM (532MB)
   - Automated deletion and re-import of fresh VMs via utmctl
   - Successfully started VM programmatically

2. **System Upgrade**
   - Upgraded from 2022 packages to November 2025 (latest)
   - Resolved glibc 2.35 → 2.38 upgrade
   - Resolved OpenSSL 1.1 → 3.x transition
   - System boots cleanly after full upgrade

3. **Remote Access**
   - SSH server installed and configured
   - Password authentication enabled
   - Passwordless sudo configured for omarchy user
   - Automated SSH interactions via Expect scripts

4. **Development Environment**
   - Git installed
   - Base development tools (gcc, make, etc.)
   - Yay AUR helper installed and working
   - Ready for building AUR packages

5. **Automation**
   - Created utmctl wrapper scripts
   - Automated VM lifecycle (delete, import, start)
   - Automated SSH-based package installation
   - Created expect scripts for password automation

---

## Next Steps

### Immediate Tasks

1. **Install Hyprland** (pending)
   - Install via yay from AUR
   - Required packages: hyprland, waybar, kitty/alacritty, wofi
   - Dependencies will be handled by yay

2. **Configure UTM Display** (pending)
   - Current: Console-only (serial terminal)
   - Need: GPU-accelerated display for Hyprland
   - Change UTM settings:
     - Display: virtio-gpu-pci
     - Enable OpenGL/GPU acceleration
     - Set resolution (1920x1080 recommended)

3. **Hyprland Configuration** (pending)
   - Create ~/.config/hypr/hyprland.conf
   - Set up keybindings
   - Configure terminal, launcher, status bar
   - Test Wayland/Hyprland launch

### Omarchy Bootstrap (Future)

1. Research Omarchy installation approach
2. Identify which Omarchy components work on ARM64
3. Install Omarchy theming and configurations
4. Test compatibility with Hyprland
5. Document any ARM64-specific adjustments needed

---

## Technical Solutions

### Challenge 1: Library Dependency Hell
**Solution:** Full atomic upgrade (`pacman -Syu`) before any other operations

### Challenge 2: SSH Access
**Solution:** Install SSH and configure password auth in same session as upgrade, before reboot

### Challenge 3: Automation Without Console Access
**Solution:** Hybrid approach - manual initial commands, then full SSH automation

### Challenge 4: Sudo Password Prompts
**Solution:** Created `/etc/sudoers.d/wheel` with NOPASSWD for wheel group

---

## Scripts & Tools Created

1. **`careful-upgrade-strategy.md`** - Documentation of successful upgrade approach
2. **`one-shot-upgrade.sh`** - One-command upgrade script
3. **`safe-initial-setup.txt`** - Initial setup commands  
4. **`UTM-SETUP-GUIDE.md`** - Guide for creating VMs from Archboot ISO (backup plan)
5. **`arch-install-guide.md`** - Complete Arch installation guide (if needed)
6. **Expect scripts** - Various automation scripts for SSH interactions
7. **Downloaded Archboot ISO** - archboot-2025.11.16 (backup, not needed after success)

---

## Resources Used

### Official Documentation
- [Arch Linux ARM](https://archlinuxarm.org/)
- [UTM Documentation](https://docs.getutm.app/)
- [Hyprland Wiki](https://wiki.hyprland.org/)

### Community Resources
- [Archboot ISOs](https://archboot.com/) - ARM64 bootable ISOs
- [UTM Gallery](https://mac.getutm.app/gallery/archlinux-arm) - Pre-built VMs
- [Yay AUR Helper](https://github.com/Jguer/yay)

### Research Articles
- GitHub Gist: Arch ARM M1 VM build guide
- Blog posts on running Arch ARM in UTM
- Hyprland on ARM64 compatibility notes

---

## Latest Development: Hyprland Backend Fix

### Problem: Backend Initialization Failure
Hyprland crashed with `CBackend::create() failed!` even with GPU working and software rendering attempted.

**Root Cause:** libseat could not access seatd service
```
[ERR] [AQ] [libseat] Could not connect to socket /run/seatd.sock: No such file or directory
[ERR] [AQ] libseat: failed to open a seat
[CRITICAL] Cannot open backend: no allocator available
```

### Solution: Install and Enable seatd
```bash
sudo pacman -S --noconfirm seatd
sudo systemctl enable --now seatd
sudo usermod -aG seat omarchy
```

**Verification:**
- Socket exists: `/run/seatd.sock` with proper permissions
- Service running: `systemctl status seatd`
- User in seat group: `groups` shows `omarchy seat wheel`

### Solution Applied
All fixes implemented successfully - Hyprland now running with full display output.

---

## Phase 4: Final Configuration and Success ✅

### Terminal Application Fix
**Problem:** kitty terminal crashed with EGL/OpenGL errors in VM environment
```
[glfw error 65543]: EGL: Failed to create context: Arguments are inconsistent
Segmentation fault (core dumped)
```

**Solution:** Installed `foot` terminal emulator (lightweight, no OpenGL dependency)
```bash
yay -S --noconfirm foot
hyprctl dispatch exec foot
```

**Result:** Terminal launches successfully, full window management working

### Final Working Configuration

**Hyprland Display:**
- Monitor: Virtual-1 (Red Hat Inc. QEMU Monitor)
- Resolution: 1280x800@74.99Hz
- DRM Backend: Working via virtio-gpu-pci
- Framebuffer: /dev/fb1 (virtio_gpudrmfb)

**Running Services:**
- Hyprland compositor (PID varies)
- waybar status bar
- seatd seat management daemon
- foot terminal emulator

**User Permissions:**
- Groups: omarchy, wheel, input, video, seat
- seatd socket: 777 permissions (world-accessible)
- DRI devices: Accessible via video group

**Keybindings:**
- `SUPER + RETURN`: Launch foot terminal
- `SUPER + Q`: Close window
- `SUPER + M`: Exit Hyprland
- `SUPER + E`: Launch wofi (app launcher)
- `SUPER + F`: Fullscreen
- `SUPER + arrows`: Navigate windows

### How to Start Hyprland

**From SSH:**
```bash
ssh omarchy@192.168.64.6
nohup Hyprland > /tmp/hyprland.out 2>&1 &
```

**From UTM Console:**
1. Login as `omarchy` / `omarchy`
2. Run `Hyprland`
3. Display activates automatically

---

## Phase 5: Omarchy Integration ✅

### Challenge: Omarchy Requires x86_64
Omarchy's official installer (`boot.sh`) checks for x86_64 architecture, Limine bootloader, and Btrfs filesystem - none of which we have on ARM64 with ext4.

### Solution: Manual Configuration Adaptation
Instead of running the full installer, we extracted and adapted Omarchy's configuration files:

**Steps:**
1. Cloned Omarchy repository: `git clone https://github.com/basecamp/omarchy.git`
2. Ran `boot.sh` which cloned to `~/.local/share/omarchy/`
3. Copied Omarchy's Hyprland configs: `cp -r ~/.local/share/omarchy/default/hypr/* ~/.config/hypr/`
4. Created main `hyprland.conf` that sources Omarchy's modular configs
5. Simplified `autostart.conf` to remove uwsm dependencies

**Omarchy Config Structure:**
```
~/.config/hypr/
├── hyprland.conf          # Main entry point (custom)
├── envs.conf              # Environment variables (Omarchy)
├── input.conf             # Input settings (Omarchy)
├── looknfeel.conf         # Visual styling (Omarchy)
├── windows.conf           # Window rules (Omarchy)
├── bindings.conf          # Keybindings (Omarchy)
├── apps.conf              # App-specific tweaks (Omarchy)
└── autostart.conf         # Startup apps (simplified)
```

**Working Configuration:**
- Hyprland with Omarchy's look and feel
- Waybar status bar (launched via `hyprctl dispatch exec waybar`)
- Foot terminal emulator
- Omarchy keybindings and window rules
- Modular config system

**Limitations on ARM64:**
- ❌ Cannot run full Omarchy installer (x86_64 only)
- ❌ Some apps unavailable on ARM64 (check AUR)
- ❌ uwsm (session manager) not used - manual app launch
- ✅ Configurations work perfectly
- ✅ Visual theme applies correctly
- ✅ Keybindings functional

### Current Setup
```bash
# Start Hyprland with Omarchy configs
ssh omarchy@192.168.64.6
nohup Hyprland > /tmp/hyprland-omarchy.log 2>&1 &

# Launch waybar
export HYPRLAND_INSTANCE_SIGNATURE=$(ls -t /run/user/1001/hypr/ | head -1)
hyprctl dispatch exec waybar

# Launch terminal
hyprctl dispatch exec foot
```

---

## Phase 6: Application Stack Installation ✅

### Installed Applications

**CLI Utilities:**
- `bat` - Better cat with syntax highlighting
- `eza` - Modern ls replacement
- `ripgrep` - Fast grep alternative
- `fd` - Fast find alternative
- `fzf` - Fuzzy finder
- `zoxide` - Smart cd replacement
- `starship` - Cross-shell prompt
- `btop` - System monitor
- `dust` - Disk usage analyzer
- `lazygit` - Git TUI
- `fastfetch` - System info
- `tree-sitter-cli` - Parser generator

**Wayland/Hyprland Tools:**
- `grim` - Screenshot utility
- `slurp` - Region selector
- `wl-clipboard` - Clipboard manager
- `hypridle` - Idle daemon
- `hyprlock` - Screen locker
- `hyprpicker` - Color picker
- `mako` - Notification daemon
- `imv` - Image viewer
- `mpv` - Video player

**GUI Applications:**
- `chromium` - Web browser
- `neovim` - Text editor
- `foot` - Terminal emulator

**Total Packages:** 100+ including dependencies

### Omarchy Utilities Configured

Added `~/.local/share/omarchy/bin/` to PATH with 50+ utility scripts:
- `omarchy-cmd-screenshot` - Screenshot tool
- `omarchy-cmd-screenrecord` - Screen recording
- `omarchy-cmd-audio-switch` - Audio device switcher
- `omarchy-font-set` - Font management
- `omarchy-hyprland-workspace-toggle-gaps` - Workspace utilities
- And many more...

### Startup Script Created

**File:** `~/start-omarchy.sh`

Simple one-command startup:
```bash
./start-omarchy.sh
```

Automatically:
1. Kills any existing Hyprland session
2. Launches Hyprland with Omarchy configs
3. Starts waybar status bar
4. Starts mako notification daemon
5. Activates display output

---

## Lessons Learned

1. **Never run `pacman -Sy` without `-u`** - Partial upgrades break systems
2. **Atomic upgrades are critical** - Upgrade everything at once, not piecemeal
3. **Pre-built VMs age quickly** - 2022 VM had 3-year-old libraries
4. **Test before rebooting** - Install and configure everything while system still runs
5. **Automation saves time** - utmctl + expect scripts dramatically speed up iteration
6. **Have a backup plan** - We had Archboot ISO ready (didn't need it, but good to have)
7. **Wayland compositors need seatd** - libseat requires seatd or logind for seat management

---

## Time Tracking

### Session 1 (Initial Attempts)
- Repository setup: ~5 minutes
- VM download and import: ~10 minutes
- Failed upgrade attempts: ~90 minutes
- Research and troubleshooting: ~45 minutes

### Session 2 (Successful Approach)
- Fresh VM import and upgrade: ~20 minutes
- SSH setup and testing: ~10 minutes
- Yay installation: ~15 minutes
- Documentation: ~20 minutes

**Total Time:** ~215 minutes (3.6 hours)

---

## System Access Info

**SSH Connection:**
```bash
ssh omarchy@192.168.64.6
# Password: omarchy
```

**VM Console:**
- Login as: `alarm` or `omarchy`
- Passwords: `alarm` / `omarchy`

**Root Access:**
```bash
ssh root@192.168.64.6
# Password: omarchy
```

Or from omarchy user:
```bash
sudo su -
# No password required (passwordless sudo)
```

---

*Last Updated: November 16, 2025 17:20 PST*
*Status: ✅ Base system fully operational, ready for Hyprland installation*
*Next Session: Install and configure Hyprland + GPU acceleration*

---

## Phase 7: Full Application Stack & Font Fixes ✅🔄

### Waybar Icon Fix (✅ COMPLETED)
**Problem:** Waybar icons not displaying - showing empty boxes instead of symbols

**Root Cause:** Missing Nerd Fonts
- Waybar configured to use 'CaskaydiaMono Nerd Font'
- Only symbol fonts were installed, not the full font families

**Solution:**
```bash
yay -S --noconfirm \
    ttf-cascadia-code-nerd \
    ttf-jetbrains-mono-nerd \
    ttf-nerd-fonts-symbols \
    ttf-nerd-fonts-symbols-mono \
    ttf-nerd-fonts-symbols-common
fc-cache -fv
```

**Verification:**
```bash
# Restart waybar via Hyprland
export HYPRLAND_INSTANCE_SIGNATURE=$(ls -t /run/user/1001/hypr/ | head -1)
hyprctl dispatch exec "pkill waybar; waybar"
```

**Result:** ✅ Icons now display correctly in waybar

### Comprehensive Package Installation (🔄 IN PROGRESS)

**Goal:** Install ALL applications referenced in Omarchy configuration for full functionality

**Packages Installed (Current: 577 total):**

**Core GUI Stack:**
- Hyprland compositor + xdg-desktop-portal
- Waybar (status bar)
- Mako (notifications)
- Foot, Kitty terminals
- Wofi launcher

**Essential Applications:**
- Thunar file manager
- Gnome Calculator
- Chromium browser
- Neovim editor

**Currently Installing:**
- Walker launcher (building from AUR - Rust compilation)
- Rofi-wayland
- Firefox browser
- Pavucontrol (audio control)
- Blueman (Bluetooth manager)
- Network-manager-applet

**Installation Strategy:**
Created comprehensive installation scripts to install ~200 additional packages:
- Display tools (grim, slurp, hyprpicker, swaylock, etc.)
- Multiple launchers (walker, rofi, fuzzel)
- Multiple terminals (alacritty, wezterm, kitty)
- File managers (thunar, nautilus, nemo)
- Development tools (VSCode, Helix, Docker)
- Media apps (VLC, mpv, OBS)
- Themes and icons
- All Nerd Fonts

**Challenges:**
- Some AUR packages timing out during build
- Walker-git requires full Rust compilation (~5-10 minutes)
- Large package downloads on VM network
- Process management via SSH (buffering issues with logs)

**Next Steps:**
1. Wait for current walker/firefox/rofi installation to complete
2. Install remaining packages in smaller batches
3. Enable system services (bluetooth, NetworkManager, docker)
4. Verify all Omarchy keybindings work with installed apps
5. Test full Omarchy workflow

**Package Count Progress:**
- Session start: 501 packages
- After initial fixes: 527 packages (+26)
- After Thunar/Calculator: 552 packages (+51)
- Current: 577 packages (+76)
- Target: ~700 packages (all Omarchy dependencies)

---

