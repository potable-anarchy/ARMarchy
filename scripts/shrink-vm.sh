#!/bin/bash
#
# VM Shrinking Script
# Removes unnecessary files to reduce VM size for distribution
#
# Run this INSIDE the VM before distributing
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

show_size() {
    df -h / | tail -1 | awk '{print "Used: "$3" / "$2" ("$5")"}'
}

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Omarchy VM Shrinking Script         ║${NC}"
echo -e "${BLUE}╔════════════════════════════════════════╝${NC}"
echo

log_info "Current disk usage:"
show_size
echo

# Remove game files (Doom, Quake, etc.)
log_info "Removing game files..."
sudo rm -rf /usr/share/doom 2>/dev/null || true
sudo rm -rf ~/.local/share/quake3 2>/dev/null || true
sudo rm -rf ~/.local/share/doom 2>/dev/null || true
sudo rm -rf /usr/share/games 2>/dev/null || true
log_success "Removed game files"

# Remove unnecessary packages
log_info "Removing games and unnecessary packages..."
sudo pacman -Rns --noconfirm \
    quake3 \
    doom \
    chocolate-doom \
    gzdoom \
    2>/dev/null || true
log_success "Removed game packages"

# Clear package cache completely
log_info "Clearing package cache..."
sudo pacman -Scc --noconfirm
log_success "Cleared package cache"

# Clear journal logs (keep only last day)
log_info "Clearing old journal logs..."
sudo journalctl --vacuum-time=1d
log_success "Cleared journal logs"

# Clear all user caches
log_info "Clearing user caches..."
rm -rf ~/.cache/*
rm -rf ~/.local/share/Trash/*
log_success "Cleared user caches"

# Remove temporary files
log_info "Clearing temporary files..."
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*
log_success "Cleared temp files"

# Clear command history
log_info "Clearing shell history..."
rm -f ~/.bash_history
rm -f ~/.zsh_history
history -c
log_success "Cleared history"

# Remove old kernels (keep only current)
log_info "Checking for old kernels..."
current_kernel=$(uname -r)
log_info "Current kernel: $current_kernel"
# Pacman handles this automatically, just noting current

# Clear systemd logs
log_info "Clearing systemd logs..."
sudo find /var/log -type f -name "*.log" -exec truncate -s 0 {} \;
sudo find /var/log -type f -name "*.old" -delete
log_success "Cleared system logs"

# Remove man pages and docs (optional - saves ~500MB)
read -p "Remove man pages and documentation? (saves ~500MB) [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_info "Removing man pages and documentation..."
    sudo rm -rf /usr/share/man/*
    sudo rm -rf /usr/share/doc/*
    sudo rm -rf /usr/share/info/*
    log_success "Removed documentation"
fi

echo
log_info "Disk usage after cleanup:"
show_size
echo

log_info "To further shrink the VM, run these commands:"
echo "  1. Zero out free space (improves compression):"
echo "     ${YELLOW}sudo dd if=/dev/zero of=/zero.dat bs=1M; sudo rm /zero.dat${NC}"
echo
echo "  2. Shutdown the VM"
echo "     ${YELLOW}sudo shutdown -h now${NC}"
echo
echo "  3. On macOS host, compress the qcow2 image"
echo

log_success "Cleanup complete!"
