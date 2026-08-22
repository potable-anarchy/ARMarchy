# Download Omarchy ARM64 VM via Torrent

The prebuilt Omarchy ARM64 VM is available as a BitTorrent download.

## Quick Start

### Option 1: Magnet Link (Easiest)

Click this magnet link or paste it into your torrent client:

```
magnet:?xt=urn:btih:b8edadd5b6293ee2e72194cd9d4ff008d5a90b2f&dn=omarchy-arm64-vm-v1.0.0&tr=udp://tracker.opentrackr.org:1337/announce&tr=udp://open.tracker.cl:1337/announce&tr=udp://tracker.torrent.eu.org:451/announce&tr=udp://exodus.desync.com:6969/announce&tr=udp://tracker.moeking.me:6969/announce&tr=udp://opentracker.i2p.rocks:6969/announce
```

### Option 2: Torrent File

Download the `.torrent` file and open it with your torrent client:

**[Download omarchy-arm64-vm-v1.0.0.torrent](https://github.com/potable-anarchy/ARMarchy/raw/main/omarchy-arm64-vm-v1.0.0.torrent)**

## VM Details

- **Size:** 13GB (actual), 93GB (full disk image)
- **Format:** UTM bundle (.utm)
- **Arch:** ARM64 (Apple Silicon only)
- **OS:** Arch Linux ARM with Hyprland + Omarchy configs
- **Hash:** `b8edadd5b6293ee2e72194cd9d4ff008d5a90b2f`

## Recommended Torrent Clients

### macOS
- **Transmission** (Free, lightweight) - [Download](https://transmissionbt.com/)
- **qBittorrent** (Free, feature-rich) - [Download](https://www.qbittorrent.org/)

### Installation

```bash
# Via Homebrew
brew install --cask transmission
# or
brew install --cask qbittorrent
```

## Download Instructions

1. **Install a torrent client** (see above)

2. **Download the VM:**
   - Open the magnet link, or
   - Download and open the `.torrent` file

3. **Wait for download to complete** (13GB download)

4. **Find the downloaded files:**
   - Default location: `~/Downloads/omarchy-arm64-vm-v1.0.0.utm/`

5. **Open in UTM:**
   ```bash
   open ~/Downloads/omarchy-arm64-vm-v1.0.0.utm
   ```

## After Download

### First Boot

1. UTM will import the VM automatically
2. Start the VM from UTM's interface
3. Login credentials:
   - **Username:** `omarchy`
   - **Password:** `omarchy`

4. Start Hyprland:
   ```bash
   ./start-omarchy.sh
   ```

### Verify Download

Check the info hash matches:

```bash
transmission-show ~/Downloads/omarchy-arm64-vm-v1.0.0.torrent | grep Hash
# Should show: Hash v1: b8edadd5b6293ee2e72194cd9d4ff008d5a90b2f
```

## Seeding (Optional but Appreciated!)

**Please seed after downloading!** This helps others get the VM faster.

- **Recommended:** Seed for at least 24 hours or 1:1 ratio
- **Ideal:** Keep seeding as long as possible

## Troubleshooting

### "No seeds available"

The initial seeding is happening. Please be patient or:
1. Try again later
2. Use the [build-from-source method](docs/BUILD-VM.md)
3. Check GitHub Discussions for updates

### Download is slow

- Check your torrent client's connection settings
- Ensure ports are properly forwarded
- Try adding more trackers

### VM won't import to UTM

1. Ensure you downloaded the complete `omarchy-arm64-vm-v1.0.0.utm` folder
2. Check that UTM is installed
3. Try double-clicking the `.utm` folder

### VM won't boot

1. Verify download completed (check info hash)
2. Check UTM settings match requirements (virtio-gpu-pci display)
3. See [troubleshooting guide](docs/BUILD-VM.md#troubleshooting)

## Alternative Download Methods

If torrenting doesn't work:

1. **Build from source** - [Build Guide](docs/BUILD-VM.md)
2. **Use the installer** - [Installer Guide](installer/README.md)

## System Requirements

- **Mac:** Apple Silicon (M1/M2/M3/M4)
- **macOS:** 12.0+ (Monterey or later)
- **UTM:** Latest version ([Download](https://mac.getutm.app))
- **Disk Space:** 100GB free (VM expands as needed)
- **RAM:** 8GB+ recommended

## What's Included

Complete Omarchy environment with:
- Hyprland 0.52.1 with Omarchy configs
- Waybar, Mako, Wayland stack
- 100+ packages (CLI tools, GUI apps)
- 50+ Omarchy utility scripts
- Pre-configured for immediate use

## Support

- **GitHub Issues:** [Report problems](https://github.com/potable-anarchy/ARMarchy/issues)
- **Discussions:** [Ask questions](https://github.com/potable-anarchy/ARMarchy/discussions)
- **Documentation:** [Browse docs](docs/)

## License

MIT License - see [LICENSE](LICENSE)

## Seeding Info

**Initial Seeder:** potable-anarchy  
**Seed Status:** Check GitHub for current seeder availability

---

**Happy torrenting!** 🌊
