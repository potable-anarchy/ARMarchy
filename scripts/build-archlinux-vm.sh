#!/bin/bash
# Build a fresh Arch Linux ARM VM image for UTM on M1 Mac
# Based on: https://gist.github.com/levihuayuzhang/da5b5937cdeb932aedd13a705f831141

set -e

echo "=== Arch Linux ARM VM Builder for UTM ==="
echo ""

# Configuration
IMG_SIZE="32G"
IMG_FILE="archlinux-arm64.img"
DOWNLOAD_URL="http://os.archlinuxarm.org/os/ArchLinuxARM-aarch64-latest.tar.gz"
TARBALL="ArchLinuxARM-aarch64-latest.tar.gz"

# Check if we're on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "Error: This script is designed for macOS"
    exit 1
fi

# Check for required tools
echo "Step 1: Checking for required tools..."
if ! command -v qemu-img &> /dev/null; then
    echo "Installing QEMU (this may take a few minutes)..."
    brew install qemu
fi

echo ""
echo "Step 2: Downloading Arch Linux ARM..."
if [[ ! -f "$TARBALL" ]]; then
    curl -L -O "$DOWNLOAD_URL"
else
    echo "Tarball already exists, skipping download"
fi

echo ""
echo "Step 3: Creating disk image ($IMG_SIZE)..."
if [[ -f "$IMG_FILE" ]]; then
    echo "Warning: $IMG_FILE already exists!"
    read -p "Delete and recreate? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm "$IMG_FILE"
    else
        echo "Aborted"
        exit 1
    fi
fi

qemu-img create -f raw "$IMG_FILE" "$IMG_SIZE"

echo ""
echo "Step 4: Partitioning disk image..."
echo "We need to partition the image. This requires hdiutil and diskutil (macOS native)..."

# Attach the image as a disk
DISK=$(hdiutil attach -nomount -noverify -noautofsck "$IMG_FILE" | head -n1 | awk '{print $1}')
echo "Attached image as: $DISK"

# Partition using diskutil
echo "Creating GPT partition table..."
diskutil partitionDisk "$DISK" GPT \
    "MS-DOS FAT32" "EFI" 512M \
    "Free Space" "ROOT" R

# Get partition identifiers
EFI_PART="${DISK}s1"
ROOT_PART="${DISK}s2"

echo "Formatting root partition as ext4..."
# Note: macOS doesn't have native ext4 support, so we'll use QEMU's qemu-nbd later
# For now, eject and we'll handle the rest differently

diskutil eject "$DISK"

echo ""
echo "=== Manual Steps Required ==="
echo ""
echo "Due to macOS limitations with ext4, you have two options:"
echo ""
echo "Option A: Use Linux (VM or dual-boot) to complete the setup"
echo "  1. Transfer $IMG_FILE and $TARBALL to a Linux system"
echo "  2. Follow the remaining steps in the gist"
echo ""
echo "Option B: Use a simpler approach - download fresh ISO and install in UTM"
echo "  1. Download Arch Linux ARM ISO from archlinuxarm.org"
echo "  2. Create new VM in UTM"
echo "  3. Boot from ISO and install manually"
echo ""
echo "Recommendation: Let's try downloading a more recent Arch ARM cloud image instead!"
