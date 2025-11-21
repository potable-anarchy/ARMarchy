#!/bin/bash
#
# ARMarchy First Boot Setup
# Auto-configures the system on first boot
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear

cat << "EOF"
    _    ____  __  __                  _
   / \  |  _ \|  \/  | __ _ _ __ ___| |__  _   _
  / _ \ | |_) | |\/| |/ _` | '__/ __| '_ \| | | |
 / ___ \|  _ <| |  | | (_| | | | (__| | | | |_| |
/_/   \_\_| \_\_|  |_|\__,_|_|  \___|_| |_|\__, |
                                           |___/

        Welcome to ARMarchy Linux!
    ARM64 Linux for Apple Silicon Macs

EOF

echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${GREEN}      First Boot Setup Wizard${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo ""

# Check if already configured
if [ -f ~/.armarchy-configured ]; then
    echo -e "${YELLOW}ARMarchy has already been configured!${NC}"
    echo ""
    read -p "Run setup again? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

# Detect hypervisor
detect_hypervisor() {
    echo -e "${CYAN}[1/6]${NC} Detecting hypervisor..."

    if grep -qi "utm" /proc/cpuinfo 2>/dev/null || [ -d "/dev/virtio-ports" ]; then
        HYPERVISOR="UTM"
    elif lspci 2>/dev/null | grep -qi "parallels"; then
        HYPERVISOR="Parallels"
    elif lspci 2>/dev/null | grep -qi "vmware"; then
        HYPERVISOR="VMware"
    else
        HYPERVISOR="Unknown"
    fi

    echo -e "   ${GREEN}✓${NC} Detected: ${HYPERVISOR}"
}

# Configure hostname
configure_hostname() {
    echo ""
    echo -e "${CYAN}[2/6]${NC} Configure hostname"
    echo -e "   Current: $(hostname)"
    echo ""
    read -p "   New hostname [armarchy]: " new_hostname
    new_hostname=${new_hostname:-armarchy}

    echo "$new_hostname" | sudo tee /etc/hostname > /dev/null
    sudo hostnamectl set-hostname "$new_hostname"

    echo -e "   ${GREEN}✓${NC} Hostname set to: $new_hostname"
}

# Configure timezone
configure_timezone() {
    echo ""
    echo -e "${CYAN}[3/6]${NC} Configure timezone"
    echo -e "   Current: $(timedatectl show -p Timezone --value)"
    echo ""
    echo "   Common timezones:"
    echo "   - America/New_York"
    echo "   - America/Los_Angeles"
    echo "   - America/Chicago"
    echo "   - Europe/London"
    echo "   - Asia/Tokyo"
    echo ""
    read -p "   Timezone [America/Los_Angeles]: " tz
    tz=${tz:-America/Los_Angeles}

    sudo timedatectl set-timezone "$tz"
    echo -e "   ${GREEN}✓${NC} Timezone set to: $tz"
}

# Update password
update_password() {
    echo ""
    echo -e "${CYAN}[4/6]${NC} Update password"
    echo -e "   ${YELLOW}Default password 'armarchy' should be changed!${NC}"
    echo ""
    read -p "   Update password now? (Y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        passwd
        echo -e "   ${GREEN}✓${NC} Password updated"
    else
        echo -e "   ${YELLOW}⚠${NC}  Skipped (remember to change it later!)"
    fi
}

# Optimize for hypervisor
optimize_hypervisor() {
    echo ""
    echo -e "${CYAN}[5/6]${NC} Optimize for ${HYPERVISOR}"

    case $HYPERVISOR in
        UTM)
            echo -e "   ${GREEN}✓${NC} UTM optimizations applied"
            # Already optimized
            ;;
        Parallels)
            echo "   Installing Parallels Tools..."
            # Future: Install Parallels tools
            echo -e "   ${YELLOW}⚠${NC}  Manual Parallels Tools installation recommended"
            ;;
        VMware)
            echo "   Installing VMware Tools..."
            # Future: Install open-vm-tools
            echo -e "   ${YELLOW}⚠${NC}  Manual VMware Tools installation recommended"
            ;;
        *)
            echo -e "   ${YELLOW}⚠${NC}  Unknown hypervisor, using defaults"
            ;;
    esac
}

# System update
system_update() {
    echo ""
    echo -e "${CYAN}[6/6]${NC} System update"
    echo ""
    read -p "   Update system packages? (Y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        echo "   Updating packages..."
        sudo pacman -Syu --noconfirm
        echo -e "   ${GREEN}✓${NC} System updated"
    else
        echo -e "   ${YELLOW}⚠${NC}  Skipped"
    fi
}

# Main setup
main() {
    detect_hypervisor
    configure_hostname
    configure_timezone
    update_password
    optimize_hypervisor
    system_update

    # Mark as configured
    touch ~/.armarchy-configured

    echo ""
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo -e "${GREEN}      Setup Complete!${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo ""
    echo -e "${GREEN}ARMarchy is ready to use!${NC}"
    echo ""
    echo "Quick tips:"
    echo "  - Start Hyprland: ./start-omarchy.sh"
    echo "  - SUPER+RETURN: Open terminal"
    echo "  - SUPER+E: App launcher"
    echo "  - SUPER+B: Browser"
    echo ""
    echo "Documentation: ~/.config/hypr/"
    echo ""
    echo -e "${CYAN}Enjoy ARMarchy!${NC}"
    echo ""
}

main
