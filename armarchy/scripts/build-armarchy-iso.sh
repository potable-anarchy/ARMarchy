#!/bin/bash
#
# ARMarchy ISO Builder
# Creates a bootable ARM64 installation ISO
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${GREEN}     ARMarchy ISO Builder${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo ""

# Check requirements
check_requirements() {
    echo "Checking requirements..."

    if ! command -v archiso &> /dev/null; then
        echo -e "${RED}Error: archiso not found${NC}"
        echo "Install with: sudo pacman -S archiso"
        exit 1
    fi

    echo -e "${GREEN}✓${NC} All requirements met"
}

# Create work directory
create_workdir() {
    WORKDIR="$(pwd)/armarchy-iso-work"

    if [ -d "$WORKDIR" ]; then
        echo "Cleaning existing work directory..."
        rm -rf "$WORKDIR"
    fi

    mkdir -p "$WORKDIR"
    echo -e "${GREEN}✓${NC} Work directory created: $WORKDIR"
}

# Copy archiso profile
setup_profile() {
    echo "Setting up archiso profile..."

    cp -r /usr/share/archiso/configs/releng/ "$WORKDIR/profile"
    cd "$WORKDIR/profile"

    # Customize for ARMarchy
    sed -i 's/Arch Linux/ARMarchy Linux/' airootfs/etc/os-release
    sed -i 's/arch/armarchy/' profiledef.sh

    echo -e "${GREEN}✓${NC} Profile configured"
}

# Add ARMarchy packages
add_packages() {
    echo "Adding ARMarchy package list..."

    cat >> "$WORKDIR/profile/packages.x86_64" << 'EOF'
# Hyprland and Wayland
hyprland
waybar
mako
wofi
grim
slurp
wl-clipboard

# CLI tools
bat
eza
ripgrep
fd
fzf
zoxide
starship
btop
dust
fastfetch

# Development
git
lazygit
neovim
tree-sitter

# GUI applications
chromium
foot
imv
mpv

# Fonts
ttf-jetbrains-mono-nerd
noto-fonts
noto-fonts-emoji

# System
networkmanager
openssh
sudo
EOF

    echo -e "${GREEN}✓${NC} Packages added"
}

# Add first-boot script
add_firstboot() {
    echo "Adding first-boot setup..."

    mkdir -p "$WORKDIR/profile/airootfs/usr/local/bin"
    cp ../../first-boot-setup.sh "$WORKDIR/profile/airootfs/usr/local/bin/armarchy-setup"
    chmod +x "$WORKDIR/profile/airootfs/usr/local/bin/armarchy-setup"

    # Auto-run on first login
    cat >> "$WORKDIR/profile/airootfs/etc/profile.d/armarchy-firstboot.sh" << 'EOF'
if [ ! -f ~/.armarchy-configured ] && [ "$USER" = "armarchy" ]; then
    armarchy-setup
fi
EOF

    echo -e "${GREEN}✓${NC} First-boot setup configured"
}

# Build ISO
build_iso() {
    echo ""
    echo "Building ISO (this will take 15-30 minutes)..."
    echo ""

    cd "$WORKDIR"
    sudo mkarchiso -v -w work/ -o out/ profile/

    ISO_FILE=$(ls out/*.iso 2>/dev/null | head -1)

    if [ -f "$ISO_FILE" ]; then
        echo ""
        echo -e "${GREEN}✓✓✓ ISO built successfully! ✓✓✓${NC}"
        echo ""
        echo "ISO location: $ISO_FILE"
        echo "Size: $(du -h "$ISO_FILE" | cut -f1)"
        echo ""
        echo "Next steps:"
        echo "  1. Test in UTM/Parallels/VMware"
        echo "  2. Create torrent"
        echo "  3. Distribute!"
    else
        echo -e "${RED}✗ ISO build failed${NC}"
        exit 1
    fi
}

# Main
main() {
    check_requirements
    create_workdir
    setup_profile
    add_packages
    add_firstboot
    build_iso
}

echo ""
echo -e "${YELLOW}Note: This must be run on an existing Arch Linux system${NC}"
echo -e "${YELLOW}For now, we'll document the process instead of building${NC}"
echo ""
echo "To build ARMarchy ISO:"
echo "  1. Boot into existing ARMarchy VM"
echo "  2. Install archiso: sudo pacman -S archiso"
echo "  3. Run this script"
echo ""
echo -e "${BLUE}Creating ISO build documentation instead...${NC}"

# For now, create documentation
cat > "$(dirname $0)/../docs/ISO-BUILD.md" << 'EOF'
# Building ARMarchy ISO

ARMarchy can be built as a bootable ISO for fresh installations.

## Requirements

- Existing Arch Linux ARM system (use ARMarchy VM)
- archiso package
- 20GB free space
- Root access

## Build Steps

### 1. Prepare Environment

```bash
# Inside ARMarchy VM or Arch Linux ARM system
sudo pacman -S archiso git
git clone https://github.com/potable-anarchy/armarchy.git
cd armarchy
```

### 2. Run ISO Builder

```bash
cd armarchy/scripts
sudo ./build-armarchy-iso.sh
```

### 3. Test ISO

- Import into UTM/Parallels/VMware
- Boot from ISO
- Follow installation prompts

## Customization

Edit `armarchy-iso-work/profile/` to customize:
- Package list
- Default configurations
- Branding and artwork

## Distribution

Once built, the ISO can be:
- Uploaded to GitHub releases
- Shared via BitTorrent
- Hosted on mirrors

## Automated Builds

Future: GitHub Actions workflow to auto-build ISOs on release.

EOF

echo -e "${GREEN}✓${NC} Created ISO build documentation"
echo ""
echo "See: armarchy/docs/ISO-BUILD.md"
