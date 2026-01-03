# Installation Guide

## What You Get

After building, you'll have a **bootable ISO file** (`GamebianOS-1.0-amd64.iso`) that you can use to:

1. **Boot on any computer** (as a live system)
2. **Install GamebianOS** to the hard drive using the Calamares installer
3. **Test the system** before installing

## Creating Installation Media

### Option 1: USB Drive (Recommended)

**Requirements:**
- USB drive (8GB or larger)
- The ISO file you built

**Steps:**

1. **Find your USB device:**
   ```bash
   lsblk
   ```
   Look for your USB drive (usually `/dev/sdb` or `/dev/sdc`)

2. **Create bootable USB:**
   ```bash
   sudo dd if=GamebianOS-1.0-amd64.iso of=/dev/sdX bs=4M status=progress oflag=sync
   ```
   ⚠️ **WARNING:** Replace `/dev/sdX` with your actual USB device (e.g., `/dev/sdb`). This will **erase everything** on the USB drive!

3. **Verify it worked:**
   ```bash
   # Check the USB has bootable partitions
   sudo fdisk -l /dev/sdX
   ```

### Option 2: DVD/CD

**Requirements:**
- Blank DVD or CD (DVD recommended, 4.7GB+)
- DVD burner

**Steps:**

1. **Burn the ISO:**
   ```bash
   # Using growisofs (if available)
   growisofs -dvd-compat -Z /dev/dvd=GamebianOS-1.0-amd64.iso
   
   # Or use a GUI tool like Brasero, K3b, or GNOME Disks
   ```

2. **Or use GUI tools:**
   - **GNOME Disks**: Right-click ISO → "Restore Disk Image"
   - **K3b**: Tools → Burn ISO Image
   - **Brasero**: Burn Image

## Installing on Another Computer

### Step 1: Boot from USB/DVD

1. **Insert your USB drive or DVD** into the target computer
2. **Power on** the computer
3. **Enter BIOS/UEFI** (usually F2, F12, Del, or Esc during boot)
4. **Change boot order** to boot from USB/DVD first
5. **Save and exit** BIOS
6. **Computer will boot** from your installation media

### Step 2: Live Environment

When the computer boots, you'll see:

1. **GRUB boot menu** with options:
   - GamebianOS Live (Qt Installer) - **Select this**
   - GamebianOS Live (Steam Test Mode)
   - GamebianOS Live (LXQt Desktop Only)
   - GamebianOS Live (Safe Graphics)

2. **System boots** into LXQt desktop with:
   - "Install GamebianOS" icon on desktop
   - "Launch Steam Big Picture" icon (for testing)
   - Welcome dialog

### Step 3: Run the Installer

1. **Double-click** "Install GamebianOS" icon on desktop
2. **Enter password** when prompted (for sudo/polkit)
3. **Calamares installer** opens with Qt interface

### Step 4: Installation Wizard

Follow the Calamares installer steps:

1. **Welcome** - Introduction screen
2. **Location** - Set timezone and locale
3. **Keyboard** - Select keyboard layout
4. **Partitioning** - Choose partition layout:
   - **Gaming Optimized (Recommended)**: Separate `/home` for Steam library
   - **SteamOS Style**: Single partition
   - **Manual**: Custom partitioning
5. **Users** - Create your user account:
   - Username (default: gamebian)
   - Password
   - Auto-login enabled by default
6. **Summary** - Review your choices
7. **Install** - Click "Install" to begin
8. **Progress** - Watch the installation progress
9. **Finished** - Installation complete!

### Step 5: Reboot

1. **Click "Restart Now"** in the installer
2. **Remove USB/DVD** when prompted
3. **Computer reboots** into installed GamebianOS
4. **Auto-login** → **Steam Big Picture** starts automatically! 🎮

## Post-Installation

### First Boot

After installation, the system will:
- ✅ Auto-login to your user account
- ✅ Start Steam Big Picture automatically
- ✅ Be ready to play games!

### Switching to Desktop

If you need the LXQt desktop:
- **Press `Ctrl+Alt+D`** to switch from Steam to desktop
- Or exit Steam Big Picture

### Returning to Steam

- Click the Steam icon in the desktop
- Or run: `restart-steam` in terminal

## System Requirements

**Minimum:**
- CPU: 64-bit processor (x86_64)
- RAM: 4GB (8GB recommended)
- Storage: 64GB free space (128GB+ recommended)
- Graphics: DirectX 11 compatible GPU

**Recommended:**
- CPU: 4+ cores
- RAM: 16GB
- Storage: 256GB+ SSD
- Graphics: NVIDIA or AMD dedicated GPU

## Troubleshooting

### Computer Won't Boot from USB

1. **Check BIOS settings:**
   - Enable "USB Boot" or "Legacy USB Support"
   - Disable "Secure Boot" (or add USB to trusted devices)
   - Set USB as first boot device

2. **Try different USB port:**
   - Use USB 2.0 port instead of USB 3.0
   - Try ports on the back of the computer

3. **Recreate USB:**
   - Use different USB drive
   - Re-download/recreate ISO

### Installer Won't Start

1. **Check permissions:**
   - Make sure you're clicking the desktop icon
   - Enter password when prompted

2. **Try terminal:**
   ```bash
   sudo calamares -d
   ```

3. **Check logs:**
   ```bash
   journalctl -f
   ```

### Installation Fails

1. **Check disk space:**
   - Need at least 64GB free
   - Check partition sizes

2. **Check internet:**
   - Some packages download during install
   - Ensure stable connection

3. **Try safe graphics mode:**
   - Boot with "Safe Graphics" option
   - May help with graphics driver issues

### Steam Won't Start After Install

1. **Check graphics drivers:**
   ```bash
   lspci | grep VGA
   glxinfo | grep "OpenGL renderer"
   ```

2. **Install drivers manually:**
   ```bash
   sudo apt update
   sudo apt install nvidia-driver  # For NVIDIA
   # or
   sudo apt install mesa-vulkan-drivers  # For AMD/Intel
   ```

3. **Check Steam installation:**
   ```bash
   which steam
   steam --version
   ```

## What Gets Installed

The installer installs:
- ✅ Debian Bookworm base system
- ✅ Linux kernel with gaming optimizations
- ✅ Steam and gaming tools (MangoHud, Gamemode, etc.)
- ✅ LXQt desktop environment
- ✅ Graphics drivers (NVIDIA/AMD)
- ✅ Audio system (PulseAudio)
- ✅ Network manager
- ✅ All configured packages from `packages.conf`

## Uninstalling (If Needed)

If you want to remove GamebianOS:

1. **Boot from another OS** or live USB
2. **Delete partitions** created during installation
3. **Fix bootloader** (if dual-booting):
   ```bash
   # From another Linux system
   sudo grub-install /dev/sda
   sudo update-grub
   ```

## Support

For issues or questions:
- Check `build.log` for build issues
- Check system logs: `journalctl -xe`
- Review Calamares logs: `/var/log/calamares/`
