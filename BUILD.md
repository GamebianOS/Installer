# Building GamebianOS ISO

This guide will help you build a bootable ISO image of GamebianOS with the Calamares installer.

## Prerequisites

### 1. Install Required Packages

```bash
sudo apt update
sudo apt install -y \
    live-build \
    live-boot \
    live-config \
    live-config-systemd \
    calamares \
    calamares-settings-debian \
    debian-installer-launcher \
    xorriso \
    isolinux \
    syslinux-utils \
    grub-pc-bin \
    grub-efi-amd64-bin \
    mtools \
    dosfstools \
    squashfs-tools
```

### 2. Verify Installation

```bash
which lb
lb --version
```

## Build Process

### Option 1: Quick Build (Recommended)

Use the automated build script:

```bash
cd /home/khinds/Dropbox/Current-Projects/GamebianOS/Installer
chmod +x build-iso.sh
sudo ./build-iso.sh
```

### Option 2: Manual Build

#### Step 1: Initial Configuration

```bash
cd /home/khinds/Dropbox/Current-Projects/GamebianOS/Installer
sudo ./build-gamebianos-qt-installer.sh
```

#### Step 2: Prepare Configuration Files

The build script will automatically copy Calamares configs, but you can verify:

```bash
# Check that configs are in place
ls -la config/includes.chroot/etc/calamares/
ls -la config/includes.chroot/usr/share/calamares/branding/gamebianos/
```

#### Step 3: Build the ISO

```bash
sudo ./build-final.sh
```

## Build Output

After a successful build, you'll find:

- `GamebianOS-1.0-amd64.iso` - The bootable ISO image
- `GamebianOS-1.0-amd64.iso.sha256` - SHA256 checksum
- `GamebianOS-1.0-amd64.iso.md5` - MD5 checksum
- `build.log` - Build log file
- `test-gamebianos.sh` - QEMU test script

## Creating a Bootable USB

Once you have the ISO:

```bash
# Find your USB device (be careful!)
lsblk

# Create bootable USB (replace /dev/sdX with your USB device)
sudo dd if=GamebianOS-1.0-amd64.iso of=/dev/sdX bs=4M status=progress oflag=sync

# Or use a safer method with persistence
sudo live-usb-maker --iso GamebianOS-1.0-amd64.iso --target /dev/sdX
```

## Testing in QEMU

Before burning to USB, test in a virtual machine:

```bash
# Make test script executable
chmod +x test-gamebianos.sh

# Run test (requires QEMU)
./test-gamebianos.sh
```

Or manually:

```bash
qemu-system-x86_64 \
    -cdrom GamebianOS-1.0-amd64.iso \
    -drive file=gamebian-test.qcow2,format=qcow2 \
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
```

## Troubleshooting

### Build Fails with "lb: command not found"

Install live-build:
```bash
sudo apt install live-build
```

### Build Fails with Permission Errors

Make sure you're running with sudo:
```bash
sudo ./build-iso.sh
```

### ISO is Too Large

The ISO should be around 2-4GB. If it's larger:
- Check package lists in `config/package-lists/`
- Remove unnecessary packages
- Use `--apt-recommends false` in lb config

### Calamares Not Found in Live System

Check the build hook:
```bash
cat config/hooks/normal/9999-install-calamares.hook.chroot
```

Make sure Calamares is in the package list:
```bash
grep calamares config/package-lists/gamebian-live.list.chroot
```

## Build Time

Expect the build to take:
- **Fast system (SSD, 8+ cores)**: 30-60 minutes
- **Average system**: 1-2 hours
- **Slow system**: 2-4 hours

The build process downloads and installs all packages, so a good internet connection helps.

## Next Steps

After building:
1. Test the ISO in QEMU
2. Create a bootable USB
3. Boot from USB and test the live environment
4. Install to a test machine or VM
5. Verify Steam Big Picture autostart works
