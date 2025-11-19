# Omarchy ARM64 VM Installer

Automated installer for creating Omarchy Linux VMs on Apple Silicon Macs.

## What It Does

This installer automates:
- ✅ System requirements checking
- ✅ Arch Linux ARM ISO download
- ✅ UTM VM creation with optimized settings
- ✅ Disk image creation (100GB)
- ✅ VM configuration for Hyprland compatibility

## Requirements

- **Mac:** Apple Silicon (M1, M2, M3, M4)
- **macOS:** 12.0+ (Monterey or later)
- **UTM:** Installed from [mac.getutm.app](https://mac.getutm.app)
- **Disk Space:** 120GB+ free recommended
- **RAM:** 8GB+ system RAM (VM uses 4GB)

## Quick Start

```bash
# Download and run the installer
curl -O https://raw.githubusercontent.com/potable-anarchy/omarchy-arm64-vm/main/installer/install-omarchy-vm.sh
chmod +x install-omarchy-vm.sh
./install-omarchy-vm.sh
```

Or specify a custom VM name:

```bash
./install-omarchy-vm.sh "MyOmarchyVM"
```

## What Happens Next

After the installer completes:

1. **Open UTM** - Find your new VM in the list
2. **Start the VM** - Boot from the Arch Linux ISO
3. **Install Arch Linux** - Follow basic installation steps
4. **Run automated setup** - Use the provided scripts to install all packages and Omarchy configs

### Automated Setup Commands

Once you have a basic Arch Linux installation:

```bash
# Install all packages and configure system
curl -sSL https://raw.githubusercontent.com/potable-anarchy/omarchy-arm64-vm/main/scripts/setup-vm.sh | bash

# Install Omarchy configuration (as your user, not root)
curl -sSL https://raw.githubusercontent.com/potable-anarchy/omarchy-arm64-vm/main/scripts/sync-full-omarchy.sh | bash
```

## VM Configuration

The installer creates a VM with:

| Setting | Value |
|---------|-------|
| **Architecture** | ARM64 (aarch64) |
| **RAM** | 4096 MB (4GB) |
| **CPU Cores** | 4 |
| **Disk Size** | 100GB |
| **Display** | virtio-gpu-pci, 1280x800 |
| **Network** | Shared network mode |
| **Boot Order** | CD → HDD |

## Customization

Edit the script to customize VM settings:

```bash
VM_RAM=8192      # Increase to 8GB
VM_CPUS=6        # Use 6 CPU cores
VM_DISK_SIZE=200 # Create 200GB disk
```

## Troubleshooting

### "UTM is not installed"

Install UTM from https://mac.getutm.app before running the installer.

### "Low disk space detected"

The installer needs ~120GB total:
- ~1GB for Arch ISO
- ~100GB for VM disk
- ~20GB for headroom

Free up space or use an external drive.

### "Required tool not found"

The installer needs these tools (all included with macOS):
- `uuidgen` - Generate UUIDs
- `hdiutil` - Create disk images
- `curl` - Download files

### VM doesn't appear in UTM

1. Check that UTM is closed when running the installer
2. Open UTM after the installer completes
3. If still missing, check `~/Library/Containers/com.utmapp.UTM/Data/Documents/`

### ISO download fails

The installer downloads from Arch Linux mirrors. If it fails:
1. Check your internet connection
2. Download manually from https://archlinuxarm.org
3. Place in `~/Downloads/archlinux-arm64-latest.iso`
4. Re-run the installer

## Manual Installation

If you prefer manual control, see:
- [Complete Build Guide](../docs/BUILD-VM.md)
- [UTM Setup Guide](../docs/UTM-SETUP-GUIDE.md)
- [Arch Install Guide](../docs/arch-install-guide.md)

## What's NOT Automated (Yet)

The installer creates the VM but doesn't automate:
- ❌ Arch Linux installation itself (needs manual partitioning, etc.)
- ❌ Network configuration
- ❌ User creation

We provide scripts for these steps - see [BUILD-VM.md](../docs/BUILD-VM.md).

## Future Enhancements

Planned improvements:
- [ ] Fully automated Arch installation via PXE/cloud-init
- [ ] Pre-configured user accounts
- [ ] One-command complete installation
- [ ] GUI installer app

## Support

- **Issues:** https://github.com/potable-anarchy/omarchy-arm64-vm/issues
- **Discussions:** Use GitHub Discussions
- **Documentation:** [docs/](../docs/)

## License

MIT License - see [LICENSE](../LICENSE)

---

**Next:** After running the installer, follow the [Build Guide](../docs/BUILD-VM.md) to complete the installation.
