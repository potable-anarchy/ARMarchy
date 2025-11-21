# ARMarchy Quick ISO Install

**The fastest way to install ARMarchy Linux from scratch**

## Download ISO

```bash
curl -O https://release.archboot.com/aarch64/latest/iso/archboot-2025.11.21-02.06-6.17.8-1-aarch64-ARCH-latest-aarch64.iso
```

Size: 284 MB

## Create VM in UTM

1. **Create New VM** → Virtualize → Linux
2. **Boot ISO**: Select downloaded ISO
3. **RAM**: 4GB+
4. **CPU**: 4-8 cores  
5. **Disk**: 40GB
6. **Start VM**

## Install (Inside VM)

### 1. Run Arch Installer

```bash
archboot-quickinst.sh
```

Set hostname: `armarchy`, create user: `omarchy`

### 2. Install ARMarchy (Before Reboot)

```bash
mount /dev/vda2 /mnt
arch-chroot /mnt
curl -O https://raw.githubusercontent.com/potable-anarchy/omarchy-arm64-vm/main/armarchy/scripts/install-armarchy.sh
chmod +x install-armarchy.sh
./install-armarchy.sh
exit
umount -R /mnt
poweroff
```

### 3. Remove ISO & Boot

1. Remove ISO from UTM VM settings
2. Start VM
3. Login as `omarchy`

### 4. Configure & Start

```bash
sudo armarchy-setup  # First-boot configuration
Hyprland            # Start ARMarchy
```

## Done! 🎉

You now have ARMarchy Linux running.

## Time Estimate

- VM creation: 2 minutes
- Base install: 15-20 minutes
- ARMarchy install: 25-35 minutes
- **Total: ~45-60 minutes**

---

For detailed instructions, see [INSTALL-FROM-ISO.md](docs/INSTALL-FROM-ISO.md)
