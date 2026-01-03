#!/bin/bash
# ~/GamebianOS/build-gamebianos-qt-installer.sh

set -e
export DEBIAN_FRONTEND=noninteractive

echo "🎮 Building GamebianOS with Qt Installer..."

cd ~/GamebianOS

# Clean previous builds
sudo lb clean
rm -rf config/auto config/includes.chroot/etc/calamares 2>/dev/null || true

# Configure live build with Calamares
lb config \
    --architectures amd64 \
    --distribution trixie \
    --binary-images iso-hybrid \
    --bootappend-live "boot=live components quiet splash" \
    --debian-installer none \
    --apt-indices false \
    --apt-recommends false \
    --cache false \
    --checksums sha256 \
    --mirror-bootstrap "http://deb.debian.org/debian/" \
    --mirror-chroot "http://deb.debian.org/debian/" \
    --security true \
    --updates true \
    --system live \
    --firmware-binary false

# Create directory structure for Calamares
mkdir -p config/includes.chroot/{etc/calamares,usr/share/calamares,usr/share/applications,home/gamebian/Desktop}
mkdir -p config/includes.chroot/usr/share/calamares/branding/gamebianos
