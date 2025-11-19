# UTM VM Setup Guide for Arch Linux ARM

## Step 1: Create New Virtual Machine

1. Open UTM
2. Click **"+"** → **"Virtualize"** (not Emulate - we want ARM64 native)
3. Select **"Linux"**

## Step 2: Boot Configuration

- **Boot ISO Image**: Browse and select the downloaded Archboot ISO:
  - `downloads/archboot-2025.11.16-02.08-6.17.8-1-aarch64-ARCH-latest-aarch64.iso`
- Click **Continue**

## Step 3: Hardware Configuration

### CPU & Memory
- **CPU Cores**: 4-8 cores (your M1 Max has 10, so 4-6 is safe)
- **Memory**: 4096 MB (4 GB) minimum, 8192 MB (8 GB) recommended

### Storage
- **Storage Size**: 32 GB minimum, 64 GB recommended for Hyprland + development
- Click **Continue**

### Shared Directory (Optional)
- Skip for now, can add later
- Click **Continue**

## Step 4: Summary & Advanced Settings

1. Review settings
2. **Before clicking "Save"**, click **"Customize"** or edit settings after creation
3. Important settings to verify/change:

### Display Settings
- **Emulated Display Card**: virtio-gpu-pci (for better performance)
- **Resolution**: 1920x1080 or your preference
- Enable **"Retina Mode"** if using high-DPI display

### Network Settings
- **Network Mode**: Shared Network (default is fine)
- This will give the VM internet access and a local IP

### System Settings
- **Architecture**: ARM64 (aarch64) - should be automatic
- **System**: QEMU 8.x virt-latest (should be default)
- **CPU**: Cortex-A72 or host (Cortex-A72 is more compatible)

## Step 5: Boot Order

1. Start the VM
2. It should boot from the ISO automatically
3. You'll see the Archboot menu

## Expected Boot Process

The Archboot ISO will:
1. Show a boot menu (select default or wait for auto-boot)
2. Load the Linux kernel
3. Start the Arch Linux installation environment
4. Present a terminal with installation tools

## Next Steps After Boot

Once booted into the Archboot environment:
1. Network should be configured automatically (DHCP)
2. You can SSH into the installer (if needed)
3. Follow Arch Linux ARM installation guide
4. Install base system to the virtual disk
5. Configure bootloader
6. Reboot into installed system

---

**Note**: Save these settings as "ArchLinux-Omarchy" or similar to distinguish from the old broken VM.
