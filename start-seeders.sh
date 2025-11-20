#!/bin/bash
#
# Start BitTorrent Seeders on Remote Machines
# Run this after VM transfers complete
#

set -e

echo "Starting Omarchy VM seeders on remote machines..."
echo ""

# Mac Studio (100.81.45.56)
echo "=== Mac Studio (100.81.45.56) ==="
ssh 100.81.45.56 'bash -s' << 'EOF'
  # Start transmission daemon
  brew services start transmission-cli 2>/dev/null || transmission-daemon
  sleep 2

  # Add torrent
  transmission-remote -a ~/omarchy-arm64-vm-v1.0.0.torrent

  echo "✓ Seeding started on Mac Studio"
EOF

echo ""

# Devbox (100.120.77.39 - Linux)
echo "=== Devbox (100.120.77.39) ==="
ssh 100.120.77.39 'bash -s' << 'EOF'
  # Start transmission daemon
  sudo systemctl start transmission-daemon
  sleep 2

  # Add torrent
  transmission-remote -a ~/omarchy-arm64-vm-v1.0.0.torrent

  echo "✓ Seeding started on Devbox"
EOF

echo ""

# WSL Box (100.104.133.109 - Linux)
echo "=== WSL Box (100.104.133.109) ==="
ssh 100.104.133.109 'bash -s' << 'EOF'
  # Start transmission daemon
  sudo systemctl start transmission-daemon
  sleep 2

  # Add torrent
  transmission-remote -a ~/omarchy-arm64-vm-v1.0.0.torrent

  echo "✓ Seeding started on WSL Box"
EOF

echo ""
echo "=== Verifying Seeders ==="
echo ""

# Check status on each machine
for host in 100.81.45.56 100.120.77.39 100.104.133.109; do
  echo "Checking $host:"
  ssh $host 'transmission-remote -l | head -5'
  echo ""
done

echo "✓ All seeders started!"
echo ""
echo "To monitor seeding:"
echo "  ssh <host> 'transmission-remote -l'"
