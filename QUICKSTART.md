# GamebianOS with Qt Installer - Quick Start

## Build Instructions:

1. Install dependencies:
   ```bash
   sudo apt install live-build calamares calamares-settings-debian
   ```

2. Clone configuration:
   ```bash
   git clone https://github.com/yourusername/GamebianOS.git
   cd GamebianOS
   ```

3. Build the ISO:
   ```bash
   chmod +x build-final.sh
   sudo ./build-final.sh
   ```

## User Experience Flow:

### Live ISO:
1. Boot from USB/DVD
2. See LXQt desktop with:
   - "Install GamebianOS" icon
   - "Launch Steam" icon
   - Welcome app
3. Click installer → Qt-based setup wizard
4. Follow installation steps

### Installed System:
1. Boot → Auto-login → Steam Big Picture
2. Play games immediately
3. Need desktop? Press Ctrl+Alt+D
4. Want Steam back? Click Steam icon or run 'restart-steam'

## Features:
- Professional Qt installer (Calamares)
- Steam-first boot experience
- Minimal LXQt desktop available
- Gaming optimizations pre-configured
- NVIDIA/AMD driver support
- Easy desktop switching
