# Shrinking the VM for Distribution

Guide to reducing VM size from ~84GB to a more manageable size for sharing.

## Current Size Analysis

The VM is currently **~84GB** due to:
- Game files (Doom, Quake 3 assets) - **~30-40GB**
- Package cache - **~2-5GB**
- Journal logs - **~500MB**
- Man pages/docs - **~500MB**
- Free space in disk image - **~10-15GB**

## Target Size

**Goal:** Reduce to **~20-30GB** (compressed to **~5-10GB**)

## Method 1: Automated Cleanup Script

Run our cleanup script inside the VM:

```bash
# SSH into the VM
ssh omarchy@192.168.64.6

# Download and run cleanup script
curl -sSL https://raw.githubusercontent.com/potable-anarchy/omarchy-arm64-vm/main/scripts/shrink-vm.sh | bash

# Or if repo is cloned:
cd omarchy-arm64-vm
./scripts/shrink-vm.sh
```

### What It Removes

✅ Game files (Doom, Quake 3, etc.) - **~30-40GB**  
✅ Package cache - **~2-5GB**  
✅ Old journal logs - **~500MB**  
✅ User caches and temp files - **~1GB**  
✅ Shell history  
✅ Optionally: man pages/docs - **~500MB**  

## Method 2: Manual Cleanup

### Remove Games

```bash
# Remove game packages
sudo pacman -Rns quake3 doom chocolate-doom gzdoom

# Remove game data
sudo rm -rf /usr/share/doom
sudo rm -rf ~/.local/share/quake3
sudo rm -rf ~/.local/share/doom
sudo rm -rf /usr/share/games
```

**Savings: ~30-40GB**

### Clear Package Cache

```bash
sudo pacman -Scc --noconfirm
```

**Savings: ~2-5GB**

### Clear Logs and Caches

```bash
# Journal logs
sudo journalctl --vacuum-time=1d

# User caches
rm -rf ~/.cache/*

# System logs
sudo find /var/log -type f -name "*.log" -exec truncate -s 0 {} \;
sudo find /var/log -type f -name "*.old" -delete

# Temp files
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*
```

**Savings: ~1-2GB**

### Remove Documentation (Optional)

```bash
sudo rm -rf /usr/share/man/*
sudo rm -rf /usr/share/doc/*
sudo rm -rf /usr/share/info/*
```

**Savings: ~500MB**

## Step 3: Zero Out Free Space

This improves compression significantly:

```bash
# Inside the VM
sudo dd if=/dev/zero of=/zero.dat bs=1M
# Wait for "No space left on device"
sudo rm /zero.dat
sync
```

**Compression improvement: 2-3x better**

## Step 4: Shutdown VM

```bash
sudo shutdown -h now
```

## Step 5: Shrink Disk Image (macOS Host)

### Option A: Convert to Sparse Image

```bash
cd ~/Library/Containers/com.utmapp.UTM/Data/Documents/YourVM.utm/Data

# Create new sparse qcow2
qemu-img convert -O qcow2 -c \
    original.qcow2 \
    shrunk.qcow2
```

### Option B: Use UTM's Built-in Compression

UTM automatically uses sparse qcow2 images, so the zeroed space won't take actual disk space.

## Step 6: Create Distributable Archive

### ZIP (Fastest)

```bash
cd ~/Library/Containers/com.utmapp.UTM/Data/Documents
zip -r OmarchyVM.zip YourVM.utm
```

### 7-Zip (Best Compression)

```bash
brew install p7zip
cd ~/Library/Containers/com.utmapp.UTM/Data/Documents
7z a -t7z -mx=9 OmarchyVM.7z YourVM.utm
```

**Expected sizes:**
- Original: ~84GB
- After cleanup: ~30-40GB
- ZIP compressed: ~8-12GB
- 7z compressed: ~5-8GB

## Expected Results

| Stage | Size | Notes |
|-------|------|-------|
| Original VM | 84GB | With games |
| After removing games | ~40GB | Major savings |
| After full cleanup | ~30GB | All unnecessary files gone |
| After zero-ing | ~30GB | Better compression ratio |
| ZIP compressed | ~8-12GB | Good for distribution |
| 7z compressed | ~5-8GB | Best compression |

## Hosting Options

For distributing large files:

1. **MEGA** - 50GB free, good download speeds
2. **Google Drive** - 15GB free (need multiple accounts or paid)
3. **Dropbox** - 2GB free (too small)
4. **Torrent** - Free, requires seeders
5. **Self-hosted** - S3, Backblaze B2, etc.

## Automation Script

See `scripts/shrink-vm.sh` for automated cleanup.

## Restoring After Shrinking

Users who download the shrunk VM can install games later if desired:

```bash
sudo pacman -S quake3 doom
```

## Tips

- Run cleanup script regularly before sharing
- Games are optional - most users won't need them
- Man pages can be reinstalled if needed
- Keep one "master" VM with everything, create shrunk copies for distribution

## See Also

- [Build VM Guide](BUILD-VM.md)
- [Quick Start](QUICKSTART.md)
- [Installer](../installer/README.md)
