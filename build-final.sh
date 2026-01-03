#!/bin/bash
# ~/GamebianOS/build-final.sh

set -e

echo "🔧 GamebianOS Final Build with Qt Installer"
echo "=========================================="

cd ~/GamebianOS

# Create necessary directories
mkdir -p config/package-lists/
mkdir -p config/includes.chroot/etc/calamares/modules/
mkdir -p config/includes.chroot/usr/share/calamares/branding/gamebianos/

# Copy Calamares configuration
if [ -d "calamares-config/" ]; then
    cp -r calamares-config/* config/includes.chroot/etc/calamares/
    cp -r calamares-config/branding/* config/includes.chroot/usr/share/calamares/branding/gamebianos/
fi

# Create package list for live system
cat > config/package-lists/gamebian-live.list.chroot << 'EOF'
# Live system packages
calamares
calamares-settings-debian
zenity
policykit-1-gnome
lxqt-core
sddm
steam
neofetch
htop
qterminal
firefox-esr
EOF

# Build the ISO
echo "🚀 Starting build process..."
sudo lb build 2>&1 | tee build.log

if [ -f live-image-amd64.hybrid.iso ]; then
    # Get version from branding
    VERSION=$(grep "version:" config/includes.chroot/usr/share/calamares/branding/gamebianos/branding.desc | cut -d':' -f2 | tr -d ' ' | head -1)
    
    mv live-image-amd64.hybrid.iso "GamebianOS-${VERSION}-amd64.iso"
    
    # Create checksums
    sha256sum "GamebianOS-${VERSION}-amd64.iso" > "GamebianOS-${VERSION}-amd64.iso.sha256"
    md5sum "GamebianOS-${VERSION}-amd64.iso" > "GamebianOS-${VERSION}-amd64.iso.md5"
    
    echo ""
    echo "✅ BUILD SUCCESSFUL!"
    echo "===================="
    echo "ISO: GamebianOS-${VERSION}-amd64.iso"
    echo "Size: $(du -h "GamebianOS-${VERSION}-amd64.iso" | cut -f1)"
    echo ""
    echo "📋 Features:"
    echo "  • Qt-based Calamares installer"
    echo "  • Boots to Steam Big Picture after install"
    echo "  • Ctrl+Alt+D to switch to LXQt desktop"
    echo "  • Gaming-optimized with MangoHud & Gamemode"
    echo ""
    echo "🔧 Create bootable USB:"
    echo "  sudo dd if=GamebianOS-${VERSION}-amd64.iso of=/dev/sdX bs=4M status=progress"
    echo ""
    echo "🖥️ Test in QEMU:"
    echo "  ./test-gamebianos.sh"
    
    # Create test script
    cat > test-gamebianos.sh << TEST
#!/bin/bash
# Test GamebianOS in QEMU

ISO="GamebianOS-${VERSION}-amd64.iso"
DISK="gamebian-test.qcow2"

# Create test disk if it doesn't exist
if [ ! -f "$DISK" ]; then
    qemu-img create -f qcow2 "$DISK" 30G
fi

# Run QEMU
qemu-system-x86_64 \
    -cdrom "$ISO" \
    -drive file="$DISK",format=qcow2 \
    -m 4096 \
    -cpu host \
    -smp 4 \
    -vga virtio \
    -display sdl,gl=on \
    -net nic,model=virtio \
    -net user \
    -enable-kvm \
    -usb \
    -device usb-tablet
TEST
    chmod +x test-gamebianos.sh
    
else
    echo "❌ Build failed! Check build.log for details."
    exit 1
fi
