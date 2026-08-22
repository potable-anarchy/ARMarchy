#!/bin/bash
#
# Omarchy ARM64 VM Installer
# Automates creation of Omarchy Linux VM on Apple Silicon Macs
#
# Usage: ./install-omarchy-vm.sh [vm-name]
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
VM_NAME="${1:-OmarchyVM}"
VM_RAM=4096  # 4GB
VM_CPUS=4
VM_DISK_SIZE=100  # GB
UTM_DIR="${HOME}/Library/Containers/com.utmapp.UTM/Data/Documents"
ARCH_ISO_URL="https://geo.mirror.pkgbuild.com/images/latest/Arch-Linux-aarch64-latest.iso"
REPO_URL="https://github.com/potable-anarchy/ARMarchy.git"

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_requirements() {
    log_info "Checking system requirements..."

    # Check if running on macOS
    if [[ "$(uname)" != "Darwin" ]]; then
        log_error "This installer only works on macOS"
        exit 1
    fi

    # Check for Apple Silicon
    if [[ "$(uname -m)" != "arm64" ]]; then
        log_error "This installer requires Apple Silicon (M1/M2/M3/M4)"
        exit 1
    fi

    # Check if UTM is installed
    if [[ ! -d "/Applications/UTM.app" ]]; then
        log_error "UTM is not installed. Please install from https://mac.getutm.app"
        exit 1
    fi

    # Check for required tools
    for tool in uuidgen hdiutil curl; do
        if ! command -v $tool &> /dev/null; then
            log_error "Required tool '$tool' not found"
            exit 1
        fi
    done

    # Check available disk space (need at least 120GB)
    available_space=$(df -g "${HOME}" | tail -1 | awk '{print $4}')
    if [[ $available_space -lt 120 ]]; then
        log_warn "Low disk space detected ($available_space GB available, 120GB recommended)"
        read -p "Continue anyway? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi

    log_success "All requirements met!"
}

download_arch_iso() {
    log_info "Downloading Arch Linux ARM ISO..."

    local iso_path="${HOME}/Downloads/archlinux-arm64-latest.iso"

    if [[ -f "$iso_path" ]]; then
        log_info "ISO already exists, skipping download"
        echo "$iso_path"
        return
    fi

    curl -L -o "$iso_path" "$ARCH_ISO_URL"
    log_success "Downloaded Arch Linux ARM ISO"
    echo "$iso_path"
}

create_utm_vm() {
    local iso_path="$1"
    log_info "Creating UTM VM: $VM_NAME..."

    # Generate UUIDs
    local vm_uuid=$(uuidgen)
    local storage_uuid=$(uuidgen)
    local apple_id=$(uuidgen)

    # Create VM bundle directory
    local vm_path="${UTM_DIR}/${VM_NAME}.utm"
    local data_path="${vm_path}/Data"

    mkdir -p "$data_path"

    # Create disk image
    log_info "Creating ${VM_DISK_SIZE}GB disk image..."
    hdiutil create -size "${VM_DISK_SIZE}g" -type UDIF -format UDZO \
        "${data_path}/disk.dmg"
    mv "${data_path}/disk.dmg" "${data_path}/${storage_uuid}.qcow2"

    # Copy ISO
    log_info "Copying ISO to VM..."
    cp "$iso_path" "${data_path}/archlinux.iso"

    # Create config.plist
    log_info "Generating VM configuration..."
    cat > "${vm_path}/config.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Backend</key>
    <string>qemu</string>
    <key>ConfigurationVersion</key>
    <integer>4</integer>
    <key>Information</key>
    <dict>
        <key>IconCustom</key>
        <false/>
        <key>Name</key>
        <string>${VM_NAME}</string>
        <key>UUID</key>
        <string>${vm_uuid}</string>
    </dict>
    <key>System</key>
    <dict>
        <key>Architecture</key>
        <string>aarch64</string>
        <key>CPUCount</key>
        <integer>${VM_CPUS}</integer>
        <key>MemorySize</key>
        <integer>${VM_RAM}</integer>
        <key>Target</key>
        <string>virt</string>
        <key>Boot</key>
        <dict>
            <key>BootOrder</key>
            <array>
                <string>cd</string>
                <string>hdd</string>
            </array>
        </dict>
    </dict>
    <key>Display</key>
    <dict>
        <key>CardName</key>
        <string>virtio-gpu-pci</string>
        <key>ResolutionHeight</key>
        <integer>800</integer>
        <key>ResolutionWidth</key>
        <integer>1280</integer>
    </dict>
    <key>Networking</key>
    <dict>
        <key>Mode</key>
        <string>shared</string>
    </dict>
    <key>Drives</key>
    <array>
        <dict>
            <key>ImageName</key>
            <string>${storage_uuid}.qcow2</string>
            <key>ImageType</key>
            <string>disk</string>
            <key>Interface</key>
            <string>virtio</string>
            <key>Removable</key>
            <false/>
        </dict>
        <dict>
            <key>ImageName</key>
            <string>archlinux.iso</string>
            <key>ImageType</key>
            <string>cd</string>
            <key>Interface</key>
            <string>usb</string>
            <key>Removable</key>
            <true/>
        </dict>
    </array>
</dict>
</plist>
EOF

    log_success "Created VM at: $vm_path"
    echo "$vm_path"
}

show_next_steps() {
    cat << EOF

${GREEN}═══════════════════════════════════════════════════════════════${NC}
${GREEN}  VM Created Successfully!${NC}
${GREEN}═══════════════════════════════════════════════════════════════${NC}

${BLUE}Next Steps:${NC}

1. Open UTM and find "${VM_NAME}" in the list
2. Start the VM and follow the Arch Linux installation
3. After basic installation, run the automated setup:

   ${YELLOW}# Inside the VM:${NC}
   curl -sSL https://raw.githubusercontent.com/potable-anarchy/ARMarchy/main/scripts/setup-vm.sh | bash

4. Install Omarchy configuration:

   ${YELLOW}# As your user (not root):${NC}
   curl -sSL https://raw.githubusercontent.com/potable-anarchy/ARMarchy/main/scripts/sync-full-omarchy.sh | bash

${BLUE}Documentation:${NC}
- Complete Guide: https://github.com/potable-anarchy/ARMarchy/blob/main/docs/BUILD-VM.md
- Quick Start: https://github.com/potable-anarchy/ARMarchy/blob/main/docs/QUICKSTART.md

${GREEN}═══════════════════════════════════════════════════════════════${NC}

EOF
}

main() {
    echo "${BLUE}"
    cat << "EOF"
   ___                       _
  / _ \ _ __ ___   __ _ _ __| |__  _   _
 | | | | '_ ` _ \ / _` | '__| '_ \| | | |
 | |_| | | | | | | (_| | |  | | | | |_| |
  \___/|_| |_| |_|\__,_|_|  |_| |_|\__, |
                                   |___/
  ARM64 VM Installer
EOF
    echo "${NC}"

    check_requirements

    log_info "Starting Omarchy VM installation..."
    log_info "VM Name: $VM_NAME"
    log_info "RAM: ${VM_RAM}MB"
    log_info "CPUs: ${VM_CPUS}"
    log_info "Disk: ${VM_DISK_SIZE}GB"
    echo

    iso_path=$(download_arch_iso)
    vm_path=$(create_utm_vm "$iso_path")

    show_next_steps
}

# Run main function
main
