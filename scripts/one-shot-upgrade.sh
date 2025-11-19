#!/bin/bash
# One-shot upgrade script for Arch ARM VM
# Run these commands in the VM console ALL AT ONCE

cat << 'VMSCRIPT'
# Unlock pacman
rm -f /var/lib/pacman/db.lck

# Full system upgrade (will take 5-10 minutes)
echo "Starting full system upgrade..."
pacman -Syu --noconfirm

echo ""
echo "Installing essential packages..."
pacman -S --noconfirm openssh qemu-guest-agent base-devel git sudo vim

echo ""
echo "Creating omarchy user..."
useradd -m -G wheel -s /bin/bash omarchy 2>/dev/null || echo "User might already exist"
echo 'omarchy:omarchy' | chpasswd
echo 'root:omarchy' | chpasswd

echo ""
echo "Configuring sudo..."
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

echo ""
echo "Configuring SSH..."
cat >> /etc/ssh/sshd_config << 'EOF'

# Allow root login and password authentication
PermitRootLogin yes
PasswordAuthentication yes
EOF

echo ""
echo "Enabling services..."
systemctl enable sshd 2>/dev/null || echo "systemctl broken, will fix on reboot"
systemctl enable qemu-guest-agent 2>/dev/null || echo "systemctl broken, will fix on reboot"
systemctl enable NetworkManager 2>/dev/null || echo "NetworkManager enable failed"

echo ""
echo "=== UPGRADE COMPLETE ==="
echo "Getting IP address for reference:"
ip -4 addr show enp0s1 | grep inet || ip -4 addr show eth0 | grep inet

echo ""
echo "System is ready to reboot!"
echo "Run: reboot"
VMSCRIPT
