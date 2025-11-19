# Careful System Upgrade Strategy for Old Arch ARM VM

## The Problem

The pre-built VM is from 2022 with:
- glibc 2.35
- Old OpenSSL 1.1
- Old systemd

Any package we install requires newer libraries, creating dependency hell.

## The Solution

**DO NOT run any pacman commands until we're ready for a full atomic upgrade.**

## Step-by-Step Upgrade Plan

### Step 1: Boot Fresh VM (Don't Touch Anything!)

1. Delete the broken VM
2. Re-import fresh copy from `downloads/ArchLinux.utm`
3. Boot it
4. Login as root (password: root)
5. **DO NOT RUN PACMAN YET**

### Step 2: Manual Full System Upgrade

Run these commands in ONE SESSION without rebooting:

```bash
# Step 1: Unlock pacman if needed
rm -f /var/lib/pacman/db.lck

# Step 2: Full system upgrade in one go (this will download A LOT)
# This upgrades EVERYTHING including glibc, systemd, openssh together
pacman -Syu --noconfirm

# If that succeeds, continue:

# Step 3: Install essential packages (while system is still running)
pacman -S --noconfirm openssh qemu-guest-agent

# Step 4: Create omarchy user
useradd -m -G wheel -s /bin/bash omarchy
echo 'omarchy:omarchy' | chpasswd

# Step 5: Configure sudo
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Step 6: Set root password
echo 'root:omarchy' | chpasswd

# Step 7: Enable services (might fail, but try anyway)
systemctl enable sshd 2>/dev/null || echo "systemctl broken, will fix on reboot"
systemctl enable qemu-guest-agent 2>/dev/null || echo "systemctl broken, will fix on reboot"

# Step 8: Configure SSH for password auth
cat >> /etc/ssh/sshd_config << 'EOF'

# Allow root login and password authentication
PermitRootLogin yes
PasswordAuthentication yes
EOF

# Step 9: Get IP for reference
ip -4 addr show enp0s1 | grep inet

# Step 10: Cross fingers and reboot
echo "Ready to reboot. The new glibc and systemd should work now!"
reboot
```

## Why This Might Work

- `pacman -Syu` upgrades ALL packages atomically
- The old system is still running with old libraries during the upgrade
- Only after reboot will the new libraries be used
- Since everything is upgraded together, there should be no version mismatches

## Fallback Plan

If the system doesn't boot after reboot:
- We still have the Archboot ISO ready to use
- Can do a proper fresh install

## Let's Try It!

Ready to give it one more shot with the pre-built VM?
