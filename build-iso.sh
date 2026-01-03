#!/bin/bash
# GamebianOS ISO Build Script
# This script builds a complete bootable ISO from the current directory

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🎮 GamebianOS ISO Builder${NC}"
echo "================================"
echo ""

# Check if running as root (needed for lb build)
if [ "$EUID" -ne 0 ]; then 
    echo -e "${YELLOW}⚠️  This script needs sudo privileges.${NC}"
    echo "Please run: sudo $0"
    exit 1
fi

# Check for required tools
echo "🔍 Checking prerequisites..."
MISSING_TOOLS=()

if ! command -v lb &> /dev/null; then
    MISSING_TOOLS+=("live-build")
fi

if ! command -v xorriso &> /dev/null; then
    MISSING_TOOLS+=("xorriso")
fi

if [ ${#MISSING_TOOLS[@]} -ne 0 ]; then
    echo -e "${RED}❌ Missing required tools: ${MISSING_TOOLS[*]}${NC}"
    echo ""
    echo "Install them with:"
    echo "  sudo apt install ${MISSING_TOOLS[*]}"
    exit 1
fi

echo -e "${GREEN}✅ All prerequisites found${NC}"
echo ""

# Clean previous builds if they exist
if [ -d "config" ] && [ -f "config/bootstrap" ]; then
    echo "🧹 Cleaning previous build..."
    lb clean --purge 2>/dev/null || true
    rm -rf config/auto config/includes.chroot/etc/calamares 2>/dev/null || true
fi

# Step 1: Configure live-build
echo "⚙️  Step 1: Configuring live-build..."
lb config \
    --architectures amd64 \
    --distribution bookworm \
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

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Configuration failed!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Configuration complete${NC}"
echo ""

# Step 2: Create directory structure
echo "📁 Step 2: Setting up directory structure..."
mkdir -p config/includes.chroot/{etc/calamares/modules,usr/share/calamares/branding/gamebianos,usr/share/applications,home/gamebian/Desktop}
mkdir -p config/includes.chroot/usr/local/bin
mkdir -p config/includes.chroot/etc/xdg/autostart
mkdir -p config/includes.chroot/etc/grub.d
mkdir -p config/package-lists
mkdir -p config/hooks/normal

echo -e "${GREEN}✅ Directory structure created${NC}"
echo ""

# Step 3: Copy Calamares configuration
echo "📋 Step 3: Installing Calamares configuration..."
if [ -d "calamares-config" ]; then
    # Copy main config
    cp -r calamares-config/* config/includes.chroot/etc/calamares/ 2>/dev/null || true
    
    # Copy branding
    if [ -d "calamares-config/branding" ]; then
        cp -r calamares-config/branding/* config/includes.chroot/usr/share/calamares/branding/gamebianos/
    fi
    
    echo -e "${GREEN}✅ Calamares config copied${NC}"
else
    echo -e "${YELLOW}⚠️  calamares-config directory not found, skipping...${NC}"
fi
echo ""

# Step 4: Copy live system scripts
echo "📜 Step 4: Installing live system scripts..."
if [ -f "config/includes.chroot/usr/local/bin/live-desktop-setup" ]; then
    chmod +x config/includes.chroot/usr/local/bin/live-desktop-setup
    echo -e "${GREEN}✅ Live setup script installed${NC}"
fi

if [ -f "config/includes.chroot/usr/local/bin/start-steam-bigpicture" ]; then
    chmod +x config/includes.chroot/usr/local/bin/start-steam-bigpicture
    echo -e "${GREEN}✅ Steam launcher installed${NC}"
fi
echo ""

# Step 5: Create package list
echo "📦 Step 5: Creating package list..."
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

echo -e "${GREEN}✅ Package list created${NC}"
echo ""

# Step 6: Ensure hooks are executable
echo "🔗 Step 6: Setting up build hooks..."
if [ -f "config/hooks/normal/9999-install-calamares.hook.chroot" ]; then
    chmod +x config/hooks/normal/9999-install-calamares.hook.chroot
    echo -e "${GREEN}✅ Build hooks configured${NC}"
fi
echo ""

# Step 7: Build the ISO
echo "🚀 Step 7: Building ISO (this will take a while)..."
echo "   This may take 30-120 minutes depending on your system and internet speed."
echo ""

lb build 2>&1 | tee build.log

if [ $? -ne 0 ]; then
    echo ""
    echo -e "${RED}❌ Build failed! Check build.log for details.${NC}"
    exit 1
fi

# Step 8: Process output
if [ -f "binary/live-image-amd64.hybrid.iso" ]; then
    # Get version from branding
    VERSION="1.0"
    if [ -f "config/includes.chroot/usr/share/calamares/branding/gamebianos/branding.desc" ]; then
        VERSION=$(grep "^version:" config/includes.chroot/usr/share/calamares/branding/gamebianos/branding.desc | cut -d':' -f2 | tr -d ' ' | head -1)
        if [ -z "$VERSION" ]; then
            VERSION="1.0"
        fi
    fi
    
    ISO_NAME="GamebianOS-${VERSION}-amd64.iso"
    mv binary/live-image-amd64.hybrid.iso "$ISO_NAME"
    
    # Create checksums
    echo "📝 Creating checksums..."
    sha256sum "$ISO_NAME" > "${ISO_NAME}.sha256"
    md5sum "$ISO_NAME" > "${ISO_NAME}.md5"
    
    # Get ISO size
    ISO_SIZE=$(du -h "$ISO_NAME" | cut -f1)
    
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════${NC}"
    echo -e "${GREEN}✅ BUILD SUCCESSFUL!${NC}"
    echo -e "${GREEN}═══════════════════════════════════════${NC}"
    echo ""
    echo "📦 ISO File: $ISO_NAME"
    echo "📏 Size: $ISO_SIZE"
    echo ""
    echo "📋 Features:"
    echo "  • Qt-based Calamares installer"
    echo "  • Boots to Steam Big Picture after install"
    echo "  • Ctrl+Alt+D to switch to LXQt desktop"
    echo "  • Gaming-optimized with MangoHud & Gamemode"
    echo ""
    echo "🔧 Create bootable USB:"
    echo "  sudo dd if=$ISO_NAME of=/dev/sdX bs=4M status=progress oflag=sync"
    echo ""
    echo "   (Replace /dev/sdX with your USB device - use lsblk to find it)"
    echo ""
    echo "🖥️  Test in QEMU:"
    echo "  ./test-gamebianos.sh"
    echo ""
    
    # Create test script
    cat > test-gamebianos.sh << TEST
#!/bin/bash
# Test GamebianOS in QEMU

ISO="$ISO_NAME"
DISK="gamebian-test.qcow2"

# Check for QEMU
if ! command -v qemu-system-x86_64 &> /dev/null; then
    echo "QEMU not found. Install with: sudo apt install qemu-system-x86"
    exit 1
fi

# Create test disk if it doesn't exist
if [ ! -f "\$DISK" ]; then
    echo "Creating test disk image..."
    qemu-img create -f qcow2 "\$DISK" 30G
fi

# Run QEMU
echo "Starting QEMU with GamebianOS..."
qemu-system-x86_64 \\
    -cdrom "\$ISO" \\
    -drive file="\$DISK",format=qcow2 \\
    -m 4096 \\
    -cpu host \\
    -smp 4 \\
    -vga virtio \\
    -display sdl,gl=on \\
    -net nic,model=virtio \\
    -net user \\
    -enable-kvm \\
    -usb \\
    -device usb-tablet
TEST
    chmod +x test-gamebianos.sh
    
    echo -e "${GREEN}✅ Test script created: test-gamebianos.sh${NC}"
    echo ""
    
else
    echo ""
    echo -e "${RED}❌ Build completed but ISO not found!${NC}"
    echo "Check build.log for errors."
    exit 1
fi
