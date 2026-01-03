# GamebianOS Installer

A Qt-based Calamares installer for GamebianOS, a Steam-first gaming Linux distribution.

## Overview

GamebianOS is a Debian-based Linux distribution optimized for gaming, featuring:
- **Steam-first experience**: Boots directly into Steam Big Picture mode
- **Professional installer**: Qt-based Calamares installer for easy installation
- **Gaming optimizations**: Pre-configured with MangoHud, Gamemode, and gaming tools
- **Desktop access**: Switch to LXQt desktop with Ctrl+Alt+D when needed

## Directory Structure

```
GamebianOS/
├── build-final.sh                    # Main build script
├── build-gamebianos-qt-installer.sh  # Initial build configuration
├── calamares-config/                 # Calamares configuration files
│   ├── settings.conf                 # Main Calamares settings
│   ├── modules/                      # Module configurations
│   │   ├── packages.conf             # Package installation list
│   │   ├── partition.conf            # Partitioning configuration
│   │   ├── users.conf                # User creation settings
│   │   └── postcfg.conf              # Post-installation scripts
│   └── branding/                     # Branding and theming
│       └── gamebianos/
│           ├── branding.desc         # Branding configuration
│           └── show.qml              # Installation slideshow
├── config/                           # Live build configuration
│   ├── hooks/                        # Build hooks
│   │   └── normal/
│   │       └── 9999-install-calamares.hook.chroot
│   ├── includes.chroot/              # Files to include in live system
│   │   ├── etc/calamares/            # Calamares configs (copied during build)
│   │   ├── usr/local/bin/            # Custom scripts
│   │   ├── etc/xdg/autostart/        # Autostart entries
│   │   └── etc/grub.d/               # GRUB menu entries
│   └── package-lists/                 # Package lists for live system
├── scripts/                          # Supporting scripts
│   ├── steam-bigpicture-session      # Steam session launcher
│   ├── exit-to-desktop               # Switch to desktop
│   ├── restart-steam                 # Restart Steam
│   └── start-steam-bigpicture        # Live system Steam launcher
├── QUICKSTART.md                     # Quick start guide
└── README.md                         # This file
```

## Installation Flow

1. **Live ISO Boot** → LXQt desktop with installer icon
2. **User clicks installer** → Qt-based Calamares wizard
3. **Installation process** → Partition, users, packages
4. **Post-install** → Removes installer, sets up Steam-first
5. **Reboot** → Boots directly into Steam Big Picture
6. **Desktop access** → Ctrl+Alt+D switches to LXQt

## Build Process

1. **Initial Setup**: Run `build-gamebianos-qt-installer.sh` to configure live-build
2. **Final Build**: Run `build-final.sh` to create the ISO
3. **Output**: `GamebianOS-1.0-amd64.iso` with checksums

## Configuration

### Calamares Modules

- **partition**: Gaming-optimized partition layouts (separate /home for Steam library)
- **users**: Auto-login enabled, gaming groups included
- **packages**: Comprehensive gaming stack (Steam, MangoHud, Gamemode, etc.)
- **postcfg**: Post-installation setup (Steam autostart, MangoHud config, etc.)

### Partition Layouts

1. **Gaming Optimized (Recommended)**:
   - `/` (50GB, ext4) - System
   - `/home` (remaining, ext4) - Steam library
   - `/boot/efi` (512MB, vfat) - EFI boot
   - `swap` (16GB) - Swap partition

2. **SteamOS Style (Single Partition)**:
   - `/` (all space, ext4) - Everything
   - `/boot/efi` (512MB, vfat) - EFI boot

## Customization

### Branding

Edit `calamares-config/branding/gamebianos/branding.desc` to customize:
- Product name and version
- Colors and styling
- Logo and welcome images

### Packages

Edit `calamares-config/modules/packages.conf` to add/remove packages.

### Partition Layouts

Edit `calamares-config/modules/partition.conf` to customize partition schemes.

## Testing

After building, test the ISO in QEMU:
```bash
./test-gamebianos.sh
```

Or create a bootable USB:
```bash
sudo dd if=GamebianOS-1.0-amd64.iso of=/dev/sdX bs=4M status=progress
```

## Requirements

- Debian Bookworm (or compatible)
- `live-build` package
- `calamares` package (from backports)
- Root/sudo access for building
- At least 20GB free disk space for build

## License

[Add your license here]

## Contributing

[Add contribution guidelines here]
