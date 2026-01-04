#!/bin/bash
# GamebianOS ISO Build Script
# This script builds a complete bootable ISO using /tmp for build files
# Final ISO is output to home directory (~)

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Build directory (use /tmp to avoid cluttering the source directory)
BUILD_DIR="/tmp/gamebianos-build-$$"
mkdir -p "$BUILD_DIR"

# Output directory (default to home directory, can be overridden with OUTPUT_DIR env var)
OUTPUT_DIR="${OUTPUT_DIR:-$HOME}"
OUTPUT_DIR="$(eval echo "$OUTPUT_DIR")"  # Expand ~ and variables

# Cleanup function
cleanup() {
    if [ -d "$BUILD_DIR" ]; then
        echo ""
        echo "🧹 Cleaning up build directory: $BUILD_DIR"
        rm -rf "$BUILD_DIR"
    fi
}

# Set trap to cleanup on exit
trap cleanup EXIT

# Change to build directory
cd "$BUILD_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🎮 GamebianOS ISO Builder${NC}"
echo "================================"
echo ""
echo "📁 Build directory: $BUILD_DIR"
echo "📁 Output directory: $OUTPUT_DIR"
echo "   (Set OUTPUT_DIR environment variable to change)"
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

# Step 1: Configure live-build
echo "⚙️  Step 1: Configuring live-build..."
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
    --firmware-binary false \
    --archive-areas "main contrib non-free non-free-firmware"

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
if [ -d "$SCRIPT_DIR/calamares-config" ]; then
    # Copy main config
    cp -r "$SCRIPT_DIR/calamares-config"/* config/includes.chroot/etc/calamares/ 2>/dev/null || true
    
    # Copy branding
    if [ -d "$SCRIPT_DIR/calamares-config/branding" ]; then
        cp -r "$SCRIPT_DIR/calamares-config/branding"/* config/includes.chroot/usr/share/calamares/branding/gamebianos/
    fi
    
    echo -e "${GREEN}✅ Calamares config copied${NC}"
else
    echo -e "${YELLOW}⚠️  calamares-config directory not found, skipping...${NC}"
fi
echo ""

# Step 4: Copy live system scripts and config files
echo "📜 Step 4: Installing live system scripts..."
# Copy includes.chroot files from source directory
if [ -d "$SCRIPT_DIR/config/includes.chroot" ]; then
    cp -r "$SCRIPT_DIR/config/includes.chroot"/* config/includes.chroot/ 2>/dev/null || true
    echo -e "${GREEN}✅ Live system files copied${NC}"
fi

# Copy hooks from source directory
if [ -d "$SCRIPT_DIR/config/hooks" ]; then
    cp -r "$SCRIPT_DIR/config/hooks"/* config/hooks/ 2>/dev/null || true
    echo -e "${GREEN}✅ Build hooks copied${NC}"
fi

# Make scripts executable
find config/includes.chroot/usr/local/bin -type f -exec chmod +x {} \; 2>/dev/null || true
find config/hooks -type f -exec chmod +x {} \; 2>/dev/null || true
echo ""

# Step 5: Create package list
echo "📦 Step 5: Creating package list..."
cat > config/package-lists/gamebian-live.list.chroot << 'EOF'
# Live system packages
calamares
calamares-settings-debian
zenity
polkitd
pkexec
lxqt-core
sddm
htop
qterminal
firefox-esr
EOF

# Note: Steam and neofetch are not in Debian repos
# They will be installed during the actual installation via Calamares
# Steam requires manual download or non-free repository
# neofetch can be installed from backports or built from source
# policykit-1 has been replaced by polkitd and pkexec in Debian 13

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
echo "   Build files are in: $BUILD_DIR"
echo ""

lb build 2>&1 | tee "$BUILD_DIR/build.log"

if [ $? -ne 0 ]; then
    echo ""
    echo -e "${RED}❌ Build failed! Check build.log for details.${NC}"
    echo "Build log: $BUILD_DIR/build.log"
    # Copy build.log to output directory for easier access
    cp "$BUILD_DIR/build.log" "$OUTPUT_DIR/build.log" 2>/dev/null || true
    exit 1
fi

# Step 8: Process output
# Check for ISO in both possible locations
ISO_LOCATION=""
if [ -f "binary/live-image-amd64.hybrid.iso" ]; then
    ISO_LOCATION="binary/live-image-amd64.hybrid.iso"
elif [ -f "live-image-amd64.hybrid.iso" ]; then
    ISO_LOCATION="live-image-amd64.hybrid.iso"
fi

if [ -n "$ISO_LOCATION" ]; then
    # Get version from branding
    VERSION="1.0"
    if [ -f "config/includes.chroot/usr/share/calamares/branding/gamebianos/branding.desc" ]; then
        VERSION=$(grep "^version:" config/includes.chroot/usr/share/calamares/branding/gamebianos/branding.desc | cut -d':' -f2 | tr -d ' ' | head -1)
        if [ -z "$VERSION" ]; then
            VERSION="1.0"
        fi
    fi
    
    # Copy build.log to output directory
    cp "$BUILD_DIR/build.log" "$OUTPUT_DIR/build.log" 2>/dev/null || true
    
    # Ensure output directory exists
    mkdir -p "$OUTPUT_DIR"
    
    ISO_NAME="GamebianOS-${VERSION}-amd64.iso"
    ISO_PATH="$OUTPUT_DIR/$ISO_NAME"
    
    # Move ISO to output directory
    mv "$ISO_LOCATION" "$ISO_PATH"
    
    # Create checksums in output directory
    echo "📝 Creating checksums..."
    cd "$OUTPUT_DIR"
    sha256sum "$ISO_NAME" > "${ISO_NAME}.sha256"
    md5sum "$ISO_NAME" > "${ISO_NAME}.md5"
    cd "$SCRIPT_DIR"
    
    # Get ISO size
    ISO_SIZE=$(du -h "$ISO_PATH" | cut -f1)
    
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════${NC}"
    echo -e "${GREEN}✅ BUILD SUCCESSFUL!${NC}"
    echo -e "${GREEN}═══════════════════════════════════════${NC}"
    echo ""
    echo "📦 ISO File: $ISO_PATH"
    echo "📏 Size: $ISO_SIZE"
    echo ""
    echo "📋 Features:"
    echo "  • Qt-based Calamares installer"
    echo "  • Boots to Steam Big Picture after install"
    echo "  • Ctrl+Alt+D to switch to LXQt desktop"
    echo "  • Gaming-optimized with MangoHud & Gamemode"
    echo ""
    echo "🔧 Create bootable USB:"
    echo "  sudo dd if=\"$ISO_PATH\" of=/dev/sdX bs=4M status=progress oflag=sync"
    echo ""
    echo "   (Replace /dev/sdX with your USB device - use lsblk to find it)"
    echo ""
    echo "🖥️  Test in QEMU:"
    echo "  $OUTPUT_DIR/test-gamebianos.sh"
    echo ""
    
    # Create test script in output directory
    cat > "$OUTPUT_DIR/test-gamebianos.sh" << TEST
#!/bin/bash
# Test GamebianOS in QEMU

ISO="$ISO_PATH"
DISK="$OUTPUT_DIR/gamebian-test.qcow2"

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
    chmod +x "$OUTPUT_DIR/test-gamebianos.sh"
    
    echo -e "${GREEN}✅ Test script created: $OUTPUT_DIR/test-gamebianos.sh${NC}"
    echo ""
    
    # Note about cleanup
    echo "🧹 Build files are in: $BUILD_DIR"
    echo "   These will be automatically cleaned up on script exit."
    echo "   To keep them, cancel the script (Ctrl+C) before it exits."
    echo ""
    
else
    echo ""
    echo -e "${RED}❌ Build completed but ISO not found!${NC}"
    echo "Searched in:"
    echo "  - $BUILD_DIR/binary/live-image-amd64.hybrid.iso"
    echo "  - $BUILD_DIR/live-image-amd64.hybrid.iso"
    echo ""
    echo "Check build.log for errors: $BUILD_DIR/build.log"
    echo "Build directory: $BUILD_DIR"
    echo "You can also search for ISO files:"
    echo "  find $BUILD_DIR -name '*.iso' -type f"
    # Copy build.log to output directory for easier access
    cp "$BUILD_DIR/build.log" "$OUTPUT_DIR/build.log" 2>/dev/null || true
    exit 1
fi
