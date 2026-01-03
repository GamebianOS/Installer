# Quick Build Guide

## Fastest Way to Build the ISO

### 1. Install Prerequisites (One-time setup)

```bash
sudo apt update
sudo apt install -y live-build live-boot live-config live-config-systemd \
    calamares calamares-settings-debian xorriso isolinux syslinux-utils \
    grub-pc-bin grub-efi-amd64-bin mtools dosfstools squashfs-tools
```

### 2. Build the ISO

```bash
cd /home/khinds/Dropbox/Current-Projects/GamebianOS/Installer
sudo ./build-iso.sh
```

That's it! The script will:
- ✅ Check prerequisites
- ✅ Configure live-build
- ✅ Copy all configuration files
- ✅ Build the ISO
- ✅ Create checksums
- ✅ Generate a test script

### 3. Expected Output

After 30-120 minutes, you'll have:
- `GamebianOS-1.0-amd64.iso` - Your bootable ISO
- `GamebianOS-1.0-amd64.iso.sha256` - Checksum
- `GamebianOS-1.0-amd64.iso.md5` - Checksum
- `test-gamebianos.sh` - QEMU test script
- `build.log` - Build log

### 4. Create Bootable USB

```bash
# Find your USB device
lsblk

# Create bootable USB (replace /dev/sdX with your device)
sudo dd if=GamebianOS-1.0-amd64.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

### 5. Test First (Optional)

Before using on real hardware, test in QEMU:

```bash
# Install QEMU if needed
sudo apt install qemu-system-x86

# Run test
./test-gamebianos.sh
```

## Troubleshooting

**"lb: command not found"**
```bash
sudo apt install live-build
```

**"Permission denied"**
```bash
# Make sure you're using sudo
sudo ./build-iso.sh
```

**Build takes too long**
- Normal! First build downloads ~2-4GB of packages
- Subsequent builds are faster (uses cache)
- Good internet connection helps

**Out of disk space**
- Need at least 10GB free
- Build creates temporary files in `config/` directory

## What Happens During Build?

1. **Configuration** (1-2 min) - Sets up live-build
2. **Bootstrap** (5-10 min) - Downloads base Debian 13 "Trixie" system
3. **Chroot Setup** (2-5 min) - Prepares build environment
4. **Package Installation** (20-60 min) - Installs all packages
5. **ISO Creation** (5-10 min) - Creates bootable ISO

Total: **30-120 minutes** depending on system speed and internet.

## Next Steps After Build

1. ✅ Test ISO in QEMU: `./test-gamebianos.sh`
2. ✅ Create bootable USB
3. ✅ Boot from USB and test live environment
4. ✅ Install to test machine/VM
5. ✅ Verify Steam Big Picture autostart
