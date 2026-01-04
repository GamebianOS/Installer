# Package Installation Notes

## Packages Not Available in Debian Repositories

### Steam

Steam is **not available** in the standard Debian repositories. It needs to be installed manually or via Steam's official installer.

**Options:**

1. **Manual Installation (Recommended)**:
   - Download Steam .deb from https://store.steampowered.com/about/
   - Install during post-installation setup
   - Or install via post-install script

2. **Via Post-Install Script**:
   ```bash
   wget -O /tmp/steam.deb https://cdn.akamai.steamstatic.com/client/installer/steam.deb
   sudo dpkg -i /tmp/steam.deb
   sudo apt-get install -f  # Fix dependencies
   ```

3. **For Live System**:
   - Steam is not included in the live ISO
   - Users can test the installer without Steam
   - Steam will be installed during the actual installation process

### neofetch

`neofetch` may not be available in Debian 13 "Trixie" main repositories.

**Options:**

1. **Install from source**:
   ```bash
   git clone https://github.com/dylanaraps/neofetch.git
   cd neofetch
   sudo make install
   ```

2. **Use alternative**: `fastfetch` or `screenfetch`

3. **Skip for live system**: Not critical for live environment

### policykit-1 / policykit-1-gnome

In Debian 13 "Trixie", `policykit-1` and `policykit-1-gnome` have been replaced.

**Solution:**
- Use `polkitd` (PolicyKit daemon)
- Use `pkexec` (PolicyKit execution utility)
- For LXQt: `polkit-kde-agent` or `lxqt-policykit` (if available)
- For GNOME: `gnome-polkit` or similar

**Updated package names:**
- `policykit-1` → `polkitd` + `pkexec`
- `policykit-1-gnome` → Use `polkitd` + `pkexec` + appropriate GUI agent

## Updated Package Lists

### Live System (gamebian-live.list.chroot)
- Removed: `steam`, `neofetch`, `policykit-1-gnome`
- Added: `policykit-1`
- Steam will be installed during actual installation

### Installation System (packages.conf)
- Steam installation should be handled via post-install script
- neofetch can be installed from source or alternative
- All other packages should be available in Debian repositories

## Repository Configuration

The build script now includes:
- `main` - Standard Debian packages
- `contrib` - Packages with dependencies not in main
- `non-free` - Non-free software
- `non-free-firmware` - Non-free firmware

This ensures access to firmware and drivers needed for gaming hardware.
