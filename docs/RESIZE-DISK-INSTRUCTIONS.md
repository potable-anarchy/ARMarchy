# How to Resize VM Disk in UTM

The VM disk is only 10GB and is 82% full. To install the remaining packages, you need to resize it.

## Method 1: Via UTM GUI (Easiest)

1. **Stop the VM:**
   - Open UTM
   - Right-click "ArchLinux" VM
   - Click "Stop"

2. **Resize the disk:**
   - Right-click "ArchLinux" VM
   - Click "Edit"
   - Go to "Drives" section
   - Find the main disk drive (VirtIO)
   - Click on it
   - Look for "Size" field
   - Change from 10GB to **50GB**
   - Click "Save"

3. **Start the VM**

4. **Expand the partition inside VM:**
   ```bash
   ssh omarchy@192.168.64.6
   
   # Check current size
   df -h /
   
   # Resize partition (as root)
   sudo growpart /dev/vda 2
   sudo resize2fs /dev/vda2
   
   # Verify
   df -h /
   # Should now show ~50GB
   ```

## Method 2: Manual with qemu-img (If GUI doesn't work)

1. **Install qemu properly:**
   ```bash
   brew install qemu
   # Wait for it to complete
   ```

2. **Stop the VM** (close UTM)

3. **Resize the disk:**
   ```bash
   cd /Users/brad/code/omarchy-arm64-vm/downloads/ArchLinux.utm/Data
   qemu-img resize BB208CBD-BFB4-4895-9542-48527C9E5473.qcow2 50G
   ```

4. **Start VM and expand partition** (same as Method 1 step 4)

## After Resizing

Once you have 50GB, you can install the remaining packages:

```bash
ssh omarchy@192.168.64.6

# Install missing apps with plenty of space
yay -S --noconfirm walker-git rofi-wayland wezterm helix \
  blueman network-manager-applet imagemagick code

# Final package count should be ~750-800 packages
```

## Current Status

- **Current disk:** 10GB (82% full, 1.7GB free)
- **Target disk:** 50GB
- **Packages now:** 732
- **Target packages:** ~750-800 (full Omarchy)
- **Missing:** 8 key applications

