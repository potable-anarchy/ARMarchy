# Progress Log - Omarchy ARM64 VM Setup

## Session: November 16, 2025

### Objective
Get Omarchy Linux running in an ARM64 VM in UTM with Hyprland working.

---

## Progress Summary

### Phase 1: Repository & VM Setup ✅

**Completed:**
1. Created GitHub repository: `potable-anarchy/omarchy-arm64-vm` (private)
2. Downloaded Arch Linux ARM pre-built VM from UTM gallery (532MB)
3. Extracted and imported VM into UTM
4. VM successfully boots and runs

**Key Findings:**
- Omarchy does not provide official ARM64 ISOs
- Must bootstrap Omarchy on top of Arch Linux ARM
- UTM pre-built image uses console-only display (need to add GUI support for Hyprland)

### Phase 2: Automation Attempts ⚠️

**Attempted Methods:**

1. **UTM CLI (`utmctl`):**
   - ✅ Can list, start, stop VMs
   - ✅ Has `exec` and `file` commands for remote control
   - ❌ Requires QEMU guest agent (not pre-installed)
   - ❌ `attach` command not yet implemented
   - ❌ Can't get IP address without guest agent

2. **Expect Script Automation:**
   - Created `auto-setup.exp` to automate console interaction
   - ❌ Failed: `utmctl attach` returns "not implemented yet"

3. **AppleScript/GUI Automation:**
   - Considered but not pursued (fragile, non-portable)

**Conclusion:**
Manual initial setup required to install QEMU guest agent and SSH, then automation can take over.

### Phase 3: Setup Scripts Created ✅

**Scripts Created:**

1. **`setup-vm.sh`** - Main automated setup script
   - System updates
   - Installs essential packages (SSH, git, base-devel, sudo, vim)
   - Configures networking (systemd-networkd)
   - Creates `omarchy` user with sudo access
   - Installs yay (AUR helper)
   - Installs Hyprland and dependencies
   
2. **`quick-setup.txt`** - Quick reference commands for manual setup
   - Unlocks pacman database
   - Installs guest agent and SSH
   - Sets up remote access

3. **`auto-setup.exp`** - Expect script (non-functional)
   - Preserved for reference
   - May work in future UTM versions

4. **`setup-via-gui.sh`** - Displays manual setup instructions
   - Helpful for first-time setup

---

## Current State

### VM Status
- **VM Name:** ArchLinux
- **UUID:** 2F2C4095-EC5B-49CD-A654-FE17D7EC7CAA
- **Status:** Running in UTM
- **Login:** root/root
- **Network:** Shared network (DHCP)
- **Display:** Console only (serial terminal)

### Blockers
1. **Pacman database locked** - Initial run showed lock error
   - Solution: `rm -f /var/lib/pacman/db.lck`
   
2. **No remote access yet** - Need to manually install SSH and guest agent
   - Waiting for user to run commands in console

3. **No GUI** - Need to configure display for Hyprland
   - Will require UTM VM settings adjustment
   - May need to switch from console to GPU-accelerated display

---

## Next Steps

### Immediate (Waiting on User)
1. Run setup commands in VM console to enable SSH
2. Get VM IP address
3. SSH into VM for remote automation

### After SSH Access
1. Update system: `pacman -Syu`
2. Install base packages
3. Configure user accounts
4. Install yay (AUR helper)

### Omarchy Bootstrap
1. Research Omarchy installation scripts
2. Adapt for ARM64 architecture
3. Install Omarchy core components:
   - Desktop environment preferences
   - Custom configurations
   - Theming and styling
   - Application suite

### Hyprland Setup
1. Install Hyprland from AUR
2. Configure VM display settings in UTM:
   - Enable GPU acceleration
   - Add display device (virtio-gpu or similar)
   - Configure resolution
3. Install Wayland dependencies
4. Configure Hyprland:
   - Create config files
   - Set up keybindings
   - Install terminal emulator (likely Kitty or Alacritty)
   - Configure status bar (likely Waybar)
5. Test GUI launch

### Documentation
1. Document successful Omarchy bootstrap process
2. Create step-by-step guide
3. Document Hyprland configuration
4. Add screenshots/recordings
5. Update README with complete instructions

---

## Technical Challenges

### Challenge 1: No Official ARM64 Support
**Problem:** Omarchy only provides x86-64 ISOs

**Solutions Considered:**
- ❌ Emulation (too slow)
- ✅ Bootstrap on Arch Linux ARM (chosen approach)
- ⚠️ Wait for official support (unknown timeline)

**Implementation:**
Start with Arch Linux ARM, then install Omarchy's components manually.

### Challenge 2: UTM Automation Limitations
**Problem:** Can't fully automate VM setup without guest agent

**Solutions Considered:**
- ❌ Expect scripts (attach not implemented)
- ❌ AppleScript GUI automation (fragile)
- ✅ Hybrid approach: manual bootstrap, then SSH automation

**Implementation:**
One-time manual setup to enable remote access, then full automation.

### Challenge 3: Display Configuration for Hyprland
**Problem:** Pre-built VM only has console display

**Solutions To Try:**
1. Add virtio-gpu device in UTM settings
2. Install mesa and GPU drivers
3. Configure Wayland/Hyprland to use virtual GPU
4. May need to use VNC or SPICE for remote display

**Status:** Not yet attempted

---

## Resources Discovered

### UTM Documentation
- [UTM Gallery - Arch Linux ARM](https://mac.getutm.app/gallery/archlinux-arm)
- [UTM Port Forwarding Guide](https://docs.getutm.app/settings-qemu/devices/network/port-forwarding/)

### Arch Linux ARM
- Main site: [archlinuxarm.org](https://archlinuxarm.org/)
- Package repositories compatible with Arch Linux
- AUR packages may need compilation for ARM64

### Omarchy Resources
- [Official Site](https://omarchy.org/)
- [GitHub Repository](https://github.com/basecamp/omarchy)
- [Omarchy Manual](https://learn.omacom.io/2/the-omarchy-manual)
- [GitHub Discussion - M* Mac VMs](https://github.com/basecamp/omarchy/discussions/452)

### Hyprland
- [Official Site](https://hyprland.org/)
- Available in AUR
- Requires Wayland, wlroots, and various dependencies

---

## Lessons Learned

1. **Always check architecture support** - Could have saved time knowing Omarchy is x86-64 only
2. **UTM CLI has limitations** - Guest agent is essential for automation
3. **Pre-built VMs are minimal** - Need manual configuration for specific use cases
4. **Hybrid automation works best** - Manual bootstrap + automated setup

---

## Time Tracking

- Repository setup: ~5 minutes
- VM download and import: ~10 minutes
- Automation research and attempts: ~20 minutes
- Script creation: ~15 minutes
- Documentation: ~10 minutes

**Total:** ~60 minutes

---

*Last Updated: November 16, 2025 14:48 PST*
*Next Update: After SSH access is established*
