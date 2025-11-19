# Arch Linux ARM Installation Guide (Archboot ISO)

## Overview

This guide covers installing Arch Linux ARM from the Archboot ISO to a blank virtual disk in UTM.

## Step 1: Boot from ISO

1. Start the VM with the Archboot ISO attached
2. Select the default boot option or wait for auto-boot
3. You'll be dropped into a root shell

## Step 2: Verify Network

```bash
# Check network connectivity
ip addr show
ping -c 3 archlinux.org
```

## Step 3: Partition the Disk

The virtual disk will likely be `/dev/vda` in QEMU/UTM.

```bash
# List available disks
lsblk

# Partition the disk with fdisk or gdisk
gdisk /dev/vda
```

### Recommended Partition Layout:

1. **EFI System Partition**: 512 MB, type EF00
   - `/dev/vda1` - FAT32, mounted at `/boot`
   
2. **Root Partition**: Remaining space, type 8300
   - `/dev/vda2` - ext4, mounted at `/`

### gdisk Commands:

```
o     (create new GPT partition table)
n     (new partition)
  1   (partition number)
      (default first sector)
  +512M (size)
  ef00 (EFI type)
  
n     (new partition) 
  2   (partition number)
      (default first sector)
      (default last sector - use all remaining)
  8300 (Linux filesystem type)
  
w     (write changes)
yes   (confirm)
```

## Step 4: Format Partitions

```bash
# Format EFI partition
mkfs.fat -F32 /dev/vda1

# Format root partition
mkfs.ext4 /dev/vda2
```

## Step 5: Mount Partitions

```bash
# Mount root
mount /dev/vda2 /mnt

# Create and mount boot
mkdir -p /mnt/boot
mount /dev/vda1 /mnt/boot
```

## Step 6: Install Base System

```bash
# Update package database
pacman -Sy

# Install base system (this will take a while)
pacstrap /mnt base base-devel linux linux-firmware \
    networkmanager openssh sudo vim git \
    efibootmgr grub
```

**Note**: If `pacstrap` isn't available in Archboot, use:

```bash
pacman -Sy archinstall
archinstall
```

Or manually:

```bash
# Sync pacman database
pacman -Sy

# Install directly to /mnt
pacman -r /mnt -Sy base base-devel linux linux-firmware \
    networkmanager openssh sudo vim git efibootmgr grub
```

## Step 7: Generate fstab

```bash
# Generate filesystem table
genfstab -U /mnt >> /mnt/etc/fstab

# Verify it looks correct
cat /mnt/etc/fstab
```

## Step 8: Chroot into New System

```bash
arch-chroot /mnt
```

## Step 9: Basic System Configuration

```bash
# Set timezone
ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
hwclock --systohc

# Set locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Set hostname
echo "omarchy-vm" > /etc/hostname

# Set root password
passwd
# Enter: omarchy

# Create omarchy user
useradd -m -G wheel -s /bin/bash omarchy
passwd omarchy
# Enter: omarchy

# Enable sudo for wheel group
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
```

## Step 10: Install and Configure Bootloader

```bash
# Install GRUB for EFI
grub-install --target=arm64-efi --efi-directory=/boot --bootloader-id=GRUB

# Generate GRUB configuration
grub-mkconfig -o /boot/grub/grub.cfg
```

## Step 11: Enable Network Services

```bash
# Enable NetworkManager
systemctl enable NetworkManager

# Enable SSH
systemctl enable sshd
```

## Step 12: Exit and Reboot

```bash
# Exit chroot
exit

# Unmount partitions
umount -R /mnt

# Reboot
reboot
```

## Step 13: Post-Reboot Setup

1. Remove the ISO from UTM boot settings
2. Boot the VM normally
3. Login as `omarchy` (password: omarchy)
4. Get IP address: `ip addr show`
5. SSH from host Mac: `ssh omarchy@<VM_IP>`

## Step 14: Install Hyprland (After First Boot)

```bash
# Update system
sudo pacman -Syu

# Install yay (AUR helper)
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

# Install Hyprland and dependencies
yay -S hyprland waybar kitty wofi
```

---

**Notes**:
- The Archboot ISO comes with installation tools pre-configured
- Network should work automatically with DHCP
- If you encounter issues, consult the Archboot documentation at archboot.com
